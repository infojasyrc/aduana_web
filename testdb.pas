unit testdb;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, oracleconnection, sqldb, IniFiles, ZConnection, ZDataset,db, lNet, lNetComponents, sockets;
  function obtiene_archivo_ini():String;
  function lector_ini():TStringList;
  function conexion():TZConnection;
  procedure tester();
  procedure cliente_socket(parametros:String);
  procedure PError(const S:string);

implementation

// Obtiene la ruta del archivo INI
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

// Ejecuta la sentencia
procedure tester();
var
  // Crea una conexion
  conexion_oracle: TZConnection;
  query_oracle: TZQuery;
  query_insert,query_select,query_update:String;
  parameters_conexion:TStringList;
  tiempo_actual:TDateTime;
  empresa,nume_orden,num_dua,codi_regi,codi_aduan,ano_prese:String;
  parametros,resultado,opcion_resultado:String;

begin
  opcion_resultado:='0';

  query_select:='SELECT EMPRESA, NUME_ORDEN, NUM_DUA, CODI_REGI,CODI_ADUAN,ANO_PRESE';
  query_select:=query_select+' FROM ORDEN WHERE (SYSDATE - FEC_NUMERACION) < 30';
  query_select:=query_select+' ORDER BY FEC_NUMERACION';

  tiempo_actual:=Now;

  try
     parameters_conexion:=lector_ini();

     conexion_oracle:=conexion();
     query_oracle:=TZQuery.create(nil);

     query_oracle.Connection:=conexion_oracle;

     query_oracle.SQL.Clear;

     query_oracle.SQL.Add(query_select);

     query_oracle.Prepare;

     query_oracle.Open;

     while not query_oracle.EOF do
     begin
       empresa:=query_oracle.FieldByName('EMPRESA').AsString;
       nume_orden:=query_oracle.FieldByName('NUME_ORDEN').AsString;
       num_dua:=query_oracle.FieldByName('NUM_DUA').AsString;
       codi_regi:=Trim(query_oracle.FieldByName('CODI_REGI').AsString);
       codi_aduan:=Trim(query_oracle.FieldByName('CODI_ADUAN').AsString);
       ano_prese:=Trim(query_oracle.FieldByName('ANO_PRESE').AsString);

       parametros:=empresa+':'+codi_aduan+':'+nume_orden+':'+codi_regi+':'+ano_prese+':'+num_dua+':'+opcion_resultado;
       WriteLn(parametros);
       cliente_socket(parametros);
       query_oracle.Next;
     end;

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


// Funcion que se conecta al socket
procedure cliente_socket(parametros:String);
var

  SAddr    : TInetSockAddr;
  //Buffer   : string [255];
  Buffer   : String;
  S        : Longint;
  Sin,Sout : Text;
  i        : integer;
  Line     : string;

begin

  //S:=fpSocket (AF_INET,SOCK_STREAM,0);
  S:=fpSocket (AF_INET,SOCK_STREAM,0);
  if s=-1 then
   Perror('Client : Socket : ');
  SAddr.sin_family:=AF_INET;
  { port 50000 in network order }
  SAddr.sin_port:=htons(11111);
  { localhost : 127.0.0.1 in network order }
  SAddr.sin_addr.s_addr:=HostToNet((127 shl 24) or 1);
  //SAddr.sin_addr.s_addr:=HostToNet(172.16.105.35);
  if not Connect (S,SAddr,Sin,Sout) then
   PError('Client : Connect : ');
  Reset(Sin);
  ReWrite(Sout);
  //Buffer:=parametros;
  //for i:=1 to 10 do
  //  Writeln(Sout,Buffer);
  //Write(Sout,Buffer);
  WriteLn(Sout,parametros);
  Flush(Sout);
  Readln(Sin,Buffer);
  WriteLn(Buffer);
  //Close(Sin);
  Close(sout);
  //CloseSocket(S)
  //result:=sout.;

end;

procedure PError(const S:string);
begin
  writeln(S,SocketError);
  halt(100);
end;

end.

