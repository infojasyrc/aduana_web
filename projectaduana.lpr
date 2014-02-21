program projectaduana;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, convutils, sqldb, admindb, LConvEncoding, Interfaces,
  pl_zeosdbo;
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

function lector_html(archivo:String):TStrings;
var
  //contenido_html:String;
  contenido_html:TStrings;

begin

  try
     contenido_html:=TStringList.Create();
     contenido_html.LoadFromFile(archivo);
     Result:=contenido_html;
  finally
  end;

end;

function lector2_html(archivo:String):String;
var
  linea:String;
  contenido_archivo:TextFile;
  contenido_final:String;

begin
  contenido_final:='';
  AssignFile(contenido_archivo,archivo);
  Reset(contenido_archivo);

  while not eof(contenido_archivo) do
  begin
    ReadLn(contenido_archivo,linea);
    if linea<>'' then
    begin
      contenido_final:=contenido_final+linea;
    end;
  end;
  CloseFile(contenido_archivo);

  Result:=contenido_final;
end;

procedure aplicacion(cod_aduana,ano_pre,cod_regi,num_dua,num_orden,tipo_doc,html:String);
var
  contenido_html:TStrings;

begin
  contenido_html:=lector_html(html);

  admindb.otro_insert(cod_aduana,ano_pre,cod_regi,num_dua,num_orden,tipo_doc,contenido_html);

end;

procedure aduana.DoRun;
var
  ErrorMsg:String;
  cod_aduana,ano_prese,num_dua,num_orden,cod_regi,tipo_doc,archivo_html:String;
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

  if numero_parametros<7 then
  begin
    WriteLn('Numero de parametros incorrectos');
    Terminate;
    Exit;
  end;

  cod_aduana:=ParamStr(1);
  ano_prese:=ParamStr(2);
  cod_regi:=ParamStr(3);
  num_dua:=ParamStr(4);
  num_orden:=ParamStr(5);
  tipo_doc:=ParamStr(6);
  archivo_html:=ParamStr(7);

  {
  WriteLn(ParamStr(0));
  WriteLn(ParamStr(1));
  WriteLn(ParamStr(2));
  WriteLn(ParamStr(3));
  WriteLn(ParamStr(4));
  WriteLn(ParamStr(5));
  WriteLn(ParamStr(6));
  WriteLn(ParamStr(7));
  }

  if FileExists(archivo_html) then
  begin
    //WriteLn('Excelente');
    aplicacion(cod_aduana,ano_prese,cod_regi,num_dua,num_orden,tipo_doc,archivo_html);
  end;

  // stop program loop
  //ReadLn();
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

