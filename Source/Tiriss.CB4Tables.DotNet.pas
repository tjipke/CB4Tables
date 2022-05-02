unit Tiriss.CB4Tables.DotNet;

interface

uses CB4RecordBuffers, Borland.Vcl.DB, Borland.Vcl.Contnrs,
  Tiriss.Codebase.NetIntf;

type
  TCB4RecordBufferDotNet = class(TCB4AbstractRecordBuffer)
  public
    procedure CopyBufferToFieldContent(Buffer: TCB4FieldBuffer; aStartPos, aLength:
        Integer);
    procedure CopyFieldContentToBuffer(aStartPos, aLength: Integer; Buffer:
        TCB4FieldBuffer);
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
    procedure FillRecordContents(aStartPos, aLen: Integer; aValue: TRecordContent); {$IFDEF INLINES}inline;{$ENDIF}
    constructor Create(aRecBufSize: Integer; aBlobFieldCount: Integer);
    destructor Destroy; override;
    function ContentsEqual(aRecBuf: TCB4RecordBufferDotNet): Boolean;
  end;

  TCB4FieldList = class(TObjectList)
    constructor Create; overload;
  end;

procedure TranslateOnIntPtr(const Src, Dst: IntPtrPChar; aLength: Integer; ToOem: Boolean);

implementation

uses System.Runtime.InteropServices, Borland.Vcl.SysUtils,
  Borland.Vcl.DBConsts, System.Security, Windows;

constructor TCB4RecordBufferDotNet.Create(aRecBufSize: Integer; aBlobFieldCount:
    Integer);
begin
  inherited;
  SetLength(FRecordContents, aRecBufSize);
end;

destructor TCB4RecordBufferDotNet.Destroy;
begin
  SetLength(FRecordContents, 0);
  inherited;
end;

function TCB4RecordBufferDotNet.ContentsEqual(aRecBuf: TCB4RecordBufferDotNet):
    Boolean;
var
  I: Integer;
  Contents2: TRecordContents;
begin
  Contents2 := aRecBuf.RecordContents;

  Result := Length(FRecordContents) = Length(Contents2);
  if not Result then Exit;
  for I := Low(FRecordContents) to High(FRecordContents) do
  begin
    Result := FRecordContents[I] = Contents2[I];
    if not Result then Break;
  end;
end;

procedure TCB4RecordBufferDotNet.CopyBufferToFieldContent(Buffer: TCB4FieldBuffer;
    aStartPos, aLength: Integer);
begin
  System.Array.Copy(Buffer, 0, FRecordContents, aStartPos, aLength);
end;

procedure TCB4RecordBufferDotNet.CopyFieldContentToBuffer(aStartPos, aLength:
    Integer; Buffer: TCB4FieldBuffer);
begin
  System.Array.Copy(FRecordContents, aStartPos, Buffer, 0, aLength);
end;

procedure TCB4RecordBufferDotNet.FillRecordContents(aStartPos, aLen: Integer; aValue:
    TRecordContent);
var
  I: Integer;
begin
  for I := aStartPos to aStartPos+aLen-1 do
    FRecordContents[I] := aValue;
end;

procedure TCB4RecordBufferDotNet.GetBool(aStartPos: Integer; Buffer: TValueBuffer);
var
  B: Boolean;
begin
  B := Byte(FRecordContents[aStartPos]) in [Ord('Y'), Ord('y'), Ord('T'), Ord('t')];
  Marshal.WriteInt16(Buffer, Ord(B));
    { ['N', 'n', 'F', 'f'] }
end;

procedure TCB4RecordBufferDotNet.SetBool(aStartPos: Integer; Buffer:
    TValueBuffer);
var
  B: Integer;
begin
  B := Marshal.ReadInt16(Buffer);
  if B<>0 then
    FRecordContents[aStartPos] := Byte('T')
  else
    FRecordContents[aStartPos] := Byte('F');
end;

procedure TCB4RecordBufferDotNet.GetDate(aStartPos, aLength: Integer;
    aInvalidDatesAsNull: Boolean; Buffer: TValueBuffer; out FieldIsNotNull:
    Boolean);
//  function GetDate(RecordData: TRecordData; out FieldIsNotNull: Boolean): Integer;
  // return FieldIsNotNull -> Because we can no show invalid dates as Null
var
  RecDate: TDateTime;
  Y,M,D: Word;
  ID: Integer;
  L: Integer;
begin
  L := aLength;
  if (L < 8) then
  begin
    FieldIsNotNull := False;
    RecDate := 0;
  end
  else
  begin
    Y := StrToIntDef(AnsiEncoding.GetString(FRecordContents, aStartPos, 4), 0);
    M := StrToIntDef(AnsiEncoding.GetString(FRecordContents, aStartPos+4, 2), 0);
    D := StrToIntDef(AnsiEncoding.GetString(FRecordContents, aStartPos+6, 2), 0);
    FieldIsNotNull := TryEncodeDate(Y, M, D, RecDate);
  end;
  if FieldIsNotNull then
    ID := DateTimeToTimeStamp(RecDate).Date
  else
  begin
    FieldIsNotNull := not aInvalidDatesAsNull;
    ID := 0; // generates exception when FieldIsNotNull = True;
  end;
  if (Buffer <> nil) then
    Marshal.WriteInt32(Buffer, ID);
end;

procedure TCB4RecordBufferDotNet.SetDate(aStartPos, aLength: Integer;
    Buffer: TValueBuffer);
var
  T: TTimeStamp;
  Data: AnsiString;
begin
  T.Date := Marshal.ReadInt32(Buffer);

  T.Time := 0;
  if aLength > 8 then aLength := 8;
  Data := FormatDateTime('yyyymmdd', TimeStampToDateTime(T));

  CopyBufferToFieldContent(AnsiEncoding.GetBytes(Data), aStartPos, aLength);

end;

procedure TCB4RecordBufferDotNet.GetDouble(aStartPos, aLength: Integer; Buffer: TValueBuffer; out FieldIsNotNull: Boolean);
  // return FieldIsNotNull -> Because invalid doubles in the BDE are represented as Null
var
  L, S: Integer;
  P: Integer;
  D: Double;
  Data: AnsiString;
begin
  L := aLength;
  while (L > 0) and (FRecordContents[aStartPos+L-1] <= Ord(' ')) do
    Dec(L);
  S := 0;
  while (S < L) and (FRecordContents[aStartPos+S] <= Ord(' ')) do
    Inc(S);
  Data := AnsiEncoding.GetString(FRecordContents, aStartPos+S, L-S);

  if DecimalSeparator <> '.' then
  begin
    P := Pos('.', Data);
    if P > 0 then Data[P] := AnsiChar(DecimalSeparator[1]){ TODO : doesn't work for multiple bytes }
  end;
  FieldIsNotNull := (Data <> '') and TryStrToFloat(Data, D);
  if not FieldIsNotNull then
    D := 0;
  if (Buffer <> nil) then
  begin
    Marshal.WriteInt64(Buffer, System.BitConverter.DoubleToInt64Bits(D));
  end;
end;

procedure TCB4RecordBufferDotNet.SetDouble(aStartPos, aLength: Integer; Buffer: TValueBuffer; aDecimals: Integer);
var
  Data: AnsiString;
  P: Integer;
  D: Double;
begin
  D := System.BitConverter.Int64BitsToDouble(Marshal.ReadInt64(Buffer));

  Data := UnlocalizeFloat(FloatToStrF(D, ffFixed, aLength, aDecimals));
  P := Length(Data);
(*
  if aLength > P then
    Data := StringOfChar(' ', aLength-P)+Data;
*)
  if P > aLength then P := aLength;

  CopyBufferToFieldContent(TBytes(Data), aStartPos+aLength-P, P);

end;

procedure TCB4RecordBufferDotNet.GetEmpty(Buffer: TValueBuffer);
begin
  Marshal.WriteByte(Buffer, 0);
end;

procedure TCB4RecordBufferDotNet.SetEmpty(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
begin
  CopyBufferToFieldContent(AnsiEncoding.GetBytes(''), aStartPos, 0);
end;

procedure TCB4RecordBufferDotNet.GetSmallInt(aStartPos, aLength: Integer; Buffer: TValueBuffer);
var
  Data: AnsiString;
  L: Integer;
begin
  L := aLength;
  while (L > 0) and (FRecordContents[aStartPos+L-1] <= Ord(' ')) do
    Dec(L);
  Data := AnsiEncoding.GetString(FRecordContents, aStartPos, L);
  Marshal.WriteInt16(Buffer, StrToIntDef(Data, 0));
end;

procedure TCB4RecordBufferDotNet.SetSmallInt(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
var
  Data: AnsiString;
begin
  Data := IntToStr(Marshal.ReadInt16(Buffer));

  Data := Copy('   ' + Data, Length(Data) + 4-aLength, aLength);
  if Length(Data) < aLength then aLength := Length(Data);
  CopyBufferToFieldContent(AnsiEncoding.GetBytes(Data), aStartPos, aLength);
end;

(*
          SetLength(Data, InternalFieldLength(Field.FieldNo));
        CopyFieldContentToBuffer(RecBuf, Field, PChar(Data));
//        Move(PChar(Integer(RecBuf) + Integer(FFieldRecPos[Field.FieldNo-1]))^, PChar(Data)^, InternalFieldLength(Field.FieldNo));
        Data := TrimRight(Data);
        Result := Length(Data) <> 0;
*)

procedure TCB4RecordBufferDotNet.GetString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
var
  L: Integer;
begin
  L := aLength;
  while (L > 0) and (FRecordContents[aStartPos+L-1] <= Ord(' ')) do
  begin
    Marshal.WriteByte(Buffer, L, 0); // #0
    Dec(L);
  end;
  Marshal.Copy(FRecordContents, aStartPos, Buffer, L);
  Marshal.WriteByte(Buffer, L, 0); // #0
end;

(*
          SetLength(Data, InternalFieldLength(Field.FieldNo));
        CopyFieldContentToBuffer(RecBuf, Field, PChar(Data));
//        Move(PChar(Integer(RecBuf) + Integer(FFieldRecPos[Field.FieldNo-1]))^, PChar(Data)^, InternalFieldLength(Field.FieldNo));
        Data := TrimRight(Data);
        Result := Length(Data) <> 0;
*)

procedure TCB4RecordBufferDotNet.SetString(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
var
  Data: AnsiString;
begin
  Data := Marshal.PtrToStringAnsi(Buffer);

  if Length(Data) < aLength then aLength := Length(Data);

  CopyBufferToFieldContent(TBytes(Data), aStartPos, aLength);

end;

procedure TCB4RecordBufferDotNet.GetWideString(aStartPos, aLength: Integer; Buffer: TValueBuffer);
var
  L: Integer;
begin
  L := aLength;
  while (L > 0) and (System.BitConverter.ToChar(FRecordContents, aStartPos+L-1) <= ' ') do
    Dec(L, 2);
  Marshal.Copy(FRecordContents, aStartPos, Buffer, L);
  Marshal.WriteInt16(Buffer, L, 0); // #0
end;

procedure TCB4RecordBufferDotNet.SetWideString(aStartPos, aLength: Integer; Buffer:
    TValueBuffer);
var
  WData: WideString;
begin
  WData := Marshal.PtrToStringUni(Buffer);

  if (Length(WData)*2) < aLength then aLength := Length(WData)*2;

  CopyBufferToFieldContent(WideBytesOf(WData), aStartPos, aLength);

end;

procedure TCB4RecordBufferDotNet.GetVFCurrency(aStartPos: Integer; Buffer:
    TValueBuffer);
var
  TmpDouble: Double;
begin
  TmpDouble := System.BitConverter.ToInt64(FRecordContents, aStartPos) / 10000;
  Marshal.WriteInt64(Buffer, System.BitConverter.DoubleToInt64Bits(TmpDouble));
end;

procedure TCB4RecordBufferDotNet.SetVFCurrency(aStartPos: Integer; Buffer:
    TValueBuffer);
var
  TmpInt64: Int64;
begin
  TmpInt64 := Trunc(System.BitConverter.Int64BitsToDouble(Marshal.ReadInt64(Buffer)) * 10000);
  System.Array.Copy(System.BitConverter.GetBytes(TmpInt64), 0, FRecordContents, aStartPos, SizeOf(TmpInt64));
end;

procedure TCB4RecordBufferDotNet.GetVFDateTime(aStartPos: Integer; aInvalidDatesAsNull:
    Boolean; Buffer: TValueBuffer; aField: TField; var aIsNotNull: Boolean);
var
  TmpInteger: Integer;
  DT: TDateTime;
begin
  TmpInteger := System.BitConverter.ToInt32(FRecordContents, aStartPos);
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
      DT := DT+(System.BitConverter.ToInt32(FRecordContents, 4+aStartPos)/(24*60*60*1000));
      Marshal.WriteInt64(Buffer, BitConverter.DoubleToInt64Bits(DT));
    end
    else
    begin
      if not aInvalidDatesAsNull then
        DatabaseErrorFmt(SFieldValueError, [aField.DisplayName]);
      Marshal.WriteInt64(Buffer, BitConverter.DoubleToInt64Bits(0));
    end;
  end;
end;

procedure TCB4RecordBufferDotNet.SetVFDateTime(aStartPos: Integer; Buffer:
    TValueBuffer);
var
  TmpInt: Integer;
  TmpInt64: Int64;
  D: Double;
  DT: TDateTime;
begin
  TmpInt64 := Marshal.ReadInt64(Buffer);
  D := System.BitConverter.ToDouble(System.BitConverter.GetBytes(TmpInt64), 0);
  DT := D;
  TmpInt := date4long(FormatDateTime('YYYYMMDD', DT));
  System.Array.Copy(System.BitConverter.GetBytes(TmpInt), 0, FRecordContents, aStartPos, SizeOf(Integer));
  TmpInt := Trunc(Frac(D) * (24*60*60*1000));
  System.Array.Copy(System.BitConverter.GetBytes(TmpInt), 0, FRecordContents, aStartPos+4, SizeOf(Integer));
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

procedure TCB4RecordBufferDotNet.GetVFFloat(aStartPos: Integer; Buffer: TValueBuffer);
begin
  Marshal.Copy(FRecordContents, aStartPos, Buffer, SizeOf(Double));
end;

procedure TCB4RecordBufferDotNet.SetVFFloat(aStartPos: Integer; Buffer: TValueBuffer);
begin
  Marshal.Copy(Buffer, FRecordContents, aStartPos, SizeOf(Double));
end;

procedure TCB4RecordBufferDotNet.GetVFInteger(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Marshal.Copy(FRecordContents, aStartPos, Buffer, SizeOf(Integer));
end;

procedure TCB4RecordBufferDotNet.SetVFInteger(aStartPos: Integer; Buffer:
    TValueBuffer);
begin
  Marshal.Copy(Buffer, FRecordContents, aStartPos, SizeOf(Integer));
end;

constructor TCB4FieldList.Create;
begin
  inherited Create(False);
end;

[SuppressUnmanagedCodeSecurity, DllImport(user32, CharSet = CharSet.Ansi, SetLastError = True, EntryPoint = 'CharToOemBuffA')]
function CharToOemBuffA(lpszSrc: IntPtrPChar; lpszDst: IntPtr; cchDstLength: DWORD): BOOL; external;
[SuppressUnmanagedCodeSecurity, DllImport(user32, CharSet = CharSet.Ansi, SetLastError = True, EntryPoint = 'OemToCharBuffA')]
function OemToCharBuffA(lpszSrc: IntPtrPChar; lpszDst: IntPtr; cchDstLength: DWORD): BOOL; external;

procedure TranslateOnIntPtr(const Src, Dst: IntPtrPChar; aLength: Integer; ToOem: Boolean);
begin
  if ToOem then
  begin
    if aLength > 0 then
      CharToOemBuffA(Src, Dst, aLength);
  end
  else
  begin
    if aLength > 0 then
      OemToCharBuffA(Src, Dst, aLength);
  end;
end;

end.
