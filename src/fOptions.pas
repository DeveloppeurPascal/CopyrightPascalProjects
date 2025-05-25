(* C2PP
  ***************************************************************************

  Copyright Pascal Projects

  Copyright 2024-2025 Patrick Prémartin under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  This program is intended for Pascal language developers who wish to add a
  copyright and version comment to the header of their source files (*.pas,
  *.dpr, *.dpk, *.lpr, ...).

  What you are reading is the result of the program.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://copyrightpascalprojects.olfsoftware.fr/

  Project site :
  https://github.com/DeveloppeurPascal/CopyrightPascalProjects

  ***************************************************************************
  File last update : 2025-05-23T20:05:23.159+02:00
  Signature : cf08da774a4e27b63311184337ab2c7b898aa4f4
  ***************************************************************************
*)

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
  FMX.Controls.Presentation,
  Olf.FMX.SelectDirectory,
  FMX.Edit;

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
    lblDefaultPascalProjectFolder: TLabel;
    edtDefaultPascalProjectFolder: TEdit;
    btnDefaultPascalProjectFolderSelect: TEllipsesEditButton;
    OlfSelectDirectoryDialog1: TOlfSelectDirectoryDialog;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveAndCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnDefaultPascalProjectFolderSelectClick(Sender: TObject);
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

procedure TfrmOptions.btnDefaultPascalProjectFolderSelectClick(Sender: TObject);
begin
  if (not edtDefaultPascalProjectFolder.Text.IsEmpty) and
    tdirectory.Exists(edtDefaultPascalProjectFolder.Text) then
    OlfSelectDirectoryDialog1.Directory := edtDefaultPascalProjectFolder.Text
  else
    OlfSelectDirectoryDialog1.Directory := tpath.GetDocumentsPath;

  if OlfSelectDirectoryDialog1.Execute and
    tdirectory.Exists(OlfSelectDirectoryDialog1.Directory) then
    edtDefaultPascalProjectFolder.Text := OlfSelectDirectoryDialog1.Directory;
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
begin
  result := false;
  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
  begin
    if VertScrollBox1.Content.Children[i] is TMemo then
      result := (VertScrollBox1.Content.Children[i] as TMemo).TagString <>
        (VertScrollBox1.Content.Children[i] as TMemo).Text
    else if VertScrollBox1.Content.Children[i] is TEdit then
      result := (VertScrollBox1.Content.Children[i] as TEdit).TagString <>
        (VertScrollBox1.Content.Children[i] as TEdit).Text;
    if result then
      break;
  end;
end;

procedure TfrmOptions.InitConfigFields;
var
  i: integer;
begin
  mmoDefaultSummary.TagString := TConfig.DefaultSummary;
  mmoDefaultCopyright.TagString := TConfig.DefaultCopyright;
  edtDefaultPascalProjectFolder.TagString := TConfig.DefaultPascalProjectFolder;

  for i := 0 to VertScrollBox1.Content.ChildrenCount - 1 do
    if VertScrollBox1.Content.Children[i] is TMemo then
      (VertScrollBox1.Content.Children[i] as TMemo).Text :=
        (VertScrollBox1.Content.Children[i] as TMemo).TagString
    else if VertScrollBox1.Content.Children[i] is TEdit then
      (VertScrollBox1.Content.Children[i] as TEdit).Text :=
        (VertScrollBox1.Content.Children[i] as TEdit).TagString;
end;

procedure TfrmOptions.SaveConfig;
begin
  TConfig.DefaultSummary := mmoDefaultSummary.Text;
  TConfig.DefaultCopyright := mmoDefaultCopyright.Text;
  TConfig.DefaultPascalProjectFolder := edtDefaultPascalProjectFolder.Text;
  TConfig.Save;

  InitConfigFields;
end;

end.
