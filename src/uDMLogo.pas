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
  Signature : 20504f128f23090648da54cf7caaf3d58f43577c
  ***************************************************************************
*)

unit uDMLogo;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList;

type
  TdmLogo = class(TDataModule)
    ilLogo: TImageList;
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  dmLogo: TdmLogo;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
