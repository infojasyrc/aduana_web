program projectaduana;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, admindb;
  { you can add units after this }

type

  { aduana }

  aduana = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ aduana }

procedure aplicacion(cod_aduana:String;ano_pre:String;cod_regi:String;num_dua:String;tipo_doc:String;html:String);
var
  query:String;
  fecha_creacion,fecha_actualizacion:String;

begin
  fecha_creacion:=FormatDateTime('DD-MMM-YYYY',Now);
  fecha_actualizacion:=fecha_creacion;

  query:='INSERT INTO ORDEN_SEMAFORO_WEB(EMPRESA,ANO_PRESE,CODI_ADUAN,CODI_REGI,';
  query:=query+'NUM_ORDEN,NUM_DUA,EST_INTRUSIVO,CONTEN_WEB,FECHA_CREACION,FECHA_ACTUAL) VALUES (';
  query:=query+'''001'', '''+ano_pre+''', '''+cod_aduana+''', '''+cod_regi+''', ''';
  query:=query+num_dua+''', '''+num_dua+''', 0, ''Hola'', '''+fecha_creacion+''', '''+fecha_actualizacion+''')';
  WriteLn(query);
  admindb.ejecuta_query(query);
end;

procedure aduana.DoRun;
var
  ErrorMsg:String;
  cod_aduana,ano_prese,num_dua,cod_regi,tipo_doc,archivo_html:String;
  numero_parametros:Integer;

begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h','help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h','help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }
  numero_parametros:=ParamCount;

  if numero_parametros<6 then
  begin
    WriteLn('Numero de parametros incorrectos');
    Terminate;
    Exit;
  end;

  cod_aduana:=ParamStr(1);
  ano_prese:=ParamStr(2);
  cod_regi:=ParamStr(3);
  num_dua:=ParamStr(4);
  tipo_doc:=ParamStr(5);
  archivo_html:=ParamStr(6);
  {
  //WriteLn(ParamStr(0));
  WriteLn(ParamStr(1));
  WriteLn(ParamStr(2));
  WriteLn(ParamStr(3));
  WriteLn(ParamStr(4));
  WriteLn(ParamStr(5));
  WriteLn(ParamStr(6));
  }
  if FileExists(archivo_html) then
  begin
    WriteLn('Excelente');
    aplicacion(cod_aduana,ano_prese,cod_regi,num_dua,tipo_doc,archivo_html);
  end;

  // stop program loop
  ReadLn();
  Terminate;
end;

constructor aduana.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor aduana.Destroy;
begin
  inherited Destroy;
end;

procedure aduana.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: aduana;
begin
  Application:=aduana.Create(nil);
  Application.Title:='aduana';
  Application.Run;
  Application.Free;
end.

