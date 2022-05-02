{
*    Tiriss CB4 Tables
*    (c) MMV Tiriss
*
*    Not in model anymore
}

unit CB4Reg;

interface

{.$DEFINE TRIAL}

// this define section only defines the ones used in this reg file
{$IFDEF VER130}         // Delphi 5 & CBuilder 5
{$DEFINE VERC5D5}
{$ENDIF}
{$IFDEF VER140}
  {$DEFINE VERK1PLUS}   // Since Kylix a 'lot' has changed
  {$IFDEF LINUX}
    {$IF RTLVersion<14.20}
    {$DEFINE VERK1}       // Kylix 1
    {$ELSEIF RTLVersion<14.50}
    {$DEFINE VERK2}       // Kylix 2
    {$ELSEIF True}
    {$DEFINE VERK3}       // Kylix 3
   {$IFEND}
  {$ELSE}
  {$DEFINE VERC6D6}     // Delphi 6 & CBuilder 6
  {$ENDIF}
{$ENDIF}
{$IFDEF VER150}
  {$DEFINE VERK1PLUS}   // Since Kylix a 'lot' has changed
  {$DEFINE VERC7D7}     // Delphi 7 & CBuilder 7(?)
{$ENDIF}

{$IFDEF CONDITIONALEXPRESSIONS}
  {$DEFINE VERK1PLUS}   // Since Kylix a 'lot' has changed
  {$IF COMPILERVERSION >= 15}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_TYPE OFF}
  {$IFEND}
  {$IF COMPILERVERSION >= 17}
    {$DEFINE INLINES}
    {$WARN UNSAFE_TYPE OFF}
  {$IFEND}
{$ENDIF}

uses SysUtils, Classes, DB, CB4Tables,
{$IFDEF LINUX}
  Libc, DesignIntf, DesignEditors, FldLinks, DBReg
  {$IFNDEF VERK1} ,Graphics, Types, VCLEditors
    {$IFNDEF VERK2} ,TreeIntf {$ENDIF}
  {$ENDIF}
{$ELSE}
  Windows,
{$IFDEF CLR}
      Borland.Vcl.Design.FldLinks,
      Graphics,
      Borland.Vcl.Design.FldProp,
      Borland.Vcl.Design.DesignEditors,
      Borland.Vcl.Design.VCLEditors,
      Borland.Vcl.Design.TreeIntf,
      Borland.Vcl.Design.DesignIntF,
      System.Runtime.InteropServices
{$ELSE}
    FldLinks, Graphics, DBReg,
    {$IFDEF VERC5D5}
      dsndb, ParentageSupport,
    {$ELSE}
      TreeIntf, DesignEditors, VCLEditors,
    {$ENDIF}

  {$IFNDEF VERK1PLUS}
    DsgnIntf
  {$ELSE}
    DesignIntf
  {$ENDIF}
{$ENDIF}

{$ENDIF};

type
{ Property Editors }
  TDatabaseNameProperty = class (TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TCompatibleAboutProperty = class (TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

  TIndexFieldNamesProperty = class (TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TIndexNameProperty = class (TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;
  
  TTableNameProperty = class (TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;
  
  TPathProperty = class (TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TCB4DatabaseEditor = class (TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TCB4DataSetEditor = class (TDataSetEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;
  
  TCB4TableFieldLinkProperty = class (TFieldLinkProperty)
  private
    FTable: TCB4Table;
  protected
    procedure GetFieldNamesForIndex(List: TStrings); override;
    function GetIndexBased: Boolean; override;
    function GetIndexDefs: TIndexDefs; override;
    function GetIndexFieldNames: string; override;
    function GetIndexName: string; override;
    function GetMasterFields: string; override;
    procedure SetIndexFieldNames(const Value: string); override;
    procedure SetIndexName(const Value: string); override;
    procedure SetMasterFields(const Value: string); override;
  public
    procedure Edit; override;
    property IndexBased: Boolean read GetIndexBased;
    property IndexDefs: TIndexDefs read GetIndexDefs;
    property IndexFieldNames: string read GetIndexFieldNames write
       SetIndexFieldNames;
    property IndexName: string read GetIndexName write SetIndexName;
    property MasterFields: string read GetMasterFields write SetMasterFields;
  end;

{$IFNDEF VERC5D5}
{$IFNDEF VERK1}
  TAboutProperty = class (TCompatibleAboutProperty, ICustomPropertyDrawing)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetName: string; override;
    procedure PropDrawName(Canvas: TCanvas; const Rect: TRect; Selected:
       Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect; ASelected:
       Boolean);
  end;

{$IFNDEF VERK2}
  TDefaultCB4DatabaseSprig = class (TTransientSprig)
  public
    function Caption: string; override;
    function ItemClass: TClass; override;
    function Transient: Boolean; override;
    function UniqueName: string; override;
  end;

  TImpliedCB4DatabaseSprig = class (TTransientSprig)
  private
    FAutoName: string;
    FDatabaseName: string;
  public
    function Caption: string; override;
    function ItemClass: TClass; override;
    function Transient: Boolean; override;
    function UniqueName: string; override;
  end;

  TCB4DatabaseSprig = class (TComponentSprig)
  public
    function AnyProblems: Boolean; override;
    function Caption: string; override;
    function Name: string; override;
  end;

  TCB4TableSprig = class (TComponentSprig)
  public
    function AnyProblems: Boolean; override;
    function Caption: string; override;
    function DragDropTo(AItem: TSprig): Boolean; override;
    function DragOverTo(AItem: TSprig): Boolean; override;
    procedure FigureParent; override;
    class function PaletteOverTo(AParent: TSprig; AClass: TClass): Boolean;
       override;
  end;

{$ENDIF}
{$ENDIF}
{$ENDIF}

function GetAboutTxt: string;
procedure Register;

implementation

uses
  {$IFDEF VERC5D5} CB4D5Prop, {$ENDIF}
  {$IFDEF LINUX}QForms, QDialogs, DBLogDlg,
  {$ELSE} Forms, Dialogs, DBLogDlg, ShlObj, ActiveX, 
  {$ENDIF} DBConsts{$IFDEF TRIAL}{$IFDEF CLR},Tiriss.Codebase.NetIntf{$ELSE},CodeBaseIntf{$ENDIF}{$ENDIF}, StdCtrls{, Controls};

const
  CB4PackName = 'CB4 Tables '; // include space for convenience

{$IFDEF TRIAL}
  LICENSEINFO='Trial version';
{$ELSE}
{$INCLUDE License.inc}
{$ENDIF}

resourcestring
  SAboutMsg = CB4PackName + #13#10'(c) 2004 Tiriss'#13#10#13#10'Version %s %s '#13#10#13#10'%s'#13#10#13#10'Info: info@tiriss.com'#13#10'See: http://www.tiriss.com';
  SAboutTxt = 'v%s (%s)';
{$IFDEF TRIAL}
  SAboutExtra = '(Trial)'#13#10'(CodeBase %d.%2d; %s)'#13#10'(C4dll path: %s)'#13#10#13#10'This trial version works only if %s is running';

  SAboutIDE = {$IFDEF LINUX}'Kylix';      {$ELSE}
              {$IFDEF BCB}  'C++Builder'; {$ELSE}
                            'Delphi';     {$ENDIF}
                                          {$ENDIF}
{$ELSE}
  SAboutExtra = #13#10'(CB %s)';
{$ENDIF}
  SCB4Unknown = 'unknown database';
  SCB4FoxPro = 'FoxPro';
  SCB4Clipper = 'Clipper';
  SCB4dBase = 'dBase';
  SClientServer = 'Client/Server for %s';
  SStandAlone = 'Stand alone for %s';

const
  szDESIGNTABLEPATH = 'DesignTablePath';

procedure Register;
begin
  RegisterComponents('Data Access', [TCB4Table]);
  RegisterComponents('Data Access', [TCB4Database]);
  RegisterPropertyEditor( TypeInfo(string), TCB4Table, 'About', TCompatibleAboutProperty);
  RegisterPropertyEditor( TypeInfo(string), TCB4Table, 'DatabaseName', TDatabaseNameProperty);
  RegisterPropertyEditor( TypeInfo(string), TCB4Table, 'IndexName', TIndexNameProperty);
  RegisterPropertyEditor( TypeInfo(string), TCB4Table, 'IndexFieldNames', TIndexFieldNamesProperty);
  RegisterPropertyEditor( TypeInfo(string), TCB4Table, 'TableName', TTableNameProperty);
  RegisterPropertyEditor( TypeInfo(string), TCB4Database, 'TablePath', TPathProperty);
  RegisterPropertyEditor( TypeInfo(string), TCB4Database, 'IndexPath', TPathProperty);
  RegisterComponentEditor(TCB4Database, TCB4DatabaseEditor);
  RegisterComponentEditor(TCB4Dataset, TCB4DataSetEditor);
  RegisterPropertyEditor(TypeInfo(string), TCB4Table, 'MasterFields', TCB4TableFieldLinkProperty);

  { Property Category registration }
  {$IFNDEF VERK1}
  {$IFDEF VERC5D5}
  RegisterPropertiesInCategory(TDatabaseCategory, TCB4DataSet, ['DatabaseName']);
  RegisterPropertiesInCategory(TDatabaseCategory, TCB4Database, ['DatabaseName']);
  RegisterPropertyEditor( TypeInfo(string), TCB4Table, 'About', TAboutPropertyD5);
  RegisterSprigType(TCB4Table, TCB4TableSprigD5);
  RegisterSprigType(TCB4Database, TCB4DatabaseSprigD5);
  {$ELSE}
  RegisterPropertiesInCategory(sDatabaseCategoryName, TCB4DataSet, ['DatabaseName']);
  RegisterPropertiesInCategory(sDatabaseCategoryName, TCB4Database, ['DatabaseName']);
  RegisterPropertyEditor(TypeInfo(string), TCB4Table, 'About', TAboutProperty);
  {$IFNDEF VERK2}
  RegisterSprigType(TCB4Table, TCB4TableSprig);
  RegisterSprigType(TCB4Database, TCB4DatabaseSprig);
  {$ENDIF}
  {$ENDIF}

  {$ENDIF}
end;

{$IFNDEF LINUX}
{$IFNDEF VERC6D6}
function IncludeTrailingPathDelimiter(const aPath: string): string;
begin
  Result := aPath;
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then
    Result := Result + '\';
end;
{$ENDIF}
{$ENDIF}

{$IFNDEF LINUX}
function BrowseCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer {$IFNDEF CLR}stdcall{$ENDIF};
begin
{$IFDEF CLR}
  if (uMsg = BFFM_INITIALIZED) and (lpData <> 0) then
    PostMessage(Wnd, BFFM_SETSELECTION, 0, lpData);
{$ELSE}
  if (uMsg = BFFM_INITIALIZED) and (PItemIDList(lpData) <> nil) then
    PostMessage(Wnd, BFFM_SETSELECTION, 0, lpData);
  {$ENDIF}
  Result := 0;
end;

function BrowseForFolder(const aTitle: string; var aFolder: string): Boolean;
var
  BrowseInfo: TBrowseInfo;
  PItemId, StartFolderItemIDList: {$IFDEF CLR}IntPtr{$ELSE}PItemIDList{$ENDIF};
  Buffer: {$IFDEF CLR}IntPtr{$ELSE}PChar{$ENDIF};
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
  StartIn: WideString;
  ShellMalloc: IMalloc;
begin
  if not(ShGetMalloc(ShellMalloc) = S_OK) then
    ShellMalloc := nil;
  {$IFDEF CLR}
  Buffer := Marshal.AllocHGlobal(MAX_PATH);
  {$ELSE}
  if (ShellMalloc <> nil) then
    Buffer := ShellMalloc.Alloc(MAX_PATH)
  else
    Buffer := StrAlloc(MAX_PATH);
  {$ENDIF}
  try
    StartIn := aFolder;
    SHGetDesktopFolder(IDesktopFolder);
    IDesktopFolder.ParseDisplayName(Application.Handle, nil,
      {$IFDEF CLR}StartIn{$ELSE}PWideChar(StartIn){$ENDIF}, Eaten, StartFolderItemIDList, Flags);

    {$IFNDEF CLR}
    FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
    {$ENDIF}
    with BrowseInfo do
    begin
      {$IFDEF CLR}
      // screen.activeform is nil in vcl .net! in designtime!
      hwndOwner := Application.ActiveFormHandle;
      {$ELSE}
      // but older delphis have no Application.ActiveFormHandle
      hwndOwner := Screen.ActiveForm.Handle;
      {$ENDIF}
      pidlRoot := nil;
      pszDisplayName := Buffer;

      {$IFDEF CLR}
      lpszTitle := aTitle;
      {$ELSE}
      lpszTitle := PChar(aTitle);
      {$ENDIF}
      ulFlags := BIF_RETURNONLYFSDIRS;
      lpfn := @BrowseCallBack;
      lparam := Integer(StartFolderItemIDList);
    end;

    // Browse for a folder and return its PIDL.
    PItemId := SHBrowseForFolder(BrowseInfo);
    Result :=  PItemId <> nil;
    if Result then
    begin
      SHGetPathFromIDList(PItemId, Buffer);
      {$IFDEF CLR}
      aFolder := Marshal.PtrToStringAuto(Buffer);
      {$ELSE}
      aFolder := Buffer;
      {$ENDIF}
      if (ShellMalloc <> nil) then
        ShellMalloc.Free(PItemID);
    end;
  finally
    {$IFDEF CLR}
    Marshal.FreeHGlobal(Buffer);
    {$ELSE}
    if (ShellMalloc <> nil) then
      ShellMalloc.Free(Buffer)
    else
      StrDispose(Buffer);
    {$ENDIF}
  end;
end;
{$ENDIF} //LINUX

function GetAboutTxt: string;
begin
  Result := Format(CB4PackName + SAboutTxt, [SCB4Version, LICENSEINFO]);
end;

procedure ShowAboutDialog(aCB4Database: TCB4Database);
var
  S: string;
begin
  if not Assigned(aCB4Database) then
    aCB4Database := DefaultDB;
  case aCB4Database.DatabaseType of
    dtCB4Unknown: S := SCB4Unknown;
    dtCB4Foxpro: S := SCB4FoxPro;
    dtCB4Clipper: S := SCB4Clipper;
    dtCB4dBase: S := SCB4dBase;
  end;

  if IsClientServer then
    S := Format(SClientServer, [S])
  else
    S := Format(SStandAlone, [S]);
  S := Format(SAboutExtra, [{$IFDEF TRIAL}CBVersion div 100, CBVersion mod 100, S, DllPath, SAboutIDE{$ELSE}S{$ENDIF}]);
  MessageDlg(Format(SAboutMsg, [SCB4Version, S, LICENSEINFO]), mtInformation, [mbOk], 0);

(*
var
  S: string;
  l: TLabel;
  F: TForm;
begin
  if IsClientServer then
    S := SClientServer
  else
    S := SStandAlone;
  S := Format(SAboutExtra, [{$IFDEF TRIAL}CBVersion div 100, CBVersion mod 100, S, SAboutIDE{$ELSE}S{$ENDIF}]);
  F := CreateMessageDialog(Format(SAboutMsg, [SCB4Version, S]), mtInformation, [mbOk]);
  with F do
    try
      Position := poScreenCenter;
      l := TLabel.Create(F);
      L.Parent := F;
      L.Font.Color := clBlue;
      L.Font.Style := L.Font.Style + [fsUnderline];
      L.Top := F.Height-64-16;
      L.Left := 76;
//      L.Width := F.ClientWidth;
//      L.Alignment := taCenter;
//      L.AutoSize := False;
      L.Caption := 'http://www.tiriss.com';
      L.Cursor := crHandPoint;
      L.OnClick := LblClick;
      l := TLabel.Create(F);
      L.Parent := F;
      L.Font.Color := clBlue;
      L.Font.Style := L.Font.Style + [fsUnderline];
      L.Top := F.Height-64-16-20;
      L.Left := 76;
      L.Caption := 'info@tiriss.com';
      L.Cursor := crHandPoint;
      L.OnClick := LblClick;
      ShowModal;
    finally
      Free;
    end;

procedure xxx.lblClick(Sender: TObject);
var
  S: string;
begin
  S := (Sender as TLabel).Caption;
  if Pos('@', S) > 0 then
    S := 'mailto:'+S+'?Subject=CB4Version'+SCB4Version;;
  ShellExecute(0, 'open', PChar(S), '','',0);
end;

*)
end;

{
**************************** TDatabaseNameProperty *****************************
}
function TDatabaseNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable, paMultiSelect];
end;

procedure TDatabaseNameProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := 0 to DatabaseCount-1 do
  begin
    if Databases(I).DatabaseName <> '' then
      Proc(Databases(I).DatabaseName);
  end;
end;

{
*************************** TCompatibleAboutProperty ***************************
}
procedure TCompatibleAboutProperty.Edit;
begin
  ShowAboutDialog((GetComponent(0) as TCB4Table).Database);
end;

function TCompatibleAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly, paMultiSelect];
end;

function TCompatibleAboutProperty.GetValue: string;
begin
  Result := Format(SAboutTxt, [SCB4Version, LICENSEINFO]);
end;

{
*************************** TIndexFieldNamesProperty ***************************
}
function TIndexFieldNamesProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable];
end;

procedure TIndexFieldNamesProperty.GetValues(Proc: TGetStrProc);
var
  C: TCB4Table;
  I: Integer;
begin
  C := GetComponent(0) as TCB4Table;
  try
    C.IndexDefs.Update;
    for I := 0 to C.IndexDefs.Count-1 do
    begin
      with C.IndexDefs[I] do
        if (Options * [ixExpression, ixDescending] = []) and (Fields <> '') then
          Proc(Fields);
    end;
  except
    on EDatabaseError do ;
  end;
end;

{
****************************** TIndexNameProperty ******************************
}
function TIndexNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable];
end;

procedure TIndexNameProperty.GetValues(Proc: TGetStrProc);
var
  C: TCB4Table;
  I: Integer;
begin
  C := GetComponent(0) as TCB4Table;
  try
    C.IndexDefs.Update;
    for I := 0 to C.IndexDefs.Count-1 do
      Proc(C.IndexDefs[I].Name);
  except
    on EDatabaseError do ;
  end;
end;

{
****************************** TTableNameProperty ******************************
}
function TTableNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable];
end;

procedure TTableNameProperty.GetValues(Proc: TGetStrProc);
var
  SearchRec: TSearchRec;
  Found: Integer;
  SearchDir: string;
  D: TCB4Database;
begin
  try
    D := (GetComponent(0) as TCB4Table).Database;
    if D = nil then
      Exit;
    if IsClientServer and (D.Params.IndexOfName(szDESIGNTABLEPATH) = -1) then
    begin
      Proc('1. To be able to select tables from a list (on c/s)');
      Proc('2. you need to set the DesignTablePath parameter');
      Proc(Format('3. in your TCB4Database (=%s)', [D.DatabaseName]));
      Proc('4. For example put a line like:');
      Proc('5. DesignTablePath=\\MyServer\MySharedDir');
      Proc('6. in the TCB4Database.Params property.');
      Exit;
    end;
    SearchDir := D.Params.Values[szDesignTablePath];
    if (SearchDir = '') and not IsClientServer then
      SearchDir := D.TablePath;
    if SearchDir <> '' then SearchDir := IncludeTrailingPathDelimiter(SearchDir);
    Found := FindFirst(SearchDir+'*.dbf', faAnyFile xor faDirectory, SearchRec);
    try
      while Found = 0 do
      begin
        Proc(SearchRec.Name);
        Found := FindNext(SearchRec);
      end;
    finally
      Sysutils.FindClose(SearchRec);
    end;
  except
  end;
end;

{
******************************** TPathProperty *********************************
}
procedure TPathProperty.Edit;
var
  D: TCB4Database;
  
  {$IFDEF VERK3}
  S, Root: WideString;
  {$ELSE}
  S{$IFDEF LINUX}, Root{$ENDIF}: string;
  {$ENDIF}
  
begin
  D := GetComponent(0) as TCB4Database;
  S := GetStrValue;
  {$IFDEF LINUX}
  Root := '/';
  if SelectDirectory(Format('Choose %s for %s', [GetPropInfo^.Name, D.Name]), Root, S) then
  {$ELSE}
  if BrowseForFolder(Format('Choose %s for %s', [GetPropInfo.Name, D.Name]), S) then
  {$ENDIF}
  SetStrValue(S);
end;

function TPathProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paRevertable];
end;

{
****************************** TCB4DatabaseEditor ******************************
}
procedure TCB4DatabaseEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: ShowAboutDialog(Component as TCB4Database);
  end;
end;

function TCB4DatabaseEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := GetAboutTxt;
  end;
end;

function TCB4DatabaseEditor.GetVerbCount: Integer;
begin
  Result := 1; { Version Info }
end;

{
****************************** TCB4DataSetEditor *******************************
}
procedure TCB4DataSetEditor.ExecuteVerb(Index: Integer);
begin
  if Index <= inherited GetVerbCount - 1 then
    inherited ExecuteVerb(Index) else
  begin
    Dec(Index, inherited GetVerbCount);
    case Index of
      0: ShowAboutDialog((Component as TCB4DataSet).Database);
    end;
  end;
end;

function TCB4DataSetEditor.GetVerb(Index: Integer): string;
begin
  if Index <= inherited GetVerbCount - 1 then
    Result := inherited GetVerb(Index) else
  begin
    Dec(Index, inherited GetVerbCount);
    case Index of
      0: Result := GetAboutTxt;
    end;
  end;
end;

function TCB4DataSetEditor.GetVerbCount: Integer;
begin
  Result := inherited GetVerbCount + 1; { Version Info }
end;

{
************************** TCB4TableFieldLinkProperty **************************
}
procedure TCB4TableFieldLinkProperty.Edit;
var
  Table: TCB4Table;
  I: Integer;
begin
  Table := DataSet as TCB4Table;
  FTable := TCB4Table.Create(nil);
  try
    if Table.DatabaseName <> '' then
      FTable.DatabaseName := Table.DatabaseName
    else
      FTable.Database := Table.Database;
    FTable.TableName := Table.TableName;
    FTable.Options := Table.Options;
    for I := 0 to Table.IndexFiles.Count-1 do
      FTable.IndexFiles.Add(Table.IndexFiles[I]);
    if Table.IndexFieldNames <> '' then
      FTable.IndexFieldNames := Table.IndexFieldNames else
      FTable.IndexName := Table.IndexName;
    FTable.MasterFields := Table.MasterFields;
    FTable.Open;
    inherited Edit;
    if Changed then
    begin
      Table.MasterFields := FTable.MasterFields;
      if FTable.IndexFieldNames <> '' then
        Table.IndexFieldNames := FTable.IndexFieldNames else
        Table.IndexName := FTable.IndexName;
    end;
  finally
    FTable.Free;
  end;
end;

procedure TCB4TableFieldLinkProperty.GetFieldNamesForIndex(List: TStrings);
var
  i: Integer;
begin
  for i := 0 to FTable.IndexFieldCount - 1 do
    List.Add(FTable.IndexFields[i].FieldName);
end;

function TCB4TableFieldLinkProperty.GetIndexBased: Boolean;
begin
  Result := True;
end;

function TCB4TableFieldLinkProperty.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TCB4TableFieldLinkProperty.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

function TCB4TableFieldLinkProperty.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

function TCB4TableFieldLinkProperty.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TCB4TableFieldLinkProperty.SetIndexFieldNames(const Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TCB4TableFieldLinkProperty.SetIndexName(const Value: string);
begin
  FTable.IndexName := Value;
end;

procedure TCB4TableFieldLinkProperty.SetMasterFields(const Value: string);
begin
  FTable.MasterFields := Value;
end;

{$IFNDEF VERK1}
{$IFNDEF VERC5D5}
{
******************************** TAboutProperty ********************************
}
function TAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paFullWidthName];
end;

function TAboutProperty.GetName: string;
begin
  Result := GetAboutTxt;
end;

procedure TAboutProperty.PropDrawName(Canvas: TCanvas; const Rect: TRect; 
   Selected: Boolean);
var
  Style: TFontStyles;
begin
  Style := Canvas.Font.Style;
  Canvas.Font.Style := Style + [fsBold];
  try
    DefaultPropertyDrawName(Self, Canvas, Rect);
  finally
    Canvas.Font.Style := Style;
  end;
end;

procedure TAboutProperty.PropDrawValue(ACanvas: TCanvas; const ARect: TRect; 
   ASelected: Boolean);
begin
end;

{$IFNDEF VERK2}

const
  cDefaultDatabaseSprigName = '<DefaultDatabase>'; { do not localize }
  cImpliedCB4DatabaseSprigPrefix =  '<ImpliedDatabase>'; { do not localize }
  cAutoDatabaseNameSprigName = '<AutoDatabaseName>'; { do not localize }

function SprigCB4DatabaseName(const AName: string): string;
begin
  Result := AName;
  if (Result = '') or
     (CompareText(Result, DefaultDB.DatabaseName) = 0) then
    Result := cDefaultDatabaseSprigName;
end;

function SprigCB4ImpliedDatabaseName(const AName: string): string;
begin
  Result := Format('%s.%s', [cImpliedCB4DatabaseSprigPrefix, AName]); { do not localize }
end;

function SprigCB4AutoDatabaseName(const AName: string): string;
begin
  Result := Format('%s.%s', [cAutoDatabaseNameSprigName, AName]); { do not localize }
end;

{
*************************** TDefaultCB4DatabaseSprig ***************************
}
function TDefaultCB4DatabaseSprig.Caption: string;
begin
  Result := CaptionFor(DefaultDB.DatabaseName, 'Default Database')
end;

function TDefaultCB4DatabaseSprig.ItemClass: TClass;
begin
  Result := TCB4Database;
end;

function TDefaultCB4DatabaseSprig.Transient: Boolean;
begin
  Result := True;
end;

function TDefaultCB4DatabaseSprig.UniqueName: string;
begin
  Result := cDefaultDatabaseSprigName;
end;

{
*************************** TImpliedCB4DatabaseSprig ***************************
}
function TImpliedCB4DatabaseSprig.Caption: string;
begin
  if FAutoName <> '' then
    Result := CaptionFor('<Auto>', 'Implied Database: '+FAutoName) { do not localize }
  else
    Result := CaptionFor(FDatabaseName, 'Implied Database'); { do not localize }
end;

function TImpliedCB4DatabaseSprig.ItemClass: TClass;
begin
  Result := TCB4Database;
end;

function TImpliedCB4DatabaseSprig.Transient: Boolean;
begin
  Result := True;
end;

function TImpliedCB4DatabaseSprig.UniqueName: string;
begin
//  if FAutoName <> '' then
//    Result := SprigCB4AutoDatabaseName(FAutoName)
//  else
    Result := SprigCB4ImpliedDatabaseName(FDatabaseName);
end;

{
****************************** TCB4DatabaseSprig *******************************
}
function TCB4DatabaseSprig.AnyProblems: Boolean;
begin
  Result := (TCB4Database(Item).DatabaseName = '') and not TCB4Database(Item).AutoDatabaseName;
end;

function TCB4DatabaseSprig.Caption: string;
begin
  if TCB4Database(Item).AutoDatabaseName then
    Result := CaptionFor('<Auto>', UniqueName)
  else
    Result := CaptionFor(TCB4Database(Item).DatabaseName, UniqueName)
end;

function TCB4DatabaseSprig.Name: string;
begin
  Result := TCB4Database(Item).DatabaseName;
end;

{
******************************** TCB4TableSprig ********************************
}
function TCB4TableSprig.AnyProblems: Boolean;
begin
  Result := (TCB4Table(Item).TableName = '');
end;

function TCB4TableSprig.Caption: string;
begin
  Result := CaptionFor(TCB4Table(Item).TableName, UniqueName);
end;

function TCB4TableSprig.DragDropTo(AItem: TSprig): Boolean;
begin
  if AItem is TImpliedCB4DatabaseSprig then
  begin
    Result := True;
    TCB4Table(Item).DatabaseName := TImpliedCB4DatabaseSprig(AItem).FDatabaseName;
  end
  else if AItem is TCB4DatabaseSprig then
  begin
    Result := True;
    TCB4Table(Item).DatabaseName := TCB4Database(AItem.Item).DatabaseName;
  end
  else
    Result := False;
end;

function TCB4TableSprig.DragOverTo(AItem: TSprig): Boolean;
begin
  Result := ((AItem is TCB4DatabaseSprig) and (TCB4Database(AItem.Item).DatabaseName <> '')) or
            (AItem is TImpliedCB4DatabaseSprig);
end;

procedure TCB4TableSprig.FigureParent;
var
  vDatabaseName: string;
  vDatabase: TSprig;
begin
  with TCB4Table(Item) do
  begin
    vDatabase := nil;
    // find the database it is connected to
    if UsesDatabase then
    begin
//      cb4log('Figureparent', Name+': UsesDatabase');
      vDatabase := Root.Find(Database, False);
//      if vDatabase = nil then
//        vDatabaseName := SprigCB4AutoDatabaseName(Database.Name)
      vDatabaseName := DatabaseName;
    end
    else
      vDatabaseName := SprigCB4DatabaseName(DatabaseName);
//    cb4log('Figureparent', Name+': '+vDatabaseName);

    // if vDatabase is nil then use databasename
    if (vDatabase = nil) then
      vDatabase := Root.Find(vDatabaseName, False);

    // if not found see if its the default session
    if (vDatabase = nil) and
       (vDatabaseName = cDefaultDatabaseSprigName) then
      vDatabase := Root.Add(TDefaultCB4DatabaseSprig.Create(nil));

    if vDatabase = nil then
    begin
      vDatabase := Root.Find(SprigCB4ImpliedDatabaseName(DatabaseName), False);

      // if not make an implied session
      if vDatabase = nil then
      begin
        vDatabase := Root.Add(TImpliedCB4DatabaseSprig.Create(nil));
        TImpliedCB4DatabaseSprig(vDatabase).FDatabaseName := DatabaseName;
        if (Database <> nil) and Database.AutoDatabaseName then
          TImpliedCB4DatabaseSprig(vDatabase).FAutoName := Database.Name;
      end;
    end;

    // set parent to the database
    vDatabase.Add(Self);
  end;
end;

class function TCB4TableSprig.PaletteOverTo(AParent: TSprig; AClass: TClass):
   Boolean;
begin
  Result := ((AParent is TCB4DatabaseSprig) and (TCB4Database(AParent.Item).DatabaseName <> '')) or
            (AParent is TImpliedCB4DatabaseSprig);
end;

{$ENDIF}

{$ENDIF}
{$ENDIF}


end.
