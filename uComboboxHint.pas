unit uComboboxHint;

interface

uses
  cxGraphics, cxControls, cxLookAndFeels, cxHint, dxCustomHint, cxClasses,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxDropDownEdit,
  cxTextEdit, cxMaskEdit, cxImageComboBox, dxScreenTip,
  
  
  
  
  
  
  
  
  
  
  System.Classes, Vcl.ExtCtrls, System.SysUtils, System.Types, Vcl.Forms;

const
  CONSTHINTDISPLAYPAUSE     = 100;
  CONSTHINTDISPLAYDURATION  = 2000;

type
  TcxComboboxHint = class(TcxComboBox)
  private
    FTimerShow: TTimer;
    FTimerHide: TTimer;
    FHintStyleController: TcxHintStyleController;
    FPopupWindow: TcxComboBoxPopupWindow;
    FDestPoint: TPoint;
    FHint: string;
    FComboboxPropertiesPopupEvent: TNotifyEvent;
    FScrollHEnabled: Boolean;
    FHintOnlyOnHiddenText: Boolean;
    FX, FY: Integer;
    function GetHintDisplayPause: Integer;
    procedure SetHintDisplayPause(aPause: Integer);
    function GetHintDisplayDuration: Integer;
    procedure SetHintDisplayDuration(aDuration: Integer);
    procedure TimerHideTimer(Sender: TObject);
    procedure TimerShowTimer(Sender: TObject);
    procedure DoComboBoxPropertiesPopup(Sender: TObject);
    procedure PopUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PopUpMouseLeave(Sender: TObject);
    property PopupWindow;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ComboboxPropertiesPopup: TNotifyEvent read FComboboxPropertiesPopupEvent;
    property HintDisplayPause: Integer read GetHintDisplayPause write SetHintDisplayPause;
    property HintDisplayDuration: Integer read GetHintDisplayDuration write SetHintDisplayDuration;
    property ScrollHEnabled: Boolean read FScrollHEnabled write FScrollHEnabled;
    property HintOnlyOnHiddenText: Boolean read FHintOnlyOnHiddenText write FHintOnlyOnHiddenText;
  end;

  TcxComboBox = class(TcxComboBoxHint)
  end;

  TcxImageComboBoxHint = class(TcxImageComboBox)
  private
    FTimerShow: TTimer;
    FTimerHide: TTimer;
    FHintStyleController: TcxHintStyleController;
    FPopupWindow: TcxComboBoxPopupWindow;
    FDestPoint: TPoint;
    FHint: string;
    FComboboxPropertiesPopupEvent: TNotifyEvent;
    FScrollHEnabled: Boolean;
    FHintOnlyOnHiddenText: Boolean;
    FX, FY: Integer;
    function GetHintDisplayPause: Integer;
    procedure SetHintDisplayPause(aPause: Integer);
    function GetHintDisplayDuration: Integer;
    procedure SetHintDisplayDuration(aDuration: Integer);
    procedure TimerHideTimer(Sender: TObject);
    procedure TimerShowTimer(Sender: TObject);
    procedure DoComboBoxPropertiesPopup(Sender: TObject);
    procedure PopUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PopUpMouseLeave(Sender: TObject);
    property PopupWindow;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ComboboxPropertiesPopup: TNotifyEvent read FComboboxPropertiesPopupEvent;
    property HintDisplayPause: Integer read GetHintDisplayPause write SetHintDisplayPause;
    property HintDisplayDuration: Integer read GetHintDisplayDuration write SetHintDisplayDuration;
    property ScrollHEnabled: Boolean read FScrollHEnabled write FScrollHEnabled;
    property HintOnlyOnHiddenText: Boolean read FHintOnlyOnHiddenText write FHintOnlyOnHiddenText;
  end;

  TcxImageComboBox = class(TcxImageComboBoxHint)
  end;

implementation

{ TcxComboboxHint }

constructor TcxComboboxHint.Create(AOwner: TComponent);
begin
  inherited;
  Properties.OnPopup := DoComboBoxPropertiesPopup;
  FComboboxPropertiesPopupEvent := DoComboBoxPropertiesPopup;
  FHintStyleController := TcxHintStyleController.Create(nil);
  FHintStyleController.Global := False;
  FTimerShow := TTimer.Create(nil);
  FTimerShow.Enabled := False;
  FTimerShow.Interval := CONSTHINTDISPLAYPAUSE;
  FTimerShow.OnTimer := TimerShowTimer;
  FTimerHide := TTimer.Create(nil);
  FTimerHide.Enabled := False;
  FTimerHide.Interval := CONSTHINTDISPLAYDURATION;
  FTimerHide.OnTimer := TimerHideTimer;
  FScrollHEnabled := False;
  FHintOnlyOnHiddenText := True;
end;

destructor TcxComboboxHint.Destroy;
begin
  FreeAndNil(FTimerHide);
  FreeAndNil(FTimerShow);
  FreeAndNil(FHintStyleController);
  FPopupWindow := nil;
  inherited;
end;

procedure TcxComboboxHint.TimerHideTimer(Sender: TObject);
begin
  FTimerHide.Enabled := False;
  FPopupWindow.Hint := '';
  FHintStyleController.HideHint;
end;

procedure TcxComboboxHint.TimerShowTimer(Sender: TObject);
begin
  FTimerShow.Enabled := False;
  FTimerHide.Enabled := False;
  FHintStyleController.ShowHint(FDestPoint.X + 15, FDestPoint.Y - 10, '', FHint);
  FTimerHide.Enabled := True;
end;

procedure TcxComboboxHint.DoComboBoxPropertiesPopup(Sender: TObject);
begin
  TcxComboBoxListBox(PopupWindow.Controls[0]).OnMouseMove := PopUpMouseMove;
end;

procedure TcxComboboxHint.PopUpMouseLeave(Sender: TObject);
begin
  FTimerShow.Enabled := False;
  FTimerHide.Enabled := False;
  FPopupWindow.Hint := '';
  FHintStyleController.HideHint;
end;

procedure TcxComboboxHint.PopUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  listBox: TcxComboBoxListBox;
  index: Integer;
begin
  if (X = FX) and (Y = FY) then
    Exit;
  FX := X;
  FY := Y;
  listBox := TcxEditListBoxContainer(Sender).InnerControl as TcxComboBoxListBox;
  listBox.OnMouseLeave := PopUpMouseLeave;
  if not FScrollHEnabled then
    listBox.ScrollWidth := 0;
  index := listBox.ItemAtPos(Point(X, Y), True);
  if index > -1 then
    begin
      FPopupWindow := TcxEditListBoxContainer(Sender).Parent as TcxComboBoxPopupWindow;
      FHint := TcxComboBox(FPopupWindow.Edit).Properties.Items[index];
      if FPopupWindow.Hint = FHint then
        Exit;
      FPopupWindow.Hint := FHint;
      FHintStyleController.HideHint;
      FDestPoint := FPopupWindow.ClientToScreen(Point(X, Y));
      if (TcxComboBox(Sender).Canvas.TextWidth(FHint) + 4 < listBox.ClientWidth) and FHintOnlyOnHiddenText then
        FTimerShow.Enabled := False
      else
        FTimerShow.Enabled := True;
    end
  else
    FHintStyleController.HideHint;
end;

function TcxComboboxHint.GetHintDisplayPause: Integer;
begin
  Result := FTimerShow.Interval;
end;

procedure TcxComboboxHint.SetHintDisplayPause(aPause: Integer);
begin
  if aPause = 0 then // если значение 0, то таймер никогда не запустится
    aPause := 1;
  FTimerShow.Interval := aPause;
end;

function TcxComboboxHint.GetHintDisplayDuration: Integer;
begin
  Result := FTimerHide.Interval;
end;

procedure TcxComboboxHint.SetHintDisplayDuration(aDuration: Integer);
begin
  FTimerHide.Interval := aDuration;
end;

{ TcxImageComboBoxHint }

constructor TcxImageComboBoxHint.Create(AOwner: TComponent);
begin
  inherited;
  Properties.OnPopup := DoComboBoxPropertiesPopup;
  FComboboxPropertiesPopupEvent := DoComboBoxPropertiesPopup;
  FHintStyleController := TcxHintStyleController.Create(nil);
  FHintStyleController.Global := False;
  FTimerShow := TTimer.Create(nil);
  FTimerShow.Enabled := False;
  FTimerShow.Interval := CONSTHINTDISPLAYPAUSE;
  FTimerShow.OnTimer := TimerShowTimer;
  FTimerHide := TTimer.Create(nil);
  FTimerHide.Enabled := False;
  FTimerHide.Interval := CONSTHINTDISPLAYDURATION;
  FTimerHide.OnTimer := TimerHideTimer;
  FScrollHEnabled := False;
  FHintOnlyOnHiddenText := True;
end;

destructor TcxImageComboBoxHint.Destroy;
begin
  FreeAndNil(FTimerHide);
  FreeAndNil(FTimerShow);
  FreeAndNil(FHintStyleController);
  FPopupWindow := nil;
  inherited;
end;

function TcxImageComboBoxHint.GetHintDisplayDuration: Integer;
begin
  Result := FTimerHide.Interval;
end;

function TcxImageComboBoxHint.GetHintDisplayPause: Integer;
begin
  Result := FTimerShow.Interval;
end;

procedure TcxImageComboBoxHint.TimerHideTimer(Sender: TObject);
begin
  FTimerHide.Enabled := False;
  FPopupWindow.Hint := '';
  FHintStyleController.HideHint;
end;

procedure TcxImageComboBoxHint.TimerShowTimer(Sender: TObject);
begin
  FTimerShow.Enabled := False;
  FTimerHide.Enabled := False;
  FHintStyleController.ShowHint(FDestPoint.X + 15, FDestPoint.Y - 10, '', FHint);
  FTimerHide.Enabled := True;
end;

procedure TcxImageComboBoxHint.DoComboBoxPropertiesPopup(Sender: TObject);
begin
  TcxComboBoxListBox(PopupWindow.Controls[0]).OnMouseMove := PopUpMouseMove;
end;

procedure TcxImageComboBoxHint.PopUpMouseLeave(Sender: TObject);
begin
  FTimerShow.Enabled := False;
  FTimerHide.Enabled := False;
  FPopupWindow.Hint := '';
  FHintStyleController.HideHint;
end;

procedure TcxImageComboBoxHint.PopUpMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  listBox: TcxComboBoxListBox;
  index: Integer;
begin
  if (X = FX) and (Y = FY) then
    Exit;
  FX := X;
  FY := Y;
  listBox := TcxEditListBoxContainer(Sender).InnerControl as TcxComboBoxListBox;
  listBox.OnMouseLeave := PopUpMouseLeave;
  if not FScrollHEnabled then
    listBox.ScrollWidth := 0;
  index := listBox.ItemAtPos(Point(X, Y), True);
  if index > -1 then
    begin
      FPopupWindow := TcxEditListBoxContainer(Sender).Parent as TcxComboBoxPopupWindow;
      FHint := TcxImageComboBox(FPopupWindow.Edit).Properties.Items[index].Description;
      if FPopupWindow.Hint = FHint then
        Exit;
      FPopupWindow.Hint := FHint;
      FHintStyleController.HideHint;
      FDestPoint := FPopupWindow.ClientToScreen(Point(X, Y));
      if (TcxImageComboBox(Sender).Canvas.TextWidth(FHint) + 4 < listBox.ClientWidth) and FHintOnlyOnHiddenText then
        FTimerShow.Enabled := False
      else
        FTimerShow.Enabled := True;
    end
  else
    FHintStyleController.HideHint;
end;

procedure TcxImageComboBoxHint.SetHintDisplayDuration(aDuration: Integer);
begin
  FTimerHide.Interval := aDuration;
end;

procedure TcxImageComboBoxHint.SetHintDisplayPause(aPause: Integer);
begin
  if aPause = 0 then // если значение 0, то таймер никогда не запустится
    aPause := 1;
  FTimerShow.Interval := aPause;
end;

end.
