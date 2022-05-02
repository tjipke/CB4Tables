{
*    Tiriss CB4 Tables
*    (c) 2000 Tiriss
*
*    Codebase interface unit
*    Specifically designed for CB4 Tables
*    Based on:
*    - CodeBase.pas: (c)Copyright Sequiter Software Inc., 1988-1999.  All rights reserved.
}
unit Tiriss.Codebase.NetIntf;

interface

{$IFDEF LINUX}
uses Libc;
{$ELSE}
uses Windows{$IFDEF CLR}
     , System.Runtime.InteropServices, System.Text
{$ENDIF};
{$ENDIF}

const
{$IFNDEF BCB}
  WM_USER             = $0400;
{$ENDIF}

{$IFDEF LINUX}
  CBDLL = 'libcb.so';      { CodePascal for Linux SO }
{$ELSE}
  CBDLL = 'C4DLL.DLL';      { CodePascal for Windows DLL }
{$ENDIF}

  {*********************************************************************}
  { Field Types }
  {*********************************************************************}
  r4bin       = integer('B') ; { binary field - when using dBASE IV }
  r4double    = integer('B') ; { Double field - when using FoxPro }
  r4str       = integer('C') ; { character field }
  r4date      = integer('D') ; { date field }
  r4float     = integer('F') ; { Floating point field }
  r4gen       = integer('G') ; { General field }
  r4int       = integer('I') ; { Integer field }
  r4log       = integer('L') ; { Logical field }
  r4memo      = integer('M') ; { Memo field }
  r4num       = integer('N') ; { Numeric or Floating Point field }
  r4dateTime  = integer('T') ; { DateTime field }
  r4memoBin   = integer('X') ; { Memo (binary) field }
  r4currency  = integer('Y') ; { Currency field }
  r4charBin   = integer('Z') ; { Character (binary) field }
  r4dateDoub  = integer('d') ; { A date is formatted as a C double }
  r4numDoub   = integer('n') ; { A numeric value is formatted as a C double }
  r4unicode   = integer('W') ; { Unicode character field }

  r4check     = -5 ; { Used for checking the value of CodeBase members }

  {********************************************************************}
  { Return Codes }
  {********************************************************************}
  r4success        =   0;
  r4same           =   0;
  r4found          =   1;  { Primary Key Match }
  r4down           =   1;
  r4after          =   2;
  r4complete       =   2;
  r4eof            =   3;
  r4bof            =   4;
  r4entry          =   5;  { No index file entry or no record (go) }
  r4descending     =  10;
  r4unique         =  20;  { Key is not unique, do not write/append }
  r4uniqueContinue =  25;  { Key is not unique, write/append anyway }
  r4locked         =  50;
  r4noCreate       =  60;  { Could not create file }
  r4noOpen         =  70;  { Could not open file }
  r4noTag          =  80;  { DataIndex::seek, with no default tag }
  r4terminate      =  90;  { no relation match with terminate set }
  r4inactive       = 110;
  r4active         = 120;
  r4authorize      = 140;
  r4connected      = 150;
  r4logOpen        = 170;
  r4logOff         = 180;
  r4null           = 190;

  {********************************************************************}
  { Error Codes }
  {********************************************************************}

  { General Disk Access Errors }
  e4close   = -10 ;
  e4create  = -20 ;
  e4len     = -30 ;
  e4lenSet  = -40 ;
  e4lock    = -50 ;
  e4open    = -60 ;
  e4permiss = -61 ;
  e4access  = -62 ;
  e4numFiles = -63 ;
  e4fileFind = -64 ;
  e4instance = -69 ;
  e4read    = -70 ;
  e4remove  = -80 ;
  e4rename  = -90 ;
  e4unlock  = -110 ;
  e4write   = -120 ;

  { Database Specific Errors }
  e4data      = -200 ;
  e4fieldName = -210 ;    { Invalid field name }
  e4fieldType = -220 ;
  e4recordLen = -230 ;
  e4append    = -240 ;
  e4seek      = -250 ;

  { Index File Specific Errors }
  e4entry   = -300 ;    { Tag entry not located }
  e4index   = -310 ;
  e4tagName = -330 ;
  e4unique  = -340 ;    { Key is not unique }
  e4tagInfo = -350 ;

  { Expression Evaluation Errors }
  e4commaExpected = -400 ;
  e4complete      = -410 ;
  e4dataName      = -420 ;
  e4lengthErr     = -422 ;
  e4notConstant   = -425 ;
  e4numParms      = -430 ;
  e4overflow      = -440 ; { Overflow while evaluating expression }
  e4rightMissing  = -450 ;
  e4typeSub       = -460 ;
  e4unrecFunction = -470 ;
  e4unrecOperator = -480 ;
  e4unrecValue    = -490 ;
  e4unterminated  = -500 ;
  e4tagExpr       = -510 ;

  { Optimization Errors }
  e4opt        = -610 ;
  e4optSuspend = -620 ;
  e4optFlush   = -630 ;

  { Relation Errors }
  e4relate    = -710 ;
  e4lookupErr = -720 ;
  e4relateRefer = -730 ;

  { Severe Errors }
  e4info          = -910 ; { Unexpected information in internal variable }
  e4memory        = -920 ; { Out of memory }
  e4parm          = -930 ; { Unexpected parameter }
  e4parmNull      = -935 ; { NULL input parameter unexpected }
  e4demo          = -940 ; { Exceeded maximum record number for demo }
  e4result        = -950 ; { Unexpected result }
  e4verify        = -960 ; { Structure Verification Failure }
  e4struct        = -970 ; {data structure corrupt or not initialized }

  e4notIindex  = -1010 ; { S4OFF_INDEX  }
  e4notMemo    = -1020 ; { S4OFF_MEMO   }
  e4notRename  = -1030 ; { S4NO_RENAME  }
  e4notWrite   = -1040 ; { S4OFF_WRITE  }
  e4notClipper = -1050 ; { S4CLIPPER    }
  e4notLock    = -1060 ; { S4LOCK_HOOK  }
  e4notHook    = -1070 ; { S4ERROR_HOOK }

  { Not Supported Errors }
  e4notSupported  = -1090 ; { function unsupported }
  e4version       = -1095 ; { application/library version mismatch }

  { Memo Errors }
  e4memoCorrupt = -1110 ; { memo file corrupt }
  e4memoCreate  = -1120 ; { error creating memo file }

  { Transaction Errors }
  e4transViolation   = -1200 ;
  e4trans            = -1210 ;
  e4rollback         = -1220 ;
  e4commit           = -1230 ;
  e4transAppend      = -1240 ;

  { Communication Errors }
  e4corrupt    = -1300 ;
  e4connection = -1310 ;
  e4socket     = -1312 ;
  e4net        = -1330 ;
  e4loadlib    = -1340 ;
  e4timeOut    = -1350 ;
  e4message    = -1360 ;
  e4packetLen  = -1370 ;
  e4packet     = -1380 ;

  { Miscellaneous Errors }
  e4max       = -1400 ;
  e4codeBase  = -1410 ;
  e4name      = -1420 ;
  e4authorize = -1430 ;

  { Server Failure Errors }
  e4server = -2100 ;
  e4config = -2110 ;
  e4cat    = -2120 ;
  { END of errors }

  {********************************************************************}
  { other defines }
  {********************************************************************}
  LOCK4OFF        = 0;
  LOCK4ALL        = 1;
  LOCK4DATA       = 2;
  LOCK4APPEND     = 10;
  LOCK4FILE       = 20;
  LOCK4RECORD     = 30;


  OPEN4DENY_NONE  = 0;
  OPEN4DENY_RW    = 1;
  OPEN4DENY_WRITE = 2;

  OPT4EXCLUSIVE   = -1;
  OPT4OFF         = 0;
  OPT4ALL         = 1;

  LOG4ALWAYS      = 2;
  LOG4ON          = 1;
  LOG4TRANS       = 0;

  SORT4MACHINE    = 0;
  SORT4GENERAL    = 1;

  collate4machine = 1;
  collate4general = 1001;
  collate4special = 1002;

  WAIT4EVER       = -1;

  {********************************************************************}
  { Client-Server switches }
  {********************************************************************}

  DEF4SERVER_ID = 'localhost';  { replace with appropriate value }
  DEF4PROCESS_ID = '23165'; { replace with appropriate value }
  DEF4PROTOCOL = 'S4SOCK.DLL';

  {********************************************************************}
  { End of constants }
  {********************************************************************}

type
  { Define pointers to common types }
//  PDouble           = ^Double ;
//  PLong             = ^Longint ;
//  PInt              = ^Integer ;
//  PPChar            = ^PChar ;
  PVoid             = IntPtr;
//  PPVoid            = ^PVoid ;
//  PWord             = ^Word ;
//  PByte             = ^Byte ;

  { Define CodeBase structure pointers }
  AREA4            = pointer ;
  CODE4            = IntPtr ;
  DATA4            = IntPtr ;
  EXPR4            = IntPtr ;
  EXPR4CALC        = pointer ;
  FIELD4           = IntPtr ;
  GROUP4           = pointer ;
  INDEX4           = IntPtr ;
  LIST4            = pointer ;
  MEMO4FILE        = pointer ;
  OBJ4             = pointer ;
  OBJECT4          = pointer ;
  OPT4             = pointer ;
  RELATE4          = pointer ;
  PRELATE4         = ^RELATE4 ;
  REPORT4          = pointer ;
  STYLE4           = pointer ;
  TAG4             = IntPtr ;
  TAG4FILE         = IntPtr ;
  TOTAL4           = pointer ;

  IntPtrPChar = IntPtr;

  { Declare the FIELD4INFO and TAG4INFO structure }
  [StructLayout(LayoutKind.Sequential, Pack=4)] // pack to 4 needed?
  FIELD4INFO = Record
     name  : IntPtrPChar;
     atype : SmallInt ;
     len   : Word;
     dec   : Word;
    nulls  : Word;
  end;

  PFIELD4INFO = IntPtr;//^FIELD4INFO;

  [StructLayout(LayoutKind.Sequential,Pack=4)]
  TAG4INFO = Record
     name       : IntPtrPChar;
     expression : IntPtrPChar;
     filter     : IntPtrPChar;
     unique     : SmallInt;
     descending : Word;
  end;

  PTAG4INFO = IntPtr; //^TAG4INFO;

var
  S4VERSION: Integer = 6000 ; { default to old}

{  CODE4 members/funtions                                            }

{$IFNDEF CLR}
  function  code4init               : CODE4;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}
  function  code4initUndo           ( p1: CODE4) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  code4tranStatus         ( p1: CODE4 ) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  code4accessMode         ( p1 : CODE4; p2 : Integer ) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  function  code4errorCode          ( p1 : CODE4; p2 : Integer ) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  code4lockDelay          ( p1 : CODE4; p2 : Longint ) : Longint; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;

{$IFDEF CLR}
  [DllImport(CBDLL)]
  function  code4autoOpen( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4compatibility      ( p1: CODE4; p2: Smallint ) : Smallint; external;

  [DllImport(CBDLL)]
  Function  code4connect            ( p1: CODE4; [MarshalAs(UnmanagedType.LPStr)]p2: string; [MarshalAs(UnmanagedType.LPStr)]p3: string; [MarshalAs(UnmanagedType.LPStr)]p4: string; [MarshalAs(UnmanagedType.LPStr)]p5: string; [MarshalAs(UnmanagedType.LPStr)]p6: string) : Integer; external; { TODO : last params can be nil! }
  [DllImport(CBDLL)]
  Function  code4errExpr            ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4errOff             ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4readOnly           ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4singleOpen         ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4lockAttempts       ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4log                ( p1 : CODE4; p2 : Integer ): Integer; external;
  [DllImport(CBDLL)]
  Function  code4logCreate          ( p1: CODE4; p2: IntPtrPChar; p3: IntPtrPChar ) : Integer; overload; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  code4logCreate          ( p1: CODE4; p2: string; p3: IntPtrPChar ) : Integer;  overload; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  code4logCreate          ( p1: CODE4; p2: string; p3: string ) : Integer;  overload; external;
  [DllImport(CBDLL)]
  Function  code4logFileName        ( p1: CODE4 ) : IntPtrPChar;  external;
  [DllImport(CBDLL)]
  Function  code4logOpen            ( p1: CODE4; p2: IntPtrPChar; p3: IntPtrPChar ) : Integer; overload; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  code4logOpen            ( p1: CODE4; p2: string; p3: IntPtrPChar ) : Integer; overload; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  code4logOpen            ( p1: CODE4; p2: string; p3: string) : Integer; overload; external;
  [DllImport(CBDLL)]
  Procedure code4logOpenOff         ( p1: CODE4 ); external;
  [DllImport(CBDLL)]
  Function  code4memSizeMemoExpr    ( p1 : CODE4; p2 : Longint ) : Longint; external;
  [DllImport(CBDLL)]
  function  code4indexExtension     ( p1: CODE4 ) : IntPtrPChar; external;
  [DllImport(CBDLL)]
  Function  code4timeout            ( p1 : CODE4 ) : Longint ; external;
  [DllImport(CBDLL)]
  Procedure code4timeoutSet         ( p1 : CODE4; p2 : Longint ) ; external;
  [DllImport(CBDLL)]
  Function  code4tranCommit         ( p1: CODE4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4tranRollback       ( p1: CODE4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4tranStart          ( p1: CODE4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4unlock             ( p1: CODE4 ) : Integer; external;
{$ELSE}
var
  code4autoOpen           :Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4connect            :Function  ( p1: CODE4; p2: IntPtrPChar; p3: IntPtrPChar; p4: IntPtrPChar; p5: IntPtrPChar; p6: IntPtrPChar ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4errExpr            :Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4errOff             :Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4readOnly           :Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4singleOpen         :Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4lockAttempts       :Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4log                :Function  ( p1 : CODE4; p2 : Integer ): Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4logCreate          :Function  ( p1: CODE4; p2: IntPtrPChar; p3: IntPtrPChar ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4logFileName        :Function  ( p1: CODE4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4logOpen            :Function  ( p1: CODE4; p2: IntPtrPChar; p3: IntPtrPChar ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4logOpenOff         :Procedure ( p1: CODE4 ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4indexExtension     :function  ( p1: CODE4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4timeout            :Function  ( p1 : CODE4 ) : Longint ; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4timeoutSet         :Procedure ( p1 : CODE4; p2 : Longint ) ; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4tranCommit         :Function  ( p1: CODE4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4tranRollback       :Function  ( p1: CODE4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4tranStart          :Function  ( p1: CODE4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4unlock             :Function  ( p1: CODE4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}

{ Data File Functions }
  function  d4appendStart     ( p1 : DATA4; p2 : Integer) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  function  d4go              ( p1 : DATA4; p2 : Longint ) : Integer;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  d4lock            ( p1 : DATA4; p2 : Longint ) : Integer;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$IFNDEF CLR}
  function  d4position        ( p1 : DATA4 ) : Double;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}
  function  d4write           ( p1 : DATA4; p2 : Longint ) : Integer;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;

{$IFDEF CLR}
  [DllImport(CBDLL)]
  Function  d4append          ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4bof             ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4bottom          ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Procedure d4blank           ( p1 : DATA4 ); external;
  [DllImport(CBDLL)]
  Function  d4changed         ( p1 : DATA4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4close           ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  d4create          ( p1 : CODE4; p2 : string; p3 : PFIELD4INFO; p4 : PTAG4INFO ) : DATA4; external;
  [DllImport(CBDLL)]
  Procedure d4delete          ( p1 : DATA4 ); external;
  [DllImport(CBDLL)]
  Function  d4deleted         ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4eof             ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL, EntryPoint = 'd4fieldInfo')]
  procedure  d4fieldInfoNet       ( p1 : DATA4; const p2: FIELD4INFO); external;
  [DllImport(CBDLL, EntryPoint = 'd4fieldInfo')]
  function  d4fieldInfo       ( p1 : DATA4): IntPtr; external;
  [DllImport(CBDLL)]
  Function  d4fieldJ          ( p1 : DATA4; p2 : Integer ) : FIELD4; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi, EntryPoint = 'd4fileName')]
  Function  d4fileNameNET     ( p1 : DATA4 ) : IntPtrPChar; external;

  [DllImport(CBDLL)]
  Function  d4index           ( p1 : DATA4; p2 : IntPtrPChar ) : INDEX4; overload; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  d4index           ( p1 : DATA4; p2 : string ) : INDEX4; overload; external;

  [DllImport(CBDLL)]
  Function  d4memoCompress    ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  d4open            ( p1 : CODE4; [MarshalAs(UnmanagedType.LPStr)]p2 : string) : DATA4; external;
  [DllImport(CBDLL)]
  Function  d4numFields       ( p1 : DATA4 ) : SmallInt; external;
  [DllImport(CBDLL)]
  Function  d4positionSet     ( p1 : DATA4; p2 : Double ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='d4recCountDo')]
  Function  d4recCount        ( p1 : DATA4 ) : Longint;external;
  [DllImport(CBDLL, EntryPoint='d4recNoLow')]
  Function  d4recNo           ( p1 : DATA4 ) : Longint;external;
  [DllImport(CBDLL, EntryPoint='d4recordLow')]
  Function  d4record          ( p1 : DATA4 ) : IntPtrPChar;external;
  [DllImport(CBDLL, EntryPoint='d4recWidthLow')]
  Function  d4recWidth        ( p1 : DATA4 ) : Word;external;
  [DllImport(CBDLL)]
  Function  d4refresh         ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4refreshRecord   ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4remove          ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  d4seek            ( p1 : DATA4; [MarshalAs(UnmanagedType.LPStr)]p2 : string) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4seekDouble      ( p1 : DATA4; p2 : Double ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4seekN           ( p1 : DATA4; p2 : IntPtrPChar; p3: Integer ) : Integer; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  d4seekNext        ( p1 : DATA4; p2 : string) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4seekNextDouble  ( p1 : DATA4; p2 : Double ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4seekNextN       ( p1 : DATA4; p2 : IntPtrPChar; p3: Integer ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4skip            ( p1 : DATA4; p2 : Longint ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4tagSelect       ( p1 : DATA4; p2 : TAG4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4tagSelected     ( p1 : DATA4 ) : TAG4;external;
  [DllImport(CBDLL)]
  Function  d4top             ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4unlock          ( p1 : DATA4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4zap             ( p1 : DATA4; p2, p3 : Longint ) : Integer; external;
{$ELSE}
var
  d4append          :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4bof             :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4bottom          :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4blank           :Procedure ( p1 : DATA4 ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4changed         :Function  ( p1 : DATA4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4close           :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4create          :Function  ( p1 : CODE4; p2 : IntPtrPChar; p3 : PFIELD4INFO; p4 : PTAG4INFO ) : DATA4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4delete          :Procedure ( p1 : DATA4 ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4deleted         :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4eof             :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4fieldInfo       :Function  ( p1 : DATA4 ) : PFIELD4INFO; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4fieldJ          :Function  ( p1 : DATA4; p2 : Integer ) : FIELD4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4fileName        :Function  ( p1 : DATA4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4index           :Function  ( p1 : DATA4; p2 : IntPtrPChar ) : INDEX4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4memoCompress    :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4open            :Function  ( p1 : CODE4; p2 : IntPtrPChar ) : DATA4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4positionSet     :Function  ( p1 : DATA4; p2 : Double ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4recCount        :Function  ( p1 : DATA4 ) : Longint; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4recNo           :Function  ( p1 : DATA4 ) : Longint; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4record          :Function  ( p1 : DATA4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4recWidth        :Function  ( p1 : DATA4 ) : Word; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4refresh         :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4refreshRecord   :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4remove          :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4seek            :Function  ( p1 : DATA4; p2 : IntPtrPChar ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4seekDouble      :Function  ( p1 : DATA4; p2 : Double ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4skip            :Function  ( p1 : DATA4; p2 : Longint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4tagSelect       :Function  ( p1 : DATA4; p2 : TAG4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4tagSelected     :Function  ( p1 : DATA4 ) : TAG4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4top             :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4unlock          :Function  ( p1 : DATA4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4zap             :Function  ( p1 : DATA4; p2, p3 : Longint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}

{ Date Functions }
  procedure date4assign    (p1 : IntPtrPChar; p2 : Longint );// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$IFDEF CLR}
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  date4long      ( p1 : string) : Longint; external;
{$ELSE}
var
  date4long      :Function  ( p1 : IntPtrPChar ) : Longint; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}

{ Error Functions }
{$IFDEF CLR}
  [DllImport(CBDLL)]
  Function  error4text     ( p1 : CODE4; P2 : Longint ) : IntPtrPChar; external;
{$ELSE}
var
  error4text     :Function  ( p1 : CODE4; P2 : Longint ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}

{ Expression Evaluation Functions }
{$IFNDEF CLR}
  function  expr4double     ( p1 : EXPR4 ) : Double; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}
  procedure expr4free       ( p1 : EXPR4 ); //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  expr4len        ( p1 : EXPR4 ) : Integer;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  expr4parse      ( p1 : DATA4; p2 : string) : EXPR4;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  function  expr4type          ( p1 : EXPR4 ) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;

{$IFDEF CLR}
  [DllImport(CBDLL)]
  Function  expr4str        ( p1 : EXPR4 ) : IntPtrPChar; external;
  [DllImport(CBDLL)]
  Function  expr4true       ( p1 : EXPR4 ) : Integer; external;
{$ELSE}
var
  expr4str        :Function  ( p1 : EXPR4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  expr4true       :Function  ( p1 : EXPR4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}

{ Field Functions }
  function  f4null         ( p1 : FIELD4 ) : Integer; //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  procedure f4assignNull   ( p1 : FIELD4 ); //{$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};

{$IFDEF CLR}
  [DllImport(CBDLL)]
  procedure f4blank        ( p1 : FIELD4 ); external;
  [DllImport(CBDLL)]
  Function  f4decimals     ( p1 : FIELD4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  f4memoAssignN  ( p1 : FIELD4; p2 : IntPtrPChar; p3 : Word ) : Integer; external;
  [DllImport(CBDLL)]
  Function  f4memoLen      ( p1 : FIELD4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  f4memoStr      ( p1 : FIELD4 ) : IntPtrPChar; external;
  [DllImport(CBDLL, EntryPoint='f4null')]
  Function  f4nullCB4      ( p1 : FIELD4 ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='f4assignNull')]
  Procedure f4assignNullCB4( p1 : FIELD4 ); external;
{$ELSE}
var
  f4blank        :procedure ( p1 : FIELD4 ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  f4decimals     :Function  ( p1 : FIELD4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  f4memoAssignN  :Function  ( p1 : FIELD4; p2 : IntPtrPChar; p3 : Word ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  f4memoLen      :Function  ( p1 : FIELD4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  f4memoStr      :Function  ( p1 : FIELD4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  f4nullCB4      :Function  ( p1 : FIELD4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  f4assignNullCB4:Procedure ( p1 : FIELD4 ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ENDIF}

{ Index Functions }
{$IFDEF CLR}
  [DllImport(CBDLL)]
  Function  i4close     ( p1 : INDEX4 ) : Integer; external;

  [DllImport(CBDLL)]
  Function  i4create    ( p1 : DATA4; p2 : IntPtrPChar; p3 : PTAG4INFO ) : INDEX4; {0 name -> productn} overload; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  i4create    ( p1 : DATA4; p2 : string; p3 : PTAG4INFO ) : INDEX4; {0 name -> productn} overload; external;

  [DllImport(CBDLL, CharSet = CharSet.Ansi, EntryPoint='i4fileName')]
  Function  i4fileNameNET  ( p1 : INDEX4 ) : IntPtrPChar; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  i4open      ( p1 : DATA4; [MarshalAs(UnmanagedType.LPStr)]p2 : string ) : INDEX4; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  Function  i4tag       ( p1 : INDEX4; [MarshalAs(UnmanagedType.LPStr)]p2 : string ) : TAG4; external;
  [DllImport(CBDLL, EntryPoint='i4tagInfo')]
  function  i4tagInfo   ( p1 : INDEX4): PTAG4INFO; external;
{$ELSE}
var
  i4close     :Function  ( p1 : INDEX4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  i4create    :Function  ( p1 : DATA4; p2 : IntPtrPChar; p3 : PTAG4INFO ) : INDEX4; {0 name -> productn} {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  i4fileName  :Function  ( p1 : INDEX4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  i4open      :Function  ( p1 : DATA4; p2 : IntPtrPChar ) : INDEX4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  i4tag       :Function  ( p1 : INDEX4; p2 : IntPtrPChar ) : TAG4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  i4tagInfo   :Function  ( p1 : INDEX4 ) : PTAG4INFO; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}

{ TAG4 functions }
  function  t4expr           ( p1 : TAG4 ) : string;// {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;

{ Utility Functions }
{$IFDEF CLR}
  [DllImport(CBDLL, EntryPoint='u4freeDefault')]
  Procedure u4free       ( p1 : PVoid ); external;
  [DllImport(CBDLL)]
  Function u4switch     : Longint; external;
{$ELSE}
var
  u4free       :Procedure ( p1 : PVoid ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  u4switch     :Function: Longint; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ENDIF}


{ Non-User Functions }
{$IFDEF CLR}
  [DllImport(CBDLL, EntryPoint='code4initP')]
  Function code4init:           CODE4; external;
  [DllImport(CBDLL, EntryPoint='code4initUndoP')]
  Function  code4initUndoP       ( p1 : CODE4 ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='code4initUndo')]
  Function  code4initUndo1       ( p1 : CODE4 ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='code4tranStatusCB')]
  Function  code4tranStatusP     ( p1: CODE4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  code4accessModeInt   ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='code4accessMode')]
  Function  code4accessModeSmall ( p1 : CODE4; p2 : SmallInt) : SmallInt; external;
  [DllImport(CBDLL, EntryPoint='code4errorCode')]
  Function  code4errorCodeInt    ( p1 : CODE4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='code4errorCode')]
  Function  code4errorCodeSmall  ( p1 : CODE4; p2 : SmallInt) : SmallInt; external;
  [DllImport(CBDLL, EntryPoint='code4lockDelay')]
  function  code4lockDelayInt    ( p1 : CODE4; p2 : Longint ) : Longint;external;
  [DllImport(CBDLL, EntryPoint='code4lockDelay')]
  function  code4lockDelayWord   ( p1 : CODE4; p2 : Word ) : Word;external;

  [DllImport(CBDLL, EntryPoint='d4appendStart')]
  Function  d4appendStartInt     ( p1 : DATA4; p2 : Integer ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='d4appendStart')]
  Function  d4appendStartSmall   ( p1 : DATA4; p2 : SmallInt ) : SmallInt; external;
  [DllImport(CBDLL, EntryPoint='d4go')]
  function  d4goP                ( p1 : DATA4; p2 : Longint ) : Integer; external;
  [DllImport(CBDLL)]
  function  d4goLow              ( p1 : DATA4; p2 : Longint; p3 : Smallint ) : Integer; external;
  [DllImport(CBDLL, EntryPoint='d4lock')]
  function  d4lockP              ( p1 : DATA4; p2 : Longint ) : Integer; external;
  [DllImport(CBDLL)]
  function  d4lockInternal       ( p1 : DATA4; p2 : Longint; p3 : Byte; p4 : Integer ): Integer ; external;
  [DllImport(CBDLL)]
  Function  d4writeP             ( p1 : DATA4; p2 : Longint ) : Integer; external;
  [DllImport(CBDLL)]
  Function  d4writeLow           ( p1 : DATA4; p2 : Longint; p3 : Integer; p4 : Integer ) : Integer; external;

  [DllImport(CBDLL)]
  Procedure date4assignP        ( p1 : IntPtrPChar; p2 : Longint ); external;
  [DllImport(CBDLL)]
  function date4assignLow      ( p1 : IntPtrPChar; p2 : Longint; p3 : Integer ) : Integer; external;
  [DllImport(CBDLL)]
  function expr4double        ( p1 : EXPR4): Double; external;
  [DllImport(CBDLL)]
  function  expr4lenP           ( p1 : EXPR4 ): Integer; external;
  [DllImport(CBDLL)]
  procedure expr4freeCB         ( p1 : EXPR4 ) ; external;

  [DllImport(CBDLL)]
  Function  expr4lenCB            ( p1 : EXPR4 ): ShortInt; external;
  [DllImport(CBDLL, CharSet = CharSet.Ansi)]
  function expr4parseLow       ( p1 : DATA4; p2: string; p3: TAG4FILE ): EXPR4; external;
  [DllImport(CBDLL)]
  Function  expr4typeP            ( p1 : EXPR4 ) : Integer; external;
  [DllImport(CBDLL)]
  Function  expr4typeCB           ( p1 : EXPR4 ): ShortInt;external;
  [DllImport(CBDLL)]
  Function  d4position            ( p1 : DATA4): Double;            external;
  [DllImport(CBDLL, EntryPoint='t4exprCB', CharSet = CharSet.Ansi)]
  Function  t4exprP               ( p1 : TAG4 ) : IntPtrPChar;               external;
{$ELSE}
  code4initP:            Function: CODE4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4initUndoP:        Function  ( p1 : CODE4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4tranStatusP:      Function  ( p1: CODE4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4accessModeInt:    Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4accessModeSmall:  Function  ( p1 : CODE4; p2 : SmallInt) : SmallInt; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4errorCodeInt:     Function  ( p1 : CODE4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4errorCodeSmall:   Function  ( p1 : CODE4; p2 : SmallInt) : SmallInt; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4lockDelayInt:     function  ( p1 : CODE4; p2 : Longint ) : Longint; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  code4lockDelayWord:    function  ( p1 : CODE4; p2 : Word ) : Word; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;

  d4appendStartInt:      Function  ( p1 : DATA4; p2 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  d4appendStartSmall:    Function  ( p1 : DATA4; p2 : SmallInt ) : SmallInt; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  d4goP:                 function  ( p1 : DATA4; p2 : Longint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4goLow:               function  ( p1 : DATA4; p2 : Longint; p3 : Smallint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  d4lockP:               function  ( p1 : DATA4; p2 : Longint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4lockInternal:        function  ( p1 : DATA4; p2 : Longint; p3 : Byte; p4 : Integer ): Integer ; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4writeP:              Function  ( p1 : DATA4; p2 : Longint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4writeLow:            Function  ( p1 : DATA4; p2 : Longint; p3 : Integer; p4 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};

  date4assignP:         Procedure ( p1 : IntPtrPChar; p2 : Longint ); {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  date4assignLow:       function ( p1 : IntPtrPChar; p2 : Longint; p3 : Integer ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  expr4double2:         function ( p1 : EXPR4; p2 : PDouble ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  expr4lenP:            function  ( p1 : EXPR4 ): Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  expr4freeCB:          procedure ( p1 : EXPR4 ) ; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};

  expr4lenCB            :Function  ( p1 : EXPR4 ): ShortInt; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  expr4parseLow:        function ( p1 : DATA4; p2: IntPtrPChar; p3: TAG4FILE ): EXPR4; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  expr4typeP            :Function  ( p1 : EXPR4 ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  expr4typeCB           :Function  ( p1 : EXPR4 ): ShortInt; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  d4position2           :Function  ( p1 : DATA4; p2 : PDouble ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
  t4exprP               :Function  ( p1 : TAG4 ) : IntPtrPChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF} ;
{$ENDIF}


{$IFDEF CLR}
// function only needed for CLR
function  d4fileName( p1 : DATA4 ) : string;
function  i4fileName( p1 : INDEX4 ) : string;
{$ENDIF}

var
  CBVersion: Integer = 0;
  DllPath: string;

implementation

uses SysUtils{$IFDEF LINUX}, QDialogs{$ENDIF};

var
  DllHandle: THandle = 0;


{$IFDEF LINUX}
var
  error4callback: procedure( p1 : CODE4; p2 : Pointer ){$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  error4number2:  Function ( p1 : Longint ) : Integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};

   Procedure errCallback( c4 : CODE4; rc1 : Smallint; rc2 : Longint; s1 : PChar; s2 : PChar; s3 : PChar ); cdecl;
   var
      errStr : string;
   begin
      if code4errOff(c4, r4check) = 0 then
      begin
         errStr := Format('Error #: %d'#10'Error #: %d', [rc1, error4number2(rc2)]);
         errStr := errStr + #10 + error4text(c4, rc1);
         errStr := errStr + #10 + error4text(c4, rc2);
         if s1 <> nil then
            errStr := errStr + #10 + s1;
         if s2 <> nil then
            errStr := errStr + #10 + s2;
         if s3 <> nil then
            errStr := errStr + #10 + s3;

         MessageDlg('CODEBASE ERROR', errStr, mtError, [mbOk], 0);
      end;
   end;


{$ENDIF}

{$IFNDEF CLR}
function code4init : CODE4;
begin
  Result := code4initP;
  {$IFDEF LINUX}
  if Result <> nil then
    error4callback(Result, @errCallback);
  {$ENDIF}
end;
{$ENDIF}

function code4initUndo( p1 : CODE4 ) : Integer;
begin
  if CBVersion < 650 then
    Result := code4initUndoP(p1)
  else
    Result := code4initUndo1( p1 );
end;

function code4tranStatus( p1: CODE4 ) : Integer;
begin
  code4tranStatus := code4tranStatusP( p1 );
end;

function  code4accessMode( p1 : CODE4; p2 : Integer ) : Integer;
begin
  if CBVersion < 650 then
    Result := code4accessModeInt( p1, p2)
  else
    Result := code4accessModeSmall( p1, p2);
end;

function  code4errorCode( p1 : CODE4; p2 : Integer ) : Integer;
begin
  if CBVersion < 650 then
    Result := code4errorCodeInt( p1, p2)
  else
    Result := code4errorCodeSmall( p1, p2);
end;

function code4lockDelay( p1 : CODE4; p2 : Longint ) : Longint;
begin
//  if CBVersion < 650 then
//    Result := code4lockDelayWord( p1, p2)
//  else
    Result := code4lockDelayInt( p1, p2);
end;

function d4appendStart( p1 : DATA4; p2 : Integer) : Integer;
begin
  if CBVersion < 650 then
    Result := d4appendStartInt( p1, p2)
  else
    Result := d4appendStartSmall( p1, p2);
end;

function d4go( p1 : DATA4; p2 : Longint ) : Integer;
begin
  if CBVersion < 650 then
    Result := d4goP( p1, p2)
  else
    Result := d4goLow( p1, p2, 1 );
end;

function d4lock( p1 : DATA4; p2 : Longint ) : Integer;
begin
  if CBVersion < 650 then
    Result := d4lockP( p1, p2)
  else
    Result := d4lockInternal( p1, p2, 1, 1 );
end;

{$IFNDEF CLR}
function d4position( p1 : DATA4 ) : Double;
var
   d : Double;
begin
   d4position2( p1, @d );
   Result := d;
end;
{$ENDIF}

function d4write( p1: DATA4; p2: Longint ): Integer;
begin
  if CBVersion < 650 then
    Result := d4writeP( p1, p2 )
  else
    Result := d4writeLow(p1,p2,0,1);
end;

procedure date4assign( p1 : IntPtrPChar; p2 : Longint );
begin
  if CBVersion < 650 then
    date4assignP( p1, p2)
  else
    date4assignLow( p1, p2, 0 )
end;

{$IFNDEF CLR}
function expr4double( p1 : EXPR4 ) : Double;
var
  d : Double;
begin
  expr4double2( p1, @d );
  Result := d;
end;
{$ENDIF}

procedure expr4free( p1: EXPR4 );
begin
  if CBVersion < 652 then
    u4free( p1 )
  else
    expr4freeCB( p1);
end;

function  expr4len( p1: EXPR4 ): Integer;
begin
  if CBVersion < 650 then
    Result := expr4lenP( p1 )
  else
    Result := expr4lenCB( p1 )
end;

function  expr4parse( p1 : DATA4; p2 : string) : EXPR4;
begin
  {$IFDEF CLR}
  Result := expr4parseLow( p1, p2, nil );
  {$ELSE}
  Result := expr4parseLow( p1, PChar(p2), nil );
  {$ENDIF}
end;

function  expr4type( p1 : EXPR4 ) : Integer;
begin
  if CBVersion < 650 then
    Result := expr4typeP( p1 )
  else
    Result := expr4typeCB( p1 );
end;

function  f4null( p1 : FIELD4 ) : Integer;
begin
  if CBVersion < 650 then
    Result := 0 // always asume not null
  else
    Result := f4nullCB4(p1);
end;

procedure f4assignNull( p1 : FIELD4 );
begin
  if CBVersion < 650 then
    // don't do anything
  else
    f4assignNullCB4(p1);
end;

function t4expr( p1 : TAG4 ) : string;
begin
  {$IFDEF CLR}
  Result := Marshal.PtrToStringAnsi(t4exprP( p1 ));
  {$ELSE}
  Result := t4exprP( p1 );
  {$ENDIF}
end;

{$IFDEF CLR}
// function only needed for CLR
function  d4fileName( p1 : DATA4 ) : string;
begin
  Result := Marshal.PtrToStringAnsi(d4fileNameNET(p1));
end;
function  i4fileName( p1 : INDEX4 ) : string;
begin
  Result := Marshal.PtrToStringAnsi(i4fileNameNET(p1));
end;
{$ENDIF}

{$IFDEF LINUX}
function GetCheckedProcAddress(Module: HMODULE; Proc: PChar): Pointer;
{$ELSE}
{$IFDEF CLR}
function GetCheckedProcAddress(Module: HMODULE; Proc: string): FARPROC;
{$ELSE}
function GetCheckedProcAddress(Module: HMODULE; Proc: LPCSTR): FARPROC;
{$ENDIF}
{$ENDIF}
begin
  Result := GetProcAddress(Module, Proc);
  if Result = nil then raise Exception.CreateFmt('External proc ''%s'' not found in %s', [string(Proc), CBDLL]);
end;

var
  DllPathS: StringBuilder;
initialization
  DllHandle := LoadLibrary(CBDLL);
{$IFDEF LINUX}
  if DLLHandle = 0 then
{$ELSE}
  if DLLHandle < HINSTANCE_ERROR then
{$ENDIF}
    raise Exception.Create('Could not load '+CBDLL);

{$IFDEF CLR}
  DllPathS := System.Text.StringBuilder.Create(MAX_PATH);
  DllPathS.Length := GetModuleFilename(DllHandle, DllPathS, DllPathS.Capacity);
  DllPath := DllPathS.ToString;
{$ELSE}
  SetLength(DllPath, 250);
  SetLength(DllPath, GetModuleFilename(DllHandle, DllPath, Length(DllPath)));
{$ENDIF}

  // determine CB version
  CBVersion := 630; //oldest we support
  if GetProcAddress(DLLHandle, 'code4largeOn') <> nil then {only in cb64 (and higher)}
  begin
    CBVersion := 640;
    S4VERSION := 6401;
  end;
  if GetProcAddress(DLLHandle, 'code4compatibility') <> nil then {only in cb65 (and higher)}
  begin
    CBVersion := 650;
    S4VERSION := 6500;
  end;
  if GetProcAddress(DLLHandle, 'd4codePage') <> nil then {only in cb651 (and higher)}
  begin
    CBVersion := 651;
    S4VERSION := 6500;
  end;
  if GetProcAddress(DLLHandle, 'expr4freeCB') <> nil then {only in cb652 (and higher) (I think it was already in 652 at least in linux!}
  begin
    CBVersion := 652;
    S4VERSION := 6500;
  end;

{$IFNDEF CLR}
  @code4initP := GetCheckedProcAddress(DllHandle, 'code4initP');
  if CBVersion < 650 then
  begin
    @code4initUndoP := GetCheckedProcAddress(DllHandle, 'code4initUndoP');
    @code4tranStatusP := GetCheckedProcAddress(DllHandle, 'code4tranStatusP')
  end
  else
  begin
    @code4initUndoP := GetCheckedProcAddress(DllHandle, 'code4initUndo');
    @code4tranStatusP := GetCheckedProcAddress(DllHandle, 'code4tranStatusCB')
  end;
  if CBVersion < 650 then
  begin
    @code4accessModeInt := GetCheckedProcAddress(DllHandle, 'code4accessMode');
    @code4errorCodeInt  := GetCheckedProcAddress(DllHandle, 'code4errorCode');
    @code4lockDelayWord := GetCheckedProcAddress(DllHandle, 'code4lockDelay');
    @code4lockDelayInt     := GetCheckedProcAddress(DllHandle, 'code4lockDelay');
  end
  else
  begin
    @code4accessModeSmall := GetCheckedProcAddress(DllHandle, 'code4accessMode');
    @code4errorCodeSmall  := GetCheckedProcAddress(DllHandle, 'code4errorCode');
    @code4lockDelayInt     := GetCheckedProcAddress(DllHandle, 'code4lockDelay');
  end;

  @code4autoOpen            := GetCheckedProcAddress(DllHandle, 'code4autoOpen');
  @code4connect         := GetCheckedProcAddress(DllHandle, 'code4connect');
  @code4errExpr             := GetCheckedProcAddress(DllHandle, 'code4errExpr');
  @code4errOff              := GetCheckedProcAddress(DllHandle, 'code4errOff');
  @code4log                 := GetCheckedProcAddress(DllHandle, 'code4log');
  @code4logCreate       := GetCheckedProcAddress(DllHandle, 'code4logCreate');
  @code4logFileName     := GetCheckedProcAddress(DllHandle, 'code4logFileName');
  @code4logOpen         := GetCheckedProcAddress(DllHandle, 'code4logOpen');
  @code4logOpenOff      := GetCheckedProcAddress(DllHandle, 'code4logOpenOff');
  @code4lockAttempts    := GetCheckedProcAddress(DllHandle, 'code4lockAttempts');
  @code4indexExtension := GetCheckedProcAddress(DllHandle, 'code4indexExtension');
  @code4readOnly            := GetCheckedProcAddress(DllHandle, 'code4readOnly');
  @code4singleOpen          := GetCheckedProcAddress(DllHandle, 'code4singleOpen');
  @code4timeout             := GetCheckedProcAddress(DllHandle, 'code4timeout');
  @code4timeoutSet          := GetCheckedProcAddress(DllHandle, 'code4timeoutSet');
  @code4tranCommit      := GetCheckedProcAddress(DllHandle, 'code4tranCommit');
  @code4tranRollback    := GetCheckedProcAddress(DllHandle, 'code4tranRollback');
  @code4tranStart       := GetCheckedProcAddress(DllHandle, 'code4tranStart');
  @code4unlock          := GetCheckedProcAddress(DllHandle, 'code4unlock');

  @d4position2 := GetCheckedProcAddress(DllHandle, 'd4position2');
  if CBVersion < 650 then
  begin
    @d4writeP := GetCheckedProcAddress(DllHandle, 'd4writeP');
    @d4recNo                  := GetCheckedProcAddress(DllHandle, 'd4recNo');
    @d4record                 := GetCheckedProcAddress(DllHandle, 'd4record');
    @d4recWidth               := GetCheckedProcAddress(DllHandle, 'd4recWidth');
    @d4goP                    := GetCheckedProcAddress(DllHandle, 'd4go');
    @d4lockP                  := GetCheckedProcAddress(DllHandle, 'd4lock');
    @d4appendStartInt         := GetCheckedProcAddress(DllHandle, 'd4appendStart');
  end
  else
  begin
    @d4writeLow := GetCheckedProcAddress(DllHandle, 'd4writeLow');
    @d4recNo                  := GetCheckedProcAddress(DllHandle, 'd4recNoLow');
    @d4record                 := GetCheckedProcAddress(DllHandle, 'd4recordLow');
    @d4recWidth               := GetCheckedProcAddress(DllHandle, 'd4recWidthLow');
    @d4goLow                  := GetCheckedProcAddress(DllHandle, 'd4goLow');
    @d4lockInternal           := GetCheckedProcAddress(DllHandle, 'd4lockInternal');
    @d4appendStartSmall       := GetCheckedProcAddress(DllHandle, 'd4appendStart');
  end;
  if CBVersion < 640 then
    @d4tagSelect              := GetCheckedProcAddress(DllHandle, 'd4tagSelect')
  else
    @d4tagSelect              := GetCheckedProcAddress(DllHandle, 'd4tagSelectP');

  @d4append                 := GetCheckedProcAddress(DllHandle, 'd4append');
  @d4bof                    := GetCheckedProcAddress(DllHandle, 'd4bof');
  @d4bottom                 := GetCheckedProcAddress(DllHandle, 'd4bottom');
  @d4blank                 := GetCheckedProcAddress(DllHandle, 'd4blank');
  @d4changed                := GetCheckedProcAddress(DllHandle, 'd4changed');
  @d4close                  := GetCheckedProcAddress(DllHandle, 'd4close');
  @d4create                 := GetCheckedProcAddress(DllHandle, 'd4create');
  @d4delete                 := GetCheckedProcAddress(DllHandle, 'd4delete');
  @d4deleted                := GetCheckedProcAddress(DllHandle, 'd4deleted');
  @d4eof                    := GetCheckedProcAddress(DllHandle, 'd4eof');
  @d4fieldInfo              := GetCheckedProcAddress(DllHandle, 'd4fieldInfo');
  @d4fieldJ                 := GetCheckedProcAddress(DllHandle, 'd4fieldJ');
  @d4fileName               := GetCheckedProcAddress(DllHandle, 'd4fileName');
  @d4index                  := GetCheckedProcAddress(DllHandle, 'd4index');
  @d4memoCompress           := GetCheckedProcAddress(DllHandle, 'd4memoCompress');
  @d4open                   := GetCheckedProcAddress(DllHandle, 'd4open');
  @d4positionSet            := GetCheckedProcAddress(DllHandle, 'd4positionSet');
  @d4recCount               := GetCheckedProcAddress(DllHandle, 'd4recCountDo');
  @d4refresh                := GetCheckedProcAddress(DllHandle, 'd4refresh');
  @d4refreshRecord          := GetCheckedProcAddress(DllHandle, 'd4refreshRecord');
  @d4remove                 := GetCheckedProcAddress(DllHandle, 'd4remove');
  @d4seek                   := GetCheckedProcAddress(DllHandle, 'd4seek');
  @d4seekDouble             := GetCheckedProcAddress(DllHandle, 'd4seekDouble');
  @d4skip                   := GetCheckedProcAddress(DllHandle, 'd4skip');
  @d4tagSelected            := GetCheckedProcAddress(DllHandle, 'd4tagSelected');
  @d4top                    := GetCheckedProcAddress(DllHandle, 'd4top');
  @d4unlock                 := GetCheckedProcAddress(DllHandle, 'd4unlock');
  @d4zap                    := GetCheckedProcAddress(DllHandle, 'd4zap');

  if CBVersion < 650 then
  begin
    @date4assignP           := GetCheckedProcAddress(DllHandle, 'date4assign');
    @expr4lenP              := GetCheckedProcAddress(DllHandle, 'expr4lenP');
    @expr4typeP             := GetCheckedProcAddress(DllHandle, 'expr4typeP');
    @t4exprP                := GetCheckedProcAddress(DllHandle, 't4exprP');
  end
  else
  begin
    @date4assignLow         := GetCheckedProcAddress(DllHandle, 'date4assignLow');
    @expr4lenCB             := GetCheckedProcAddress(DllHandle, 'expr4lenCB');
    @expr4typeCB            := GetCheckedProcAddress(DllHandle, 'expr4typeCB');
    @t4exprP                := GetCheckedProcAddress(DllHandle, 't4exprCB');
    @f4nullCB4              := GetCheckedProcAddress(DllHandle, 'f4null');
    @f4assignNullCB4        := GetCheckedProcAddress(DllHandle, 'f4assignNull');
  end;
  @date4long                := GetCheckedProcAddress(DllHandle, 'date4long');

  @error4text               := GetCheckedProcAddress(DllHandle, 'error4text');

  @expr4double2             := GetCheckedProcAddress(DllHandle, 'expr4double2');
  @expr4parseLow            := GetCheckedProcAddress(DllHandle, 'expr4parseLow');
  @expr4str                 := GetCheckedProcAddress(DllHandle, 'expr4str');
  @expr4true                := GetCheckedProcAddress(DllHandle, 'expr4true');

  @f4blank                  := GetCheckedProcAddress(DllHandle, 'f4blank');
  @f4decimals               := GetCheckedProcAddress(DllHandle, 'f4decimals');
  @f4memoAssignN            := GetCheckedProcAddress(DllHandle, 'f4memoAssignN');
  @f4memoLen                := GetCheckedProcAddress(DllHandle, 'f4memoLen');
  @f4memoStr                := GetCheckedProcAddress(DllHandle, 'f4memoStr');

  @i4close                := GetCheckedProcAddress(DllHandle, 'i4close');
  @i4create               := GetCheckedProcAddress(DllHandle, 'i4create');
  @i4fileName             := GetCheckedProcAddress(DllHandle, 'i4fileName');
  @i4open                 := GetCheckedProcAddress(DllHandle, 'i4open');
  @i4tag                  := GetCheckedProcAddress(DllHandle, 'i4tag');
  @i4tagInfo              := GetCheckedProcAddress(DllHandle, 'i4tagInfo');

  @u4free                 := GetCheckedProcAddress(DllHandle, 'u4freeDefault');
  if CBVersion >= 652 then
  begin
    @expr4freeCB          := GetCheckedProcAddress(DllHandle, 'expr4freeCB');
  end;

  @u4switch               := GetCheckedProcAddress(DllHandle, 'u4switch');

  {$IFDEF LINUX}
  @error4callback         := GetCheckedProcAddress(DllHandle, 'error4callback');
  @error4number2          := GetCheckedProcAddress(DllHandle, 'error4number2');
  {$ENDIF}
  {$ENDIF}
end.
