{
*    Tiriss CB4 Tables                                       
*    (c) MMII Tiriss                                      
*
*    ModelName   : CBE
*    Generated   : 27-3-2002 10:54:58
}

unit CB4D5Prop;
// Unit for usage in Delphi 5 and CBuilder 5 (different design time func) 

interface

uses SysUtils, Classes, DB, CB4Tables, Windows,
    FldLinks, Graphics, dsndb, ParentageSupport, 
    DsgnIntf, CB4Reg;  

type
{ Property Editors }
  TAboutPropertyD5 = class (TCompatibleAboutProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetName: string; override;
    procedure PropDrawName(Canvas: TCanvas; const Rect: TRect; Selected: 
       Boolean); override;
  end;
  
  TDefaultCB4DatabaseSprigD5 = class (TSprigAtRoot)
  public
    function Caption: string; override;
    function ItemClass: TClass; override;
    function Transient: Boolean; override;
    function UniqueName: string; override;
  end;
  
  TImpliedCB4DatabaseSprigD5 = class (TSprigAtRoot)
  private
    FDatabaseName: string;
  public
    function Caption: string; override;
    function ItemClass: TClass; override;
    function Transient: Boolean; override;
    function UniqueName: string; override;
  end;
  
  TCB4DatabaseSprigD5 = class (TSprigAtRoot)
  public
    function AnyProblems: Boolean; override;
    function Caption: string; override;
    function Name: string; override;
  end;
  
  TCB4TableSprigD5 = class (TDataSetSprig)
  public
    function AnyProblems: Boolean; override;
    function Caption: string; override;
    function DragDropTo(AItem: TSprig): Boolean; override;
    function DragOverTo(AItem: TSprig): Boolean; override;
    procedure FigureParent; override;
    class function PaletteOverTo(AParent: TSprig; AClass: TClass): Boolean;
       override;
  end;


implementation

{
******************************* TAboutPropertyD5 *******************************
}
function TAboutPropertyD5.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paFullWidthName];
end;

function TAboutPropertyD5.GetName: string;
begin
  Result := GetAboutTxt;
end;

procedure TAboutPropertyD5.PropDrawName(Canvas: TCanvas; const Rect: TRect; 
   Selected: Boolean);
var
  Style: TFontStyles;
begin
  Style := Canvas.Font.Style;
  Canvas.Font.Style := Style + [fsBold];
  try
    inherited;
  finally
    Canvas.Font.Style := Style;
  end;
end;


const
  cDefaultDatabaseSprigName = '<DefaultDatabase>'; { do not localize }
  cImpliedCB4DatabaseSprigPrefix =  '<ImpliedDatabase>'; { do not localize }

function SprigCB4DatabaseName(const AName: string): string;
begin
  Result := AName;
  if (Result = '') or
     AnsiSameText(Result, DefaultDB.DatabaseName) then
    Result := cDefaultDatabaseSprigName;
end;

function SprigCB4ImpliedDatabaseName(const AName: string): string;
begin
  Result := Format('%s.%s', [cImpliedCB4DatabaseSprigPrefix, AName]); { do not localize }
end;

{
************************** TDefaultCB4DatabaseSprigD5 **************************
}
function TDefaultCB4DatabaseSprigD5.Caption: string;
begin
  Result := CaptionFor(DefaultDB.DatabaseName, 'Default Database')
end;

function TDefaultCB4DatabaseSprigD5.ItemClass: TClass;
begin
  Result := TCB4Database;
end;

function TDefaultCB4DatabaseSprigD5.Transient: Boolean;
begin
  Result := True;
end;

function TDefaultCB4DatabaseSprigD5.UniqueName: string;
begin
  Result := cDefaultDatabaseSprigName;
end;

{
************************** TImpliedCB4DatabaseSprigD5 **************************
}
function TImpliedCB4DatabaseSprigD5.Caption: string;
begin
  Result := CaptionFor(FDatabaseName, 'Implied Database'); { do not localize }
end;

function TImpliedCB4DatabaseSprigD5.ItemClass: TClass;
begin
  Result := TCB4Database;
end;

function TImpliedCB4DatabaseSprigD5.Transient: Boolean;
begin
  Result := True;
end;

function TImpliedCB4DatabaseSprigD5.UniqueName: string;
begin
  Result := SprigCB4ImpliedDatabaseName(FDatabaseName);
end;

{
***************************** TCB4DatabaseSprigD5 ******************************
}
function TCB4DatabaseSprigD5.AnyProblems: Boolean;
begin
  Result := (TCB4Database(Item).DatabaseName = '');
end;

function TCB4DatabaseSprigD5.Caption: string;
begin
  Result := CaptionFor(TCB4Database(Item).DatabaseName, UniqueName);
end;

function TCB4DatabaseSprigD5.Name: string;
begin
  Result := TCB4Database(Item).DatabaseName;
end;

{
******************************* TCB4TableSprigD5 *******************************
}
function TCB4TableSprigD5.AnyProblems: Boolean;
begin
  Result := (TCB4Table(Item).TableName = '');
end;

function TCB4TableSprigD5.Caption: string;
begin
  Result := CaptionFor(TCB4Table(Item).TableName, UniqueName);
end;

function TCB4TableSprigD5.DragDropTo(AItem: TSprig): Boolean;
begin
  if AItem is TImpliedCB4DatabaseSprigD5 then
  begin
    Result := True;
    TCB4Table(Item).DatabaseName := TImpliedCB4DatabaseSprigD5(AItem).FDatabaseName;
  end
  else if AItem is TCB4DatabaseSprigD5 then
  begin
    Result := True;
    TCB4Table(Item).DatabaseName := TCB4Database(AItem.Item).DatabaseName;
  end
  else
    Result := False;
end;

function TCB4TableSprigD5.DragOverTo(AItem: TSprig): Boolean;
begin
  Result := ((AItem is TCB4DatabaseSprigD5) and (TCB4Database(AItem.Item).DatabaseName <> '')) or
            (AItem is TImpliedCB4DatabaseSprigD5);
end;

procedure TCB4TableSprigD5.FigureParent;
var
  vDatabaseName: string;
  vDatabase: TSprig;
begin
  with TCB4Table(Item) do
  begin
    // find real or default session
    vDatabaseName := SprigCB4DatabaseName(DatabaseName);
    vDatabase := Root.Find(vDatabaseName, False);
  
    // if not found see if its the default session
    if (vDatabase = nil) and
       (vDatabaseName = cDefaultDatabaseSprigName) then
      vDatabase := Root.Add(TDefaultCB4DatabaseSprigD5.Create(nil));
  
    if vDatabase = nil then
    begin
      vDatabase := Root.Find(SprigCB4ImpliedDatabaseName(DatabaseName), False);
  
      // if not make an implied session
      if vDatabase = nil then
      begin
        vDatabase := Root.Add(TImpliedCB4DatabaseSprigD5.Create(nil));
        TImpliedCB4DatabaseSprigD5(vDatabase).FDatabaseName := DatabaseName;
      end;
    end;
  
    // set parent to the database
    vDatabase.Add(Self);
  end;
end;

class function TCB4TableSprigD5.PaletteOverTo(AParent: TSprig; AClass: TClass): 
   Boolean;
begin
  Result := ((AParent is TCB4DatabaseSprigD5) and (TCB4Database(AParent.Item).DatabaseName <> '')) or
            (AParent is TImpliedCB4DatabaseSprigD5);
end;


initialization
finalization
end.
