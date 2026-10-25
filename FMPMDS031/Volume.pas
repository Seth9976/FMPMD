//============================================================================
//                            音量設定用フォーム
//                      Copyright & Programmed by C60
//============================================================================
unit Volume;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, StdCtrls, CommCtrl, ShellAPI, Extrkbar, PMDWin, WinFMP, PinForm,
	IniFiles, Main, FMPMDPlayDefine;

type
  TVolumeForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    TrackBar1: TExtTrackBar;
    Label8: TLabel;
		PinForm1: TPinForm;
    TrackBar2: TExtTrackBar;
    Label9: TLabel;
		TrackBar3: TExtTrackBar;
    Label10: TLabel;
    TrackBar4: TExtTrackBar;
    Label11: TLabel;
    Label5: TLabel;
		TrackBar5: TExtTrackBar;
    Label12: TLabel;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
		procedure TrackBar5Change(Sender: TObject);
		procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private 宣言 }
		// WinFMP, PMDWin の function(共用部)
		c_setfmvoldown : procedure(voldown : Integer); stdcall;
		c_setssgvoldown : procedure(voldown : Integer); stdcall;
		c_setrhythmvoldown : procedure(voldown : Integer); stdcall;
		c_setadpcmvoldown : procedure(voldown : Integer); stdcall;
		c_setppzvoldown : procedure(voldown : Integer); stdcall;
		c_getfmvoldown : function : Integer; stdcall;
		c_getssgvoldown : function : Integer; stdcall;
		c_getrhythmvoldown : function : Integer; stdcall;
		c_getadpcmvoldown : function : Integer; stdcall;
		c_getppzvoldown : function : Integer; stdcall;
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		procedure Driver_Change(var Msg : TMessage); message WM_DRIVERCHANDE;
		procedure SetNowVolume(var Msg:TMessage); message WM_SetVolDown;
		function GetFMVolume : Integer;
		function GetSSGVolume : Integer;
		function GetRhythmVolume : Integer;
		function GetADPCMVolume : Integer;
		function GetPPZVolume : Integer;
		procedure SetFMVolume(value : Integer);
		procedure SetSSGVolume(value : Integer);
		procedure SetRhythmVolume(value : Integer);
		procedure SetADPCMVolume(value : Integer);
		procedure SetPPZVolume(value : Integer);

	public
		{ Public 宣言 }
		property FMVolumeDown : Integer read GetFMVolume write SetFMVolume;
		property SSGVolumeDown : Integer read GetSSGVolume write SetSSGVolume;
		property RhythmVolumeDown : Integer read GetRhythmVolume write SetRhythmVolume;
		property ADPCMVolumeDown : Integer read GetADPCMVolume write SetADPCMVolume;
		property PPZVolumeDown : Integer read GetPPZVolume write SetPPZVolume;
	end;

var
	VolumeForm: TVolumeForm;

implementation

{$R *.DFM}


//***************************************************************************
// Form の生成
//***************************************************************************
procedure TVolumeForm.FormCreate(Sender: TObject);
begin
	DragAcceptFiles(Handle, True);

	// とりあえず PMDWin 側に設定
	c_setfmvoldown := setfmvoldown;
	c_setssgvoldown := setssgvoldown;
	c_setrhythmvoldown := setrhythmvoldown;
	c_setadpcmvoldown := setadpcmvoldown;
	c_setppzvoldown := setppzvoldown;
	c_getfmvoldown := getfmvoldown;
	c_getssgvoldown := getssgvoldown;
	c_getrhythmvoldown := getrhythmvoldown;
	c_getadpcmvoldown := getadpcmvoldown;
	c_getppzvoldown := getppzvoldown;

{$IFNDEF VER90}
  // Delphi 2 以外だったら TrackBar の太さを調整する
	TrackBar1.ThumbLength := 12;
	TrackBar2.ThumbLength := 12;
	TrackBar3.ThumbLength := 12;
	TrackBar4.ThumbLength := 12;
  TrackBar5.ThumbLength := 12;
{$ENDIF}
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure TVolumeForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
begin
	if(FMPMDForm.Snap = True) then begin
		Msg.WindowPos^.x := (Msg.WindowPos^.x div FMPMDForm.SnapWidth) * FMPMDForm.SnapWidth;
		Msg.WindowPos^.y := (Msg.WindowPos^.y div FMPMDForm.SnapWidth) * FMPMDForm.SnapWidth;
	end;

  inherited;
end;


//***************************************************************************
// Window への D&D
//***************************************************************************
procedure TVolumeForm.DropFiles(var Msg:TWMDROPFILES);
begin
	FMPMDForm.DropFiles(Msg);
end;


//***************************************************************************
// フォームを開いたとき
//***************************************************************************
procedure TVolumeForm.FormActivate(Sender: TObject);
begin
	FMPMDForm.VolumeMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure TVolumeForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FMPMDForm.VolumeMenu.Checked := False;
end;


//***************************************************************************
// ドライバー変更
//***************************************************************************
procedure TVolumeForm.Driver_Change(var Msg : TMessage);
begin
	if(Msg.WParam = WPARAM(DRIVER_FMP)) then begin
		c_setfmvoldown := fmp_setfmvoldown;
		c_setssgvoldown := fmp_setssgvoldown;
		c_setrhythmvoldown := fmp_setrhythmvoldown;
		c_setadpcmvoldown := fmp_setadpcmvoldown;
		c_setppzvoldown := fmp_setppzvoldown;
		c_getfmvoldown := fmp_getfmvoldown;
		c_getssgvoldown := fmp_getssgvoldown;
		c_getrhythmvoldown := fmp_getrhythmvoldown;
		c_getadpcmvoldown := fmp_getadpcmvoldown;
		c_getppzvoldown := fmp_getppzvoldown;
		TrackBar1.Min := -99;
		TrackBar2.Min := -15;
		TrackBar3.Min := -63;
		TrackBar4.Min := -99;
//		TrackBar5.Min := -15;
		TrackBar5.Enabled := False;
		Label5.Enabled := False;
		Label12.Enabled := False;
	end else begin
		c_setfmvoldown := setfmvoldown;
		c_setssgvoldown := setssgvoldown;
		c_setrhythmvoldown := setrhythmvoldown;
		c_setadpcmvoldown := setadpcmvoldown;
		c_setppzvoldown := setppzvoldown;
		c_getfmvoldown := getfmvoldown;
		c_getssgvoldown := getssgvoldown;
		c_getrhythmvoldown := getrhythmvoldown;
		c_getadpcmvoldown := getadpcmvoldown;
		c_getppzvoldown := getppzvoldown;
		TrackBar1.Min := -255;
		TrackBar2.Min := -255;
		TrackBar3.Min := -255;
		TrackBar4.Min := -255;
//		TrackBar5.Min := -255;
		TrackBar5.Enabled := True;
		Label5.Enabled := True;
		Label12.Enabled := True;
	end;
	TrackBar1.Position := c_getfmvoldown;
	TrackBar2.Position := c_getssgvoldown;
	TrackBar3.Position := c_getrhythmvoldown;
	TrackBar4.Position := c_getadpcmvoldown;
	TrackBar5.Position := c_getppzvoldown;
end;


//***************************************************************************
// FM Volume Down
//***************************************************************************
procedure TVolumeForm.TrackBar1Change(Sender: TObject);
begin
	Label8.Caption := IntToStr(TrackBar1.Position);
	EnterCriticalSection(Sect1);
	try
		c_setfmvoldown(-TrackBar1.Position);
	finally
		LeaveCriticalSection(Sect1);
	end;
end;


//***************************************************************************
// SSG Volume Down
//***************************************************************************
procedure TVolumeForm.TrackBar2Change(Sender: TObject);
begin
	Label9.Caption := IntToStr(TrackBar2.Position);
	EnterCriticalSection(Sect1);
	try
		c_setssgvoldown(-TrackBar2.Position);
	finally
		LeaveCriticalSection(Sect1);
	end;
end;


//***************************************************************************
// Rhythm Volume Down
//***************************************************************************
procedure TVolumeForm.TrackBar3Change(Sender: TObject);
begin
	Label10.Caption := IntToStr(TrackBar3.Position);
	EnterCriticalSection(Sect1);
	try
		c_setrhythmvoldown(-TrackBar3.Position);
	finally
		LeaveCriticalSection(Sect1);
	end;
end;


//***************************************************************************
// ADPCM Volume Down
//***************************************************************************
procedure TVolumeForm.TrackBar4Change(Sender: TObject);
begin
	Label11.Caption := IntToStr(TrackBar4.Position);
	EnterCriticalSection(Sect1);
	try
		c_setadpcmvoldown(-TrackBar4.Position);
	finally
		LeaveCriticalSection(Sect1);
	end;
end;


//***************************************************************************
// PPZ Volume Down
//***************************************************************************
procedure TVolumeForm.TrackBar5Change(Sender: TObject);
begin
	Label12.Caption := IntToStr(TrackBar5.Position);
	EnterCriticalSection(Sect1);
	try
		c_setppzvoldown(-TrackBar5.Position);
	finally
		LeaveCriticalSection(Sect1);
	end;
end;


//***************************************************************************
// Property 取得
//***************************************************************************
function TVolumeForm.GetFMVolume : Integer;
begin
	result := -TrackBar1.Position;
end;


function TVolumeForm.GetSSGVolume : Integer;
begin
	result := -TrackBar2.Position;
end;


function TVolumeForm.GetRhythmVolume : Integer;
begin
	result := -TrackBar3.Position;
end;


function TVolumeForm.GetADPCMVolume : Integer;
begin
	result := -TrackBar4.Position;
end;


function TVolumeForm.GetPPZVolume : Integer;
begin
	result := -TrackBar5.Position;
end;


//***************************************************************************
// Property 設定
//***************************************************************************
procedure TVolumeForm.SetFMVolume(value : Integer);
begin
	TrackBar1.Position := -value;
	Label8.Caption := IntToStr(TrackBar1.Position);
end;


procedure TVolumeForm.SetSSGVolume(value : Integer);
begin
	TrackBar2.Position := -value;
	Label9.Caption := IntToStr(TrackBar2.Position);
end;


procedure TVolumeForm.SetRhythmVolume(value : Integer);
begin
	TrackBar3.Position := -value;
	Label10.Caption := IntToStr(TrackBar3.Position);
end;


procedure TVolumeForm.SetADPCMVolume(value : Integer);
begin
	TrackBar4.Position := -value;
	Label11.Caption := IntToStr(TrackBar4.Position);
end;


procedure TVolumeForm.SetPPZVolume(value : Integer);
begin
	TrackBar5.Position := -value;
	Label12.Caption := IntToStr(TrackBar5.Position);
end;


//***************************************************************************
// すべてのパートの Voldown を WinFMP or PMDWin から読み出してスライダーに設定
//***************************************************************************
procedure TVolumeForm.SetNowVolume;
var
	Value : Integer;
begin
	EnterCriticalSection(Sect1);
	try
		Value := c_getfmvoldown;
	  TrackBar1.Position := -Value;
		Label8.Caption := IntToStr(-Value);

		Value := c_getssgvoldown;
	  TrackBar2.Position := -Value;
		Label9.Caption := IntToStr(-Value);

		Value := c_getrhythmvoldown;
		TrackBar3.Position := -Value;
		Label10.Caption := IntToStr(-Value);

		Value := c_getadpcmvoldown;
		TrackBar4.Position := -Value;
		Label11.Caption := IntToStr(-Value);

		Value := c_getppzvoldown;
		TrackBar5.Position := -Value;
		Label12.Caption := IntToStr(-Value);
	finally
		LeaveCriticalSection(Sect1);
	end;
end;


end.

