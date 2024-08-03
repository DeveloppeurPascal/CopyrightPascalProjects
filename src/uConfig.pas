unit uConfig;

interface

type
  TConfig = class
  private
    class procedure SetDefaultCopyright(const Value: string); static;
    class procedure SetDefaultSummary(const Value: string); static;
    class function GetDefaultCopyright: string; static;
    class function GetDefaultSummary: string; static;
    class function GetDefaultPascalProjectFolder: string; static;
    class procedure SetDefaultPascalProjectFolder(const Value: string); static;
  protected
  public
    class property DefaultSummary: string read GetDefaultSummary
      write SetDefaultSummary;
    class property DefaultCopyright: string read GetDefaultCopyright
      write SetDefaultCopyright;
    class property DefaultPascalProjectFolder: string
      read GetDefaultPascalProjectFolder write SetDefaultPascalProjectFolder;
    class procedure Save;
    class procedure Cancel;
  end;

implementation

uses
{$IFDEF RELEASE}
  System.Classes,
  System.Types,
{$ENDIF}
  System.IOUtils,
  System.SysUtils,
  Olf.RTL.Params,
  Olf.RTL.CryptDecrypt;

procedure InitConfig;
begin
  tparams.InitDefaultFileNameV2('OlfSoftware',
    'CopyrightPascalProjects', false);
{$IFDEF RELEASE}
  tparams.onCryptProc := function(Const AParams: string): TStream
    var
      Keys: TByteDynArray;
      ParStream: TStringStream;
    begin
      ParStream := TStringStream.Create(AParams);
      try
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}
        result := TOlfCryptDecrypt.XORCrypt(ParStream, Keys);
      finally
        ParStream.free;
      end;
    end;
  tparams.onDecryptProc := function(Const AStream: TStream): string
    var
      Keys: TByteDynArray;
      Stream: TStream;
      StringStream: TStringStream;
    begin
{$I '..\_PRIVATE\src\ConfigFileXORKey.inc'}
      result := '';
      Stream := TOlfCryptDecrypt.XORdeCrypt(AStream, Keys);
      try
        if assigned(Stream) and (Stream.Size > 0) then
        begin
          StringStream := TStringStream.Create;
          try
            Stream.Position := 0;
            StringStream.CopyFrom(Stream);
            result := StringStream.DataString;
          finally
            StringStream.free;
          end;
        end;
      finally
        Stream.free;
      end;
    end;
{$ENDIF}
  tparams.Load;
end;

{ TConfig }

class procedure TConfig.Cancel;
begin
  tparams.Cancel;
end;

class function TConfig.GetDefaultCopyright: string;
begin
  result := tparams.getValue('DC', '');
end;

class function TConfig.GetDefaultPascalProjectFolder: string;
var
  LDefaultDelphiProjectsFolder: string;
begin
  result := tparams.getValue('DPF', '');
  if result.IsEmpty then
  begin
    LDefaultDelphiProjectsFolder := tpath.Combine(tpath.GetDocumentsPath,
      'Embarcadero', 'Studio', 'Projets');
    if TDirectory.Exists(LDefaultDelphiProjectsFolder) then
      result := LDefaultDelphiProjectsFolder;
  end;
end;

class function TConfig.GetDefaultSummary: string;
begin
  result := tparams.getValue('DS', '');
end;

class procedure TConfig.Save;
begin
  tparams.Save;
end;

class procedure TConfig.SetDefaultCopyright(const Value: string);
begin
  tparams.setValue('DC', Value);
end;

class procedure TConfig.SetDefaultPascalProjectFolder(const Value: string);
begin
  tparams.setValue('DPF', Value);
end;

class procedure TConfig.SetDefaultSummary(const Value: string);
begin
  tparams.setValue('DS', Value);
end;

initialization

InitConfig;

finalization

end.
