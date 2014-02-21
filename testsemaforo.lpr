program testsemaforo;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, testdb, pl_zeosdbo, Interfaces;
  { you can add units after this }

type

  { seguimientodeorden }

  seguimientodeorden = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ seguimientodeorden }

procedure seguimientodeorden.DoRun;
var
  ErrorMsg: String;
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
  testdb.tester();
  // stop program loop
  ReadLn;
  Terminate;
end;

constructor seguimientodeorden.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor seguimientodeorden.Destroy;
begin
  inherited Destroy;
end;

procedure seguimientodeorden.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;

var
  Application: seguimientodeorden;
begin
  Application:=seguimientodeorden.Create(nil);
  Application.Title:='seguimientodeorden';
  Application.Run;
  Application.Free;
end.

