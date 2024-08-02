unit uProjectC2PP;

interface

uses
  System.Messaging,
  System.Classes,
  System.Generics.Collections;

const
  CProjectFileVersion = 20240802;

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
    procedure SetAuthor(const Value: string);
    procedure SetCopyright(const Value: string);
    procedure SetDescription(const Value: string);
    procedure SetProjectURL(const Value: string);
    procedure SetSiteURL(const Value: string);
    function GetFileName: string;
    procedure SetHasChanged(const Value: boolean);
  protected
  public
    property HasChanged: boolean read FHasChanged write SetHasChanged;
    property FilePath: string read FFilePath;
    property FileName: string read GetFileName;
    property Description: string read FDescription write SetDescription;
    property Copyright: string read FCopyright write SetCopyright;
    property Author: string read FAuthor write SetAuthor;
    property SiteURL: string read FSiteURL write SetSiteURL;
    property ProjectURL: string read FProjectURL write SetProjectURL;
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
