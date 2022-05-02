{
*    Tiriss CB4 Tables
*    (c) MMV Tiriss
*
*    unit: CB4Defs.pas
}

unit CB4Defs;

interface

uses {$IFDEF CLR}Tiriss.Codebase.NetIntf{$ELSE}{$IFDEF TRIAL}CodeBaseIntf{$ELSE}CodeBase{$ENDIF}{$ENDIF};

{next functions are necessary to use any compiled CB4 with any CodeBase.pas}
function DefaultServerId: string;
function DefaultProcessId: string;
function DefaultProtocol: string;
function CBDllName: string;

{resourcestrings from BDEConst}
resourcestring
  SDuplicateDatabaseName = 'Duplicate database name ''%s''';
  SInvalidDatabaseName = 'Invalid database name ''%s''';
  SDatabaseOpen = 'Cannot perform this operation on an open database';
  SDatabaseClosed = 'Cannot perform this operation on a closed database';
  STableMismatch = 'Source and destination tables are incompatible';
  SLoginError = 'Cannot connect to database ''%s''';
  SNoFieldAccess = 'Cannot access field ''%s'' in a filter';
  SIndexDoesNotExist = 'Index does not exist. Index: %s';
  SCompositeIndexError = 'Cannot use array of Field values with Expression Indices';

implementation

function DefaultServerId: string;
begin
  Result := DEF4SERVER_ID;
end;

function DefaultProcessId: string;
begin
  Result := DEF4PROCESS_ID;
end;

function DefaultProtocol: string;
begin
  Result := DEF4PROTOCOL;
end;

function CBDllName: string;
begin
  Result := CBDLL;
end;

end.
