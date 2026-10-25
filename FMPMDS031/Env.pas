//============================================================================
//                           環境設定のフォーム
//                      Copyright & Programmed by C60
//============================================================================
unit Env;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ExtCtrls, BrowsDlg, Speana, PinForm, MMSystem, PMDWin, WinFMP,
	FMPMDDefine, Spin, ComCtrls;

type
  TEnvForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    BrowseDialog1: TBrowseDialog;
    PinForm1: TPinForm;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
		TabSheet2: TTabSheet;
    GroupBox3: TGroupBox;
    Button3: TButton;
		GroupBox1: TGroupBox;
		Button6: TButton;
		ListBox1: TListBox;
    Button7: TButton;
		GroupBox2: TGroupBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox5: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
		CheckBox3: TCheckBox;
    Edit2: TEdit;
    Edit1: TEdit;
    GroupBox7: TGroupBox;
    CheckBox5: TCheckBox;
    GroupBox6: TGroupBox;
		Label4: TLabel;
		Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    CheckBox6: TCheckBox;
		TrackBar1: TTrackBar;
    GroupBox8: TGroupBox;
    Label7: TLabel;
		CheckBox7: TCheckBox;
    SpinEdit3: TSpinEdit;
		GroupBox11: TGroupBox;
    CheckBox8: TCheckBox;
		GroupBox10: TGroupBox;
		Label9: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label10: TLabel;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    SpinEdit7: TSpinEdit;
    GroupBox9: TGroupBox;
    Label3: TLabel;
    SpinEdit2: TSpinEdit;
    GroupBox4: TGroupBox;
    Label2: TLabel;
		CheckBox4: TCheckBox;
		SpinEdit1: TSpinEdit;
		GroupBox12: TGroupBox;
		CheckBox9: TCheckBox;
		RadioButton1: TRadioButton;
		RadioButton2: TRadioButton;
		RadioButton3: TRadioButton;
		RadioButton4: TRadioButton;
		RadioButton5: TRadioButton;
		RadioButton6: TRadioButton;
		RadioButton7: TRadioButton;
		RadioButton8: TRadioButton;
    GroupBox13: TGroupBox;
    CheckBox10: TCheckBox;
    RadioButton9: TRadioButton;
		RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    RadioButton16: TRadioButton;
    GroupBox14: TGroupBox;
		CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    GroupBox15: TGroupBox;
    CheckBox13: TCheckBox;
		procedure Button6Click(Sender: TObject);
		procedure Button7Click(Sender: TObject);
		procedure Edit1KeyPress(Sender: TObject; var Key: Char);
		procedure FormShow(Sender: TObject);
		procedure ComboBox1Change(Sender: TObject);
		procedure ComboBox2Change(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure CheckBox4Click(Sender: TObject);
		procedure CheckBox7Click(Sender: TObject);
		procedure CheckBox9Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
	private
		{ Private 宣言 }
		FDeviceID : UINT;
		FNumOfBuffers : Integer;
		function GetFreq : Integer;
		function GetPPZRate : Integer;
		function GetPPZRateChange : Boolean;
		function GetPCMDir : TStrings;
		function GetRhythmDir : String;
		function GetFMip : Boolean;
		function GetPPSip : Boolean;
		function GetP86ip : Boolean;
		function GetPPZip : Boolean;
		function GetUseHummingWindow : Boolean;
		function GetUseTaskTray : Boolean;
		function GetNumOfBand : TSpeanaLevel;
		function GetFadeOutTime : Integer;
		function GetLoopToFadeOut : Boolean;
		function GetCompressor : Boolean;
		function GetNumOfLoopToFadeOut : Integer;
		function GetCheckMusicLength : Boolean;
		function GetParamDelay : Integer;
		function GetDisplay50Flame : Boolean;
		function GetSnap : Boolean;
		function GetSnapWidth : Integer;
		function GetNoPCMForcePlay : Boolean;
		function GetFMWait : Integer;
		function GetSSGWait : Integer;
		function GetRhythmWait : Integer;
		function GetADPCMWait : Integer;
		procedure SetFreq(Value : Integer);
		procedure SetPPZRate(Value : Integer);
		procedure SetPPZRateChange(Value : Boolean);
		procedure SetRhythmDir(Value : String);
		procedure SetPCMDir(Value : TStrings);
		procedure SetFMip(Value : Boolean);
		procedure SetPPSip(Value : Boolean);
		procedure SetP86ip(Value : Boolean);
		procedure SetPPZip(Value : Boolean);
		procedure SetUseHummingWindow(Value : Boolean);
		procedure SetUseTaskTray(Value : Boolean);
		procedure SetNumOfBand(Value : TSpeanaLevel);
		procedure SetFadeOutTime(Value : Integer);
		procedure SetLoopToFadeOut(Value : Boolean);
		procedure SetCompressor(Value : Boolean);
		procedure SetNumOfLoopToFadeOut(Value : Integer);
		procedure SetCheckMusicLength(Value : Boolean);
		procedure SetParamDelay(Value : Integer);
		procedure SetDisplay50Flame(Value : Boolean);
		procedure SetSnap(Value : Boolean);
		procedure SetSnapWidth(Value : Integer);
    procedure SetNoPCMForcePlay(Value : Boolean);
		procedure SetFMWait(Value : Integer);
		procedure SetSSGWait(Value : Integer);
		procedure SetRhythmWait(Value : Integer);
		procedure SetADPCMWait(Value : Integer);
	public
		{ Public 宣言 }
		property DeviceID : UINT read FDeviceID write FDeviceID;
		property NumofBuffers : Integer read FNumOfBuffers write FNumOfBuffers;
		property Freq : Integer read GetFreq write SetFreq;
		property PPZRate : Integer read GetPPZRate write SetPPZRate;
		property PPZRateChange : Boolean read GetPPZRateChange write SetPPZRateChange;
		property PCMDir : TStrings read GetPCMDir write SetPCMDir;
		property RhythmDir : String read GetRhythmDir write SetRhythmDir;
		property FMip  : Boolean read GetFMip  write SetFMip;
		property PPSip : Boolean read GetPPSip write SetPPSip;
		property P86ip : Boolean read GetP86ip write SetP86ip;
		property PPZip : Boolean read GetPPZip write SetPPZip;
		property UseHummingWindow : Boolean read GetUseHummingWindow write SetUseHummingWindow;
    property UseTaskTray : Boolean read GetUseTaskTray write SetUseTaskTray;
		property NumOfBand : TSpeanaLevel read GetNumOfBand write SetNumOfBand;
		property FadeOutTime : Integer read GetFadeOutTime write SetFadeOutTime;
		property LoopToFadeOut : Boolean read GetLoopToFadeOut write SetLoopToFadeOut;
		property Compressor : Boolean read GetCompressor write SetCompressor;
		property NumOfLoopToFadeOut : Integer read GetNumOfLoopToFadeOut write SetNumOfLoopToFadeOut;
		property CheckMusicLength : Boolean read GetCheckMusicLength write SetCheckMusicLength;
		property ParamDelay : Integer read GetParamDelay write SetParamDelay;
		property Display50Flame : Boolean read GetDisplay50Flame write SetDisplay50Flame;
		property Snap : Boolean read GetSnap write SetSnap;
		property SnapWidth : Integer read GetSnapWidth write SetSnapWidth;
		property NoPCMForcePlay : Boolean read GetNoPCMForcePlay write SetNoPCMForcePlay;
		property FMWait : Integer read GetFMWait write SetFMWait;
		property SSGWait : Integer read GetSSGWait write SetSSGWait;
		property RhythmWait : Integer read GetRhythmWait write SetRhythmWait;
		property ADPCMWait : Integer read GetADPCMWait write SetADPCMWait;
	end;

var
	EnvForm: TEnvForm;

implementation

{$R *.DFM}


//***************************************************************************
// コンストラクタ
//***************************************************************************
procedure TEnvForm.FormActivate(Sender: TObject);
begin
	// Delphi 2 以外だったら TrackBar の太さを調整する
{$IFNDEF VER90}
	TrackBar1.ThumbLength := 14;
{$ENDIF}
end;


//***************************************************************************
// pcmdirの参照
//***************************************************************************
procedure TEnvForm.Button6Click(Sender: TObject);
begin


	if(BrowseDialog1.Execute = False) then Exit;
	if(ListBox1.Items.Count >= MAX_PCMDIR) then begin
		ShowMessage('これ以上設定できません.');
	end;
	ListBox1.Items.Add(BrowseDialog1.Directory);
end;


//***************************************************************************
// RhythmDir の参照
//***************************************************************************
procedure TEnvForm.Button3Click(Sender: TObject);
begin
	if(BrowseDialog1.Execute = False) then Exit;
  Edit2.text := BrowseDialog1.Directory;
end;


//***************************************************************************
// ListBoxの項目削除
//***************************************************************************
procedure TEnvForm.Button7Click(Sender: TObject);
begin
	if(ListBox1.ItemIndex = -1) then Exit;		// 選択されていない
	ListBox1.Items.Delete(ListBox1.ItemIndex);
end;


//***************************************************************************
// PCMdir の入力が終了したとき
//***************************************************************************
procedure TEnvForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
	if(Key <> #13) then Exit;

	if(ListBox1.Items.Count >= MAX_PCMDIR) then begin
  	ShowMessage('これ以上設定できません.');
  end else begin
	  ListBox1.Items.Add(Edit1.Text);
	end;
	Edit1.Text := '';
end;


//***************************************************************************
// Freq の取得
//***************************************************************************
function TEnvForm.GetFreq : Integer;
begin
	if(RadioButton9.Checked = True) then begin
		Result := SOUND_48K;
	end else if(RadioButton10.Checked = True) then begin
		Result := SOUND_44K;
	end else if(RadioButton11.Checked = True) then begin
		Result := SOUND_22K;
	end else if(RadioButton12.Checked = True) then begin
		Result := SOUND_11K;
	end else begin
		Result := SOUND_44K;
	end;
end;


//***************************************************************************
// PPZRate の取得
//***************************************************************************
function TEnvForm.GetPPZRate : Integer;
begin
	if(RadioButton1.Checked = True) then begin
		Result := PPZ8_i0;
	end else if(RadioButton2.Checked = True) then begin
		Result := PPZ8_i1;
	end else if(RadioButton3.Checked = True) then begin
		Result := PPZ8_i2;
	end else if(RadioButton4.Checked = True) then begin
		Result := PPZ8_i3;
	end else if(RadioButton5.Checked = True) then begin
		Result := PPZ8_i4;
	end else if(RadioButton6.Checked = True) then begin
		Result := PPZ8_i5;
	end else if(RadioButton7.Checked = True) then begin
		Result := PPZ8_i6;
	end else if(RadioButton8.Checked = True) then begin
		Result := PPZ8_i7;
	end else begin
		Result := PPZ8_i0;
	end;
end;


//***************************************************************************
// PPZ8 駆動周波数を出力周波数とあわせるかどうかを取得
//***************************************************************************
function TEnvForm.GetPPZRateChange : Boolean;
begin
	result := not CheckBox9.Checked;
end;


//***************************************************************************
// PCMdir の取得
//***************************************************************************
function TEnvForm.GetPCMDir : TStrings;
begin
	result := ListBox1.Items;
end;


//***************************************************************************
// Rhythmdir の取得
//***************************************************************************
function TEnvForm.GetRhythmDir : String;
begin
	result := Edit2.Text;
end;


//***************************************************************************
// FMip の取得
//***************************************************************************
function TEnvForm.GetFMip : Boolean;
begin
	result := CheckBox10.Checked;
end;


//***************************************************************************
// PPSip の取得
//***************************************************************************
function TEnvForm.GetPPSip : Boolean;
begin
	result := CheckBox1.Checked;
end;


//***************************************************************************
// P86ip の取得
//***************************************************************************
function TEnvForm.GetP86ip : Boolean;
begin
	result := CheckBox2.Checked;
end;


//***************************************************************************
// PPZ8ip の取得
//***************************************************************************
function TEnvForm.GetPPZip : Boolean;
begin
	result := CheckBox3.Checked;
end;


//***************************************************************************
// UseHummingWindow の取得
//***************************************************************************
function TEnvForm.GetUseHummingWindow : Boolean;
begin
	result := CheckBox8.Checked;
end;


//***************************************************************************
// UseTaskTray の取得
//***************************************************************************
function TEnvForm.GetUseTaskTray : Boolean;
begin
	result := CheckBox13.Checked;
end;


//***************************************************************************
// NumOfBand の取得
//***************************************************************************
function TEnvForm.GetNumOfBand : TSpeanaLevel;
begin
	if(RadioButton13.Checked = True) then begin
		Result := SPLow;
	end else if(RadioButton14.Checked = True) then begin
		Result := SPMiddle;
	end else if(RadioButton15.Checked = True) then begin
		Result := SPHigh;
	end else if(RadioButton16.Checked = True) then begin
		Result := SPSuper;
	end else begin
		Result := SPHigh;
	end;
end;


//***************************************************************************
// FadeOutTime の取得
//***************************************************************************
function TEnvForm.GetFadeOutTime : Integer;
begin
	result := SpinEdit1.Value;
end;


//***************************************************************************
// LoopToFadeOut の取得
//***************************************************************************
function TEnvForm.GetLoopToFadeOut : Boolean;
begin
	result := CheckBox4.Checked;
end;


//***************************************************************************
// Compressor の取得
//***************************************************************************
function TEnvForm.GetCompressor : Boolean;
begin
	result := CheckBox11.Checked;
end;


//***************************************************************************
// NumOfLoopToFadeOut の取得
//***************************************************************************
function TEnvForm.GetNumOfLoopToFadeOut : Integer;
begin
	result := SpinEdit2.Value;
end;


//***************************************************************************
// CheckMusicLength の取得
//***************************************************************************
function TEnvForm.GetCheckMusicLength : Boolean;
begin
	result := CheckBox5.Checked;
end;


//***************************************************************************
// ParamDelay の取得
//***************************************************************************
function TEnvForm.GetParamDelay : Integer;
begin
	result := TrackBar1.Position;
end;


//***************************************************************************
// Display50Flame の取得
//***************************************************************************
function TEnvForm.GetDisplay50Flame : Boolean;
begin
	result := CheckBox6.Checked;
end;


//***************************************************************************
// Snap の取得
//***************************************************************************
function TEnvForm.GetSnap : Boolean;
begin
	result := CheckBox7.Checked;
end;


//***************************************************************************
// SnapWidth の取得
//***************************************************************************
function TEnvForm.GetSnapWidth : Integer;
begin
	result := SpinEdit3.Value;
end;


//***************************************************************************
// NoPCMForcePlay の取得
//***************************************************************************
function TEnvForm.GetNoPCMForcePlay : Boolean;
begin
	result := CheckBox12.Checked;
end;


//***************************************************************************
// FMWait の取得
//***************************************************************************
function TEnvForm.GetFMWait : Integer;
begin
	result := SpinEdit4.Value;
end;


//***************************************************************************
// SSGWait の取得
//***************************************************************************
function TEnvForm.GetSSGWait : Integer;
begin
	result := SpinEdit5.Value;
end;


//***************************************************************************
// RhythmWait の取得
//***************************************************************************
function TEnvForm.GetRhythmWait : Integer;
begin
	result := SpinEdit6.Value;
end;


//***************************************************************************
// ADPCMWait の取得
//***************************************************************************
function TEnvForm.GetADPCMWait : Integer;
begin
	result := SpinEdit7.Value;
end;


//***************************************************************************
// Freq の設定
//***************************************************************************
procedure TEnvForm.SetFreq(Value : Integer);
begin
	if(Value = SOUND_48K) then begin
		RadioButton9.Checked := True;
	end else if(Value = SOUND_44K) then begin
		RadioButton10.Checked := True;
	end else if(Value = SOUND_22K) then begin
		RadioButton11.Checked := True;
	end else if(Value = SOUND_11K) then begin
		RadioButton12.Checked := True;
	end;
end;



//***************************************************************************
// PPZRate の設定
//***************************************************************************
procedure TEnvForm.SetPPZRate(Value : Integer);
begin
	if(Value = PPZ8_i0) then begin
		RadioButton1.Checked := True;
	end else if(Value = PPZ8_i1) then begin
		RadioButton2.Checked := True;
	end else if(Value = PPZ8_i2) then begin
		RadioButton3.Checked := True;
	end else if(Value = PPZ8_i3) then begin
		RadioButton4.Checked := True;
	end else if(Value = PPZ8_i4) then begin
		RadioButton5.Checked := True;
	end else if(Value = PPZ8_i5) then begin
		RadioButton6.Checked := True;
	end else if(Value = PPZ8_i6) then begin
		RadioButton7.Checked := True;
	end else if(Value = PPZ8_i7) then begin
		RadioButton8.Checked := True;
	end else begin
		RadioButton1.Checked := True;
	end;
end;


//***************************************************************************
// PPZ8 駆動周波数を出力周波数とあわせるかどうかを設定
//***************************************************************************
procedure TEnvForm.SetPPZRateChange(Value : Boolean);
begin
	CheckBox9.Checked := not Value;
end;


//***************************************************************************
// PCMdir の設定
//***************************************************************************
procedure TEnvForm.SetPCMDir(Value : TStrings);
begin
	ListBox1.Items.Assign(Value);
end;


//***************************************************************************
// Rhythmdir の設定
//***************************************************************************
procedure TEnvForm.SetRhythmDir(Value : String);
begin
	Edit2.Text := Value;
end;


//***************************************************************************
// FMip の設定
//***************************************************************************
procedure TEnvForm.SetFMip(Value : Boolean);
begin
	CheckBox10.Checked := Value;
end;


//***************************************************************************
// PPSip の設定
//***************************************************************************
procedure TEnvForm.SetPPSip(Value : Boolean);
begin
	CheckBox1.Checked := Value;
end;


//***************************************************************************
// P86ip の設定
//***************************************************************************
procedure TEnvForm.SetP86ip(Value : Boolean);
begin
	CheckBox2.Checked := Value;
end;


//***************************************************************************
// PPZip の設定
//***************************************************************************
procedure TEnvForm.SetPPZip(Value : Boolean);
begin
	CheckBox3.Checked := Value;
end;


//***************************************************************************
// UseHummingWindow の設定
//***************************************************************************
procedure TEnvForm.SetUseHummingWindow(Value : Boolean);
begin
	CheckBox8.Checked := Value;
end;


//***************************************************************************
// UseTaskTray の設定
//***************************************************************************
procedure TEnvForm.SetUseTaskTray(Value : Boolean);
begin
	CheckBox13.Checked := Value;
end;


//***************************************************************************
// NumOfBand の設定
//***************************************************************************
procedure TEnvForm.SetNumOfBand(Value : TSpeanaLevel);
begin
	case Value of
		SPLow    : RadioButton13.Checked := True;
		SPMiddle : RadioButton14.Checked := True;
		SPHigh   : RadioButton15.Checked := True;
		SPSuper  : RadioButton16.Checked := True;
		else       RadioButton16.Checked := True;
	end;
end;


//***************************************************************************
// FadeOutTime の設定
//***************************************************************************
procedure TEnvForm.SetFadeOutTime(Value : Integer);
begin
	SpinEdit1.Value := Value;
end;


//***************************************************************************
// LoopToFadeOut の設定
//***************************************************************************
procedure TEnvForm.SetLoopToFadeOut(Value : Boolean);
begin
	CheckBox4.Checked := Value;
end;


//***************************************************************************
// Compressor の設定
//***************************************************************************
procedure TEnvForm.SetCompressor(Value : Boolean);
begin
	CheckBox11.Checked := Value;
end;


//***************************************************************************
// NumOfLoopToFadeOut の設定
//***************************************************************************
procedure TEnvForm.SetNumOfLoopToFadeOut(Value : Integer);
begin
	SpinEdit2.Value := Value;
end;


//***************************************************************************
// CheckMusicLength の設定
//***************************************************************************
procedure TEnvForm.SetCheckMusicLength(Value : Boolean);
begin
	CheckBox5.Checked := Value;
end;


//***************************************************************************
// ParamDelay の設定
//***************************************************************************
procedure TEnvForm.SetParamDelay(Value : Integer);
begin
	TrackBar1.Position := Value;
end;


//***************************************************************************
// Display50Flame の設定
//***************************************************************************
procedure TEnvForm.SetDisplay50Flame(Value : Boolean);
begin
	CheckBox6.Checked := Value;
end;


//***************************************************************************
// Snap の設定
//***************************************************************************
procedure TEnvForm.SetSnap(Value : Boolean);
begin
	CheckBox7.Checked := Value;
end;


//***************************************************************************
// SnapWidth の設定
//***************************************************************************
procedure TEnvForm.SetSnapWidth(Value : Integer);
begin
	SpinEdit3.Value := Value;
end;


//***************************************************************************
// NoPCMForcePlay の設定
//***************************************************************************
procedure TEnvForm.SetNoPCMForcePlay(Value : Boolean);
begin
	CheckBox12.Checked := Value;
end;


//***************************************************************************
// FMWait の設定
//***************************************************************************
procedure TEnvForm.SetFMWait(Value : Integer);
begin
	SpinEdit4.Value := Value;
end;


//***************************************************************************
// SSGWait の設定
//***************************************************************************
procedure TEnvForm.SetSSGWait(Value : Integer);
begin
	SpinEdit5.Value := Value;
end;


//***************************************************************************
// RhythmWait の設定
//***************************************************************************
procedure TEnvForm.SetRhythmWait(Value : Integer);
begin
	SpinEdit6.Value := Value;
end;


//***************************************************************************
// ADPCMWait の設定
//***************************************************************************
procedure TEnvForm.SetADPCMWait(Value : Integer);
begin
	SpinEdit7.Value := Value;
end;


//***************************************************************************
// OnShow(Freq 等の設定)
//***************************************************************************
procedure TEnvForm.FormShow(Sender: TObject);
var
	WaveOutCaps: TWaveOutCaps;
	i : Integer;
begin
	Edit1.Text := '';

	ComboBox1.Items.Clear;
	ComboBox1.Items.Add('Wave Mapper');
  for i := 0 to waveOutGetNumDevs-1 do begin
	  waveOutGetDevCaps(i, @WaveOutCaps, sizeof(WaveOutCaps));
		ComboBox1.Items.Add(string(WaveOutCaps.szPname));
  end;

  if(FDeviceID = WAVE_MAPPER) then begin
  	ComboBox1.ItemIndex := 0;
  end else begin
  	ComboBox1.ItemIndex := FDeviceID + 1;
  end;

	if(FNumOfBuffers <= 2) then begin
		ComboBox2.ItemIndex := 0;
  end else begin
		ComboBox2.ItemIndex := (FNumOfBuffers + 3) div 4
  end;
end;


//***************************************************************************
// DeviceID を変更した
//***************************************************************************
procedure TEnvForm.ComboBox1Change(Sender: TObject);
begin
	FDeviceID := ComboBox1.ItemIndex - 1;
end;


//***************************************************************************
// Buffer 数を変更した
//***************************************************************************
procedure TEnvForm.ComboBox2Change(Sender: TObject);
begin
	FNumOfBuffers := StrToInt(ComboBox2.Text);
end;


//***************************************************************************
// PPZ8 駆動周波数を出力周波数とそろえるかどうかのチェックボックスを変更した
//***************************************************************************
procedure TEnvForm.CheckBox9Click(Sender: TObject);
begin
	if(CheckBox9.Checked = True) then begin
		RadioButton1.Enabled := False;
		RadioButton2.Enabled := False;
		RadioButton3.Enabled := False;
		RadioButton4.Enabled := False;
		RadioButton5.Enabled := False;
		RadioButton6.Enabled := False;
		RadioButton7.Enabled := False;
		RadioButton8.Enabled := False;
	end else begin
		RadioButton1.Enabled := True;
		RadioButton2.Enabled := True;
		RadioButton3.Enabled := True;
		RadioButton4.Enabled := True;
		RadioButton5.Enabled := True;
		RadioButton6.Enabled := True;
		RadioButton7.Enabled := True;
		RadioButton8.Enabled := True;
	end;
end;


//***************************************************************************
// フェードアウトするかどうかのチェックボックスを変更した
//***************************************************************************
procedure TEnvForm.CheckBox4Click(Sender: TObject);
begin
//	Label3.Enabled := CheckBox4.Checked;
//	SpinEdit2.Enabled := CheckBox4.Checked;
end;


//***************************************************************************
// Delete キーを押した
//***************************************************************************
procedure TEnvForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	if(Key = VK_DELETE) then begin
		if(ListBox1.ItemIndex >= 0) then begin
			ListBox1.Items.Delete(ListBox1.ItemIndex);
		end;
	end;
end;


//***************************************************************************
// フェードアウトするかどうかのチェックボックスを変更した
//***************************************************************************
procedure TEnvForm.CheckBox7Click(Sender: TObject);
begin
	SpinEdit3.Enabled := CheckBox7.Checked;
	Label7.Enabled := CheckBox7.Checked;
end;


end.
