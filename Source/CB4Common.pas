{
*    Tiriss CB4 Tables                                       
*    (c) MMII Tiriss                                      
*
*    ModelName   : CBE
*    Generated   : 27-3-2002 10:55:13
}
{
  This unit is necessary for pre D5 versions!
}

unit CB4Common;

interface

uses Classes, DB;

type
  TLoginEvent = procedure (Sender: TObject; Username, Password: string) of 
     object;
{ TMasterDataLink }

  TMasterDataLink = class (TDataLink)
  private
    FDataSet: TDataSet;
    FFieldNames: string;
    FFields: TList;
    FOnMasterChange: TNotifyEvent;
    FOnMasterDisable: TNotifyEvent;
    procedure SetFieldNames(const Value: string);
  protected
    procedure ActiveChanged; override;
    procedure CheckBrowseMode; override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(DataSet: TDataSet);
    destructor Destroy; override;
    property FieldNames: string read FFieldNames write SetFieldNames;
    property Fields: TList read FFields;
    property OnMasterChange: TNotifyEvent read FOnMasterChange write 
       FOnMasterChange;
    property OnMasterDisable: TNotifyEvent read FOnMasterDisable write 
       FOnMasterDisable;
  end;
  
  TCustomConnection = class (TComponent)
  private
    FAfterConnect: TNotifyEvent;
    FAfterDisconnect: TNotifyEvent;
    FBeforeConnect: TNotifyEvent;
    FBeforeDisconnect: TNotifyEvent;
    FClients: TList;
    FConnectEvents: TList;
    FDataSets: TList;
    FLoginPrompt: Boolean;
    FOnLogin: TLoginEvent;
    FStreamedConnected: Boolean;
  protected
    procedure DoConnect; virtual;
    procedure DoDisconnect; virtual;
    function GetConnected: Boolean; virtual;
    function GetDataSet(Index: Integer): TDataSet; virtual;
    function GetDataSetCount: Integer; virtual;
    procedure Loaded; override;
    procedure RegisterClient(Client: TObject); virtual;
    procedure SendConnectEvent(Connecting: Boolean);
    procedure SetConnected(Value: Boolean); virtual;
    procedure UnRegisterClient(Client: TObject); virtual;
    property StreamedConnected: Boolean read FStreamedConnected write 
       FStreamedConnected;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Close;
    procedure Open;
    property AfterConnect: TNotifyEvent read FAfterConnect write FAfterConnect;
    property AfterDisconnect: TNotifyEvent read FAfterDisconnect write 
       FAfterDisconnect;
    property BeforeConnect: TNotifyEvent read FBeforeConnect write 
       FBeforeConnect;
    property BeforeDisconnect: TNotifyEvent read FBeforeDisconnect write 
       FBeforeDisconnect;
    property Connected: Boolean read GetConnected write SetConnected default 
       False;
    property DataSetCount: Integer read GetDataSetCount;
    property DataSets[Index: Integer]: TDataSet read GetDataSet;
    property LoginPrompt: Boolean read FLoginPrompt write FLoginPrompt default 
       False;
    property OnLogin: TLoginEvent read FOnLogin write FOnLogin;
  end;
  

implementation


uses DBConsts, SysUtils;

{ TMasterDataLink }
{
******************************* TMasterDataLink ********************************
}
constructor TMasterDataLink.Create(DataSet: TDataSet);
begin
  inherited Create;
  FDataSet := DataSet;
  FFields := TList.Create;
end;

destructor TMasterDataLink.Destroy;
begin
  FFields.Free;
  inherited Destroy;
end;

procedure TMasterDataLink.ActiveChanged;
begin
  FFields.Clear;
  if Active then
    try
      DataSet.GetFieldList(FFields, FFieldNames);
    except
      FFields.Clear;
      raise;
    end;
  if FDataSet.Active and not (csDestroying in FDataSet.ComponentState) then
    if Active and (FFields.Count > 0) then
    begin
      if Assigned(FOnMasterChange) then FOnMasterChange(Self);
    end else
      if Assigned(FOnMasterDisable) then FOnMasterDisable(Self);
end;

procedure TMasterDataLink.CheckBrowseMode;
begin
  if FDataSet.Active then FDataSet.CheckBrowseMode;
end;

procedure TMasterDataLink.LayoutChanged;
begin
  ActiveChanged;
end;

procedure TMasterDataLink.RecordChanged(Field: TField);
begin
  if (DataSource.State <> dsSetKey) and FDataSet.Active and
    (FFields.Count > 0) and ((Field = nil) or
    (FFields.IndexOf(Field) >= 0)) and
     Assigned(FOnMasterChange) then
    FOnMasterChange(Self);
end;

procedure TMasterDataLink.SetFieldNames(const Value: string);
begin
  if FFieldNames <> Value then
  begin
    FFieldNames := Value;
    ActiveChanged;
  end;
end;

{
****************************** TCustomConnection *******************************
}
constructor TCustomConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataSets := TList.Create;
  FClients := TList.Create;
  FConnectEvents := TList.Create;
end;

destructor TCustomConnection.Destroy;
begin
  inherited Destroy;
  SetConnected(False);
  FConnectEvents.Free;
  FConnectEvents := nil;
  FClients.Free;
  FClients := nil;
  FDataSets.Free;
  FDataSets := nil;
end;

procedure TCustomConnection.Close;
begin
  SetConnected(False);
end;

procedure TCustomConnection.DoConnect;
begin
end;

procedure TCustomConnection.DoDisconnect;
begin
end;

function TCustomConnection.GetConnected: Boolean;
begin
  Result := False;
end;

function TCustomConnection.GetDataSet(Index: Integer): TDataSet;
begin
  Result := FDataSets[Index];
end;

function TCustomConnection.GetDataSetCount: Integer;
begin
  Result := FDataSets.Count;
end;

procedure TCustomConnection.Loaded;
begin
  inherited Loaded;
  try
    if FStreamedConnected then SetConnected(True);
  except
    on E: Exception do
      if csDesigning in ComponentState then
        ShowException(E, ExceptAddr) else
        raise;
  end;
end;

procedure TCustomConnection.Open;
begin
  SetConnected(True);
end;

procedure TCustomConnection.RegisterClient(Client: TObject);
begin
  FClients.Add(Client);
  //FConnectEvents.Add(TMethod(Event).Code);
  if Client is TDataSet then
    FDataSets.Add(Client);
end;

procedure TCustomConnection.SendConnectEvent(Connecting: Boolean);
var
  I: Integer;
begin
  for I := 0 to FClients.Count - 1 do
  begin
  (*
    if FConnectEvents[I] <> nil then
    begin
      TMethod(ConnectEvent).Code := FConnectEvents[I];
      TMethod(ConnectEvent).Data := FClients[I];
      ConnectEvent(Self, Connecting);
    end;
  *)
  (*
    if TObject(FClients[I]) is TDataset then
      TDataSet(FClients[I]).DataEvent(deConnectChange, Integer(Connecting));
  *)
  end;
end;

procedure TCustomConnection.SetConnected(Value: Boolean);
begin
  if (csReading in ComponentState) and Value then
    FStreamedConnected := True else
  begin
    if Value = GetConnected then Exit;
    if Value then
    begin
      if Assigned(BeforeConnect) then BeforeConnect(Self);
      DoConnect;
      SendConnectEvent(True);
      if Assigned(AfterConnect) then AfterConnect(Self);
    end else
    begin
      if Assigned(BeforeDisconnect) then BeforeDisconnect(Self);
      SendConnectEvent(False);
      DoDisconnect;
      if Assigned(AfterDisconnect) then AfterDisconnect(Self);
    end;
  end;
end;

procedure TCustomConnection.UnRegisterClient(Client: TObject);
var
  Index: Integer;
begin
  if Client is TDataSet then
    FDataSets.Remove(Client);
  Index := FClients.IndexOf(Client);
  if Index <> -1 then
  begin
    FClients.Delete(Index);
  //  FConnectEvents.Delete(Index);
  end;
end;


end.
