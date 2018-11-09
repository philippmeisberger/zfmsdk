program Sample;

{$IFDEF MSWINDOWS}
{$APPTYPE CONSOLE}

{$R *.res}
{$ENDIF}
uses
  SysUtils,
  Zfm;

var
  Index: SmallInt;
  Accuracy: Word;

begin
  try
    ZfmInitialize();

    try
      ZfmConnect({$IFDEF MSWINDOWS}'COM3'{$ELSE}'/dev/ttyUSB0'{$ENDIF});
      Writeln(Format('%d template(s) stored on sensor', [ZfmTemplateNum()]));

      if ZfmGenImg() then
      begin
        ZfmImage2Tz(CharBuffer1);
        ZfmSearch(CharBuffer1, Index, Accuracy);

        if (Index <> -1) then
          Writeln(Format('Found template at %d with accuracy %d', [Index, Accuracy]))
        else
          Writeln('Template not found!');
      end  //of begin
      else
        Writeln('No finger on sensor!');

    finally
      ZfmUnInitialize();
      Readln;
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
