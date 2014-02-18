unit admindb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, oracleconnection, sqldb, IniFiles;
  function obtiene_archivo_ini():String;
  function lector_ini():TStringList;
  function conexion():TOracleConnection;
  procedure ejecuta_query(string_query:TSQLQuery);
  procedure ejecuta_insert(cod_aduana,ano_pre,cod_regi,num_dua,tipo_doc:String;contenido:TStrings);

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
  config_file: String;
  Ini:TIniFile;

begin
  config_file:=obtiene_archivo_ini();

  try
     Ini:= TIniFile.Create(config_file);

     hostname:=Ini.ReadString('db','hostname','');
     databasename:=Ini.ReadString('db','database','');
     username:=Ini.ReadString('db','username','');
     password:=Ini.ReadString('db','password','');

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

  result:=parameters_conexion;
end;

// Genera la conexion a la base de datos
function conexion():TOracleConnection;
var
  // Crea una conexion
  conexion_oracle: TOracleConnection;
  parameters_conexion: TStringList;

begin
  parameters_conexion:=lector_ini();

  conexion_oracle:=TOracleConnection.Create(nil);

  conexion_oracle.HostName:=parameters_conexion[0];
  conexion_oracle.DatabaseName:=parameters_conexion[1];
  conexion_oracle.UserName:=parameters_conexion[2];
  conexion_oracle.Password:=parameters_conexion[3];

  try
     conexion_oracle.Connected:=True;
     //WriteLn('Conexion satisfactoria a SIG');
     result:=conexion_oracle;
  except on e: Exception do
  begin
    WriteLn('Error al realizar la conexion a la Base de Datos: ',e.Message);
    WriteLn(e.Message);
    Exit;
  end;
  end;

end;

// Ejecuta la sentencia
procedure ejecuta_query(string_query:TSQLQuery);
var
  // Crea una conexion
  conexion_oracle: TOracleConnection;
  query_oracle: TSQLQuery;
  transaction_oracle: TSQLTransaction;

begin

  try
     conexion_oracle:=conexion();
     //WriteLn('Conexion satisfactoria a SIG');

     transaction_oracle:=TSQLTransaction.Create(nil);
     query_oracle:=TSQLQuery.create(nil);
     query_oracle:=string_query;

     conexion_oracle.Transaction:=transaction_oracle;
     transaction_oracle.DataBase:=conexion_oracle;
     query_oracle.DataBase:=conexion_oracle;
     query_oracle.Transaction:=transaction_oracle;

     transaction_oracle.StartTransaction;

     query_oracle.SQL.Clear;
     //query_oracle.SQL:= string_query.SQL;
     query_oracle.ExecSQL;
     query_oracle.SQL.Clear;

     transaction_oracle.Commit;
     transaction_oracle.Free;

     query_oracle.Close;
     query_oracle.Free;

     conexion_oracle.Close;
     conexion_oracle.Free;

  except on e: Exception do
  begin
    WriteLn('Error al realizar la conexion a la Base de Datos: ',e.Message);
    WriteLn(e.Message);
    Exit;
  end;
  end;
end;

// Ejecuta la sentencia
procedure ejecuta_insert(cod_aduana,ano_pre,cod_regi,num_dua,tipo_doc:String;contenido:TStrings);
var
  // Crea una conexion
  conexion_oracle: TOracleConnection;
  query_oracle: TSQLQuery;
  transaction_oracle: TSQLTransaction;
  query:String;

begin

  query:='INSERT INTO ORDEN_SEMAFORO_WEB(EMPRESA,ANO_PRESE,CODI_ADUAN,CODI_REGI,NUM_ORDEN,';
  query:=query+'NUM_DUA,EST_INTRUSIVO,CONTEN_WEB,FECHA_CREACION,FECHA_ACTUAL) VALUES (';
  query:=query+':EMPRESA,:ANO_PRESE,:CODI_ADUAN,:CODI_REGI,:NUM_ORDEN,:NUM_DUA,';
  query:=query+':EST_INTRUSIVO,:CONTEN_WEB,:FECHA_CREACION,:FECHA_ACTUAL);';

  try
     conexion_oracle:=conexion();
     //WriteLn('Conexion satisfactoria a SIG');

     transaction_oracle:=TSQLTransaction.Create(nil);
     query_oracle:=TSQLQuery.create(nil);

     conexion_oracle.Transaction:=transaction_oracle;
     transaction_oracle.DataBase:=conexion_oracle;
     query_oracle.DataBase:=conexion_oracle;
     query_oracle.Transaction:=transaction_oracle;

     transaction_oracle.StartTransaction;

     //query_oracle.SQL.Clear;
     query_oracle.SQL.Text:=query;

     WriteLn(contenido.Text);

     query_oracle.Params.ParamByName('EMPRESA').AsString:='001';
     query_oracle.Params.ParamByName('ANO_PRESE').AsString:=ano_pre;
     query_oracle.Params.ParamByName('CODI_ADUAN').AsString:=cod_aduana;
     query_oracle.Params.ParamByName('CODI_REGI').AsString:=cod_regi;
     query_oracle.Params.ParamByName('NUM_ORDEN').AsString:=num_dua;
     query_oracle.Params.ParamByName('NUM_DUA').AsString:=num_dua;
     query_oracle.Params.ParamByName('EST_INTRUSIVO').AsString:='0';
     query_oracle.Params.ParamByName('CONTEN_WEB').AsString:=contenido.Text;
     query_oracle.Params.ParamByName('FECHA_CREACION').AsDate:=Now;
     query_oracle.Params.ParamByName('FECHA_ACTUAL').AsDate:=Now;

     query_oracle.ExecSQL;
     //query_oracle.SQL.Clear;

     transaction_oracle.Commit;
     transaction_oracle.Free;

     query_oracle.Close;
     query_oracle.Free;

     conexion_oracle.Close;
     conexion_oracle.Free;

  except on e: Exception do
  begin
    WriteLn('Error al realizar la conexion a la Base de Datos: ',e.Message);
    WriteLn(e.Message);
    Exit;
  end;
  end;
end;


end.

