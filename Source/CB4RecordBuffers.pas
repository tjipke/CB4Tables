unit CB4RecordBuffers;

interface

{$IFDEF CONDITIONALEXPRESSIONS}
  {$DEFINE VERK1PLUS}   // Since Kylix a 'lot' has changed
  {$IF COMPILERVERSION >= 15}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_TYPE OFF}
  {$IFEND}
  {$IF COMPILERVERSION >= 17}
    {$DEFINE INLINES}
  {$IFEND}
{$ENDIF}

uses DB, Classes;

type
  TCB4RecordNumber = Integer;
  PCB4RecordNumber = ^TCB4RecordNumber;

  TCB4BlobState = (bsEmpty, bsCached, bsModified);
  TCB4BlobData = record
    State: TCB4BlobState;
    Data: TMemoryStream;
  end;
  TCB4BlobDataArray = array of TCB4BlobData;

{$IFNDEF CLR}
  TRecordContent = Char;
  TRecordContents = PChar;
  TCB4FieldBuffer = Pointer;
  TValueBuffer = Pointer;
{$ELSE}
  TRecordContent = Byte;
  TRecordContents = array of Byte;
  TCB4FieldBuffer = array of Byte;
{$ENDIF}


(*
  a record consists of:
  * RecordContents (Data+CalcFields)
  * BlobData (Blobfieldcount * TBlobData)
  * MetaData
*)
  TCB4AbstractRecordBuffer = class
  private
    FRecordNumber: TCB4RecordNumber;
    FBookmarkFlag: TBookmarkFlag;
    FBlobData: TCB4BlobDataArray;
//    FUpdateStatus: TUpdateStatus; -> for batch updates etc...
  protected
    FRecordContents: TRecordContents;
    class function TryJulianDateToDateTime(const AValue: Integer; out ADateTime:
        TDateTime): Boolean;
  public
    constructor Create(aRecBufSize: Integer; aBlobFieldCount: Integer);
    destructor Destroy; override;
    procedure FillRecordContents(aStartPos, aLen: Integer; aValue: TRecordContent); {$IFDEF INLINES}inline;{$ENDIF}
    procedure SetBlobState(aOffset: Integer; aBlobState: TCB4BlobState);
    class function UnlocalizeFloat(aFloatStr: string): string;
    property RecordContents: TRecordContents read FRecordContents;
    property BlobData: TCB4BlobDataArray read FBlobData;
    // meta data
    property BookmarkFlag: TBookmarkFlag read FBookmarkFlag write FBookmarkFlag;
    property RecordNumber: TCB4RecordNumber read FRecordNumber write FRecordNumber;
//    property UpdateStatus: TUpdateStatus read FUpdateStatus write FUpdateStatus;
  end;

  {$IFNDEF CLR}
  TCB4RecordBufferWin32 = class(TCB4AbstractRecordBuffer)
  public
    procedure CopyFieldContentToBuffer(aStartPos, aLength: Integer; Buffer:
        TCB4FieldBuffer);
    procedure CopyBufferToFieldContent(Buffer: TCB4FieldBuffer; aStartPos, aLength:
        Integer);
    procedure GetBool(aStartPos: Integer; Buffer: TValueBuffer);
    procedure SetBool(aStartPos: Integer; Buffer: TValueBuffer);
    procedure GetDate(aStartPos, aLength: Integer; aInvalidDatesAsNull: Boolean;
        Buffer: TValueBuffer; out FieldIsNotNull: Boolean);
    procedure SetDate(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure GetDouble(aStartPos, aLength: Integer; Buffer: TValueBuffer; out
        FieldIsNotNull: Boolean);
    procedure SetDouble(aStartPos, aLength: Integer; Buffer: TValueBuffer;
        aDecimals: Integer);
    procedure GetEmpty(Buffer: TValueBuffer);
    procedure SetEmpty(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure GetSmallInt(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure SetSmallInt(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure GetString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure SetString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure GetWideString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure SetWideString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
    procedure GetVFCurrency(aStartPos: Integer; Buffer: TValueBuffer);
    procedure SetVFCurrency(aStartPos: Integer; Buffer: TValueBuffer);
    procedure GetVFDateTime(aStartPos: Integer; aInvalidDatesAsNull: Boolean;
        Buffer: TValueBuffer; aField: TField; var aIsNotNull: Boolean);
    procedure SetVFDateTime(aStartPos: Integer;
        Buffer: TValueBuffer);
    procedure GetVFFloat(aStartPos: Integer; Buffer: TValueBuffer);
    procedure SetVFFloat(aStartPos: Integer; Buffer: TValueBuffer);
    procedure GetVFInteger(aStartPos: Integer; Buffer: TValueBuffer);
    procedure SetVFInteger(aStartPos: Integer; Buffer: TValueBuffer);
    function ContentsEqual(aRecBuf: TCB4AbstractRecordBuffer;aRecBufSize:Integer): Boolean;
    constructor Create(aRecBufSize: Integer; aBlobFieldCount: Integer);
    destructor Destroy; override;
  end;
  {$ENDIF}

implementation

uses SysUtils, DBConsts
  {$IFNDEF CLR},
  {$IFDEF TRIAL}CodeBaseIntf
  {$ELSE}CodeBase{$ENDIF}{$ENDIF};

{$IFDEF VER130}         // Delphi 5 & CBuilder 5
  {$DEFINE NEEDTRYSTRTOFLOAT}
{$ENDIF}

{$IFDEF VER140}
  {$IFDEF LINUX}
    {$IF RTLVersion<14.20}
    {$DEFINE NEEDTRYSTRTOFLOAT}
    {$IFEND}
  {$ENDIF}
{$ENDIF}


{$IFNDEF VERK1PLUS} //only needed for D5 & C5 (Pre Kylix)
{from filectrl:} // Kylix and higher have these in sysutils
function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean;
begin
  Result := False;
  if (Year > 0) and (Month > 0) and (Day > 0) then
    try
      Date := EncodeDate(Year, Month, Day);
      Result := True;
    except
      on EConvertError do ;// nothing
    end;
end;
{$ENDIF}

{$IFDEF NEEDTRYSTRTOFLOAT}
function TryStrToFloat(const S: string; out Value: Double): Boolean;
var
  Temp: Extended;
begin
  Result := TextToFloat(PChar(S), Temp, fvExtended);
  if Result then
    Value := Temp;
end;
{$ENDIF}

constructor TCB4AbstractRecordBuffer.Create(aRecBufSize: Integer; aBlobFieldCount:
    Integer);
begin
  inherited Create;
  SetLength(FBlobData, aBlobFieldCount);  // will initialize to zero -> bsempty, nil
end;

destructor TCB4AbstractRecordBuffer.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(FBlobData) do
    SetBlobState(I, bsEmpty);
  SetLength(FBlobData, 0); // just to be sure it is removed
  inherited;
end;

procedure TCB4AbstractRecordBuffer.FillRecordContents(aStartPos, aLen: Integer; aValue:
    TRecordContent);
var
  I: Integer;
begin
  for I := aStartPos to aStartPos+aLen-1 do
    FRecordContents[I] := aValue;
end;

procedure TCB4AbstractRecordBuffer.SetBlobState(aOffset: Integer; aBlobState: TCB4BlobState);
begin
  if aBlobState = FBlobData[aOffSet].State then Exit;
  FBlobData[aOffSet].State := aBlobState;
  if aBlobState=bsEmpty then
    FreeAndNil(FBlobData[aOffset].Data)
  else
  if FBlobData[aOffset].Data = nil then
    FBlobData[aOffset].Data := TMemoryStream.Create;
end;

class function TCB4AbstractRecordBuffer.TryJulianDateToDateTime(const AValue:
    Integer; out ADateTime: TDateTime): Boolean;
var
  L, N, LYear, LMonth, LDay: Integer;
//  Data: string;
//  DT: TDateTime;
begin
  L := AValue + 68570;
  N := 4 * L div 146097;
  L := L - (146097 * N + 3) div 4;
  LYear := 4000 * (L + 1) div 1461001;
  L := L - 1461 * LYear div 4 + 31;
  LMonth := 80 * L div 2447;
  LDay := L - 2447 * LMonth div 80;
  L := LMonth div 11;
  LMonth := LMonth + 2 - 12 * L;
  LYear := 100 * (N - 49) + LYear + L;
  Result := TryEncodeDate(LYear, LMonth, LDay, ADateTime);
  if Result then
    ADateTime := Trunc(ADateTime - 0.5);
{ code to test this implementation with codebase
  SetLength(Data, 8);
  date4Assign(PChar(Data), aValue);
  if Result and (Trim(Data)='') then
    raise Exception.Create('');

  if Result and not TryEncodeDate(StrToIntDef(Copy(Data, 1, 4), 0),
                                      StrToIntDef(Copy(Data, 5, 2), 0),
                                      StrToIntDef(Copy(Data, 7, 2), 0), DT) then
    raise Exception.Create('');
  if DT <> aDateTime then
    raise Exception.Create('');
}
end;

class function TCB4AbstractRecordBuffer.UnlocalizeFloat(aFloatStr: string):
    string;
var
  P: Integer;
begin
  Result := aFloatStr;
  if DecimalSeparator <> '.' then
  begin
    P := Pos(DecimalSeparator, Result);
    if P > 0 then Result[P] := '.';
  end;
end;

{$IFNDEF CLR}
constructor TCB4RecordBufferWin32.Create(aRecBufSize: Integer; aBlobFieldCount:
    Integer);
begin
  inherited;
  FRecordContents := StrAlloc(aRecBufSize);
end;

destructor TCB4RecordBufferWin32.Destroy;
begin
  StrDispose(FRecordContents);
  inherited;
end;

procedure TCB4RecordBufferWin32.CopyBufferToFieldContent(Buffer:
    TCB4FieldBuffer; aStartPos, aLength: Integer);
begin
  Move(Buffer^, TRecordContents(Integer(FRecordContents) + TRecordContents(aStartPos))^, aLength);
end;

procedure TCB4RecordBufferWin32.CopyFieldContentToBuffer(aStartPos, aLength:
    Integer; Buffer: TCB4FieldBuffer);
begin
  Move(TRecordContents(Integer(FRecordContents) + TRecordContents(aStartPos))^, Buffer^, aLength);
end;

procedure TCB4RecordBufferWin32.GetBool(aStartPos: Integer; Buffer: TValueBuffer);
var
  B: Boolean;
begin
  B := Byte(FRecordContents[aStartPos]) in [Ord('Y'), Ord('y'), Ord('T'), Ord('t')];
  WordBool(Buffer^) := B;
    { ['N', 'n', 'F', 'f'] }
end;

procedure TCB4RecordBufferWin32.SetBool(aStartPos: Integer; Buffer:
    TValueBuffer);
  {$IFDEF CLR}
var
  B: Integer;
  {$ENDIF}
begin
  {$IFDEF CLR}
  B := Marshal.ReadInt16(Buffer);
  if B<>0 then
    FRecordContents[aStartPos] := Byte('T')
  else
    FRecordContents[aStartPos] := Byte('F');
  {$ELSE}
  if WordBool(Buffer^) then
    FRecordContents[aStartPos] := 'T'
  else
    FRecordContents[aStartPos] := 'F';
  {$ENDIF}
end;

procedure TCB4RecordBufferWin32.GetDate(aStartPos, aLength: Integer;
    aInvalidDatesAsNull: Boolean; Buffer: TValueBuffer; out FieldIsNotNull:
    Boolean);
//  function GetDate(RecordData: TRecordData; out FieldIsNotNull: Boolean): Integer;
  // return FieldIsNotNull -> Because we can no show invalid dates as Null
var
  RecDate: TDateTime;
  Y,M,D: Word;
  ID: Integer;
  Data: AnsiString;
begin
  SetLength(Data, aLength);
  CopyFieldContentToBuffer(aStartPos, aLength, PChar(Data));
  Y := StrToIntDef(Copy(Data, 1, 4), 0);
  M := StrToIntDef(Copy(Data, 5, 2), 0);
  D := StrToIntDef(Copy(Data, 7, 2), 0);
  FieldIsNotNull := TryEncodeDate(Y, M, D, RecDate);

  if FieldIsNotNull then
    ID := DateTimeToTimeStamp(RecDate).Date
  else
  begin
    FieldIsNotNull := not aInvalidDatesAsNull;
    ID := 0; // generates exception when FieldIsNotNull = True;
  end;
  if (Buffer <> nil) then
    Integer(Buffer^) := ID;
end;

procedure TCB4RecordBufferWin32.SetDate(aStartPos, aLength: Integer;
    Buffer: TValueBuffer);
var
  T: TTimeStamp;
  Data: AnsiString;
begin
  {$IFDEF CLR}
  T.Date := Marshal.ReadInt32(Buffer);
  {$ELSE}
  T.Date := Integer(Buffer^);
  {$ENDIF}
  T.Time := 0;
  if aLength > 8 then aLength := 8;
  Data := FormatDateTime('yyyymmdd', TimeStampToDateTime(T));
  {$IFDEF CLR}
  CopyBufferToFieldContent(AnsiEncoding.GetBytes(Data), aStartPos, aLength);
  {$ELSE}
  CopyBufferToFieldContent(PChar(Data), aStartPos, aLength);
  {$ENDIF}
end;

procedure TCB4RecordBufferWin32.GetDouble(aStartPos, aLength: Integer; Buffer: TValueBuffer; out FieldIsNotNull: Boolean);
  // return FieldIsNotNull -> Because invalid doubles in the BDE are represented as Null
var
  P: Integer;
  D: Double;
  Data: AnsiString;
begin
  SetLength(Data, aLength);
  CopyFieldContentToBuffer(aStartPos, aLength, PChar(Data));
  Data := Trim(Data); // Get rid of spaces on both sides

  if DecimalSeparator <> '.' then
  begin
    P := Pos('.', Data);
    if P > 0 then Data[P] := DecimalSeparator; { TODO : doesn't work for multiple bytes }
  end;
  FieldIsNotNull := (Data <> '') and TryStrToFloat(Data, D);
  if not FieldIsNotNull then
    D := 0;
  if (Buffer <> nil) then
  begin
    Double(Buffer^) := D;
  end;
end;

procedure TCB4RecordBufferWin32.SetDouble(aStartPos, aLength: Integer; Buffer: TValueBuffer; aDecimals: Integer);
var
  Data: AnsiString;
  P: Integer;
  D: Double;
begin
  {$IFDEF CLR}
  D := System.BitConverter.Int64BitsToDouble(Marshal.ReadInt64(Buffer));
  {$ELSE}
  D := Double(Buffer^);
  {$ENDIF}
  Data := UnlocalizeFloat(FloatToStrF(D, ffFixed, aLength, aDecimals));
  P := Length(Data);
(*
  if aLength > P then
    Data := StringOfChar(' ', aLength-P)+Data;
*)
  if P > aLength then P := aLength;
  {$IFDEF CLR}
  CopyBufferToFieldContent(TBytes(Data), aStartPos+aLength-P, P);
  {$ELSE}
  CopyBufferToFieldContent(PChar(Data), aStartPos+aLength-P, P);
  {$ENDIF}
end;

procedure TCB4RecordBufferWin32.GetEmpty(Buffer: TValueBuffer);
begin
  PChar(Buffer)[0] := ''#0;
end;

procedure TCB4RecordBufferWin32.SetEmpty(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
begin
  CopyBufferToFieldContent(PChar(''), aStartPos, 0);
end;

procedure TCB4RecordBufferWin32.GetSmallInt(aStartPos, aLength: Integer; Buffer: TValueBuffer);
var
  Data: AnsiString;
begin
  SetLength(Data, aLength);
  CopyFieldContentToBuffer(aStartPos, aLength, PChar(Data));
  Data := TrimRight(Data);
  SmallInt(Buffer^) := StrToIntDef(Data, 0);
end;

procedure TCB4RecordBufferWin32.SetSmallInt(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
var
  Data: AnsiString;
begin
  Data := IntToStr(SmallInt(Buffer^));

  Data := Copy('   ' + Data, Length(Data) + 4-aLength, aLength);
  if Length(Data) < aLength then aLength := Length(Data);

  CopyBufferToFieldContent(PChar(Data), aStartPos, aLength);
end;

(*
        SetLength(Data, InternalFieldLength(Field.FieldNo));
      CopyFieldContentToBuffer(RecBuf, Field, PChar(Data));
//        Move(PChar(Integer(RecBuf) + Integer(FFieldRecPos[Field.FieldNo-1]))^, PChar(Data)^, InternalFieldLength(Field.FieldNo));
      Data := TrimRight(Data);
      Result := Length(Data) <> 0;
*)

procedure TCB4RecordBufferWin32.GetString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
var
  Data: AnsiString;
begin
  SetLength(Data, aLength);
  CopyFieldContentToBuffer(aStartPos, aLength, PChar(Data));
  Data := TrimRight(Data);
  StrCopy(PChar(Buffer), PChar(Data));
end;

procedure TCB4RecordBufferWin32.SetString(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
var
  Data: AnsiString;
begin
  Data := string(PChar(Buffer));

  if Length(Data) < aLength then aLength := Length(Data);

  CopyBufferToFieldContent(PChar(Data), aStartPos, aLength);
end;

procedure TCB4RecordBufferWin32.SetWideString(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
var
  WData: WideString;
begin
  WData := Widestring(Buffer^);

  if (Length(WData)*2) < aLength then aLength := Length(WData)*2;

  CopyBufferToFieldContent(PWideChar(WData), aStartPos, aLength);
end;

procedure TCB4RecordBufferWin32.GetWideString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
var
  WData: WideString;
begin
  SetLength(WData, aLength div 2);
  CopyFieldContentToBuffer(aStartPos, aLength, PWideChar(WData));
//        Move(PChar(Integer(RecBuf) + Integer(FFieldRecPos[Field.FieldNo-1]))^, PWideChar(WData)^, InternalFieldLength(Field.FieldNo));
  WData := TrimRight(WData);
  Widestring(Buffer^) := WData;
end;

procedure TCB4RecordBufferWin32.GetVFCurrency(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Double(Buffer^) := Currency(Pointer(Integer(FRecordContents) + aStartPos)^);
end;

procedure TCB4RecordBufferWin32.SetVFCurrency(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Currency(Pointer(Integer(FRecordContents) + aStartPos)^) := Double(Buffer^);
end;

procedure TCB4RecordBufferWin32.GetVFDateTime(aStartPos: Integer; aInvalidDatesAsNull:
    Boolean; Buffer: TValueBuffer; aField: TField; var aIsNotNull: Boolean);
var
  TmpInteger: Integer;
  DT: TDateTime;
begin
  TmpInteger := Integer(Pointer(Integer(FRecordContents) + aStartPos)^);

//       SetLength(Data, 8);
//            date4Assign(PChar(Data), Integer(Pointer(Integer(RecBuf) + Integer(FFieldRecPos[Field.FieldNo-1]))^));
//            Result := Trim(Data)<>'';// we say if Data='' then it is null, even if it isn't supported by table!
  aIsNotNull := TmpInteger > 0;
  if aIsNotNull then
  begin
//              Result := TryEncodeDate(StrToIntDef(Copy(Data, 1, 4), 0),
//                                      StrToIntDef(Copy(Data, 5, 2), 0),
//                                      StrToIntDef(Copy(Data, 7, 2), 0), DT);
    aIsNotNull := TryJulianDateToDateTime(TmpInteger, DT);
    if aIsNotNull then
    begin

      TDateTime(Buffer^) := DT +
          (Integer(Pointer(4 + Integer(FRecordContents) + aStartPos)^) / (24*60*60*1000) )

    end
    else
    begin
      if not aInvalidDatesAsNull then
        DatabaseErrorFmt(SFieldValueError, [aField.DisplayName]);

      TDateTime(Buffer^) := 0;

    end;
  end;
end;

procedure TCB4RecordBufferWin32.SetVFDateTime(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Integer(Pointer(Integer(FRecordContents) + aStartPos)^) := date4long(PChar(FormatDateTime('YYYYMMDD', TDateTime(Buffer^))));
  Integer(Pointer(4 + Integer(FRecordContents) + aStartPos)^) := Trunc(Frac(TDateTime(Buffer^)) * (24*60*60*1000));
  { TODO : check stuff below what is relevant?}

(*
  Result := TmpInteger > 0;
  if Result then
  begin
//              Result := TryEncodeDate(StrToIntDef(Copy(Data, 1, 4), 0),
//                                      StrToIntDef(Copy(Data, 5, 2), 0),
//                                      StrToIntDef(Copy(Data, 7, 2), 0), DT);
    Result := TryJulianDateToDateTime(TmpInteger, DT);
    if Result then
    begin
      {$IFDEF CLR}
      DT := DT+(System.BitConverter.ToInt32(FRecordContents, 4+aStartPos)/(24*60*60*1000));
      Marshal.Copy(System.BitConverter.GetBytes(DT), 0, Buffer, SizeOf(TDateTime)); //test
      {$ELSE}
      TDateTime(Buffer^) := DT +
          (Integer(Pointer(4 + Integer(FRecordContents) + aStartPos)^) / (24*60*60*1000) )
      {$ENDIF}
    end
    else
    begin
      if not aInvalidDatesAsNull then
        DatabaseErrorFmt(SFieldValueError, [Field.DisplayName]);
      {$IFDEF CLR}
      DT := 0;
      Marshal.Copy(System.BitConverter.GetBytes(DT), 0, Buffer, SizeOf(TDateTime)); //test
      {$ELSE}
      TDateTime(Buffer^) := 0;
      {$ENDIF}
    end;
  end;
*)
end;

procedure TCB4RecordBufferWin32.GetVFFloat(aStartPos: Integer; Buffer: TValueBuffer);
begin
  Double(Buffer^) := Double(Pointer(Integer(FRecordContents) + aStartPos)^);
end;

procedure TCB4RecordBufferWin32.SetVFFloat(aStartPos: Integer; Buffer: TValueBuffer);
begin
  Double(Pointer(Integer(FRecordContents) + aStartPos)^) := Double(Buffer^);
end;

procedure TCB4RecordBufferWin32.GetVFInteger(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Integer(Buffer^) := Integer(Pointer(Integer(FRecordContents) + Integer(aStartPos))^);
end;

procedure TCB4RecordBufferWin32.SetVFInteger(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Integer(Pointer(Integer(FRecordContents) + Integer(aStartPos))^) := Integer(Buffer^);
end;

function TCB4RecordBufferWin32.ContentsEqual(aRecBuf: TCB4AbstractRecordBuffer;
    aRecBufSize:Integer): Boolean;
var
  Contents2: TRecordContents;
begin
  Contents2 := aRecBuf.RecordContents;
  Result := BuffersEqual(FRecordContents, Contents2, aRecBufSize);
end;
{$ENDIF}

end.
