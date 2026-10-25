//============================================================================
//                             メインフォーム
//                      Copyright & Programmed by C60
//============================================================================
unit Main;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ShellAPI, CommDlg, ComCtrls, Buttons, StdCtrls, MMSystem, Menus, ExtCtrls,
	CommDlg2, IniFiles, PMDWin, WinFMP, FMPMDDefine, GlobalAtom, Env, LowLVPCM,
	PinForm, BrowsDlg, Extrkbar, util, FMPMDPlayDefine, FMPLabel, TrayIcon;

{$R Comdlg32.res}                                                                          

type
	//**************************************************************************
	// 例外
	//**************************************************************************
	EWindowListError = class(Exception);

	//*************************************************************************
	// ウィンドウ一覧を格納するための構造体
	//*************************************************************************
  PWindowListRecord = ^TWindowListRecord;
	TWindowListRecord = record
  	Form : TForm;			// Form のポインタ
    Flag : Boolean;   // くっついているかどうかを格納する Flag
  end;

	//*************************************************************************
	// TWindowListRecord 用 TList。要素のメモリ確保、開放は自動的に行う)
	//*************************************************************************
  TWindowList = class(TList)
	protected
    { Protected 宣言 }
		function Get(Index: Integer): PWindowListRecord;
		procedure Put(Index: Integer; Item: PWindowListRecord);
	public
		{ Public 宣言 }
		destructor Destroy; override;
		function Add(Item: TWindowListRecord): Integer;
		procedure Insert(Index: Integer; Item: TWindowListRecord);
		procedure Clear;
		procedure Delete(Index: Integer);
		property Items[Index: Integer]: PWindowListRecord read Get write Put; default;
	end;

	//*************************************************************************
	// メインフォーム
	//*************************************************************************
	TFMPMDForm = class(TForm)
		PinForm1: TPinForm;
		MainMenu1: TMainMenu;
		File1: TMenuItem;
		Help1: TMenuItem;
		Open1: TMenuItem;
		N1: TMenuItem;
		Exit1: TMenuItem;
		K1: TMenuItem;
		KP1: TMenuItem;
		KP2: TMenuItem;
		KP3: TMenuItem;
		Window1: TMenuItem;
    LevelMeterMenu: TMenuItem;
    SpeanaMenu: TMenuItem;
		Panel1: TPanel;
    VolumeMenu: TMenuItem;
		SaveDialog1: TSaveDialog;
		N2: TMenuItem;
		KwaveS1: TMenuItem;
		KPCM1: TMenuItem;
		PPCC1: TMenuItem;
		P8681: TMenuItem;
		PPSS1: TMenuItem;
		PPZZ1: TMenuItem;
		OpenDialog2: TOpenDialog;
		PPZ221: TMenuItem;
		BitBtn1: TBitBtn;
		BitBtn2: TBitBtn;
		BitBtn3: TBitBtn;
		BitBtn5: TBitBtn;
		P1: TMenuItem;
		BitBtn4: TBitBtn;
    ParamaterMenu: TMenuItem;
		KS1: TMenuItem;
    PlayListMenu: TMenuItem;
    BitBtn6: TBitBtn;
		BitBtn7: TBitBtn;
		N3: TMenuItem;
		KE3: TMenuItem;
    PartMaskMenu: TMenuItem;
		KPlayListI1: TMenuItem;
    SaveDialog2: TSaveDialog;
		N4: TMenuItem;
    RandomMenu: TMenuItem;
    LoopMenu: TMenuItem;
		KN1: TMenuItem;
    KB1: TMenuItem;
    N5: TMenuItem;
		LowLVPCM1: TLowLVPCM;
    KF1: TMenuItem;
		BrowseDialog1: TBrowseDialog;
    ConsoleMenu: TMenuItem;
    Label13: TLabel;
    Label15: TLabel;
    Labelm: TLabel;
    Labels: TLabel;
    Labelms: TLabel;
    ExtTrackBar1: TExtTrackBar;
    Panel2: TPanel;
    TitleLabel: TFMPLabel;
    CheckBox51: TCheckBox;
    CheckBox50: TCheckBox;
    CheckBox52: TCheckBox;
    CheckBox53: TCheckBox;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    KF2: TMenuItem;
    KF3: TMenuItem;
    N6: TMenuItem;
    KS2: TMenuItem;
    KA1: TMenuItem;
    KS3: TMenuItem;
    N7: TMenuItem;
    KR2: TMenuItem;
    KL2: TMenuItem;
    N8: TMenuItem;
    KE1: TMenuItem;
    N9: TMenuItem;
    Exit2: TMenuItem;
    Show1: TMenuItem;
    N10: TMenuItem;
		procedure LoadButtonClick(Sender: TObject);
		procedure StopButtonClick(Sender: TObject);
		procedure LowLVPCM1BufferEmpty(Sender: TObject);
		procedure PlayButtonClick(Sender: TObject);
		procedure LevelMeterMenuClick(Sender: TObject);
		procedure SpeanaMenuClick(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormShow(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure Exit1Click(Sender: TObject);
		procedure K1Click(Sender: TObject);
		procedure VolumeMenuClick(Sender: TObject);
		procedure SaveButtonClick(Sender: TObject);
		procedure CheckBox50Click(Sender: TObject);
		procedure PPCC1Click(Sender: TObject);
		procedure PPZZ1Click(Sender: TObject);
		procedure CheckBox51Click(Sender: TObject);
		procedure PPSS1Click(Sender: TObject);
		procedure PauseButtonClick(Sender: TObject);
		procedure ExtTrackBar1MouseUp(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure ExtTrackBar1MouseDown(Sender: TObject; Button: TMouseButton;
			Shift: TShiftState; X, Y: Integer);
		procedure ExtTrackBar1KeyUp(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure ExtTrackBar1KeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure P8681Click(Sender: TObject);
		procedure CheckBox52Click(Sender: TObject);
		procedure FadeButtonClick(Sender: TObject);
		procedure ParamaterMenuClick(Sender: TObject);
		procedure PlayListMenuClick(Sender: TObject);
		procedure BitBtn7Click(Sender: TObject);
		procedure BitBtn6Click(Sender: TObject);
		procedure KE3Click(Sender: TObject);
    procedure PartMaskMenuClick(Sender: TObject);
		procedure KPlayListI1Click(Sender: TObject);
		procedure RandomMenuClick(Sender: TObject);
		procedure LoopMenuClick(Sender: TObject);
    procedure FolderOpenClick(Sender: TObject);
    procedure FileOpenClick(Sender: TObject);
    procedure ExtTrackBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ConsoleMenuClick(Sender: TObject);
    procedure CheckBox53Click(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure Show1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
	private
		{ Private 宣言 }
		CompressorTable : Array[-32768..32767] of SmallInt;		// コンプレッサの変換テーブル
		FInstalledGraphicFont : Boolean;	// ９８グラフィックフォントが印すとるされているか？
		FInstalledLineFont : Boolean;			// ９８罫線フォントが印すとるされているか？
		FPlayDriver : TPlayDriver;				// 現在演奏しているファイルの種類(FMP or PMD)
		FIniRead : Boolean;								// Ini を読んだかフラグ
		FActivated : Boolean;							// アクティブ化されたかフラグ
		FLoadFirstOpen : Boolean;					// 曲を最初に開くかフラグ
		FLoadInitialDir : String;					// 曲ロードで最初に開く dir
		FLoadPFirstOpen : Boolean;				// PCMを最初に開くかフラグ
		FLoadPInitialDir : String;				// PCMロードで最初に開く dir
		FSaveFirstOpen : Boolean;					// WAVセーブで最初に開くかフラグ
		FSaveFirstOpen2 : Boolean;				// PlayListセーブで最初に開くかフラグ
		FSaveInitialDir : String;					// WAVセーブで最初に開く dir
		FSaveInitialDir2 : String;				// PlayListセーブで最初に開く dir
		FPlayFirst : Boolean;							// 演奏開始後最初の getpcmdataか（Vol設定用)
		FPause : Boolean;									// Pause 中なら true
		FFadeOut : Boolean;								// 手動 FadeOut 中なら true
		FTrackBarMouseDown : Boolean;			// TrackBar を Drag 中なら true
		PCMDir : TStringList;							// PCMDir 本体
		FRhythmDir : String;							// リズム wave の path
		FFMCalc55k : Boolean;							// FM で55kHz合成するか？
		FPPSip : Boolean;									// PPS で補完するか
		FP86ip : Boolean;									// P86 で補完するか
		FPPZip : Boolean;									// PPZ で補完するか
		FPPZratechange : Boolean;					// PPZ の駆動周波数を出力周波数と変えるか？
		freq : Integer;										// 再生周波数
		ppzrate : Integer;								// PPZ 合成周波数
		FNoPCMForcePlay : Boolean;				// PVI, PPC, PZI 等が見つからなくても強制再生するか？
		Fw : Integer;											// ファイル保存用
		WaveHeader : TWavFormat;					// Wave 保存用ヘッダ
		lms : Integer;										// 曲停止時の時間(<0 なら演奏開始していない)
		FadeOutTime : Integer;						// フェードアウトの時間(ms)
		LoopToFadeOut : Boolean;					// ループ後に自動的にフェードアウトするか？
		Compressor : Boolean;							// コンプレッサをかけるか？
		FFadeOutFirst : Boolean;					// 最初の fadeout か
		NumOfLoopToFadeOut : Integer;			// フェードアウトするまでのループ数
		CheckMusicLength : Boolean;				// 演奏開始時に曲の演奏時間をチェックするか？
		NumOfBuffers : Integer;						// バッファ数
		ParamDelay : Integer;							// パラメータ表示補正(ms単位)
		F50Flame : Boolean;								// パラメーターを秒５０フレーム表示するか
																			// どうかのフラグ(False なら２０フレーム）
		FSnap : Boolean;									// ウィンドウをスナップするか？
		FSnapWidth : Integer;							// スナップする際の間隔
    FWindowList : TWindowList;				// Window の一覧(Drag 用)
		FFMWait : Integer;         		   	// FM Register 出力時の wait
		FSSGWait : Integer;								// SSG Register 出力時の wait
		FRhythmWait : Integer;						// Rhythm Register 出力時の wait
		FADPCMWait : Integer;							// ADPCM Register 出力時の wait

		// 以下、WinFMP, PMDWin の function(共用部)
	protected
		c_init : function(path : PChar) : Boolean; stdcall;
		c_music_load : function(filename : PChar) : Integer; stdcall;
		c_music_start : procedure ; stdcall;
		c_fadeout2 : procedure(speed : Integer); stdcall;
		c_getpcmdata : procedure (buf : PSmallInt; nsamples : Integer); stdcall;
		c_getmusicfilename : function(dest : PChar) : PChar; stdcall;
		c_getpcmfilename : function(dest : PChar) : PChar; stdcall;
		c_getppzfilename : function(dest : PChar; bufnum : Integer) : PChar; stdcall;
		c_setpos : procedure(pos : Integer); stdcall;
		c_getpos : function : Integer; stdcall;
		c_getlength : function(filename : PChar; var length : Integer;
				var loop : Integer) : Boolean; stdcall;
		c_getloopcount : function : Integer; stdcall;
		procedure NonClientLeftButtonDown(var Msg : TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure SetTimer(var Msg:TMessage); message WM_SETTIMER;
		procedure PlayNext(var Msg:TMessage); message WM_PLAYNEXT;
		procedure WndProc(var Msg: TMessage); override;
		procedure PlayListSelect(Sender: TObject);
		function LoadMusicData(FileName : String) : Boolean;
		procedure CommandLineCheck(CommandLine : TStrings);	// コマンドラインの処理
		procedure ShowMessage2(str : String);
		function GetPPZ1(str : String) : String;
		function GetPPZ2(str : String) : String;
		procedure Stop_Play;
		procedure Start_Play;
		function GetInstalledFMPFont : Boolean;
    procedure AppOnMinimize(Sender : TObject);
    procedure AppOnRestore(Sender : TObject);
	public
		{ Public 宣言 }
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		property  PlayDriver : TPlayDriver read FPlayDriver;
		property  Snap : Boolean read FSnap;
		property  SnapWidth : Integer read FSnapWidth;
		property  InstalledFMPFont : Boolean read GetInstalledFMPFont;
		property  InstalledGraphicFont : Boolean read FInstalledGraphicFont;
		property  InstalledLineFont : Boolean read FInstalledLineFont;


//		property  LoadFirstOpen : Boolean read FLoadFirstOpen write FLoadFirstOpen;
//		property  LoadInitialDir : String read FLoadInitialDir;
	end;

function ComDlg32DlgProc(Handle : HWND; uMsg : Cardinal;
										wPrm : WPARAM; lPrm : LPARAM) : Boolean; stdcall;



var
	FMPMDForm: TFMPMDForm;
	Sect1 : TRTLCriticalSection;
	DlgFileName : Array[0..DLGFILENAME_BUF-1] of Char;
	Filter : String;
	OpenFileName : TOPENFILENAME;

implementation

uses HRLVMeter, Speana, Version, Volume, status, PlayList, PartMask, Prompt;

{$R *.DFM}



//###########################################################################
//###########################################################################
//	TWndowList
//###########################################################################
//###########################################################################
//***************************************************************************
// デストラクタ
//***************************************************************************
destructor TWindowList.Destroy;
begin
	Clear;
	inherited Destroy;
end;


//***************************************************************************
// Item 追加
//***************************************************************************
function TWindowList.Add(Item: TWindowListRecord): Integer;
var
	p_DecodeESCCommand : PWindowListRecord;
begin
	New(p_DecodeESCCommand);
	p_DecodeESCCommand^ := Item;
	result := inherited Add(p_DecodeESCCommand);
end;


//***************************************************************************
// Item 挿入
//***************************************************************************
procedure TWindowList.Insert(Index: Integer; Item: TWindowListRecord);
var
	p_DecodeESCCommand : PWindowListRecord;
begin
	New(p_DecodeESCCommand);
	p_DecodeESCCommand^ := Item;
	inherited Insert(Index, p_DecodeESCCommand);
end;


//***************************************************************************
// Item 削除
//***************************************************************************
procedure TWindowList.Delete(Index: Integer);
begin
	if (Index < 0) or (Index >= Count) then begin
		raise EWindowListError.Create(MSG_ERR_LISTINDEX);
	end;

	if(Items[Index] <> nil) then begin
		Dispose(inherited Items[Index]);
		inherited Delete(Index);
		Pack;
	end;
end;


//***************************************************************************
// Item 全削除
//***************************************************************************
procedure TWindowList.Clear;
var
	i : Integer;
begin
	// Item の開放
	for i := 0 to Count-1 do begin
		if(Items[i] <> nil) then begin
			Dispose(inherited Items[i]);
		end;
	end;
	inherited Clear;
	Pack;
end;


//***************************************************************************
// Item 取得
//***************************************************************************
function TWindowList.Get(Index : Integer) : PWindowListRecord;
begin
	result := inherited Get(Index);
end;


//***************************************************************************
// Item 代入
//***************************************************************************
procedure TWindowList.Put(Index: Integer; Item: PWindowListRecord);
begin
	TWindowListRecord(inherited Items[Index]^) := Item^;
end;



//###########################################################################
//###########################################################################
//	TMainForm
//###########################################################################
//###########################################################################


//***************************************************************************
// Form の生成
//***************************************************************************
procedure TFMPMDForm.FormCreate(Sender: TObject);
var
	ini : TIniFile;
	i : Integer;
begin
	FPlayDriver := DRIVER_PMD;
	FIniRead := False;
	FActivated := False;
	FLoadFirstOpen := True;
	FLoadPFirstOpen := True;
	FSaveFirstOpen := True;
	FSaveFirstOpen2 := True;
	FPlayFirst := False;
	FFadeOutFirst := True;
	FPause := False;
	FFadeOut := False;
	FTrackBarMouseDown := False;
	Fw := -1;
	lms := -1;
	InitializeCriticalSection(Sect1);
	PCMDir := TStringList.Create;
	DragAcceptFiles(Handle, True);
	F50Flame := True;
	ParamDelay := 0;
	OpenFileName.nFilterIndex := 0;
	DlgFileName := '';
  FWindowList := TWindowList.Create;
  Application.OnMiniMize := AppOnMinimize;
  Application.OnRestore := AppOnRestore;

	// とりあえず PMDWin 側に設定
	c_init := pmdwininit;
	c_music_load := music_load;
	c_music_start := music_start;
	c_fadeout2 := fadeout2;
	c_getpcmdata := getpcmdata;
	c_getmusicfilename := getmusicfilename;
	c_getpcmfilename := getpcmfilename;
	c_getppzfilename := getppzfilename;
	c_setpos := setpos;
	c_getpos := getpos;
	c_getlength := getlength;
	c_getloopcount := getloopcount;

	// WinFMP & PMDWin の初期化
	Ini := TIniFile.Create(PinForm1.FileName);
	try
		FRhythmDir := Ini.ReadString(Name, 'RhythmPath', ExtractFileDir(ParamStr(0)));
		pmdwininit(PChar(FRhythmDir));
		fmp_init(PChar(FRhythmDir));
	finally
		Ini.Destroy;
	end;

	// コンプレッサ用テーブルの計算


(*
	for i := 0 to SizeOf(pcmbuf) div SizeOf(Integer) div 2 - 1 do begin
		if(pcmbuf[i] > 0) then begin
			pcmbuf[i] := Round(32768.0 * 0.9 * exp(0.85*ln(pcmbuf[i] / 32768.0)));
		end else if(pcmbuf[i] = 0) then begin
			pcmbuf[i] := 0;
		end else begin
			pcmbuf[i] := Round(-32768 *  0.9 * exp(0.85*ln(-pcmbuf[i] / 32768.0)));
		end;
	end;
*)

(*
	for i := 0 to SizeOf(pcmbuf) div SizeOf(Integer) div 2 - 1 do begin
		if(Abs(pcmbuf[i]) < 16384) then begin
			pcmbuf[i] := pcmbuf[i] * 8 div 5;
		end else begin
			if(pcmbuf[i] > 0) then begin
				pcmbuf[i] := Round(pcmbuf[i] * 1 / 5 + 26214.4 - 3276.8);
			end else begin
				pcmbuf[i] := -Round(-pcmbuf[i] * 1 / 5 + 26214.4 - 3276.8);
			end;
		end;
	end;
*)

(*
	for i := 0 to SizeOf(pcmbuf) div SizeOf(Integer) div 2 - 1 do begin
		if(Abs(pcmbuf[i]) < 16384) then begin
			pcmbuf[i] := pcmbuf[i] * 7 div 5;
		end else begin
			if(pcmbuf[i] > 0) then begin
				pcmbuf[i] := Round(pcmbuf[i] * 1 / 5 + 22937.6 - 3276.8);
			end else begin
				pcmbuf[i] := -Round(-pcmbuf[i] * 1 / 5 + 22937.6 - 3276.8);
			end;
		end;
	end;
*)

(*
	for i := -32768 to 32767 do begin
		CompressorTable[i] := SmallInt(trunc(sin(PI / 2 * i / $8000)*$7fff));
	end;
*)

(*
	for i := 1 to 32767 do begin
		CompressorTable[i]  := SmallInt(trunc(sin(PI / 2 * i / $8000)*$7fff));
		CompressorTable[-i] := -CompressorTable[i];
	end;

	CompressorTable[0]      :=      0;
	CompressorTable[-32768] := -32767;
*)


	for i := 0 to 16383 do begin
		CompressorTable[i]  := SmallInt(trunc(1.0 / sqrt(2) * i / 16384 * $7fff));
		CompressorTable[-i] := -CompressorTable[i];
	end;

	for i := 16384 to 32767 do begin
		CompressorTable[i]  := SmallInt(trunc(sin(PI / 2 * i / $8000)*$7fff));
		CompressorTable[-i] := -CompressorTable[i];
	end;


	CompressorTable[0]      :=      0;
	CompressorTable[-32768] := -32767;

  // Delphi 2 以外だったら TrackBar の太さを調整する
{$IFNDEF VER90}
  ExtTrackBar1.ThumbLength := 15;
{$ENDIF}
end;


//***************************************************************************
// Form の表示（PCMDir を ini から読む ＋ ICON D&D の処理）
//***************************************************************************
procedure TFMPMDForm.FormShow(Sender: TObject);
var
	TempWindowListRecord : TWindowListRecord;
  i, NumOfPCMDir : Integer;
	ini : TIniFile;
	str : TStringList;
	strPlayListFileName : string;
	FilterStrTemp : string;
	FilterStrList : TStringList;
begin
	if(FIniRead = True) then Exit;

  Application.Icon.Assign(Self.Icon);

	// 98グラフィックフォントがインストールされているかどうか調べる
  if(Screen.Fonts.IndexOf(STR_98GRAPHICS) < 0) then begin
		FInstalledGraphicFont := False;
  end else begin
		FInstalledGraphicFont := True;
  end;

	// 98罫線フォントがインストールされているかどうか調べる
  if(Screen.Fonts.IndexOf(STR_98LINE) < 0) then begin
		FInstalledLineFont := False;
  end else begin
		FInstalledLineFont := True;
  end;

  // Window 一覧(Env, Version 以外)を FWindowList に登録
  TempWindowListRecord.Form := FMPMDForm;
  TempWindowListRecord.Flag := True;			// MainForm のみフラグを True に
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := PlayListForm;
  TempWindowListRecord.Flag := False;			// MainForm 以外はフラグを False に
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := VolumeForm;
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := PartMaskForm;
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := HRLVMeterForm;
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := SPForm;
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := PromptForm;
  FWindowList.Add(TempWindowListRecord);

  TempWindowListRecord.Form := StatusForm;
  FWindowList.Add(TempWindowListRecord);

	// PlayList の読み出し
	if(PinForm1.FileDir[Length(PinForm1.FileDir)] = '\') then begin
		strPlayListFileName := PinForm1.FileDir + PlayListFileName;
	end else begin
		strPlayListFileName := PinForm1.FileDir + '\' + PlayListFileName;
	end;

	if(FileExists(strPlayListFileName)) then begin
		PlayListForm.LoadFromFIle(strPlayListFileName);
	end;

	Ini := TIniFile.Create(PinForm1.FileName);
	try
		FFMCalc55k := Ini.ReadBool(Name, 'FMCalc55k', True);
		FPPSip := Ini.ReadBool(Name, 'PPSInterPolation', True);
		FP86ip := Ini.ReadBool(Name, 'P86InterPolation', True);
		FPPZip := Ini.ReadBool(Name, 'PPZInterPolation', True);
		freq := Ini.ReadInteger(Name, 'Frequency', SOUND_44K);
		ppzrate := Ini.ReadInteger(Name, 'PPZ_Frequency', SOUND_44K);
		FPPZratechange := Ini.ReadBool(Name, 'PPZ_RateChange', False);

		// 互換性確保のため
		if(freq = SOUND_55K) then begin
			freq := SOUND_44K;
			FFMCalc55k := True;
		end;

		NumOfBuffers := Ini.ReadInteger(Name, 'NumOfBuffers', 8);
		LowLVPCM1.DeviceID := UINT(Ini.ReadInteger(Name, 'DeviceID', Integer(WAVE_MAPPER)));

		FLoadInitialDir := Ini.ReadString(Name, 'LoadDirectory', '');
		FLoadPInitialDir := Ini.ReadString(Name, 'LoadPCMDirectory', '');
		FSaveInitialDir := Ini.ReadString(Name, 'SaveDirectory', '');
		FSaveInitialDir2 := Ini.ReadString(Name, 'SaveDirectory2', '');
(*
		FRhythmDir := Ini.ReadString(Name, 'RhythmPath', ExtractFileDir(ParamStr(0)));
		pmdwininit(PChar(FRhythmDir));
		fmp_init(PChar(FRhythmDir));
*)
		CheckBox50.Checked := Ini.ReadBool(Name, 'RhythmUseWithSSGDrum', False);
		CheckBox51.Checked := Ini.ReadBool(Name, 'UsePPS', True);
		CheckBox52.Checked := Ini.ReadBool(Name, 'PMD86PCMMode', False);
		CheckBox53.Checked := Ini.ReadBool(Name, 'ADPCMPPZ8Emulate', False);
		CheckBox51Click(Self);

		if(Ini.ReadBool(Name, 'LevelMeter', False) = True) then
				HRLVMeterForm.Start(LowLVPCM1);
		if(Ini.ReadBool(Name, 'Speana', False) = True) then SPForm.Start(LowLVPCM1);
		if(Ini.ReadBool(Name, 'VolumeChange', False) = True) then VolumeForm.Show;
		if(Ini.ReadBool(Name, 'Parameter', False) = True) then StatusForm.Start;
		if(Ini.ReadBool(Name, 'PlayList', False) = True) then PlayListForm.Show;
		if(Ini.ReadBool(Name, 'PartMask', False) = True) then PartMaskForm.Show;
		if(Ini.ReadBool(Name, 'Prompt', False) = True) then PromptForm.Show;

		NumOfPCMDir := Ini.ReadInteger(Name, 'NumOfPCMDir', 0);
		for i := 0 to NumOfPCMDir - 1 do begin
			PCMDir.Add(Ini.ReadString(Name,'PCMDir'+IntToStr(i+1), ''));
		end;

(*
		VolumeForm.FMVolumeDown := Ini.ReadInteger(Name, 'FM_VOLDOWN', 0);
		VolumeForm.SSGVolumeDown := Ini.ReadInteger(Name, 'SSG_VOLDOWN', 0);
		VolumeForm.RhythmVolumeDown := Ini.ReadInteger(Name, 'RHYTHM_VOLDOWN', 0);
		VolumeForm.ADPCMVolumeDown := Ini.ReadInteger(Name, 'ADPCM_VOLDOWN', 0);
		VolumeForm.PPZVolumeDown := Ini.ReadInteger(Name, 'PPZ_VOLDOWN', 0);

		setfmvoldown(VolumeForm.FMVolumeDown);
		setssgvoldown(VolumeForm.SSGVolumeDown);
		setrhythmvoldown(VolumeForm.RhythmVolumeDown);
		setadpcmvoldown(VolumeForm.ADPCMVolumeDown);
		setppzvoldown(VolumeForm.PPZVolumeDown);
*)

		setfmvoldown(Ini.ReadInteger(Name, 'FM_VOLDOWN', 0));
		setssgvoldown(Ini.ReadInteger(Name, 'SSG_VOLDOWN', 0));
		setrhythmvoldown(Ini.ReadInteger(Name, 'RHYTHM_VOLDOWN', 0));
		setadpcmvoldown(Ini.ReadInteger(Name, 'ADPCM_VOLDOWN', 0));
		setppzvoldown(Ini.ReadInteger(Name, 'PPZ_VOLDOWN', 0));

		fmp_setfmvoldown(Ini.ReadInteger(Name, 'FMP_FM_VOLDOWN', 0));
		fmp_setssgvoldown(Ini.ReadInteger(Name, 'FMP_SSG_VOLDOWN', 0));
		fmp_setrhythmvoldown(Ini.ReadInteger(Name, 'FMP_RHYTHM_VOLDOWN', 0));
		fmp_setadpcmvoldown(Ini.ReadInteger(Name, 'FMP_ADPCM_VOLDOWN', 0));
		fmp_setppzvoldown(Ini.ReadInteger(Name, 'FMP_PPZ_VOLDOWN', 0));

		// Voldown スライダーを初期化
		PostMessage(VolumeForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_PMD), 0);

		SPForm.UseHummingWindow := Ini.ReadBool(Name, 'UseHummingWindow', False);
		SPForm.NumOfBand := TSpeanaLevel(Ini.ReadInteger(Name, 'NumOfBand', Integer(SPHigh)));

		RandomMenu.Checked := Ini.ReadBool(Name, 'RandomPlay', False);
		KR2.Checked := RandomMenu.Checked;
		LoopMenu.Checked := Ini.ReadBool(Name, 'LoopPlay', False);
    KL2.Checked := LoopMenu.Checked;
		PlayListForm.Random := RandomMenu.Checked;
		PlayListForm.Loop := LoopMenu.Checked;

		setppsinterpolation(FPPSip);
		setp86interpolation(FP86ip);
		setppzinterpolation(FPPZip);
		fmp_setppzinterpolation(FPPZip);

		FadeOutTime := Ini.ReadInteger(Name, 'FadeOutTime', 3000);
		LoopToFadeOut := Ini.ReadBool(Name, 'LoopToFadeOut', False);
		Compressor := Ini.ReadBool(Name, 'Compressor', False);
		NumOfLoopToFadeOut := Ini.ReadInteger(Name, 'NumOfLoopToFadeOut', 2);
		CheckMusicLength := Ini.ReadBool(Name, 'CheckMusicLength', True);
		ParamDelay := Ini.ReadInteger(Name, 'ParamDelay', 0);
		F50Flame := Ini.ReadBool(Name, 'Display50Flame', False);
		FSnap := Ini.ReadBool(Name, 'SnapWindow', True);
		FSnapWidth := Ini.ReadInteger(Name, 'SnapWidth', 10);
		FNoPCMForcePlay := Ini.ReadBool(Name, 'NoPCMForcePlay', False);
		FFMWait := Ini.ReadInteger(Name, 'FMWait', 15000);
		FSSGWait := Ini.ReadInteger(Name, 'SSGWait', 15000);
		FRhythmWait := Ini.ReadInteger(Name, 'RhythmWait', 15000);
		FADPCMWait := Ini.ReadInteger(Name, 'ADPCMWait', 15000);
		PlayListForm.PlayIndex := Ini.ReadInteger(Name, 'PlayCount', 0);
		setfmwait(FFMWait);
		setssgwait(FSSGWait);
		setrhythmwait(FRhythmWait);
		setadpcmwait(FADPCMWait);
		fmp_setfmwait(FFMWait);
		fmp_setssgwait(FSSGWait);
		fmp_setrhythmwait(FRhythmWait);
		fmp_setadpcmwait(FADPCMWait);
	finally
		Ini.Destroy;
		FIniRead := True;
	end;

	// プレイリストのフォルダを開いたときの選択拡張子を初期化
	FilterStrTemp := FilterStr[1];		// 最初のファイル選択部分
	FilterStrList := TStringList.Create;
	while(Pos('.', FilterStrTemp) > 0) do begin
		if(Pos(';', FilterStrTemp) > 0) then begin
			FilterStrList.Add(Copy(FilterStrTemp, Pos('.', FilterStrTemp) + 1,
				Pos(';', FilterStrTemp) - Pos('.', FilterStrTemp) - 1));
			FilterStrTemp := Copy(FilterStrTemp, Pos(';', FilterStrTemp) + 1,
				Length(FilterStrTemp) - Pos(';', FilterStrTemp));
		end else begin
			FilterStrList.Add(Copy(FilterStrTemp, Pos('.', FilterStrTemp) + 1,
				Length(FilterStrTemp) - Pos('.', FilterStrTemp)));
			Break;
		end;
	end;

	PlayListForm.SelectExt := FilterStrList;
	FilterStrList.Destroy;


	// プレイリストのダブルクリックイベントを関連付け
	PlayListForm.OnSelect := PlayListSelect;

	// ICON D&D
	if(ParamCount >= 1) then begin
		str := TStringList.Create;
		try
			for i := 1 to ParamCount do begin
				str.Add(ParamStr(i));
			end;
			CommandLineCheck(str);
		finally
			str.Destroy;
		end;
	end;
end;


//***************************************************************************
// Form のアクティブ化
//***************************************************************************
procedure TFMPMDForm.FormActivate(Sender: TObject);
var
	Ini : TIniFile;
begin
	// すでにアクティブ化されていたら終了する
	if(FActivated = True) then Exit;
  FActivated := True;

  // TrayIcon の表示／非表示を読み込み、設定する
	Ini := TIniFile.Create(PinForm1.FileName);
	try
 		TrayIcon1.Visible := Ini.ReadBool(Name, 'UseTaskTray', False);
  finally
		Ini.Destroy;
	end;
end;


//***************************************************************************
// Form の破棄（PCMDir を ini へ書き込む）
//***************************************************************************
procedure TFMPMDForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
 i : Integer;
 ini : TIniFile;
begin
	StopButtonClick(Self);
  FWindowList.Free;
  FWindowList := nil;

	Ini := TIniFile.Create(PinForm1.FileName);
	try
		Ini.WriteInteger(Name, 'Frequency', freq);
		Ini.WriteInteger(Name, 'PPZ_Frequency', ppzrate);
		Ini.WriteBool(Name, 'PPZ_RateChange', FPPZratechange);
		Ini.WriteBool(Name, 'FMCalc55k', FFMCalc55k);
		Ini.WriteBool(Name, 'PPSInterPolation', FPPSip);
		Ini.WriteBool(Name, 'P86InterPolation', FP86ip);
		Ini.WriteBool(Name, 'PPZInterPolation', FPPZip);
		Ini.WriteInteger(Name, 'NumOfBuffers', NumOfBuffers);
		Ini.WriteInteger(Name, 'DeviceID', Integer(LowLVPCM1.DeviceID));

		Ini.WriteBool(Name, 'LevelMeter', HRLVMeterForm.Visible);
		Ini.WriteBool(Name, 'Speana', SPForm.Visible);
		Ini.WriteBool(Name, 'VolumeChange', VolumeForm.Visible);
		Ini.WriteBool(Name, 'Parameter', StatusForm.Visible);
		Ini.WriteBool(Name, 'PlayList', PlayListForm.Visible);
		Ini.WriteBool(Name, 'PartMask', PartMaskForm.Visible);
		Ini.WriteBool(Name, 'Prompt', PromptForm.Visible);

		if(PlayListForm.PlayFileName <> '') then begin
			Ini.WriteString(Name, 'LoadDirectory',
									ExtractFileDir(PlayListForm.PlayFileName));
		end;

		if(OpenDialog2.Filename <> '') then begin
			Ini.WriteString(Name, 'LoadPCMDirectory', ExtractFileDir(OpenDialog2.FileName));
		end;

		if(SaveDialog1.Filename <> '') then begin
			Ini.WriteString(Name, 'SaveDirectory', ExtractFileDir(SaveDialog1.FileName));
		end;

		if(SaveDialog2.Filename <> '') then begin
			Ini.WriteString(Name, 'SaveDirectory2', ExtractFileDir(SaveDialog2.FileName));
		end;

		Ini.WriteBool(Name, 'RhythmUseWithSSGDrum', CheckBox50.Checked);
		Ini.WriteBool(Name, 'UsePPS', CheckBox51.Checked);
		Ini.WriteBool(Name, 'PMD86PCMMode', CheckBox52.Checked);
		Ini.WriteBool(Name, 'ADPCMPPZ8Emulate', CheckBox53.Checked);

		Ini.WriteString(Name, 'RhythmPath', FRhythmDir);

		Ini.WriteInteger(Name, 'NumOfPCMDir', PCMDir.Count);
		for i := 0 to PCMDir.Count - 1 do begin
			Ini.WriteString(Name,'PCMDir'+IntToStr(i+1), PCMDir[i]);
		end;

		Ini.WriteInteger(Name, 'FM_VOLDOWN', getfmvoldown2);
		Ini.WriteInteger(Name, 'SSG_VOLDOWN', getssgvoldown2);
		Ini.WriteInteger(Name, 'Rhythm_VOLDOWN', getrhythmvoldown2);
		Ini.WriteInteger(Name, 'ADPCM_VOLDOWN', getadpcmvoldown2);
		Ini.WriteInteger(Name, 'PPZ_VOLDOWN', getppzvoldown2);

		Ini.WriteInteger(Name, 'FMP_FM_VOLDOWN', fmp_getfmvoldown);
		Ini.WriteInteger(Name, 'FMP_SSG_VOLDOWN', fmp_getssgvoldown);
		Ini.WriteInteger(Name, 'FMP_Rhythm_VOLDOWN', fmp_getrhythmvoldown);
		Ini.WriteInteger(Name, 'FMP_ADPCM_VOLDOWN', fmp_getadpcmvoldown);
		Ini.WriteInteger(Name, 'FMP_PPZ_VOLDOWN', fmp_getppzvoldown);

		Ini.WriteBool(Name, 'UseHummingWindow', SPForm.UseHummingWindow);
		Ini.WriteInteger(Name, 'NumOfBand', Integer(SPForm.NumOfBand));
		Ini.WriteBool(Name, 'RandomPlay', RandomMenu.Checked);
		Ini.WriteBool(Name, 'LoopPlay', LoopMenu.Checked);


		Ini.WriteInteger(Name, 'FadeOutTime', FadeOutTime);
		Ini.WriteBool(Name, 'LoopToFadeOut', LoopToFadeOut);
		Ini.WriteBool(Name, 'Compressor', Compressor);
 		Ini.WriteBool(Name, 'UseTaskTray', TrayIcon1.Visible);

		Ini.WriteInteger(Name, 'NumOfLoopToFadeOut', NumOfLoopToFadeOut);
		Ini.WriteBool(Name, 'CheckMusicLength', CheckMusicLength);
		Ini.WriteInteger(Name, 'ParamDelay', ParamDelay);
		Ini.WriteBool(Name, 'Display50Flame', F50Flame);
		Ini.WriteBool(Name, 'SnapWindow', FSnap);
		Ini.WriteInteger(Name, 'SnapWidth', FSnapWidth);
		Ini.WriteBool(Name, 'NoPCMForcePlay', FNoPCMForcePlay);

		Ini.WriteInteger(Name, 'FMWait', FFMWait);
		Ini.WriteInteger(Name, 'SSGWait', FSSGWait);
		Ini.WriteInteger(Name, 'RhythmWait', FRhythmWait);
		Ini.WriteInteger(Name, 'ADPCMWait', FADPCMWait);

		Ini.WriteInteger(Name, 'PlayCount', PlayListForm.PlayIndex);
	finally
		Ini.Destroy;
		PCMDir.Destroy;
	end;

	// PlayList の書き出し
	if(PinForm1.FileDir[Length(PinForm1.FileDir)] = '\') then begin
		PlayListForm.SaveToFIle(PinForm1.FileDir + PlayListFileName);
	end else begin
		PlayListForm.SaveToFIle(PinForm1.FileDir + '\' + PlayListFileName);
	end;

	DeleteCriticalSection(Sect1);
end;


//***************************************************************************
// FMPフォントがインストールされているかどうか？
//***************************************************************************
function TFMPMDForm.GetInstalledFMPFont : Boolean;
begin
	result := TitleLabel.InstalledFMPFont;
end;


//***************************************************************************
// アプリケーションの最小化
//***************************************************************************
procedure TFMPMDForm.AppOnMinimize(Sender : TObject);
begin
	if(TrayIcon1.Visible = True) then begin
		ShowWindow(Application.Handle, SW_HIDE);
		SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong
			(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
	  ShowWindow(Application.Handle, SW_SHOW);
		Show1.Caption := MSG_POPUP_RESTORE;
	end;
end;


//***************************************************************************
// アプリケーションの復元
//***************************************************************************
procedure TFMPMDForm.AppOnRestore(Sender : TObject);
begin
	if(TrayIcon1.Visible = True) then begin
		ShowWindow(Application.Handle, SW_HIDE);
		SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong
			(Application.Handle, GWL_EXSTYLE) and not (WS_EX_TOOLWINDOW));
	  ShowWindow(Application.Handle, SW_SHOW);
		Show1.Caption := MSG_POPUP_MINIMIZE;
	end;
end;


//***************************************************************************
// Window の非クライアントエリアで左ボタンが押された
//***************************************************************************
procedure TFMPMDForm.NonClientLeftButtonDown(var Msg : TWMNCLButtonDown);
var
	GatherWindow : Integer;
  GatherWindow2 : Integer;
  i, j : Integer;
  FSnapWidthDiv2 : Integer;
	FromForm, DestForm : TForm;
begin
  if(Msg.HitTest = HTCAPTION) then begin
  	// タイトルバーがクリックされた

		if Assigned(FWindowList) then begin
      // FWindowList が登録されているなら、他の Window がくっついているかどうか調べる

  		GatherWindow := 1;
    	FSnapWidthDiv2 := FSnapWidth div 2;
	    for i := 1 to FWindowList.Count - 1 do begin
  	  	FWindowList[i].Flag := False;		// フラグをクリア
    	end;

  	  FromForm := nil;
    	DestForm := nil;

	    repeat
  	  	GatherWindow2 := GatherWindow;
    		for i := 0 to FWindowList.Count - 1 - 1 do begin
      		for j := i + 1 to FWindowList.Count - 1 do begin

        		// くっついているかどうか評価
						if(FWindowList[i].Form.Visible) and (FWindowList[j].Form.Visible) and
								(FWindowList[i].Flag) and (FWindowList[j].Flag = False) then begin
          		FromForm := FWindowList[i].Form;
            	DestForm := FWindowList[j].Form;
          	end else if(FWindowList[i].Form.Visible) and (FWindowList[j].Form.Visible) and
          			(FWindowList[i].Flag = False) and (FWindowList[j].Flag) then begin
          		FromForm := FWindowList[j].Form;
            	DestForm := FWindowList[i].Form;
          	end else begin
          		Continue;
          	end;

          	// 右側にくっついている場合
						if(Abs(FromForm.Left + FromForm.Width - DestForm.Left) <= FSnapWidthDiv2)
  	         		and ((FromForm.Top <= DestForm.Top + DestForm.Height)
    	           	and (FromForm.Top + FromForm.Height >= DestForm.Top)) then begin
      	     	FWindowList[i].Flag := True;
        	   	FWindowList[j].Flag := True;
							Inc(GatherWindow);

	          // 左側にくっついている場合
						end else if(Abs(DestForm.Left + DestForm.Width - FromForm.Left) <= FSnapWidthDiv2)
    	       		and ((FromForm.Top <= DestForm.Top + DestForm.Height)
      	         	and (FromForm.Top + FromForm.Height >= DestForm.Top)) then begin
        	   	FWindowList[i].Flag := True;
          	 	FWindowList[j].Flag := True;
							Inc(GatherWindow);

	          // 上側にくっついている場合
						end else if(Abs(DestForm.Top + DestForm.Height - FromForm.Top) <= FSnapWidthDiv2)
    	       		and ((FromForm.Left <= DestForm.Left + DestForm.Width)
      	         	and (FromForm.Left + FromForm.Width >= DestForm.Left)) then begin
        	   	FWindowList[i].Flag := True;
          	 	FWindowList[j].Flag := True;
							Inc(GatherWindow);

	          // 下側にくっついている場合
						end else if(Abs(FromForm.Top + FromForm.Height - DestForm.Top) <= FSnapWidthDiv2)
    	       		and ((FromForm.Left <= DestForm.Left + DestForm.Width)
      	         	and (FromForm.Left + FromForm.Width >= DestForm.Left)) then begin
        	   	FWindowList[i].Flag := True;
          	 	FWindowList[j].Flag := True;
							Inc(GatherWindow);
	          end;
  	      end;
    	  end;
    	until(GatherWindow = GatherWindow2);
    end;
  end;

	inherited;
end;


//***************************************************************************
// Window の位置／サイズを変更中
//***************************************************************************
procedure TFMPMDForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
var
	i : Integer;
begin
	// Window をスナップする
	if(FSnap = True) then begin
		Msg.WindowPos^.x := (Msg.WindowPos^.x div FSnapWidth) * FSnapWidth;
		Msg.WindowPos^.y := (Msg.WindowPos^.y div FSnapWidth) * FSnapWidth;
	end;

	// サイズ＝０の時は無視する
	if(Msg.WindowPos^.cx <> 0) and (Msg.WindowPos^.cy <> 0) then begin
		if Assigned(FWindowList) then begin
      // FWindowList が登録されているなら、他の Window を動かす
	   	for i := 1 to FWindowList.Count - 1 do begin
  	  	if(FWindowList[i].Flag = True) then begin
	  	  	FWindowList[i].Form.Left := FWindowList[i].Form.Left + (Msg.WindowPos^.x - Self.Left);
 		  		FWindowList[i].Form.Top  := FWindowList[i].Form.Top  + (Msg.WindowPos^.y - Self.Top );
      	end;
    	end;
 	  end;
  end;

  inherited;
end;


//***************************************************************************
// Window への D&D
//***************************************************************************
procedure TFMPMDForm.DropFiles(var Msg:TWMDROPFILES);
var
	FileName: array[0..1024] of Char;
	i, Files : Integer;
	StrList : TStringList;
begin
	PlayListForm.Clear;
	StrList := TStringList.Create;
	try
		// ﾄﾞﾛｯﾌﾟされたﾌｧｲﾙ数を取得
		Files:= DragQueryFile(Msg.Drop, $ffffffff, nil, 0);
		// ファイルのリストをListBoxに表示する
		for i := 0 to Files - 1 do begin
			DragQueryFile(Msg.Drop, i, FileName, Sizeof(FileName) - 1);
			StrList.Add(FileName);
		end;
		// 終了処理
		DragFinish(Msg.Drop);

		PlayListForm.AddStrings(StrList);
	finally
		Msg.result := 0;
		StrList.Destroy;
	end;

	if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
		Start_Play;		// 演奏開始
	end;
end;


//***************************************************************************
// 曲データのオープン＆演奏開始
//***************************************************************************
procedure TFMPMDForm.LoadButtonClick(Sender: TObject);
begin
	if((GetAsyncKeyState(VK_SHIFT) and $8000) <> 0) then begin	// SHIFT が押されている
		FolderOpenClick(Self);
	end else begin
		FileOpenClick(Self);
	end;
end;


//***************************************************************************
// ファイルのオープン＆演奏開始
//***************************************************************************
procedure TFMPMDForm.FileOpenClick(Sender: TObject);
var
	i : Integer;
	str : TStringList;
	dir : string;
	yen : string;
	filename : string;
	p : PChar;
begin
	Filter := '';
	for i := 0 to NumOfFilter*2-1 do begin
		Filter := Filter + FilterStr[i] + #0;
	end;
	Filter := Filter + #0;

	OpenFileName.lStructSize       := SizeOf(OpenFileName);
	OpenFileName.hwndOwner         := Handle;
	OpenFileName.hInstance         := HInstance;
	OpenFileName.lpstrFilter       := PChar(Filter);
	OpenFileName.lpstrCustomFilter := Nil;
	OpenFileName.nMaxCustFilter    := 0;
	OpenFileName.lpstrFile         := @DlgFileName[0];
	OpenFileName.nMaxFile          := sizeof(DlgFileName);
	OpenFileName.lpstrFileTitle    := Nil;
	OpenFileName.nMaxFileTitle     := 0;
	OpenFileName.lpstrTitle        := Nil;
	OpenFileName.nFileOffset       := 0;
	OpenFileName.nFileExtension    := 0;
	OpenFileName.lpstrDefExt       := Nil;
	OpenFileName.lCustData         := 0;
	OpenFileName.lpfnHook 		     := @ComDlg32DlgProc;
	OpenFileName.lpTemplateName    := MAKEINTRESOURCE(IDD_COMDLG32);
	OpenFileName.Flags             := OFN_HIDEREADONLY or OFN_FILEMUSTEXIST or
		OFN_EXPLORER or OFN_ENABLETEMPLATE or OFN_ENABLEHOOK or OFN_ALLOWMULTISELECT or OFN_ENABLESIZING;

	if(FLoadFirstOpen = True) then begin
		FLoadFirstOpen := False;
		OpenFileName.lpstrInitialDir   := PChar(FLoadInitialDir);
		BrowseDialog1.Directory := FLoadInitialDir;
	end else begin
		OpenFileName.lpstrInitialDir   := Nil;
	end;

	PartMaskForm.EnablePartMask := False;
	// Call the common dialog function.
	if(GetOpenFileName(OpenFileName) = True) then begin
		PlayListForm.Clear;
		if(OpenFileName.lpstrFile[StrLen(OpenFileName.lpstrFile)+1] = #0) then begin
			// １曲のみ
			PlayListForm.Add(String(OpenFileName.lpstrFile));
		end else begin
			// ２曲以上
			str := TStringList.Create;
			try
				dir := string(OpenFileName.lpstrFile);
				if(Length(dir) = 3) then begin
					yen := '';
				end else begin
					yen := '\';
				end;

				p := @OpenFileName.lpstrFile[Length(dir)];
				Inc(p);
				repeat
					filename := string(p);
					Inc(p, Length(filename));
					Inc(p);
					str.Add(dir + yen + filename);
				until (p^ = #0);
				PlayListForm.AddStrings(str);
			finally
				StrCopy(@DlgFileName[0], PChar(str[0]));
				str.Destroy;
			end;
		end;

		if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
			Start_Play;		// 演奏開始
		end;
	end;

	PartMaskForm.EnablePartMask := True;
end;


//***************************************************************************
// フォルダのオープン＆演奏開始
//***************************************************************************
procedure TFMPMDForm.FolderOpenClick(Sender: TObject);
begin
	PartMaskForm.EnablePartMask := False;

	if(FLoadFirstOpen = True) then begin
		FLoadFirstOpen := False;
		OpenFileName.lpstrInitialDir   := PChar(FLoadInitialDir);
		BrowseDialog1.Directory := FLoadInitialDir;
	end else begin
		OpenFileName.lpstrInitialDir   := Nil;
	end;

	if(BrowseDialog1.Execute = True) then begin
		PlayListForm.Clear;
		PlayListForm.Add(BrowseDialog1.Directory);

		if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
			Start_Play;		// 演奏開始
		end;
	end;
	
	PartMaskForm.EnablePartMask := True;
end;


//***************************************************************************
// コモンダイアログボックスのフック関数
//***************************************************************************
function ComDlg32DlgProc(Handle : HWND; uMsg : Cardinal;
				wPrm : WPARAM; lPrm : LPARAM) : Boolean;
var
	FileName : Array[0.._MAX_PATH] of Char;
	MemoMsg : Array[0..1024-1] of Char;
	commentpointer : TComment;
	commentstr : String;
	i : Integer;
begin
	result := False;
	if(uMsg = WM_NOTIFY) and (POFNOTIFY(lPrm)^.hdr.code = CDN_SELCHANGE) then begin
		if(SendMessage(GetParent(Handle), CDM_GETFILEPATH, WPARAM(sizeof(FileName)),
							LPARAM(LPSTR(@FileName[0]))) <= sizeof(FileName)) then begin

			if(AnsiCompareText(ExtractFileExt(FileName), '.opi') = 0) or
					(AnsiCompareText(ExtractFileExt(FileName), '.ovi') = 0) or
					(AnsiCompareText(ExtractFileExt(FileName), '.ozi') = 0) then begin
				// WinFMP

				CommentPointer[0] := PChar(@memomsg[  0]);
				CommentPointer[1] := PChar(@memomsg[ 82]);
				CommentPointer[2] := PChar(@memomsg[164]);
				if(fmp_fgetcomment3(CommentPointer, FileName) <> WINFMP_OK) then begin
					SetDlgItemText(Handle, IDE_SELECTED1, '');
					SetDlgItemText(Handle, IDE_SELECTED2, '');
					SetDlgItemText(Handle, IDE_SELECTED3, '');
				end else begin
					for i := 0 to 3-1 do begin
						commentstr := trimleft(spc3tospc2(zenspc2spc(string(CommentPointer[i]))));
						SetDlgItemText(Handle, IDE_SELECTED1 + i, PChar(commentstr));
					end;
				end;

			end else begin
				// PMDWin
				if(fgetmemo3(@MemoMsg[0], FileName, 1) <> PMDWIN_OK) then begin
					SetDlgItemText(Handle, IDE_SELECTED1, '');
					SetDlgItemText(Handle, IDE_SELECTED2, '');
					SetDlgItemText(Handle, IDE_SELECTED3, '');
				end else begin
					fgetmemo3(@MemoMsg[0], FileName, 1);		// Title
					SetDlgItemText(Handle, IDE_SELECTED1, @MemoMsg[0]);

					fgetmemo3(@MemoMsg[0], FileName, 2);		// Composer
					SetDlgItemText(Handle, IDE_SELECTED2, @MemoMsg[0]);

					fgetmemo3(@MemoMsg[0], FileName, 3);		// Arranger
					SetDlgItemText(Handle, IDE_SELECTED3, @MemoMsg[0]);
				end;
			end;
			result :=  True;
		end;
	end;
end;


//***************************************************************************
// ２重起動時の送信文字列の受け取り＆処理
//***************************************************************************
procedure TFMPMDForm.WndProc(var Msg: TMessage);
var
	aAtom1,aAtom2: TAtom;
	pcAtom1, pcAtom2: PChar;
	MsgID: UINT;
	FileName : String;
	str : TStringList;
begin
	MsgID:=RegisterWindowMessage(GlobalAtomUniqueName);
				 {アプリ間通信登録メッセージの取り出し}
	if Msg.Msg=MsgID then begin
		pcAtom1:=StrAlloc(AMAX_BUF+1);
		pcAtom2:=StrAlloc(AMAX_BUF+1);
		aAtom1:=LoWord(Msg.wParam);
		aAtom2:=LoWord(Msg.lParam);

		FileName := '';
		if GlobalGetAtomName(aAtom1,pcAtom1,AMAX_BUF+1)<>0 then begin
			FileName := PChar(pcAtom1);
		end;
		if GlobalGetAtomName(aAtom2,pcAtom2,AMAX_BUF+1)<>0 then begin
			FileName := FileName + PChar(pcAtom2);
		end;

		PlayListForm.Clear;
		str := TStringList.Create;

		try
			SplitAtomReceivedStr(TStrings(str), PChar(FileName));
			PlayListForm.AddStrings(str);
		finally
			str.Free;
		end;

		if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
			Start_Play;		// 演奏開始
		end;

		StrDispose(pcAtom1);
		StrDispose(pcAtom2);
	end;

	inherited WndProc(Msg);  {これを忘れない！}
end;


//***************************************************************************
// コマンドライン文字列の解析＆処理
//***************************************************************************
procedure TFMPMDForm.CommandLineCheck(CommandLine : TStrings);
var
	filenamebuf : Array[0..1024-1] of Char;
begin
	if(CommandLine.Count = 0) then Exit;
	if(CommandLine[0][1] = '/') or (CommandLine[0][1] = '-')then begin
		if(CommandLine[0][2] = 'P') or (CommandLine[0][2] = 'p') then begin
			EnterCriticalSection(Sect1);
			c_getmusicfilename(PChar(@filenamebuf[0]));
			LeaveCriticalSection(Sect1);
			if(string(filenamebuf) = '') then Exit;
			Start_Play;
		end else if(CommandLine[0][2] = 'S') or (CommandLine[0][2] = 's') then begin
			StopButtonClick(Self);
		end else if(CommandLine[0][2] = 'A') or (CommandLine[0][2] = 'a') then begin
			PauseButtonClick(Self);
		end else if(CommandLine[0][2] = 'F') or (CommandLine[0][2] = 'f') then begin
			FadeButtonClick(Self);
		end else if(CommandLine[0][2] = 'N') or (CommandLine[0][2] = 'n') then begin
			BitBtn7Click(Self);
		end else if(CommandLine[0][2] = 'B') or (CommandLine[0][2] = 'b') then begin
			BitBtn6Click(Self);
		end else begin
			ShowMessage2(MSG_ERROR_COMMANDLINE);
		end;
	end else begin
		PlayListForm.Clear;
		PlayListForm.AddStrings(CommandLine);

		if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
			Start_Play;		// 演奏開始
		end;
	end;
end;


//***************************************************************************
// 曲データのロード ＆ FMPMD への登録（単曲、PlayList は不可）
//***************************************************************************
function TFMPMDForm.LoadMusicData(FileName : String) : Boolean;
var
	i, rslt : Integer;
	path : Array[0..MAX_PCMDIR-1] of PChar;		// pcmdir の path のポインタ配列
	errmsg : Array[0..1024-1] of Char;
	str : String;
begin
	for i := 0 to PCMDir.Count-1 do begin
		path[i] := PChar(PCMDir[i]);
	end;
	path[PCMDir.Count] := nil;

	StopButtonClick(Self);		// 演奏停止
	EnterCriticalSection(Sect1);

	try
		if(setpcmdir(@path[0]) = False) or (fmp_setpcmdir(@path[0]) = False) then begin
			ShowMessage2(MSG_ERROR_SET_PCMDIR);
			result := False;
			Exit;
		end;

		if(AnsiCompareText(ExtractFileExt(FileName), '.opi') = 0) or
				(AnsiCompareText(ExtractFileExt(FileName), '.ovi') = 0) or
				(AnsiCompareText(ExtractFileExt(FileName), '.ozi') = 0) then begin
			// WinFMP
			if(FPlayDriver <> DRIVER_FMP) then begin
				FPlayDriver := DRIVER_FMP;
				PostMessage(StatusForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_FMP), 0);
				PostMessage(VolumeForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_FMP), 0);
				PostMessage(PartMaskForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_FMP), 0);
        Application.ProcessMessages;

				c_init := fmp_init;
				c_music_load := fmp_load;
				c_music_start := fmp_start;
				c_fadeout2 := fmp_fadeout2;
				c_getpcmdata := fmp_getpcmdata;
				c_getmusicfilename := fmp_getmusicfilename;
				c_getpcmfilename := fmp_getpcmfilename;
				c_getppzfilename := fmp_getppzfilename;
				c_setpos := fmp_setpos;
				c_getpos := fmp_getpos;
				c_getlength := fmp_getlength;
				c_getloopcount := fmp_getloopcount;
			end;
		end else begin
			// PMDWin
			if(FPlayDriver <> DRIVER_PMD) then begin
				FPlayDriver := DRIVER_PMD;
				PostMessage(StatusForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_PMD), 0);
				PostMessage(VolumeForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_PMD), 0);
				PostMessage(PartMaskForm.Handle, WM_DRIVERCHANDE, WPARAM(DRIVER_PMD), 0);

        c_init := pmdwininit;
				c_music_load := music_load;
				c_music_start := music_start;
				c_fadeout2 := fadeout2;
				c_getpcmdata := getpcmdata;
				c_getmusicfilename := getmusicfilename;
				c_getpcmfilename := getpcmfilename;
				c_getppzfilename := getppzfilename;
				c_setpos := setpos;
				c_getpos := getpos;
				c_getlength := getlength;
				c_getloopcount := getloopcount;
			end;
		end;

		rslt := c_music_load(PChar(FileName));
		if(rslt in [PMDWIN_OK, WARNING_PPC_ALREADY_LOAD, WARNING_P86_ALREADY_LOAD,
    	WARNING_PPS_ALREADY_LOAD, WARNING_PPZ1_ALREADY_LOAD, WARNING_PPZ2_ALREADY_LOAD]) then begin
			result := True;
			PromptForm.MusicChange(Filename, FPlayDriver);
			Exit;
    end;

    if(FNoPCMForcePlay = True) and (rslt in
				[	ERR_OPEN_PPC_FILE, ERR_OPEN_P86_FILE, ERR_OPEN_PPS_FILE,
					ERR_OPEN_PPZ1_FILE, ERR_OPEN_PPZ2_FILE,
					ERR_WRONG_PPC_FILE, ERR_WRONG_P86_FILE, ERR_WRONG_PPS_FILE,
					ERR_WRONG_PPZ1_FILE, ERR_WRONG_PPZ2_FILE
				]) then begin

			c_init(PChar(FRhythmDir));
			rslt := c_music_load(PChar(FileName));
			if(rslt in
					[	PMDWIN_OK, ERR_OPEN_PPC_FILE, ERR_OPEN_P86_FILE, ERR_OPEN_PPS_FILE,
						ERR_OPEN_PPZ1_FILE, ERR_OPEN_PPZ2_FILE,
						WARNING_PPC_ALREADY_LOAD,
						WARNING_P86_ALREADY_LOAD, WARNING_PPS_ALREADY_LOAD, WARNING_PPZ1_ALREADY_LOAD,
						WARNING_PPZ2_ALREADY_LOAD,
						ERR_WRONG_PPC_FILE, ERR_WRONG_P86_FILE, ERR_WRONG_PPS_FILE,
						ERR_WRONG_PPZ1_FILE, ERR_WRONG_PPZ2_FILE
					]) then begin

				result := True;
        PromptForm.MusicChange(Filename, FPlayDriver);
        Exit;
      end;
    end;

		case rslt of
			ERR_OPEN_MUSIC_FILE :
				ShowMessage2(MSG_ERROR_OPEN_FMPMDDATA);

			ERR_WRONG_MUSIC_FILE :
				ShowMessage2(MSG_ERROR_NOT_FMPMDDATA);

			ERR_OPEN_PPC_FILE :
				begin
					if(FPlayDriver = DRIVER_PMD) then begin
						fgetmemo(PChar(@errmsg[0]), PChar(FileName), 0);	// PPC の取得
					end else begin
						fmp_fgetdefinedpcmfilename(PChar(@errmsg[0]), PChar(FileName));		// PVI(FMP) の取得
					end;
					ShowMessage2(addand(errmsg) + MSG_ERROR_NOT_READ_PPCDATA);
				end;

			ERR_OPEN_P86_FILE :
				begin
					fgetmemo(PChar(@errmsg[0]), PChar(FileName), 0);	// P86 の取得
					ShowMessage2(addand(errmsg) + MSG_ERROR_NOT_READ_P86DATA);
				end;

			ERR_OPEN_PPS_FILE :
				begin
					fgetmemo(PChar(@errmsg[0]), PChar(FileName), -1);	// PPS の取得
					ShowMessage2(addand(errmsg) + MSG_ERROR_NOT_READ_PPSDATA);
				end;

			ERR_OPEN_PPZ1_FILE :
				begin
					if(FPlayDriver = DRIVER_PMD) then begin
						fgetmemo(PChar(@errmsg[0]), PChar(FileName), -2);	// PPZ1 の取得
						str := GetPPZ1(string(errmsg));
					end else begin
						// PPZ1(FMP) の取得
						fmp_fgetdefinedppzfilename(PChar(@errmsg[0]), PChar(@FileName[1]), 0);
						str := string(errmsg);
					end;
					ShowMessage2(addand(str) + MSG_ERROR_NOT_READ_PPZ1DATA);
				end;

			ERR_OPEN_PPZ2_FILE :
				begin
					fgetmemo(PChar(@errmsg[0]), PChar(FileName), -2);	// PPZ2 の取得
					str := GetPPZ2(string(errmsg));
					ShowMessage2(addand(str) + MSG_ERROR_NOT_READ_PPZ2DATA);
				end;

			ERR_WRONG_PPC_FILE :
				begin
					if(FPlayDriver = DRIVER_PMD) then begin
						fgetmemo(PChar(@errmsg[0]), PChar(FileName), 0);	// PPC の取得
					end else begin
						// PVI(FMP) の取得
						fmp_fgetdefinedpcmfilename(PChar(@errmsg[0]), PChar(FileName));
					end;
					ShowMessage2(addand(errmsg) + MSG_ERROR_NOT_PPCDATA);
				end;

			ERR_WRONG_P86_FILE :
				begin
					fgetmemo(PChar(@errmsg[0]), PChar(FileName), 0);	// P86 の取得
					ShowMessage2(addand(errmsg) + MSG_ERROR_NOT_P86DATA);
				end;

			ERR_WRONG_PPS_FILE :
				begin
					fgetmemo(PChar(@errmsg[0]), PChar(FileName), -1);	// PPS の取得
					ShowMessage2(addand(errmsg) + MSG_ERROR_NOT_PPSDATA);
				end;

			ERR_WRONG_PPZ1_FILE :
				begin
					if(FPlayDriver = DRIVER_PMD) then begin
						fgetmemo(PChar(@errmsg[0]), PChar(FileName), -2);	// PPZ1 の取得
						str := GetPPZ1(string(errmsg));
					end else begin
						fmp_fgetdefinedppzfilename(PChar(@errmsg[0]), PChar(FileName), 0);	// PPZ1(FMP) の取得
						str := string(errmsg);
					end;
					ShowMessage2(addand(str) + MSG_ERROR_NOT_PPZ1DATA);
				end;

			ERR_WRONG_PPZ2_FILE :
				begin
					fgetmemo(PChar(@errmsg[0]), PChar(FileName), -2);	// PPZ2 の取得
					str := GetPPZ2(string(errmsg));
					ShowMessage2(addand(str) + MSG_ERROR_NOT_PPZ2DATA);
				end;

			ERR_OUT_OF_MEMORY :
				ShowMessage2(MSG_ERROR_OUT_OF_MEMORY);

		else
			ShowMessage2(MSG_ERROR_OTHER);
		end;

	finally
		LeaveCriticalSection(Sect1);
	end;
	result := False;
end;


//***************************************************************************
// 演奏開始
//***************************************************************************
procedure TFMPMDForm.PlayButtonClick(Sender: TObject);
begin
	if(FPause) then begin
		PauseButtonClick(Self);
	end else begin
		if(PlayListForm.Count = 0) then begin
			LoadButtonClick(Self);
		end else begin
			if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
				Start_Play;		// 演奏開始
			end;
		end;
	end;
end;


//***************************************************************************
// Pause
//***************************************************************************
procedure TFMPMDForm.PauseButtonClick(Sender: TObject);
begin
	// Pause 解除のとき演奏位置をスライダーの位置にする
	if(LowLVPCM1.lhWaveOut <> 0) then begin
		if(FPause = True) then begin
			LowLVPCM1.Stop;
			EnterCriticalSection(Sect1);
			c_setpos(ExtTrackBar1.Position * 100);
			LeaveCriticalSection(Sect1);

			if(F50Flame = True) then begin
				LowLVPCM1.BufferSize := 2048;
				LowLVPCM1.NumOfBuffers := NumOfBuffers * 8;
				StatusForm.Interval := 20;		// 20msec 毎
			end else begin
				LowLVPCM1.BufferSize := 8192;
				LowLVPCM1.NumOfBuffers := NumOfBuffers * 2;
				StatusForm.Interval := 50;		// 50msec 毎
			end;

			StatusForm.Delay := LowLVPCM1.NumOfBuffers * LowLVPCM1.BufferSize * 1000
				div LowLVPCM1.nSamplesPerSec div (LowLVPCM1.wBitsPerSample div 8) div LowLVPCM1.nChannels + ParamDelay;
			PromptForm.Delay := StatusForm.Delay;

			LowLVPCM1.Play;

		end else begin;
			LowLVPCM1.Pause;
		end;

		FPause := not FPause;

		PostMessage(StatusForm.Handle, WM_PLAYPAUSE, 0, 0);
		PostMessage(PromptForm.Handle, WM_PLAYPAUSE, 0, 0);
	end;
(*
	if(FPause = True) then begin
		PostMessage(StatusForm.Handle, WM_PLAYSTOP, 0, 0);
	end else begin
		PostMessage(StatusForm.Handle, WM_PLAYSTART, 0, 0);
	end;
*)
end;


//***************************************************************************
// 演奏停止
//***************************************************************************
procedure TFMPMDForm.StopButtonClick(Sender: TObject);
begin
	Stop_Play;
	if(Fw <> -1) then begin
		WaveHeader.RIFFsize := WaveHeader.datasize + SizeOf(WaveHeader)-8;
		FileSeek(Fw, 0, 0);
		FileWrite(Fw, WaveHeader, SizeOf(WaveHeader));

		FileClose(Fw);
		Fw := -1;
	end;
end;


//***************************************************************************
// フェードアウト
//***************************************************************************
procedure TFMPMDForm.FadeButtonClick(Sender: TObject);
begin
	EnterCriticalSection(Sect1);
	c_fadeout2(FadeOutTime);
	LeaveCriticalSection(Sect1);
	FFadeOut := True;
end;


//***************************************************************************
// 次の曲を演奏
//***************************************************************************
procedure TFMPMDForm.BitBtn7Click(Sender: TObject);
begin
	StopButtonClick(Self);
	if(PlayListForm.Next = True) then begin
		if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
			Start_Play;		// 演奏開始
		end;
	end;
end;


//***************************************************************************
// 前の曲を演奏
//***************************************************************************
procedure TFMPMDForm.BitBtn6Click(Sender: TObject);
begin
	EnterCriticalSection(Sect1);
	LeaveCriticalSection(Sect1);
	StopButtonClick(Self);

	if(PlayListForm.Prev = True) then begin
		if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
			Start_Play;		// 演奏開始
		end;
	end;
end;


//***************************************************************************
// プレイリストでダブルクリックされた
//***************************************************************************
procedure TFMPMDForm.PlayListSelect(Sender: TObject);
begin
	StopButtonClick(Self);
	if(LoadMusicData(PlayListForm.PlayFileName) = True) then begin
		Start_Play;		// 演奏開始
	end;
end;


//***************************************************************************
// 次の曲を演奏（メッセージ）
//***************************************************************************
procedure TFMPMDForm.PlayNext(var Msg:TMessage);
begin
	if(FFadeOut = True) then begin		// 手動 FadeOut なら止める
		StopButtonClick(Self);
	end else begin
		BitBtn7Click(Self);
	end;
end;


//***************************************************************************
// 再生位置変更
//***************************************************************************
procedure TFMPMDForm.ExtTrackBar1MouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	FTrackBarMouseDown := True;
end;


procedure TFMPMDForm.ExtTrackBar1KeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	FTrackBarMouseDown := True;
end;


procedure TFMPMDForm.ExtTrackBar1MouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
var
	TempMsg : TMessage;
begin
	if(FTrackBarMouseDown = True) then begin
		TempMsg.WParam := 0;		// 何でも良い
		TempMsg.LParam := 0;		// 何でも良い
		SetTimer(TempMsg);
	end;
end;


procedure TFMPMDForm.ExtTrackBar1MouseUp(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	if(LowLVPCM1.lhWaveOut <> 0) and (FPause = False) then begin
		PostMessage(PromptForm.Handle, WM_POSITIONMOVE_START, 0, 0);
		LowLVPCM1.Stop;
		EnterCriticalSection(Sect1);
		c_setpos(ExtTrackBar1.Position * 100);
		LeaveCriticalSection(Sect1);

		if(F50Flame = True) then begin
			LowLVPCM1.BufferSize := 2048;
			LowLVPCM1.NumOfBuffers := NumOfBuffers * 8;
			StatusForm.Interval := 20;		// 20msec 毎
		end else begin
			LowLVPCM1.BufferSize := 8192;
			LowLVPCM1.NumOfBuffers := NumOfBuffers * 2;
			StatusForm.Interval := 50;		// 50msec 毎
		end;

		StatusForm.Delay := LowLVPCM1.NumOfBuffers * LowLVPCM1.BufferSize * 1000
			div LowLVPCM1.nSamplesPerSec div (LowLVPCM1.wBitsPerSample div 8) div LowLVPCM1.nChannels + ParamDelay;
		PromptForm.Delay := StatusForm.Delay;

		LowLVPCM1.Play;
		PostMessage(PromptForm.Handle, WM_POSITIONMOVE_END, 0, 0);
	end;
	FTrackBarMouseDown := False;
end;


procedure TFMPMDForm.ExtTrackBar1KeyUp(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	if(LowLVPCM1.lhWaveOut <> 0) and (FPause = False) then begin
		if(Key in [VK_DOWN, VK_UP, VK_LEFT, VK_RIGHT, VK_HOME, VK_END,
																					VK_PRIOR, VK_NEXT]) then begin
			PostMessage(PromptForm.Handle, WM_POSITIONMOVE_START, 0, 0);
			LowLVPCM1.Stop;
			EnterCriticalSection(Sect1);
			c_setpos(ExtTrackBar1.Position * 100);
			LeaveCriticalSection(Sect1);

			if(F50Flame = True) then begin
				LowLVPCM1.BufferSize := 2048;
				LowLVPCM1.NumOfBuffers := NumOfBuffers * 8;
				StatusForm.Interval := 20;		// 20msec 毎
			end else begin
				LowLVPCM1.BufferSize := 8192;
				LowLVPCM1.NumOfBuffers := NumOfBuffers * 2;
				StatusForm.Interval := 50;		// 50msec 毎
			end;

			StatusForm.Delay := LowLVPCM1.NumOfBuffers * LowLVPCM1.BufferSize * 1000
				div LowLVPCM1.nSamplesPerSec div (LowLVPCM1.wBitsPerSample div 8) div LowLVPCM1.nChannels + ParamDelay;
			PromptForm.Delay := StatusForm.Delay;

			LowLVPCM1.Play;
			PostMessage(PromptForm.Handle, WM_POSITIONMOVE_END, 0, 0);
		end;
	end;
	FTrackBarMouseDown := False;
end;


//***************************************************************************
// 再生位置表示
//***************************************************************************
procedure TFMPMDForm.SetTimer(var Msg:TMessage);
begin
	if(FTrackBarMouseDown = False) then begin
		Labelms.Caption := Format('%.2d', [(Msg.LParam mod 1000) div 10]);

		ExtTrackBar1.Position := Msg.LParam div 100;	// 1/10sec 単位

	  Msg.LParam := Msg.LParam div 1000;

		Labels.Caption := Format('%.2d', [Msg.LParam mod 60]);
		Labelm.Caption := Format('%.2d', [Msg.LParam div 60]);

	end else begin

		Labelms.Caption := Format('%.1d0', [ExtTrackBar1.Position mod 10]);
		Labels.Caption  := Format('%.2d', [(ExtTrackBar1.Position div 10)mod 60]);
		Labelm.Caption  := Format('%.2d', [ExtTrackBar1.Position div 600]);
	end;
end;


//***************************************************************************
// 演奏停止(Sub)
//***************************************************************************
procedure TFMPMDForm.Stop_Play;
begin
	EnterCriticalSection(Sect1);
	music_stop;
	fmp_stop;
	LeaveCriticalSection(Sect1);
	LowLVPCM1.Stop;
	PostMessage(handle, WM_SetTimer, 0, 0);
	PostMessage(StatusForm.Handle, WM_PLAYSTOP, 0, 0);
	PostMessage(PromptForm.Handle, WM_PLAYSTOP, 0, 0);
	Application.ProcessMessages;
	FPause := False;
	FFadeOut := False;
end;


//***************************************************************************
// 演奏開始(Sub)
//***************************************************************************
procedure TFMPMDForm.Start_Play;
var
	namebuf : Array[0..1024-1] of Char;
	length, loop : Integer;
	CommentPointer : TComment;
	commentbuf: String;
begin
	Stop_Play;		// 演奏停止
	lms := -1;		// 曲停止時の時間

	if(CheckMusicLength = True) then begin
		EnterCriticalSection(Sect1);
		c_getmusicfilename(@namebuf[0]);
		c_getlength(PChar(PlayListForm.PlayFileName), length, loop);
		LeaveCriticalSection(Sect1);
		ExtTrackBar1.Max := (length + loop * (NumOfLoopToFadeOut - 1)) div 100;
			if(LoopToFadeOut = True) and (loop > 0) then begin
			ExtTrackBar1.Max := ExtTrackBar1.Max + FadeOutTime div 100;
		end;

		(*
		if(loop = 0) then begin
			ExtTrackBar1.Max := ExtTrackBar1.Max + PLAY_STOP_AFTER_MUSIC_STOP div 100;
		end;
	*)
		if(ExtTrackBar1.Max < 50) then begin
			ExtTrackBar1.Frequency := 1;
		end else if(ExtTrackBar1.Max < 600) then begin
			ExtTrackBar1.Frequency := 10;
		end else begin
			ExtTrackBar1.Frequency := 100;
		end;
	end else begin
		ExtTrackBar1.Max := 3000;					// ５分
		ExtTrackBar1.Frequency := 100;		// １０秒
	end;

	EnterCriticalSection(Sect1);
	setpcmrate(freq);
	fmp_setpcmrate(freq);
	setfmcalc55k(FFMCalc55k);
	fmp_setfmcalc55k(FFMCalc55k);

	if(FPPZratechange = True) then begin
		setppzrate(ppzrate);
		fmp_setppzrate(ppzrate);
	end;

	c_music_start;
	LeaveCriticalSection(Sect1);
	PartMaskForm.SetAllPartMask;
	LowLVPCM1.nSamplesPerSec := freq;

	if(F50Flame = True) then begin
		LowLVPCM1.BufferSize := 2048;
		LowLVPCM1.NumOfBuffers := NumOfBuffers * 8;
		StatusForm.Interval := 20;		// 20msec 毎
	end else begin
		LowLVPCM1.BufferSize := 8192;
		LowLVPCM1.NumOfBuffers := NumOfBuffers * 2;
		StatusForm.Interval := 50;		// 50msec 毎
	end;

	StatusForm.Delay := LowLVPCM1.NumOfBuffers * LowLVPCM1.BufferSize * 1000
		div LowLVPCM1.nSamplesPerSec div (LowLVPCM1.wBitsPerSample div 8) div LowLVPCM1.nChannels + ParamDelay;
	PromptForm.Delay := StatusForm.Delay;

	FPlayFirst := True;
	FFadeOutFirst := True;

	LowLVPCM1.Play;

	EnterCriticalSection(Sect1);

	if(FPlayDriver = DRIVER_PMD) then begin				// PMDWin の場合
		fgetmemo3(@namebuf[0], nil, 1);		// Title
		TitleLabel.Caption := string(namebuf);
	end else begin																	// WinFMP の場合
		CommentPointer[0] := PChar(@namebuf[  0]);
		CommentPointer[1] := PChar(@namebuf[ 82]);
		CommentPointer[2] := PChar(@namebuf[164]);

		fmp_fgetcomment3(CommentPointer, nil);				// Title
		commentbuf := spc3tospc2(zenspc2spc(string(CommentPointer[0])
				+ string(CommentPointer[1]) + string(CommentPointer[2])));

		TitleLabel.Caption := commentbuf;
	end;
	LeaveCriticalSection(Sect1);

	StatusForm.DisplayMemo(PlayListForm.PlayFileName);
	PostMessage(StatusForm.Handle, WM_PLAYSTART, 0, 0);
	PostMessage(PromptForm.Handle, WM_PLAYSTART, 0, 0);
	Application.ProcessMessages;
end;

//***************************************************************************
// セーブ開始
//***************************************************************************
procedure TFMPMDForm.SaveButtonClick(Sender: TObject);
var
	namebuf : Array[0..1024-1] of Char;
begin
(*
	EnterCriticalSection(Sect1);
	c_getmusicfilename(PChar(@namebuf[0]));
	LeaveCriticalSection(Sect1);
	if(string(namebuf) = '') then begin
		ShowMessage(MSG_ANNOUNCE_READ_FMPMDDATA);
		Exit;
	end;
*)

	if(PlayListForm.Count = 0) then begin
		ShowMessage(MSG_ANNOUNCE_READ_FMPMDDATA);
		Exit;
  end;
  
	if(LoadMusicData(PlayListForm.PlayFileName) = False) then begin
		ShowMessage(MSG_ANNOUNCE_READ_FMPMDDATA);
		Exit;
	end;

	if(FSaveFirstOpen = True) then begin
		FSaveFirstOpen := False;
		SaveDialog1.InitialDir := FSaveInitialDir;
	end else begin
		SaveDialog1.InitialDir := '';
	end;

 	c_getmusicfilename(PChar(@namebuf[0]));

	StrScan(PChar(@namebuf[0]), '.')^ := #0;		// 拡張子以降を cut
	SaveDialog1.Filename := ExtractFileName(string(namebuf) + '.wav');

	if(SaveDialog1.Execute = False) then Exit;

	Fw := FileCreate(SaveDialog1.FileName);
	if(Fw = -1) then Begin
		ShowMessage(SaveDialog1.FileName + MSG_ERROR_NOT_OPEN_SAVEFILE);
		Exit;
	end;

	WaveHeader.RIFFstr := 'RIFF';
	WaveHeader.WAVEstr := 'WAVE';
	WaveHeader.fmtstr := 'fmt ';
	WaveHeader.fmtsize := $10;
	WaveHeader.formatID := 1;
	WaveHeader.nChannels := 2;

	WaveHeader.nSamplesPerSec := freq;

	WaveHeader.wBitsPerSample := 16;
	WaveHeader.nBlockAlign :=
			WaveHeader.nChannels * WaveHeader.wBitsPerSample div 8;
	WaveHeader.nAvgBytesPerSec :=
			WaveHeader.nSamplesPerSec * WaveHeader.nChannels *
			WaveHeader.wBitsPerSample div 8;
	WaveHeader.datastr := 'data';
	WaveHeader.datasize := 0;

	FileWrite(Fw, WaveHeader, SizeOf(WaveHeader));

	Start_Play;
end;


//***************************************************************************
// PCM バッファが空になった
//***************************************************************************
procedure TFMPMDForm.LowLVPCM1BufferEmpty(Sender: TObject);
var
	i : Integer;
	pcmbuf : Array[0..65536*2] of SmallInt;
	ms : Integer;
begin
	EnterCriticalSection(Sect1);
	c_getpcmdata(@pcmbuf[0], LowLVPCM1.BufferSize div 4);
	ms := c_getpos;
	LeaveCriticalSection(Sect1);

	// コンプレッサをかける
	if(Compressor) then begin
		for i := 0 to LowLVPCM1.BufferSize div SizeOf(SmallInt) - 1 do begin
			pcmbuf[i] := CompressorTable[pcmbuf[i]];
		end;
	end;

	LowLVPCM1.SetBuffer(@pcmBuf[0], LowLVPCM1.Buffersize);

	if(Fw <> -1) then begin
		FileWrite(Fw, pcmbuf[0], LowLVPCM1.BufferSize);
		Inc(WaveHeader.datasize, LowLVPCM1.BufferSize);
	end;

	try
		EnterCriticalSection(Sect1);
		if(FPlayFirst = True) then begin
			PostMessage(VolumeForm.Handle, WM_SetVolDown, 0, 0);
			if(getpmd86pcmmode) then begin
				PostMessage(CheckBox52.handle, BM_SETCHECK, BST_CHECKED, 0);
			end else begin
				PostMessage(CheckBox52.handle, BM_SETCHECK, BST_UNCHECKED, 0);
			end;
			FPlayFirst := False;
		end;

		PostMessage(handle, WM_SetTimer, 0, ms);

		// 指定回数ループしたらフェードアウトする
		if(FFadeOutFirst = True) and (c_getloopcount >= NumOfLoopToFadeOut) and
					((LoopToFadeOut = True) or (PlayListForm.Count > 1)) then begin
			FFadeOutFirst := False;
			c_fadeout2(FadeOutTime);
		end;

		// 演奏後 PLAY_STOP_AFTER_MUSIC_STOP 経過か Fadeout 終了したら次の曲へ
		if(lms >= 0) then begin
			if((FFadeOutFirst = True) and (ms - lms >= PLAY_STOP_AFTER_MUSIC_STOP)) or
					((FFadeOutFirst = False) and (ms >= lms))then begin
				FFadeOutFirst := True;
				lms := -1;
				PostMessage(handle, WM_PLAYNEXT, 0, 0);
			end;

		// 曲が終わったかどうかのチェック
		end else if(c_getloopcount = -1) then begin
			lms := ms;
		end;

	finally
		LeaveCriticalSection(Sect1);
	end;
end;


//***************************************************************************
// 終了
//***************************************************************************
procedure TFMPMDForm.Exit1Click(Sender: TObject);
begin
	Close;
end;


//***************************************************************************
// バージョン情報
//***************************************************************************
procedure TFMPMDForm.K1Click(Sender: TObject);
begin
	VersionForm.ShowModal;
end;


//***************************************************************************
// PlayList 表示
//***************************************************************************
procedure TFMPMDForm.PlayListMenuClick(Sender: TObject);
begin
	if(PlayListForm.Visible = True) then begin
		PlayListForm.Close;
	end else begin
  	PlayListForm.Show;
  end;
end;


//***************************************************************************
// Volume 調整表示
//***************************************************************************
procedure TFMPMDForm.VolumeMenuClick(Sender: TObject);
begin
	if(VolumeForm.Visible = True) then begin
		VolumeForm.Close;
	end else begin
  	VolumeForm.Show;
  end;
end;


//***************************************************************************
// PartMask 表示
//***************************************************************************
procedure TFMPMDForm.PartMaskMenuClick(Sender: TObject);
begin
	if(PartMaskForm.Visible = True) then begin
		PartMaskForm.Close;
	end else begin
  	PartMaskForm.Show;
	end;
end;


//***************************************************************************
// レベルメーター表示
//***************************************************************************
procedure TFMPMDForm.LevelMeterMenuClick(Sender: TObject);
begin
	if(HRLVMeterForm.Visible = True) then begin
		HRLVMeterForm.Close;
	end else begin
		HRLVMeterForm.Start(LowLVPCM1);
	end;
end;


//***************************************************************************
// スペアナ表示
//***************************************************************************
procedure TFMPMDForm.SpeanaMenuClick(Sender: TObject);
begin
	if(SPForm.Visible = True) then begin
		SPForm.Close;
	end else begin
		SPForm.Start(LowLVPCM1);
	end;
end;


//***************************************************************************
// パラメーター表示
//***************************************************************************
procedure TFMPMDForm.ParamaterMenuClick(Sender: TObject);
begin
	if(StatusForm.Visible = True) then begin
		StatusForm.Close;
	end else begin
		StatusForm.Start;
	end;
end;


//***************************************************************************
// コンソール表示
//***************************************************************************
procedure TFMPMDForm.ConsoleMenuClick(Sender: TObject);
begin
	if(PromptForm.Visible = True) then begin
		PromptForm.Close;
	end else begin
		PromptForm.Show;
	end;
end;


//***************************************************************************
// PPS を鳴らすか？設定
//***************************************************************************
procedure TFMPMDForm.CheckBox51Click(Sender: TObject);
begin
	EnterCriticalSection(Sect1);
//	CheckBox50.Enabled := not CheckBox51.Checked;
	setppsuse(CheckBox51.Checked);
	LeaveCriticalSection(Sect1);
end;


//***************************************************************************
// SSGドラムと同時にリズム音源を鳴らすか？設定
//***************************************************************************
procedure TFMPMDForm.CheckBox50Click(Sender: TObject);
begin
	EnterCriticalSection(Sect1);
	setrhythmwithssgeffect(CheckBox50.Checked);
	LeaveCriticalSection(Sect1);
end;


//***************************************************************************
// PMD86 を PMDB2 互換にするか？設定
//***************************************************************************
procedure TFMPMDForm.CheckBox52Click(Sender: TObject);
begin
	EnterCriticalSection(Sect1);
	setpmd86pcmmode(CheckBox52.Checked);
	LeaveCriticalSection(Sect1);
end;


//***************************************************************************
// WinFMP の ADPCM Part を PPZ8 でエミュレートするか？設定
//***************************************************************************
procedure TFMPMDForm.CheckBox53Click(Sender: TObject);
begin
	EnterCriticalSection(Sect1);
	fmp_setadpcmppz8emulate(CheckBox53.Checked);
	LeaveCriticalSection(Sect1);
end;


//***************************************************************************
// アクティブ化して ShowMessage
//***************************************************************************
procedure TFMPMDForm.ShowMessage2(str : String);
begin
	SetForegroundWindow(Handle);
	ShowMessage(str);
end;

//***************************************************************************
// メモ文字列から PPZ1 を取得
//***************************************************************************
function TFMPMDForm.GetPPZ1(str : String) : String;
var
	p : Integer;
begin
	p := Pos(',', str);
	if(p = 0) then begin
		result := str;
	end else begin
		result := Copy(str, 1, p-1);
	end;
end;

//***************************************************************************
// メモ文字列から PPZ2 を取得
//***************************************************************************
function TFMPMDForm.GetPPZ2(str : String) : String;
var
	p : Integer;
begin
	p := Pos(',', str);
	if(p = 0) then begin
		result := '';
	end else begin
		result := Copy(str, p+1, length(str)-p);
	end;
end;


//***************************************************************************
// 環境設定
//***************************************************************************
procedure TFMPMDForm.KE3Click(Sender: TObject);
begin
	EnvForm.freq := freq;
	EnvForm.PPZRate := PPZRate;
	EnvForm.PPZRateChange := FPPZRateChange;
	EnvForm.NumOfBuffers := NumOfBuffers;
	EnvForm.DeviceID := LowLVPCM1.DeviceID;
	EnvForm.PCMDir := PCMDir;
	EnvForm.RhythmDir := FRhythmDir;

	EnvForm.FMip  := FFMCalc55k;
	EnvForm.PPSip := FPPSip;
	EnvForm.P86ip := FP86ip;
	EnvForm.PPZip := FPPZip;
	EnvForm.UseHummingWindow := SPForm.UseHummingWindow;
	EnvForm.NumOfBand := SPForm.NumOfBand;

	EnvForm.FadeOutTime := FadeOutTime;
	EnvForm.LoopToFadeOut := LoopToFadeOut;
	EnvForm.Compressor := Compressor;
  EnvForm.UseTaskTray := TrayIcon1.Visible;
	EnvForm.NumOfLoopToFadeOut := NumOfLoopToFadeOut;
	EnvForm.CheckMusicLength := CheckMusicLength;
	EnvForm.ParamDelay := ParamDelay;
	EnvForm.Display50Flame := F50Flame;
	EnvForm.Snap := FSnap;
	EnvForm.SnapWidth := FSnapWidth;
	EnvForm.NoPCMForcePlay := FNoPCMForcePlay;
	EnvForm.FMWait := FFMWait;
	EnvForm.SSGWait := FSSGWait;
	EnvForm.RhythmWait := FRhythmWait;
	EnvForm.ADPCMWait := FADPCMWait;

	PartMaskForm.EnablePartMask := False;
	if(EnvForm.ShowModal = mrOK) then begin
//		StopButtonClick(Self);
		freq := EnvForm.freq;
		PPZRate := EnvForm.PPZRate;
		FPPZRateChange := EnvForm.PPZRateChange;
		FadeOutTime := EnvForm.FadeOutTime;
		LoopToFadeOut := EnvForm.LoopToFadeOut;
		Compressor := EnvForm.Compressor;
	  TrayIcon1.Visible := EnvForm.UseTaskTray;

		// トレイアイコン表示→非表示でメインフォームが最小化されている時、
    // タイトルバーを表示する
    if(TrayIcon1.Visible = False) and (Show1.Caption = MSG_POPUP_RESTORE) then begin
			ShowWindow(Application.Handle, SW_HIDE);
			SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong
				(Application.Handle, GWL_EXSTYLE) and not (WS_EX_TOOLWINDOW));
	  	ShowWindow(Application.Handle, SW_SHOW);
    end;

		NumOfLoopToFadeOut := EnvForm.NumOfLoopToFadeOut;
		CheckMusicLength := EnvForm.CheckMusicLength;
		ParamDelay := EnvForm.ParamDelay;
		F50Flame := EnvForm.Display50Flame;
		FSnap := EnvForm.Snap;
		FSnapWidth := EnvForm.SnapWidth;
		FNoPCMForcePlay := EnvForm.NoPCMForcePlay;

//		setpcmrate(freq);
//		fmp_setpcmrate(freq);
//    if(freq <> SOUND_55K) then LowLVPCM1.nSamplesPerSec := freq;
		PCMDir.Assign(EnvForm.PCMDir);
		LowLVPCM1.DeviceID := EnvForm.DeviceID;
		NumOfBuffers := EnvForm.NumOfBuffers;

		FFMCalc55k  := EnvForm.FMip;
		FPPSip := EnvForm.PPSip;
		FP86ip := EnvForm.P86ip;
		FPPZip := EnvForm.PPZip;
		SPForm.UseHummingWindow := EnvForm.UseHummingWindow;
		SPForm.NumOfBand := EnvForm.NumOfBand;
		FFMWait := EnvForm.FMWait;
		FSSGWait := EnvForm.SSGWait;
		FRhythmWait := EnvForm.RhythmWait;
		FADPCMWait := EnvForm.ADPCMWait;

		EnterCriticalSection(Sect1);
		setppsinterpolation(FPPSip);
		setp86interpolation(FP86ip);
		setppzinterpolation(FPPZip);
		setfmwait(FFMWait);
		setssgwait(FSSGWait);
		setrhythmwait(FRhythmWait);
		setadpcmwait(FADPCMWait);
		fmp_setfmwait(FFMWait);
		fmp_setssgwait(FSSGWait);
		fmp_setrhythmwait(FRhythmWait);
		fmp_setadpcmwait(FADPCMWait);
		fmp_setppzinterpolation(FPPZip);
		LeaveCriticalSection(Sect1);

		if(EnvForm.RhythmDir <> FRhythmDir) then begin
			StopButtonClick(Self);
			FRhythmDir := EnvForm.RhythmDir;

			EnterCriticalSection(Sect1);
			if(loadrhythmsample(PChar(FRhythmDir)) = False) or
						(fmp_loadrhythmsample(PChar(FRhythmDir)) = False) then begin
				LeaveCriticalSection(Sect1);
				ShowMessage(MSG_ERROR_NOT_READ_RHYTHM);
			end else begin
				LeaveCriticalSection(Sect1);
			end;

//      ShowMessage(MSG_ANNOUNCE_CHANGE_RHYTHMDIR);
		end;
	end;
	PartMaskForm.EnablePartMask := True;
end;


//***************************************************************************
// PPC 手動読み込み
//***************************************************************************
procedure TFMPMDForm.PPCC1Click(Sender: TObject);
var
	rslt : Integer;
begin
	if(FLoadPFirstOpen = True) then begin
		FLoadPFirstOpen := False;
		OpenDialog2.InitialDir := FLoadPInitialDir;
	end else begin
		OpenDialog2.InitialDir := '';
	end;

	if(OpenDialog2.FilterIndex <> 1) and (OpenDialog2.FilterIndex <> 4) then begin
		OpenDialog2.FilterIndex := 1;
	end;

	PartMaskForm.EnablePartMask := False;
	try
		if(OpenDialog2.Execute = False) then Exit;
	finally
		PartMaskForm.EnablePartMask := True;
	end;

	EnterCriticalSection(Sect1);
	rslt := ppc_load(PChar(OpenDialog2.FileName));
	LeaveCriticalSection(Sect1);

	case rslt of
		PMDWIN_OK : 								Exit;
		ERR_OPEN_PPC_FILE :         ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_READ_PPCDATA);
		ERR_OUT_OF_MEMORY :         ShowMessage(MSG_ERROR_OUT_OF_MEMORY);
		ERR_WRONG_PPC_FILE :        ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_PPCDATA);
		WARNING_PPC_ALREADY_LOAD :	ShowMessage(OpenDialog2.FileName + MSG_WARNING_ALREADY_READ_PPCDATA);
	else
		ShowMessage(MSG_ERROR_OTHER);
	end;
end;


//***************************************************************************
// PPS 手動読み込み
//***************************************************************************
procedure TFMPMDForm.PPSS1Click(Sender: TObject);
var
	rslt : Integer;
begin
	if(FLoadPFirstOpen = True) then begin
		FLoadPFirstOpen := False;
		OpenDialog2.InitialDir := FLoadPInitialDir;
	end else begin
		OpenDialog2.InitialDir := '';
	end;

	if(OpenDialog2.FilterIndex <> 3) then begin
		OpenDialog2.FilterIndex := 3;
	end;

	PartMaskForm.EnablePartMask := False;
	try
		if(OpenDialog2.Execute = False) then Exit;
	finally
		PartMaskForm.EnablePartMask := True;
	end;

	EnterCriticalSection(Sect1);
	rslt := pps_load(PChar(OpenDialog2.FileName));
	LeaveCriticalSection(Sect1);

	case rslt of
		PMDWIN_OK : 								Exit;
		ERR_OPEN_PPS_FILE :         ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_READ_PPSDATA);
		ERR_OUT_OF_MEMORY :         ShowMessage(MSG_ERROR_OUT_OF_MEMORY);
		WARNING_PPS_ALREADY_LOAD :	ShowMessage(OpenDialog2.FileName + MSG_WARNING_ALREADY_READ_PPSDATA);
	else
		ShowMessage(MSG_ERROR_OTHER);
	end;
end;


//***************************************************************************
// P86 手動読み込み
//***************************************************************************
procedure TFMPMDForm.P8681Click(Sender: TObject);
var
	rslt : Integer;
begin
	if(FLoadPFirstOpen = True) then begin
		FLoadPFirstOpen := False;
		OpenDialog2.InitialDir := FLoadPInitialDir;
	end else begin
		OpenDialog2.InitialDir := '';
	end;

	if(OpenDialog2.FilterIndex <> 2) then begin
		OpenDialog2.FilterIndex := 2;
	end;

	PartMaskForm.EnablePartMask := False;
	try
		if(OpenDialog2.Execute = False) then Exit;
	finally
		PartMaskForm.EnablePartMask := True;
	end;

	EnterCriticalSection(Sect1);
	rslt := p86_load(PChar(OpenDialog2.FileName));
	LeaveCriticalSection(Sect1);

	case rslt of
		PMDWIN_OK : 								Exit;
		ERR_OPEN_P86_FILE :         ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_READ_P86DATA);
		ERR_WRONG_P86_FILE :       	ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_P86DATA);
		ERR_OUT_OF_MEMORY :         ShowMessage(MSG_ERROR_OUT_OF_MEMORY);
		WARNING_P86_ALREADY_LOAD :	ShowMessage(OpenDialog2.FileName + MSG_WARNING_ALREADY_READ_P86DATA);
	else
		ShowMessage(MSG_ERROR_OTHER);
	end;
end;


//***************************************************************************
// PPZ 手動読み込み
//***************************************************************************
procedure TFMPMDForm.PPZZ1Click(Sender: TObject);
var
	rslt : Integer;
begin
	if(FLoadPFirstOpen = True) then begin
		FLoadPFirstOpen := False;
		OpenDialog2.InitialDir := FLoadPInitialDir;
	end else begin
		OpenDialog2.InitialDir := '';
	end;

	if(OpenDialog2.FilterIndex <> 4) and (OpenDialog2.FilterIndex <> 5) then begin
		OpenDialog2.FilterIndex := 5;
	end;

	PartMaskForm.EnablePartMask := False;
	try
		if(OpenDialog2.Execute = False) then Exit;
	finally
		PartMaskForm.EnablePartMask := True;
	end;

	EnterCriticalSection(Sect1);
	if(Sender = PPZZ1) then begin
		rslt := ppz_load(PChar(OpenDialog2.FileName), 0);
	end else begin
		rslt := ppz_load(PChar(OpenDialog2.FileName), 1);
	end;
	LeaveCriticalSection(Sect1);

	case rslt of
		PMDWIN_OK : 								Exit;
		ERR_OPEN_PPZ1_FILE :        ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_READ_PPZ1DATA);
		ERR_OPEN_PPZ2_FILE :        ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_READ_PPZ2DATA);
		ERR_OUT_OF_MEMORY :         ShowMessage(MSG_ERROR_OUT_OF_MEMORY);
		ERR_WRONG_PPZ1_FILE :       ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_PPZ1DATA);
		ERR_WRONG_PPZ2_FILE :       ShowMessage(OpenDialog2.FileName + MSG_ERROR_NOT_PPZ2DATA);
		WARNING_PPZ1_ALREADY_LOAD :	ShowMessage(OpenDialog2.FileName + MSG_WARNING_ALREADY_READ_PPZ1DATA);
		WARNING_PPZ2_ALREADY_LOAD :	ShowMessage(OpenDialog2.FileName + MSG_WARNING_ALREADY_READ_PPZ2DATA);
	else
		ShowMessage(MSG_ERROR_OTHER);
	end;
end;


//***************************************************************************
// PlayList 保存
//***************************************************************************
procedure TFMPMDForm.KPlayListI1Click(Sender: TObject);
begin
	if(FSaveFirstOpen2 = True) then begin
		FSaveFirstOpen2 := False;
		SaveDialog2.InitialDir := FSaveInitialDir2;
	end else begin
		SaveDialog2.InitialDir := '';
	end;

	if(SaveDialog2.Execute = True) then begin
		PlayListForm.SaveToFile(SaveDialog2.FileName);
	end;
end;


//***************************************************************************
// ランダム演奏
//***************************************************************************
procedure TFMPMDForm.RandomMenuClick(Sender: TObject);
begin
	RandomMenu.Checked := not RandomMenu.Checked;
  KR2.Checked := RandomMenu.Checked;
	PlayListForm.Random := RandomMenu.Checked;
end;


//***************************************************************************
// ループ演奏
//***************************************************************************
procedure TFMPMDForm.LoopMenuClick(Sender: TObject);
begin
	LoopMenu.Checked := not LoopMenu.Checked;
  KL2.Checked := LoopMenu.Checked;
	PlayListForm.Loop := LoopMenu.Checked;
end;


//***************************************************************************
// タスクトレイのアイコンをダブルクリックされた
//***************************************************************************
procedure TFMPMDForm.TrayIcon1DblClick(Sender: TObject);
begin
	Application.Restore;
end;


//***************************************************************************
// 最小化 or 元のサイズに戻す
//***************************************************************************
procedure TFMPMDForm.Show1Click(Sender: TObject);
begin
	if(Show1.Caption = MSG_POPUP_MINIMIZE) then begin
  	Application.Minimize;
  end else begin
  	Application.Restore;
  end;
end;


end.
