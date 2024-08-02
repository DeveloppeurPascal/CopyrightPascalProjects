unit fOptions;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TfrmOptions = class(TForm)
    VertScrollBox1: TVertScrollBox;
    GridPanelLayout1: TGridPanelLayout;
    btnSaveAndClose: TButton;
    btnCancel: TButton;
    lblDefaultSummary: TLabel;
    lblDefaultCopyright: TLabel;
    mmoDefaultSummary: TMemo;
    mmoDefaultCopyright: TMemo;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveAndCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    procedure SaveConfig;
    procedure InitConfigFields;
    function HasChanged: Boolean;
  public
  end;

implementation

{$R *.fmx}

uses
  FMX.DialogService,
  System.IOUtils,
  uConfig;

procedure TfrmOptions.btnCancelClick(Sender: TObject);
begin
  InitConfigFields;
  close;
end;

procedure TfrmOptions.btnSaveAndCloseClick(Sender: TObject);
begin
  SaveConfig;
  close;
end;

procedure TfrmOptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if HasChanged then
  begin
    CanClose := false;
    TDialogService.MessageDialog
      ('Do you want to save your changes before closing ?',
      tmsgdlgtype.mtConfirmation, mbyesno, tmsgdlgbtn.mbYes, 0,
      procedure(const AModalResult: TModalResult)
      begin
        case AModalResult of
          mryes:
            tthread.forcequeue(nil,
              procedure
              begin
                btnSaveAndCloseClick(Sender);
              end);
        else
          tthread.forcequeue(nil,
            procedure
            begin
              btnCancelClick(Sender);
            end);
        end;
      end);
  end
  else
    CanClose := true;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
begin
  InitConfigFields;
end;

function TfrmOptions.HasChanged: Boolean;
var
  i: integer;
  mmo: TMemo;
begin
  result := false;
  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TMemo then
    begin
      mmo := VertScrollBox1.Content.Children[i] as TMemo;
      result := mmo.TagString <> mmo.Text;
      if result then
        break;
    end;
end;

procedure TfrmOptions.InitConfigFields;
var
  i: integer;
  mmo: TMemo;
begin
  mmoDefaultSummary.TagString := TConfig.DefaultSummary;
  mmoDefaultCopyright.TagString := TConfig.DefaultCopyright;

  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TMemo then
    begin
      mmo := VertScrollBox1.Content.Children[i] as TMemo;
      mmo.Text := mmo.TagString;
    end;
end;

procedure TfrmOptions.SaveConfig;
begin
  TConfig.DefaultSummary := mmoDefaultSummary.Text;
  TConfig.DefaultCopyright := mmoDefaultCopyright.Text;
  TConfig.Save;

  InitConfigFields;
end;

end.
