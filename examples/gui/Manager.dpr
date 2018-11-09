program Manager;

uses
{$IFDEF UNIX}{$IFDEF FPC}
  cthreads,
{$ENDIF}{$ENDIF}
  Forms, {$IFDEF FPC}Interfaces,{$ENDIF}
  Main in 'Main.pas' {MainForm},
  PMCW.Serial.ZFM in '..\src\PMCW.Serial.ZFM.pas';

{$R *.res}

begin
  Application.Initialize;
{$IFDEF MSWINDOWS}
  Application.MainFormOnTaskbar := True;
{$ENDIF}
  Application.Title:='ZFM Manager';
  Application.CreateForm(TMain, MainForm);
  Application.Run;
end.
