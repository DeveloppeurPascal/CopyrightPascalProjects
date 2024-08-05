/// <summary>
/// ***************************************************************************
///
/// Copyright Pascal Projects
///
/// Copyright 2024 Patrick Prémartin under AGPL 3.0 license.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
/// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
/// DEALINGS IN THE SOFTWARE.
///
/// ***************************************************************************
///
/// This program is intended for Pascal language developers who wish to add a
/// copyright and version comment to the header of their source files (*.pas,
/// *.dpr, *.dpk, *.lpr, ...).
///
/// What you are reading is the result of the program.
///
/// ***************************************************************************
///
/// Author(s) :
/// Patrick PREMARTIN
///
/// Site :
/// https://copyrightpascalprojects.olfsoftware.fr/
///
/// Project site :
/// https://github.com/DeveloppeurPascal/CopyrightPascalProjects
///
/// ***************************************************************************
/// File last update : 03/08/2024 16:04:56
/// Signature : c3215d962b300523d80379e07bcf0012098676dc
/// ***************************************************************************
/// </summary>

unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  FMX.Forms,
  FMX.ActnList,
  FMX.Dialogs,
  FMX.Controls,
  FMX.Menus,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Types,
  FMX.Controls.Presentation,
  uDMLogo,
  Olf.FMX.AboutDialog,
  uProjectC2PP,
  Olf.FMX.AboutDialogForm,
  Olf.FMX.SelectDirectory,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.Edit;

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
    ActionList1: TActionList;
    actQuit: TAction;
    actProjectOpen: TAction;
    actProjectNew: TAction;
    actProjectSave: TAction;
    actProjectClose: TAction;
    actAbout: TAction;
    actOptions: TAction;
    actProjectRun: TAction;
    MainMenu1: TMainMenu;
    mnuMacOS: TMenuItem;
    mnuFile: TMenuItem;
    mnuFileNew: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSave: TMenuItem;
    mnuFileClose: TMenuItem;
    mnuFileQuit: TMenuItem;
    mnuProject: TMenuItem;
    mnuProjectRun: TMenuItem;
    mnuTools: TMenuItem;
    mnuToolsOptions: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpAbout: TMenuItem;
    odC2PPProject: TOpenDialog;
    sdC2PPProject: TSaveDialog;
    sddPascalProject: TOlfSelectDirectoryDialog;
    VertScrollBox1: TVertScrollBox;
    edtPascalProjectFolder: TEdit;
    btnPascalProjectFolderSelect: TEllipsesEditButton;
    lblCopyright: TLabel;
    lblPascalProjectFolder: TLabel;
    lblSummary: TLabel;
    mmoCopyright: TMemo;
    mmoSummary: TMemo;
    lblSiteURL: TLabel;
    edtSiteURL: TEdit;
    btnSiteURLOpen: TEllipsesEditButton;
    lblProjectURL: TLabel;
    edtProjectURL: TEdit;
    btnAuthorURLOpen: TEllipsesEditButton;
    lblAuthor: TLabel;
    edtAuthor: TEdit;
    mmoLog: TMemo;
    procedure OlfAboutDialog1URLClick(const AURL: string);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    function OlfAboutDialog1GetText(const ALang: TOlfAboutDialogLang;
      const ATxtID: TOlfAboutDialogTxtID): string;
    procedure actQuitExecute(Sender: TObject);
    procedure actProjectOpenExecute(Sender: TObject);
    procedure actProjectNewExecute(Sender: TObject);
    procedure actProjectSaveExecute(Sender: TObject);
    procedure actProjectCloseExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actProjectRunExecute(Sender: TObject);
    procedure btnPascalProjectFolderSelectClick(Sender: TObject);
    procedure btnAuthorURLOpenClick(Sender: TObject);
    procedure btnSiteURLOpenClick(Sender: TObject);
    procedure edtPascalProjectFolderChangeTracking(Sender: TObject);
    procedure mmoSummaryChangeTracking(Sender: TObject);
    procedure mmoCopyrightChangeTracking(Sender: TObject);
    procedure edtAuthorChangeTracking(Sender: TObject);
    procedure edtProjectURLChangeTracking(Sender: TObject);
    procedure edtSiteURLChangeTracking(Sender: TObject);
  private
    FCurrentProject: TC2PPProject;
    procedure SetCurrentProject(const Value: TC2PPProject);
  protected
    procedure SubscribeToProjectChangedMessage;
    procedure InitMainMenuForMacOS;
    procedure AddCommentsToFolder(const AFolder: string);
    procedure AddCommentsToFile(const AFilePath: string);
  public
    property CurrentProject: TC2PPProject read FCurrentProject
      write SetCurrentProject;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

uses
  System.Hash,
  FMX.DialogService,
  System.IOUtils,
  System.Messaging,
  u_urlOpen,
  uAboutDescriptionText,
  uAboutLicenseText,
  fOptions,
  uConfig;

procedure TfrmMain.actAboutExecute(Sender: TObject);
begin
  OlfAboutDialog1.Execute;
end;

procedure TfrmMain.actOptionsExecute(Sender: TObject);
var
  f: TfrmOptions;
begin
  f := TfrmOptions.Create(self);
  try
    f.showmodal;
  finally
    f.free;
  end;
end;

procedure TfrmMain.actProjectCloseExecute(Sender: TObject);
begin
  if assigned(CurrentProject) and CurrentProject.HasChanged then
  begin
    TDialogService.MessageDialog
      ('Current project has been changed. Do you want to save it ?',
      tmsgdlgtype.mtConfirmation, mbyesno, tmsgdlgbtn.mbYes, 0,
      procedure(const AModalResult: TModalResult)
      begin
        if AModalResult = mryes then
          if not CurrentProject.FilePath.IsEmpty then
            CurrentProject.SaveToFile
          else
          begin
            tthread.ForceQueue(nil,
              procedure
              begin
                actProjectSaveExecute(Sender);
              end);
            abort;
          end;
        CurrentProject.free;
        CurrentProject := nil;
      end);
  end
  else
  begin
    CurrentProject.free;
    CurrentProject := nil;
  end;
end;

procedure TfrmMain.actProjectRunExecute(Sender: TObject);
begin
  if not assigned(CurrentProject) then
    exit;

  // Sur cette version, on exclut les dossiers :
  // .*
  // __history & __recovery (dossiers de Delphi)
  // _PRIVATE ou _PRIVE (les fichiers non diffusés sur le dépôt de code)
  // lib-externes et lib-externe (les sous-modules dans mes dépôts de code)

  // Les extensions de fichiers prises en charge :
  // *.pas
  // *.dpr
  // *.dpk
  // *.lpr

  // Parcours de l'arborescence sélectionnée pour le projet Pascal
  // Pour chaque dossier, parcourrir les sous-dossier puis les fichiers
  // Pour chaque fichier à traiter (non exclu, avec la bonne extension)
  // => récupérer la date/heure de dernière moficiation du fichier
  // => lire le fichier et récupérer la signature existante
  // => calculer la nouvelle signature une fois le bloc de commentaire en entête supprimé
  // => si la signature diffère, générer une nouvelle version du fichier avec son commentaire à jour

  if CurrentProject.PascalProjectFolder.IsEmpty then
    raise Exception.Create('Unknow Pascal project folder to run on !');

  if not TDirectory.Exists(CurrentProject.PascalProjectFolder) then
    raise Exception.Create('Current Pascal project folder doesn''t exist !');

  // TODO : faire le traitement en batch pour ne pas bloquer l'écran pendant qu'il tourne

  // TODO : proposer éventuellement d'enregistrer les données du projet ouvert
  // TODO : ajouter une demande de confiramtion d'écrasement des fichier de destination (rappel qu'il n'y a pas de retour en arrière sauf backup ou VCS pour Version Control System)

  mmoLog.Visible := true; // TODO : à conditionner dans les options du programme
  mmoLog.lines.clear;
  mmoLog.BringToFront;

  actProjectRun.Enabled := false;
  try
    lProject.Enabled := false;
    try
      AddCommentsToFolder(CurrentProject.PascalProjectFolder);
    finally
      lProject.Enabled := true;
    end;
  finally
    actProjectRun.Enabled := true;
  end;
end;

procedure TfrmMain.actProjectNewExecute(Sender: TObject);
var
  Project: TC2PPProject;
begin
  if assigned(CurrentProject) then
    actProjectCloseExecute(Sender);

  if sddPascalProject.Directory.IsEmpty then
    if (not tconfig.DefaultPascalProjectFolder.IsEmpty) and
      TDirectory.Exists(tconfig.DefaultPascalProjectFolder) then
      sddPascalProject.Directory := tconfig.DefaultPascalProjectFolder
    else
      sddPascalProject.Directory := tpath.GetDocumentsPath;

  sddPascalProject.Text := 'Select the Pascal project directory';
  // TODO : à traduire

  if sddPascalProject.Execute and (not sddPascalProject.Directory.IsEmpty) and
    TDirectory.Exists(sddPascalProject.Directory) then
  begin
    Project := TC2PPProject.Create;
    Project.PascalProjectFolder := sddPascalProject.Directory;
    Project.Copyright := tconfig.DefaultCopyright;
    Project.Description := tconfig.DefaultSummary;
    CurrentProject := Project;
  end;
end;

procedure TfrmMain.actProjectOpenExecute(Sender: TObject);
var
  Project: TC2PPProject;
begin
  if assigned(CurrentProject) then
    actProjectCloseExecute(Sender);

  if odC2PPProject.InitialDir.IsEmpty then
    if (not tconfig.DefaultPascalProjectFolder.IsEmpty) and
      TDirectory.Exists(tconfig.DefaultPascalProjectFolder) then
      odC2PPProject.InitialDir := tconfig.DefaultPascalProjectFolder
    else
      odC2PPProject.InitialDir := tpath.GetDocumentsPath;

  if odC2PPProject.Execute and (odC2PPProject.FileName <> '') and
    tfile.Exists(odC2PPProject.FileName) and
    (tpath.GetExtension(odC2PPProject.FileName).ToLower = '.c2pp') then
  begin
    Project := TC2PPProject.Create(odC2PPProject.FileName);
    if TDirectory.Exists(Project.PascalProjectFolder) then
      CurrentProject := Project
    else
      TDialogService.ShowMessage
        ('The Pascal project folder doesn''t exist. Please select the new one.',
        procedure(const AModalResult: TModalResult)
        begin
          if sddPascalProject.Directory.IsEmpty then
            sddPascalProject.Directory := tconfig.DefaultPascalProjectFolder;

          if sddPascalProject.Execute and
            (not sddPascalProject.Directory.IsEmpty) and
            TDirectory.Exists(sddPascalProject.Directory) then
          begin
            Project.PascalProjectFolder := sddPascalProject.Directory;
            CurrentProject := Project;
          end
          else
            Project.free;
        end);
  end;
end;

procedure TfrmMain.actProjectSaveExecute(Sender: TObject);
begin
  if not assigned(CurrentProject) then
    exit;

  if not CurrentProject.FilePath.IsEmpty then
    CurrentProject.SaveToFile
  else
  begin
    if sdC2PPProject.InitialDir.IsEmpty then
      if (not CurrentProject.PascalProjectFolder.IsEmpty) and
        TDirectory.Exists(CurrentProject.PascalProjectFolder) then
        sdC2PPProject.InitialDir := CurrentProject.PascalProjectFolder
      else
        sdC2PPProject.InitialDir := tpath.GetDocumentsPath;

    if not CurrentProject.PascalProjectFolder.IsEmpty then
      sdC2PPProject.FileName := tpath.GetFileNameWithoutExtension
        (CurrentProject.PascalProjectFolder) + '.c2pp'
    else
      sdC2PPProject.FileName := 'nonamed.c2pp';

    if sdC2PPProject.Execute and (sdC2PPProject.FileName <> '') then
      CurrentProject.SaveToFile(sdC2PPProject.FileName);
  end;
end;

procedure TfrmMain.actQuitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.AddCommentsToFile(const AFilePath: string);
  procedure AddTo(var Tab: TStringDynArray; const s: string);
  var
    idx: int64;
  begin
    idx := length(Tab);
    setlength(Tab, idx + 1);
    Tab[idx] := s.TrimRight;
  end;

  procedure AddStringsTo(var Tab: TStringDynArray; const s: string);
  var
    i, j: int64;
    sl, slWrap: TStringList;
  begin
    sl := TStringList.Create;
    try
      sl.Text := s;
      slWrap := TStringList.Create;
      try
        for i := 0 to sl.Count - 1 do
          if (sl[i].length < 75) then
            AddTo(Tab, '/// ' + sl[i].TrimRight)
          else
          begin
            slWrap.Text := wraptext(sl[i], 75);
            for j := 0 to slWrap.Count - 1 do
              AddTo(Tab, '/// ' + slWrap[j].TrimRight)
          end;
      finally
        slWrap.free;
      end;
    finally
      sl.free;
    end;
  end;

  function Space(const Nb: integer; const s: string): string;
  var
    i: int64;
  begin
    result := '';
    for i := 1 to Nb do
      result := result + s;
  end;

var
  FileName: string;
  LastWriteTime: TDateTime;
  SourceFile, DestFile: TStringDynArray;
  PrevSignature, NewSignature: string;
  i, idx: int64;
  FirstSourceLineIndex: int64;
  Encoding: TEncoding;
begin
  if AFilePath.IsEmpty then
    exit;

  // TODO : s'assurer que le dossier du fichier est bien à traiter

  FileName := tpath.GetFileName(AFilePath).ToLower;

  if (FileName = '.') or (FileName = '..') then
    exit;

  // TODO : vérifier que l'extension du fichier est dans la liste des extnsions à traiter

  if not(FileName.EndsWith('.pas') or FileName.EndsWith('.dpr') or
    FileName.EndsWith('.dpk') or FileName.EndsWith('.lpr')) then
    exit;

  // TODO : vérifier que le fichier n'est pas dans la liste des exclusions

  if not tfile.Exists(AFilePath) then
    exit;

  // Pour les fichiers à traiter :
  // => récupérer la date/heure de dernière moficiation du fichier
  LastWriteTime := tfile.GetLastWriteTime(AFilePath);

  // => lire le fichier
  try
    SourceFile := tfile.ReadAllLines(AFilePath, TEncoding.utf8);
    Encoding := TEncoding.utf8;
  except
    on EEncodingError do
    begin
      SourceFile := tfile.ReadAllLines(AFilePath, TEncoding.ansi);
      Encoding := TEncoding.ansi;
    end;
  end;

  // => récupérer la signature existante
  i := 0;
  while (i < length(SourceFile)) and SourceFile[i].trim.IsEmpty do
    inc(i);

  PrevSignature := '';
  while (i < length(SourceFile)) and SourceFile[i].trim.startswith('///') do
  begin
    idx := SourceFile[i].IndexOf('Signature : ');
    if (idx >= 0) then
      PrevSignature := SourceFile[i].Substring(idx + 'Signature : '.length);
    inc(i);
  end;

  while (i < length(SourceFile)) and SourceFile[i].trim.IsEmpty do
    inc(i);

  FirstSourceLineIndex := i;

  NewSignature := '';
  // => calculer la nouvelle signature une fois le bloc de commentaire en entête supprimé
  for i := FirstSourceLineIndex to length(SourceFile) - 1 do
    NewSignature := thashsha1.GetHashString(NewSignature + SourceFile[i]);

  // => si la signature diffère, générer une nouvelle version du fichier avec son commentaire à jour
  if (NewSignature <> PrevSignature) then
  begin
    setlength(DestFile, 0);
    AddTo(DestFile, '/// <summary>');
    if (not CurrentProject.Copyright.IsEmpty) then
    begin
      AddTo(DestFile, '/// ' + Space(75, '*'));
      AddTo(DestFile, '///');
      AddStringsTo(DestFile, CurrentProject.Copyright);
      AddTo(DestFile, '///');
    end;
    if (not CurrentProject.Description.IsEmpty) then
    begin
      AddTo(DestFile, '/// ' + Space(75, '*'));
      AddTo(DestFile, '///');
      AddStringsTo(DestFile, CurrentProject.Description);
      AddTo(DestFile, '///');
    end;
    if (not CurrentProject.Author.IsEmpty) or
      (not CurrentProject.SiteURL.IsEmpty) or
      (not CurrentProject.ProjectURL.IsEmpty) then
    begin
      AddTo(DestFile, '/// ' + Space(75, '*'));
      if (not CurrentProject.Author.IsEmpty) then
      begin
        AddTo(DestFile, '///');
        AddTo(DestFile, '/// Author(s) :');
        // TODO : traiter le cas de plusieurs ou un seul auteurs
        AddTo(DestFile, '/// ' + CurrentProject.Author);
      end;
      if (not CurrentProject.SiteURL.IsEmpty) then
      begin
        AddTo(DestFile, '///');
        AddTo(DestFile, '/// Site :');
        AddTo(DestFile, '/// ' + CurrentProject.SiteURL);
      end;
      if (not CurrentProject.ProjectURL.IsEmpty) then
      begin
        AddTo(DestFile, '///');
        AddTo(DestFile, '/// Project site :');
        AddTo(DestFile, '/// ' + CurrentProject.ProjectURL);
      end;
      AddTo(DestFile, '///');
    end;
    AddTo(DestFile, '/// ' + Space(75, '*'));
    AddTo(DestFile, '/// File last update : ' + datetimetostr(LastWriteTime));
    AddTo(DestFile, '/// Signature : ' + NewSignature);
    AddTo(DestFile, '/// ' + Space(75, '*'));
    AddTo(DestFile, '/// </summary>');
    AddTo(DestFile, '');

    idx := length(DestFile);
    setlength(DestFile, idx + length(SourceFile) - FirstSourceLineIndex);
    for i := FirstSourceLineIndex to length(SourceFile) - 1 do
    begin
      DestFile[idx] := SourceFile[i];
      inc(idx);
    end;

    tfile.WriteAllLines(AFilePath, DestFile, Encoding);

    mmoLog.lines.Add('     => ' + FileName + ' ***** modifié *****');
    mmoLog.lines.Add('         Last updated date/time : ' +
      datetimetostr(LastWriteTime));
    mmoLog.lines.Add('         Prev signature : ' + PrevSignature);
    mmoLog.lines.Add('         New signature : ' + NewSignature);
    mmoLog.GoToLineEnd;
  end
  else
  begin
{$IFDEF DEBUG}
    mmoLog.lines.Add('     => ' + FileName + ' (non modifié)');
    mmoLog.GoToLineEnd;
{$ENDIF}
  end;
end;

procedure TfrmMain.AddCommentsToFolder(const AFolder: string);
var
  i: integer;
  Tab: TStringDynArray;
  fld: string;
begin
  if AFolder.IsEmpty then
    exit;

  fld := tpath.GetFileName(AFolder).ToLower;

  if (fld = '.') or (fld = '..') then
    exit;

  // TODO : vérifier que le dossier n'est pas dans la liste des exclusions

  if fld.startswith('.') or (fld = '_private') or (fld = '_prive') or
    (fld = '__history') or (fld = '__recovery') or (fld = 'lib-externes') or
    (fld = 'lib-externe') then
    exit;

  if (not TDirectory.Exists(AFolder)) then
    exit;

  mmoLog.lines.Add(AFolder);
  mmoLog.GoToLineEnd;

  Tab := TDirectory.GetFiles(AFolder);
  for i := 0 to length(Tab) - 1 do
    AddCommentsToFile(Tab[i]);

  Tab := TDirectory.GetDirectories(AFolder);
  for i := 0 to length(Tab) - 1 do
    AddCommentsToFolder(Tab[i]);
end;

procedure TfrmMain.btnAuthorURLOpenClick(Sender: TObject);
begin
  if not edtProjectURL.Text.IsEmpty then
    url_Open_In_Browser(edtProjectURL.Text);
end;

procedure TfrmMain.btnPascalProjectFolderSelectClick(Sender: TObject);
begin
  if (not edtPascalProjectFolder.Text.IsEmpty) and
    TDirectory.Exists(edtPascalProjectFolder.Text) then
    sddPascalProject.Directory := edtPascalProjectFolder.Text
  else if (not tconfig.DefaultPascalProjectFolder.IsEmpty) and
    TDirectory.Exists(tconfig.DefaultPascalProjectFolder) then
    sddPascalProject.Directory := tconfig.DefaultPascalProjectFolder
  else
    sddPascalProject.Directory := tpath.GetDocumentsPath;

  sddPascalProject.Text := 'Select the Pascal project directory';
  // TODO : à traduire

  if sddPascalProject.Execute and (not sddPascalProject.Directory.IsEmpty) and
    TDirectory.Exists(sddPascalProject.Directory) then
    edtPascalProjectFolder.Text := sddPascalProject.Directory;
end;

procedure TfrmMain.btnSiteURLOpenClick(Sender: TObject);
begin
  if not edtSiteURL.Text.IsEmpty then
    url_Open_In_Browser(edtSiteURL.Text);
end;

procedure TfrmMain.edtAuthorChangeTracking(Sender: TObject);
begin
  CurrentProject.Author := edtAuthor.Text;
end;

procedure TfrmMain.edtPascalProjectFolderChangeTracking(Sender: TObject);
begin
  CurrentProject.PascalProjectFolder := edtPascalProjectFolder.Text;
end;

procedure TfrmMain.edtProjectURLChangeTracking(Sender: TObject);
begin
  CurrentProject.ProjectURL := edtProjectURL.Text;
end;

procedure TfrmMain.edtSiteURLChangeTracking(Sender: TObject);
begin
  CurrentProject.SiteURL := edtSiteURL.Text;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if assigned(CurrentProject) then
  begin
    actProjectCloseExecute(Sender);
    CanClose := not assigned(CurrentProject);
  end
  else
    CanClose := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  SubscribeToProjectChangedMessage;
  CurrentProject := nil;

  InitMainMenuForMacOS;

  mmoLog.Visible := false;
end;

procedure TfrmMain.InitMainMenuForMacOS;
begin
{$IFDEF MACOS}
  mnuMacOS.Visible := true;
  actQuit.shortcut := scCommand + ord('Q'); // 4177;
  mnuHelpAbout.Parent := mnuMacOS;
  mnuHelp.Visible := (mnuHelp.Children[0].ChildrenCount > 0);
  mnuToolsOptions.Parent := mnuMacOS;
  mnuTools.Visible := (mnuTools.Children[0].ChildrenCount > 0);
{$ELSE}
  mnuMacOS.Visible := false;
{$ENDIF}
  actAbout.Text := '&About ' + OlfAboutDialog1.Titre;
  btnAbout.Text := '&About';
end;

procedure TfrmMain.mmoCopyrightChangeTracking(Sender: TObject);
begin
  CurrentProject.Copyright := mmoCopyright.Text;
end;

procedure TfrmMain.mmoSummaryChangeTracking(Sender: TObject);
begin
  CurrentProject.Description := mmoSummary.Text;
end;

function TfrmMain.OlfAboutDialog1GetText(const ALang: TOlfAboutDialogLang;
const ATxtID: TOlfAboutDialogTxtID): string;
begin
  case ATxtID of
    TOlfAboutDialogTxtID.DescriptionText:
      result := CAboutDescriptionEN;
    TOlfAboutDialogTxtID.LicenseText:
      result := CAboutLicenseEN;
  end;
  // TODO : traduire les textes
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
    mmoLog.Visible := false;
    TMessageManager.DefaultManager.SendMessage(self,
      TC2PPProjectHasChangedMessage.Create(FCurrentProject));
  end
  else
  begin
    edtPascalProjectFolder.Text := CurrentProject.PascalProjectFolder;
    mmoSummary.Text := CurrentProject.Description;
    mmoCopyright.Text := CurrentProject.Copyright;
    edtAuthor.Text := CurrentProject.Author;
    edtProjectURL.Text := CurrentProject.ProjectURL;
    edtSiteURL.Text := CurrentProject.SiteURL;

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
        raise Exception.Create('Wrong message for subscription !');

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

        actProjectSave.Enabled := assigned(CurrentProject);
        actProjectClose.Enabled := assigned(CurrentProject);

        mnuProject.Enabled := assigned(CurrentProject);

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
