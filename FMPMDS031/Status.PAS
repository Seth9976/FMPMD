//============================================================================
//                        パラメーター表示用フォーム
//                      Copyright & Programmed by C60
//============================================================================
unit Status;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ShellAPI, PinForm, PMDWin, WinFMP, util, FMPMDPlayDefine,
	ExtCtrls, FMPLabel;

type
	TPartName = array[0..NumOfAllPart-1] of string;
	TFMP_PartName = array[0..13-1] of string;
	TFMP_PartChange = Array[0..13-1] of Integer;
	TOnkaiName = array[0..12-1] of string;

const
	BaseWindowClientRect : TRect = (			 						// ClientRect のオリジナルのサイズ
  	Left : 0; Top : 0; Right : 452; Bottom : 297
	);

	NumOfDelayBuffer = 50*2;		// ５０フレーム×２秒分の遅延バッファ
	PartName : TPartName = (	'FM1 ', 'FM2 ', 'FM3 ', 'FM4 ', 'FM5 ', 'FM6 ',
		'SSG1', 'SSG2', 'SSG3', 'ADP ', 'RHY ', 'FMx1', 'FMx2', 'FMx3', 'DMY ',
		'EFF ', 'PPZ1', 'PPZ2', 'PPZ3', 'PPZ4', 'PPZ5', 'PPZ6', 'PPZ7', 'PPZ8');

	FMP_PartName : TFMP_PartName =
		(	'FM1 ', 'FM2 ', 'FM3 ', 'FM4 ', 'FM5 ', 'FM6 ', 'SSG1', 'SSG2', 'SSG3',
		'ADP ',	'FMx1', 'FMx2', 'FMx3');

	FMP_PartChange : TFMP_PartChange =
		(0, 1, 2, 3, 4, 5, 18, 19, 20, 21, 6, 7, 8);

	OnkaiName : TOnkaiName =
		('c ', 'c+', 'd ', 'd+', 'e ', 'f ', 'f+', 'g ', 'g+', 'a ', 'a+', 'b ');

type
	//*************************************************************************
	// TStatusThread
	//*************************************************************************
	TStatusThread = class(TThread)
	private
		{ Private 宣言 }
		FSect1 : TRTLCriticalSection;       // ドライバー変更時の同期用
		FSect2 : TRTLCriticalSection;       // 全画面書き換えの同期用
		FOwner : TForm;
		FHandle : HWND;
		FPlayDriver : TPlayDriver;
		FFullDraw : Boolean;
		FFileNameDraw : Boolean;
		FPlayStop : Boolean;
		FPause : Boolean;
		FInterval : Integer;
		FDelay : Integer;
		FFileName : String;
		DisplayStatus : Boolean;						// 表示中は true
		Open_Work2 : Array[0..NumOfDelayBuffer-1] of POPEN_WORK2;	// 遅延用バッファ
		Part_Work : Array[0..NumOfDelayBuffer-1, 0..NumOfAllPart-1] of PQQ;
																															// 遅延用バッファ
		Works2 : Array[0..NumOfDelayBuffer-1] of PWORKS2;	// 遅延用バッファ(WinFMP)
		pw : Integer;               				// バッファ書き込み位置
		pr : Integer;                 			// バッファ読み出し位置
		pr2 : Integer;                 			// バッファ読み出し位置－１
	protected
		procedure Execute; override;
		procedure SetDelay(Value : Integer);
		procedure SetPlayDriver(Value : TPlayDriver);
		function GetDelay : Integer;
		procedure SetFullDraw(Value : Boolean);
		procedure SetFileNameDraw(Value : Boolean);
		procedure DisplayPMDStatus;
		procedure DisplayPMDStatusDif;
		procedure DisplayFMPStatus;
		procedure DisplayFMPStatusDif;
		procedure DisplayFMPFileName;
    procedure DisplayPMDFileName;
    function GetPPZ1(str : String) : String;
    function GetPPZ2(str : String) : String;
		function CalcScreenX(X : Integer) : Integer;
		function CalcScreenY(Y : Integer) : Integer;
		function CalcFontHeight(Height : Integer) : Integer;
	public
		{ Public 宣言 }
		constructor Create(Owner : TForm);
		destructor Destroy;	override;
		property FullDraw : Boolean read FFullDraw write SetFullDraw default True;
		property FileNameDraw : Boolean read FFileNameDraw write SetFileNameDraw default True;
		property Interval : Integer read FInterval write FInterval default 20;
		property Delay : Integer read GetDelay write SetDelay default 0;
		property PlayDriver : TPlayDriver read FPlayDriver write SetPlayDriver default DRIVER_PMD;
		property FileName : String read FFileName write FFileName;
		procedure Start;
		procedure Stop;
		procedure PlayStart;
		procedure PlayStop;
		procedure PlayPause;
	end;

	//*************************************************************************
	// TStatusForm
	//*************************************************************************
	TStatusForm = class(TForm)
		PinForm1: TPinForm;
		procedure FormHide(Sender: TObject);
		procedure FormPaint(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure FormActivate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private 宣言 }
		StatusThread : TStatusThread;
	protected
		{ Protected 宣言 }
		procedure OnPartMaskChanged(Sender : TObject);
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		procedure Driver_Change(var Msg : TMessage); message WM_DRIVERCHANDE;
		procedure Play_Start(var Msg : TMessage); message WM_PLAYSTART;
		procedure Play_Stop(var Msg : TMessage); message WM_PLAYSTOP;
		procedure Play_Pause(var Msg : TMessage); message WM_PLAYPAUSE;
		procedure SetPriority(Value : TThreadPriority);
		function GetPriority : TThreadPriority;
		procedure SetInterval(Value : Integer);
		function GetInterval : Integer;
		procedure SetDelay(Value : Integer);
		function GetDelay : Integer;
	public
		{ Public 宣言 }
		procedure Start;
		procedure Stop;
		procedure DisplayMemo(FFilename : string);
		property Priority : TThreadPriority read GetPriority write SetPriority
																															default tpNormal;
		property Interval : Integer read GetInterval write SetInterval default 20;
		property Delay : Integer read GetDelay write SetDelay default 0;
	end;


var
	StatusForm: TStatusForm;

implementation

uses Main, PartMask;

{$R *.DFM}


//***************************************************************************
// コンストラクタ
//***************************************************************************
procedure TStatusForm.FormCreate(Sender: TObject);
begin
	DragAcceptFiles(Handle, True);
	StatusThread := TStatusThread.Create(Self);
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
procedure TStatusForm.FormDestroy(Sender: TObject);
begin
	if Assigned(StatusThread) then begin
		StatusThread.Terminate;
		StatusThread.WaitFor;
		StatusThread.Free;
  end;
end;


//***************************************************************************
// フォームのアクティブ化
//***************************************************************************
procedure TStatusForm.FormActivate(Sender: TObject);
begin
	PartMaskForm.OnChanged := OnPartMaskChanged;
	FMPMDForm.ParamaterMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure TStatusForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FMPMDForm.ParamaterMenu.Checked := False;
end;


//***************************************************************************
// フォームを閉じたときの処理
//***************************************************************************
procedure TStatusForm.FormHide(Sender: TObject);
begin
	if Assigned(StatusThread) then begin
		StatusThread.Stop;
	end;
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure TStatusForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
begin
	if(FMPMDForm.Snap = True) then begin
		Msg.WindowPos^.x := (Msg.WindowPos^.x div FMPMDForm.SnapWidth) * FMPMDForm.SnapWidth;
		Msg.WindowPos^.y := (Msg.WindowPos^.y div FMPMDForm.SnapWidth) * FMPMDForm.SnapWidth;
		Msg.WindowPos^.cx := (Msg.WindowPos^.cx div FMPMDForm.SnapWidth) * FMPMDForm.SnapWidth;
		Msg.WindowPos^.cy := (Msg.WindowPos^.cy div FMPMDForm.SnapWidth) * FMPMDForm.SnapWidth;    
	end;

  inherited;
end;


//***************************************************************************
// Window への D&D
//***************************************************************************
procedure TStatusForm.DropFiles(var Msg:TWMDROPFILES);
begin
	FMPMDForm.DropFiles(Msg);
end;


//***************************************************************************
// フォーム再描画
//***************************************************************************
procedure TStatusForm.FormPaint(Sender: TObject);
begin
	if Assigned(StatusThread) then begin
		StatusThread.FullDraw := True;
	end;
end;


//***************************************************************************
// フォームサイズ変更
//***************************************************************************
procedure TStatusForm.FormResize(Sender: TObject);
begin
	StatusThread.FullDraw := True;
end;


//***************************************************************************
// ステータス表示開始
//***************************************************************************
procedure TStatusForm.Start;
begin
	if Assigned(StatusThread) then begin
		Show;
		StatusThread.FullDraw := True;
		StatusThread.Start;
	end;
end;


//***************************************************************************
// ステータス表示停止
//***************************************************************************
procedure TStatusForm.Stop;
begin
	if Assigned(StatusThread) then begin
		StatusThread.Stop;
		Hide;
	end;
end;


//***************************************************************************
// ドライバー変更
//***************************************************************************
procedure TStatusForm.Driver_Change(var Msg : TMessage);
begin
	if Assigned(StatusThread) then begin
		if(StatusThread.PlayDriver <> TPlayDriver(Msg.WParam)) then begin
			StatusThread.PlayDriver := TPlayDriver(Msg.WParam);
		end;
	end;
end;


//***************************************************************************
// 演奏開始
//***************************************************************************
procedure TStatusForm.Play_Start(var Msg : TMessage);
begin
	if Assigned(StatusThread) then begin
		StatusThread.PlayStart;
	end;
end;


//***************************************************************************
// 演奏停止
//***************************************************************************
procedure TStatusForm.Play_Stop(var Msg : TMessage);
begin
	if Assigned(StatusThread) then begin
		StatusThread.PlayStop;
	end;
end;


//***************************************************************************
// Pause
//***************************************************************************
procedure TStatusForm.Play_Pause(var Msg : TMessage);
begin
	if Assigned(StatusThread) then begin
		StatusThread.PlayPause;
	end;
end;


//***************************************************************************
// メモ表示
//***************************************************************************
procedure TStatusForm.DisplayMemo(FFileName : String);
begin
	StatusThread.FileName := FFileName;
	StatusThread.FileNameDraw := True;
end;


//***************************************************************************
// パートマスクの状態変化
//***************************************************************************
procedure TStatusForm.OnPartMaskChanged;
begin
	FormPaint(Self);
end;


//***************************************************************************
// Priority 取得
//***************************************************************************
function TStatusForm.GetPriority : TThreadPriority;
begin
	if Assigned(StatusThread) then begin
		Result := StatusThread.Priority;
	end else begin
		Result := tpNormal;
	end;
end;

//***************************************************************************
// Priority 設定
//***************************************************************************
procedure TStatusForm.Setpriority(Value : TThreadPriority);
begin
	if Assigned(StatusThread) then begin
		StatusThread.Priority := Value;
	end;
end;


//***************************************************************************
// Interval 取得
//***************************************************************************
function TStatusForm.GetInterval : Integer;
begin
	if Assigned(StatusThread) then begin
		Result := StatusThread.Interval;
	end else begin
		Result := 20;
	end;
end;

//***************************************************************************
// Interval 設定
//***************************************************************************
procedure TStatusForm.SetInterval(Value : Integer);
begin
	if Assigned(StatusThread) then begin
		StatusThread.Interval := Value;
	end;
end;


//***************************************************************************
// Delay 取得
//***************************************************************************
function TStatusForm.GetDelay : Integer;
begin
	if Assigned(StatusThread) then begin
		Result := StatusThread.Delay;
	end else begin
		Result := 0;
	end;
end;

//***************************************************************************
// Delay 設定
//***************************************************************************
procedure TStatusForm.SetDelay(Value : Integer);
begin
	if Assigned(StatusThread) then begin
		if(Value < 0) then Value := 0;
		StatusThread.Delay := Value;
	end;
end;


//***************************************************************************
// スレッドコンストラクタ
//***************************************************************************
constructor TStatusThread.Create(Owner : TForm);
var
	i, j : Integer;
begin
	FOwner := Owner;
	FHandle := Owner.Handle;
	FInterval := 20;
	FDelay := 0;
	FPlayStop := True;
	FPause := False;
	FreeOnTerminate := False;
	DisplayStatus := False;
	FFileName := '';
	pw := 0;
	pr := 0;
	pr2 := 0;

	// バッファ用メモリポインタの初期化
	for i := 0 to NumOfDelayBuffer - 1 do begin
		Open_Work2[i] := nil;
		Works2[i] := nil;

		for j := 0 to NumOfAllPart - 1 do begin
			Part_Work[i][j] := nil;
		end;
	end;

	// クリティカルセクションオブジェクトの作成
	InitializeCriticalSection(FSect1);
	InitializeCriticalSection(FSect2);

	FFullDraw := True;
	FFileNameDraw := True;
	SetPlayDriver(DRIVER_PMD);

	inherited Create(False);
	Priority := tpNormal;
end;


//***************************************************************************
// スレッドデストラクタ
//***************************************************************************
destructor TStatusThread.Destroy;
var
	i, j : Integer;
begin
	// バッファ用メモリの開放
	for i := 0 to NumOfDelayBuffer - 1 do begin
		Dispose(Open_Work2[i]);
		Dispose(Works2[i]);

		for j := 0 to NumOfAllPart - 1 do begin
			Dispose(Part_Work[i][j]);
		end;
	end;

	// クリティカルセクションオブジェクトの破棄
	DeleteCriticalSection(FSect1);
	DeleteCriticalSection(FSect2);

	inherited Destroy;
end;


//***************************************************************************
// FullDwaw の設定
//***************************************************************************
procedure TStatusThread.SetFullDraw(Value : Boolean);
begin
	EnterCriticalSection(FSect2);
	FFullDraw := Value;
  if(FFullDraw = True) then begin
  	FFileNameDraw := True;
  end;
	LeaveCriticalSection(FSect2);
end;


//***************************************************************************
// FileNameDraw の設定
//***************************************************************************
procedure TStatusThread.SetFileNameDraw(Value : Boolean);
begin
	EnterCriticalSection(FSect2);
	FFileNameDraw := Value;
	LeaveCriticalSection(FSect2);
end;


//***************************************************************************
// ドライバー変更
//***************************************************************************
procedure TStatusThread.SetPlayDriver(Value : TPlayDriver);
var
	i, j : Integer;
begin
	EnterCriticalSection(FSect1);

	// バッファ用メモリの開放
	for i := 0 to NumOfDelayBuffer - 1 do begin
		Dispose(Open_Work2[i]);
		Open_Work2[i] := nil;
		Dispose(Works2[i]);
		Works2[i] := nil;

		for j := 0 to NumOfAllPart - 1 do begin
			Dispose(Part_Work[i][j]);
			Part_Work[i][j] := nil;
		end;
	end;

	// バッファ用メモリの確保
	if(Value = DRIVER_PMD) then begin
		for i := 0 to NumOfDelayBuffer - 1 do begin
			New(Open_Work2[i]);
			ZeroMemory(Open_Work2[i], SizeOf(Open_Work2[i]^));

			for j := 0 to NumOfAllPart - 1 do begin
				New(Part_Work[i][j]);
				ZeroMemory(Part_Work[i][j], SizeOf(Part_Work[i][j]^));
			end;
		end;
	end else begin
		for i := 0 to NumOfDelayBuffer - 1 do begin
			New(Works2[i]);
			ZeroMemory(Works2[i], SizeOf(Works2[i]^));
		end;
	end;
	FPlayDriver := Value;
	LeaveCriticalSection(FSect1);

	EnterCriticalSection(FSect2);

	pw := 0;
	pr := 0;
	pr2 := 0;
	LeaveCriticalSection(FSect2);

	FFullDraw := True;
	SetDelay(FDelay);
end;


//***************************************************************************
// スレッド実行部分
//***************************************************************************
procedure TStatusThread.Execute;
var
	Time1, Time2 : Integer;
	i : Integer;
	DC : HDC;
  br, Oldbr : HBrush;
begin
	while(Terminated = False) do begin
		Time1 := GetTickCount;

    if(FFullDraw = True) then begin
		// 画面消去
			DC := GetDC(FHandle);
			br := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
			Oldbr := SelectObject(DC, br);
			Windows.FillRect(DC, RECT(0, 0, FOwner.ClientWidth, FOwner.ClientHeight), br);
			SelectObject(DC, Oldbr);
			DeleteObject(br);
			ReleaseDC(FHandle, DC);
    end;

		EnterCriticalSection(FSect1);
		if(FPlayDriver = DRIVER_PMD) then begin

			//---------------------------------------------------------------------
			// PMDWin のパラメーター表示処理
			//---------------------------------------------------------------------
			if(FPlayStop = True) then begin
				ZeroMemory(Open_Work2[pr], SizeOf(Open_Work2[pr]^));
				for i := 0 to NumOfAllPart-1 do begin
					ZeroMemory(Part_Work[pr][i], sizeof(Part_Work[pr][i]^));
				end;
			end else begin
				Open_Work2[pw]^ := POPEN_WORK2(getopenwork)^;

				for i := 0 to NumOfAllPart-1 do begin
					if(POPEN_WORK2(getopenwork)^.MusPart[i] <> nil) then begin
						Part_Work[pw][i]^ := POPEN_WORK2(getopenwork)^.MusPart[i]^;
					end else begin
						ZeroMemory(Part_Work[pw][i], sizeof(Part_Work[pw][i]^));
					end;
				end;
			end;

			if(DisplayStatus = True) then begin
				if(FFullDraw = True) then begin
					// 画面全体書き換え
					FFullDraw := False;
					FFileNameDraw := False;
		 			EnterCriticalSection(FSect2);
					DisplayPMDStatus;
          DisplayPMDFileName;
					LeaveCriticalSection(FSect2);
				end else begin
					// 部分的書き換え
					if(FPause = False) then begin
						DisplayPMDStatusDif;
					end;

          if(FFileNameDraw = True) then begin
          	// ファイル名描画
          	FFileNameDraw := False;
						EnterCriticalSection(FSect2);
						DisplayPMDFileName;
						LeaveCriticalSection(FSect2);
          end;
				end;
			end;
		end else begin
			//---------------------------------------------------------------------
			// WinFMP のパラメーター表示処理
			//---------------------------------------------------------------------
			if(FPlayStop = True) then begin
				ZeroMemory(Works2[pr], SizeOf(Works2[pr]^));
			end else begin
				Works2[pw]^ := PWORKS2(fmp_getworks)^;
			end;

			if(DisplayStatus = True) then begin
				if(FFullDraw = True) then begin
					// 画面全体書き換え
					FFullDraw := False;
					FFileNameDraw := False;
					EnterCriticalSection(FSect2);
					DisplayFMPStatus;
          DisplayFMPFileName;
					LeaveCriticalSection(FSect2);
				end else begin
					// 部分的書き換え
					if(FPause = False) then begin
						DisplayFMPStatusDif;
					end;

          if(FFileNameDraw = True) then begin
          	// ファイル名描画
          	FFileNameDraw := False;
						EnterCriticalSection(FSect2);
	          DisplayFMPFileName;
						LeaveCriticalSection(FSect2);
          end;
				end;
			end;
		end;

		LeaveCriticalSection(FSect1);

		if(FPause = False) then begin
			Inc(pw);
			if(pw = NumOfDelayBuffer) then pw := 0;
			Inc(pr);
			if(pr = NumOfDelayBuffer) then pr := 0;
			Inc(pr2);
			if(pr2 = NumOfDelayBuffer) then pr2 := 0;
		end;
		
		Time2 := GetTickCount;
		if(FInterval - (Time2 - Time1) > 0) then begin
			Sleep(FInterval - (Time2 - Time1));
		end;
	end;
end;


//***************************************************************************
// PMDWin のパラメーター表示(全画面書き換え）
//***************************************************************************
procedure TStatusThread.DisplayPMDStatus;
var
	DC : HDC;
	Font : HFont;
	OldFont : HFont;
	p1: TLogFont;
	i, j : Integer;
	onkai : Integer;
	PanStr : String;
begin
	DC := GetDC(FHandle);

	with p1 do begin
		lfHeight := CalcFontHeight(13);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));
	Windows.Textout(DC, CalcScreenX( 61), CalcScreenY(0), '@', 1);
	Windows.Textout(DC, CalcScreenX(105), CalcScreenY(0), 'v', 1);
	Windows.Textout(DC, CalcScreenX(148), CalcScreenY(0), 'p', 1);
	Windows.Textout(DC, CalcScreenX(189), CalcScreenY(0), 'n', 1);
	Windows.Textout(DC, CalcScreenX(234), CalcScreenY(0), 'd', 1);
	Windows.Textout(DC, CalcScreenX(281), CalcScreenY(0), 'l', 1);

	j := 0;
	for i := 0 to NumOfAllPart-1 do begin
		if(PartMaskForm.GetPartMask(i) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		if(i = 10) or (i = 14) or (i = 15) then continue;		// RHY,DMY, EFF は飛ばす
		Windows.Textout(DC,  CalcScreenX( 5), CalcScreenY(20+j*13), PChar(PartName[i]), 4);
		Windows.Textout(DC,  CalcScreenX(48), CalcScreenY(20+j*13), PChar(Format('@%.3d', [Part_Work[pr][i].voicenum])), 4);
		Windows.Textout(DC,  CalcScreenX(98), CalcScreenY(20+j*13), PChar(Format('%.3d', [Part_Work[pr][i].volume])), 3);
		case i of
			0..5, 9, 11..13 :		// FM, ADPCM, FM3Ex
				begin
					case(Part_Work[pr][i].fmpan and $c0)of
						$80 : PanStr := 'L ';
						$40 : PanStr := ' R';
						$c0 : PanStr := 'LR';
					else
						PanStr := '  ';
					end;
				end;

			16..23 :						// PPZ8
				begin
					case Part_Work[pr][i].fmpan of
						1..4 : PanStr := 'L ';
						5 :		 PanStr := 'LR';
						6..9 : PanStr := ' R';
					else
						PanStr := '  ';
					end;
				end;
		else
			PanStr := '  ';
		end;

		Windows.Textout(DC, CalcScreenX(144), CalcScreenY(20+j*13), PChar(PanStr), 2);

		onkai := Part_Work[pr][i].onkai;
		if(FPlayStop = True) or (onkai and $0f >= 12) then begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+j*13), PChar('  r '), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+j*13), PChar(Format('o%1d%2s', [(onkai div $10) + 1, OnkaiName[onkai mod $10]])), 4);
		end;

		if(Part_Work[pr][i].detune >= 0) then begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+j*13), PChar(Format(' %.3d', [Part_Work[pr][i].detune])), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+j*13), PChar(Format('%.3d', [Part_Work[pr][i].detune])), 4);
		end;

		if(Part_Work[pr][i].leng >= 0) then begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+j*13), PChar(Format('%.3d', [Part_Work[pr][i].leng])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+j*13), PChar(Format('%.3d', [0])), 3);
		end;

		Inc(j);
	end;
	SelectObject(DC, OldFont);
	DeleteObject(Font);

	with p1 do begin
		lfHeight := CalcFontHeight(14);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);

	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(30), PChar(Format('Count  :  %.6d',
			[Open_Work2[pr].syousetu_lng * Open_Work2[pr].syousetu + Open_Work2[pr].opncount])), 16);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(50), PChar(Format('TimerB :   %5d', [Open_Work2[pr].tempo_d])), 16);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(70), PChar(Format('Loop   :   %5d', [Open_Work2[pr].status2])), 16);

	SelectObject(DC, OldFont);
	DeleteObject(Font);
	ReleaseDC(FHandle, DC);
end;


//***************************************************************************
// PMDWin のパラメーター表示(差分）
//***************************************************************************
procedure TStatusThread.DisplayPMDStatusDif;
var
	DC : HDC;
	Font : HFont;
	OldFont : HFont;
	p1: TLogFont;
	i, j : Integer;
	onkai : Integer;
	PanStr : String;
begin
	DC := GetDC(FHandle);
	with p1 do begin
		lfHeight := CalcFontHeight(13);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));

	j := 0;
	for i := 0 to NumOfAllPart-1 do begin
		if(PartMaskForm.GetPartMask(i) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		if(i = 10) or (i = 14) or (i = 15) then continue;		// RHY,DMY, EFF は飛ばす

		if(Part_Work[pr][i].voicenum <> Part_Work[pr2][i].voicenum) then
			Windows.Textout(DC, CalcScreenX(48), CalcScreenY(20+j*13), PChar(Format('@%.3d', [Part_Work[pr][i].voicenum])), 4);

		if(Part_Work[pr][i].volume <> Part_Work[pr2][i].volume) then
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(20+j*13), PChar(Format('%.3d', [Part_Work[pr][i].volume])), 3);
			

		if(Part_Work[pr][i].fmpan <> Part_Work[pr2][i].fmpan) then begin
			case i of
		  	0..5, 9, 11..13 :		// FM, ADPCM, FM3Ex
		    	begin
		      	case(Part_Work[pr][i].fmpan and $c0)of
		        	$80 : PanStr := 'L ';
							$40 : PanStr := ' R';
							$c0 : PanStr := 'LR';
						else
							PanStr := '  ';
						end;
					end;

				16..23 :						// PPZ8
					begin
						case Part_Work[pr][i].fmpan of
		      		1..4 : PanStr := 'L ';
		      		5 :		 PanStr := 'LR';
		          6..9 : PanStr := ' R';
						else
		         	PanStr := '  ';
						end;
		      end;
			else
				PanStr := '  ';
			end;

			Windows.Textout(DC, CalcScreenX(144), CalcScreenY(20+j*13), PChar(PanStr), 2);
		end;

		if(Part_Work[pr][i].onkai <> Part_Work[pr2][i].onkai) then begin
		onkai := Part_Work[pr][i].onkai;
	    if(FPlayStop = True) or (onkai and $0f >= 12) then begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+j*13), PChar('  r '), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+j*13), PChar(Format('o%1d%2s', [(onkai div $10) + 1, OnkaiName[onkai mod $10]])), 4);
		  end;
		end;

		if(Part_Work[pr][i].detune <> Part_Work[pr2][i].detune) then begin
			if(Part_Work[pr][i].detune >= 0) then begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+j*13), PChar(Format(' %.3d', [Part_Work[pr][i].detune])), 4);
	    end else begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+j*13), PChar(Format('%.3d', [Part_Work[pr][i].detune])), 4);
		  end;
		end;

		if(Part_Work[pr][i].leng <> Part_Work[pr2][i].leng) then begin
			if(Part_Work[pr][i].leng >= 0) then begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+j*13), PChar(Format('%.3d', [Part_Work[pr][i].leng])), 3);
			end else begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+j*13), PChar(Format('%.3d', [0])), 3);
			end;
		end;

	  Inc(j);
	end;
	SelectObject(DC, OldFont);
	DeleteObject(Font);

	with p1 do begin
		lfHeight := CalcFontHeight(14);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);

	if(Open_Work2[pr].opncount <> Open_Work2[pr2].opncount) then
		Windows.Textout(DC, CalcScreenX(315), CalcScreenY(30), PChar(Format('Count  :  %.6d',
				[Open_Work2[pr].syousetu_lng * Open_Work2[pr].syousetu + Open_Work2[pr].opncount])), 16);

	if(Open_Work2[pr].tempo_d <> Open_Work2[pr2].tempo_d) then
		Windows.Textout(DC, CalcScreenX(315), CalcScreenY(50), PChar(Format('TimerB :   %5d', [Open_Work2[pr].tempo_d])), 16);

	if(Open_Work2[pr].status2 <> Open_Work2[pr2].status2) then
		Windows.Textout(DC, CalcScreenX(315), CalcScreenY(70), PChar(Format('Loop   :   %5d', [Open_Work2[pr].status2])), 16);


	SelectObject(DC, OldFont);
	DeleteObject(Font);

	ReleaseDC(FHandle, DC);
end;


//***************************************************************************
// PMDWin の FileName, PPC, PPS, PZI 表示
//***************************************************************************
procedure TStatusThread.DisplayPMDFileName;
var
	DC : HDC;
	Font, OldFont : HFont;
	p1: TLogFont;
	namebuf : Array[0..1024-1] of Char;
	name1, name2 : String;
begin
	with p1 do begin
		lfHeight := CalcFontHeight(14);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;

	DC := GetDC(FHandle);
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
  SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));

  // ファイル名
	name1 := ExtractFileName(FFileName);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(198), PChar(Format('File:%-12s', [name1])), 17);

	// PPC
	fgetmemo(@namebuf[0], nil, 0);		// PPC(曲に含まれるか確認)
	if(string(namebuf) = '') then begin
  	name1 := '';
  end else begin
		name1 := ExtractFileName(string(namebuf));
	end;
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(218), PChar(Format('PPC :%-12s', [name1])), 17);

	// PPS
	fgetmemo(@namebuf[0], nil, -1);		// PPS(曲に含まれるか確認)
	if(string(namebuf) = '') then begin
		name1 := '';
	end else begin
		name1 := ExtractFileName(string(namebuf));
	end;
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(238), PChar(Format('PPS :%-12s', [name1])), 17);

	// PPZ
	fgetmemo(@namebuf[0], nil, -2);		// PPZ(曲に含まれるか確認)
	if(GetPPZ1(string(namebuf)) = '') then begin
		name1 := '';
		name2 := '';
	end else if(GetPPZ2(string(namebuf)) = '') then begin
		name1 := string(namebuf);
		name2 := '';
	end else begin
		name1 := GetPPZ1(string(namebuf));
		name2 := GetPPZ2(string(namebuf));
	end;

	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(258), PChar(Format('PPZ1:%-12s', [name1])), 17);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(278), PChar(Format('PPZ2:%-12s', [name2])), 17);

	SelectObject(DC, OldFont);
	DeleteObject(Font);
	ReleaseDC(FHandle, DC);
end;

//***************************************************************************
// WinFMP のパラメーター表示(全画面書き換え）
//***************************************************************************
procedure TStatusThread.DisplayFMPStatus;
var
	DC : HDC;
	Font : HFont;
	OldFont : HFont;
	p1: TLogFont;
	i : Integer;
	onkai : Integer;
	PanStr : String;
begin
	DC := GetDC(FHandle);

	with p1 do begin
		lfHeight := CalcFontHeight(13);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));
	Windows.Textout(DC, CalcScreenX( 61), CalcScreenY(0), '@', 1);
	Windows.Textout(DC, CalcScreenX(105), CalcScreenY(0), 'v', 1);
	Windows.Textout(DC, CalcScreenX(148), CalcScreenY(0), 'p', 1);
	Windows.Textout(DC, CalcScreenX(189), CalcScreenY(0), 'n', 1);
	Windows.Textout(DC, CalcScreenX(234), CalcScreenY(0), 'd', 1);
	Windows.Textout(DC, CalcScreenX(281), CalcScreenY(0), 'l', 1);

	// FM
	for i := 0 to FMP_NumOfFMPart-1 do begin
		if(PartMaskForm.GetPartMask(i) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		Windows.Textout(DC,  CalcScreenX( 5), CalcScreenY(20+i*21), PChar(FMP_PartName[i]), 4);
		Windows.Textout(DC,  CalcScreenX(48), CalcScreenY(20+i*21), PChar(Format('@%.3d', [Works2[pr]._F[i].CPatS.PartStone])), 4);
		if(FPlayStop = True) then begin
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(20+i*21), PChar(Format('%.3d', [0])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(20+i*21), PChar(Format('%.3d', [127-Works2[pr]._F[i].CPatS.PartSvol])), 3);
		end;

		case(Works2[pr]._F[i].CPatS.PartSpan and $c0) of
			$80 : PanStr := 'L ';
			$40 : PanStr := ' R';
			$c0 : PanStr := 'LR';
		else
			PanStr := '  ';
		end;

		Windows.Textout(DC, CalcScreenX(144), CalcScreenY(20+i*21), PChar(PanStr), 2);

		onkai := Works2[pr]._F[i].CPatS.PartSbefore;
		if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+i*21), PChar('  r '), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+i*21), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
		end;

		if(Works2[pr]._F[i].CPatS.PartSdetune >= 0) then begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+i*21), PChar(Format(' %.3d', [Works2[pr]._F[i].CPatS.PartSdetune])), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+i*21), PChar(Format('%.3d', [Works2[pr]._F[i].CPatS.PartSdetune])), 4);
		end;

		if(Works2[pr]._F[i].CPatS.PartScnt >= 0) then begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+i*21), PChar(Format('%.3d', [Works2[pr]._F[i].CPatS.PartScnt])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+i*21), PChar(Format('%.3d', [Works2[pr]._F[i].CPatS.PartScnt])), 3);
		end;
	end;

	// SSG
	for i := 0 to FMP_NumOfSSGPart-1 do begin
		if(PartMaskForm.GetPartMask(i+6) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;
		
		Windows.Textout(DC,  CalcScreenX( 5), CalcScreenY(146+i*21), PChar(FMP_PartName[i+NumOfFMPart]), 4);
		Windows.Textout(DC,  CalcScreenX(48), CalcScreenY(146+i*21), PChar(Format('@%.3d', [Works2[pr]._S[i].CPatS.PartStone])), 4);

		if(FPlayStop = True) then begin
			Windows.Textout(DC, CalcScreenX( 98), CalcScreenY(146+i*21), PChar(Format('%.3d', [0])), 3);
			Windows.Textout(DC, CalcScreenX(144), CalcScreenY(146+i*21), PChar('  '), 2);
		end else begin
			Windows.Textout(DC, CalcScreenX( 98), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartSvol-1])), 3);
			Windows.Textout(DC, CalcScreenX(144), CalcScreenY(146+i*21), PChar('LR'), 2);
		end;

		onkai := Works2[pr]._S[i].CPatS.PartSbefore;
		if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(146+i*21), PChar('  r '), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(146+i*21), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
		end;

		if(Works2[pr]._S[i].CPatS.PartSdetune >= 0) then begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(146+i*21), PChar(Format(' %.3d', [Works2[pr]._S[i].CPatS.PartSdetune])), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartSdetune])), 4);
		end;

		if(Works2[pr]._S[i].CPatS.PartScnt >= 0) then begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartScnt])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartScnt])), 3);
		end;
	end;

	// ADPCM
	if(PartMaskForm.GetPartMask(9) = True) then begin
		SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
	end else begin
		SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
	end;

	Windows.Textout(DC,  CalcScreenX( 5), CalcScreenY(209), PChar(FMP_PartName[NumOfFMPart+NumOfSSGPart]), 4);
	Windows.Textout(DC,  CalcScreenX(48), CalcScreenY(209), PChar(Format('@%.3d', [Works2[pr]._A.CPatS.PartStone])), 4);
	Windows.Textout(DC,  CalcScreenX(98), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartSvol])), 3);

	case(Works2[pr]._A.CPatS.PartSpan and $c0) of
		$80 : PanStr := 'L ';
		$40 : PanStr := ' R';
		$c0 : PanStr := 'LR';
	else
		PanStr := '  ';
	end;

	Windows.Textout(DC, CalcScreenX(144), CalcScreenY(209), PChar(PanStr), 2);

	onkai := Works2[pr]._A.CPatS.PartSbefore;
	if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
		Windows.Textout(DC, CalcScreenX(182), CalcScreenY(209), PChar('  r '), 4);
	end else begin
		Windows.Textout(DC, CalcScreenX(182), CalcScreenY(209), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
	end;

	if(Works2[pr]._A.CPatS.PartSdetune >= 0) then begin
		Windows.Textout(DC, CalcScreenX(220), CalcScreenY(209), PChar(Format(' %.3d', [Works2[pr]._A.CPatS.PartSdetune])), 4);
	end else begin
		Windows.Textout(DC, CalcScreenX(220), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartSdetune])), 4);
	end;

	if(Works2[pr]._A.CPatS.PartScnt >= 0) then begin
		Windows.Textout(DC, CalcScreenX(274), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartScnt])), 3);
	end else begin
		Windows.Textout(DC, CalcScreenX(274), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartScnt])), 3);
	end;

	// FM3Ex
	for i := 0 to FMP_NumOfExtPart-1 do begin
		if(PartMaskForm.GetPartMask(i+11) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		Windows.Textout(DC, CalcScreenX( 5), CalcScreenY(230+i*21), PChar(FMP_PartName[i+FMP_NumOfFMPart+FMP_NumOfSSGPart+FMP_NumOfADPCMPart]), 4);
		Windows.Textout(DC, CalcScreenX(48), CalcScreenY(230+i*21), PChar(Format('@%.3d', [Works2[pr]._X[i].CPatS.PartStone])), 4);
		if(FPlayStop = True) then begin
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(230+i*21), PChar(Format('%.3d', [0])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(230+i*21), PChar(Format('%.3d', [127-Works2[pr]._X[i].CPatS.PartSvol])), 3);
		end;

		case(Works2[pr]._X[i].CPatS.PartSpan and $c0) of
			$80 : PanStr := 'L ';
			$40 : PanStr := ' R';
			$c0 : PanStr := 'LR';
		else
			PanStr := '  ';
		end;

		Windows.Textout(DC, CalcScreenX(144), CalcScreenY(230+i*21), PChar(PanStr), 2);

		onkai := Works2[pr]._X[i].CPatS.PartSbefore;
		if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(230+i*21), PChar('  r '), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(230+i*21), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
		end;

		if(Works2[pr]._X[i].CPatS.PartSdetune >= 0) then begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(230+i*21), PChar(Format(' %.3d', [Works2[pr]._X[i].CPatS.PartSdetune])), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(230+i*21), PChar(Format('%.3d', [Works2[pr]._X[i].CPatS.PartSdetune])), 4);
		end;

		if(Works2[pr]._X[i].CPatS.PartScnt >= 0) then begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(230+i*21), PChar(Format('%.3d', [Works2[pr]._X[i].CPatS.PartScnt])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(230+i*21), PChar(Format('%.3d', [Works2[pr]._X[i].CPatS.PartScnt])), 3);
		end;
	end;

	// count, tempo, loop
	SelectObject(DC, OldFont);
	DeleteObject(Font);

	with p1 do begin
		lfHeight := CalcFontHeight(14);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);

	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(30), PChar(Format('Count  :  %.6d',
			[Works2[pr].MusicClockcnt * Works2[pr].ExtBuff.FmpSsho +
			(Works2[pr].MusicClockcnt - Works2[pr].ClockCnt)])), 16);

	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(50), PChar(Format('TimerB :   %5d', [Works2[pr].ExtBuff.FmpStempo])), 16);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(70), PChar(Format('Loop   :   %5d', [Works2[pr].ExtBuff.FmpSloop_c])), 16);

	SelectObject(DC, OldFont);
	DeleteObject(Font);
	ReleaseDC(FHandle, DC);
end;


//***************************************************************************
// WinFMP のパラメーター表示(差分）
//***************************************************************************
procedure TStatusThread.DisplayFMPStatusDif;
var
	DC : HDC;
	Font : HFont;
	OldFont : HFont;
	p1: TLogFont;
	i : Integer;
	onkai : Integer;
	PanStr : String;
begin
	DC := GetDC(FHandle);
	with p1 do begin
		lfHeight := CalcFontHeight(13);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));

	// FM
	for i := 0 to FMP_NumOfFMPart-1 do begin
		if(PartMaskForm.GetPartMask(i) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		if(Works2[pr]._F[i].CPatS.PartStone <> Works2[pr2]._F[i].CPatS.PartStone) then
			Windows.Textout(DC, CalcScreenX(48), CalcScreenY(20+i*21), PChar(Format('@%.3d', [Works2[pr]._F[i].CPatS.PartStone])), 4);

		if(Works2[pr]._F[i].CPatS.PartSvol <> Works2[pr2]._F[i].CPatS.PartSvol) then
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(20+i*21), PChar(Format('%.3d', [127-Works2[pr]._F[i].CPatS.PartSvol])), 3);

		if((Works2[pr]._F[i].CPatS.PartSpan and $c0) <> (Works2[pr2]._F[i].CPatS.PartSpan and $c0)) then begin
			case(Works2[pr]._F[i].CPatS.PartSpan and $c0) of
				$80 : PanStr := 'L ';
				$40 : PanStr := ' R';
				$c0 : PanStr := 'LR';
			else
				PanStr := '  ';
			end;
			Windows.Textout(DC, CalcScreenX(144), CalcScreenY(20+i*21), PChar(PanStr), 2);
		end;

		if(Works2[pr]._F[i].CPatS.PartSbefore <> Works2[pr2]._F[i].CPatS.PartSbefore) then begin
			onkai := Works2[pr]._F[i].CPatS.PartSbefore;
			if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+i*21), PChar('  r '), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(20+i*21), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
			end;
		end;

		if(Works2[pr]._F[i].CPatS.PartSdetune <> Works2[pr2]._F[i].CPatS.PartSdetune) then begin
			if(Works2[pr]._F[i].CPatS.PartSdetune >= 0) then begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+i*21), PChar(Format(' %.3d', [Works2[pr]._F[i].CPatS.PartSdetune])), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(20+i*21), PChar(Format('%.3d', [Works2[pr]._F[i].CPatS.PartSdetune])), 4);
			end;
		end;

		if(Works2[pr]._F[i].CPatS.PartScnt <> Works2[pr2]._F[i].CPatS.PartScnt) then begin
			if(Works2[pr]._F[i].CPatS.PartScnt >= 0) then begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+i*21), PChar(Format('%.3d', [Works2[pr]._F[i].CPatS.PartScnt])), 3);
			end else begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(20+i*21), PChar(Format('%.3d', [Works2[pr]._F[i].CPatS.PartScnt])), 3);
			end;
		end;
	end;

	// SSG
	for i := 0 to FMP_NumOfSSGPart-1 do begin
		if(PartMaskForm.GetPartMask(i+6) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		if(Works2[pr]._S[i].CPatS.PartStone <> Works2[pr2]._S[i].CPatS.PartStone) then
			Windows.Textout(DC, CalcScreenX(48), CalcScreenY(146+i*21), PChar(Format('@%.3d', [Works2[pr]._S[i].CPatS.PartStone])), 4);

		if(Works2[pr]._S[i].CPatS.PartSvol <> Works2[pr2]._S[i].CPatS.PartSvol) then
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartSvol-1])), 3);

		if(Works2[pr]._S[i].CPatS.PartSbefore <> Works2[pr2]._S[i].CPatS.PartSbefore) then begin
			onkai := Works2[pr]._S[i].CPatS.PartSbefore;
			if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(146+i*21), PChar('  r '), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(146+i*21), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
			end;
		end;

		if(Works2[pr]._S[i].CPatS.PartSdetune <> Works2[pr2]._S[i].CPatS.PartSdetune) then begin
			if(Works2[pr]._S[i].CPatS.PartSdetune >= 0) then begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(146+i*21), PChar(Format(' %.3d', [Works2[pr]._S[i].CPatS.PartSdetune])), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartSdetune])), 4);
			end;
		end;

		if(Works2[pr]._S[i].CPatS.PartScnt <> Works2[pr2]._S[i].CPatS.PartScnt) then begin
			if(Works2[pr]._S[i].CPatS.PartScnt >= 0) then begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartScnt])), 3);
			end else begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(146+i*21), PChar(Format('%.3d', [Works2[pr]._S[i].CPatS.PartScnt])), 3);
			end;
		end;
	end;

	// ADPCM
	if(PartMaskForm.GetPartMask(9) = True) then begin
		SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
	end else begin
		SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
	end;

	if(Works2[pr]._A.CPatS.PartStone <> Works2[pr2]._A.CPatS.PartStone) then
		Windows.Textout(DC, CalcScreenX(48), CalcScreenY(209), PChar(Format('@%.3d', [Works2[pr]._A.CPatS.PartStone])), 4);

	if(Works2[pr]._A.CPatS.PartSvol <> Works2[pr2]._A.CPatS.PartSvol) then
		Windows.Textout(DC, CalcScreenX(98), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartSvol])), 3);

	if((Works2[pr]._A.CPatS.PartSpan and $c0) <> (Works2[pr2]._A.CPatS.PartSpan and $c0)) then begin
		case(Works2[pr]._A.CPatS.PartSpan and $c0) of
			$80 : PanStr := 'L ';
			$40 : PanStr := ' R';
			$c0 : PanStr := 'LR';
		else
			PanStr := '  ';
		end;
		Windows.Textout(DC, CalcScreenX(144), CalcScreenY(209), PChar(PanStr), 2);
	end;

	if(Works2[pr]._A.CPatS.PartSbefore <> Works2[pr2]._A.CPatS.PartSbefore) then begin
		onkai := Works2[pr]._A.CPatS.PartSbefore;
		if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(209), PChar('  r '), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(182), CalcScreenY(209), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
		end;
	end;

	if(Works2[pr]._A.CPatS.PartSdetune <> Works2[pr2]._A.CPatS.PartSdetune) then begin
		if(Works2[pr]._A.CPatS.PartSdetune >= 0) then begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(209), PChar(Format(' %.3d', [Works2[pr]._A.CPatS.PartSdetune])), 4);
		end else begin
			Windows.Textout(DC, CalcScreenX(220), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartSdetune])), 4);
		end;
	end;

	if(Works2[pr]._A.CPatS.PartScnt <> Works2[pr2]._A.CPatS.PartScnt) then begin
		if(Works2[pr]._A.CPatS.PartScnt >= 0) then begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartScnt])), 3);
		end else begin
			Windows.Textout(DC, CalcScreenX(274), CalcScreenY(209), PChar(Format('%.3d', [Works2[pr]._A.CPatS.PartScnt])), 3);
		end;
	end;

	// FM3Ex
	for i := 0 to FMP_NumOfExtPart-1 do begin
		if(PartMaskForm.GetPartMask(i+11) = True) then begin
			SetTextColor(DC, GetSysColor(COLOR_GRAYTEXT));
		end else begin
			SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
		end;

		if(Works2[pr]._X[i].CPatS.PartStone <> Works2[pr2]._X[i].CPatS.PartStone) then
			Windows.Textout(DC, CalcScreenX(48), CalcScreenY(230+i*21), PChar(Format('@%.3d', [Works2[pr]._X[i].CPatS.PartStone])), 4);

		if(Works2[pr]._X[i].CPatS.PartSvol <> Works2[pr2]._X[i].CPatS.PartSvol) then
			Windows.Textout(DC, CalcScreenX(98), CalcScreenY(230+i*21), PChar(Format('%.3d', [127-Works2[pr]._X[i].CPatS.PartSvol])), 3);

		if((Works2[pr]._X[i].CPatS.PartSpan and $c0) <> (Works2[pr2]._X[i].CPatS.PartSpan and $c0)) then begin
			case(Works2[pr]._X[i].CPatS.PartSpan and $c0) of
				$80 : PanStr := 'L ';
				$40 : PanStr := ' R';
				$c0 : PanStr := 'LR';
			else
				PanStr := '  ';
			end;
			Windows.Textout(DC,CalcScreenX(144), CalcScreenY(230+i*21), PChar(PanStr), 2);
		end;

		if(Works2[pr]._X[i].CPatS.PartSbefore <> Works2[pr2]._X[i].CPatS.PartSbefore) then begin
			onkai := Works2[pr]._X[i].CPatS.PartSbefore;
			if(FPlayStop = True) or (onkai = $61) or (onkai < 0) then begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(230+i*21), PChar('  r '), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(182), CalcScreenY(230+i*21), PChar(Format('o%1d%2s', [(onkai div 12) + 1, OnkaiName[onkai mod 12]])), 4);
			end;
		end;

		if(Works2[pr]._X[i].CPatS.PartSdetune <> Works2[pr2]._X[i].CPatS.PartSdetune) then begin
			if(Works2[pr]._X[i].CPatS.PartSdetune >= 0) then begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(230+i*21), PChar(Format(' %.3d', [Works2[pr]._X[i].CPatS.PartSdetune])), 4);
			end else begin
				Windows.Textout(DC, CalcScreenX(220), CalcScreenY(230+i*21), PChar(Format('%.3d', [Works2[pr]._X[i].CPatS.PartSdetune])), 4);
			end;
		end;

		if(Works2[pr]._X[i].CPatS.PartScnt <> Works2[pr2]._X[i].CPatS.PartScnt) then begin
			if(Works2[pr]._X[i].CPatS.PartScnt >= 0) then begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(230+i*21), PChar(Format('%.3d', [Works2[pr]._X[i].CPatS.PartScnt])), 3);
			end else begin
				Windows.Textout(DC, CalcScreenX(274), CalcScreenY(230+i*21), PChar(Format('%.3d', [Works2[pr]._X[i].CPatS.PartScnt])), 3);
			end;
		end;
	end;
	SelectObject(DC, OldFont);
	DeleteObject(Font);

	// count, tempo, loop
	with p1 do begin
		lfHeight := CalcFontHeight(14);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);

	if(Works2[pr].MusicClockcnt * Works2[pr].ExtBuff.FmpSsho + (Works2[pr].MusicClockcnt - Works2[pr].ClockCnt)
		<> Works2[pr2].MusicClockcnt * Works2[pr2].ExtBuff.FmpSsho + (Works2[pr2].MusicClockcnt - Works2[pr2].ClockCnt)) then
		Windows.Textout(DC, CalcScreenX(315), CalcScreenY(30), PChar(Format('Count  :  %.6d',
				[Works2[pr].MusicClockcnt * Works2[pr].ExtBuff.FmpSsho +
				(Works2[pr].MusicClockcnt - Works2[pr].ClockCnt)])), 16);

	if(Works2[pr].ExtBuff.FmpStempo <> Works2[pr2].ExtBuff.FmpStempo) then
		Windows.Textout(DC, CalcScreenX(315), CalcScreenY(50), PChar(Format('TimerB :   %5d', [Works2[pr].ExtBuff.FmpStempo])), 16);

	if(Works2[pr].ExtBuff.FmpSloop_c <> Works2[pr2].ExtBuff.FmpSloop_c) then
		Windows.Textout(DC, CalcScreenX(315), CalcScreenY(70), PChar(Format('Loop   :   %5d', [Works2[pr].ExtBuff.FmpSloop_c])), 16);

	SelectObject(DC, OldFont);
	DeleteObject(Font);
	ReleaseDC(FHandle, DC);
end;


//***************************************************************************
// WinFMP の FileName, PVI, PZI 表示
//***************************************************************************
procedure TStatusThread.DisplayFMPFileName;
var
	DC : HDC;
	Font, OldFont : HFont;
	p1: TLogFont;
	namebuf : Array[0..1024-1] of Char;
	name1 : String;
begin
	with p1 do begin
		lfHeight := CalcFontHeight(14);
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := SHIFTJIS_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ ゴシック';
	end;

	DC := GetDC(FHandle);
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
  SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));

	// ファイル名
	name1 := ExtractFileName(FFileName);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(198), PChar(Format('File:%-12s', [name1])), 17);

	// PVI
	fmp_fgetdefinedpcmfilename(@namebuf[0], nil);			// PVI(曲に含まれるか確認）
	if(string(namebuf) = '') then begin
		name1 := '';
	end else begin
		name1 := ExtractFileName(string(namebuf));
	end;
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(218), PChar(Format('PVI :%-12s', [name1])), 17);

  // PPZ
  fmp_fgetdefinedppzfilename(@namebuf[0], nil, 0);	// PPZ(曲に含まれるか確認）
	if(string(namebuf) = '') then begin
		name1 := '';
	end else begin
		name1 := ExtractFileName(string(namebuf));
	end;
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(238), PChar(Format('PPZ :%-12s', [name1])), 17);

  Windows.Textout(DC, CalcScreenX(315), CalcScreenY(258), PChar(Format('%-17s', [''])), 17);
	Windows.Textout(DC, CalcScreenX(315), CalcScreenY(278), PChar(Format('%-17s', [''])), 17);

	SelectObject(DC, OldFont);
	DeleteObject(Font);
	ReleaseDC(FHandle, DC);
end;


//***************************************************************************
// 表示開始
//***************************************************************************
procedure TStatusThread.Start;
begin
	FullDraw := True;
	DisplayStatus := True;
end;


//***************************************************************************
// 表示停止
//***************************************************************************
procedure TStatusThread.Stop;
begin
	DisplayStatus := False;
	FPause := False;
end;


//***************************************************************************
// 演奏開始
//***************************************************************************
procedure TStatusThread.PlayStart;
var
	i, j : Integer;
begin
	EnterCriticalSection(FSect1);

	// バッファ用メモリのクリア
	if(FPlayDriver = DRIVER_PMD) then begin
		for i := 0 to NumOfDelayBuffer - 1 do begin
			ZeroMemory(Open_Work2[i], SizeOf(Open_Work2[i]^));

			for j := 0 to NumOfAllPart - 1 do begin
				ZeroMemory(Part_Work[i][j], SizeOf(Part_Work[i][j]^));
			end;
		end;
	end else begin
		for i := 0 to NumOfDelayBuffer - 1 do begin
			ZeroMemory(Works2[i], SizeOf(Works2[i]^));
		end;
	end;

	LeaveCriticalSection(FSect1);

	FPlayStop := False;
	FullDraw := True;
end;


//***************************************************************************
// 演奏停止
//***************************************************************************
procedure TStatusThread.PlayStop;
begin
	FPlayStop := True;
	FullDraw := True;
  FPause := False;
end;


//***************************************************************************
// Pause
//***************************************************************************
procedure TStatusThread.PlayPause;
begin
	FPause := not FPause;
end;


//***************************************************************************
// Delay 取得
//***************************************************************************
function TStatusThread.GetDelay : Integer;
begin
	Result := FDelay;
end;

//***************************************************************************
// Delay 設定
//***************************************************************************
procedure TStatusThread.SetDelay(Value : Integer);
begin
	pr := pw - Value div FInterval;
	while(pr < 0) do begin
		Inc(pr, NumOfDelayBuffer);
	end;
	pr2 := pr - 1;
	if(pr2 < 0) then pr2 := NumOfDelayBuffer-1;


	FDelay := Value;
end;


//***************************************************************************
// メモ文字列から PPZ1 を取得
//***************************************************************************
function TStatusThread.GetPPZ1(str : String) : String;
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
function TStatusThread.GetPPZ2(str : String) : String;
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
// フォームサイズが変更された際の描画位置（ｘ座標）を計算する
//***************************************************************************
function TStatusThread.CalcScreenX(X : Integer) : Integer;
begin
	Result := X * FOwner.ClientWidth div BaseWindowClientRect.Right;
end;


//***************************************************************************
// フォームサイズが変更された際の描画位置（ｙ座標）を計算する
//***************************************************************************
function TStatusThread.CalcScreenY(Y : Integer) : Integer;
begin
	Result := Y * FOwner.ClientHeight div BaseWindowClientRect.Bottom;
end;


//***************************************************************************
// フォームサイズが変更された際のフォントの Height を計算する
//***************************************************************************
function TStatusThread.CalcFontHeight(Height : Integer) : Integer;
var
	Height1, Height2 : Integer;
begin
	Height1 := Height * FOwner.ClientWidth div BaseWindowClientRect.Right;
	Height2 := Height * FOwner.ClientHeight div BaseWindowClientRect.Bottom;
	if(Height1 < Height2) then begin
  	Result := Height1;
  end else begin
  	Result := Height2;
  end;
end;


end.

