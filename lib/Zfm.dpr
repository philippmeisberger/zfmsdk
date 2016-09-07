{ *********************************************************************** }
{                                                                         }
{ ZhianTec Fingerprint Module (ZFM) SDK library                           }
{                                                                         }
{ Copyright (c) 2011-2016 Philipp Meisberger (PM Code Works)              }
{                                                                         }
{ *********************************************************************** }

library Zfm;

{$IFDEF FPC}{$mode delphi}{$ENDIF}

uses
  SysUtils,
  PMCW.Serial,
  PMCW.Serial.ZFM;

{$R *.res}

var
  FSensor: TZfmSensor;

procedure ZfmInitialize(AAddress: UInt32 = $FFFFFFFF; APassword: UInt32 = 0); cdecl;
begin
  FSensor := TZfmSensor.Create(AAddress, APassword);
end;

procedure ZfmUnInitialize(); cdecl;
begin
  FreeAndNil(FSensor);
end;

procedure ZfmConnect(APort: PWideChar; ABaudrate: UInt32 = 57600); cdecl;
begin
  FSensor.Connect(APort, ABaudrate);
end;

procedure ZfmEmpty(); cdecl;
begin
  FSensor.ClearDatabase();
end;

function ZfmMatch(): Word; cdecl;
begin
  Result := FSensor.CompareCharacteristics();
end;

procedure ZfmImage2Tz(ACharBuffer: Byte); cdecl;
begin
  if (ACharBuffer = Byte(Ord(cbOne))) then
    FSensor.ConvertImage(cbOne)
  else
    FSensor.ConvertImage(cbTwo);
end;

procedure ZfmRegModel(); cdecl;
begin
  FSensor.CreateTemplate();
end;

procedure ZfmDeletChar(AStartIndex: Word; ACount: Word = 1); cdecl;
begin
  FSensor.DeleteTemplate(AStartIndex, ACount);
end;

function ZfmTemplateNum(): Word; cdecl;
begin
  Result := FSensor.GetTemplateCount();
end;

function ZfmGetRandomCode(): UInt32; cdecl;
begin
  Result := FSensor.GenerateRandomNumber();
end;

function ZfmReadConList(APage: Byte; AList: PByte; var AListLength: UInt32): Boolean; cdecl;
var
  TemplateIndex: TZfmTemplateIndex;

begin
  Result := False;

  if (APage > High(TZfmTemplatePage)) then
    Exit;

  if (not Assigned(AList) or (AListLength < 256)) then
  begin
    AListLength := 256;
    Exit;
  end;  //of begin

  TemplateIndex := FSensor.GetTemplateIndex(APage);
  AListLength := Length(TemplateIndex);
  Move(TemplateIndex[0], AList^, AListLength);
  Result := True;
end;

procedure ZfmLoadChar(AIndex: Word; ACharBuffer: Byte = 1); cdecl;
begin
  if (ACharBuffer = Byte(Ord(cbOne))) then
    FSensor.LoadTemplate(AIndex, cbOne)
  else
    FSensor.LoadTemplate(AIndex, cbTwo);
end;

function ZfmGenImg(): Boolean; cdecl;
begin
  Result := FSensor.ReadImage();
end;

procedure ZfmSearch(ACharBuffer: Byte; out ATemplateIndex: SmallInt;
  out AAccuracy: Word); cdecl;
var
  SearchResult: TZfmTemplateSearchResult;

begin
  if (ACharBuffer = Byte(Ord(cbOne))) then
    SearchResult := FSensor.SearchTemplate(cbOne)
  else
    SearchResult := FSensor.SearchTemplate(cbTwo);

  ATemplateIndex := SearchResult.TemplateIndex;
  AAccuracy := SearchResult.Accuracy;
end;

procedure ZfmStore(AIndex: Word; ACharBuffer: Byte = 1); cdecl;
begin
  if (ACharBuffer = Byte(Ord(cbOne))) then
    FSensor.StoreTemplate(AIndex, cbOne)
  else
    FSensor.StoreTemplate(AIndex, cbTwo);
end;

function ZfmDownChar(ADestination: Byte; ACharacteristics: PByte;
  ACharacteristicsLength: UInt32): Boolean; cdecl;
var
  Characteristics: TZfmCharacteristics;

begin
  // Nothing to do
  if (not Assigned(ACharacteristics) or (ACharacteristicsLength <> ZFM_CHARACTERISTICS_COUNT)) then
  begin
    Result := False;
    Exit;
  end;  //of begin

  Move(ACharacteristics^, Characteristics[0], ACharacteristicsLength);

  if (ADestination = Byte(Ord(cbOne))) then
    Result := FSensor.UploadCharacteristics(cbOne, Characteristics)
  else
    Result := FSensor.UploadCharacteristics(cbTwo, Characteristics);
end;

function ZfmUpChar(ACharBuffer: Byte; ACharacteristics: PByte;
  var ACharacteristicsLength: UInt32): Boolean; cdecl;
var
  Characteristics: TZfmCharacteristics;

begin
  // Determine needed buffer size
  if not Assigned(ACharacteristics) or (ACharacteristicsLength <> ZFM_CHARACTERISTICS_COUNT) then
  begin
    ACharacteristicsLength := ZFM_CHARACTERISTICS_COUNT;
    Result := False;
    Exit;
  end;  //of begin

  if (ACharBuffer = Byte(Ord(cbOne))) then
    Characteristics := FSensor.DownloadCharacteristics(cbOne)
  else
    Characteristics := FSensor.DownloadCharacteristics(cbTwo);

  Move(Characteristics[0], ACharacteristics^, ACharacteristicsLength);
  Result := True;
end;

function ZfmDownImage(AFileName: PWideChar): Boolean; cdecl;
begin
  Result := FSensor.UploadImage(AFileName);
end;

function ZfmUpImage(AFileName: PWideChar): Boolean; cdecl;
begin
  Result := FSensor.DownloadImage(AFileName);
end;

function ZfmReadNotepad(APage: Byte; AData: PByte; var ADataLength: Byte): Boolean; cdecl;
var
  NotepadData: TZfmNotepadData;

begin
  Result := False;

  if (APage > High(TZfmNotepadPage)) then
    Exit;

  if (not Assigned(AData) or not (ADataLength in [1..ZFM_NOTEPAD_DATA_COUNT])) then
  begin
    ADataLength := ZFM_NOTEPAD_DATA_COUNT;
    Exit;
  end; //of begin

  NotepadData := FSensor.ReadNotepad(APage);
  Move(NotepadData[0], AData^, ADataLength);
  Result := True;
end;

function ZfmWriteNotepad(APage: Byte; AData: PByte; ADataLength: Byte): Boolean; cdecl;
var
  NotepadData: TZfmNotepadData;

begin
  Result := False;

  if (APage > High(TZfmNotepadPage)) then
    Exit;

  if (not Assigned(AData) or not (ADataLength in [1..ZFM_NOTEPAD_DATA_COUNT])) then
    Exit;

  Move(AData^, NotepadData[0], ADataLength);
  FSensor.WriteNotepad(APage, NotepadData);
  Result := True;
end;

function ZfmVfyPwd(): Boolean; cdecl;
begin
  Result := FSensor.VerifyPassword();
end;

procedure ZfmSetAddr(const ANewAddress: UInt32); cdecl;
begin
  FSensor.Address := ANewAddress;
end;

procedure ZfmSetPwd(const ANewPassword: UInt32); cdecl;
begin
  FSensor.Password := ANewPassword;
end;

function ZfmGetLastError(): Byte; cdecl;
begin
  Result := FSensor.LastError;
end;

exports
  ZfmInitialize,
  ZfmUnInitialize,
  ZfmConnect,
  ZfmEmpty,
  ZfmMatch,
  ZfmImage2Tz,
  ZfmRegModel,
  ZfmDeletChar,
  ZfmTemplateNum,
  ZfmGetRandomCode,
  ZfmReadConList,
  ZfmLoadChar,
  ZfmGenImg,
  ZfmSearch,
  ZfmStore,
  ZfmDownChar,
  ZfmUpChar,
  ZfmDownImage,
  ZfmUpImage,
  ZfmReadNotepad,
  ZfmWriteNotepad,
  ZfmVfyPwd,
  ZfmSetAddr,
  ZfmSetPwd,
  ZfmGetLastError;

begin
end.
