unit fMain;

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
  uDMLogo,
  Olf.FMX.AboutDialog,
  FMX.Controls.Presentation,
  FMX.StdCtrls, uProjectC2PP, FMX.Layouts;

type
  TfrmMain = class(TForm)
    OlfAboutDialog1: TOlfAboutDialog;
    ToolBar1: TToolBar;
    btnProjectOpen: TButton;
    btnProjectClose: TButton;
    btnProjectRun: TButton;
    btnProjectNew: TButton;
    btnAbout: TButton;
    btnOptions: TButton;
    btnQuit: TButton;
    lProject: TLayout;
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure FormCreate(Sender: TObject);
    procedure btnQuitClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnOptionsClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FCurrentProject: TC2PPProject;
    procedure SetCurrentProject(const Value: TC2PPProject);
  protected
    procedure SubscribeToProjectChangedMessage;
  public
    property CurrentProject: TC2PPProject read FCurrentProject
      write SetCurrentProject;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.Messaging,
  u_urlOpen,
  uAboutDescriptionText,
  uAboutLicenseText,
  fOptions;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  OlfAboutDialog1.Execute;
end;

procedure TfrmMain.btnOptionsClick(Sender: TObject);
var
  f: TfrmOptions;
begin
  f := TfrmOptions.Create(self);
  try
    f.ShowModal;
  finally
    f.free;
  end;
end;

procedure TfrmMain.btnQuitClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if assigned(CurrentProject) then
  begin
    // TODO :   actProjectCloseExecute(Sender);
    CanClose := not assigned(CurrentProject);
  end
  else
    CanClose := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  SubscribeToProjectChangedMessage;
  CurrentProject := nil;

  // TODO : traduire les textes
  OlfAboutDialog1.Description.Text := CAboutDescriptionEN;
  OlfAboutDialog1.Licence.Text := CAboutLicenseEN;
end;

procedure TfrmMain.OlfAboutDialog1URLClick(const AURL: string);
begin
  url_Open_In_Browser(AURL);
end;

procedure TfrmMain.SetCurrentProject(const Value: TC2PPProject);
begin
  FCurrentProject := Value;

  if not assigned(FCurrentProject) then
  begin
    lProject.Visible := false;
    TMessageManager.DefaultManager.SendMessage(self,
      TC2PPProjectHasChangedMessage.Create(FCurrentProject));
  end
  else
  begin
    // TOOD : à compléter
    lProject.Visible := true;
    TMessageManager.DefaultManager.SendMessage(self,
      TC2PPProjectHasChangedMessage.Create(FCurrentProject));
  end;
end;

procedure TfrmMain.SubscribeToProjectChangedMessage;
begin
  TMessageManager.DefaultManager.SubscribeToMessage
    (TC2PPProjectHasChangedMessage,
    procedure(const Sender: TObject; const M: TMessage)
    var
      msg: TC2PPProjectHasChangedMessage;
    begin
      if M is TC2PPProjectHasChangedMessage then
        msg := M as TC2PPProjectHasChangedMessage
      else
        raise exception.Create('Wrong message for subscription !');

      if (msg.Value = CurrentProject) then
      begin
        if assigned(CurrentProject) then
        begin
          if CurrentProject.HasChanged then
            OlfAboutDialog1.MainFormCaptionPrefix := CurrentProject.FileName
              + '(*) -'
          else
            OlfAboutDialog1.MainFormCaptionPrefix :=
              CurrentProject.FileName + ' -'
        end
        else
          OlfAboutDialog1.MainFormCaptionPrefix := '';

        // TODO : à compléter
        // actProjectSave.Enabled := assigned(CurrentProject);
        // actProjectOptions.Enabled := assigned(CurrentProject);
        // actProjectClose.Enabled := assigned(CurrentProject);
        //
        // mnuProject.Enabled := assigned(CurrentProject);

        btnProjectOpen.Visible := not assigned(CurrentProject);
        btnProjectNew.Visible := btnProjectOpen.Visible;
        btnProjectClose.Visible := not btnProjectOpen.Visible;
        btnProjectRun.Visible := not btnProjectOpen.Visible;
      end;
    end);
end;

initialization

{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := true;
{$ENDIF}

end.
