unit admindb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, oracleconnection, sqldb, IniFiles;
  function obtiene_archivo_ini():String;
  function lector_ini():TStringList;
  function conexion():TOracleConnection;
  procedure ejecuta_query(string_query:String);

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
procedure ejecuta_query(string_query:String);
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

     conexion_oracle.Transaction:=transaction_oracle;
     transaction_oracle.DataBase:=conexion_oracle;
     query_oracle.DataBase:=conexion_oracle;
     query_oracle.Transaction:=transaction_oracle;

     transaction_oracle.StartTransaction;

     query_oracle.SQL.Clear;
     query_oracle.SQL.Text:= string_query;
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


end.

