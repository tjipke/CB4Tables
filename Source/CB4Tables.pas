{
*    Tiriss CB4 Tables
*    (c) MMV Tiriss
*
*    Not in model anymore
}

// TODO : IntPtrToAnsi -> Marshal.copy  ansistring?

unit CB4Tables;

interface


// uncomment next line for CodeBase versions before 6.5 that don't have Visual Foxpro Null support!
//{$DEFINE NOVFNULLSUPPORT}

{$IFDEF VER100}         // Delphi 3
{$MSG DELPHI 3 is not supported}
{$ENDIF}
{$IFDEF VER110}         // CBuilder 3
{$MSG CBUILDER 3 is not supported}
{$ENDIF}
{$IFDEF VER120}         // Delphi 4
{$MSG DELPHI 4 is not supported}
{$ENDIF}
{$IFDEF VER125}         // CBuilder 4
{$MSG CBUILDER 4 is not supported}
{$ENDIF}
{$IFDEF VER130}         // Delphi 5 & CBuilder 5
//{$DEFINE VERC5D5}
  {$DEFINE NEEDTRYSTRTOFLOAT}
  {$DEFINE NEEDMREWS}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE NEEDMREWS}   // in D6/Kylix the TMultiReadExclusiveWriteSynchronizer is buggy: don't use it
  {$IFDEF LINUX}
    {$IF RTLVersion<14.20}
    {$DEFINE NEEDTRYSTRTOFLOAT}
//    {$DEFINE VERK1}       // Kylix 1
    {$ELSEIF RTLVersion<14.50}
//    {$DEFINE VERK2}       // Kylix 2
    {$ELSEIF True}
//    {$DEFINE VERK3}       // Kylix 3
   {$IFEND}
  {$ELSE}
//  {$DEFINE VERC6D6}     // Delphi 6 & CBuilder 6
  {$ENDIF}
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

uses SysUtils, Classes, DB,
  {$IFDEF CLR}Tiriss.Codebase.NetIntf{$ELSE}
    {$IFDEF TRIAL}CodeBaseIntf{$ELSE}CodeBase{$ENDIF}
  {$ENDIF},
  {$IFDEF VERK1PLUS}Variants,{$ENDIF}
  {$IFDEF CLR}
  Tiriss.CB4Tables.DotNet,
  {$ENDIF}
  CB4Defs, CB4RecordBuffers;


const
  SCB4Version = '2.0';

type

{$IFNDEF CLR}
  TRecordBuffer = PChar; // used as indexer in recordbuffers
  TCB4DataEventInfo = Integer;
  TCB4PCharType = PChar;
  TCB4FieldList = TList;
  TCB4FieldDataRawBuffer = Pointer;
  TCB4RecordBuffer = TCB4RecordBufferWin32;
{$ELSE}
  TCB4DataEventInfo = TObject;
  TCB4PCharType = string;
  TCB4FieldDataRawBuffer = array of Byte;
  TCB4RecordBuffer = TCB4RecordBufferDotNet;
{$ENDIF}

  TKeyIndex = (kiLookup, kiRangeStart, kiRangeEnd, kiCurRangeStart,
    kiCurRangeEnd, kiSave);

  TKeyBuffer = class
    Modified: Boolean;
    Exclusive: Boolean;
    FieldCount: Integer;
    Data: TRecordBuffer;
  end;

  TCB4Table = class; //forward decl

  TCB4FreeBufferList = array of Integer;
  TCB4RecordBufferList = class
  private
    FList: TList;
    FFreeBufferList: TCB4FreeBufferList;
    FLastFreeIndex: Integer;
    FRecBufSize: Integer;
    FTable: TCB4Table;
    function GetBuffers(Index: TRecordBuffer): TCB4RecordBuffer;
    function GetCount: Integer;
    procedure SetBuffers(Index: TRecordBuffer; Value: TCB4RecordBuffer);
    procedure SetRecBufSize(const Value: Integer);
  protected
    function InternalAdd(aRecordBuffer: TCB4RecordBuffer): TRecordBuffer;
    property Buffers[Index: TRecordBuffer]: TCB4RecordBuffer read GetBuffers write
        SetBuffers; default;
  public
    constructor Create(aTable: TCB4Table);
    destructor Destroy; override;
    function Add: TRecordBuffer;
    procedure Clear; virtual;
    procedure CopyRecordContents(aSource, aDest: TCB4RecordBuffer);
    procedure Delete(Index: TRecordBuffer);
    function GetField(aIndex: TRecordBuffer; aField: TField; Buffer: TValueBuffer):
        Boolean;
    procedure SetField(aIndex: TRecordBuffer; aField: TField; Buffer: TValueBuffer);
    property Count: Integer read GetCount;
    property RecBufSize: Integer read FRecBufSize write SetRecBufSize;
  end;

  TCB4DataSet = class; {forward def.}
  TCB4Database = class; {forward def.}

{ TIndexFiles from DBTables}
  TIndexName = type string;

  TIndexFiles = class(TStringList)
  private
    FOwner: TCB4Table;
  public
    constructor Create(AOwner: TCB4Table);
    function Add(const S: string): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
  end;

  TCB4TableOption = (toShowDeletedRecords, toLockOnPost, toUseProductionIndex, toSequenceIndex, toRecognizeTagExpressions, toInvalidDatesAsNull, toNoCharacterTranslation);
  TCB4TableOptions = set of TCB4TableOption;

  TCB4PositionState = (psNormal, psBeforeFirst, psAfterLast);

  TCB4DatabaseType = (dtCB4Unknown, dtCB4Foxpro, dtCB4Clipper, dtCB4dBase);

  TDatabaseLoginEvent = procedure (Database: TCB4Database; LoginParams:
     TStrings) of object;

  TCB4Database = class (TCustomConnection)
  private
    FCBCODE4: CODE4;
    FConnected: Boolean;
    FDatabaseName: string;
    FDatabaseType: TCB4DatabaseType;
    FIndexPath: string;
    FOnLogin: TDatabaseLoginEvent;
    FParams: TStrings;
    FRaisedError: Integer;
    FTablePath: string;
    FAutoDatabaseName: Boolean;
    procedure CheckActive;
    procedure CheckInactive;
    function GetDatabaseType: TCB4DatabaseType;
    function GetInTransaction: Boolean;
    function GetLockAttempts: SmallInt;
    function GetLockDelay: Word;
    procedure Login(LoginParams: TStrings);
    procedure ParamsChanging(Sender: TObject);
    procedure SetLockAttempts(Value: SmallInt);
    procedure SetLockDelay(Value: Word);
    procedure SetAutoDatabaseName(Value: Boolean);
    function DatabaseNameStored: Boolean;
    function GetDatabaseName: string;
    procedure GenerateDBName;
    function GetMemoExprSize: Integer;
    procedure InternalSetDatabaseName(const Value: string);
  protected
    procedure Check(aErrorCode: Integer);
    procedure CheckMessage(aErrorCode: Integer; aMessage: string);
    procedure DisconnectDataSets;
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    function GetConnected: Boolean; override;
    function GetConnectionTimeout: Integer;
    procedure SetConnectionTimeout(Value: Integer);
    procedure SetDatabaseName(const Value: string);
    procedure SetIndexPath(const Value: string);
    procedure SetName(const Value: TComponentName); override;
    procedure SetParams(Value: TStrings);
    procedure SetTablePath(const Value: string);
    // for dot net we redefine them, else cb4dataset can't use them
    procedure RegisterClient(Client: TObject; Event: TConnectChangeEvent = nil); override;
    procedure UnRegisterClient(Client: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseDataSets;
    procedure Commit;
    procedure Rollback;
    procedure StartTransaction;
    property CBCODE4: CODE4 read FCBCODE4;
    property ConnectionTimeout: Integer read GetConnectionTimeout write
       SetConnectionTimeout;
    property DatabaseType: TCB4DatabaseType read GetDatabaseType;
    property InTransaction: Boolean read GetInTransaction;
    property MemoExprSize: Integer read GetMemoExprSize;
    property RaisedError: Integer read FRaisedError;
  published
    property AfterConnect;
    property AfterDisconnect;
    property BeforeConnect;
    property BeforeDisconnect;
    property Connected;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName stored
        DatabaseNameStored;
    property IndexPath: string read FIndexPath write SetIndexPath;
    property LockAttempts: SmallInt read GetLockAttempts write SetLockAttempts
       default -1;
    property LockDelay: Word read GetLockDelay write SetLockDelay default 100;
    property LoginPrompt default True;
    property OnLogin: TDatabaseLoginEvent read FOnLogin write FOnLogin;
    property Params: TStrings read FParams write SetParams;
    property TablePath: string read FTablePath write SetTablePath;
    property AutoDatabaseName: Boolean read FAutoDatabaseName write 
        SetAutoDatabaseName default False;
  end;

  TCB4DataSet = class (TDataSet)
  private
    FDatabase: TCB4Database;
    FDatabaseName: string;
    FIndexDefs: TIndexDefs;
    FDontClearDatabaseName: Boolean;
  protected
    procedure Disconnect;
    function GetDatabase: TCB4Database;
    function GetDatabaseName: string;
    procedure InternalHandleException; override;
    function InternalTranslate(const Src: string; var Dest: string; ToOem:
        Boolean): Integer; overload; virtual;
{$IFDEF WIN32}
    function InternalTranslate(Src, Dest: PChar; aLength: Integer; ToOem: Boolean):
        Integer; overload; virtual;
{$ENDIF}
    procedure RestoreInternalState; virtual;
    procedure SetDatabase(Value: TCB4Database); virtual;
    procedure SetDatabaseName(const Value: string);
    procedure SetIndexDefs(Value: TIndexDefs);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function InternalGetDatabase(aRequired: Boolean): TCB4Database;
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean);
        override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property FieldDefs;
    property IndexDefs: TIndexDefs read FIndexDefs write SetIndexDefs;
    function GetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat: Boolean):
        Boolean; override;
{$IFDEF WIN32}
    function Translate(Src, Dest: PChar; ToOem: Boolean): Integer; override;
{$ENDIF}
{$IFDEF CLR}
    function Translate(const Src: string; var Dest: string; ToOem: Boolean): Integer; override;
{$ENDIF}
    function UsesDatabaseName: Boolean;
    function UsesDatabase: Boolean;
  published
    property Active;
    property Database: TCB4Database read GetDatabase write SetDatabase stored
        UsesDatabase;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName stored
        UsesDatabaseName;
  end;

{$IFDEF VERK1PLUS}
  TCB4StreamSizeType = Int64;
{$ELSE}
  TCB4StreamSizeType = Integer;
{$ENDIF}

  TCB4BlobStream = class (TStream)
  private
    FBuffer: TRecordBuffer;
    FDataSet: TCB4Table;
    FField: TBlobField;
    FFieldNo: Integer;
    FMode: TBlobStreamMode;
    FModified: Boolean;
    FOpened: Boolean;
    FPosition: TCB4StreamSizeType;
    function GetBlobSize: Integer;
  protected
    procedure GetFromTable;
    procedure SetSize({$IFNDEF CLR}{$IFNDEF VER130}const{$ENDIF}{$ENDIF} NewSize: TCB4StreamSizeType); override;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Read(var Buffer{$IFDEF CLR}: array of Byte; Offset: Integer{$ENDIF}; Count: Integer): Integer; override;
    function Write(const Buffer{$IFDEF CLR}: array of Byte; Offset: Integer{$ENDIF}; Count: Integer): Integer; override;
{$IFDEF VERK1PLUS}
    function Seek(const Offset: TCB4StreamSizeType; Origin: TSeekOrigin): TCB4StreamSizeType; override;
{$ELSE}
    function Seek(Offset: TCB4StreamSizeType; Origin: Word): TCB4StreamSizeType; override;
{$ENDIF}
    procedure Truncate;
  end;

  TCB4RangeKey= record
    {$IFDEF CLR}
    KeyType: Byte;
    DoubleKey: Double;
    StringKey: TBytes;
   {$ELSE}
    case KeyType: Byte of
      r4num: (DoubleKey: Double);
      r4str: (StringKey: PChar);
    {$ENDIF}
  end;

  TCB4Table = class (TCB4DataSet)
  private
    FAbout: string;
    FCacheBlobs: Boolean;
    FCanModify: Boolean;
    FCaseInsIndex: Boolean;
    FCBDATA4: DATA4;
    FEmptyRecord: Integer;
    FExclusive: Boolean;
    FExpIndex: Boolean;
    FFieldRecPos: array of Integer;
    FFieldRecType: array of Byte;
    FFieldsIndex: Boolean;
    FFilterBuffer: TRecordBuffer;
    FFilterEXPR4: EXPR4;
    FFiltersActive: Boolean;
    FFirstSequencedPosition: Double;
    FIndexFields: TCB4FieldList;
    FIndexFiles: TStrings;
    FIndexName: TIndexName;
    FKeyBuffer: TKeyBuffer;
    FKeyBuffers: array[TKeyIndex] of TKeyBuffer;
    FKeyEXPR4: EXPR4;
    FKeyExpression: string;
    FKeySize: Word;
    FKeyExprEXPR4: EXPR4;
    FKeyExprSize: Word;
    FKeyRangeStartSize: Word;
    FKeyRangeEndSize: Word;
    FKeyType: Integer;
    FMasterLink: TMasterDataLink;
    FOptions: TCB4TableOptions;
    FPositionState: TCB4PositionState;
    FRaisedError: Integer;
    FRangeActive: Boolean;
    FRangeStartKey: TCB4RangeKey;
    FRangeEndKey: TCB4RangeKey;
    FRangeSequencedPosition: Double;
    FReadOnly: Boolean;
    FRecordBuffers: TCB4RecordBufferList;
    FRecordSize: Word;
    FStoreDefs: Boolean;
    FTableName: string;
    procedure AnalyzeTAG(CBTAG4INFO: PTAG4INFO; var Options: TIndexOptions; var
       Expression, DescFields, CaseInsFields: string);
    procedure AnalyzeTAGExpression(const TagExpression: string; var Options:
       TIndexOptions; var Expression, DescFields, CaseInsFields: string);
    procedure CheckMasterRange;
    procedure ClearBlobCache(Buffer: TRecordBuffer);
    procedure CloseTempTable;
    procedure CreateExprFilter(const Text: string);
    procedure DoAppend;
    procedure DoWrite;
    function GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
    function GetBlobState(Field: TField; Buffer: TRecordBuffer): TCB4BlobState;
    function GetExists: Boolean;
    function GetIndexFieldNames: string;
    function GetIndexName: string;
    procedure GetIndexParams(const IndexName: string; FieldsIndex: Boolean; var
       IndexedName, IndexTag: string);
    function GetIndexPath(aIndexFile: string): string;
    function GetIndexPaths(Index: Integer): string;
    function GetMasterFields: string;
    function GetTablePath: string;
    procedure GotoRecord(aRecordNumber: TCB4RecordNumber);
    procedure InitBufferPointers(GetProps: Boolean);
    function InternalFieldLength(FieldNo: Integer): Integer;
    procedure MasterChanged(Sender: TObject);
    procedure MasterDisabled(Sender: TObject);
    procedure OpenTempTable(OpenIndices: Boolean);
    function FilterCurrentRecord: Boolean;
    function SeekKeyExpression(KeyBuffer: TKeyBuffer): Integer;
    procedure SetBlobState(Field: TField; Buffer: TRecordBuffer; aBlobState:
        TCB4BlobState);
    procedure SetIndexFieldNames(const Value: string);
    procedure SetIndexFiles(Value: TStrings);
    procedure SetIndexName(const Value: string);
    procedure SetKeyExpression(FieldCount: Integer);
    procedure SetMasterFields(const Value: string);
    procedure SetOptions(Value: TCB4TableOptions);
    procedure SetReadOnly(Value: Boolean);
    procedure SetTableName(const Value: string);
    procedure UpdateRange;
    function DoRangeSeek(aEndKey: Boolean): Integer;
    function FieldDefsStored: Boolean;
    function IndexDefsStored: Boolean;
    function InternalCreateStringFilterText(const aFieldName: string; aFieldValue:
        string; aFieldLength: Integer; aPartial: Boolean; aIsMemoField:
        Boolean=False): string;
    procedure CopyKeyBuffer(aSource, aDestination: TKeyBuffer);
    procedure CopyRecordToRecordBuffer(Buffer: TRecordBuffer);
    procedure CopyRecordBufferToRecord(Buffer: TRecordBuffer);
    procedure FreeRangeKeys;
    function GetBlobData(Field: TField; Buffer: TRecordBuffer): TMemoryStream;
    function KeyBuffersEqual(aBuffer1, aBuffer2: TKeyBuffer): Boolean;
  protected
    FSavedRecord: Integer;
    procedure ActivateFilters;
    procedure AllocKeyBuffers;
    function AllocRecordBuffer: TRecordBuffer; override;
    procedure Check(aErrorCode: Integer);
    procedure CheckNeg(aErrorCode: Integer);
    procedure CheckSetKeyMode;
    procedure ClearCalcFields(Buffer: TRecordBuffer); override;
    procedure CloseBlob(Field: TField); override;
    function CreateLookupFilter(Fields: TList; const Values: Variant; Options:
        TLocateOptions): string;
    procedure DataEvent(Event: TDataEvent; Info: TCB4DataEventInfo); override;
    procedure DeactivateFilters;
    procedure DoOnNewRecord; override;
    procedure ExternalSetToRecord(Buffer: TRecordBuffer);
    procedure FieldLogicalToPhysical(FieldDef: TFieldDef; var atype: SmallInt;
       var Len, Dec: word);
    procedure FreeKeyBuffers;
    procedure FreeRecordBuffer(var Buffer: TRecordBuffer); override;
    procedure GetBookmarkData(Buffer: TRecordBuffer; {$IFDEF CLR}var Bookmark: TBookmark{$ELSE}Data: Pointer{$ENDIF}); override;
    function GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag; override;
    function GetCanModify: Boolean; override;
    function GetDataSource: TDataSource; override;
    function GetIndexFieldCount: Integer;
    function GetIndexFields(Index: Integer): TField;
    function GetIsIndexField(Field: TField): Boolean; override;
    function GetKeyBuffer(KeyIndex: TKeyIndex): TKeyBuffer;
    function GetKeyExclusive: Boolean;
    function GetMasterSource: TDataSource;
    function GetRecNo: Integer; override;
    function GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck: Boolean):
       TGetResult; override;
    function GetRecordCount: Integer; override;
    function GetRecordSize: Word; override;
    procedure InitFieldDefs; override;
    function InitKeyBuffer(Buffer: TKeyBuffer; aAllocate: Boolean): TKeyBuffer;
    procedure InitRecord(Buffer: TRecordBuffer); override;
    procedure InternalAddRecord(Buffer: {$IFDEF CLR}TRecordBuffer{$ELSE}Pointer{$ENDIF}; Append: Boolean); override;
    procedure InternalCancel; override;
    procedure InternalClose; override;
    procedure InternalDelete; override;
    procedure InternalEdit; override;
    procedure InternalFirst; override;
    procedure InternalGotoBookmark({$IFDEF CLR}const {$ENDIF}Bookmark: TBookmark); override;
    procedure InternalInitFieldDefs; override;
    procedure InternalInitRecord(Buffer: TRecordBuffer); override;
    procedure InternalLast; override;
    procedure InternalOpen; override;
    procedure InternalPost; override;
    procedure InternalRefresh; override;
    procedure InternalSetToRecord(Buffer: TRecordBuffer); override;
    function IsCursorOpen: Boolean; override;
    function LocateRecord(const KeyFields: string;  const KeyValues: Variant;
       Options: TLocateOptions;  SyncCursor: Boolean): Boolean;
    function MapsToIndex(Fields: TList; CaseInsensitive: Boolean): Boolean;
    procedure PostKeyBuffer(Commit: Boolean);
    function RecordAllowed: Integer;
    function ResetCursorRange: Boolean;
    procedure RestoreInternalState; override;
    procedure SetBookmarkData(Buffer: TRecordBuffer; {$IFDEF CLR}const Bookmark: TBookmark{$ELSE}Data: Pointer{$ENDIF}); override;
    procedure SetBookmarkFlag(Buffer: TRecordBuffer; Value: TBookmarkFlag); override;
    function SetCursorRange: Boolean;
    procedure SetDatabase(Value: TCB4Database); override;
    procedure SetExclusive(Value: Boolean);
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetFilterText(const Value: string); override;
    procedure SetIndex(const Value: string; FieldsIndex: Boolean);
    procedure SetIndexFields(Index: Integer; Value: TField);
    procedure SetKeyBuffer(KeyIndex: TKeyIndex; Clear: Boolean);
    procedure SetKeyExclusive(Value: Boolean);
    procedure SetKeyFields(KeyIndex: TKeyIndex;   const Values: array of const);
    procedure SetLinkRanges(MasterFields: TList);
    procedure SetMasterSource(const Value: TDataSource);
    procedure SetRecNo(Value: Integer); override;
    procedure SwitchToIndex(const IndexName, TagName:string);
    procedure UpdateIndexDefs; override;
    procedure CheckCBError;
    procedure DefChanged(Sender: TObject); override;
    {$IFDEF CLR}
    function InternalTranslate(const Src: string; var Dest: string; ToOem: Boolean): Integer; override;
    function InternalTranslate(const Src: IntPtrPChar; aMem: TMemoryStream; aLength: Integer; ToOem: Boolean): integer; overload;
    {$ELSE}
    function InternalTranslate(Src, Dest: PChar; aLength: Integer; ToOem: Boolean):
        Integer; override;
    {$ENDIF}
    function SeekSingleKey(aValue: Variant; aNext: Boolean): Integer;
    // redefine for .net
    property BlobFieldCount;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyRange;
    function BookmarkValid({$IFDEF CLR}Const{$ENDIF}Bookmark: TBookmark): Boolean; override;
    procedure Cancel; override;
    procedure CancelRange;
    procedure CloseIndexFile(const IndexFileName: string);
    function CompareBookmarks({$IFDEF CLR}const{$ENDIF}Bookmark1, Bookmark2: TBookmark): Integer;
       override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
       override;
    procedure CreateTable;
    procedure DeleteTable;
    procedure EditKey;
    procedure EditRangeEnd;
    procedure EditRangeStart;
    procedure EmptyTable;
    function FieldLength(Field: TField): Integer;
    function FindKey(const KeyValues: array of const): Boolean;
    procedure FindNearest(const KeyValues: array of const);
    function GetCurrentRecord(Buffer: TRecordBuffer{not really a recordbuffer indexer}): Boolean; override;
    function GetFieldData(Field: TField; Buffer: TValueBuffer): Boolean; override;
    function GetFieldDataRaw(aField: TField; {$IFDEF CLR}var {$ENDIF}aBuffer:
        TCB4FieldDataRawBuffer; aLength: Integer=MaxInt): Boolean;
    procedure GetIndexInfo;
    procedure GetIndexNames(List: TStrings);
    procedure GotoCurrent(Table: TCB4Table);
    function GotoKey: Boolean;
    procedure GotoNearest;
    function IsSequenced: Boolean; override;
    function Locate(const KeyFields: string; const KeyValues: Variant; Options:
       TLocateOptions): Boolean; override;
    function Lookup(const KeyFields: string; const KeyValues: Variant; const
       ResultFields: string): Variant; override;
    procedure OpenIndexFile(const IndexName: string);
    procedure Post; override;
    procedure SetFieldDataRaw(aField: TField; aBuffer: TValueBuffer; aLength:
       Integer=MaxInt);
    procedure SetKey;
    procedure SetRange(const StartValues, EndValues: array of const);
    procedure SetRangeEnd;
    procedure SetRangeStart;
    function CreateStringFilterText(const aFieldName: string; aFieldValue: string;
        aFieldLength: Integer): string;
    function FastSeek(aValue: Variant): Boolean;
    property CacheBlobs: Boolean read FCacheBlobs write FCacheBlobs default
       True;
    property CBDATA4: DATA4 read FCBDATA4;
    property Exists: Boolean read GetExists;
    property ExpIndex: Boolean read FExpIndex;
    property IndexFieldCount: Integer read GetIndexFieldCount;
    property IndexFields[Index: Integer]: TField read GetIndexFields write 
       SetIndexFields;
    property IndexPaths[Index: Integer]: string read GetIndexPaths;
    property KeyExclusive: Boolean read GetKeyExclusive write SetKeyExclusive;
    property KeySize: Word read FKeySize;
    property RaisedError: Integer read FRaisedError;
    property TablePath: string read GetTablePath;
  published
    property About: string read FAbout write FAbout;
    property AfterCancel;
    property AfterClose;
    property AfterDelete;
    property AfterEdit;
    property AfterInsert;
    property AfterOpen;
    property AfterPost;
    property AfterScroll;
    property AutoCalcFields;
    property BeforeCancel;
    property BeforeClose;
    property BeforeDelete;
    property BeforeEdit;
    property BeforeInsert;
    property BeforeOpen;
    property BeforePost;
    property BeforeScroll;
    property Exclusive: Boolean read FExclusive write SetExclusive default
       False;
    property FieldDefs stored FieldDefsStored;
    property Filter;
    property Filtered;
    property IndexDefs stored IndexDefsStored;
    property IndexFieldNames: string read GetIndexFieldNames write
       SetIndexFieldNames;
    property IndexFiles: TStrings read FIndexFiles write SetIndexFiles;
    property IndexName: string read GetIndexName write SetIndexName;
    property MasterFields: string read GetMasterFields write SetMasterFields;
    property MasterSource: TDataSource read GetMasterSource write 
       SetMasterSource;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property Options: TCB4TableOptions read FOptions write SetOptions default 
       [toUseProductionIndex];
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property StoreDefs: Boolean read FStoreDefs write FStoreDefs default false;
    property TableName: string read FTableName write SetTableName;
  end;

function DefaultDB: TCB4Database;

function DatabaseCount: Integer;
function Databases(Index: Integer): TCB4Database;

var
  IsClientServer: Boolean;

implementation

uses
  {$IFDEF LINUX} Libc, Variants, {$IFDEF TRIAL}XLib, QT,{$ENDIF}
  {$ELSE} Windows,
    {$IFDEF VERK1PLUS}
      {$IFDEF CLR}
        System.IO,// due to bug in delphi2005 hints!
        System.Security,
        System.Runtime.InteropServices,
        System.Text,
      {$ELSE}//Variants,
      {$ENDIF}
    {$ELSE}
      DBLogDlg, Forms,
    {$ENDIF}
  {$ENDIF} DBConsts;

resourcestring
  SNoFieldIndexes = 'No index currently active';

  SUnknownDatabaseName = 'Unknown database name %s';
  SInvalidDirectory = 'Invalid database path %s';
  SInitCB4Error = 'An error occurred while attempting to initialize CodeBase';
  SWideStringLocateNotSupported = 'Locating field %s of type widestring is not supported';
  SUnsupportedKeytype = 'Unsupported keytype: "%s"';
  SErrorInTagEvaluation = 'Error in tag evaluation';
  SOnlySearchingOnSingleKeySupport = 'Only searching on a single value with this key is supported';
  SErrorInFilterExpression = 'Error in filter expression: %s';

  SCantSetAutoDatabaseName = 'Can''t set the DatabaseName of Database (%s) with AutoDatabaseName=True';

  SCBError = 'CodeBase Error: %s (%d)';
{$IFDEF TRIAL}
  SIDEName = {$IFDEF LINUX}'Kylix';      {$ELSE}
             {$IFDEF BCB}  'C++Builder'; {$ELSE}
                           'Delphi';     {$ENDIF}
                                         {$ENDIF}
  STrial = #13#10'This program uses a trial version of CB4 Tables that only works if %s is running!'#13#10'Please get the retail version from: http://www.tiriss.com';
{$ENDIF}

const
  ShareModes: array[Boolean] of Integer = (OPEN4DENY_NONE, OPEN4DENY_RW);

  szUSERNAME         = 'USER NAME';
  szPASSWORD         = 'PASSWORD';
  szSERVERNAME       = 'SERVER NAME';
  szPROCESSID        = 'PROCESS ID';

  LOGFILE = 'c4.log';
  
  r4int       = integer('I') ; { Integer field }
  r4dateTime  = integer('T') ; { DateTime field }
  r4memoBin   = integer('X') ; { Memo (binary) field }
  r4double    = integer('B') ; { VF double field }
  r4currency  = integer('Y') ; { Currency field }

  r4unicode   = integer('W') ; { Unicode character field: Codebase 6.5 specific}

  VFNFields = [Byte(r4double), Byte(r4int), Byte(r4dateTime), Byte(r4currency)]; // Visual Foxpro fields that need special isNull handling
  SingleKeyTypes = [Byte(r4int), Byte(r4dateTime), Byte(r4currency), Byte(r4unicode), Byte(r4log)]; // Keys with only single value search support

  COneSecond = 1/(60*60*24);

var
  FDefaultDB: TCB4Database;
  FDatabases: TStringList;

{$IFDEF NEEDMREWS}
type
{$IFDEF VERK1PLUS}
// in D6/Kylix use the TSimpleRWSync
  TMultiReadExclusiveWriteSynchronizer = TSimpleRWSync;
{$ELSE}
  TMultiReadExclusiveWriteSynchronizer = class (TObject)
  private
    FSection: TRTLCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginRead;
    procedure EndRead;
    procedure BeginWrite;
    procedure EndWrite;
  end;

constructor TMultiReadExclusiveWriteSynchronizer.Create;
begin
  inherited Create;
  InitializeCriticalSection(FSection);
end;
destructor TMultiReadExclusiveWriteSynchronizer.Destroy;
begin
  DeleteCriticalSection(FSection);
  inherited Destroy;
end;
procedure TMultiReadExclusiveWriteSynchronizer.BeginRead;
begin
  EnterCriticalSection(FSection);
end;
procedure TMultiReadExclusiveWriteSynchronizer.EndRead;
begin
  LeaveCriticalSection(FSection);
end;
procedure TMultiReadExclusiveWriteSynchronizer.BeginWrite;
begin
  BeginRead;
end;
procedure TMultiReadExclusiveWriteSynchronizer.EndWrite;
begin
  EndRead;
end;
{$ENDIF}
{$ENDIF}

var
  FDatabasesSync : TMultiReadExclusiveWriteSynchronizer;

{$IFDEF TRIAL}
{$INCLUDE TrialTest.inc}
{$ENDIF}

{$IFNDEF LINUX}
{$IFNDEF CLR}
var
  SaveCode4InitUndo: function( p1 : CODE4 ) : Integer; stdcall;

function IsOldCodebase( p1 : CODE4 ): Boolean;
var
  CBHandle: HMODULE;
begin
  CBHandle := LoadLibrary(PChar(CBDllName));
  try
    if CBHandle < HINSTANCE_ERROR then
      Result := True {can't find it asume it is oldcb}
    else
      Result := GetProcAddress(CBHandle, 'code4largeOn') = nil; {only in cb64 and higher}
    if Result then
    begin
      SaveCode4InitUndo := GetProcAddress(CBHandle, 'code4initUndo');
      if Assigned(SaveCode4InitUndo) then SaveCode4InitUndo(P1);
    end;
  finally
    FreeLibrary(CBHandle);
  end;
end;
{$ENDIF} //LINUX
{$ENDIF} //LINUX

{$IFNDEF VERK1PLUS} //only needed for D5 & C5 (Pre Kylix)
{from filectrl:} // Kylix and higher have these in sysutils
function DirectoryExists(const Name: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(Name));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function IncludeTrailingPathDelimiter(const aPath: string): string;
begin
  Result := aPath;
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then
    Result := Result + '\';
end;

(*
function InternalWideCompare(const S1, S2: WideString; CmpFlags: Integer): Integer;
var
  a1, a2: AnsiString;
begin
  SetLastError(0);
  Result := CompareStringW(LOCALE_USER_DEFAULT, CmpFlags, PWideChar(S1),
    Length(S1), PWideChar(S2), Length(S2)) - 2;
  case GetLastError of
    0: ;
    ERROR_CALL_NOT_IMPLEMENTED:
    begin
      a1 := s1;
      a2 := s2;
      Result := CompareStringA(LOCALE_USER_DEFAULT, CmpFlags, PChar(a1), Length(a1),
        PChar(a2), Length(a2)) - 2;
    end;
  else
    RaiseLastWin32Error;
  end;
end;

function WideCompareText(const S1, S2: WideString): Integer;
begin
  Result := InternalWideCompare(S1, S2, NORM_IGNORECASE);
end;

function WideCompareStr(const S1, S2: WideString): Integer;
begin
  Result := InternalWideCompare(S1, S2, 0);
end;
*)
function VarToWideStr(const V: Variant): WideString;
begin
  if VarIsNull(V) then
    Result := ''
  else
    Result := V;
end;
{$ENDIF}

function DelimitDatabasePath(const aPath: string): string;
// a database path that is empty should stay empty!
begin
  if (aPath <> '') then
    Result := IncludeTrailingPathDelimiter(aPath)
  else
    Result := aPath;
end;

function JustFileName(const FileName: string): string;
begin
  Result := ExtractFileName(FileName);
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result)));
end;

procedure ApplicationHandleException(Sender: TObject);
begin
{$IFNDEF VERK1PLUS}
  Application.HandleException(Sender)
{$ELSE}
  if Assigned(Classes.ApplicationHandleException) then
    Classes.ApplicationHandleException(Sender);
{$ENDIF}
end;

function DefaultDB: TCB4Database;
begin
  FDatabasesSync.BeginWrite;
  try
    if not Assigned(FDefaultDB) then
    begin
      FDefaultDB := TCB4Database.Create(nil);
    end;
  finally
    FDatabasesSync.EndWrite;
  end;
  Result := FDefaultDB;
end;

function DatabaseCount: Integer;
begin
  FDatabasesSync.BeginRead;
  try
    Result := FDatabases.Count;
//    if Assigned(FDefaultDB) then Inc(Result);
  finally
    FDatabasesSync.EndRead;
  end;
end;

function Databases(Index: Integer): TCB4DataBase;
begin
  FDatabasesSync.BeginRead;
  try
(*
    if Assigned(FDefaultDB) then
    begin
      if Index = 0 then
      begin
        Result := DefaultDB;
        Exit;
      end;
      Dec(Index);
    end;
*)
    Result := FDatabases.Objects[Index] as TCB4DataBase;
  finally
    FDatabasesSync.EndRead;
  end;
end;

procedure RegisterDatabase(Value: TCB4DataBase; const Name: string);
var
  I: Integer;
begin
  FDatabasesSync.BeginWrite;
  try
    if (Name <> '') and (FDatabases.IndexOf(Name) <> -1) then
      DatabaseErrorFmt(SDuplicateDatabaseName, [Name]);
    I := FDatabases.IndexOfObject(Value);
    if I <> -1 then
      FDatabases[i] := Name
    else
      FDatabases.AddObject(Name, Value);
  finally
    FDatabasesSync.EndWrite;
  end;
end;

procedure UnregisterDatabase(Value: TCB4DataBase);
var
  I: Integer;
begin
  FDatabasesSync.BeginWrite;
  try
    I := FDatabases.IndexOfObject(Value);
    if I <> -1 then FDatabases.Delete(I);
  finally
    FDatabasesSync.EndWrite;
  end;
end;

{ TIndexFiles from DBTables}

constructor TIndexFiles.Create(AOwner: TCB4Table);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TIndexFiles.Add(const S: string): Integer;
begin
  with FOwner do
  begin
    if Active then OpenIndexFile(S);
    IndexDefs.Updated := False;
  end;
  Result := inherited Add(S);
end;

procedure TIndexFiles.Clear;
var
  I: Integer;
begin
  with FOwner do
    if Active then
      for I := 0 to Count - 1 do CloseIndexFile(Strings[I]);
  inherited Clear;
end;

procedure TIndexFiles.Insert(Index: Integer; const S: string);
begin
  inherited Insert(Index, S);
  with FOwner do
  begin
    if Active then OpenIndexFile(S);
    IndexDefs.Updated := False;
  end;
end;

procedure TIndexFiles.Delete(Index: Integer);
begin
  with FOwner do
  begin
    if Active then CloseIndexFile(Strings[Index]);
    IndexDefs.Updated := False;
  end;
  inherited Delete(Index);
end;

{
********************************* TCB4Database *********************************
}
constructor TCB4Database.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParams := TStringList.Create;
  TStringList(FParams).OnChanging := ParamsChanging;
  LoginPrompt := True;

  FCBCODE4 := code4init;
  if FCBCODE4 = nil then DatabaseError(SInitCB4Error);

  code4errExpr(FCBCODE4, 0);
  code4singleOpen(FCBCODE4, 0);

  code4log(FCBCODE4, LOG4TRANS);
  code4logOpenOff(FCBCODE4);

  {all dialogs off:}
  code4errOff(FCBCODE4, 1);
  RegisterDatabase(Self, FDatabaseName);
end;

destructor TCB4Database.Destroy;
begin
  UnregisterDatabase(Self); {first unregister (before destroy!}
  // destroy: does a close but what about unregistering... done on close of table??? yes
  DisconnectDatasets; // force close+disconnect
  inherited Destroy;
  {$IFNDEF LINUX}{$IFNDEF CLR}
  if not IsOldCodebase(FCBCODE4) then
  {$ENDIF}{$ENDIF}
    code4initUndo(FCBCODE4);  {throw away FCBCODE4 after destroy (still needed by tables)}
  FParams.Free;
end;

procedure TCB4Database.Check(aErrorCode: Integer);
begin
  CheckMessage(aErrorCode, '');
end;

procedure TCB4Database.CheckMessage(aErrorCode: Integer; aMessage: string);
begin
  if aErrorCode <> r4success then
  begin
    FRaisedError := aErrorCode;
    if aMessage <> '' then
      aMessage := aMessage+#13;
    DatabaseErrorFmt(aMessage+SCBError, [error4text(FCBCODE4, aErrorCode), aErrorCode]);
  end;
end;

procedure TCB4Database.CheckActive;
begin
  if not Connected then DatabaseError(SDatabaseClosed);
end;

procedure TCB4Database.CheckInactive;
var
  I: Integer;
begin
  if csDesigning in ComponentState then
    Close
  else
  begin
    if Connected then DatabaseError(SDatabaseOpen);
    for I := DataSetCount-1 downto 0 do
      if TCB4DataSet(DataSets[I]).Active then DatabaseError(SDatabaseOpen);
  end;
end;

procedure TCB4Database.CloseDataSets;
var
  I: Integer;
begin
  for I := DataSetCount-1 downto 0 do TCB4DataSet(DataSets[I]).Close;
end;

procedure TCB4Database.DisconnectDataSets;
begin
  while DataSetCount <> 0 do TCB4DataSet(DataSets[DataSetCount-1]).Disconnect;
end;

procedure TCB4Database.Commit;
begin
  CheckActive;
  try
    Check(code4tranCommit(FCBCODE4));
  finally
   code4unlock(FCBCODE4);
  end;
end;

procedure TCB4Database.DoConnect;
var
  LoginParams: TStringList;
  ServerName, ProcessId, UserName, Password: string;
  Err: Integer;
begin
  FConnected := False;
  {$IFDEF TRIAL}
  if not IsIDERunning2 then
    raise EDatabaseError.CreateFmt(STrial, [SIDEName]);
  {$ENDIF}
  if IsClientServer then
  begin
    if LoginPrompt then
    begin
      LoginParams := TStringList.Create;
      try
        LoginParams.Values[szUSERNAME] := FParams.Values[szUSERNAME];
        Login(LoginParams);
        Password := LoginParams.Values[szPASSWORD];
        FParams.Values[szUSERNAME] := LoginParams.Values[szUSERNAME];
      finally
        LoginParams.Free;
      end;
    end else
      Password := FParams.Values[szPASSWORD];
  
    ServerName := FParams.Values[szSERVERNAME];
    if ServerName = '' then ServerName := DefaultServerId;
    ProcessId := FParams.Values[szPROCESSID];
    if ProcessId = '' then ProcessId := DefaultProcessId;
    UserName := FParams.Values[szUSERNAME];

    Err := code4connect(FCBCODE4, TCB4PCharType(ServerName), TCB4PCharType(ProcessId), TCB4PCharType(UserName), TCB4PCharType(Password), TCB4PCharType(DefaultProtocol));
//    Err := code4connect(FCBCODE4, ServerName, ProcessId, UserName, Password, DefaultProtocol);
    if (Err <> r4connected) and (Err <> r4success) then
      CheckMessage(Err, Format(SLoginError, [DatabaseName]));
  end
  else
  begin
    if (Length(TablePath) <> 0) and not DirectoryExists(TablePath) then
      DatabaseErrorFmt(SInvalidDirectory, [TablePath]);
    if (Length(IndexPath) <> 0) and not DirectoryExists(IndexPath) then
      DatabaseErrorFmt(SInvalidDirectory, [IndexPath]);
  end;
  
  FConnected := True;
end;

procedure TCB4Database.DoDisconnect;
begin
  CloseDataSets;
  FConnected := False;
end;

function TCB4Database.GetConnected: Boolean;
begin
  Result := FConnected;
end;

function TCB4Database.GetConnectionTimeout: Integer;
begin
  Result := code4timeout(FCBCODE4);
end;

function TCB4Database.GetDatabaseType: TCB4DatabaseType;
var
  {$IFDEF CLR}
  p: IntPtrPChar; S: string;
  {$ELSE}
  p: PChar;
  {$ENDIF}
begin
  if FDatabaseType = dtCB4Unknown then
  begin
    p := code4indexExtension(CBCODE4);
    if p=nil then
      // nothing
    else
    begin
    {$IFDEF CLR}
      S := Marshal.PtrToStringAnsi(p);
      if CompareText(S, 'cdx') = 0 then
        FDatabaseType := dtCB4FoxPro
      else
      if (CompareText(S, 'cgp') = 0) or (CompareText(S, 'ntx') = 0) then
        FDatabaseType := dtCB4Clipper
      else
      if CompareText(S, 'mdx') = 0 then
        FDatabaseType := dtCB4dBase
    {$ELSE}
      if StrIComp(p, 'cdx') = 0 then
        FDatabaseType := dtCB4FoxPro
      else
      if (StrIComp(p, 'cgp') = 0) or (StrIComp(p, 'ntx') = 0) then
        FDatabaseType := dtCB4Clipper
      else
      if StrIComp(p, 'mdx') = 0 then
        FDatabaseType := dtCB4dBase
    {$ENDIF}
    end;
  end;
  Result := FDatabaseType;
end;

function TCB4Database.GetInTransaction: Boolean;
begin
  Result := (FCBCODE4 <> nil) and ((code4tranStatus(FCBCODE4) and $FFFF) = r4active);  // due to bug in codebase -> and with $FFFF
end;

function TCB4Database.GetLockAttempts: SmallInt;
begin
  Result := code4LockAttempts(FCBCODE4, r4check);
end;

function TCB4Database.GetLockDelay: Word;

  {$IFNDEF LINUX}
  {$IFNDEF CLR}
  var
    c: CODE4;
    r: WORD;
  {$ENDIF}
  {$ENDIF}

begin
  {$IFDEF LINUX}
  Result := code4lockDelay(FCBCODE4, r4check);
  {$ELSE}
  {$IFDEF CLR}
  Result := code4lockDelay(FCBCODE4, r4check);
  {$ELSE}

  // next should work with codebase 6.3 - 6.5 (with different parameter defs) and(!) different optimization options!
  c := FCBCODE4;
  asm
    push Integer(r4check);
    mov eax,c;
    push eax;
    call code4lockDelay;
    mov r,ax;
  end;
  Result := r; // assign result
  {$ENDIF}
  {$ENDIF}
end;

function TCB4Database.GetMemoExprSize: Integer;
  {$IFNDEF LINUX}
  {$IFNDEF CLR}
  var
    c: CODE4;
    r: WORD;
  {$ENDIF}
  {$ENDIF}
begin
  {$IFDEF LINUX}
  Result := code4memSizeMemoExpr(FCBCODE4, r4check);
  {$ELSE}
  {$IFDEF CLR}
  Result := code4memSizeMemoExpr(FCBCODE4, r4check);
  {$ELSE}
  // next should work with codebase 6.3 - 6.5 (with different parameter defs) and(!) different optimization options!
  c := FCBCODE4;
  asm
    push Integer(r4check);
    mov eax,c;
    push eax;
    call code4memSizeMemoExpr;
    mov r,ax;
  end;
  Result := r; // assign result
  {$ENDIF}
  {$ENDIF}
end;


procedure TCB4Database.RegisterClient(Client: TObject; Event: TConnectChangeEvent = nil);
begin
  inherited;
end;

procedure TCB4Database.UnRegisterClient(Client: TObject);
begin
  inherited;
end;

procedure TCB4Database.Login(LoginParams: TStrings);
var
  UserName, Password: string;
begin
  if Assigned(FOnLogin) then FOnLogin(Self, LoginParams) else
  begin
    UserName := LoginParams.Values[szUSERNAME];
  {$IFNDEF VERK1PLUS}
    if not LoginDialogEx(DatabaseName, UserName, Password, False) then
      DatabaseErrorFmt(SLoginError, [DatabaseName]);
  {$ELSE}
    if Assigned(LoginDialogExProc) then
      if not LoginDialogExProc(DatabaseName, UserName, Password, False) then
        DatabaseErrorFmt(SLoginError, [DatabaseName]);
    { TODO : No login dialog -> not defined in DBTables }
  {$ENDIF}
    LoginParams.Values[szUSERNAME] := UserName;
    LoginParams.Values[szPASSWORD] := Password;
  end;
end;

procedure TCB4Database.ParamsChanging(Sender: TObject);
begin
  CheckInactive;
end;

procedure TCB4Database.Rollback;
var
  I: Integer;
begin
  CheckActive;
  try
    Check(code4tranRollback(FCBCODE4));
  finally
   code4unlock(FCBCODE4);
  end;
  for I := 0 to DataSetCount-1 do
    TCB4DataSet(DataSets[I]).RestoreInternalState;
end;

procedure TCB4Database.SetConnectionTimeout(Value: Integer);
begin
  code4timeoutSet(FCBCODE4, Value);
end;

procedure TCB4Database.SetDatabaseName(const Value: string);
var
  S: string;
begin
  S := Trim(Value);
  if S = '' then DatabaseErrorFmt(SInvalidDatabaseName, [Value]);
  if AutoDatabaseName then
  begin
    if csDesigning in ComponentState then
      AutoDatabaseName := False
    else
      DatabaseErrorFmt(SCantSetAutoDatabaseName, [Self.Name]);
  end;

  InternalSetDatabaseName(S);
end;

procedure TCB4Database.InternalSetDatabaseName(const Value: string);
var
  I: Integer;
begin
  if CompareText(Value, FDatabaseName) <> 0 then
    RegisterDatabase(Self, Value); // we can reregister a database now

  FDatabaseName := Value;

  for I := DataSetCount-1 downto 0 do
  begin
    if TCB4DataSet(DataSets[I]).UsesDatabaseName then
      TCB4DataSet(DataSets[I]).FDatabaseName := FDatabaseName; {make Datasets aware of it}
  end;
end;

procedure TCB4Database.SetIndexPath(const Value: string);
begin
  CheckInactive;
  CloseDataSets;
  FIndexPath := Value;
end;

procedure TCB4Database.SetLockAttempts(Value: SmallInt);
begin
  code4LockAttempts(FCBCODE4, Value);
end;

procedure TCB4Database.SetLockDelay(Value: Word);
begin
  code4lockDelay(FCBCODE4, Value);
end;

procedure TCB4Database.SetName(const Value: TComponentName);
var
  ChangeDBName: Boolean;
begin
  ChangeDBName :=
    not (csLoading in ComponentState) and (Name = FDatabaseName);
  inherited SetName(Value);
  if ChangeDBName then
    GenerateDBName;
end;

procedure TCB4Database.SetParams(Value: TStrings);
begin
  CheckInactive;
  FParams.Assign(Value);
end;

procedure TCB4Database.SetTablePath(const Value: string);
begin
  CheckInactive;
  CloseDataSets;
  FTablePath := Value;
end;

procedure TCB4Database.StartTransaction;
var
  Err: Integer;
  S: string;
begin
  CheckActive;
  (*
  if (TransIsolation <> tiDirtyRead) then
    DatabaseError(SLocalTransDirty);
  *)
  
  S := DelimitDatabasePath(TablePath)+LOGFILE;
  Err := code4logOpen(FCBCODE4, TCB4PCharType(S), nil);
//  Err := code4logOpen(FCBCODE4, S, nil);

  if Err = -1 then
  begin
    if FileExists(S) then
      SysUtils.DeleteFile(S);
    Err := code4errorCode(FCBCODE4, 0); {reset errorcode}
  end;
  
  if (Err <> r4success) and (Err <> r4logOpen) then
  begin
    Err := code4logCreate(FCBCODE4, TCB4PCharType(S), nil);
//    Err := code4logCreate(FCBCODE4, S, nil);
    if (Err <> r4success) and (Err <> r4logOpen) then
      Check(Err);
  end;
  Check(code4tranStart(FCBCODE4));
end;

procedure TCB4Database.SetAutoDatabaseName(Value: Boolean);
begin
  FAutoDatabaseName := Value;
  if Value then
    InternalSetDatabaseName('')
  else
    GenerateDBName;
end;

function TCB4Database.DatabaseNameStored: Boolean;
begin
  Result := not FAutoDatabaseName;
end;

function TCB4Database.GetDatabaseName: string;
begin
  if AutoDatabaseName then
  begin
    if csDesigning in ComponentState then
      Result := ''
    else
      if FDatabaseName = '' then
        GenerateDBName;
  end;
  Result := FDatabaseName;
end;

procedure TCB4Database.GenerateDBName;
var
  I: Integer;
  NewName, Prefix: string;
begin
  I := 1;
  if AutoDatabaseName then
  begin
    Prefix := Name+'_';
    NewName := Prefix+'0';
  end
  else
  begin
    Prefix := Name;
    NewName := Prefix;
  end;
  while True do
  begin
    FDatabasesSync.BeginRead;
    try
      while FDatabases.IndexOf(NewName) <> -1 do
      begin
        if I < FDatabases.Count then
          I := FDatabases.Count;
        NewName := Prefix + IntToStr(I);
        Inc(I);
      end;
    finally
      FDatabasesSync.EndRead;
    end;
    try
      InternalSetDatabaseName(NewName);
      Break;
    except
      on E: EDatabaseError do ;// get here if other thread also got this name in the mean time! -> Try again
    end;
  end;
end;



{
********************************* TCB4DataSet **********************************
}

constructor TCB4DataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIndexDefs := TIndexDefs.Create(Self);
end;

destructor TCB4DataSet.Destroy;
begin
  if Assigned(FDatabase) then FDatabase.UnRegisterClient(Self);
  inherited Destroy;
  // free indexdefs after destroy: is still used
  FIndexDefs.Free;
end;

procedure TCB4DataSet.Disconnect;
begin
  {database tells us to disconnect from him}
  Close;
  if Assigned(FDatabase) then
  begin
    FDontClearDatabaseName := True;
    try
      Database := nil;
    finally
      FDontClearDatabaseName := True;
    end;
  end;
end;

function TCB4DataSet.GetDatabase: TCB4Database;
begin
  Result := InternalGetDatabase(not(csDesigning in ComponentState));
end;

function TCB4DataSet.InternalGetDatabase(aRequired: Boolean): TCB4Database;
var
  I: Integer;
begin
  if not Assigned(FDatabase) then
  begin
    FDontClearDatabaseName := True;
    try
      if FDatabaseName = '' then
      begin
        if aRequired then
          Database := DefaultDB
      end
      else
      begin
        FDatabasesSync.BeginRead;
        try
          I := FDatabases.IndexOf(FDatabaseName);
          if I = -1 then
          begin
            if aRequired then
              DatabaseErrorFmt(SUnknownDatabaseName, [FDatabaseName]);
          end
          else
          begin
            Database := TCB4Database(FDatabases.Objects[I]);
          end;
        finally
          FDatabasesSync.EndRead;
        end;
      end
    finally
      FDontClearDatabaseName := False;
    end;
  end;
  Result := FDatabase;
end;

function TCB4DataSet.GetDatabaseName: string;
begin
  if Assigned(FDatabase) then
    Result := FDatabase.DatabaseName
  else
    Result := FDatabaseName;
end;

{
********************************* TCB4D4Table **********************************
}
function TCB4DataSet.GetFieldData(Field: TField; Buffer: TValueBuffer; NativeFormat:
    Boolean): Boolean;
begin
  if (Field.DataType=ftWidestring) or (Field.DataType=ftDateTime) then // for ftWideString, ftDatetime NativeFormat = false -> we ignore the dataconvert stuff
    Result := GetFieldData(Field, Buffer)
  else
    Result := inherited GetFieldData(Field, Buffer, NativeFormat)
end;

procedure TCB4DataSet.InternalHandleException;
begin
  ApplicationHandleException(Self);
end;

function TCB4DataSet.InternalTranslate(const Src: string; var Dest: string; ToOem: Boolean):
   Integer;
  {$IFDEF CLR}
var
  Dst: StringBuilder;
  {$ENDIF}
begin
  {$IFDEF CLR}
  Result := Length(Src);
  Dest := Src;
  Dst := StringBuilder.Create(Result);
  if ToOem then
  begin
    if Result > 0 then
    begin
      CharToOemBuffA(Src, Dst, Result); // widestring version doesn't work!
      Dst.Length := Result;
      Dest := Dst.ToString;
    end;
  end
  else
  begin
    if Result > 0 then
    begin
      OemToCharBuffA(Src, Dst, Result); // widestring version doesn't work!
      Dst.Length := Result;
      Dest := Dst.ToString;
    end;
  end;
  {$ELSE}
  Result := InternalTranslate(PChar(Src), PChar(Dest), Length(Src), ToOem);
  {$ENDIF}
end;

{$IFNDEF CLR}
function TCB4DataSet.InternalTranslate(Src, Dest: PChar; aLength: Integer;
    ToOem: Boolean): Integer;
begin
   {$IFDEF LINUX}
  Result := inherited Translate(Src, Dest, ToOem);
  {$ELSE}
  Result := aLength;
  if ToOem then
  begin
    if Result > 0 then
      CharToOemBuff(Src, Dest, Result);
  end
  else
  begin
    if Result > 0 then
      OemToCharBuff(Src, Dest, Result);
  end;
  {$ENDIF}
end;
{$ENDIF}

procedure TCB4DataSet.RestoreInternalState;
begin
end;

procedure TCB4DataSet.SetDatabase(Value: TCB4Database);
begin
  if Value <> FDatabase then
  begin
    if Assigned(FDatabase) then
    begin
      FDatabase.UnRegisterClient(Self);
      FDatabase.RemoveFreeNotification(Self);
    end;
    FDatabase := Value;
    if Assigned(FDatabase) then
    begin
      FDatabase.RegisterClient(Self);
      FDatabase.FreeNotification(Self);
    end;
  end;
  if not FDontClearDatabaseName then
    FDatabaseName := '';
end;

procedure TCB4DataSet.SetDatabaseName(const Value: string);
begin
  if Assigned(FDatabase) {it knows us} then
  begin
    if (CompareText(Value, FDatabaseName) <> 0) then
    begin
      CheckInactive;
      Disconnect;
    end;
  end;
  FDatabaseName := Value;
end;

procedure TCB4DataSet.SetIndexDefs(Value: TIndexDefs);
begin
  IndexDefs.Assign(Value);
end;

function TCB4DataSet.UsesDatabaseName: Boolean;
begin
  Result := (FDatabaseName<>'') or (FDatabase=nil) or (FDatabase=FDefaultDB);
end;

function TCB4DataSet.UsesDatabase: Boolean;
begin
  Result := not UsesDatabaseName;
end;

procedure TCB4DataSet.Notification(AComponent: TComponent; Operation: 
    TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDatabase) then
    Disconnect;
end;

procedure TCB4DataSet.SetFieldData(Field: TField; Buffer: TValueBuffer;
    NativeFormat: Boolean);
begin
  if (Field.DataType=ftWidestring) or (Field.DataType=ftDateTime) then // for ftWideString, ftDatetime NativeFormat = false -> we ignore the dataconvert stuff
    SetFieldData(Field, Buffer)
  else
    inherited SetFieldData(Field, Buffer, NativeFormat)
end;

{$IFDEF WIN32}
function TCB4DataSet.Translate(Src, Dest: PChar; ToOem: Boolean): Integer;
begin
  Result := InternalTranslate(Src, Dest, StrLen(Src), ToOem);
  if Src <> Dest then Dest[Result] := #0;
end;
{$ENDIF}
{$IFDEF CLR}
function TCB4DataSet.Translate(const Src: string; var Dest: string; ToOem: Boolean): Integer;
begin
  Result := InternalTranslate(Src, Dest, ToOem);
end;
{$ENDIF}

{
******************************** TCB4BlobStream ********************************
}
constructor TCB4BlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
begin
  inherited Create;
  FMode := Mode;
  FField := Field;
  FDataSet := FField.DataSet as TCB4Table;
  FFieldNo := FField.FieldNo;

  if not FDataSet.GetActiveRecBuf(FBuffer) then Exit;
  if FDataSet.State = dsFilter then
    DatabaseErrorFmt(SNoFieldAccess, [FField.DisplayName]);

  if not FField.Modified then
  begin

    if not FDataSet.FCacheBlobs then {make Sure we get it from the Table}
    begin
      FDataSet.SetBlobState(FField, FBuffer, bsEmpty);
    end;

    if Mode <> bmRead then
    begin
      if FField.ReadOnly then DatabaseErrorFmt(SFieldReadOnly, [FField.DisplayName]);
      if not (FDataSet.State in [dsEdit, dsInsert]) then DatabaseError(SNotEditing);
    end;
  end;
  FOpened := FDataset.State <> dsSetKey; {we can't open a blob in setkey state}
  if Mode = bmWrite then Truncate;
end;

destructor TCB4BlobStream.Destroy;
begin
  if FOpened then
  begin
    if FModified then FField.Modified := True;

    if not FDataSet.FCacheBlobs and
      (FDataSet.GetBlobState(FField, FBuffer) <> bsModified) then
    begin
      FDataSet.SetBlobState(FField, FBuffer, bsEmpty);
    end;

  end;

  if FModified then
  try
    FDataSet.DataEvent(deFieldChange, TCB4DataEventInfo(FField));
  except
    ApplicationHandleException(Self);
  end;
end;

function TCB4BlobStream.GetBlobSize: Integer;
begin
  Result := 0;
  if FOpened then
  begin
    if FDataSet.GetBlobState(FField, FBuffer) = bsEmpty then
    begin
      if FDataSet.GetBookmarkFlag(FBuffer) = bfCurrent then
      begin  // only get from table if bookmarkdata is valid
        FDataSet.ExternalSetToRecord(FBuffer);
        Result := f4memoLen(d4fieldJ(FDataSet.CBDATA4, FFieldNo));
        if Result <= 0 then FDataSet.CheckCBError;
      end
      else
        Result := 0;
    end
    else
      Result := FDataSet.GetBlobData(FField, FBuffer).Size;
  end;
end;


procedure TCB4BlobStream.SetSize({$IFNDEF CLR}{$IFNDEF VER130}const{$ENDIF}{$ENDIF} NewSize: TCB4StreamSizeType);
begin
  // nothing to do
end;

procedure TCB4BlobStream.GetFromTable;
var
  CBFIELD4: FIELD4;
  {$IFDEF CLR}
  MemoStr: IntPtrPChar;
  {$ELSE}
  MemoStr: PChar;
  {$ENDIF}
  MemoSize: Integer;
  Mem: TMemoryStream;
begin
  if FDataSet.GetBookmarkFlag(FBuffer) = bfCurrent then // if bookmarkdata is valid
  begin
    FDataSet.ExternalSetToRecord(FBuffer);
    CBFIELD4 := d4fieldJ(FDataSet.CBDATA4, FFieldNo);
    MemoSize := f4memoLen(CBFIELD4);
    if MemoSize >= 0 then
      MemoStr := f4memoStr(CBFIELD4)
    else
      MemoStr := nil;
    if (MemoStr = nil) then
    begin
      FDataSet.CheckCBError;
      Exit;
    end
  end
  else
  begin
    MemoSize := 0;
    MemoStr := nil; // remove warning
  end;

  FDataSet.SetBlobState(FField, FBuffer, bsCached);
  Mem := FDataSet.GetBlobData(FField, FBuffer);
  with Mem do
  begin
    Size := MemoSize;
    if (MemoSize > 0) then
      if FField.Transliterate then
      begin
      {$IFDEF CLR}
        FDataSet.InternalTranslate(MemoStr, Mem, MemoSize, False);
      {$ELSE}
        FDataSet.InternalTranslate(MemoStr, Memory, MemoSize, False)
      {$ENDIF}
      end
      else
      begin
      {$IFDEF CLR}
        Marshal.Copy(MemoStr, Memory, 0, MemoSize);
      {$ELSE}
        Move(MemoStr^, PChar(Memory)^, MemoSize);
      {$ENDIF}
      end;
    end;
end;

function TCB4BlobStream.Read(var Buffer {$IFDEF CLR}: array of Byte; Offset: Integer{$ENDIF}; Count: Integer): Integer;
begin
  Result := 0;
  if FOpened then
  begin
    if FDataSet.GetBlobState(FField, FBuffer) = bsEmpty then {not cached -> get from table}
      GetFromTable;
    with FDataSet.GetBlobData(FField, FBuffer) do
    begin
      Position := FPosition;
      Result := Read(Buffer, Count);
      FPosition := Position;
    end;
  end;
end;

{$IFNDEF VERK1PLUS}
const
  soBeginning = soFromBeginning;
  soCurrent = soFromCurrent;
  soEnd = soFromEnd;
function TCB4BlobStream.Seek(Offset: Integer; Origin: Word): TCB4StreamSizeType;
{$ELSE}
function TCB4BlobStream.Seek(const Offset: Int64; Origin: TSeekOrigin): TCB4StreamSizeType;
{$ENDIF}
begin
  case Origin of
//    soFromBeginning: FPosition := Offset;
//    soFromCurrent:   Inc(FPosition, Offset);
//    soFromEnd:       FPosition := GetBlobSize + Offset;
    soBeginning: FPosition := Offset;
    soCurrent:   Inc(FPosition, Offset);
    soEnd:       FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;

procedure TCB4BlobStream.Truncate;
begin
  if FOpened then
  begin
    FModified := True;
    FDataSet.SetBlobState(FField, FBuffer, bsModified);
    FDataSet.GetBlobData(FField, FBuffer).Size := 0;
  end;
end;

function TCB4BlobStream.Write(const Buffer{$IFDEF CLR}: array of Byte; Offset: Integer{$ENDIF}; Count: Integer): Integer;
begin
  Result := 0;
  if FOpened then
  begin
    if FDataSet.GetBlobState(FField, FBuffer) = bsEmpty then {not cached -> get from table}
      GetFromTable;

    with FDataSet.GetBlobData(FField, FBuffer) do
    begin
      Position := FPosition;
      Result := Write(Buffer, Count);
      FPosition := Position;
    end;
    FModified := True;
    FDataSet.SetBlobState(FField, FBuffer, bsModified);
  end;
end;

{
********************************** TCB4Table ***********************************
}
constructor TCB4Table.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRecordBuffers := TCB4RecordBufferList.Create(Self);
  //FFieldRecPos := TList.Create;
  SetLength(FFieldRecPos, 0);
  // Init records is not be necessary
  // FRangeStartKey.KeyType := 0;
  // FRangeEndKey.KeyType := 0;

//  FFieldRecType := TList.Create;
  SetLength(FFieldRecType, 0);
  FIndexFields := TCB4FieldList.Create;
  FIndexFiles := TIndexFiles.Create(Self);
  FMasterLink := TMasterDataLink.Create(Self);
  FMasterLink.OnMasterChange := MasterChanged;
  FMasterLink.OnMasterDisable := MasterDisabled;

  BookMarkSize := SizeOf(TCB4RecordNumber);
  FCacheBlobs := True;
  FOptions := [toUseProductionIndex];
  FFirstSequencedPosition := 0;
  FRangeSequencedPosition := 1;
end;

destructor TCB4Table.Destroy;
begin
  inherited Destroy;

  Assert(FCBDATA4 = nil);
  if FCBDATA4 <> nil then d4close(FCBDATA4);

  {Destroy calls close -> and thus will use my fields so free fields after destroy!}
  FreeRangeKeys;

//  FFieldRecPos.Free;
  SetLength(FFieldRecPos, 0);

//  FFieldRecType.Free;
  SetLength(FFieldRecType, 0);
  FIndexFields.Free;
  FIndexFiles.Free;
  FMasterLink.Free;
  FRecordBuffers.Free;
end;

procedure TCB4Table.ActivateFilters;
begin
  if (FFilterEXPR4 <> nil) or Assigned(OnFilterRecord) then
    FFiltersActive := True;
end;

procedure TCB4Table.AllocKeyBuffers;
var
  KeyIndex: TKeyIndex;
begin
  try
    for KeyIndex := Low(TKeyIndex) to High(TKeyIndex) do
      FKeyBuffers[KeyIndex] := InitKeyBuffer(nil, True);
  except
    FreeKeyBuffers;
    raise;
  end;
end;

function TCB4Table.AllocRecordBuffer: TRecordBuffer;
begin
  Assert(FRecordBuffers.RecBufSize>0);
  Result := FRecordBuffers.Add;
end;

procedure TCB4Table.AnalyzeTAG(CBTAG4INFO: PTAG4INFO; var Options:
   TIndexOptions; var Expression, DescFields, CaseInsFields: string);
var
  Desc, All: TCB4FieldList;
  i, j: Integer;
  Expr: string;
  TagInfo: {$IFDEF CLR}TAG4INFO{$ELSE}PTAG4INFO{$ENDIF};

  procedure AddField(var FieldList: string; FieldName: string);
  begin
    if FieldList = '' then
      FieldList := FieldName
    else
      FieldList := FieldList + ';' + FieldName
  end;

begin
  {$IFDEF CLR}
  TagInfo := TAG4INFO(Marshal.PtrToStructure(CBTAG4INFO, TypeOf(TAG4INFO)));
  Expr := Marshal.PtrToStringAnsi(TagInfo.expression);
  {$ELSE}
  TagInfo := CBTAG4INFO;
  Expr := string(CBTAG4INFO^.expression);
  {$ENDIF}
  AnalyzeTagExpression(Expr, Options, Expression, DescFields, CaseInsFields);

  if TagInfo.unique <> 0 then Options := Options + [ixUnique];
  if TagInfo.descending <> 0 then
  begin
    Options := Options + [ixDescending];
    if not (ixExpression in Options) then
    begin
      if DescFields = '' then
        AddField(DescFields, Expression)
      else // remove the descfields from expression and make that the new descfields
      begin
        All := nil;
        Desc := TCB4FieldList.Create;
        try
          All := TCB4FieldList.Create;
          GetFieldList(Desc, DescFields);
          GetFieldList(All, Expression);
          for i := 0 to Desc.Count-1 do
          begin
            j := All.IndexOf(Desc[i]);
            if j <> -1 then
              All.Delete(j)
          end;
          DescFields := '';
          for i := 0 to All.Count-1 do
            AddField(DescFields, TField(All[i]).FieldName);
        finally
          All.Free;
          Desc.Free;
        end;
      end;
    end;
  end;
end;

procedure TCB4Table.AnalyzeTAGExpression(const TagExpression: string; var
   Options:  TIndexOptions; var Expression, DescFields, CaseInsFields: string);
var
  ExpressionString: string;
  AnalyzeFailed: Boolean;
  P: Integer;
  
  procedure AddField(var FieldList: string; FieldName: string);
  begin
    if FieldList = '' then
      FieldList := FieldName
    else
      FieldList := FieldList + ';' + FieldName
  end;
  
  function DeleteWhiteSpace(S: string): string;
  var
    I: Integer;
  begin
    Result := '';
    for I := 1 to Length(S) do
      if not (AnsiChar(S[I]) in [#01..#32]) then
        Result := Result + S[I];
  end;

  function AnalyzeExpressionPart(ExpressionPart: string; IsPart: Boolean): Boolean;
  var
    FieldInfo: {$IFDEF CLR}FIELD4INFO{$ELSE}PFIELD4INFO{$ENDIF};
    KeptFieldInfo{$IFDEF CLR}, CurFieldInfo{$ENDIF}: PFIELD4INFO;
    FieldName: string;
  begin
    ExpressionPart := DeleteWhiteSpace(ExpressionPart);
    Result := True;
    KeptFieldInfo := d4fieldinfo(FCBDATA4);
    {$IFDEF CLR}
    FieldInfo := FIELD4INFO(Marshal.PtrToStructure(KeptFieldInfo, TypeOf(FIELD4INFO)));
    CurFieldInfo := KeptFieldInfo;
    {$ELSE}
    FieldInfo := KeptFieldInfo;
    {$ENDIF}
    try
      while FieldInfo.Name <> nil do
      begin
        {$IFDEF CLR}
        FieldName := Marshal.PtrToStringAnsi(FieldInfo.Name);
        {$ELSE}
        FieldName := FieldInfo.Name;
        {$ENDIF}
        if not IsPart and (CompareText(FieldName, ExpressionPart) = 0) then
        begin
          AddField(Expression, FieldName);
          Exit;
        end;
        if (toRecognizeTagExpressions in FOptions) then
        begin
          if CompareText(Format('ASCEND(%S)', [FieldName]), ExpressionPart) = 0 then
          begin
            AddField(Expression, FieldName);
            Exit;
          end;
          if CompareText(Format('DESCEND(%S)', [FieldName]), ExpressionPart) = 0 then
          begin
            AddField(Expression, FieldName);
            AddField(DescFields, FieldName);
            Exit;
          end;
          case FieldInfo.atype of
            r4str:
              if CompareText(FieldName, ExpressionPart) = 0 then
              begin
                AddField(Expression, FieldName);
                Exit;
              end
              else
              if CompareText(Format('UPPER(%S)', [FieldName]), ExpressionPart) = 0 then
              begin
                AddField(Expression, FieldName);
                AddField(CaseInsFields, FieldName);
                Options := Options + [ixCaseInsensitive];
                Exit;
              end;
            r4unicode:
              if (CompareText(FieldName, ExpressionPart) = 0) or
                 (CompareText(Format('STR(%S)', [FieldName]), ExpressionPart) = 0) then
              begin
                AddField(Expression, FieldName);
                Exit;
              end
              else
              if CompareText(Format('UPPER(STR(%S))', [FieldName]), ExpressionPart) = 0 then
              begin
                AddField(Expression, FieldName);
                AddField(CaseInsFields, FieldName);
                Options := Options + [ixCaseInsensitive];
                Exit;
              end;
            r4num, r4float:
              if CompareText(Format('STR(%S,%d,%d)', [FieldName, FieldInfo.len, FieldInfo.dec]), ExpressionPart) = 0 then
              begin
                AddField(Expression, FieldName);
                Exit;
              end
              else
              if (FieldInfo.dec = 0) and (CompareText(Format('STR(%S,%d)', [FieldName, FieldInfo.len]), ExpressionPart) = 0) then
              begin
                AddField(Expression, FieldName);
                Exit;
              end;
            r4log:
              if CompareText(Format('IIF(%S,''T'',''F'')', [FieldName]), ExpressionPart) = 0 then
              begin
                AddField(Expression, FieldName);
                Exit;
              end;
            r4date:
              if CompareText(Format('DTOS(%S)', [FieldName]), ExpressionPart) = 0 then
              begin
                AddField(Expression, FieldName);
                Exit;
              end;
          end;
        end;
        {$IFDEF CLR}
        CurFieldInfo := IntPtr(CurFieldInfo.ToInt32 + SizeOf(FIELD4INFO));
        FieldInfo := FIELD4INFO(Marshal.PtrToStructure(CurFieldInfo, TypeOf(FIELD4INFO)));
        {$ELSE}
        FieldInfo := Pointer(Integer(FieldInfo) + SizeOf(FIELD4INFO));
        {$ENDIF}
      end;
    finally
      u4free(PVoid(KeptFieldInfo));
    end;
    Result := False;
  end;

begin
  Options := [];
  ExpressionString := TagExpression;
  CaseInsFields := '';
  DescFields := '';
  Expression := '';

  if (toRecognizeTagExpressions in FOptions) and (Pos('+', ExpressionString) <> 0) then
  begin
    AnalyzeFailed := False;
    while not AnalyzeFailed do
    begin
      P := Pos('+', ExpressionString);
      if P <> 0 then
      begin
        AnalyzeFailed := not AnalyzeExpressionPart(Copy(ExpressionString, 1, P-1), True);
        {$IFDEF CLR}Borland.Delphi.{$ENDIF}System.Delete(ExpressionString, 1, P);
      end
      else
      begin
        AnalyzeFailed := not AnalyzeExpressionPart(ExpressionString, True);
        Break;
      end;
    end;
  end
  else
    AnalyzeFailed := not AnalyzeExpressionPart(ExpressionString, False);

  if AnalyzeFailed then
  begin
    Options := [ixExpression];
    Expression := TagExpression;
    CaseInsFields := '';
    DescFields := '';
  end;
end;

procedure TCB4Table.ApplyRange;
begin
  CheckBrowseMode;
  if SetCursorRange then First;
end;

function TCB4Table.BookmarkValid({$IFDEF CLR}const{$ENDIF}Bookmark: TBookmark): Boolean;
var
  RecordNumber: TCB4RecordNumber;
begin
  Result := (FCBDATA4 <> nil) and (Bookmark <> nil);
  if Result then
  begin
  {$IFDEF CLR}
    RecordNumber := Marshal.ReadInt32(Bookmark);
  {$ELSE}
    RecordNumber := PCB4RecordNumber(Bookmark)^;
  {$ENDIF}
    Result := (RecordNumber > 0) and (RecordNumber <= d4recCount(FCBDATA4));
    if Result then
    begin
      CursorPosChanged;
      d4changed(FCBDATA4, 0); {don't save the changed record}
      Result := (d4go(FCBDATA4, RecordNumber) = r4success) and (RecordAllowed = r4success);
    end;
  end;
end;

procedure TCB4Table.Cancel;
begin
  inherited Cancel;
  if State = dsSetKey then
    PostKeyBuffer(False);
end;

procedure TCB4Table.CancelRange;
begin
  CheckBrowseMode;
  UpdateCursorPos;
  if ResetCursorRange then Resync([]);
end;

procedure TCB4Table.Check(aErrorCode: Integer);
begin
  if aErrorCode <> r4success then
  begin
    FRaisedError := aErrorCode;
    DatabaseErrorFmt(SCBError, [error4text(Database.CBCODE4, aErrorCode), aErrorCode]);
  end;
end;

procedure TCB4Table.CheckCBError;
begin
  Check(code4errorCode(Database.CBCODE4, 0));
end;


procedure TCB4Table.CheckMasterRange;
begin
  if FMasterLink.Active and (FMasterLink.Fields.Count > 0) then
  begin
    SetLinkRanges(FMasterLink.Fields);
    SetCursorRange;
  end;
end;

procedure TCB4Table.CheckNeg(aErrorCode: Integer);
begin
  if aErrorCode < 0 then
  begin
    FRaisedError := aErrorCode;
    DatabaseErrorFmt(SCBError, [error4text(Database.CBCODE4, aErrorCode), aErrorCode]);
  end;
end;

procedure TCB4Table.CheckSetKeyMode;
begin
  if State <> dsSetKey then DatabaseError(SNotEditing);
end;

procedure TCB4Table.ClearBlobCache(Buffer: TRecordBuffer);
var
  I: Integer;
  Buf: TCB4RecordBuffer;
begin
  if FCacheBlobs then
  begin
    Buf := FRecordBuffers.Buffers[Buffer];
    for I := 0 to BlobFieldCount - 1 do
      Buf.SetBlobState(I, bsEmpty);
  end;
end;

procedure TCB4Table.ClearCalcFields(Buffer: TRecordBuffer);
var
  Buf: TRecordContents;
begin
  Buf := FRecordBuffers.Buffers[Buffer].RecordContents;
  {$IFDEF CLR}
  System.Array.Clear(Buf, RecordSize, CalcFieldsSize);
  {$ELSE}
  FillChar(Buf[RecordSize], CalcFieldsSize, 0);
  {$ENDIF}
end;

procedure TCB4Table.CloseBlob(Field: TField);
begin
  //  N.I.Y.
end;

procedure TCB4Table.CloseIndexFile(const IndexFileName: string);
var
  IndexName, IndexTag: string;
  CBINDEX4: INDEX4;
begin
  if not Assigned(FCBDATA4) then Exit;
  if State <> dsInactive then
  begin
    GetIndexParams(FIndexName, FFieldsIndex, IndexName, IndexTag);
    if CompareText(IndexName, IndexFileName) = 0 then
      Self.IndexName := '';
  end;
  IndexName :=  GetIndexPath(IndexFileName);
  CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(IndexName));
//  CBINDEX4 := d4index(FCBDATA4, IndexName);
  if CBINDEX4 <> nil then Check(i4close(CBINDEX4));
end;

procedure TCB4Table.CloseTempTable;
begin
  if FCBDATA4 <> nil then Check(d4close(FCBDATA4));
  FCBDATA4 := nil;
end;

function TCB4Table.CompareBookmarks({$IFDEF CLR}const{$ENDIF}Bookmark1, Bookmark2: TBookmark): Integer;
begin
  Result := 1;
  if (Bookmark1 = Bookmark2) then
    Result := 0
  else
    if BookmarkValid(Bookmark1) and BookmarkValid(Bookmark2) then
    begin
      {$IFDEF CLR}
      Result := Marshal.ReadInt32(Bookmark1) - Marshal.ReadInt32(Bookmark2);
      {$ELSE}
      Result := PCB4RecordNumber(Bookmark1)^ - PCB4RecordNumber(Bookmark2)^;
      {$ENDIF}
      if Result < 0 then
        Result := -1
      else
        if Result > 0 then
          Result := 1;
    end;
end;

function TCB4Table.CreateBlobStream(Field: TField; Mode: TBlobStreamMode):
   TStream;
begin
  Result := TCB4BlobStream.Create(Field as TBlobField, Mode);
end;

procedure TCB4Table.CreateExprFilter(const Text: string);
begin
  if Assigned(FFilterEXPR4) then expr4free(FFilterEXPR4);
  if Text <> '' then
  begin
    FFilterEXPR4 := expr4parse(FCBDATA4, TCB4PCharType(Text));
//    FFilterEXPR4 := expr4parse(FCBDATA4, Text);
    if (FFilterEXPR4 = nil) and (Text <> '') then
    begin
      CheckCBError;
      DatabaseErrorFmt(SErrorInFilterExpression, [Text]); // no error found by Check
    end;
  end
  else
    FFilterEXPR4 := nil;
end;

function TCB4Table.CreateStringFilterText(const aFieldName: string;
    aFieldValue: string; aFieldLength: Integer): string;
begin
  Result := InternalCreateStringFilterText(aFieldName, aFieldValue, aFieldLength, False);
end;

function TCB4Table.InternalCreateStringFilterText(const aFieldName: string;
    aFieldValue: string; aFieldLength: Integer; aPartial: Boolean; aIsMemoField: Boolean=False): string;

  function HandleQuotesInFilter(aValue: string): string;
  var
    PS, PD: Integer;
  begin
    // comparing with single and double quotes
    // see http://www.codebase.com/support/kb/?article=C01066
    Result := '';
    PS := Pos('''', aValue);   // '
    while PS > 0 do
    begin
      PD := Pos('"', aValue); // "
      if PD = 0 then
        PD := MaxInt;
      if (PD > PS) then
      begin
        Result := Format('%s+"%s"', [Result, Copy(aValue, 1, PD-1)]);
        {$IFDEF CLR}Borland.Delphi.{$ENDIF}System.Delete(aValue, 1, PD-1);
      end
      else
      begin
        Result := Format('%s+''%s''', [Result, Copy(aValue, 1, PS-1)]);
        {$IFDEF CLR}Borland.Delphi.{$ENDIF}System.Delete(aValue, 1, PS-1);
      end;
      PS := Pos('''', aValue);
    end;
    if (Result = '') and (aValue = '') then
      Result := ''''''
    else
    begin
      if aValue <> '' then
        Result := Format('%s+''%s''', [Result, aValue]);
      {$IFDEF CLR}Borland.Delphi.{$ENDIF}System.Delete(Result, 1, 1); // remove the +
    end;
  end;

var
  L: Integer;
begin
  {$IFDEF NOVFNULLSUPPORT} // reuse define
  if aIsMemoField then DatabaseError('Memofields can not be used in filters!');
  {$ENDIF}
  if aPartial then
  begin
    Result := Format('LEFT(%s,%d)=%s', [aFieldName, Length(aFieldValue), HandleQuotesInFilter(aFieldValue)]);
  end
  else
  begin
    // comparing to empty strings, and partials doesn't work -> comparing filled up with spaces does...
    // see http://www.codebase.com/support/hints/#exactMatch
    // and instead of spaces (which can produce big filters, on codebase 6.5 we can use padr!
    L := Length(aFieldValue);
    if L > aFieldLength then
      aFieldValue := Copy(aFieldValue, 1, aFieldLength);

    aFieldValue := HandleQuotesInFilter(aFieldValue);
    if L < aFieldLength then
    begin
      {$IFDEF NOVFNULLSUPPORT} // reuse define
      aFieldValue := aFieldValue + '+'''+StringOfChar(' ', aFieldLength - L)+'''';
      {$ELSE}
      aFieldValue := Format('PADR(%s,%d)', [aFieldValue, aFieldLength]);
      {$ENDIF}
    end;
    if aIsMemoField then
      Result := Format('PADR(%s,%d)=%s', [aFieldName, aFieldLength, aFieldValue])
    else
      Result := aFieldName+'='+aFieldValue
  end;
end;

{$IFDEF CLR} // works!
function VarToDateTime(Value: Variant): TDateTime;
begin
  Result := Value;
end;
{$ENDIF}

function TCB4Table.CreateLookupFilter(Fields: TList; const Values: Variant;
    Options: TLocateOptions): string;

const
  Bool2Log: array[Boolean] of string = ('.F.', '.T.');
var
  S: string;
  I: Integer;
  V: Variant;
  FieldName, FieldValue: string;
begin
  Result := '';
  for I := 0 to Fields.Count - 1 do
  begin
    if (Fields.Count > 1) or VarIsArray(Values) then
      V := Values[I]
    else
      V := Values;

    if (TField(Fields[I]).DataType = ftWideString) then
      FieldName := 'STR('+TField(Fields[I]).FieldName+')'
    else
      FieldName := TField(Fields[I]).FieldName;

    if (loCaseInsensitive in Options) and (TField(Fields[I]).DataType in [ftString, ftMemo, ftWideString]) then
    begin
      FieldValue := UpperCase(VarToStr(V));
      FieldName := 'UPPER('+FieldName+')';
    end
    else
    begin
      FieldValue := VarToStr(V);
    end;

    if (I = Fields.Count-1) and (loPartialKey in Options) and (TField(Fields[I]).DataType in [ftString, ftMemo, ftWideString]) then
    begin
      if ((TField(Fields[i]) is TStringField) and TStringField(Fields[i]).Transliterate) or
         ((TField(Fields[i]) is TMemoField) and TMemoField(Fields[i]).Transliterate) then
        InternalTranslate(FieldValue, FieldValue, True);
      S := InternalCreateStringFilterText(FieldName, FieldValue, 0{ignored for partial}, True)
    end
    else
    begin
      case TField(Fields[I]).DataType of
        ftString:
        begin
          if (TField(Fields[i]) as TStringField).Transliterate then
            InternalTranslate(FieldValue, FieldValue, True);
          S := InternalCreateStringFilterText(FieldName, FieldValue, FieldLength(TField(Fields[I])), False);
        end;
        ftMemo:
        begin
          if (TField(Fields[i]) as TMemoField).Transliterate then
            InternalTranslate(FieldValue, FieldValue, True);
          S := InternalCreateStringFilterText(FieldName, FieldValue, Database.MemoExprSize, False, True);
        end;
        ftBlob:
          DatabaseError('Can''t use a Blob field in a filter');
        ftWideString:
          DatabaseErrorFmt(SWideStringLocateNotSupported, [FieldName]);  { TODO : Doesn't work for widestrings! }
//          S := InternalCreateStringFilterText(FieldName, FieldValue, Length(FieldValue), False);
        ftBoolean:
          S := Format('%s=%s', [FieldName, Bool2Log[Boolean(V)]]);
        ftDate:
        begin
          if VarIsNull(V) then
            FieldValue := ' '
          else
            FieldValue := FormatDateTime('yyyymmdd', VarToDateTime(V));
          S := Format('DTOS(%s)="%s"', [FieldName, FieldValue]);
        end;
        ftFloat, ftCurrency:
        begin
          if VarIsNull(V) then
            S := Format('%s=0', [FieldName])
          else
            S := Format('%s=%s', [FieldName, TCB4AbstractRecordBuffer.UnlocalizeFloat(FloatToStr(V))]);
        end;
        ftSmallInt, ftInteger:
        begin
          if VarIsNull(V) then
            S := Format('%s=0', [FieldName])
          else
            S := Format('%s=%s', [FieldName, V]);
        end;
        ftDateTime:
        begin
          if VarIsNull(V) then
          begin
            S := Format('%s<DATETIME(0,1,1)', [FieldName]); // code by trial and error
          end
          else
          begin
            FieldValue := FormatDateTime('yyyy,m,d,h,n,s', VarToDateTime(V));
            S := Format('%s>=DATETIME(%s)', [FieldName, FieldValue]);
            // need to compare with >= real time and < 1 second after real time!
            FieldValue := FormatDateTime('yyyy,m,d,h,n,s', VarToDateTime(V)+COneSecond);
            S := S+Format(' .and. %s<DATETIME(%s)', [FieldName, FieldValue]);
          end;
        end
        else
          S := Format('%s=%s', [FieldName, V]);
      end;
    end;
    if I = 0 then
      Result := S
    else
    begin
(*
      if Length(Result)+Length(S)>512 then
      begin
        code4calcCreate(Database.FCBCODE4, expr4parse(FCBDATA4, PChar(Result)), 'CB4Func1');
        Result := 'CB4Func1()';
      end;
*)
      Result := Format('%s .AND. %s', [Result, S]);
    end;
  end;
end;

procedure TCB4Table.CreateTable;
var
{$IFDEF CLR}
  StringBuffer: TDBBufferList;
  FieldInfo: PFIELD4INFO;
  TagInfo: PTAG4INFO;
{$ENDIF}
  FieldDescs: array of FIELD4INFO;
  IndexDescs: array of TAG4INFO;
  CBINDEX4: INDEX4;
  I: Integer;

  procedure InitTableSettings;
  begin
  end;

  procedure InitFieldDescriptors;
  var
    I: Integer;
    {$IFDEF CLR}
    Size: Integer;
    {$ENDIF}
  begin
    InitFieldDefsFromFields;
    SetLength(FieldDescs, FieldDefs.Count+1);
    {$IFDEF CLR}
    Size := Marshal.SizeOf(TypeOf(FIELD4INFO));
    FieldInfo := StringBuffer.AllocHGlobal((FieldDefs.Count+1)*Size);
    {$ENDIF}
    for I := 0 to FieldDefs.Count-1 do
    begin
      with FieldDescs[I] do
      begin
        Len := FieldDefs[I].Size;
        Dec := FieldDefs[I].Precision;
        FieldLogicalToPhysical(FieldDefs[I], aType, Len, Dec);
      {$IFDEF CLR}
        Name := StringBuffer.StringToHGlobalAnsi(FieldDefs[I].Name);
        Marshal.StructureToPtr(FieldDescs[I],IntPtr(FieldInfo.ToInt32+I*Size), False);
      {$ELSE}
        Name := PChar(FieldDefs[I].Name);
      {$ENDIF}
      end;
    end;
    FieldDescs[FieldDefs.Count].Name := nil;
    {$IFDEF CLR}
    Marshal.StructureToPtr(FieldDescs[FieldDefs.Count],IntPtr(FieldInfo.ToInt32+FieldDefs.Count*Size),False);
    {$ENDIF}
  end;

  function GetExpressionPart(aIndexDef: TIndexDef; FieldName: string): string;
  var
//    FieldInfo: PFIELD4INFO;
    I: Integer;
  begin
//    FieldInfo := FieldDescs;
//    while FieldInfo^.Name <> nil do
    for I := 0 to FieldDefs.Count-1 do
    begin
      if CompareText(FieldName, FieldDefs[I].Name) = 0 then
      begin
        case FieldDescs[I].atype of
          r4str:
            if ixCaseInsensitive in aIndexDef.Options then
              Result := Format('UPPER(%S)', [FieldName])
            else
              Result := FieldName;
          r4unicode:
            if ixCaseInsensitive in aIndexDef.Options then
              Result := Format('UPPER(STR(%S))', [FieldName])
            else
              Result := Format('STR(%S)', [FieldName]);
          r4num, r4float:
            Result := Format('STR(%S,%d,%d)', [FieldName, FieldDescs[I].len, FieldDescs[I].dec]);
          r4log:
            Result := Format('IIF(%S,''T'',''F'')', [FieldName]);
          r4date:
            Result := Format('DTOS(%S)', [FieldName]);
        end;
        Break;
      end;
//      FieldInfo := Pointer(Integer(FieldInfo) + SizeOf(FIELD4INFO));

    end;
  end;

  function GetTagExpression(aIndexDef: TIndexDef): string;
  var
    P: Integer;
    S: string;
  begin
    P := Pos(';', aIndexDef.Fields);
    if not (toRecognizeTagExpressions in Options) or (P < 1) then
    begin
      Result := aIndexDef.Fields;
      Exit;
    end;

    Result := '';
    S := aIndexDef.Fields;
    while Length(S) > 0 do
    begin
      Result := Result + ' + ' + GetExpressionPart(aIndexDef, Trim(Copy(S, 1, P-1)));
      {$IFDEF CLR}Borland.Delphi.{$ENDIF}System.Delete(S, 1, P);
      P := Pos(';', S);
      if P = 0 then P := MaxInt;
    end;
    {$IFDEF CLR}Borland.Delphi.{$ENDIF}System.Delete(Result, 1, 3);
  end;

  procedure InitIndexDescriptors(aFilename: string);
  var
    I: Integer;
    Expr: string;
    {$IFDEF CLR}
    Size: Integer;
    {$ENDIF}
  begin
    SetLength(IndexDescs, IndexDefs.Count+1);
    {$IFDEF CLR}
    Size := Marshal.SizeOf(TypeOf(TAG4INFO));
    TagInfo := StringBuffer.AllocHGlobal((IndexDefs.Count+1)*Size);
    {$ENDIF}
    for I := 0 to IndexDefs.Count-1 do
    begin
      if (aFileName = '') then
      begin
        if (IndexDefs[I].Source <> '') and
           (CompareText(JustFileName(IndexDefs[I].Source), JustFileName(TablePath)) <> 0) then
          Continue;
      end
      else
      begin
        if CompareText(JustFileName(IndexDefs[I].Source), JustFileName(aFileName)) <> 0 then
          Continue;
      end;

      with IndexDescs[I] do
      begin
        if ixUnique in IndexDefs[I].Options then
          unique := r4uniqueContinue
        else
          unique := 0;
        if ixDescending in IndexDefs[I].Options then
          descending := r4descending
        else
          descending := 0;
        if ixExpression in IndexDefs[I].Options then
          Expr := IndexDefs[I].Expression
        else
          Expr := GetTagExpression(IndexDefs[I]) + '';
        {$IFDEF CLR}
        Name := StringBuffer.StringToHGlobalAnsi(IndexDefs[I].Name);
        Expression := StringBuffer.StringToHGlobalAnsi(Expr);
        Marshal.StructureToPtr(IndexDescs[I], IntPtr(TagInfo.ToInt32+I*Size), False);
        {$ELSE}
        Name := PChar(IndexDefs[I].Name);
        Expression := PChar(Expr);
        {$ENDIF}
      end;
    end;
    IndexDescs[FieldDefs.Count].Name := nil;
    {$IFDEF CLR}
    Marshal.StructureToPtr(IndexDescs[IndexDefs.Count],IntPtr(TagInfo.ToInt32+IndexDefs.Count*Size),False);
    {$ENDIF}
  end;

begin
  CheckInactive;
  InternalGetDatabase(True);
  if not Database.Connected then Database.Open;

  try
    DeleteTable; {make sure it doesn't exist!}
  except
  end;

  {$IFDEF CLR}
  StringBuffer := TDBBufferList.Create;
  try
  {$ENDIF}
    InitFieldDescriptors;
    if toUseProductionIndex in FOptions then
    begin
      InitIndexDescriptors('');
      {$IFDEF CLR}
      FCBDATA4 := d4create(Database.CBCODE4, TablePath, FieldInfo, TagInfo);
      {$ELSE}
      FCBDATA4 := d4create(Database.CBCODE4, PChar(TablePath), @FieldDescs[0], @IndexDescs[0]);
      {$ENDIF}
    end
    else
    begin
      {$IFDEF CLR}
      FCBDATA4 := d4create(Database.CBCODE4, TablePath, FieldInfo, nil);
      {$ELSE}
      FCBDATA4 := d4create(Database.CBCODE4, PChar(TablePath), @FieldDescs[0], nil);
      {$ENDIF}
    end;
    if FCBDATA4 = nil then CheckCBError;

    for I := 0 to IndexFiles.Count-1 do
    begin
      InitIndexDescriptors(IndexFiles[I]);
      {$IFDEF CLR}
      CBINDEX4 := i4create(FCBDATA4, GetIndexPath(IndexFiles[I]), TagInfo);
      {$ELSE}
      CBINDEX4 := i4create(FCBDATA4, PChar(GetIndexPath(IndexFiles[I])), @IndexDescs[0]);
      {$ENDIF}
      if CBINDEX4 = nil then CheckCBError;
    end;
    Check(d4close(FCBDATA4));
  {$IFDEF CLR}
  finally
    StringBuffer.Free;
  end;
  {$ENDIF}
  FCBDATA4 := nil;
end;

procedure TCB4Table.DataEvent(Event: TDataEvent; Info: TCB4DataEventInfo);
begin
  if (Event = dePropertyChange) and Assigned(IndexDefs) then IndexDefs.Updated := False;
  inherited DataEvent(Event, Info);
end;

procedure TCB4Table.DeactivateFilters;
begin
  FFiltersActive := False;
end;

procedure TCB4Table.DefChanged(Sender: TObject);
begin
  StoreDefs := True;
end;

procedure TCB4Table.DeleteTable;
begin
  CheckInactive;
  OpenTempTable(True);
  try
    d4remove(FCBDATA4);
    FCBDATA4 := nil;
  finally
    CloseTempTable;
  end;
end;

procedure TCB4Table.DoAppend;
begin
  try
    Check(d4append(FCBDATA4));
    // if append succeeded then Current Record is this record: reset position state
    FPositionState := psNormal;
  except
    code4errorCode(Database.CBCODE4, 0); // reset errorcodes
    if not Database.InTransaction then d4unlock(FCBDATA4);
    raise;
  end;
  if not Database.InTransaction then Check(d4unlock(FCBDATA4));
end;

procedure TCB4Table.DoOnNewRecord;
var
  I: Integer;
begin
  if FMasterLink.Active and (FMasterLink.Fields.Count > 0) then
    for I := 0 to FMasterLink.Fields.Count - 1 do
      IndexFields[I] := TField(FMasterLink.Fields[I]);
  inherited DoOnNewRecord;
end;

function TCB4Table.DoRangeSeek(aEndKey: Boolean): Integer;
begin
  case FKeyType of
    r4num:
    begin
      if aEndKey then
        Result := d4seekDouble(FCBDATA4, FRangeEndKey.DoubleKey)
      else
        Result := d4seekDouble(FCBDATA4, FRangeStartKey.DoubleKey)
    end
    else
    begin
      if aEndKey then
        Result := d4seek(FCBDATA4, FRangeEndKey.StringKey)
      else
        Result := d4seek(FCBDATA4, FRangeStartKey.StringKey);
    end
  end;
end;

procedure TCB4Table.DoWrite;
begin
  try
    Check(d4write(FCBDATA4, -1));
  except
    d4changed(FCBDATA4, 0); {don't save the changed record in CB}
    code4errorCode(Database.CBCODE4, 0); // reset errorcodes
    d4refreshRecord(FCBDATA4);
    if (toLockOnPost in FOptions) then  // if failed unlock only if lockonpost
      if not Database.InTransaction then d4unlock(FCBDATA4);
    raise;
  end;
  if not Database.InTransaction then Check(d4unlock(FCBDATA4));
end;

procedure TCB4Table.EditKey;
begin
  SetKeyBuffer(kiLookup, False);
end;

procedure TCB4Table.EditRangeEnd;
begin
  SetKeyBuffer(kiRangeEnd, False);
end;

procedure TCB4Table.EditRangeStart;
begin
  SetKeyBuffer(kiRangeStart, False);
end;

procedure TCB4Table.EmptyTable;
begin
  if Active then
  begin
    CheckBrowseMode;
    Check(d4zap(FCBDATA4, 1, d4recCount(FCBDATA4)));
    Check(d4memoCompress(FCBDATA4));
    ClearBuffers;
    DataEvent(deDataSetChange, TCB4DataEventInfo(0));
    First; // set all internal states good
  end else
  begin
    OpenTempTable(True);
    try
      Check(d4zap(FCBDATA4, 1, d4recCount(FCBDATA4)));
      Check(d4memoCompress(FCBDATA4));
    finally
      CloseTempTable;
    end;
  end;
end;

procedure TCB4Table.ExternalSetToRecord(Buffer: TRecordBuffer);
begin
  if FSavedRecord = -1 then
  begin
    FSavedRecord := d4RecNo(FCBDATA4);
    if FRecordBuffers.Buffers[Buffer].RecordNumber = FSavedRecord then
      FSavedRecord := -1;
  end;

  GotoRecord(FRecordBuffers.Buffers[Buffer].RecordNumber);
end;

function TCB4Table.FastSeek(aValue: Variant): Boolean;
// FastSeek: searches a little faster for a specific value by using d4seek directly
var
  SeekNext: Boolean;
  S: string;
  function VarToFloat(aValue: Variant): Double;
  begin
    Result := aValue;
  end;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;
  SetKeyExpression(0);
  SeekNext := False;
  repeat
    if (FKeyType in SingleKeyTypes) then
      Result := SeekSingleKey(aValue, SeekNext)=r4success
    else
    begin
      case FKeyType of
        r4str:
        begin
          S := VarToStr(aValue);
          if SeekNext then
            Result := d4seekNext(FCBDATA4, TCB4PCharType(s)) = r4success
//            Result := d4seekNext(FCBDATA4, s) = r4success
          else
            Result := d4seek(FCBDATA4, TCB4PCharType(s)) = r4success;
//            Result := d4seek(FCBDATA4, s) = r4success;
        end;
        r4num:
        begin
          if SeekNext then
            Result := d4seekNextDouble(FCBDATA4, VarToFloat(aValue)) = r4success
          else
            Result := d4seekDouble(FCBDATA4, VarToFloat(aValue)) = r4success;
        end;
        else
        begin
          DatabaseErrorFmt(SUnsupportedKeytype, [char(FKeyType)]);
          Result := False; // dummy to get rid of warning
        end;
      end;
    end;
    SeekNext := True;
  until not Result or (RecordAllowed = r4success);

  FSavedRecord := -1;
  if Result then
  begin
    Resync([rmExact, rmCenter]);
    DoAfterScroll;
  end;
end;

function TCB4Table.FieldDefsStored: Boolean;
begin
  Result := StoreDefs and (FieldDefs.Count > 0);
end;

function TCB4Table.FieldLength(Field: TField): Integer;
begin
  if (Field.FieldNo > 0) and (Field.FieldNo < Length(FFieldRecPos)) then
    Result := InternalFieldLength(Field.FieldNo)
  else
    Result := -1;
end;

procedure TCB4Table.FieldLogicalToPhysical(FieldDef: TFieldDef; var atype: 
   SmallInt;   var Len, Dec: word);
  
  const Log2PhysMap: array[ftUnknown..ftTypedBinary] of SmallInt = (
    -1, r4str, r4num, r4num, r4num, r4log, r4float, r4num, r4str, r4date, -1, r4date,
    r4memo, r4memo, r4num, r4memo, r4memo, r4memo, r4memo, r4gen, r4gen, r4gen);

begin
  if FieldDef.DataType <= High(Log2PhysMap) then
    atype := Log2PhysMap[FieldDef.DataType]
  else
    atype := -1;

  case FieldDef.DataType of
    ftSmallint, ftWord:
    begin
      Len := 6;
      Dec := 0;
    end;
    ftInteger, ftAutoInc:
    begin
      Len := 11;
      Dec := 0;
    end;
    ftFloat, ftCurrency:
    begin
      Len := 20;
      Dec := 4;
    end;
    ftFixedChar: atype := r4str;
    ftWideString: atype := r4unicode;
    ftLargeint:
    begin
      atype := r4num;
      Len := 20;
      Dec := 0;
    end;
  end;
end;

function TCB4Table.FindKey(const KeyValues: array of const): Boolean;
begin
  CheckBrowseMode;
  SetKeyFields(kiLookup, KeyValues);
  Result := GotoKey;
end;

procedure TCB4Table.FindNearest(const KeyValues: array of const);
begin
  CheckBrowseMode;
  SetKeyFields(kiLookup, KeyValues);
  GotoNearest;
end;

procedure TCB4Table.FreeKeyBuffers;
var
  KeyIndex: TKeyIndex;
begin
  for KeyIndex := Low(TKeyIndex) to High(TKeyIndex) do
    if Assigned(FKeyBuffers[KeyIndex]) then
    begin
      FreeRecordBuffer(FKeyBuffers[KeyIndex].Data);
      FreeAndNil(FKeyBuffers[KeyIndex]);
      FKeyBuffers[KeyIndex] := nil;
    end;
end;

procedure TCB4Table.FreeRecordBuffer(var Buffer: TRecordBuffer);
begin
  FRecordBuffers.Delete(Buffer);
  Buffer := TRecordBuffer(0);
end;

function TCB4Table.GetActiveRecBuf(var RecBuf: TRecordBuffer): Boolean;
begin
  case State of
    dsBlockRead,
    dsBrowse: if IsEmpty then RecBuf := nil else RecBuf := ActiveBuffer;
    dsEdit, dsInsert: RecBuf := ActiveBuffer;
    dsSetKey: RecBuf := FKeyBuffer.Data;
    dsCalcFields: RecBuf := CalcBuffer;
    dsFilter: RecBuf := FFilterBuffer;
  (*
    dsNewValue: if FInUpdateCallback then
                  RecBuf := FUpdateCBBuf.pNewRecBuf else
                  RecBuf := ActiveBuffer;
    dsOldValue: if FInUpdateCallback then
                  RecBuf := FUpdateCBBuf.pOldRecBuf else
                  RecBuf := GetOldRecord;
  *)
  else
    RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

function TCB4Table.GetBlobState(Field: TField; Buffer: TRecordBuffer):
    TCB4BlobState;
begin
  Result := FRecordBuffers.Buffers[Buffer].BlobData[Field.Offset].State;
end;

procedure TCB4Table.GetBookmarkData(Buffer: TRecordBuffer; {$IFDEF CLR}var Bookmark: TBookmark{$ELSE}Data: Pointer{$ENDIF});
begin
  {$IFDEF CLR}
  Marshal.WriteInt32(Bookmark, FRecordBuffers.Buffers[Buffer].RecordNumber);
  {$ELSE}
  Move(FRecordBuffers.Buffers[Buffer].RecordNumber, Data^, BookmarkSize);
  {$ENDIF}
end;

function TCB4Table.GetBookmarkFlag(Buffer: TRecordBuffer): TBookmarkFlag;
begin
  Result := FRecordBuffers.Buffers[Buffer].BookmarkFlag;
end;

function TCB4Table.GetCanModify: Boolean;
begin
  Result := FCanModify and not ReadOnly;
end;

function TCB4Table.GetCurrentRecord(Buffer: TRecordBuffer{not really a recordbuffer indexer}): Boolean;
{$IFDEF CLR}
var
  P: array of byte;
{$ENDIF}
begin
  if not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then
  begin
    UpdateCursorPos;
    {$IFDEF CLR}
    SetLength(P, FRecordSize);
    Marshal.Copy(d4record(FCBDATA4), P, 0, FRecordSize);
    Marshal.Copy(P, 0, Buffer, FRecordSize);
    {$ELSE}
    Move(d4record(FCBDATA4)^, Buffer^, FRecordSize);
    {$ENDIF}
    Result := True;
  end else
    Result := False;
end;

function TCB4Table.GetDataSource: TDataSource;
begin
  Result := MasterSource;
end;

function TCB4Table.GetExists: Boolean;
var
  S: string;
begin
  Result := Active;
  if Result or (TableName = '') then Exit;
  if IsClientServer then
  try
    OpenTempTable(False);
    try
      Result := FCBDATA4 <> nil;
    finally
      CloseTempTable;
    end;
  except
    Result := False;
  end
  else
  begin
    S := GetTablePath;
    Result := FileExists(S);
    if not Result and (ExtractFileExt(S) = '') then
      Result := FileExists(S+ '.dbf');
  end;
end;

function TCB4Table.GetFieldData(Field: TField; Buffer: TValueBuffer): Boolean;
var
  Buf: TRecordContents;
  I: Integer;
  RecBuffer: TRecordBuffer;
begin
  Result := False;
  if not GetActiveRecBuf(RecBuffer) then Exit;
  with Field do
    if FieldNo > 0 then
    begin
      Result := FRecordBuffers.GetField(RecBuffer, Field, Buffer);
    end
    else
      if State in [dsBrowse, dsEdit, dsInsert, dsCalcFields] then
      begin
        Buf := FRecordBuffers.Buffers[RecBuffer].RecordContents;
        I := FRecordSize + Offset;
        Result := Boolean(Buf[I]);
        if Result and (Buffer <> nil) then
        {$IFDEF CLR}
          Marshal.Copy(Buf, I+1, Buffer, DataSize);
        {$ELSE}
          Move(Buf[I+1], Buffer^, DataSize);
        {$ENDIF}
      end;
end;

function TCB4Table.GetFieldDataRaw(aField: TField; {$IFDEF CLR}var {$ENDIF}aBuffer: TCB4FieldDataRawBuffer; aLength:
   Integer=MaxInt): Boolean;
var
  Buf: TRecordContents;
  I: Integer;
  RecBuffer: TRecordBuffer;
  Len: Integer;
begin
  { TODO : share code with GetFieldData }
  Result := False;
  if not GetActiveRecBuf(RecBuffer) then Exit;
  Buf := FRecordBuffers.Buffers[RecBuffer].RecordContents;
  with aField do
    if FieldNo > 0 then
    begin
      Len := InternalFieldLength(FieldNo);
      if Len > aLength then
        Len := aLength;
      FRecordBuffers.Buffers[RecBuffer].CopyFieldContentToBuffer(FFieldRecPos[FieldNo-1], Len, aBuffer);
//      CopyFieldContentToBuffer(Buf, aField, aBuffer, Len);
//      Move(PChar(Integer(Buf) + Integer(FFieldRecPos[FieldNo-1]))^, aBuffer^, Len);
    end
    else
      if State in [dsBrowse, dsEdit, dsInsert, dsCalcFields] then
      begin
        I := FRecordSize + Offset;
        Result := Boolean(Buf[I]);
        if Result then
        begin
          Len := DataSize;
          if Len > aLength then
            Len := aLength;
        {$IFDEF CLR}
          System.Array.Copy(Buf, I+1, aBuffer, 0, Len);
        {$ELSE}
          Move(Buf[I+1], aBuffer^, Len);
        {$ENDIF}
        end;
      end;
end;

function TCB4Table.GetIndexFieldCount: Integer;
begin
  //RefreshIndexFields;
  Result := FIndexFields.Count;
end;

function TCB4Table.GetIndexFieldNames: string;
begin
  if FFieldsIndex then Result := FIndexName else Result := '';
end;

function TCB4Table.GetIndexFields(Index: Integer): TField;
begin
  if (Index < 0) or (Index >= IndexFieldCount) then
    DatabaseError(SFieldIndexError);
  Result := TField(FIndexFields[Index]);
end;

procedure TCB4Table.GetIndexInfo;
var
  CBTAG4: TAG4;
  Expr: string;
  IndexOptions: TIndexOptions;
  Expression, DescFields, CaseInsFields: string;
begin
  CBTAG4 := d4tagSelected(FCBDATA4);
  if CBTAG4 <> nil then
  begin
    Expr := string(t4expr(CBTAG4));
    AnalyzeTagExpression(string(Expr), IndexOptions, Expression, DescFields, CaseInsFields);

    FExpIndex := ixExpression in IndexOptions;
    if not FExpIndex then
      try
        GetFieldList(FIndexFields, Expression);
      except
        on EDatabaseError do  // not all fields found -> just say it is ExpIndex
        begin
          FExpIndex := True;
          FIndexFields.Clear;
        end;
      end;

    FCaseInsIndex := not FExpIndex and (ixCaseInsensitive in IndexOptions);
    SetKeyExpression(0); // init KeyExpr
    FKeySize := FKeyExprSize;
    if Assigned(FKeyEXPR4) then expr4free(FKeyEXPR4);
    FKeyEXPR4 := FKeyExprEXPR4;
    FKeyExprEXPR4 := nil;
  end;
end;

function TCB4Table.GetIndexName: string;
begin
  if FFieldsIndex then Result := '' else Result := FIndexName;
end;

procedure TCB4Table.GetIndexNames(List: TStrings);
begin
  IndexDefs.Update;
  IndexDefs.GetItemNames(List);
end;

procedure TCB4Table.GetIndexParams(const IndexName: string; FieldsIndex: 
   Boolean; var  IndexedName, IndexTag: string);
var
  IndexStr: string;
  I: Integer;
begin
  IndexedName := '';
  IndexTag := '';
  
  if IndexName <> '' then
  begin
    IndexDefs.Update;
    {UpdateIndexDefs;}
    IndexStr := IndexName;
    if FieldsIndex then
      IndexStr := IndexDefs.FindIndexForFields(IndexName).Name;
    if (UpperCase(ExtractFileExt(IndexStr)) <> '.NDX') then
    begin
      IndexTag := IndexStr;
      with IndexDefs do
      begin
        I := IndexOf(IndexStr);
        if I <> -1 then
          IndexStr := Items[I].Source
        else
          DatabaseErrorFmt(SIndexDoesNotExist, [IndexName]);
        IndexedName := IndexStr;
      end;
    end
    else
      IndexedName := IndexStr;
  end;
end;

function TCB4Table.GetIndexPath(aIndexFile: string): string;
var
  CBINDEX4: INDEX4;
begin
  Result := '';
  if FCBDATA4 <> nil then
  begin
    CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(aIndexFile));
    if CBINDEX4 <> nil then
    begin
      Result := i4fileName(CBINDEX4);
      Exit;
    end;
  end;
  
  if Length(ExtractFilePath(aIndexFile)) = 0 then
  begin
    if Length(Database.IndexPath) = 0 then
      Result := ExtractFilePath(TablePath)
    else
      Result := DelimitDatabasePath(Database.IndexPath);
  end;
  Result := Result + aIndexFile;
end;

function TCB4Table.GetIndexPaths(Index: Integer): string;
begin
  if Index = -1 then
    Result := GetIndexPath('')
  else
    Result := GetIndexPath(IndexFiles[Index]);
end;

function TCB4Table.GetIsIndexField(Field: TField): Boolean;
var
  I: Integer;
begin
  if (State = dsSetKey) and (IndexFieldCount = 0) and FExpIndex then
    Result := True else
  begin
    Result := False;
    with Field do
      if FieldNo > 0 then
        for I := 0 to IndexFieldCount - 1 do
         if IndexFields[I] = Field then
          begin
            Result := True;
            Exit;
          end;
  end;
end;

function TCB4Table.GetKeyBuffer(KeyIndex: TKeyIndex): TKeyBuffer;
begin
  Result := FKeyBuffers[KeyIndex];
end;

function TCB4Table.GetKeyExclusive: Boolean;
begin
  CheckSetKeyMode;
  Result := FKeyBuffer.Exclusive;
end;

function TCB4Table.GetMasterFields: string;
begin
  Result := FMasterLink.FieldNames;
end;

function TCB4Table.GetMasterSource: TDataSource;
begin
  Result := FMasterLink.DataSource;
end;

function TCB4Table.GetRecNo: Integer;
var
  BufPtr: TRecordBuffer;
  I: Integer;
begin
  {seems to be only used by scrollbars if table is sequenced, well and ofcourse by other users...}
  CheckActive;
  if (FIndexName <> '') and (toSequenceIndex in Options) then
  begin
    UpdateCursorPos;
    I := d4reccount(FCBDATA4);
    if FRangeSequencedPosition = 0 then // only one record(?) always set to middle
      Result := I div 2
    else
      Result := Round(((d4position(FCBDATA4) - FFirstSequencedPosition) * I) / FRangeSequencedPosition);
    if Result > I then Result := I;
    if Result < 0 then Result := 0;
  end
  else
  begin
    if State = dsCalcFields then
      BufPtr := CalcBuffer else
      BufPtr := ActiveBuffer;
    Result := FRecordBuffers.Buffers[BufPtr].RecordNumber;
  end;

  if (toSequenceIndex in Options) then
  begin
    if EOF then Result := d4reccount(FCBDATA4);
    if BOF then Result := 0;
  end;
end;

function TCB4Table.GetRecord(Buffer: TRecordBuffer; GetMode: TGetMode; DoCheck:
    Boolean): TGetResult;
var
  Err: Integer;

  function FindNext: Integer;
  begin
    repeat
      Result := d4skip(FCBDATA4, 1);
      if Result = r4success then
      begin
        Result := RecordAllowed;
        if Result in [r4success, r4eof] then Break;
      end
      else
        Break;
    until False
  end;
  
  function FindPrior: Integer;
  begin
    repeat
      Result := d4skip(FCBDATA4, -1);
      if Result = r4success then
      begin
        Result := RecordAllowed;
        if Result in [r4success, r4bof] then Break;
      end
      else
        Break;
    until False
  end;

begin
  if FPositionState in [psBeforeFirst, psAfterLast] then
  begin
    FEmptyRecord := 0;
    if FPositionState = psBeforeFirst then
    begin
    { TODO : Implement ranges on currency etc (SingleKeyTypes)}
      if FRangeActive and (FRangeStartKey.KeyType <> 0) then
      begin
        Err := DoRangeSeek(False);
        if (Err = r4after) then
          Err := r4success {after 'precise' hit is also first}
        else
        begin
          if (Err = r4success) and (FKeyBuffers[kiRangeStart].Exclusive) then
            Err := FindNext;
        end;
      end
      else
        Err := d4top(FCBDATA4);
      if (Err = r4success) and not (RecordAllowed = r4success) then
        Err := FindNext;
    end
    else
    begin // psAfterLast
      if FRangeActive then
      begin
        if FRangeEndKey.KeyType<>0 then
        begin
          Err := DoRangeSeek(True);
          if not FKeyBuffers[kiRangeEnd].Exclusive then
            while Err = r4success do {direct hit -> possibly more that fit}
              Err := FindNext;
          if (Err = r4after) or (Err = r4EOF) or
             ((Err = r4success) and (FKeyBuffers[kiRangeEnd].Exclusive)) then
            Err := FindPrior;
        end
        else
          Err := r4EOF;
      end
      else
        Err := d4bottom(FCBDATA4);
      if (Err = r4success) and not (RecordAllowed = r4success) then
        Err := FindPrior;
    end;
    FPositionState := psNormal;
  end
  else
  begin
    if FEmptyRecord > 0 then d4go(FCBDATA4, FEmptyRecord);
    if FSavedRecord > 0 then d4go(FCBDATA4, FSavedRecord);
    case GetMode of
      gmNext:
        Err := FindNext;
      gmPrior:
        Err := FindPrior;
    else
      begin
        if (RecordAllowed = r4success) then
          Err := r4success
        else
          Err := r4after; {abuse r4after to generate grError}
      end
    end;
  end;
  
  FEmptyRecord := 0;
  FSavedRecord := -1;
  
  case Err of
    r4success:
      begin
        Result := grOK;
        if (GetMode = gmCurrent) then
        begin
          if d4bof(FCBDATA4) <> 0 then
          begin
            Result := grBOF;
          end
          else
          if d4eof(FCBDATA4) <> 0 then
          begin
            Result := grEOF;
          end
        end;
        if Result = grOK then
        begin
          CopyRecordToRecordBuffer(Buffer);
//          Rec := d4record(FCBDATA4);
//          Move(Rec^, Buf^, FRecordSize);
//          FRecordBuffers.Buffers[Buffer].UpdateStatus := usUnmodified;
          FRecordBuffers.Buffers[Buffer].RecordNumber := d4RecNo(FCBDATA4);
          FRecordBuffers.Buffers[Buffer].BookmarkFlag := bfCurrent;

          ClearBlobCache(Buffer);
          GetCalcFields(Buffer);
        end;
      end;
    r4bof: Result := grBOF;
    r4eof: Result := grEOF;
  else
    Result := grError;
    if DoCheck and (Err <> r4after) then Check(Err);
  end;
end;

function TCB4Table.GetRecordCount: Integer;
begin
  {seems to be only used by scrollbars if table is sequenced}
  CheckActive;
  Result := d4reccount(FCBDATA4);
end;

function TCB4Table.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

function TCB4Table.GetTablePath: string;
begin
  if Active then
    Result := d4fileName(FCBDATA4)
  else
  begin
    if Length(ExtractFilePath(TableName)) = 0 then
      Result := DelimitDatabasePath(Database.TablePath) + TableName
    else
      Result := TableName;
  end;
end;

procedure TCB4Table.GotoCurrent(Table: TCB4Table);
begin
  CheckBrowseMode;
  Table.CheckBrowseMode;
  if (Database <> Table.Database) or
    (CompareText(TableName, Table.TableName) <> 0) then
    DatabaseError(STableMismatch);
  Table.UpdateCursorPos;
  
  InternalGotoBookmark(Table.GetBookmark);
  
  DoBeforeScroll;
  Resync([rmExact, rmCenter]);
  DoAfterScroll;
end;

function TCB4Table.GotoKey: Boolean;
var
  SaveState: TDataSetState;
  KeyBuffer: TKeyBuffer;
  I: Integer;
  IndexValues: Variant;
  TempFilter: string;
  TempEXPR4: EXPR4;
begin
  CheckBrowseMode;
  DoBeforeScroll;
  CursorPosChanged;

  KeyBuffer := GetKeyBuffer(kiLookup);
  SetKeyExpression(KeyBuffer.FieldCount);
  if (FKeyType in SingleKeyTypes) then
  begin
    if IndexFieldCount<>1 then
      DatabaseError(SOnlySearchingOnSingleKeySupport);
    SaveState := SetTempState(dsSetKey);  // get our key fields
    try
      IndexValues := IndexFields[0].Value;
    finally
      RestoreState(SaveState);
    end;
    Result := SeekSingleKey(IndexValues, False)=r4success; // use the first index field which is set by setkeyfields
  end
  else
    Result := SeekKeyExpression(KeyBuffer) = r4success;

  if Result and not (RecordAllowed = r4success) then
  begin // we probably have a filter that excludes this record -> search again
    SaveState := SetTempState(dsSetKey);  // get our key fields
    try
      if IndexFieldCount = 1 then
        IndexValues := IndexFields[0].AsVariant
      else
      begin
        IndexValues := VarArrayCreate([0, FIndexFields.Count-1], {$IFDEF CLR}varObject{$ELSE}varVariant{$ENDIF});
        for I := 0 to IndexFieldCount-1 do
          IndexValues[I] := IndexFields[I].AsVariant;
      end;
    finally
      RestoreState(SaveState);
    end;

    {Create Filter to check lookup question}
    TempFilter := CreateLookupFilter(FIndexFields, IndexValues, []);
    TempEXPR4 := expr4parse(FCBDATA4, TCB4PCharType(TempFilter));
    if TempEXPR4 <> nil then
    try
      SaveState := SetTempState(dsFilter);
      try
        repeat
          Result := d4skip(FCBDATA4, 1) = r4success;
          Result := Result and (expr4true(TempEXPR4) > 0);
        until not Result or (RecordAllowed = r4success);
      finally
        RestoreState(SaveState);
      end;
    finally
      expr4free(TempEXPR4);
    end
    else
      Result := False;
  end;

  FSavedRecord := -1;
  if Result then
  begin
    Resync([rmExact, rmCenter]);
    DoAfterScroll;
  end;
end;

procedure TCB4Table.GotoNearest;
var
  Err: Integer;
  KeyBuffer: TKeyBuffer;
begin
  CheckBrowseMode;
  CursorPosChanged;
  
  KeyBuffer := GetKeyBuffer(kiLookup);
  SetKeyExpression(KeyBuffer.FieldCount);
  Err := SeekKeyExpression(KeyBuffer);
  FSavedRecord := -1;
  
  if ((KeyBuffer.Exclusive) and (Err = r4success)) or not (RecordAllowed = r4success) then
   Next;
  
  Resync([rmCenter]);
end;

procedure TCB4Table.GotoRecord(aRecordNumber: TCB4RecordNumber);
begin
  if aRecordNumber > 0 then
  begin
    if FEmptyRecord > 0 then FEmptyRecord := 0;
    d4changed(FCBDATA4, 0); {don't save the changed record}
    Check(d4go(FCBDATA4, aRecordNumber))
  end
  else
  begin
    if FEmptyRecord = 0 then FEmptyRecord := d4RecNo(FCBDATA4);
    d4changed(FCBDATA4, 0); {don't save the changed record}
    Check(d4appendStart(FCBDATA4, 0));
  end;
end;

function TCB4Table.IndexDefsStored: Boolean;
begin
  Result := StoreDefs and (IndexDefs.Count > 0);
end;

procedure TCB4Table.InitBufferPointers(GetProps: Boolean);
begin
  if GetProps then
    FRecordSize := d4RecWidth(FCBDATA4);

  FRecordBuffers.RecBufSize := FRecordSize + CalcFieldsSize;
end;

procedure TCB4Table.InitFieldDefs;
begin
  // TODO: why is this function overriden?
  InternalInitFieldDefs;
end;

function TCB4Table.InitKeyBuffer(Buffer: TKeyBuffer; aAllocate: Boolean):
    TKeyBuffer;
begin
  if aAllocate then
  begin
    Result := TKeyBuffer.Create;
    Result.Data := AllocRecordBuffer; // Could be FRecordsize big
    // ->   AllocMem(SizeOf(TKeyBuffer) + FRecordSize)
  end
  else
    Result := Buffer;
  Result.Modified := False;
  Result.Exclusive := False;
  Result.FieldCount := 0;
  {$IFDEF CLR}
  FRecordBuffers.Buffers[Result.Data].FillRecordContents(0, FRecordSize, 32);
  {$ELSE}
  FillChar(FRecordBuffers.Buffers[Result.Data].RecordContents^, FRecordSize, ' ');
  {$ENDIF}
end;

procedure TCB4Table.InitRecord(Buffer: TRecordBuffer);
begin
  inherited InitRecord(Buffer);
  ClearBlobCache(Buffer);
//  FRecordBuffers.Buffers[Buffer].UpdateStatus := TUpdateStatus(usInserted);
  FRecordBuffers.Buffers[Buffer].RecordNumber := -1;
  FRecordBuffers.Buffers[Buffer].BookmarkFlag := bfInserted;
end;

procedure TCB4Table.InternalAddRecord(Buffer: {$IFDEF CLR}TRecordBuffer{$ELSE}Pointer{$ENDIF}; Append: Boolean);
begin
  Check(d4appendStart(FCBDATA4, 0));
  CopyRecordBufferToRecord(TRecordBuffer(Buffer));
  DoAppend;
end;

procedure TCB4Table.InternalCancel;
begin
  if not (toLockOnPost in FOptions) then
    if not Database.InTransaction then Check(d4unlock(FCBDATA4));
end;

procedure TCB4Table.InternalClose;
var
  I: Integer;
begin
  if FRangeActive then
    ResetCursorRange;
  FreeKeyBuffers;
  FreeRecordBuffer(FFilterBuffer);
  if Assigned(FKeyEXPR4) then expr4free(FKeyEXPR4);
  FKeyEXPR4 := nil;
  if Assigned(FKeyExprEXPR4) then expr4free(FKeyExprEXPR4);
  FKeyExprEXPR4 := nil;
  if Assigned(FFilterEXPR4) then expr4free(FFilterEXPR4);
  FFilterEXPR4 := nil;

  BindFields(False);
  if DefaultFields then DestroyFields;

  FKeySize := 0;
  FExpIndex := False;
  FCaseInsIndex := False;

  FCanModify := False;
  {@ cancel record???}

  for I := 0 to IndexFiles.Count - 1 do
  try
    CloseIndexFile(IndexFiles[I]);
  except
   {ignore errors}
  end;
  FIndexFields.Clear;

  if FCBDATA4 <> nil then Check(d4close(FCBDATA4));
  FRecordBuffers.RecBufSize := 0;
  FCBDATA4 := nil;
end;

procedure TCB4Table.InternalDelete;
begin
  d4delete(FCBDATA4);
  DoWrite;
end;

procedure TCB4Table.InternalEdit;
begin
  CopyRecordToRecordBuffer(ActiveBuffer);
  ClearBlobCache(ActiveBuffer);
  
  if not (toLockOnPost in FOptions) then
    Check(d4lock(FCBDATA4, d4recNo(FCBDATA4)));
end;

function TCB4Table.InternalFieldLength(FieldNo: Integer): Integer;
begin
  Result := Integer(FFieldRecPos[FieldNo]) - Integer(FFieldRecPos[FieldNo-1]);
end;

procedure TCB4Table.InternalFirst;
begin
  FPositionState := psBeforeFirst;
end;

procedure TCB4Table.InternalGotoBookmark({$IFDEF CLR}const {$ENDIF}Bookmark: TBookmark);
begin
  FSavedRecord := -1;
  {$IFDEF CLR}
  GotoRecord(Marshal.ReadInt32(Bookmark));
  {$ELSE}
  GotoRecord(PCB4RecordNumber(Bookmark)^);
  {$ENDIF}
end;

procedure TCB4Table.InternalInitFieldDefs;
var
  FieldInfo: {$IFDEF CLR}FIELD4INFO{$ELSE}PFIELD4INFO{$ENDIF};
  KeptFieldInfo{$IFDEF CLR}, CurFieldInfo{$ENDIF}: PFIELD4INFO;
  FieldName: string;
  DataType: TFieldType;
  Len: Integer;
  RecPos: Integer;
  NeededToOpen: Boolean;
  NumFields: Integer;
begin
  FieldDefs.Clear;

  NeededToOpen := not Assigned(FCBDATA4);
  if NeededToOpen then
    OpenTempTable(False);
  try
    NumFields := d4numFields(FCBDATA4);
    SetLength(FFieldRecType, NumFields);
    SetLength(FFieldRecPos, NumFields+1); // +1 for pos of end of fields

    RecPos := 1; // pos 0 is 'deleted' flag
    KeptFieldInfo := d4fieldinfo(FCBDATA4);
    {$IFDEF CLR}
    FieldInfo := FIELD4INFO(Marshal.PtrToStructure(KeptFieldInfo, TypeOf(FIELD4INFO)));
    CurFieldInfo := KeptFieldInfo;
    {$ELSE}
    FieldInfo := KeptFieldInfo;
    {$ENDIF}
    try
      while FieldInfo.Name <> nil do
      begin
        DataType := ftUnknown;
        Len := FieldInfo.len;

        FFieldRecPos[FieldDefs.Count] := RecPos;
        FFieldRecType[FieldDefs.Count] := Byte(FieldInfo.atype);

        Inc(RecPos, Len);

        case FieldInfo.atype of
          r4bin{, r4double}: { binary field }
          begin
            if (Database.DatabaseType = dtCB4FoxPro) then
            begin
              DataType := ftFloat;
              Len := 0;
            end
            else
            begin
              DataType := ftTypedBinary;
              Len := 1;
            end;
          end;
          r4str: { character field }
            DataType := ftString;
          r4date: { date field }
          begin
            DataType := ftDate;
            Len := 0;
          end;
          r4float: { Floating Point field }
          begin
            DataType := ftFloat;
            Len := 0;
          end;
          r4num: { Numeric or Floating Point field }
          begin
            if (Len < 5) and (FieldInfo.dec = 0) then
              DataType := ftSmallInt
            else
              DataType := ftFloat;
            Len := 0;
          end;
          r4gen: { General field }
          begin
            DataType := ftDBaseOle;
            Len := 1;
          end;
          r4int: { VF Integer field }
          begin
            DataType := ftInteger;
            Len := 0;
          end;
          r4log: { Logical field }
          begin
            DataType := ftBoolean;
            Len := 0;
          end;
          r4datetime: { VF DateTime field }
          begin
            DataType := ftDateTime;
            Len := 0;
          end;
          r4memo: { Memo field }
          begin
            DataType := ftMemo;
            Len := 1;
          end;
          r4memoBin: { VF Memo Bin field }
          begin
            DataType := ftBlob;
            Len := 1;
          end;
          r4currency:  { (VF) Currency field }
          begin
            DataType := ftCurrency;
            Len := 0;
          end;
          r4dateDoub: { A date is formatted as a C double }
            DataType := ftUnknown;
          r4numDoub: { A numeric value is formatted as a C double }
            DataType := ftUnknown;
          r4unicode:
            DataType := ftWideString;
        end;
        {$IFDEF CLR}
        FieldName := Marshal.PtrToStringAnsi(FieldInfo.Name);
        {$ELSE}
        FieldName := FieldInfo.Name;
        {$ENDIF}
        FieldDefs.Add(FieldName, DataType, Len, False);
        if DataType = ftFloat then
        begin
          FieldDefs[FieldDefs.Count-1].Precision := FieldInfo.dec;
        end;
        {$IFDEF CLR}
        CurFieldInfo := IntPtr(CurFieldInfo.ToInt32 + SizeOf(FIELD4INFO));
        FieldInfo := FIELD4INFO(Marshal.PtrToStructure(CurFieldInfo, TypeOf(FIELD4INFO)));
        {$ELSE}
        FieldInfo := Pointer(Integer(FieldInfo) + SizeOf(FIELD4INFO));
        {$ENDIF}
      end;
      FFieldRecPos[FieldDefs.Count] := RecPos; // add one extra RecPos to be able to calc lengths
    finally
      u4free(PVoid(KeptFieldInfo));
    end;
  finally
    if NeededToOpen then
      CloseTempTable;
  end;
end;

procedure TCB4Table.InternalInitRecord(Buffer: TRecordBuffer);
var
  Buf: TRecordContents;
  I: Integer;

  {$IFNDEF NOVFNULLSUPPORT}
  var
    F4: FIELD4;
    Err: Integer;
    DoNullFields: Boolean;
  {$ENDIF}

begin
  {$IFNDEF NOVFNULLSUPPORT}
  DoNullFields := False;
  {$ENDIF}
  Buf := FRecordBuffers.Buffers[Buffer].RecordContents;
  {$IFDEF CLR}
  FRecordBuffers.Buffers[Buffer].FillRecordContents(0, FRecordSize, 32);
  {$ELSE}
  FillChar(Buf^, FRecordSize, ' ');
  {$ENDIF}
  if (Database.DatabaseType = dtCB4FoxPro) then
  begin
    // clear unicode fields
    for I := 0 to FieldCount-1 do
      if (Fields[I].FieldNo > 0) and (FFieldRecType[Fields[I].FieldNo-1] = r4unicode) then
      begin
        {$IFDEF CLR}
        System.Array.Clear(Buf, FFieldRecPos[Fields[I].FieldNo-1], InternalFieldLength(Fields[I].FieldNo));
        {$ELSE}
        FillChar(PChar(Integer(Buf) + Integer(FFieldRecPos[Fields[I].FieldNo-1]))^, InternalFieldLength(Fields[I].FieldNo), #0)
        {$ENDIF}
      end
      {$IFNDEF NOVFNULLSUPPORT}
      else
      if (Fields[I].FieldNo > 0) and (FFieldRecType[Fields[I].FieldNo-1] in VFNFields) then
        DoNullFields := True;
      {$ENDIF};

    {$IFNDEF NOVFNULLSUPPORT}
    if DoNullFields then
    {$ENDIF};
    begin
      CopyRecordBufferToRecord(Buffer); // move RecBuf to CB
      try
        {$IFDEF NOVFNULLSUPPORT}
        d4blank(FCBDATA4); // -> doesn't blank VF fields
        {$ELSE}
        for I := 0 to FieldCount-1 do
          if (Fields[I].FieldNo > 0) and (FFieldRecType[Fields[I].FieldNo-1] in VFNFields) then
          begin
            F4 := d4fieldJ(FCBDATA4, Fields[I].FieldNo);
            f4assignNull(F4); // to let it set null
            Err := code4errorCode(Database.CBCODE4, 0);
            if Err = e4parm then
            begin
              f4blank(F4);
              Err := code4errorCode(Database.CBCODE4, 0);
            end;
            Check(Err);
          end;
        {$ENDIF}
      finally
        CopyRecordToRecordBuffer(Buffer); // move CB back to RecBuf
        d4changed(FCBDATA4, 0); {don't save the changed record in CB}
      end;
    end;

  end;
end;

procedure TCB4Table.InternalLast;
begin
  FPositionState := psAfterLast;
end;

procedure TCB4Table.InternalOpen;
var
  IndexName, IndexTag, FileName: string;
  I: Integer;

  {$IFNDEF LINUX}
  var
    Attribs: Integer;
  {$ENDIF}
  
begin
  {$IFDEF TRIAL}
  if not IsIDERunning1 then
    raise EDatabaseError.CreateFmt(STrial, [SIDEName]);
  {$ENDIF}

  Assert(FCBDATA4 = nil, 'Open called on an open table');

  InternalGetDatabase(True);
  if not Database.Connected then Database.Open;
  code4accessMode(Database.CBCODE4, ShareModes[FExclusive]);
  code4autoOpen(Database.CBCODE4, Ord(toUseProductionIndex in FOptions));
  code4readOnly(Database.CBCODE4, Ord(FReadOnly));
  FCBDATA4 := d4open(Database.CBCODE4, TCB4PCharType(TablePath));
  {back to default:}
  code4accessMode(Database.CBCODE4, ShareModes[False]);
  code4autoOpen(Database.CBCODE4, 1);
  code4readOnly(Database.CBCODE4, 0);
  if FCBDATA4 = nil then CheckCBError;

  FRecordSize := d4RecWidth(FCBDATA4);

  if IsClientServer then
    FCanModify := True // assume we can...
  else
  begin
  {$IFDEF LINUX}
    FCanModify := euidaccess(d4fileName(FCBDATA4), W_OK) = 0;
  {$ELSE}

    {$IFDEF VERK1PLUS}
    {$WARN SYMBOL_PLATFORM OFF}
    {$ENDIF}
    FileName := d4fileName(FCBDATA4);
    Attribs := FileGetAttr(FileName);
    FCanModify := (Attribs <> -1) and ((Attribs and (SysUtils.faReadOnly or faSysFile)) = 0);
    {$IFDEF VERK1PLUS}
    {$WARN SYMBOL_PLATFORM ON}
    {$ENDIF}

  {$ENDIF}
  end;

  FieldDefs.Updated := False;
  FieldDefs.Update;

  if DefaultFields then CreateFields;
  BindFields(True);

  InitBufferPointers(False);
  AllocKeyBuffers;

  for I := 0 to IndexFiles.Count - 1 do
    OpenIndexFile(IndexFiles[I]);
  FIndexDefs.Updated := False;

  GetIndexParams(FIndexName, FFieldsIndex, IndexName, IndexTag);
  SwitchToIndex(IndexName, IndexTag);
  CheckMasterRange;

  FFilterBuffer := AllocRecordBuffer; // Maybe could be FRecordsize big?

  if Filter <> '' then CreateExprFilter(Filter);
  if Filtered then ActivateFilters;

  InternalFirst;
end;

procedure TCB4Table.InternalPost;

  procedure HandleBlobFieldChanges;
  var
    I: Integer;
 {$IFDEF CLR}
     IP: IntPtr;
 {$ENDIF}
  begin
    for I := 0 to FieldCount-1 do
    begin
      if (Fields[I] is TBlobField) and (Fields[I].FieldKind = fkData) then
      begin
        if GetBlobState(Fields[I], ActiveBuffer) = bsModified then
        begin
          with GetBlobData(Fields[I], ActiveBuffer) do
          begin
            {$IFDEF CLR}
            with TDBBufferList.Create do
            try
              IP := AllocHGlobal(Size);
              try
                Marshal.Copy(Memory, 0, IP, Size);
                if TBlobField(Fields[I]).Transliterate and not (toNoCharacterTranslation in Options) then
                  TranslateOnIntPtr(IP, IP, Size, True);
                Check(f4memoAssignN(d4fieldJ(FCBDATA4, Fields[I].FieldNo), IP, Size));
              finally
                FreeHGlobal(IP);
              end;
            finally
              Free;
            end;
            {$ELSE}
            if TBlobField(Fields[I]).Transliterate then
              InternalTranslate(PChar(Memory), PChar(Memory), Size, True);
            Check(f4memoAssignN(d4fieldJ(FCBDATA4, Fields[I].FieldNo), Memory, Size));
            {$ENDIF}
          end;
        end;
        FRecordBuffers.Buffers[ActiveBuffer].SetBlobState(Fields[i].Offset, bsEmpty);
      end;
    end;
  end;

begin
  {$IFDEF VERK1PLUS}
  inherited;
  {$ENDIF}

  if State = dsEdit then
  begin
    CopyRecordBufferToRecord(ActiveBuffer);
    HandleBlobFieldChanges;
    d4changed(FCBDATA4, 1);
    DoWrite;
  end
  else
  begin
    Check(d4appendStart(FCBDATA4, 0));
    CopyRecordBufferToRecord(ActiveBuffer);
    HandleBlobFieldChanges;
    DoAppend;
  end;
end;
                              
procedure TCB4Table.InternalRefresh;
begin
  d4Refresh(FCBDATA4);
  d4RefreshRecord(FCBDATA4);
end;

procedure TCB4Table.InternalSetToRecord(Buffer: TRecordBuffer);
begin
  // implementation identical to InternalGotoBookmark!
  FSavedRecord := -1;
  GotoRecord(FRecordBuffers.Buffers[Buffer].RecordNumber);
end;

function TCB4Table.IsCursorOpen: Boolean;
begin
  Result := FCBDATA4 <> nil;
end;

function TCB4Table.IsSequenced: Boolean;
begin
  if toSequenceIndex in Options then
    Result := True
  else
    Result := (FIndexName = '') and (not Filtered);
end;

function TCB4Table.Locate(const KeyFields: string; const KeyValues: Variant; 
   Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := LocateRecord(KeyFields, KeyValues, Options, True);
  if Result then
  begin
    Resync([rmExact, rmCenter]);
    DoAfterScroll;
  end;
end;

procedure TCB4Table.CopyKeyBuffer(aSource, aDestination: TKeyBuffer);
begin
  aDestination.Modified := aSource.Modified;
  aDestination.Exclusive := aSource.Exclusive;
  aDestination.FieldCount := aSource.FieldCount;
  FRecordBuffers.CopyRecordContents(FRecordBuffers.Buffers[aSource.Data], FRecordBuffers.Buffers[aDestination.Data]);
end;

procedure TCB4Table.CopyRecordToRecordBuffer(Buffer: TRecordBuffer);
begin
  {$IFDEF CLR}
  Marshal.Copy(d4record(FCBDATA4), FRecordBuffers.Buffers[Buffer].RecordContents, 0, FRecordSize);
  {$ELSE}
  Move(d4record(FCBDATA4)^, FRecordBuffers.Buffers[Buffer].RecordContents^, FRecordSize);
  {$ENDIF}
end;

procedure TCB4Table.CopyRecordBufferToRecord(Buffer: TRecordBuffer);
begin
  {$IFDEF CLR}
  Marshal.Copy(FRecordBuffers.Buffers[Buffer].RecordContents, 0, d4record(FCBDATA4), FRecordSize);
  {$ELSE}
  Move(FRecordBuffers.Buffers[Buffer].RecordContents^, d4record(FCBDATA4)^, FRecordSize);
  {$ENDIF}
end;

function TCB4Table.KeyBuffersEqual(aBuffer1, aBuffer2: TKeyBuffer): Boolean;
begin
  Result := (aBuffer2.Modified = aBuffer1.Modified) and (aBuffer2.Exclusive = aBuffer1.Exclusive) and
    (aBuffer2.FieldCount = aBuffer1.FieldCount);
  Result := Result and FRecordBuffers.Buffers[aBuffer1.Data].ContentsEqual(FRecordBuffers.Buffers[aBuffer2.Data]
            {$IFNDEF CLR}, FRecordBuffers.RecBufSize{$ENDIF})
end;

function TCB4Table.LocateRecord(const KeyFields: string;  const KeyValues:
   Variant; Options: TLocateOptions;  SyncCursor: Boolean): Boolean;
var
  Buf: TRecordContents;
  Fields: TCB4FieldList;
  Buffer: TRecordBuffer;
  UseKey: Boolean;
  I: Integer;
  KeyIndex: TIndexDef;
  CurrentRecNo: Integer;
  CurrentTAG4: TAG4;
  IndexName: string;
  IndexTag: string;
  CBINDEX4: INDEX4;
  CBTAG4: TAG4;
  Err: Integer;
  KeyBuf: TKeyBuffer;
  TempFilter: string;
  SavedPositionState: TCB4PositionState;
  TempEXPR4: EXPR4;
begin
  CheckBrowseMode;
  CursorPosChanged;
  Buffer := TempBuffer;
  Fields := TCB4FieldList.Create;
  try
    GetFieldList(Fields, KeyFields);

    KeyIndex := nil;
    if MapsToIndex(Fields, loCaseInsensitive in Options) then
      UseKey := True
    else
    begin
      { TODO : GetIndexForFields doesn't seem to work for descending indices -> look into possibilities }
      KeyIndex := IndexDefs.GetIndexForFields(KeyFields, loCaseInsensitive in Options);
      UseKey := KeyIndex <> nil;
    end;

    CurrentRecNo := d4recno(FCBDATA4); {save position}
    if UseKey then
    begin
      SetTempState(dsFilter);
//      FFilterBuffer := Buffer;
      try
        InternalInitRecord(FFilterBuffer);
        if Fields.Count = 1 then
        begin
          if VarIsArray(KeyValues) then
            TField(Fields.First).Value := KeyValues[0] else
            TField(Fields.First).Value := KeyValues;
        end else
          for I := 0 to Fields.Count - 1 do
            TField(Fields[I]).Value := KeyValues[I];

        if KeyIndex <> nil then
        begin
          CurrentTAG4 := d4tagSelected(FCBDATA4);
          GetIndexParams(KeyIndex.Name, False, IndexName, IndexTag);
          if (IndexName <> '') and (IndexTag <> '') then
          begin
            CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(GetIndexPath(IndexName)));
            if CBINDEX4 = nil then CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(IndexName));
            if CBINDEX4 = nil then CheckCBError;

            CBTAG4 := i4tag(CBINDEX4, TCB4PCharType(IndexTag));
            if CBTAG4 = nil then CheckCBError;
            Result := d4tagSelect(FCBDATA4, CBTAG4) >= 0;
          end
          else
            Result := d4tagSelect(FCBDATA4, nil) >= 0 ;
        end
        else
        begin
          Result := True;
          CurrentTAG4 := nil; // remove warning
        end;


        if Result then
        begin
          SetKeyExpression(Fields.Count);

          KeyBuf := InitKeyBuffer(nil, True);
          try
            Buf := FRecordBuffers.Buffers[FFilterBuffer].RecordContents;
            {$IFDEF CLR}
            System.Array.Copy(Buf, FRecordBuffers.Buffers[KeyBuf.Data].RecordContents, FRecordSize);
            {$ELSE}
            Move(Buf^, FRecordBuffers.Buffers[KeyBuf.Data].RecordContents^, FRecordSize);
            {$ENDIF}
            Err := SeekKeyExpression(KeyBuf);
          finally
            FreeRecordBuffer(KeyBuf.Data);
            FreeAndNil(KeyBuf);
          end;

          if (Err = r4success) or (Err = r4after) then {in case of r4after, a partial expression can still be true!}
          begin
            {Create Filter to check lookup question}
            TempFilter := CreateLookupFilter(Fields, KeyValues, Options);
            TempEXPR4 := expr4parse(FCBDATA4, TCB4PCharType(TempFilter));
            if TempEXPR4 <> nil then
            try
              Result := expr4true(TempEXPR4) > 0;
              {check filters etc.}
              while Result and (Err = r4success) and not (RecordAllowed = r4success) do
              begin
                Err := d4skip(FCBDATA4, 1);
                Result := expr4true(TempEXPR4) > 0;
              end;
            finally
              expr4free(TempEXPR4);
            end
            else
              Result := False;
          end
          else
            Result := False;

        end;

      finally
        RestoreState(dsBrowse);
      end;

      if Result then
      begin  // save record in (Temp)Buffer
        CopyRecordToRecordBuffer(Buffer);
      end;

      if Result and SyncCursor then
      begin
        FSavedRecord := -1;
        CurrentRecNo := d4recno(FCBDATA4); {save position}
      end;

      if KeyIndex <> nil then {Set Index back}
        d4tagSelect(FCBDATA4, CurrentTAG4);

    end else
    begin
      Result := False;
      TempFilter := CreateLookupFilter(Fields, KeyValues, Options);

      if TempFilter <> '' then
      begin
        if Filtered and (Filter <> '') then
          CreateExprFilter(Format('(%s) .AND. (%s)', [Filter, TempFilter]))
        else
          CreateExprFilter(TempFilter);
        FFiltersActive := True;
      end;

      try
        SavedPositionState := FPositionState;
        FPositionState := psBeforeFirst;
        try
          Result := GetRecord(Buffer, gmNext, False) = grOK;

          if Result and SyncCursor then
          begin
            FSavedRecord := -1;
            CurrentRecNo := d4recno(FCBDATA4); {save position}
          end;
        finally
          {restore state}
          FPositionState := SavedPositionState;
        end;
      finally
        CreateExprFilter(Filter);
        FFiltersActive := Filtered and ((FFilterEXPR4 <> nil) or Assigned(OnFilterRecord));
      end;

    end;

    if (CurrentRecno > 0) then
    begin
      {set to saved position}
      if CurrentRecNo > d4reccount(FCBDATA4) then
        Result := (d4bottom(FCBDATA4) in [r4success, r4eof]) and (d4skip(FCBDATA4, 1) = r4eof) and Result
      else
        Result := (d4go(FCBDATA4, CurrentRecNo) = r4success) and Result;
      if not Result then code4errorCode(Database.CBCODE4, 0); {reset errorcodes}
    end;

  finally
    Fields.Free;
  end;
end;

function TCB4Table.Lookup(const KeyFields: string; const KeyValues: Variant;
   const ResultFields: string): Variant;
begin
  Result := Null;
  if LocateRecord(KeyFields, KeyValues, [], False) then
  begin
    SetTempState(dsCalcFields);
    try
      CalculateFields(TempBuffer);
      Result := FieldValues[ResultFields];
    finally
      RestoreState(dsBrowse);
    end;
  end;
end;

function TCB4Table.MapsToIndex(Fields: TList; CaseInsensitive: Boolean): 
   Boolean;
var
  I: Integer;
  HasStr: Boolean;
begin
  Result := False;
  HasStr := False;
  for I := 0 to Fields.Count - 1 do
  begin
    HasStr := TField(Fields[I]).DataType in [ftString , ftFixedChar, ftWideString];
    if HasStr then break;
  end;
  if (CaseInsensitive <> FCaseInsIndex) and HasStr then Exit;
  if Fields.Count > IndexFieldCount then Exit;
  for I := 0 to Fields.Count - 1 do
    if Fields[I] <> IndexFields[I] then Exit;
  Result := True;
end;

procedure TCB4Table.MasterChanged(Sender: TObject);
begin
  CheckBrowseMode;
  UpdateRange;
  ApplyRange;
end;

procedure TCB4Table.MasterDisabled(Sender: TObject);
begin
  CancelRange;
end;

procedure TCB4Table.OpenIndexFile(const IndexName: string);
var
  CBINDEX4: INDEX4;
begin
  if Length(IndexName) = 0 then Exit;
  CBINDEX4 := i4open(FCBDATA4, TCB4PCharType(GetIndexPath(IndexName)));
  if CBINDEX4 = nil then CheckCBError;
end;

procedure TCB4Table.OpenTempTable(OpenIndices: Boolean);
var
  I: Integer;
begin
  InternalGetDatabase(True);
  if not Database.Connected then Database.Open;
  code4accessMode(Database.CBCODE4, ShareModes[FExclusive]);
  code4autoOpen(Database.CBCODE4, Ord( OpenIndices and (toUseProductionIndex in FOptions)));
  code4readOnly(Database.CBCODE4, Ord(FReadOnly));
  FCBDATA4 := d4open(Database.CBCODE4, TCB4PCharType(TablePath));
  {back to default:}
  code4accessMode(Database.CBCODE4, OPEN4DENY_NONE);
  code4autoOpen(Database.CBCODE4, 1);
  code4readOnly(Database.CBCODE4, 0);
  
  if FCBDATA4 = nil then CheckCBError;
  if not OpenIndices then Exit;
  
  for I := 0 to IndexFiles.Count - 1 do
    OpenIndexFile(IndexFiles[I]);
end;

procedure TCB4Table.Post;
begin
  inherited Post;
  if State = dsSetKey then
    PostKeyBuffer(True);
end;

procedure TCB4Table.PostKeyBuffer(Commit: Boolean);
begin
  DataEvent(deCheckBrowseMode, TCB4DataEventInfo(0));
  if Commit then
    FKeyBuffer.Modified := Modified
  else
    CopyKeyBuffer(FKeyBuffers[kiSave], FKeyBuffer);
  SetState(dsBrowse);
  DataEvent(deDataSetChange, TCB4DataEventInfo(0));
end;

function TCB4Table.RecordAllowed: Integer;
var
  RecExpr: string;
  RecDouble: Double;

  function CheckRangeStart(CompValue: Double): Integer;
  begin
    if (CompValue > 0) or ((CompValue = 0) and not FKeyBuffers[kiRangeStart].Exclusive) then
      Result := r4success
    else
      Result := r4bof;
  end;
  function CheckRangeEnd(CompValue: Double): Integer;
  begin
    if (CompValue < 0) or ((CompValue = 0) and not FKeyBuffers[kiRangeEnd].Exclusive) then
      Result := r4success
    else
      Result := r4eof;
  end;

begin
  if (d4deleted(FCBDATA4) = 0) or (toShowDeletedRecords in FOptions) then
    Result := r4success
  else
    Result := -1;

  if (Result = r4success) and FRangeActive then
  begin

    if FKeyType = r4num then
    begin
      RecDouble := expr4double(FKeyEXPR4);
      if FRangeStartKey.KeyType <> 0 then
        Result := CheckRangeStart(RecDouble - FRangeStartKey.DoubleKey);
      {else it's allready r4success}
      if (Result = r4success) then
      begin
        if FRangeEndKey.KeyType <> 0 then
          Result := CheckRangeEnd(RecDouble - FRangeEndKey.DoubleKey)
        else
          Result := r4eof;
      end;
    end
    else
    begin
      SetLength(RecExpr, FKeySize);
      {$IFDEF CLR}
      RecExpr := Marshal.PtrToStringAnsi(expr4str(FKeyEXPR4));
      {$ELSE}
      Move(expr4str(FKeyEXPR4)^, PChar(RecExpr)^, FKeySize);
      {$ENDIF}
      if FRangeStartKey.KeyType <> 0 then
        Result := CheckRangeStart(CompareStr(Copy(RecExpr, 1, FKeyRangeStartSize), string(FRangeStartKey.StringKey)));
      {else it's allready r4success}
      if (Result = r4success) then
      begin
        if FRangeEndKey.KeyType <> 0 then
          Result := CheckRangeEnd(CompareStr(Copy(RecExpr, 1, FKeyRangeEndSize), string(FRangeEndKey.StringKey)))
        else
          Result := r4eof;
      end;
    end;
  end;

  if ((Result = r4success) and FFiltersActive) and not FilterCurrentRecord then
    Result := -1;
end;

function TCB4Table.FilterCurrentRecord: Boolean;
var
  SaveState: TDataSetState;
begin
  Result := True;

  if Assigned(FFilterEXPR4) then
  begin
    Result := expr4true(FFilterEXPR4) > 0;
    if not Result then Exit;
  end;

  if Assigned(OnFilterRecord) then
  begin
    SaveState := SetTempState(dsFilter);
    try
      CopyRecordToRecordBuffer(FFilterBuffer);
      OnFilterRecord(Self, Result);
    finally
      RestoreState(SaveState);
    end;
  end;
end;

function TCB4Table.GetBlobData(Field: TField; Buffer: TRecordBuffer):
    TMemoryStream;
begin
  Result := FRecordBuffers.Buffers[Buffer].BlobData[Field.Offset].Data;
end;

function TCB4Table.ResetCursorRange: Boolean;
begin
  Result := False;
  if FKeyBuffers[kiCurRangeStart].Modified or
    FKeyBuffers[kiCurRangeEnd].Modified then
  begin
    FRangeActive := False;
    FreeRangeKeys;

    InitKeyBuffer(FKeyBuffers[kiCurRangeStart], False);
    InitKeyBuffer(FKeyBuffers[kiCurRangeEnd], False);
  //    DestroyLookupCursor;
    Result := True;
    FFirstSequencedPosition := 0;
    FRangeSequencedPosition := 1;
  end;
end;

procedure TCB4Table.RestoreInternalState;
begin
  // called by Database after Rollback
  CursorPosChanged;
  d4top(CBDATA4); // let CodeBase get a correct position;
  try
    UpdateCursorPos;  // could fail if record don't exist anymore
  except
    on EDatabaseError do
    begin
      if code4errorCode(Database.CBCODE4, 0) = e4read then
      begin
        // this behaviour is different from BDE: the BDE generates a Record/key deleted error in operations following the rollback
        SetState(dsBrowse); // make sure table is in browse mode
        First; // no valid position anymore -> set it to first record
      end
      else
        raise;
    end;
  end;
  inherited RestoreInternalState;
end;

function TCB4Table.SeekKeyExpression(KeyBuffer: TKeyBuffer): Integer;
var
  P: {$IFDEF CLR}IntPtr{$ELSE}PChar{$ENDIF};
  D: Double;
begin
  CopyRecordBufferToRecord(KeyBuffer.Data);
  d4changed(FCBDATA4, 0); {don't save the changed record}
  case FKeyType of
    r4str:
    begin
      {$IFDEF CLR}
      P := expr4str(FKeyExprEXPR4);
      Result := d4seek(FCBDATA4, Marshal.PtrToStringAnsi(P, FKeyExprSize))
      {$ELSE}
      P := StrAlloc(FKeyExprSize+1);
      try  // copy Evaluated Expression to P with length of KeyExprSize !!!
        StrLCopy(P, expr4str(FKeyExprEXPR4), FKeyExprSize);
        P[FKeyExprSize] := #0;
        Result := d4seek(FCBDATA4, P); {this crashed if P was to long!}
      finally
        StrDispose(P);
      end;
      {$ENDIF}
    end;
    r4num:
    begin
      D := expr4double(FKeyExprEXPR4);
      Result := d4seekDouble(FCBDATA4, D);
    end
    else
    begin
      DatabaseError(SErrorInTagEvaluation);
      Result := -1; // dummy to get rid of warning
    end;

  end;
end;

function TCB4Table.SeekSingleKey(aValue: Variant; aNext: Boolean): Integer;
var
  W: Widestring;
  S: string;
  {$IFDEF CLR}
  IP: IntPtr;
  {$ELSE}
  IP: Pointer;
  {$ENDIF}
begin
  case FKeyType of
    r4log: if Boolean(aValue) then S := 'T' else S := 'F';
    r4int: S := IntToStr(aValue);
    r4currency: S := TCB4AbstractRecordBuffer.UnlocalizeFloat(FloatToStr(aValue));
    r4dateTime: S := FormatFloat('yyyymmddhh":"nn":"ss":"zzz', VarToDateTime(aValue));
    r4unicode:
    begin
      W := VarToWideStr(aValue);
    end
    else
      DatabaseErrorFmt(SUnsupportedKeytype, [char(FKeyType)]);
  end;

  if FKeyType = r4unicode then
  begin
    {$IFDEF CLR}
    IP := Marshal.StringToHGlobalUni(W);
    try
    {$ELSE}
    IP := Pointer(W);
    {$ENDIF}
      if aNext then
        Result := d4seekNextN(FCBDATA4, IP, Length(W)*2)
      else
        Result := d4seekN(FCBDATA4, IP, Length(W)*2)
    {$IFDEF CLR}
    finally
      Marshal.FreeCoTaskMem(IP);
    end;
    {$ENDIF}
  end
  else
  begin
    if aNext then
      Result := d4seekNext(FCBDATA4, TCB4PCharType(s))
    else
      Result := d4seek(FCBDATA4, TCB4PCharType(s));
  end;
end;

procedure TCB4Table.SetBlobState(Field: TField; Buffer: TRecordBuffer;
    aBlobState: TCB4BlobState);
begin
  if (Buffer = ActiveBuffer) or (Buffer = CalcBuffer) then
    FRecordBuffers.Buffers[Buffer].SetBlobState(Field.Offset, aBlobState);
end;

procedure TCB4Table.SetBookmarkData(Buffer: TRecordBuffer; {$IFDEF CLR}const Bookmark: TBookmark{$ELSE}Data: Pointer{$ENDIF});
begin
  {$IFDEF CLR}
  FRecordBuffers.Buffers[Buffer].RecordNumber := Marshal.ReadInt32(Bookmark);
  {$ELSE}
  FRecordBuffers.Buffers[Buffer].RecordNumber := Integer(Data^);
  {$ENDIF}
end;

procedure TCB4Table.SetBookmarkFlag(Buffer: TRecordBuffer; Value:
    TBookmarkFlag);
begin
  FRecordBuffers.Buffers[Buffer].BookmarkFlag := Value;
end;

function TCB4Table.SetCursorRange: Boolean;
var
  RangeStart, RangeEnd: TKeyBuffer;
  SavedPositionState: TCB4PositionState;
  Buffer: TRecordBuffer;

  procedure SetRecordTo(aKeybuffer: TKeyBuffer);
  begin
    CopyRecordBufferToRecord(aKeyBuffer.Data);
    d4changed(FCBDATA4, 0); {don't save the changed record}
  end;

begin
  Result := False;
  if not (
    KeyBuffersEqual(FKeyBuffers[kiRangeStart], FKeyBuffers[kiCurRangeStart]) and
    KeyBuffersEqual(FKeyBuffers[kiRangeEnd], FKeyBuffers[kiCurRangeEnd])) then
  begin

  //  UseStartKey := True;
  //  UseEndKey := True;
    FreeRangeKeys;
    RangeStart := FKeyBuffers[kiRangeStart];
    SetKeyExpression(RangeStart.FieldCount);
    FKeyRangeStartSize := FKeyExprSize;
    if RangeStart.Modified then
    begin
      SetRecordTo(RangeStart);
      if FKeyType = r4num then
      begin
        FRangeStartKey.DoubleKey := expr4double(FKeyExprEXPR4);
      end
      else
      begin
        {$IFDEF CLR}
        SetLength(FRangeStartKey.StringKey, FKeyExprSize+1);
        Marshal.Copy(expr4str(FKeyExprEXPR4), FRangeStartKey.StringKey, 0, FKeyExprSize);
        FRangeStartKey.StringKey[FKeyExprSize] := 0;
        {$ELSE}
        FRangeStartKey.StringKey := StrAlloc(FKeyExprSize+1);
        Move(expr4str(FKeyExprEXPR4)^, FRangeStartKey.StringKey^, FKeyExprSize);
        PChar(FRangeStartKey.StringKey)[FKeyExprSize] := #0;
        {$ENDIF}
      end;
      FRangeStartKey.KeyType := FKeyType;
  //    UseStartKey := True;
    end;

    RangeEnd := FKeyBuffers[kiRangeEnd];
    SetKeyExpression(RangeEnd.FieldCount);
    FKeyRangeEndSize := FKeyExprSize;
    if RangeEnd.Modified then
    begin
      SetRecordTo(RangeEnd);
      if FKeyType = r4num then
      begin
        FRangeEndKey.DoubleKey := expr4double(FKeyExprEXPR4);
      end
      else
      begin
        {$IFDEF CLR}
        SetLength(FRangeEndKey.StringKey, FKeyExprSize+1);
        Marshal.Copy(expr4str(FKeyExprEXPR4), FRangeEndKey.StringKey, 0, FKeyExprSize);
        FRangeEndKey.StringKey[FKeyExprSize] := 0;
        {$ELSE}
        FRangeEndKey.StringKey := StrAlloc(FKeyExprSize+1);
        Move(expr4str(FKeyExprEXPR4)^, FRangeEndKey.StringKey^, FKeyExprSize);
        PChar(FRangeEndKey.StringKey)[FKeyExprSize] := #0;
        {$ENDIF}
      end;
      FRangeEndKey.KeyType := FKeyType;
  //    UseEndKey := True;
    end;

  //  UseKey := UseStartKey and UseEndKey;

    FRangeActive := True;

    CopyKeyBuffer(FKeyBuffers[kiRangeStart], FKeyBuffers[kiCurRangeStart]);
    CopyKeyBuffer(FKeyBuffers[kiRangeEnd], FKeyBuffers[kiCurRangeEnd]);
  //    DestroyLookupCursor;
    Result := True;

    if toSequenceIndex in Options then // find position of first and last record
    begin
      SavedPositionState := FPositionState;
      try
        Buffer := TempBuffer;
        // @ no need to save current recno, because the table is always synced after setcursorrange???
        FPositionState := psBeforeFirst;
        if GetRecord(Buffer, gmNext, False) = grOK then
          FFirstSequencedPosition := d4position(FCBDATA4)
        else
          FFirstSequencedPosition := 0;

        FPositionState := psAfterLast;
        if GetRecord(Buffer, gmNext, False) = grOK then
          FRangeSequencedPosition := d4position(FCBDATA4) - FFirstSequencedPosition
        else
          FRangeSequencedPosition := 1;
      finally
        {restore state}
        FPositionState := SavedPositionState;
      end;
    end;
  end;
end;

procedure TCB4Table.SetDatabase(Value: TCB4Database);
begin
  if FDatabase <> Value then
  begin
    CheckInactive;
//    if FDatabase <> nil then DatabaseError(SDatabaseOpen);
    inherited SetDatabase(Value);
    DataEvent(dePropertyChange, TCB4DataEventInfo(0));
  end
  else
  begin
    inherited SetDatabase(Value);
  end;
end;

procedure TCB4Table.SetExclusive(Value: Boolean);
begin
  CheckInactive;
  FExclusive := Value;
end;

procedure TCB4Table.FreeRangeKeys;
begin
(*
  if Assigned(FRangeStartKey) then FreeMem(FRangeStartKey);
  FRangeStartKey := nil;
  if Assigned(FRangeEndKey) then FreeMem(FRangeEndKey);
  FRangeEndKey := nil;
*)
  if FRangeEndKey.KeyType = r4str then
  begin
    {$IFDEF CLR}
    SetLength(FRangeEndKey.StringKey, 0);
    {$ELSE}
    StrDispose(FRangeEndKey.StringKey);
    FRangeEndKey.StringKey := nil;
    {$ENDIF}
  end;
  FRangeEndKey.KeyType := 0;
  if FRangeStartKey.KeyType = r4str then
  begin
    {$IFDEF CLR}
    SetLength(FRangeStartKey.StringKey, 0);
    {$ELSE}
    StrDispose(FRangeStartKey.StringKey);
    FRangeStartKey.StringKey := nil;
    {$ENDIF}
  end;
  FRangeStartKey.KeyType := 0;
end;

procedure TCB4Table.SetFieldData(Field: TField; Buffer: TValueBuffer);
var
  I: Integer;
  RecBuffer: TRecordBuffer;
  Buf: TRecordContents;
begin

(*begin
  Result := False;
  if not GetActiveRecBuf(RecBuffer) then Exit;
  with Field do
    if FieldNo > 0 then
    begin
      Result := FRecordBuffers.Buffers[RecBuffer].GetField(Self, Field, Buffer);
    end
    else
      if State in [dsBrowse, dsEdit, dsInsert, dsCalcFields] then
      begin
        Buf := FRecordBuffers.Buffers[RecBuffer].RecordContents;
        I := FRecordSize + Offset;
        Result := Boolean(Buf[I]);
        if Result and (Buffer <> nil) then
        {$IFDEF CLR}
          Marshal.Copy(Buf, I+1, Buffer, DataSize);
        {$ELSE}
          Move(Buf[I+1], Buffer^, DataSize);
        {$ENDIF}
      end;
*)

  with Field do
  begin
    if not (State in dsWriteModes) then DatabaseError(SNotEditing);
    if (State = dsSetKey) and ((FieldNo < 0) or (IndexFieldCount > 0) and
      not IsIndexField) then DatabaseErrorFmt(SNotIndexField, [DisplayName]);
    GetActiveRecBuf(RecBuffer);
    if FieldNo > 0 then
    begin
      if State = dsCalcFields then DatabaseError(SNotEditing);
      if ReadOnly and not (State in [dsSetKey, dsFilter]) then
        DatabaseErrorFmt(SFieldReadOnly, [DisplayName]);
      Validate(Buffer);
      if FieldKind <> fkInternalCalc then
      begin
  //      if FConstraintLayer and Field.HasConstraints and (State in [dsEdit, dsInsert]) then
  //        Check(DbiVerifyField(FHandle, FieldNo, Buffer, Blank));
        FRecordBuffers.SetField(RecBuffer, Field, Buffer);
      end;
    end else {fkCalculated, fkLookup}
    begin
      Buf := FRecordBuffers.Buffers[RecBuffer].RecordContents;
      I := FRecordSize + Offset;
      if Buffer<>nil then
      begin
        Buf[I] := TRecordContent(True);
        {$IFDEF CLR}
          Marshal.Copy(Buffer, Buf, I+1, DataSize);
        {$ELSE}
          Move(Buffer^, Buf[I+1], DataSize);
        {$ENDIF}
      end
      else
        Buf[I] := TRecordContent(False);
    end;
    if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
      DataEvent(deFieldChange, TCB4DataEventInfo(Field));
  end;
end;

procedure TCB4Table.SetFieldDataRaw(aField: TField; aBuffer: TValueBuffer;
    aLength: Integer=MaxInt);
var
  RecBuffer: TRecordBuffer;
  Buf: TRecordContents;
  Len: Integer;
  I: Integer;
begin
  { TODO : share code with SetFieldData }
  with aField do
  begin
    if not (State in dsWriteModes) then DatabaseError(SNotEditing);
    if (State = dsSetKey) and ((FieldNo < 0) or (IndexFieldCount > 0) and
      not IsIndexField) then DatabaseErrorFmt(SNotIndexField, [DisplayName]);
    GetActiveRecBuf(RecBuffer);
    if FieldNo > 0 then
    begin
      if State = dsCalcFields then DatabaseError(SNotEditing);
      if ReadOnly and not (State in [dsSetKey, dsFilter]) then
        DatabaseErrorFmt(SFieldReadOnly, [DisplayName]);
      if FieldKind <> fkInternalCalc then
      begin
  //      if FConstraintLayer and Field.HasConstraints and (State in [dsEdit, dsInsert]) then
  //        Check(DbiVerifyField(FHandle, FieldNo, Buffer, Blank));
        Len := InternalFieldLength(FieldNo);
        if Len > aLength then
          Len := aLength;
      {$IFDEF CLR}
        Marshal.Copy(aBuffer, FRecordBuffers.Buffers[RecBuffer].RecordContents, FFieldRecPos[FieldNo-1], Len);
      {$ELSE}
        FRecordBuffers.Buffers[RecBuffer].CopyBufferToFieldContent(aBuffer, FFieldRecPos[FieldNo-1], Len);
      {$ENDIF}
//        Move(aBuffer^, PChar(Integer(Buf) + Integer(FFieldRecPos[FieldNo-1]))^, Len);
      end;
    end else {fkCalculated, fkLookup}
    begin
      Buf := FRecordBuffers.Buffers[RecBuffer].RecordContents;
      I := FRecordSize + Offset;
      Buf[I] := TRecordContent(True);
      Len := DataSize;
      if Len > aLength then
        Len := aLength;
      {$IFDEF CLR}
        Marshal.Copy(aBuffer, Buf, I+1, Len);
      {$ELSE}
        Move(aBuffer^, Buf[I+1], Len);
      {$ENDIF}
    end;
    if not (State in [dsCalcFields, dsFilter, dsNewValue]) then
      DataEvent(deFieldChange, TCB4DataEventInfo(aField));
  end;
end;

procedure TCB4Table.SetFiltered(Value: Boolean);
begin
  if Active then
  begin
    CheckBrowseMode;
    if Filtered <> Value then
    begin
  //    DestroyLookupCursor;
      InternalFirst;
      if Value then ActivateFilters else DeactivateFilters;
      inherited SetFiltered(Value);
    end;
    First;
  end else
  inherited SetFiltered(Value);
end;

procedure TCB4Table.SetFilterText(const Value: string);
begin
  if Active then
  begin
    CheckBrowseMode;
    if (Filter <> Value) then
    begin
      CreateExprFilter(Value);
  
      if Filtered then
      begin
        CursorPosChanged;
    //  DestroyLookupCursor;
        InternalFirst;
      end
    end;
  end;
  inherited SetFilterText(Value);
  if Active and Filtered then First;
end;

procedure TCB4Table.SetIndex(const Value: string; FieldsIndex: Boolean);
var
  IndexName, IndexTag: string;
begin
  if Active then CheckBrowseMode;
  if (FIndexName <> Value) or (FFieldsIndex <> FieldsIndex) then
  begin
    if Active then
    begin
      GetIndexParams(Value, FieldsIndex, IndexName, IndexTag);
      SwitchToIndex(IndexName, IndexTag);
      CheckMasterRange;
    end;
    FIndexName := Value;
    FFieldsIndex := FieldsIndex;
    if Active then Resync([]);
  end;
end;

procedure TCB4Table.SetIndexFieldNames(const Value: string);
begin
  SetIndex(Value, Value <> '');
end;

procedure TCB4Table.SetIndexFields(Index: Integer; Value: TField);
begin
  GetIndexFields(Index).Assign(Value);
end;

procedure TCB4Table.SetIndexFiles(Value: TStrings);
begin
  FIndexFiles.Assign(Value);
end;

procedure TCB4Table.SetIndexName(const Value: string);
begin
  SetIndex(Value, False);
end;

procedure TCB4Table.SetKey;
begin
  SetKeyBuffer(kiLookup, True);
end;

procedure TCB4Table.SetKeyBuffer(KeyIndex: TKeyIndex; Clear: Boolean);
begin
  CheckBrowseMode;
  FKeyBuffer := FKeyBuffers[KeyIndex];
  CopyKeyBuffer(FKeyBuffer, FKeyBuffers[kiSave]);
  if Clear then InitKeyBuffer(FKeyBuffer, False);
  SetState(dsSetKey);
  SetModified(FKeyBuffer.Modified);
  DataEvent(deDataSetChange, TCB4DataEventInfo(0));
end;

procedure TCB4Table.SetKeyExclusive(Value: Boolean);
begin
  CheckSetKeyMode;
  FKeyBuffer.Exclusive := Value;
end;

procedure TCB4Table.SetKeyExpression(FieldCount: Integer);

  procedure InternalSetKeyExpression(const aExpr: string);
  begin
    if Assigned(FKeyExprEXPR4) and (aExpr = FKeyExpression) then
      Exit;  // it is allready set
    if Assigned(FKeyExprEXPR4) then expr4free(FKeyExprEXPR4);
    if aExpr = '' then
    begin
      FKeyExprEXPR4 := nil;
      FKeyExprSize := 0;
      FKeyType := 0;
    end
    else
    begin
      FKeyExprEXPR4 := expr4parse(FCBDATA4, TCB4PCharType(aExpr));
      FKeyExprSize := expr4len(FKeyExprEXPR4);
      FKeyType := expr4type(FKeyExprEXPR4);
      case FKeyType of
        r4date, r4str: FKeyType := r4str;
        r4dateDoub, r4num, r4numDoub: FKeyType := r4num;
      end;
    end;
    FKeyExpression := aExpr;
  end;

var
  CBTAG4: TAG4;
  S: string;
  L, P: Integer;
begin
  CBTAG4 := d4tagSelected(FCBDATA4);
  if CBTAG4 <> nil then
  begin
    S := string(t4expr(CBTAG4));
    if FExpIndex or (FieldCount = 0) then
      InternalSetKeyExpression(S)
    else
    begin
      L := 0;
      P := 1;
      while (P <> 0) and (FieldCount > 0) do
      begin
        P := Pos('+', Copy(S, L+1, MaxInt));
        if P <> 0 then L := L + P;
        Dec(FieldCount);
      end;
      if P = 0 then
        InternalSetKeyExpression(S)
      else
        InternalSetKeyExpression(Trim(Copy(S, 1, L-1)));
    end;
  end
  else
    InternalSetKeyExpression('');
end;

procedure TCB4Table.SetKeyFields(KeyIndex: TKeyIndex;   const Values: array of
   const);
var
  SaveState: TDataSetState;
  I: Integer;
begin
  if ExpIndex then DatabaseError(SCompositeIndexError);
  if IndexFieldCount = 0 then DatabaseError(SNoFieldIndexes);
  SaveState := SetTempState(dsSetKey);
  try
    SetKeyExpression(High(Values) + 1);
    FKeyBuffer := InitKeyBuffer(FKeyBuffers[KeyIndex], False);
    for I := 0 to High(Values) do
    {$IFDEF CLR}
      GetIndexFields(I).AssignValue(Variant(Values[I]));
    {$ELSE}
      GetIndexFields(I).AssignValue(Values[I]);
    {$ENDIF}
    FKeyBuffer.FieldCount := High(Values) + 1;
    FKeyBuffer.Modified := Modified;
  finally
    RestoreState(SaveState);
  end;
end;

procedure TCB4Table.SetLinkRanges(MasterFields: TList);
var
  I: Integer;
  SaveState: TDataSetState;
begin
  SaveState := SetTempState(dsSetKey);
  try
    FKeyBuffer := InitKeyBuffer(FKeyBuffers[kiRangeStart], False);
    FKeyBuffer.Modified := True;
    for I := 0 to MasterFields.Count - 1 do
      IndexFields[I].Assign(TField(MasterFields[I]));
    FKeyBuffer.FieldCount := MasterFields.Count;
  // on except restore previous range?
  finally
    RestoreState(SaveState);
  end;
  CopyKeyBuffer(FKeyBuffers[kiRangeStart], FKeyBuffers[kiRangeEnd]);
end;

procedure TCB4Table.SetMasterFields(const Value: string);
begin
  FMasterLink.FieldNames := Value;
end;

procedure TCB4Table.SetMasterSource(const Value: TDataSource);
begin
  if IsLinkedTo(Value) then DatabaseError(SCircularDataLink);
  FMasterLink.DataSource := Value;
end;

procedure TCB4Table.SetOptions(Value: TCB4TableOptions);
begin
  CheckInactive;
  FOptions := Value;
end;

procedure TCB4Table.SetRange(const StartValues, EndValues: array of const);
begin
  CheckBrowseMode;
  SetKeyFields(kiRangeStart, StartValues);
  SetKeyFields(kiRangeEnd, EndValues);
  ApplyRange;
end;

procedure TCB4Table.SetRangeEnd;
begin
  SetKeyBuffer(kiRangeEnd, True);
end;

procedure TCB4Table.SetRangeStart;
begin
  SetKeyBuffer(kiRangeStart, True);
end;

procedure TCB4Table.SetReadOnly(Value: Boolean);
begin
  CheckInactive;
  FReadOnly := Value;
end;

procedure TCB4Table.SetRecNo(Value: Integer);
var
  I, Err: Integer;
begin
  CheckBrowseMode;
  if IsSequenced and (Value <> RecNo) and (Value > 0) and ((FIndexName = '') or (toSequenceIndex in Options)) then
  begin
    DoBeforeScroll;
    if (FIndexName <> '') then
    begin
      I := d4reccount(FCBDATA4);
      if I > 0 then
      begin
        if FRangeSequencedPosition = 0 then
          Err := d4positionSet(FCBDATA4, FFirstSequencedPosition)
        else
          Err := d4positionSet(FCBDATA4, ((Value*FRangeSequencedPosition)/I) + FFirstSequencedPosition);
  
        if Err = r4eof then
          Value := I
        else
        begin
          if Err <> r4success then
            Check(Err)
          else
            Value := d4recno(FCBDATA4);
        end;
      end
      else
        Value := 0;
    end;
  
    if Value > 0 then
    begin
      FSavedRecord := -1;
      GotoRecord(Value);
    end;
    Resync([rmCenter]);
    DoAfterScroll;
  end;
end;

procedure TCB4Table.SetTableName(const Value: string);
begin
  if csReading in ComponentState then
    FTableName := Value
  else if (FTableName <> Value) then
  begin
    CheckInactive;
    IndexFiles.Clear;
    FTableName := Value;
    DataEvent(dePropertyChange, TCB4DataEventInfo(0));
  end;
end;

procedure TCB4Table.SwitchToIndex(const IndexName, TagName:string);
var
  CBINDEX4: INDEX4;
  CBTAG4: TAG4;
begin
  ResetCursorRange;
  UpdateCursorPos;

  if (IndexName <> '') and (TagName <> '') then
  begin
    CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(GetIndexPath(IndexName)));
    if CBINDEX4 = nil then CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(IndexName));
    if CBINDEX4 = nil then CheckCBError;

    CBTAG4 := i4tag(CBINDEX4, TCB4PCharType(TagName));
    if CBTAG4 = nil then CheckCBError;
    CheckNeg(d4tagSelect(FCBDATA4, CBTAG4));
  end
  else
    CheckNeg(d4tagSelect(FCBDATA4, nil));
  
  FKeySize := 0;
  FExpIndex := False;
  FCaseInsIndex := False;
  
  FIndexFields.Clear;
  
  SetBufListSize(0);
  InitBufferPointers(True); // is this necessary in CB4 Tables?
  try
    SetBufListSize(BufferCount + 1);
  except
    SetState(dsInactive);
    CloseCursor;
    raise;
  end;

  GetIndexInfo;
end;

procedure TCB4Table.UpdateIndexDefs;
var
//  IndexDescs: Pointer;
  TagInfo: {$IFDEF CLR}TAG4INFO{$ELSE}PTAG4INFO{$ENDIF};
  KeptTagInfo{$IFDEF CLR}, CurTagInfo{$ENDIF}: PTAG4INFO;
  TagName: string;

  I: Integer;
  CBINDEX4: INDEX4;
  IndexFile: string;
  NeededToOpen: Boolean;
  Options: TIndexOptions;
  Expression, DescFields, CaseIns: string;
begin
  if not FIndexDefs.Updated then
  begin
    NeededToOpen := not Assigned(FCBDATA4);
    if NeededToOpen then
      OpenTempTable(True);
    try
      FieldDefs.Update;

      IndexDefs.Clear;
      for I := -1 to FIndexFiles.Count-1 do
      begin
        if (I = -1) and not (toUseProductionIndex in FOptions) then Continue;

        IndexFile := IndexPaths[I];
        CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(IndexFile));
        if CBINDEX4 = nil then
        begin
          IndexFile := ExtractFileName(IndexPaths[I]);
          CBINDEX4 := d4index(FCBDATA4, TCB4PCharType(IndexFile));
        end;

        if CBINDEX4 <> nil then
        begin

          KeptTagInfo := i4tagInfo(CBINDEX4);
          {$IFDEF CLR}
          TagInfo := TAG4INFO(Marshal.PtrToStructure(KeptTagInfo, TypeOf(TAG4INFO)));
          CurTagInfo := KeptTagInfo;
          {$ELSE}
          TagInfo := KeptTagInfo;
          {$ENDIF}
          try
            while TagInfo.Name <> nil do
            begin
              {$IFDEF CLR}
              TagName := Marshal.PtrToStringAnsi(TagInfo.Name);
              AnalyzeTAG(CurTagInfo, Options, Expression, DescFields, CaseIns);
              {$ELSE}
              TagName := TagInfo.Name;
              AnalyzeTAG(TagInfo, Options, Expression, DescFields, CaseIns);
              {$ENDIF}

              FIndexDefs.Add(TagName, Expression, Options);
              FIndexDefs[FIndexDefs.Count - 1].DescFields := DescFields;
              FIndexDefs[FIndexDefs.Count - 1].CaseInsFields := CaseIns;

              if I >= 0 then
                FIndexDefs[FIndexDefs.Count - 1].Source := FIndexFiles[I]
              else
                FIndexDefs[FindexDefs.Count - 1].Source := ExtractFileName(IndexFile);

              {$IFDEF CLR}
              CurTagInfo := IntPtr(CurTagInfo.ToInt32 + SizeOf(TAG4INFO));
              TagInfo := TAG4INFO(Marshal.PtrToStructure(CurTagInfo, TypeOf(TAG4INFO)));
              {$ELSE}
              TagInfo := Pointer(Integer(TagInfo) + SizeOf(TAG4INFO));
              {$ENDIF}
            end;
          finally
            u4free(PVoid(KeptTagInfo));
          end;
        end;
      end;
    finally
      if NeededToOpen then
        CloseTempTable;
    end;
    IndexDefs.Updated := True;
  end;
  inherited UpdateIndexDefs;
end;

procedure TCB4Table.UpdateRange;
begin
  SetLinkRanges(FMasterLink.Fields);
end;

{$IFDEF CLR}
function TCB4Table.InternalTranslate(const Src: IntPtrPChar; aMem: TMemoryStream; aLength: Integer; ToOem: Boolean):
   Integer;
var
  Dst: IntPtr;
begin
  Result := aLength;
  if toNoCharacterTranslation in Options then
  begin
    Marshal.Copy(Src, aMem.Memory, 0, aLength);
    Exit;
  end;
  with TDBBufferList.Create do
  try
    Dst := AllocHGlobal(aLength+1);
    TranslateOnIntPtr(Src, Dst, aLength, ToOem);
    Marshal.Copy(Dst, aMem.Memory, 0, aLength);
  finally
    FreeHGlobal(Dst);
    Free;
  end;
end;
{$ENDIF}

{$IFDEF WIN32}
function TCB4Table.InternalTranslate(Src, Dest: PChar; aLength: Integer;
    ToOem: Boolean): Integer;
{$ELSE}
function TCB4Table.InternalTranslate(const Src: string; var Dest: string; ToOem: Boolean): Integer;
{$ENDIF}
begin
  if toNoCharacterTranslation in Options then
  begin
    if (Src <> nil) then
    begin
      if (Src <> Dest) then
      begin
        {$IFDEF CLR}
        Dest := Src;
        {$ELSE}
        StrLCopy(Dest, Src, aLength);
        {$ENDIF}
      end;
      {$IFDEF CLR}
      Result := Length(Dest);
      {$ELSE}
      Result := aLength;
      {$ENDIF}
    end
    else
      Result := 0;
  end
  else
    Result := inherited InternalTranslate(Src, Dest, {$IFNDEF CLR}aLength, {$ENDIF}ToOem);
end;

constructor TCB4RecordBufferList.Create(aTable: TCB4Table);
begin
  inherited Create;
  FTable := aTable;
  FLastFreeIndex := -1;
  FList := TList.Create;
  SetLength(FFreeBufferList, 0);
end;

destructor TCB4RecordBufferList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TCB4RecordBufferList.InternalAdd(aRecordBuffer: TCB4RecordBuffer):
    TRecordBuffer;
var
  Index: Integer;
begin
  if (FLastFreeIndex=-1) or (Length(FFreeBufferList) = 0) then
    Index := FList.Add(aRecordBuffer)+1
  else
  begin
    Index := FFreeBufferList[FLastFreeIndex]+1;
    Dec(FLastFreeIndex);
    Buffers[TRecordBuffer(Index)] := aRecordBuffer;
  end;
  Result := TRecordBuffer(Index);
end;

function TCB4RecordBufferList.Add: TRecordBuffer;
var
  RecBuf: TCB4RecordBuffer;
begin
  RecBuf := TCB4RecordBuffer.Create(FRecBufSize, FTable.BlobFieldCount);
  Result := InternalAdd(RecBuf);
end;

procedure TCB4RecordBufferList.Clear;
var
  I: Integer;
begin
  for I := 1 to Count do
    Buffers[TRecordBuffer(I)].Free;
  FList.Clear;
  SetLength(FFreeBufferList, 0);
  FLastFreeIndex := -1;
end;

procedure TCB4RecordBufferList.CopyRecordContents(aSource, aDest:
    TCB4RecordBuffer);
begin
  // only the recordcontents!
  {$IFDEF CLR}
  System.Array.Copy(aSource.RecordContents, aDest.RecordContents, FRecBufSize);
  {$ELSE}
  Move(aSource.RecordContents^, aDest.RecordContents^, FRecBufSize);
  {$ENDIF}
end;

const
  EXPANDFREEBUFFERSIZE = 10;

procedure TCB4RecordBufferList.Delete(Index: TRecordBuffer);
var
  RecBuf: TCB4RecordBuffer;
begin
  if Index=TRecordBuffer(0) then Exit; // 'nil'
  RecBuf := Buffers[Index];
  RecBuf.Free;

  Inc(FLastFreeIndex);
  if FLastFreeIndex > High(FFreeBufferList) then
    SetLength(FFreeBufferList, Length(FFreeBufferList)+EXPANDFREEBUFFERSIZE);

  FFreeBufferList[FLastFreeIndex] := Integer(Index)-1;
  Buffers[Index] := nil;
end;

function TCB4RecordBufferList.GetBuffers(Index: TRecordBuffer):
    TCB4RecordBuffer;
begin
  Result := TCB4RecordBuffer(FList[Integer(Index)-1]);
end;

function TCB4RecordBufferList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCB4RecordBufferList.GetField(aIndex: TRecordBuffer; aField: TField; Buffer: TValueBuffer): Boolean;
var
  IndexedRecord: TCB4RecordBuffer;
  I, StartPos: Integer;
  B: Byte;
begin
//    if (Database.DatabaseType = dtCB4FoxPro) and ((Field.DataType in [ftInteger, ftCurrency, ftDateTime]) or ((Field.DataType = ftFloat) and (Integer(FFieldRecType[Field.FieldNo-1]) = r4double)) ) then
  StartPos := FTable.FFieldRecPos[aField.FieldNo-1]; // is used by almost any function
  IndexedRecord := Buffers[aIndex];

  B := FTable.FFieldRecType[aField.FieldNo-1];
  if (FTable.Database.DatabaseType = dtCB4FoxPro) and (B in VFNFields) then
  begin
    {$IFDEF NOVFNULLSUPPORT}
    Result := True;
    {$ELSE}


    FTable.CopyRecordBufferToRecord(aIndex);
(*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
  IF YOU GET AN ERROR HERE THEN GOTO TOP OF THIS UNIT AND UNCOMMENT the NOVFNULLSUPPORT line
  (or get a newer version of CodeBase (6.5) that support nulling Visual Foxpro fields) *)
    Result := f4null(d4fieldJ(FTable.CBDATA4, aField.FieldNo)) = 0;
(*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*)
    d4changed(FTable.CBDATA4, 0); {don't save the changed record}
    {$ENDIF}

    if (Buffer <> nil) and Result then
    begin
      case aField.DataType of
        ftInteger:
          IndexedRecord.GetVFInteger(StartPos, Buffer);
        ftCurrency:
          IndexedRecord.GetVFCurrency(StartPos, Buffer);
        ftDateTime:
          IndexedRecord.GetVFDateTime(StartPos, (toInvalidDatesAsNull in FTable.Options), Buffer, aField, Result);
        ftFloat:
          IndexedRecord.GetVFFloat(StartPos, Buffer);
      end;
    end;
    Exit;  // ready handling VF type
  end;
  case aField.DataType of
    ftMemo, ftBlob:
    begin
      // for memo and blob we only need to know if there is any data. No need for the real data
      if IndexedRecord.BlobData[aField.Offset].State = bsEmpty then {not cached -> get from table}
      begin
        if FTable.InternalFieldLength(aField.FieldNo) = 4 then  // blokno is saved as integer
        begin
        {$IFDEF CLR}
          Result := System.BitConverter.ToInt32(IndexedRecord.RecordContents, StartPos) <> 0;
        {$ELSE}
          Result := Integer(Pointer(Integer(IndexedRecord.RecordContents) + StartPos)^) <> 0;
        {$ENDIF}
        end
        else // blokno is saved as string
        begin
          Result := False;
          for I := FTable.InternalFieldLength(aField.FieldNo)-1 downto 0 do // right aligned normally
          begin
            if not Byte(IndexedRecord.RecordContents[StartPos+I]) in [0..Ord(' '), Ord('0')] then
            begin
              Result := True;
              Break;
            end;
          end;
        end;
      end
      else
        Result := IndexedRecord.BlobData[aField.Offset].Data.Size <> 0;
    end;
    ftWideString:
    begin
      Result := False;
      I := 0;
      while I < FTable.InternalFieldLength(aField.FieldNo) do
      begin
        {$IFDEF CLR}
        if System.BitConverter.ToChar(IndexedRecord.RecordContents, StartPos+I) > ' ' then
        {$ELSE}
        if (PWideChar(Integer(IndexedRecord.RecordContents) + TRecordContents(StartPos)))^ > ' ' then
        {$ENDIF}
        begin
          Result := True;
          Break;
        end;
        Inc(I, 2);
      end;
    end
    else
    begin
      Result := False;
      for I := 0 to FTable.InternalFieldLength(aField.FieldNo)-1 do
      begin
        if Byte(IndexedRecord.RecordContents[StartPos+I]) > Ord(' ') then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
  if Result then
  begin
    if (Buffer <> nil) then
      case aField.DataType of
        ftUnknown: ;
        ftString: IndexedRecord.GetString(StartPos, FTable.InternalFieldLength(aField.FieldNo), Buffer);
        ftSmallint: IndexedRecord.GetSmallInt(StartPos, FTable.InternalFieldLength(aField.FieldNo), Buffer);
        ftBoolean: IndexedRecord.GetBool(StartPos, Buffer);
        ftFloat: IndexedRecord.GetDouble(StartPos, FTable.InternalFieldLength(aField.FieldNo), Buffer, Result);
        ftDate: IndexedRecord.GetDate(StartPos, FTable.InternalFieldLength(aField.FieldNo), toInvalidDatesAsNull in FTable.Options, Buffer, Result);
        ftVarBytes,
        ftBlob, ftMemo,
        ftDBaseOle,
        ftTypedBinary: IndexedRecord.GetEmpty(Buffer);
        ftWideString:  IndexedRecord.GetWideString(StartPos, FTable.InternalFieldLength(aField.FieldNo), Buffer);
      end
    else
      case aField.DataType of
        ftFloat: IndexedRecord.GetDouble(StartPos, FTable.InternalFieldLength(aField.FieldNo), nil, Result);
        ftDate: IndexedRecord.GetDate(StartPos, FTable.InternalFieldLength(aField.FieldNo), toInvalidDatesAsNull in FTable.Options, nil, Result);
      end;
  end;
end;

procedure TCB4RecordBufferList.SetBuffers(Index: TRecordBuffer; Value:
    TCB4RecordBuffer);
begin
  FList[Integer(Index)-1] := Value;
end;

procedure TCB4RecordBufferList.SetField(aIndex: TRecordBuffer; aField: TField;
    Buffer: TValueBuffer);
var
  IndexedRecord: TCB4RecordBuffer;
  StartPos: Integer;
  Len: Integer;
  Err: Integer;
  F4: FIELD4;
begin
  IndexedRecord := Buffers[aIndex];
  StartPos := FTable.FFieldRecPos[aField.FieldNo-1];
//    if (Database.DatabaseType = dtCB4FoxPro) and ((Field.DataType in [ftInteger, ftCurrency, ftDateTime]) or ((Field.DataType = ftFloat) and (Integer(FFieldRecType[Field.FieldNo-1]) = r4double)) ) then
  if (FTable.Database.DatabaseType = dtCB4FoxPro) and (FTable.FFieldRecType[aField.FieldNo-1] in VFNFields) then
  begin
    FTable.CopyRecordBufferToRecord(aIndex); // move RecBuf to CB
    try
      F4 := d4fieldJ(FTable.FCBDATA4, aField.FieldNo);
      if (Buffer = nil) then // set to Null
      begin
        {$IFDEF NOVFNULLSUPPORT}
        DatabaseErrorFmt(SFieldValueError, [aField.FieldName]);
        Err := 0; // remove warning
        {$ELSE}
        f4assignNull(F4); // to let it set null
        Err := code4errorCode(FTable.Database.CBCODE4, 0);
        if Err = e4parm then
        begin
          if FTable.FFieldRecType[aField.FieldNo-1] = byte(r4DateTime) then
          begin
            f4blank(F4); // datetime we set to null even if not supported by blanking the date part
            Err := code4errorCode(FTable.Database.CBCODE4, 0);
          end
          else
          // but when we can't set to null (no VFP or Field not nullable) then codebase generates a e4parm
            DatabaseErrorFmt(SFieldValueError, [aField.FieldName]);
        end;
        {$ENDIF}
      end
      else
      begin
        f4blank(F4); // make sure it is not null anymore     or use F4assign...!!!
        Err := code4errorCode(FTable.Database.CBCODE4, 0);
      end;
      FTable.Check(Err);
    finally
      FTable.CopyRecordToRecordBuffer(aIndex);
      d4changed(FTable.FCBDATA4, 0); {don't save the changed record in CB}
    end;
    if (Buffer <> nil) then
      case aField.DataType of
        ftInteger:
          IndexedRecord.SetVFInteger(StartPos, Buffer);
        ftCurrency:
          IndexedRecord.SetVFCurrency(StartPos, Buffer);
        ftFloat:
          IndexedRecord.SetVFFloat(StartPos, Buffer);
        ftDateTime:
          IndexedRecord.SetVFDateTime(StartPos, Buffer);
      end;
    Exit;
  end;

  Len := FTable.InternalFieldLength(aField.FieldNo);
  {$IFDEF CLR}
  if aField.DataType = ftWideString then
    System.Array.Clear(IndexedRecord.RecordContents, StartPos, Len)
  else
    IndexedRecord.FillRecordContents(StartPos, Len, 32);
  {$ELSE}
  if aField.DataType = ftWideString then
    FillChar(PChar(Integer(IndexedRecord.RecordContents) + StartPos)^, Len, #0)
  else
    FillChar(PChar(Integer(IndexedRecord.RecordContents) + StartPos)^, Len, ' ');
  {$ENDIF}

  if Buffer <> nil then
  begin
    case aField.DataType of
      ftUnknown: ;
      ftString: IndexedRecord.SetString(StartPos, Len, Buffer);
      ftSmallInt: IndexedRecord.SetSmallInt(StartPos, Len, Buffer);
      ftBoolean: IndexedRecord.SetBool(StartPos, Buffer);
      ftFloat: IndexedRecord.SetDouble(StartPos, Len, Buffer, f4decimals(d4fieldJ(FTable.FCBDATA4, aField.FieldNo)));
      ftDate: IndexedRecord.SetDate(StartPos, Len, Buffer);
      ftWideString: IndexedRecord.SetWideString(StartPos, Len, Buffer)
      else
        IndexedRecord.SetEmpty(StartPos, Len, Buffer);
    end;
  end
end;

procedure TCB4RecordBufferList.SetRecBufSize(const Value: Integer);
begin
  if FRecBufSize <> Value then
  begin
    Assert(Count-(FLastFreeIndex+1)=0);
    FRecBufSize := Value;
  end;
end;

const
  S4CLIENT_VAL = $8;
  S4STAND_ALONE_VAL = $80;

initialization
  FDatabases := TStringlist.Create;
  FDatabases.Sorted := False; // False otherwise we can't rename
  FDatabases.Duplicates := dupAccept;
  FDatabasesSync := TMultiReadExclusiveWriteSynchronizer.Create;

  FDefaultDB := nil;

  IsClientServer := (u4switch and S4CLIENT_VAL) <> 0;
//  IsClientServer := True;

finalization

  if Assigned(FDefaultDB) then FDefaultDB.Free;
  FDatabases.Free;
  FDatabasesSync.Free;

end.
