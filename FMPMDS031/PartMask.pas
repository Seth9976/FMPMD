//============================================================================
//                            PartMask フォーム
//                      Copyright & Programmed by C60
//============================================================================
unit PartMask;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ShellAPI, PinForm, WinFMP, PMDWin, FMPMDPlayDefine;

type
  TPartMaskForm = class(TForm)
    Label1: TLabel;
    CheckBox1: TCheckBox;
		CheckBox2: TCheckBox;
		CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
		Label4: TLabel;
    Label3: TLabel;
    CheckBox7: TCheckBox;
		CheckBox8: TCheckBox;
		CheckBox9: TCheckBox;
		Label5: TLabel;
		CheckBox13: TCheckBox;
		Label6: TLabel;
		CheckBox14: TCheckBox;
		Label8: TLabel;
		CheckBox15: TCheckBox;
		CheckBox16: TCheckBox;
		CheckBox17: TCheckBox;
		CheckBox18: TCheckBox;
		CheckBox19: TCheckBox;
		CheckBox20: TCheckBox;
		CheckBox21: TCheckBox;
		CheckBox22: TCheckBox;
		Button8: TButton;
		Button9: TButton;
		PinForm1: TPinForm;
		procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
		procedure Button9Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private 宣言 }
		FOnChanged : TNotifyEvent;
		FPlayDriver : TPlayDriver;			// 現在演奏しているファイルの種類(FMP or PMD)
		FEnablePartMask : Boolean;			// キーによるパートマスクを許可するか？
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		procedure Driver_Change(var Msg : TMessage); message WM_DRIVERCHANDE;
		procedure AppOnMessage(var Msg: TMsg; var Handled: Boolean);
		procedure CheckAllPartMask;
		function c_maskon(ch : Integer) : Integer;				// FMP, PMD 共通 maskon
		function c_maskoff(ch : Integer) : Integer;				// FMP, PMD 共通 maskoff

	public
		{ Public 宣言 }
		procedure SetAllPartMask;
		function GetPartMask(ch : Integer) : Boolean;
		property EnablePartMask : Boolean read FEnablePartMask write FEnablePartMask;
		property OnChanged : TNotifyEvent read FOnChanged write FOnChanged;
	end;

var
	PartMaskForm: TPartMaskForm;

implementation

uses Main;

{$R *.DFM}


//***************************************************************************
// Form の生成
//***************************************************************************
procedure TPartMaskForm.FormCreate(Sender: TObject);
begin
	DragAcceptFiles(Handle, True);
	Application.OnMessage := AppOnMessage;
	FOnChanged := Nil;
	FPlayDriver := DRIVER_PMD;
	FEnablePartMask := True;
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure TPartMaskForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
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
procedure TPartMaskForm.DropFiles(var Msg:TWMDROPFILES);
begin
	FMPMDForm.DropFiles(Msg);
end;


//***************************************************************************
// フォームを開いたとき
//***************************************************************************
procedure TPartMaskForm.FormActivate(Sender: TObject);
begin
	FMPMDForm.PartMaskMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure TPartMaskForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
	FMPMDForm.PartMaskMenu.Checked := False;
end;


//***************************************************************************
// ドライバー変更
//***************************************************************************
procedure TPartMaskForm.Driver_Change(var Msg : TMessage);
begin
	if(Msg.WParam = WPARAM(DRIVER_FMP)) then begin
		FPlayDriver := DRIVER_FMP;
		Label8.Enabled := False;
		CheckBox15.Enabled := False;
		CheckBox16.Enabled := False;
		CheckBox17.Enabled := False;
		CheckBox18.Enabled := False;
		CheckBox19.Enabled := False;
		CheckBox20.Enabled := False;
		CheckBox21.Enabled := False;
		CheckBox22.Enabled := False;
	end else begin
		FPlayDriver := DRIVER_PMD;
		Label8.Enabled := True;
		CheckBox15.Enabled := True;
		CheckBox16.Enabled := True;
		CheckBox17.Enabled := True;
		CheckBox18.Enabled := True;
		CheckBox19.Enabled := True;
		CheckBox20.Enabled := True;
		CheckBox21.Enabled := True;
		CheckBox22.Enabled := True;
	end;

	SetAllPartMask;
end;


//***************************************************************************
// WinFMP, PMDWin 共通 maskon(ch : PMD 互換)
//***************************************************************************
function TPartMaskForm.c_maskon(ch : Integer) : Integer;
begin
	EnterCriticalSection(Sect1);
	if(FPlayDriver = DRIVER_PMD) then begin							// PMDWin の制御
		result := maskon(ch);
	end else begin																			// WinFMP の制御
		if(ch = 10) or (ch = 14) then begin		// Rhythm
			result := fmp_maskon(true, $3f);
		end else if(ch < 6) then begin				// FM
			result := fmp_maskon(false, ch);
		end else if(ch < 9) then begin				// SSG
			result := fmp_maskon(false, ch + 12);
		end else if(ch = 9) then begin				// ADPCM
			result := fmp_maskon(false, 21);
		end else if(ch < 14) then begin				// FM3Ex
			result := fmp_maskon(false, ch - 5);
		end else begin
			result := ERR_WRONG_PARTNO;
		end;
	end;
	LeaveCriticalSection(Sect1);
end;


//***************************************************************************
// WinFMP, PMDWin 共通 maskoff(ch : PMD 互換)
//***************************************************************************
function TPartMaskForm.c_maskoff(ch : Integer) : Integer;
begin
	EnterCriticalSection(Sect1);
	if(FPlayDriver = DRIVER_PMD) then begin							// PMDWin の制御
		result := maskoff(ch);
	end else begin																			// WinFMP の制御
		if(ch = 10) or (ch = 14) then begin		// Rhythm
			result := fmp_maskoff(true, $3f);
		end else if(ch < 6) then begin				// FM
			result := fmp_maskoff(false, ch);
		end else if(ch < 9) then begin				// SSG
			result := fmp_maskoff(false, ch + 12);
		end else if(ch = 9) then begin				// ADPCM
			result := fmp_maskoff(false, 21);
		end else if(ch < 14) then begin				// FM3Ex
			result := fmp_maskoff(false, ch - 5);
		end else begin
			result := FMP_ERR_WRONG_PARTNO;
		end;
	end;
	LeaveCriticalSection(Sect1);
end;


//***************************************************************************
// すべてのパートのマスクを設定
//***************************************************************************
procedure TPartMaskForm.SetAllPartMask;
begin
	// FM
	if(CheckBox1.Checked) then c_maskon(CheckBox1.Tag) else c_maskoff(CheckBox1.Tag);
	if(CheckBox2.Checked) then c_maskon(CheckBox2.Tag) else c_maskoff(CheckBox2.Tag);
	if(CheckBox3.Checked) then c_maskon(CheckBox3.Tag) else c_maskoff(CheckBox3.Tag);
	if(CheckBox4.Checked) then c_maskon(CheckBox4.Tag) else c_maskoff(CheckBox4.Tag);
	if(CheckBox5.Checked) then c_maskon(CheckBox5.Tag) else c_maskoff(CheckBox5.Tag);
	if(CheckBox6.Checked) then c_maskon(CheckBox6.Tag) else c_maskoff(CheckBox6.Tag);

	// SSG
	if(CheckBox7.Checked) then c_maskon(CheckBox7.Tag) else c_maskoff(CheckBox7.Tag);
	if(CheckBox8.Checked) then c_maskon(CheckBox8.Tag) else c_maskoff(CheckBox8.Tag);
	if(CheckBox9.Checked) then c_maskon(CheckBox9.Tag) else c_maskoff(CheckBox9.Tag);

	// FM3
	if(CheckBox10.Checked) then c_maskon(CheckBox10.Tag) else c_maskoff(CheckBox10.Tag);
	if(CheckBox11.Checked) then c_maskon(CheckBox11.Tag) else c_maskoff(CheckBox11.Tag);
	if(CheckBox12.Checked) then c_maskon(CheckBox12.Tag) else c_maskoff(CheckBox12.Tag);

	// Rhythm
	if(CheckBox13.Checked) then begin
		c_maskon(CheckBox13.Tag);
		c_maskon(14);
	end else begin
		c_maskoff(CheckBox13.Tag);
		c_maskoff(14);
	end;

	// ADPCM
	if(CheckBox14.Checked) then c_maskon(CheckBox14.Tag) else c_maskoff(CheckBox14.Tag);

	if(FPlayDriver = DRIVER_PMD) then begin				// PMDWin の場合
		// PPZ8
		if(CheckBox15.Checked) then c_maskon(CheckBox15.Tag) else c_maskoff(CheckBox15.Tag);
		if(CheckBox16.Checked) then c_maskon(CheckBox16.Tag) else c_maskoff(CheckBox16.Tag);
		if(CheckBox17.Checked) then c_maskon(CheckBox17.Tag) else c_maskoff(CheckBox17.Tag);
		if(CheckBox18.Checked) then c_maskon(CheckBox18.Tag) else c_maskoff(CheckBox18.Tag);
		if(CheckBox19.Checked) then c_maskon(CheckBox19.Tag) else c_maskoff(CheckBox19.Tag);
		if(CheckBox20.Checked) then c_maskon(CheckBox20.Tag) else c_maskoff(CheckBox20.Tag);
		if(CheckBox21.Checked) then c_maskon(CheckBox21.Tag) else c_maskoff(CheckBox21.Tag);
		if(CheckBox22.Checked) then c_maskon(CheckBox22.Tag) else c_maskoff(CheckBox22.Tag);
	end;
end;


//***************************************************************************
// すべてのパートをマスクする
//***************************************************************************
procedure TPartMaskForm.CheckAllPartMask;
begin
	// FM
	CheckBox1.Checked := True;
	CheckBox2.Checked := True;
	CheckBox3.Checked := True;
	CheckBox4.Checked := True;
	CheckBox5.Checked := True;
	CheckBox6.Checked := True;

	// SSG
	CheckBox7.Checked := True;
	CheckBox8.Checked := True;
	CheckBox9.Checked := True;

	// FM3
	CheckBox10.Checked := True;
	CheckBox11.Checked := True;
	CheckBox12.Checked := True;

	// Rhythm
	CheckBox13.Checked := True;

	// ADPCM
	CheckBox14.Checked := True;

	// PPZ8
	CheckBox15.Checked := True;
	CheckBox16.Checked := True;
	CheckBox17.Checked := True;
	CheckBox18.Checked := True;
	CheckBox19.Checked := True;
	CheckBox20.Checked := True;
	CheckBox21.Checked := True;
	CheckBox22.Checked := True;
end;


//***************************************************************************
// パートマスクON/OFF
//***************************************************************************
procedure TPartMaskForm.CheckBox1Click(Sender: TObject);
begin
	if((Sender as TCheckBox).Checked = True) then begin
		c_maskon((Sender as TCheckBox).Tag);
		if(Sender = CheckBox13) then begin
			c_maskon(14);
		end;

	end else begin
		c_maskoff((Sender as TCheckBox).Tag);
		if(Sender = CheckBox13) then begin
			c_maskoff(14);
		end;
	end;

	if(Assigned(FOnChanged)) then begin
		FOnChanged(Self);
	end;
end;


//***************************************************************************
// キーによるパートマスクON/OFF
//***************************************************************************
procedure TPartMaskForm.AppOnMessage(var Msg: TMsg; var Handled: Boolean);
begin
	if(Msg.message <> WM_KEYDOWN) then Exit;
	if(FEnablePartMask = False) then Exit;
	if(GetKeyState(VK_CONTROL) and $80 <> 0) then Exit; // + CTRL
//	if(GetKeyState(VK_ALT) and $80 <> 0) then Exit;			// + ALT

	if(GetKeyState(VK_SHIFT) and $80 <> 0) then begin		// + SHIFT
		case(Msg.wParam) of
			// FM
			ord('1') : CheckAllPartMask; 	// 1
			ord('2') : CheckAllPartMask; 	// 2
			ord('3') : CheckAllPartMask; 	// 3
			ord('4') : CheckAllPartMask; 	// 4
			ord('5') : CheckAllPartMask; 	// 5
			ord('6') : CheckAllPartMask; 	// 6

			// SSG
			ord('7') : CheckAllPartMask; 	// 7
			ord('8') : CheckAllPartMask; 	// 8
			ord('9') : CheckAllPartMask; 	// 9

			// FM3
			ord('Q') : CheckAllPartMask; 	// Q
			ord('W') : CheckAllPartMask; 	// W
			ord('E') : CheckAllPartMask; 	// E

			// Rhythm
			ord('0') : CheckAllPartMask; 	// 0

			// ADPCM
			189			 : CheckAllPartMask; 	// -
		end;

		if(FPlayDriver = DRIVER_PMD) then begin
			case(Msg.wParam) of
				// PPZ
				ord('A') : CheckAllPartMask; 	// A
				ord('S') : CheckAllPartMask; 	// S
				ord('D') : CheckAllPartMask; 	// D
				ord('F') : CheckAllPartMask; 	// F
				ord('G') : CheckAllPartMask; 	// G
				ord('H') : CheckAllPartMask; 	// H
				ord('J') : CheckAllPartMask; 	// J
				ord('K') : CheckAllPartMask; 	// K
			end;
		end;
	end;

	case(Msg.wParam) of
		// FM
		ord('1') : CheckBox1.Checked := not CheckBox1.Checked;			// 1
		ord('2') : CheckBox2.Checked := not CheckBox2.Checked;			// 2
		ord('3') : CheckBox3.Checked := not CheckBox3.Checked;			// 3
		ord('4') : CheckBox4.Checked := not CheckBox4.Checked;			// 4
		ord('5') : CheckBox5.Checked := not CheckBox5.Checked;			// 5
		ord('6') : CheckBox6.Checked := not CheckBox6.Checked;			// 6

		// SSG
		ord('7') : CheckBox7.Checked := not CheckBox7.Checked;			// 7
		ord('8') : CheckBox8.Checked := not CheckBox8.Checked;			// 8
		ord('9') : CheckBox9.Checked := not CheckBox9.Checked;			// 9

		// FM3
		ord('Q') : CheckBox10.Checked := not CheckBox10.Checked;		// Q
		ord('W') : CheckBox11.Checked := not CheckBox11.Checked;		// W
		ord('E') : CheckBox12.Checked := not CheckBox12.Checked;		// E

		// Rhythm
		ord('0') : CheckBox13.Checked := not CheckBox13.Checked;		// 0

		// ADPCM
		189			 : CheckBox14.Checked := not CheckBox14.Checked;		// -

		// Reverse
		222			 : Button8Click(Self);															// ^

		// Reset
		220			 : Button9Click(Self);															// \
	end;

	if(FPlayDriver = DRIVER_PMD) then begin
		// PPZ
		case(Msg.wParam) of
			ord('A') : CheckBox15.Checked := not CheckBox15.Checked;		// A
			ord('S') : CheckBox16.Checked := not CheckBox16.Checked;		// S
			ord('D') : CheckBox17.Checked := not CheckBox17.Checked;		// D
			ord('F') : CheckBox18.Checked := not CheckBox18.Checked;		// F
			ord('G') : CheckBox19.Checked := not CheckBox19.Checked;		// G
			ord('H') : CheckBox20.Checked := not CheckBox20.Checked;		// H
			ord('J') : CheckBox21.Checked := not CheckBox21.Checked;		// J
			ord('K') : CheckBox22.Checked := not CheckBox22.Checked;		// K
		end;
	end;

	if(Assigned(FOnChanged)) then begin
		FOnChanged(Self);
	end;
end;


//***************************************************************************
// パートマスク反転
//***************************************************************************
procedure TPartMaskForm.Button8Click(Sender: TObject);
begin
	// FM
	CheckBox1.Checked := not CheckBox1.Checked;
	CheckBox2.Checked := not CheckBox2.Checked;
	CheckBox3.Checked := not CheckBox3.Checked;
	CheckBox4.Checked := not CheckBox4.Checked;
	CheckBox5.Checked := not CheckBox5.Checked;
	CheckBox6.Checked := not CheckBox6.Checked;

	// SSG
	CheckBox7.Checked := not CheckBox7.Checked;
	CheckBox8.Checked := not CheckBox8.Checked;
	CheckBox9.Checked := not CheckBox9.Checked;

	// FM3
	CheckBox10.Checked := not CheckBox10.Checked;
	CheckBox11.Checked := not CheckBox11.Checked;
	CheckBox12.Checked := not CheckBox12.Checked;

	// Rhythm
	CheckBox13.Checked := not CheckBox13.Checked;

	// ADPCM
	CheckBox14.Checked := not CheckBox14.Checked;

	// PPZ8
  CheckBox15.Checked := not CheckBox15.Checked;
  CheckBox16.Checked := not CheckBox16.Checked;
	CheckBox17.Checked := not CheckBox17.Checked;
	CheckBox18.Checked := not CheckBox18.Checked;
	CheckBox19.Checked := not CheckBox19.Checked;
  CheckBox20.Checked := not CheckBox20.Checked;
  CheckBox21.Checked := not CheckBox21.Checked;
  CheckBox22.Checked := not CheckBox22.Checked;
end;


//***************************************************************************
// パートマスクリセット
//***************************************************************************
procedure TPartMaskForm.Button9Click(Sender: TObject);
begin
	// FM
	CheckBox1.Checked := False;
	CheckBox2.Checked := False;
	CheckBox3.Checked := False;
	CheckBox4.Checked := False;
	CheckBox5.Checked := False;
	CheckBox6.Checked := False;

	// SSG
	CheckBox7.Checked := False;
	CheckBox8.Checked := False;
	CheckBox9.Checked := False;

	// FM3
	CheckBox10.Checked := False;
	CheckBox11.Checked := False;
	CheckBox12.Checked := False;

	// Rhythm
	CheckBox13.Checked := False;

	// ADPCM
	CheckBox14.Checked := False;

	// PPZ8
	CheckBox15.Checked := False;
	CheckBox16.Checked := False;
	CheckBox17.Checked := False;
	CheckBox18.Checked := False;
	CheckBox19.Checked := False;
	CheckBox20.Checked := False;
	CheckBox21.Checked := False;
	CheckBox22.Checked := False;
end;


//***************************************************************************
// パートマスクの状態取得
//***************************************************************************
function TPartMaskForm.GetPartMask(ch : Integer) : Boolean;
begin
	Result := False;
	case(ch) of
		00 : Result := CheckBox1.Checked;
		01 : Result := CheckBox2.Checked;
		02 : Result := CheckBox3.Checked;
		03 : Result := CheckBox4.Checked;
		04 : Result := CheckBox5.Checked;
		05 : Result := CheckBox6.Checked;
		06 : Result := CheckBox7.Checked;
		07 : Result := CheckBox8.Checked;
		08 : Result := CheckBox9.Checked;
		09 : Result := CheckBox14.Checked;
		10 : Result := CheckBox13.Checked;
		11 : Result := CheckBox10.Checked;
		12 : Result := CheckBox11.Checked;
		13 : Result := CheckBox12.Checked;
		14 : Result := CheckBox13.Checked;
		16 : Result := CheckBox15.Checked;
		17 : Result := CheckBox16.Checked;
		18 : Result := CheckBox17.Checked;
		19 : Result := CheckBox18.Checked;
		20 : Result := CheckBox19.Checked;
		21 : Result := CheckBox20.Checked;
		22 : Result := CheckBox21.Checked;
		23 : Result := CheckBox22.Checked;
	end;
end;


end.

