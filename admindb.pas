unit admindb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, oracleconnection, sqldb, IniFiles, ZConnection, ZDataset,db;
  //Classes, SysUtils, oracleconnection, sqldb, IniFiles;
  function obtiene_archivo_ini():String;
  function lector_ini():TStringList;
  function conexion():TZConnection;
  procedure verifica_fecha_retiro(empresa,cod_aduana,ano_pre,cod_regi,num_dua,num_orden:String);
  procedure graba_datos(empresa,cod_aduana,ano_pre,cod_regi,num_dua,num_orden,tipo_doc,archivo:String;contenido:TStrings);
  procedure muestra_html(empresa,cod_aduana,ano_pre,cod_regi,num_dua,num_orden:String);

implementation

function obtiene_archivo_ini():String;
var
  config_file: String;

begin
  config_file:=ExtractFilePath(ParamStr(0))+'config.ini';
  result:=config_file;
end;

// Lee los datos de conexion del archivo INI
function lector_ini():TStringList;
var
  parameters_conexion: TStringList;
  hostname,databasename,username,password: String;
  config_file,port,protocol: String;
  Ini:TIniFile;

begin
  config_file:=obtiene_archivo_ini();

  try
     Ini:= TIniFile.Create(config_file);

     hostname:=Ini.ReadString('db','hostname','');
     databasename:=Ini.ReadString('db','database','');
     username:=Ini.ReadString('db','username','');
     password:=Ini.ReadString('db','password','');
     port:=Ini.ReadString('db','port','');
     protocol:=Ini.ReadString('db','protocol','');

     Ini.Free;

  except on e: Exception do
  begin
    WriteLn('Error al leer el archivo de configuracion: ',e.Message);
    WriteLn(e.Message);
    Exit;
  end;

  end;

  parameters_conexion:=TStringList.Create;
  parameters_conexion.Add(hostname);
  parameters_conexion.Add(databasename);
  parameters_conexion.Add(username);
  parameters_conexion.Add(password);
  parameters_conexion.Add(port);
  parameters_conexion.Add(protocol);

  result:=parameters_conexion;
end;

// Genera la conexion a la base de datos
function conexion():TZConnection;
var
  // Crea una conexion
  conexion_oracle: TZConnection;
  parameters_conexion: TStringList;

begin
  parameters_conexion:=lector_ini();

  conexion_oracle:=TZConnection.Create(nil);

  conexion_oracle.HostName:=parameters_conexion[0];
  conexion_oracle.Database:=parameters_conexion[1];
  conexion_oracle.User:=parameters_conexion[2];
  conexion_oracle.Password:=parameters_conexion[3];
  conexion_oracle.Port:=StrtoInt(parameters_conexion[4]);
  conexion_oracle.Protocol:=parameters_conexion[5];
  conexion_oracle.AutoCommit:=False;

  conexion_oracle.Connected:=True;

  try
     conexion_oracle.Connected:=True;
     result:=conexion_oracle;
  except on e: Exception do
  begin
    WriteLn('Error al realizar la conexion a la Base de Datos: ',e.Message);
    WriteLn(e.Message);
    Exit;
  end;
  end;

end;

procedure verifica_fecha_retiro(empresa,cod_aduana,ano_pre,cod_regi,num_dua,num_orden:String);
var
  conexion_oracle: TZConnection;
  query_oracle: TZQuery;
  query_select: String;
  parameters_conexion:TStringList;
  local_file:String;
  rows_affected:Integer;
begin
  query_select:='SELECT COUNT(*) CONTADOR FROM ORDEN WHERE';
  query_select:=query_select+' EMPRESA=:EMPRESA AND ANO_PRESE=:ANO_PRESE';
  query_select:=query_select+' AND CODI_ADUAN=:CODI_ADUAN AND CODI_REGI=:CODI_REGI';
  query_select:=query_select+' AND NUME_ORDEN=:NUME_ORDEN AND NUM_DUA=:NUM_DUA';
  query_select:=query_select+' AND FEC_RETIRO IS NOT NULL';

  try
     parameters_conexion:=lector_ini();

     conexion_oracle:=conexion();
     query_oracle:=TZQuery.create(nil);

     query_oracle.Connection:=conexion_oracle;
     query_oracle.SQL.Clear;

     query_oracle.SQL.Add(query_select);
     query_oracle.ParamByName('EMPRESA').AsString:=empresa;
     query_oracle.ParamByName('ANO_PRESE').AsString:=ano_pre;
     query_oracle.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
     query_oracle.ParamByName('CODI_REGI').AsString:=cod_regi;
     query_oracle.ParamByName('NUME_ORDEN').AsString:=num_orden;
     query_oracle.ParamByName('NUM_DUA').AsString:=num_dua;

     query_oracle.Prepare;

     query_oracle.Open;
     rows_affected:=query_oracle.FieldByName('CONTADOR').AsInteger;
     query_oracle.Close;

     conexion_oracle.Commit;
  finally
  end;

end;

// Muestra la pagina web
procedure muestra_html(empresa,cod_aduana,ano_pre,cod_regi,num_dua,num_orden:String);
var
  conexion_oracle: TZConnection;
  query_oracle: TZQuery;
  query_select: String;
  parameters_conexion:TStringList;
  local_file:String;

begin
  query_select:='SELECT ARCHIVO_LOCAL FROM ORDEN_SEMAFORO_WEB WHERE';
  query_select:=query_select+' EMPRESA=:EMPRESA AND ANO_PRESE=:ANO_PRESE';
  query_select:=query_select+' AND CODI_ADUAN=:CODI_ADUAN AND CODI_REGI=:CODI_REGI';
  query_select:=query_select+' AND NUME_ORDEN=:NUME_ORDEN AND NUM_DUA=:NUM_DUA';

  try
     parameters_conexion:=lector_ini();

     conexion_oracle:=conexion();
     query_oracle:=TZQuery.create(nil);

     query_oracle.Connection:=conexion_oracle;
     query_oracle.SQL.Clear;

     query_oracle.SQL.Add(query_select);
     query_oracle.ParamByName('EMPRESA').AsString:=empresa;
     query_oracle.ParamByName('ANO_PRESE').AsString:=ano_pre;
     query_oracle.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
     query_oracle.ParamByName('CODI_REGI').AsString:=cod_regi;
     query_oracle.ParamByName('NUME_ORDEN').AsString:=num_orden;
     query_oracle.ParamByName('NUM_DUA').AsString:=num_dua;

     query_oracle.Prepare;

     query_oracle.Open;
     local_file:=query_oracle.FieldByName('ARCHIVO_LOCAL').AsString;
     WriteLn(local_file);
     query_oracle.Close;

     conexion_oracle.Commit;
  finally
  end;

end;

// Ejecuta la sentencia
procedure graba_datos(empresa,cod_aduana,ano_pre,cod_regi,num_dua,num_orden,tipo_doc,archivo:String;contenido:TStrings);
var
  // Crea una conexion
  conexion_oracle: TZConnection;
  query_oracle: TZQuery;
  query_insert,query_select,query_update,query_select2:String;
  parameters_conexion:TStringList;
  tiempo_actual:TDateTime;
  rows_affected:Integer;

begin

  query_select:='SELECT COUNT(*) CONTADOR FROM ORDEN_SEMAFORO_WEB WHERE';
  query_select:=query_select+' EMPRESA=:EMPRESA AND ANO_PRESE=:ANO_PRESE';
  query_select:=query_select+' AND CODI_ADUAN=:CODI_ADUAN AND CODI_REGI=:CODI_REGI';
  query_select:=query_select+' AND NUME_ORDEN=:NUME_ORDEN AND NUM_DUA=:NUM_DUA';

  tiempo_actual:=Now;

  try
     parameters_conexion:=lector_ini();

     conexion_oracle:=conexion();
     query_oracle:=TZQuery.create(nil);

     query_oracle.Connection:=conexion_oracle;

     query_oracle.SQL.Clear;

     query_oracle.SQL.Add(query_select);
     query_oracle.ParamByName('EMPRESA').AsString:=empresa;
     query_oracle.ParamByName('ANO_PRESE').AsString:=ano_pre;
     query_oracle.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
     query_oracle.ParamByName('CODI_REGI').AsString:=cod_regi;
     query_oracle.ParamByName('NUME_ORDEN').AsString:=num_orden;
     query_oracle.ParamByName('NUM_DUA').AsString:=num_dua;

     query_oracle.Prepare;

     query_oracle.Open;
     rows_affected:=query_oracle.FieldByName('CONTADOR').AsInteger;
     query_oracle.Close;

     if (rows_affected = 0) then
     begin

       query_insert:='INSERT INTO ORDEN_SEMAFORO_WEB (EMPRESA,ANO_PRESE,CODI_ADUAN,CODI_REGI,NUME_ORDEN,';
       query_insert:=query_insert+'NUM_DUA,EST_INTRUSIVO,FECHA_CREACION,FECHA_ACTUAL,CONTENIDO_WEB,';
       query_insert:=query_insert+'ARCHIVO_LOCAL) VALUES (';
       query_insert:=query_insert+':EMPRESA,:ANO_PRESE,:CODI_ADUAN,:CODI_REGI,:NUME_ORDEN,:NUM_DUA,';
       query_insert:=query_insert+':EST_INTRUSIVO,:FECHA_CREACION,:FECHA_ACTUAL,:CONTENIDO,:ARCHIVO)';

       query_oracle.SQL.Clear;
       query_oracle.SQL.Add(query_insert);
       query_oracle.ParamByName('EMPRESA').AsString:=empresa;
       query_oracle.ParamByName('ANO_PRESE').AsString:=ano_pre;
       query_oracle.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
       query_oracle.ParamByName('CODI_REGI').AsString:=cod_regi;
       query_oracle.ParamByName('NUME_ORDEN').AsString:=num_orden;
       query_oracle.ParamByName('NUM_DUA').AsString:=num_dua;
       query_oracle.ParamByName('EST_INTRUSIVO').AsInteger:=0;
       query_oracle.ParamByName('FECHA_CREACION').AsDate:=tiempo_actual;
       query_oracle.ParamByName('FECHA_ACTUAL').AsDate:=tiempo_actual;
       query_oracle.ParamByName('CONTENIDO').AsBlob:=contenido.Text;
       query_oracle.ParamByName('ARCHIVO').AsString:=archivo;
     end
     else
     begin

       query_select2:='SELECT FECHA_ACTUAL, ARCHIVO_LOCAL FROM ORDEN_SEMAFORO_WEB WHERE';
       query_select2:=query_select2+' EMPRESA=:EMPRESA AND ANO_PRESE=:ANO_PRESE';
       query_select2:=query_select2+' AND CODI_ADUAN=:CODI_ADUAN AND CODI_REGI=:CODI_REGI';
       query_select2:=query_select2+' AND NUME_ORDEN=:NUME_ORDEN AND NUM_DUA=:NUM_DUA'
       ;

       query_oracle.SQL.Clear;

       query_oracle.SQL.Add(query_select2);
       query_oracle.ParamByName('EMPRESA').AsString:=empresa;
       query_oracle.ParamByName('ANO_PRESE').AsString:=ano_pre;
       query_oracle.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
       query_oracle.ParamByName('CODI_REGI').AsString:=cod_regi;
       query_oracle.ParamByName('NUME_ORDEN').AsString:=num_orden;
       query_oracle.ParamByName('NUM_DUA').AsString:=num_dua;

       query_oracle.Prepare;
       query_oracle.Open;
       fecha_ultimo_actualizacion:=query_oracle.FieldByName('FECHA_ACTUAL').AsDateTime;
       archivo_local:=query_oracle.FieldByName('ARCHIVO_LOCAL').AsString;
       query_oracle.Close;



       query_update:='UPDATE ORDEN_SEMAFORO_WEB SET CONTENIDO_WEB=:CONTENIDO, FECHA_ACTUAL=:FECHA_ACTUAL,';
       query_update:=query_update+' ARCHIVO_LOCAL=:ARCHIVO';
       query_update:=query_update+' WHERE EMPRESA=:EMPRESA AND ANO_PRESE=:ANO_PRESE';
       query_update:=query_update+' AND CODI_ADUAN=:CODI_ADUAN AND CODI_REGI=:CODI_REGI';
       query_update:=query_update+' AND NUME_ORDEN=:NUME_ORDEN';

       query_oracle.SQL.Clear;
       query_oracle.SQL.Add(query_update);
       query_oracle.ParamByName('EMPRESA').AsString:=empresa;
       query_oracle.ParamByName('ANO_PRESE').AsString:=ano_pre;
       query_oracle.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
       query_oracle.ParamByName('CODI_REGI').AsString:=cod_regi;
       query_oracle.ParamByName('NUME_ORDEN').AsString:=num_orden;
       query_oracle.ParamByName('FECHA_ACTUAL').AsDate:=tiempo_actual;
       query_oracle.ParamByName('CONTENIDO').AsBlob:=contenido.Text;
       query_oracle.ParamByName('ARCHIVO').AsString:=archivo;
     end;

     query_oracle.Prepare;
     query_oracle.ExecSQL;
     query_oracle.Close;

     conexion_oracle.Commit;

  except on e: Exception do
  begin
    WriteLn('Error al realizar la conexion a la Base de Datos: ',e.Message);
    WriteLn(e.Message);
    Exit;
  end;
  end;
end;


end.

