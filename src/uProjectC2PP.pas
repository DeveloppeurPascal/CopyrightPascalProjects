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
  Signature : 77a254d04903afb6a12f0cffd7c26f4830b3d89c
  ***************************************************************************
*)

unit uProjectC2PP;

interface

uses
  System.Messaging,
  System.Classes,
  System.Generics.Collections;

const
  CProjectFileVersion = 20240803;

type
  TC2PPProject = class;

  TC2PPProjectHasChangedMessage = class(TMessage<TC2PPProject>)
  end;

  TC2PPProject = class
  private const
    CVersion = 1;

  var
    FHasChanged: boolean;
    FIsLoading: boolean;
    FIsCloning: boolean;
    FFilePath: string;
    FProjectURL: string;
    FAuthor: string;
    FDescription: string;
    FCopyright: string;
    FSiteURL: string;
    FPascalProjectFolder: string;
    procedure SetPascalProjectFolder(const Value: string);
    procedure SetAuthor(const Value: string);
    procedure SetCopyright(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetProjectURL(const Value: string);
    procedure SetSiteURL(const Value: string);
    function GetFileName: string;
    procedure SetHasChanged(const Value: boolean);
  protected
  public
    /// <summary>
    /// Return True if a property value has changed since last Save() or Load().
    /// </summary>
    property HasChanged: boolean read FHasChanged write SetHasChanged;
    /// <summary>
    /// Return the C2PP project file path
    /// </summary>
    property FilePath: string read FFilePath;
    /// <summary>
    /// Return the C2PP project filename
    /// </summary>
    property FileName: string read GetFileName;
    /// <summary>
    /// Used as a SUMMARY tag in exported comments
    /// </summary>
    property Description: string read FDescription write SetDescription;
    /// <summary>
    /// Used as a REMARKS tag in exported comments
    /// </summary>
    property Copyright: string read FCopyright write SetCopyright;
    /// <summary>
    /// Used in the generated REMARKS comment
    /// </summary>
    property Author: string read FAuthor write SetAuthor;
    /// <summary>
    /// Used in the generated REMARKS comment
    /// </summary>
    property SiteURL: string read FSiteURL write SetSiteURL;
    /// <summary>
    /// Used in the generated REMARKS comment
    /// </summary>
    property ProjectURL: string read FProjectURL write SetProjectURL;
    /// <summary>
    /// Pascal project path (where we look for .pas/.dpr.lpr files to update)
    /// </summary>
    property PascalProjectFolder: string read FPascalProjectFolder
      write SetPascalProjectFolder;
    // TODO : add included/excluded folders
    // TODO : add included/excluded files
    procedure LoadFromFile(const AFilePath: string = '');
    procedure LoadFromStream(const AStream: TStream);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToFile(const AFilePath: string = '');
    constructor Create; overload;
    constructor Create(const AFilePath: string); overload;
    destructor Destroy; override;
    function Clone: TC2PPProject;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  Olf.RTL.Streams,
  uConfig;

{ TC2PPProject }

constructor TC2PPProject.Create;
begin
  inherited;
  FHasChanged := false;
  FIsLoading := false;
  FIsCloning := false;
  FFilePath := '';
  FProjectURL := '';
  FAuthor := '';
  FDescription := '';
  FCopyright := '';
  FSiteURL := '';
  FPascalProjectFolder := '';
end;

function TC2PPProject.Clone: TC2PPProject;
var
  ms: TMemoryStream;
begin
  FIsCloning := true;
  try
    result := TC2PPProject.Create;
    ms := TMemoryStream.Create;
    try
      SaveToStream(ms);
      ms.Position := 0;
      result.LoadFromStream(ms);
    finally
      ms.free;
    end;
    result.FFilePath := FFilePath;
    result.FHasChanged := false;
  finally
    FIsCloning := false;
  end;
end;

constructor TC2PPProject.Create(const AFilePath: string);
begin
  Create;
  LoadFromFile(AFilePath);
end;

destructor TC2PPProject.Destroy;
begin
  inherited;
end;

function TC2PPProject.GetFileName: string;
begin
  if FFilePath.isempty then
    result := 'noname'
  else
    result := tpath.GetFileNameWithoutExtension(FFilePath);
end;

procedure TC2PPProject.LoadFromFile(const AFilePath: string);
var
  fs: TFileStream;
begin
  if not AFilePath.isempty then
    FFilePath := AFilePath;

  if FFilePath.isempty then
    raise exception.Create('No filename, what do you want to load ?');

  if not tfile.Exists(FFilePath) then
    raise exception.Create('This file doesn''t exist !');

  fs := TFileStream.Create(FFilePath, fmOpenRead);
  try
    LoadFromStream(fs);
  finally
    fs.free;
  end;
end;

procedure TC2PPProject.LoadFromStream(const AStream: TStream);
var
  ProjectVersion: uint64;
  Version: byte;
begin
  FIsLoading := true;
  try
    if (AStream.Read(ProjectVersion, sizeof(ProjectVersion)) <>
      sizeof(ProjectVersion)) then
      raise exception.Create('Wrong file format.');

    if (ProjectVersion > CProjectFileVersion) then
      raise exception.Create
        ('This project file is too recent. Please upgrade this program if you wish to load it.');

    if (AStream.Read(Version, sizeof(Version)) <> sizeof(Version)) then
      raise exception.Create('Wrong file format (undefined project record).');

    if (Version > CVersion) then
      raise exception.Create
        ('This project file is too recent. Please upgrade this program if you wish to load it.');

    FAuthor := LoadStringFromStream(AStream);
    FCopyright := LoadStringFromStream(AStream);
    FDescription := LoadStringFromStream(AStream);
    FProjectURL := LoadStringFromStream(AStream);
    FSiteURL := LoadStringFromStream(AStream);
    FPascalProjectFolder := LoadStringFromStream(AStream);

  finally
    FIsLoading := false;
  end;
  HasChanged := false;
end;

procedure TC2PPProject.SaveToFile(const AFilePath: string);
var
  fs: TFileStream;
begin
  if not AFilePath.isempty then
    FFilePath := AFilePath;

  if FFilePath.isempty then
    raise exception.Create
      ('No filename, where do you want to save your project ?');

  fs := TFileStream.Create(FFilePath, fmOpenWrite + fmCreate);
  try
    SaveToStream(fs);
  finally
    fs.free;
  end;
end;

procedure TC2PPProject.SaveToStream(const AStream: TStream);
var
  ProjectVersion: uint64;
  Version: byte;
begin
  ProjectVersion := CProjectFileVersion;
  AStream.Write(ProjectVersion, sizeof(ProjectVersion));
  Version := CVersion;
  AStream.Write(Version, sizeof(Version));

  SaveStringToStream(FAuthor, AStream);
  SaveStringToStream(FCopyright, AStream);
  SaveStringToStream(FDescription, AStream);
  SaveStringToStream(FProjectURL, AStream);
  SaveStringToStream(FSiteURL, AStream);
  SaveStringToStream(FPascalProjectFolder, AStream);

  if not FIsCloning then
    HasChanged := false;
end;

procedure TC2PPProject.SetAuthor(const Value: string);
begin
  if FAuthor <> Value then
  begin
    FAuthor := Value;
    HasChanged := true;
  end;
end;

procedure TC2PPProject.SetCopyright(const Value: string);
begin
  if FCopyright <> Value then
  begin
    FCopyright := Value;
    HasChanged := true;
  end;
end;

procedure TC2PPProject.SetDescription(const Value: string);
begin
  if FDescription <> Value then
  begin
    FDescription := Value;
    HasChanged := true;
  end;
end;

procedure TC2PPProject.SetHasChanged(const Value: boolean);
begin
  if (FHasChanged <> Value) then
  begin
    FHasChanged := Value;

    if FIsLoading then
      exit;

    tthread.ForceQueue(nil,
      procedure
      begin
        TMessageManager.DefaultManager.SendMessage(self,
          TC2PPProjectHasChangedMessage.Create(self));
      end);
  end;
end;

procedure TC2PPProject.SetPascalProjectFolder(const Value: string);
begin
  if FPascalProjectFolder <> Value then
  begin
    FPascalProjectFolder := Value;
    HasChanged := true;
  end;
end;

procedure TC2PPProject.SetProjectURL(const Value: string);
begin
  if FProjectURL <> Value then
  begin
    FProjectURL := Value;
    HasChanged := true;
  end;
end;

procedure TC2PPProject.SetSiteURL(const Value: string);
begin
  if FSiteURL <> Value then
  begin
    FSiteURL := Value;
    HasChanged := true;
  end;
end;

end.
