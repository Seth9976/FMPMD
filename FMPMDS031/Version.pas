//============================================================================
//                        バージョン表示用フォーム
//                      Copyright & Programmed by C60
//============================================================================
unit Version;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ExtCtrls, FMPMDPlayDefine, PMDWin, WinFMP;

type
  TVersionForm = class(TForm)
    Panel1: TPanel;
    ProductName: TLabel;
    VersionLabel: TLabel;
    Copyright: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    Image1: TImage;
    PMDWinVersionLabel: TLabel;
    WinFMPVersionLabel: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  VersionForm: TVersionForm;

implementation

{$R *.DFM}

procedure TVersionForm.FormShow(Sender: TObject);
begin
	VersionLabel.Caption := 'Version ' + Format('%3.2f', [FMPMD_Version / 100.0]);
	WinFMPVersionLabel.Caption := 'WinFMP.dll : Version '
			+ Format('%3.2f', [fmp_getversion / 100.0]);
	PMDWinVersionLabel.Caption := 'PMDWin.dll : Version '
			+ Format('%3.2f', [getversion / 100.0]);
end;

end.
