//============================================================================
//                  カラオケ用コマンドライン表示用フォーム
//                      Copyright & Programmed by C60
//============================================================================
unit Prompt;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Util, ExtCtrls, ShellAPI, PinForm, DecodeESC, FMPMDPlayDefine,
	WinFMP, PMDWin;

// debug モードの時に有効にする(不正なエスケープシーケンスで例外を生成する)
//{$DEFINE DEBUG}

type
	TBlinkArray = Array[0..1] of Integer;

const
	NumOfDelayBuffer = 50*2;				// ５０フレーム×２秒分の遅延バッファ
	STR_MSGOTHIC = 'ＭＳ ゴシック';
  STR_98GRAPHIC = '98Graphics';
	STR_FMPGAIJI = 'FMP外字';				// フォント名
	EdgeWidth = 3;									// 画面のふちの幅（ドット数）
	ORG_SCREEN_WIDTH  = 640;				// PC-98x1 の横総ドット数
	ORG_SCREEN_HEIGHT = 400;        // PC-98x1 の縦総ドット数
  BlinkTime : TBlinkArray = (1500, 500);			// 点滅／消灯時間(msec 単位)

	WM_PROMPT_MUSICCHANGE				= WM_USER + $100;			// 曲変更
  		// (wParam = TPlayDriver(FMP or PMD), lParam = 曲名のポインタ(呼び出し先で開放)
	WM_PROMPT_PLAYSTART					= WM_USER + $101;			// 演奏開始
  WM_PROMPT_PLAYSTOP					= WM_USER + $102;			// 演奏停止
  WM_PROMPT_PLAYPAUSE					= WM_USER + $103;			// Pause
  WM_PROMPT_POSITIONMOVESTART	= WM_USER + $104;			// 演奏位置移動開始
	WM_PROMPT_POSITIONMOVEEND		= WM_USER + $105;			// 演奏位置移動終了


type
	TPromptForm = class;
	PWord = ^Word;

	//**************************************************************************
	// TPromptThread クラス
	// 曲に同期して描画コマンド(描画文字列、全画面クリア、全画面描画)を供給する
	//**************************************************************************
	TPromptThread = class(TThread)
	private
		{ Private 宣言 }
		FOwner : TPromptForm;
		FPlayDriver : TPlayDriver;
		FInterval : Integer;
		FDelay : Integer;
		FMusData : Array[0..FMP_MUSDATASIZE + 32 -1] of Byte;
		pKaraoke : PChar;
		DummyChar : Char;
		SyncScntBuf : Array[0..NumOfDelayBuffer-1] of Integer;	// 遅延用バッファ(WinFMP)
		FPMDWinDraw : Boolean;																	// PMDWin 描画フラグ
		DisplayPrompt : Boolean;							// 描画しても良い時は True
		FLastSyncScnt : Integer;
		FDrawStr : String;
		pw : Integer;               					// バッファ書き込み位置
		pr : Integer;                 				// バッファ読み出し位置
	protected
		{ Protected 宣言 }
		procedure Execute; override;
		procedure SetInterval(Value : Integer);
		procedure SetDelay(Value : Integer);
		procedure InitDisplay;
		procedure DrawDisplay;
		procedure FullDraw;
		procedure MusicChange(Filename : string; PlayDriver : TPlayDriver);
		procedure PlayStart;
		procedure PlayStop;
		procedure PlayPause;
		procedure PositionMoveStart;
		procedure PositionMoveEnd;
		procedure DrawFMPPrompt;
		procedure DrawPMDPrompt;
	public
		{ Public 宣言 }
		constructor Create(Owner : TPromptForm);
		destructor Destroy;	override;
		property Interval : Integer read FInterval write SetInterval default 50;
		property Delay : Integer read FDelay write SetDelay default 0;
end;

	//**************************************************************************
	// TPromptBlinkThread クラス
	// 画面の点滅を制御する
	//**************************************************************************
	TPromptBlinkThread = class(TThread)
	private
		{ Private 宣言 }
		FOwner : TPromptForm;
		FInterval : Integer;
		RemainTime : Integer;				// 点滅／消滅切り替えの残り時間(msec)
	protected
		{ Protected 宣言 }
		procedure Execute; override;
		procedure SetInterval(Value : Integer);
		procedure BlinkDraw;
	public
		{ Public 宣言 }
		constructor Create(Owner : TPromptForm);
		property Interval : Integer read FInterval write SetInterval default 50;
  end;


	//**************************************************************************
	// TPromptForm クラス
	//**************************************************************************
	TPromptForm = class(TForm)
		PinForm1: TPinForm;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private 宣言 }
		PromptThread : TPromptThread;
    PromptBlinkThread : TPromptBlinkThread;
		DecodeESCSequence : TDecodeESCSequence;
		TempBitmap : TBitmap;						// 裏描画用Bitmap(２バイト半角で使用)
		FPositionMove : Boolean;				// 描画停止(再生位置移動中)なら True(サブスレッドで制御)
		FBlinkOn : Boolean;							// True なら点滅で描画、False なら点滅で描画せず
	protected
		{ Protected 宣言 }
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		procedure SetPriority(Value : TThreadPriority);
		function GetPriority : TThreadPriority;
		procedure SetInterval(Value : Integer);
		function GetInterval : Integer;
		procedure SetDelay(Value : Integer);
		function GetDelay : Integer;
		procedure ScroolDisplay(Rect : TRect; ScroolLine : Integer);
		procedure InsertDisplay(Rect : TRect; ScroolLine : Integer);
		procedure WriteDisplay(DecodeESCCommand : TDecodeESCCommand);
		function CalcScreenX(CharX : Integer) : Integer;
		function CalcScreenY(CharY : Integer) : Integer;
		function CalcBitmapX(CharX : Integer) : Integer;
		function CalcBitmapY(CharY : Integer) : Integer;
		function CalcFontHeight : Integer;
		function CalcLineWidth : Integer;
	public
		{ Public 宣言 }
		procedure InitDisplay;
		procedure ClearAllDisplay;
		procedure ClearDisplay(Rect : TRect);
		procedure DrawDisplay(DrawStr : string);
		procedure FullDraw;
		procedure BlinkDraw;
		procedure Play_Start(var Msg : TMessage); message WM_PLAYSTART;
		procedure Play_Stop(var Msg : TMessage); message WM_PLAYSTOP;
		procedure Play_Pause(var Msg : TMessage); message WM_PLAYPAUSE;
		procedure PositionMove_Start(var Msg : TMessage); message WM_POSITIONMOVE_START;
		procedure PositionMove_End(var Msg : TMessage); message WM_POSITIONMOVE_END;
		procedure MusicChange(Filename : string; PlayDriver : TPlayDriver);
		property PositionMove : Boolean read FPositionMove write FPositionMove;
		property BlinkOn : Boolean read FBlinkOn write FBlinkOn;
		property Priority : TThreadPriority read GetPriority write SetPriority
																															default tpNormal;
		property Interval : Integer read GetInterval write SetInterval default 50;
		property Delay : Integer read GetDelay write SetDelay default 0;
	end;

var
	PromptForm: TPromptForm;

implementation

uses Main;


{$R *.DFM}


//###########################################################################
//###########################################################################
// TPromptForm クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// コンストラクタ
//***************************************************************************
procedure TPromptForm.FormCreate(Sender: TObject);
begin
	DragAcceptFiles(Handle, True);
	TempBitmap := TBitmap.Create;

  FPositionMove := False;
  FBlinkOn := True;
	DecodeESCSequence := TDecodeESCSequence.Create;
	PromptThread := TPromptThread.Create(Self);
	PromptBlinkThread := TPromptBlinkThread.Create(Self);
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
procedure TPromptForm.FormDestroy(Sender: TObject);
begin
	TempBitmap.Free;
	PromptThread.Terminate;
	PromptBlinkThread.Terminate;
	PromptThread.WaitFor;
	PromptBlinkThread.WaitFor;
	PromptThread.Free;
	PromptBlinkThread.Free;
	DecodeESCSequence.Free;
end;


//***************************************************************************
// フォーム再描画
//***************************************************************************
procedure TPromptForm.FormPaint(Sender: TObject);
begin
	FullDraw;
end;


//***************************************************************************
// フォームのサイズ変更
//***************************************************************************
procedure TPromptForm.FormResize(Sender: TObject);
begin
	FullDraw;
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure TPromptForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
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
procedure TPromptForm.DropFiles(var Msg:TWMDROPFILES);
begin
	FMPMDForm.DropFiles(Msg);
end;


//***************************************************************************
// フォームを開いたとき
//***************************************************************************
procedure TPromptForm.FormActivate(Sender: TObject);
begin
	FMPMDForm.ConsoleMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure TPromptForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FMPMDForm.ConsoleMenu.Checked := False;
end;


//***************************************************************************
// プロンプト表示開始
//***************************************************************************
procedure TPromptForm.Play_Start;
begin
	if Assigned(PromptThread) then begin
		PostThreadMessage(PromptThread.ThreadID, WM_PROMPT_PLAYSTART, 0, 0);
	end;
end;


//***************************************************************************
// プロンプト表示停止
//***************************************************************************
procedure TPromptForm.Play_Stop;
begin
	if Assigned(PromptThread) then begin
		PostThreadMessage(PromptThread.ThreadID, WM_PROMPT_PLAYSTOP, 0, 0);
	end;
end;


//***************************************************************************
// プロンプト表示 Pause
//***************************************************************************
procedure TPromptForm.Play_Pause;
begin
	if Assigned(PromptThread) then begin
		PostThreadMessage(PromptThread.ThreadID, WM_PROMPT_PLAYPAUSE, 0, 0);
	end;
end;


//***************************************************************************
// 再生位置変更処理開始
//***************************************************************************
procedure TPromptForm.PositionMove_Start;
begin
	if Assigned(PromptThread) then begin
		PostThreadMessage(PromptThread.ThreadID, WM_PROMPT_POSITIONMOVESTART, 0, 0);
	end;
end;


//***************************************************************************
// 再生位置変更処理終了
//***************************************************************************
procedure TPromptForm.PositionMove_End;
begin
	if Assigned(PromptThread) then begin
		PostThreadMessage(PromptThread.ThreadID, WM_PROMPT_POSITIONMOVEEND, 0, 0);
	end;
end;


//***************************************************************************
// 曲変更
//***************************************************************************
procedure TPromptForm.MusicChange(Filename : string; PlayDriver : TPlayDriver);
var
	pStr : PChar;
begin
	pStr := StrNew(PChar(FileName));
	PostThreadMessage(PromptThread.ThreadID,
  		WM_PROMPT_MUSICCHANGE, WPARAM(PlayDriver), LPARAM(pStr));
end;


//***************************************************************************
// Priority 取得
//***************************************************************************
function TPromptForm.GetPriority : TThreadPriority;
begin
	if Assigned(PromptThread) then begin
		Result := PromptThread.Priority;
	end else begin
		Result := tpNormal;
	end;
end;

//***************************************************************************
// Priority 設定
//***************************************************************************
procedure TPromptForm.Setpriority(Value : TThreadPriority);
begin
	if Assigned(PromptThread) then begin
		PromptThread.Priority := Value;
	end;
end;


//***************************************************************************
// Interval 取得
//***************************************************************************
function TPromptForm.GetInterval : Integer;
begin
	if Assigned(PromptThread) then begin
		Result := PromptThread.Interval;
	end else begin
		Result := 50;
	end;
end;

//***************************************************************************
// Interval 設定
//***************************************************************************
procedure TPromptForm.SetInterval(Value : Integer);
begin
	if Assigned(PromptThread) then begin
		PromptThread.Interval := Value;
	end;
end;


//***************************************************************************
// Delay 取得
//***************************************************************************
function TPromptForm.GetDelay : Integer;
begin
	if Assigned(PromptThread) then begin
		Result := PromptThread.Delay;
	end else begin
		Result := 0;
	end;
end;

//***************************************************************************
// Delay 設定
//***************************************************************************
procedure TPromptForm.SetDelay(Value : Integer);
begin
	if Assigned(PromptThread) then begin
		PromptThread.Delay := Value;
	end;

end;


//***************************************************************************
// 画面初期化
//***************************************************************************
procedure TPromptForm.InitDisplay;
begin
	DecodeESCSequence.Init;
	ClearAllDisplay;
end;


//***************************************************************************
// 全画面消去
//***************************************************************************
procedure TPromptForm.ClearAllDisplay;
var
	DestRect : TRect;
begin
	DestRect.Left   := 0;
	DestRect.Top    := 0;
	DestRect.Right  := ClientWidth;
	DestRect.Bottom := ClientHeight;
	Canvas.Brush.Color := clBlack;
	Canvas.Brush.Style := bsSolid;
	Canvas.FillRect(DestRect);
end;


//***************************************************************************
// 全画面再描画
//***************************************************************************
procedure TPromptForm.FullDraw;
var
	x, y : Integer;
	DecodeESCCommand : TDecodeESCCommand;
	TempChar : Array[0..2] of Char;
begin
	if(FPositionMove = True) then Exit;

	ClearAllDisplay;

	DecodeESCCommand.Command := DECODEESC_WRITE;
	DecodeESCCommand.ScroolLine := 0;
	TempChar[2] := #0;

	for y := 0 to SCREEN_HEIGHT - 1 do begin
		DecodeESCCommand.Rect.Top := y;
		DecodeESCCommand.Rect.Bottom := y;

		// x を操作するので while ループにする
		x := 0;
		while(x < SCREEN_WIDTH) do begin
			case DecodeESCSequence.VRAM[x, y].Attribute.LetterCode of
			// ASCII
			CHAR_ASCII :
				begin
					// 空白以外だったら描画する
					if not(DecodeESCSequence.VRAM[x, y].Letter in [$0, $20]) then begin
						DecodeESCCommand.Rect.Left  := x;
						DecodeESCCommand.Rect.Right := x;
						DecodeESCCommand.Text := Chr(DecodeESCSequence.VRAM[x, y].Letter);
						DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
						WriteDisplay(DecodeESCCommand);
					end;
					Inc(x);
				end;

			CHAR_GRAPHIC :
				begin
					// 空白以外だったら描画する
					if not(DecodeESCSequence.VRAM[x, y].Letter in [$0, $20]) then begin
						DecodeESCCommand.Rect.Left  := x;
						DecodeESCCommand.Rect.Right := x;
						DecodeESCCommand.Text := Chr(DecodeESCSequence.VRAM[x, y].Letter);
						DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
						WriteDisplay(DecodeESCCommand);
					end;
					Inc(x);
				end;

			// SJIS １文字目
			CHAR_SJIS1 :
				begin
{$IFDEF DEBUG}
					if(x + 1 >= SCREEN_WIDTH) then begin
						raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
					end else if(DecodeESCSequence.VRAM[x+1, y].Attribute.LetterCode <> CHAR_SJIS2) then begin
						raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
					end;
{$ENDIF}
					// 空白以外だったら描画する
					if(DecodeESCSequence.VRAM[x, y].Letter <> $81) or
							(DecodeESCSequence.VRAM[x+1, y].Letter <> $40) then begin
						DecodeESCCommand.Rect.Left  := x;
						DecodeESCCommand.Rect.Right := x + 1;
						TempChar[0] := Char(DecodeESCSequence.VRAM[x  , y].Letter);
						TempChar[1] := Char(DecodeESCSequence.VRAM[x+1, y].Letter);
						DecodeESCCommand.Text := String(TempChar);
						DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
						WriteDisplay(DecodeESCCommand);
					end;
					Inc(x, 2);
				end;

			// ２バイト半角
			CHAR_ZEN2 :
				begin
					DecodeESCCommand.Rect.Left  := x;
					DecodeESCCommand.Rect.Right := x;
					TempChar[0] := Char(DecodeESCSequence.VRAM[x, y].Letter shr 8);
					TempChar[1] := Char(DecodeESCSequence.VRAM[x, y].Letter and $ff);
					DecodeESCCommand.Text := String(TempChar);
					DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
					WriteDisplay(DecodeESCCommand);
					Inc(x);
				end;
			else
			// CHAR_SJIS2
{$IFDEF DEBUG}
					raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
			end;
		end;
	end;
end;


//***************************************************************************
// 点滅画面描画
//***************************************************************************
procedure TPromptForm.BlinkDraw;
var
	x, y : Integer;
	DecodeESCCommand : TDecodeESCCommand;
	TempChar : Array[0..2] of Char;
begin
	if(FPositionMove = True) then Exit;

	DecodeESCCommand.Command := DECODEESC_WRITE;
	DecodeESCCommand.ScroolLine := 0;
	TempChar[2] := #0;

	for y := 0 to SCREEN_HEIGHT - 1 do begin
		DecodeESCCommand.Rect.Top := y;
		DecodeESCCommand.Rect.Bottom := y;

		// x を操作するので while ループにする
		x := 0;
		while(x < SCREEN_WIDTH) do begin
			if not(Blink in DecodeESCSequence.VRAM[x, y].Attribute.Attribute_Sub) then begin
				// 点滅以外
				if(DecodeESCSequence.VRAM[x, y].Attribute.LetterCode = CHAR_SJIS1) then begin
					// SJIS1
					Inc(x, 2);
				end else begin
					// SJIS2, ASCII, GRAPHIC, ２バイト半角
					Inc(x);
				end;
			end else begin
				// 点滅
				case DecodeESCSequence.VRAM[x, y].Attribute.LetterCode of
				// ASCII
				CHAR_ASCII :
					begin
						// 空白以外だったら描画する
						if not(DecodeESCSequence.VRAM[x, y].Letter in [$0, $20]) then begin
							DecodeESCCommand.Rect.Left  := x;
							DecodeESCCommand.Rect.Right := x;
							DecodeESCCommand.Text := Chr(DecodeESCSequence.VRAM[x, y].Letter);
							DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
							WriteDisplay(DecodeESCCommand);
						end;
						Inc(x);
					end;

				CHAR_GRAPHIC :
					begin
						// 空白以外だったら描画する
						if not(DecodeESCSequence.VRAM[x, y].Letter in [$0, $20]) then begin
							DecodeESCCommand.Rect.Left  := x;
							DecodeESCCommand.Rect.Right := x;
							DecodeESCCommand.Text := Chr(DecodeESCSequence.VRAM[x, y].Letter);
							DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
							WriteDisplay(DecodeESCCommand);
						end;
						Inc(x);
					end;

				// SJIS １文字目
				CHAR_SJIS1 :
					begin
{$IFDEF DEBUG}
						if(x + 1 >= SCREEN_WIDTH) then begin
							raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
						end else if(DecodeESCSequence.VRAM[x+1, y].Attribute.LetterCode <> CHAR_SJIS2) then begin
							raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
						end;
{$ENDIF}
						// 空白以外だったら描画する
						if(DecodeESCSequence.VRAM[x, y].Letter <> $81) or
								(DecodeESCSequence.VRAM[x+1, y].Letter <> $40) then begin
							DecodeESCCommand.Rect.Left  := x;
							DecodeESCCommand.Rect.Right := x + 1;
							TempChar[0] := Char(DecodeESCSequence.VRAM[x  , y].Letter);
							TempChar[1] := Char(DecodeESCSequence.VRAM[x+1, y].Letter);
							DecodeESCCommand.Text := String(TempChar);
							DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
							WriteDisplay(DecodeESCCommand);
						end;
						Inc(x, 2);
					end;

				// ２バイト半角
				CHAR_ZEN2 :
					begin
						DecodeESCCommand.Rect.Left  := x;
						DecodeESCCommand.Rect.Right := x;
						TempChar[0] := Char(DecodeESCSequence.VRAM[x, y].Letter shr 8);
						TempChar[1] := Char(DecodeESCSequence.VRAM[x, y].Letter and $ff);
						DecodeESCCommand.Text := String(TempChar);
						DecodeESCCommand.Attribute := DecodeESCSequence.VRAM[x, y].Attribute;
						WriteDisplay(DecodeESCCommand);
						Inc(x);
					end;
				else
					// CHAR_SJIS2
{$IFDEF DEBUG}
					raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
				end;
			end;
		end;
	end;
end;


//***************************************************************************
// 画面描画
//***************************************************************************
procedure TPromptForm.DrawDisplay(DrawStr : String);
var
	i : Integer;
	DecodeESCCommandList : TDecodeESCCommandList;
begin
	DecodeESCCommandList := TDecodeESCCommandList.Create;
	try
		DecodeESCSequence.DecodeESCSequence(DrawStr, DecodeESCCommandList);

		if(FPositionMove = True) then Exit;

		for i := 0 to DecodeESCCommandList.Count - 1 do begin
			case DecodeESCCommandList[i]^.Command of
			DECODEESC_CLEAR :		// 画面消去
				begin
					ClearDisplay(DecodeESCCommandList[i]^.Rect);
				end;

			DECODEESC_SCROOL :	// スクロール
				begin
					ScroolDisplay(DecodeESCCommandList[i]^.Rect, DecodeESCCommandList[i]^.ScroolLine);
				end;

			DECODEESC_INSERT :	// 空白行挿入
				begin
					InsertDisplay(DecodeESCCommandList[i]^.Rect, DecodeESCCommandList[i]^.ScroolLine);
				end;

			DECODEESC_WRITE :		// 文字描画
				begin
					WriteDisplay(DecodeESCCommandList[i]^);
				end;
			end;
		end;
	finally
		DecodeESCCommandList.Free;
	end;
end;


//***************************************************************************
// 画面消去
//***************************************************************************
procedure TPromptForm.ClearDisplay(Rect : TRect);
var
	DestRect : TRect;
begin
	DestRect.Left   := CalcScreenX(Rect.Left);
	DestRect.Top    := CalcScreenY(Rect.Top );
	DestRect.Right  := CalcScreenX(Rect.Right  + 1);
	DestRect.Bottom := CalcScreenY(Rect.Bottom + 1);
	Canvas.Brush.Color := clBlack;
	Canvas.Brush.Style := bsSolid;
	Canvas.FillRect(DestRect);
end;


//***************************************************************************
// スクロール
//***************************************************************************
procedure TPromptForm.ScroolDisplay(Rect : TRect; ScroolLine : Integer);
var
	SourceRect : TRect;
	DestRect : TRect;
	i : Integer;
begin
	// 重いけど誤差を防ぐために１行づつスクロールする
	SourceRect.Left  := CalcScreenX(0);
	SourceRect.Right := CalcScreenX(SCREEN_WIDTH);
	DestRect.Left    := SourceRect.Left;
	DestRect.Right   := SourceRect.Right;

	for i := 0 to Rect.Bottom - Rect.Top - ScroolLine do begin
		SourceRect.Top    := CalcScreenY(Rect.Top + i + ScroolLine);
		SourceRect.Bottom := CalcScreenY(Rect.Top + i + ScroolLine + 1);
		DestRect.Top      := CalcScreenY(Rect.Top + i);
		DestRect.Bottom   := CalcScreenY(Rect.Top + i + 1);

		// スクロール
		Canvas.CopyRect(DestRect, Canvas, SourceRect);

	end;

// スクロール下部を塗りつぶす
SourceRect.Top    := CalcScreenY(Rect.Bottom - ScroolLine + 1);
SourceRect.Bottom := CalcScreenY(Rect.Bottom + 1);
Canvas.Brush.Color := clBlack;
Canvas.Brush.Style := bsSolid;
Canvas.FillRect(SourceRect);

// 画面を保存
//	Image1.Picture.Bitmap.SaveToFile('r:\test.bmp');	//@ for debug
end;


//***************************************************************************
// 空白行挿入
//***************************************************************************
procedure TPromptForm.InsertDisplay(Rect : TRect; ScroolLine : Integer);
var
	SourceRect : TRect;
	DestRect : TRect;
	i : Integer;
begin
	// 重いけど誤差を防ぐために１行づつ移動する
	SourceRect.Left  := CalcScreenX(0);
	SourceRect.Right := CalcScreenX(SCREEN_WIDTH);
	DestRect.Left    := CalcScreenX(0);
	DestRect.Right   := CalcScreenX(SCREEN_WIDTH);

	for i := 0 to Rect.Bottom - Rect.Top - ScroolLine do begin
		SourceRect.Top    := CalcScreenY(Rect.Bottom - (ScroolLine - 1) - i);
		SourceRect.Bottom := CalcScreenY(Rect.Bottom - (ScroolLine - 1) - i + 1);
		DestRect.Top      := CalcScreenY(Rect.Bottom - i);
		DestRect.Bottom   := CalcScreenY(Rect.Bottom - i + 1);

		// 移動
		Canvas.CopyRect(DestRect, Canvas, SourceRect);
	end;

	// 挿入上部を塗りつぶす
	SourceRect.Top    := CalcScreenY(Rect.Top);
	SourceRect.Bottom := CalcScreenY(Rect.Top + ScroolLine);
	Canvas.Brush.Color := clBlack;
	Canvas.Brush.Style := bsSolid;
	Canvas.FillRect(SourceRect);
end;


//***************************************************************************
// 文字列描画
//***************************************************************************
procedure TPromptForm.WriteDisplay(DecodeESCCommand : TDecodeESCCommand);
var
	i : Integer;
	TempRect  : TRect;		// 描画領域（２バイト半角の場合：一次描画用TBitmap）ドット単位
	DstRect   : TRect;		// 描画領域（DesCanvas）ドット単位
	SrcRect   : TRect;		// TempCanvas or DstCanvas へ文字を書く時の文字の座標代入用
	TempTxt   : String;		// TempCanvas or DstCanvas へ文字を書く時の描画文字代入用
	DstCanvas : TCanvas;	// 描画先 Canvas(=Image1.Canvas)
	x, y : Integer;
begin
  DstCanvas := Canvas;
	if(DecodeESCCommand.Attribute.LetterCode = CHAR_ZEN2) then begin
		//-----------------------------------------------------------------------
		// ２バイト半角
		//-----------------------------------------------------------------------
		TempBitmap.Width  := CalcBitmapX(Length(DecodeESCCommand.Text));
		TempBitmap.Height := CalcScreenY(DecodeESCCommand.Rect.Top + 1)
			- CalcScreenY(DecodeESCCommand.Rect.Top);
		TempRect.Left   := 0;
		TempRect.Top    := 0;
		TempRect.Right  := TempBitmap.Width;
		TempRect.Bottom := TempBitmap.Height;

		DstRect.Left   := CalcScreenX(DecodeESCCommand.Rect.Left);
		DstRect.Top    := CalcScreenY(DecodeESCCommand.Rect.Top);
		DstRect.Right  := CalcScreenX(DecodeESCCommand.Rect.Left + Length(DecodeESCCommand.Text) div 2);
		DstRect.Bottom := CalcScreenY(DecodeESCCommand.Rect.Top + 1);

		// まず(黒 or 反転色)で塗りつぶす
		if(Reverse in DecodeESCCommand.Attribute.Attribute_Sub) then begin
			TempBitmap.Canvas.Brush.Color := DecodeESCCommand.Attribute.Color;
			TempBitmap.Canvas.Font.Color  := clBlack;
		end else begin
			TempBitmap.Canvas.Brush.Color := clBlack;
			TempBitmap.Canvas.Font.Color  := DecodeESCCommand.Attribute.Color;
		end;

		if(Secret in DecodeESCCommand.Attribute.Attribute_Sub) or
    		((Blink in DecodeESCCommand.Attribute.Attribute_Sub) and (FBlinkOn = False)) then begin
			TempBitmap.Canvas.Font.Color  := TempBitmap.Canvas.Brush.Color;
		end;

    // 背景が黒じゃなかったら塗りつぶし領域を１行減らす
		if(TempBitmap.Canvas.Brush.Color = clBlack) then begin
			TempBitmap.Canvas.Brush.Style := bsSolid;
			TempBitmap.Canvas.FillRect(TempRect);
    end else begin
			Dec(TempRect.Bottom);
			TempBitmap.Canvas.Brush.Style := bsSolid;
			TempBitmap.Canvas.FillRect(TempRect);
			Inc(TempRect.Bottom);
    end;

		// フォントの設定
		TempBitmap.Canvas.Font.Pitch  := fpFixed;
		TempBitmap.Canvas.Font.Style  := [];
		TempBitmap.Canvas.Font.Height := CalcFontHeight;

		// １文字づつ描画する
		i := 0;
		SrcRect.Top    := 0;
		SrcRect.Bottom := TempBitmap.Height;

		while(i + 1 <= Length(DecodeESCCommand.Text)) do begin
			// １ドットずれの誤差排除のため
			SrcRect.Left := CalcBitmapX(DecodeESCCommand.Rect.Left + i)
				- CalcBitmapX(DecodeESCCommand.Rect.Left);

			TempTxt := '';
			if(DecodeESCCommand.Text[i+1] in [#$81..#$9f, #$e0..#$fc]) then begin
				// 漢字１バイト目
        if(DecodeESCCommand.Text[i+1] = #$86) and (DecodeESCCommand.Text[i+2] in [#$a2..#$ed]) then begin
        	// ９８罫線の場合
					if(FMPMDForm.InstalledLineFont = False) then begin
						TempBitmap.Canvas.Font.Name :=  STR_MSGOTHIC;
						TempTxt := '・';
					end else begin
						TempBitmap.Canvas.Font.Name := STR_98LINE;
						TempTxt := #$96 + DecodeESCCommand.Text[i+2];
					end;
        end else begin
					TempBitmap.Canvas.Font.Name := STR_MSGOTHIC;
   				TempTxt := DecodeESCCommand.Text[i+1] + DecodeESCCommand.Text[i+2];
        end;
				Inc(i, 2);
			end else begin
      	// 半角文字
				TempTxt := DecodeESCCommand.Text[i+1];
        TempBitmap.Canvas.Font.Name :=  STR_MSGOTHIC;
				Inc(i);
      end;
			TempBitmap.Canvas.TextOut(SrcRect.Left, SrcRect.Top, TempTxt);
		end;

//@	TempBitmap.SaveToFile('r:\aaa.bmp');

		// TempBitmap から DstBitmap へ横方向 1/2 でコピー
		//@ 高速化必要かも・・・
		if(Reverse in DecodeESCCommand.Attribute.Attribute_Sub) then begin
			for y := 0 to TempBitmap.Height - 1 do begin
				for x := 0 to TempBitmap.Width div 2 - 1 do begin
					DstCanvas.Pixels[DstRect.Left + x, DstRect.Top + y]
						:= $01000000
						or $00ffffff and (not (TempBitmap.Canvas.Pixels[x * 2, y] or TempBitmap.Canvas.Pixels[x * 2 + 1, y]));
				end;
			end;
		end else begin
			for y := 0 to TempBitmap.Height - 1 do begin
				for x := 0 to TempBitmap.Width div 2 - 1 do begin
					DstCanvas.Pixels[DstRect.Left + x, DstRect.Top + y]
						:= TempBitmap.Canvas.Pixels[x * 2, y] or TempBitmap.Canvas.Pixels[x * 2 + 1, y];
				end;
			end;
		end;
  end else begin
		//-----------------------------------------------------------------------
		// ２バイト半角以外
		//-----------------------------------------------------------------------
		DstRect.Left   := CalcScreenX(DecodeESCCommand.Rect.Left);
		DstRect.Top    := CalcScreenY(DecodeESCCommand.Rect.Top);
		DstRect.Right  := CalcScreenX(DecodeESCCommand.Rect.Left + Length(DecodeESCCommand.Text));
		DstRect.Bottom := CalcScreenY(DecodeESCCommand.Rect.Top + 1);

		// まず(黒 or 反転色)で塗りつぶす
		if(Reverse in DecodeESCCommand.Attribute.Attribute_Sub) then begin
			DstCanvas.Brush.Color := DecodeESCCommand.Attribute.Color;
			DstCanvas.Font.Color  := clBlack;
		end else begin
			DstCanvas.Brush.Color := clBlack;
			DstCanvas.Font.Color  := DecodeESCCommand.Attribute.Color;
		end;

		if(Secret in DecodeESCCommand.Attribute.Attribute_Sub) or
    		((Blink in DecodeESCCommand.Attribute.Attribute_Sub) and (FBlinkOn = False)) then begin
			DstCanvas.Font.Color  := DstCanvas.Brush.Color;
		end;

    // 背景が黒じゃなかったら塗りつぶし領域を１行減らす
		if(DstCanvas.Brush.Color = clBlack) then begin
			DstCanvas.Brush.Style := bsSolid;
			DstCanvas.FillRect(DstRect);
    end else begin
			Dec(DstRect.Bottom);
			DstCanvas.Brush.Style := bsSolid;
			DstCanvas.FillRect(DstRect);
			Inc(DstRect.Bottom);
    end;

		// フォントの設定
		DstCanvas.Font.Pitch  := fpFixed;
		DstCanvas.Font.Style  := [];
		DstCanvas.Font.Height := CalcFontHeight;

		// １文字づつ描画する
		i := 0;
		SrcRect.Top    := DstRect.Top;
		SrcRect.Bottom := DstRect.Bottom;

		while(i + 1 <= Length(DecodeESCCommand.Text)) do begin
			SrcRect.Left := CalcScreenX(DecodeESCCommand.Rect.Left + i);

      if(DecodeESCCommand.Attribute.LetterCode = CHAR_GRAPHIC) then begin
      	// グラフィック文字
				if(FMPMDForm.InstalledGraphicFont = False) then begin
        	DstCanvas.Font.Name :=  STR_MSGOTHIC;
					TempTxt := '･';
        end else begin
					DstCanvas.Font.Name := STR_98GRAPHIC;
          if(DecodeESCCommand.Text[i+1] in [#$80..#$9f]) then begin
						TempTxt := Chr(Ord(DecodeESCCommand.Text[i+1]) - $60);
					end else begin
						TempTxt := Chr(Ord(DecodeESCCommand.Text[i+1]) - $a0);
          end;
        end;
				Inc(i);
				SrcRect.Right := CalcScreenX(DecodeESCCommand.Rect.Left + i);

			end else if(DecodeESCCommand.Text[i+1] in [#$81..#$9f, #$e0..#$fc]) then begin
				// 漢字１バイト目
				TempTxt := DecodeESCCommand.Text[i+1] + DecodeESCCommand.Text[i+2];

				// FMP 外字の判別：$EB9F ～ $EC9E
				if(((TempTxt[1] = #$eb) and (TempTxt[2] >= #$9f)) or
						((TempTxt[1] = #$ec) and (TempTxt[2] <= #$9e))) then begin

					// FMP外字がないときは「・」にする
					if(FMPMDForm.InstalledFMPFont = False) then begin
						DstCanvas.Font.Name :=  STR_MSGOTHIC;
						TempTxt := '・';
					end else begin
						DstCanvas.Font.Name := STR_FMPGAIJI;
						TempTxt[1] := Chr(Ord(TempTxt[1]) - $60);
					end;

				// 98罫線(全角)の判別：$86A2 ～ $86ED
        end else if(TempTxt[1] = #$86) and (TempTxt[2] in [#$a2..#$ed]) then begin
					if(FMPMDForm.InstalledLineFont = False) then begin
						DstCanvas.Font.Name :=  STR_MSGOTHIC;
						TempTxt := '・';
					end else begin
						DstCanvas.Font.Name := STR_98LINE;
						TempTxt[1] := Chr(Ord(TempTxt[1]) + $10);
					end;

				end else begin
					DstCanvas.Font.Name :=  STR_MSGOTHIC;
				end;
				Inc(i, 2);
				SrcRect.Right := CalcScreenX(DecodeESCCommand.Rect.Left + i);
			end else begin
				// 半角文字
				DstCanvas.Font.Name :=  STR_MSGOTHIC;
				TempTxt := DecodeESCCommand.Text[i+1];
				Inc(i);
				SrcRect.Right := CalcScreenX(DecodeESCCommand.Rect.Left + i);
			end;

			DstCanvas.TextOut(SrcRect.Left, SrcRect.Top, TempTxt);
		end;
	end;


	// バーティカルラインを引く
	if(VerticalLine in DecodeESCCommand.Attribute.Attribute_Sub) then begin
		if not(Secret in DecodeESCCommand.Attribute.Attribute_Sub) or
    		((Blink in DecodeESCCommand.Attribute.Attribute_Sub) and (FBlinkOn = False)) then begin
			DstCanvas.Pen.Color := DecodeESCCommand.Attribute.Color;
			DstCanvas.Pen.Width := CalcLineWidth;
			DstCanvas.Pen.Style := psSolid;
			DstCanvas.Pen.Mode  := pmCopy;

			for i := 0 to Length(DecodeESCCommand.Text) - 1 do begin
				DstCanvas.MoveTo((CalcScreenX(DecodeESCCommand.Rect.Left + i)
						+ CalcScreenX(DecodeESCCommand.Rect.Left + i + 1)) div 2 - 1, DstRect.Top);
				DstCanvas.LineTo((CalcScreenX(DecodeESCCommand.Rect.Left + i)
						+ CalcScreenX(DecodeESCCommand.Rect.Left + i + 1)) div 2 - 1, DstRect.Bottom - 1);
			end;
		end;
	end;

	// アンダーラインを引く
	if(UnderLine in DecodeESCCommand.Attribute.Attribute_Sub) then begin
		if not(Secret in DecodeESCCommand.Attribute.Attribute_Sub) or
    		((Blink in DecodeESCCommand.Attribute.Attribute_Sub) and (FBlinkOn = False)) then begin
			DstCanvas.Pen.Color := DecodeESCCommand.Attribute.Color;
			DstCanvas.Pen.Width := CalcLineWidth;
			DstCanvas.Pen.Style := psSolid;
			DstCanvas.Pen.Mode  := pmCopy;
			DstCanvas.MoveTo(DstRect.Left , DstRect.Bottom - CalcLineWidth);
			DstCanvas.LineTo(DstRect.Right, DstRect.Bottom - CalcLineWidth);
		end;
	end;
end;


//***************************************************************************
// キャラクタベースのX座標からグラフィックベース(Screen)のX座標を計算する
//***************************************************************************
function TPromptForm.CalcScreenX(CharX : Integer) : Integer;
var
	DrawWidth : Integer;		// 描画領域の幅　(ふち除く）
	DrawHeight : Integer;   // 描画領域の高さ(ふち除く）
begin
	DrawWidth  := ClientWidth  - EdgeWidth * 2;
	DrawHeight := ClientHeight - EdgeWidth * 2;

	if(SCREEN_WIDTH * DrawHeight > SCREEN_HEIGHT * 2 * DrawWidth) then begin	// 縦長
		Result := EdgeWidth + DrawWidth * CharX div SCREEN_WIDTH;
	end else begin																														// 横長
		Result := EdgeWidth
			+ DrawHeight * CharX div (SCREEN_HEIGHT * 2)
			+ (DrawWidth - DrawHeight * SCREEN_WIDTH div (SCREEN_HEIGHT * 2)) div 2;
	end;
end;


//***************************************************************************
// キャラクタベースのY座標からグラフィックベース(Screen)のY座標を計算する
//***************************************************************************
function TPromptForm.CalcScreenY(CharY : Integer) : Integer;
var
	DrawWidth : Integer;		// 描画領域の幅　(ふち除く）
	DrawHeight : Integer;   // 描画領域の高さ(ふち除く）
begin
	DrawWidth  := ClientWidth  - EdgeWidth * 2;
	DrawHeight := ClientHeight - EdgeWidth * 2;

	if(SCREEN_WIDTH * DrawHeight > SCREEN_HEIGHT * 2 * DrawWidth) then begin	// 縦長
		Result := EdgeWidth
			+ DrawWidth * CharY * 2 div SCREEN_WIDTH
			+ (DrawHeight - DrawWidth * SCREEN_HEIGHT * 2 div SCREEN_WIDTH) div 2;
	end else begin																														// 横長
		Result := EdgeWidth + DrawHeight * CharY div SCREEN_HEIGHT;
	end;
end;


//***************************************************************************
// キャラクタベースのX座標からグラフィックベース(Bitmap)のX座標を計算する
//***************************************************************************
function TPromptForm.CalcBitmapX(CharX : Integer) : Integer;
var
	DrawWidth : Integer;		// 描画領域の幅　(ふち除く）
	DrawHeight : Integer;   // 描画領域の高さ(ふち除く）
begin
	DrawWidth  := ClientWidth  - EdgeWidth * 2;
	DrawHeight := ClientHeight - EdgeWidth * 2;

	if(SCREEN_WIDTH * DrawHeight > SCREEN_HEIGHT * 2 * DrawWidth) then begin	// 縦長
		Result := DrawWidth * CharX div SCREEN_WIDTH;
	end else begin																														// 横長
		Result := DrawHeight * CharX div (SCREEN_HEIGHT * 2);
	end;
end;


//***************************************************************************
// キャラクタベースのY座標からグラフィックベース(Bitmap)のY座標を計算する
//***************************************************************************
function TPromptForm.CalcBitmapY(CharY : Integer) : Integer;
var
	DrawWidth : Integer;		// 描画領域の幅　(ふち除く）
	DrawHeight : Integer;   // 描画領域の高さ(ふち除く）
begin
	DrawWidth  := ClientWidth  - EdgeWidth * 2;
	DrawHeight := ClientHeight - EdgeWidth * 2;

	if(SCREEN_WIDTH * DrawHeight > SCREEN_HEIGHT * 2 * DrawWidth) then begin	// 縦長
		Result := DrawWidth * CharY * 2 div SCREEN_WIDTH;
	end else begin																														// 横長
		Result := DrawHeight * CharY div SCREEN_HEIGHT;
	end;
end;


//***************************************************************************
// 画面サイズからフォントのサイズ(Height)を計算する
//***************************************************************************
function TPromptForm.CalcFontHeight : Integer;
var
	DrawWidth : Integer;		// 描画領域の幅　(ふち除く）
	DrawHeight : Integer;   // 描画領域の高さ(ふち除く）
begin
	DrawWidth  := ClientWidth  - EdgeWidth * 2;
	DrawHeight := ClientHeight - EdgeWidth * 2;

	if(SCREEN_WIDTH * DrawHeight > SCREEN_HEIGHT * 2 * DrawWidth) then begin	// 縦長
		Result := DrawWidth * 2 div SCREEN_WIDTH;
	end else begin																														// 横長
		Result := DrawHeight div SCREEN_HEIGHT;
	end;

  if(Result < 1) then begin
  	Result := 1;
  end;
end;


//***************************************************************************
// 画面サイズから線幅を計算する
//***************************************************************************
function TPromptForm.CalcLineWidth : Integer;
var
	DrawWidth : Integer;		// 描画領域の幅　(ふち除く）
	DrawHeight : Integer;   // 描画領域の高さ(ふち除く）
begin
	DrawWidth  := ClientWidth  - EdgeWidth * 2;
	DrawHeight := ClientHeight - EdgeWidth * 2;

	if(SCREEN_WIDTH * DrawHeight > SCREEN_HEIGHT * 2 * DrawWidth) then begin	// 縦長
		Result := (DrawWidth + ORG_SCREEN_WIDTH div 2) div ORG_SCREEN_WIDTH;
	end else begin																														// 横長
		Result := (DrawHeight + ORG_SCREEN_HEIGHT div 2) div ORG_SCREEN_HEIGHT;
	end;
	if(Result < 1) then begin
		Result := 1;
	end;
end;


//###########################################################################
//###########################################################################
// TPromptThread クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// コンストラクタ
//***************************************************************************
constructor TPromptThread.Create(Owner : TPromptForm);
begin
	FOwner := Owner;
	FDelay := 0;
	FInterval := 50;
	DummyChar := #0;
	pKaraoke := @DummyChar;
	FillChar(FMusData, SizeOf(FMusData), 0);
	FillChar(SyncScntBuf, SizeOf(SyncScntBuf), 0);
	FLastSyncScnt := -1;
	FPMDWinDraw := False;
	FDrawStr := '';
	pw := 0;
	pr := 0;
	DisplayPrompt := False;

	inherited Create(False);
	Priority := tpNormal;
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
destructor TPromptThread.Destroy;
begin
	inherited Destroy;
end;


//***************************************************************************
// 表示開始
//***************************************************************************
procedure TPromptThread.PlayStart;
begin
	FillChar(SyncScntBuf, SizeOf(SyncScntBuf), 0);
	FLastSyncScnt := -1;
	pw := 0;
	pr := 0;
	SetDelay(FDelay);
	DisplayPrompt := True;
	FOwner.PositionMove := False;
end;


//***************************************************************************
// 表示停止
//***************************************************************************
procedure TPromptThread.PlayStop;
begin
	DisplayPrompt := False;
	FOwner.PositionMove := False;
end;


//***************************************************************************
// 表示 Pause
//***************************************************************************
procedure TPromptThread.PlayPause;
begin
	DisplayPrompt := not DisplayPrompt;
end;


//***************************************************************************
// 再生位置変更処理開始
//***************************************************************************
procedure TPromptThread.PositionMoveStart;
begin
	FOwner.PositionMove := True;
end;


//***************************************************************************
// 再生位置変更処理終了
//***************************************************************************
procedure TPromptThread.PositionMoveEnd;
var
	i : Integer;
	Len : Integer;
begin
	if(FPlayDriver = DRIVER_FMP) then begin						// WinFMP の場合
		if(SyncScntBuf[pw] >= fmp_getsyncscnt) then begin	// 再生位置が前に戻ったとき
			Synchronize(InitDisplay);
			FLastSyncScnt := -1;															// 最初から描画
			pKaraoke := @FMusData[PWord(@FMusData[0])^];
			if(StrLComp(pKaraoke, 'FMC', 3) = 0) then begin
				pKaraoke := pKaraoke + 4;
			end else begin
				pKaraoke := @DummyChar;
			end;
		end;

		for i := 0 to NumOfDelayBuffer-1 do begin
			SyncScntBuf[i] := fmp_getsyncscnt;
		end;

    for i := FLastSyncScnt to SyncScntBuf[pr] - 1 do begin
			// 区切り文字を探す($1b $21)
			Len := Pos(#$1b#$21, String(pKaraoke));
			if(Len > 0) then begin
				FDrawStr := Copy(String(pKaraoke), 1, Len - 1);
				Inc(pKaraoke, Len + 2);
			end else begin
				FDrawStr := String(pKaraoke);
				// 全部終わったのでダミーに関連付け
				pKaraoke := @DummyChar;
			end;

			Synchronize(DrawDisplay);
    end;
		FLastSyncScnt := SyncScntBuf[pr];
	end;
	FOwner.PositionMove := False;
	Synchronize(FullDraw);
end;


//***************************************************************************
// FMP のプロンプト描画
//***************************************************************************
procedure TPromptThread.DrawFMPPrompt;
var
	Len : Integer;
	i : Integer;
begin
		SyncScntBuf[pw] := fmp_getsyncscnt;

		if(SyncScntBuf[pr] > FLastSyncScnt) then begin
			for i := FLastSyncScnt to SyncScntBuf[pr] - 1 do begin
				if(DisplayPrompt = False) or (FOwner.PositionMove = True) then begin
					Break;
				end;

				// 区切り文字を探す($1b $21)
				Len := Pos(#$1b#$21, String(pKaraoke));
				if(Len > 0) then begin
					FDrawStr := Copy(String(pKaraoke), 1, Len - 1);
					Inc(pKaraoke, Len + 2);
				end else begin
					FDrawStr := String(pKaraoke);
					// 全部終わったのでダミーに関連付け
					pKaraoke := @DummyChar;
				end;

				Synchronize(DrawDisplay);
			end;

			FLastSyncScnt := SyncScntBuf[pr];
		end;
end;


//***************************************************************************
// PMD のプロンプト描画
//***************************************************************************
procedure TPromptThread.DrawPMDPrompt;
var
	i : Integer;
	MemoMsg : Array[0..1024-1] of Char;
begin
	if(FPMDWinDraw = True) then begin
		FPMDWinDraw := False;

		// FileName の追加
		getmusicfilename(@MemoMsg[0]);
		FDrawStr := 'Filename : ' + ExtractFileName(String(MemoMsg)) + #$0D#$0A;

		// PPZFile の追加
		getmemo(@MemoMsg[0], Nil, 0, -2);
		if(MemoMsg[0] <> #0) then begin
			FDrawStr := FDrawStr + 'PPZFile  : ' + String(MemoMsg) + #$0D#$0A;
		end;

		// PPSFile の追加
		getmemo(@MemoMsg[0], Nil, 0, -1);
		if(MemoMsg[0] <> #0) then begin
			FDrawStr := FDrawStr + 'PPSFile  : ' + String(MemoMsg) + #$0D#$0A;
		end;

		// PCMFile の追加
		getmemo(@MemoMsg[0], Nil, 0,  0);
		if(MemoMsg[0] <> #0) then begin
			FDrawStr := FDrawStr + 'PCMFile  : ' + String(MemoMsg) + #$0D#$0A;
		end;

		// Title の追加
		getmemo(@MemoMsg[0], Nil, 0,  1);
		if(MemoMsg[0] <> #0) then begin
			FDrawStr := FDrawStr + 'Title    : ' + String(MemoMsg) + #$0D#$0A;
		end;

		// Composer の追加
		getmemo(@MemoMsg[0], Nil, 0,  2);
		if(MemoMsg[0] <> #0) then begin
			FDrawStr := FDrawStr + 'Composer : ' + String(MemoMsg) + #$0D#$0A;
		end;

		// Arranger の追加
		getmemo(@MemoMsg[0], Nil, 0,  3);
		if(MemoMsg[0] <> #0) then begin
			FDrawStr := FDrawStr + 'Arranger : ' + String(MemoMsg) + #$0D#$0A;
		end;

		// Memo の追加
		for i := 4 to 255 do begin
			getmemo(@MemoMsg[0], Nil, 0,  i);
			if(MemoMsg[0] = #0) then begin
				Break;
			end;
			FDrawStr := FDrawStr + '         : ' + String(MemoMsg) + #$0D#$0A;
		end;

		Synchronize(DrawDisplay);
	end;
end;


//***************************************************************************
// Interval 設定
//***************************************************************************
procedure TPromptThread.SetInterval(Value : Integer);
begin
	if(Value < 1) then begin
		FInterval := 1;
	end else begin
		FInterval := Value;
	end;
end;


//***************************************************************************
// Delay 設定
//***************************************************************************
procedure TPromptThread.SetDelay(Value : Integer);
begin
	pr := pw - Value div FInterval;
	while(pr < 0) do begin
		Inc(pr, NumOfDelayBuffer);
	end;

	FDelay := Value;
end;


//***************************************************************************
// 曲変更
//***************************************************************************
procedure TPromptThread.MusicChange(Filename : string; PlayDriver : TPlayDriver);
var
	F : Integer;
begin
	DisplayPrompt := False;
	FillChar(SyncScntBuf, SizeOf(SyncScntBuf), 0);
	FLastSyncScnt := -1;
	pw := 0;
	pr := 0;
	SetDelay(FDelay);

	FPlayDriver := PlayDriver;

	// 曲データ読み込み
	FillChar(FMusData, SizeOf(FMusData), 0);
	pKaraoke := @DummyChar;

	F := FileOpen(Filename, fmOpenRead	or fmShareDenyWrite);
	if(F < 0) then begin		// 読み込み失敗
		Exit;
	end;

	// 読み込み
	try
		FileRead(F, FMusData, FMP_MUSDATASIZE);
		if(FPlayDriver = DRIVER_FMP) then begin
			pKaraoke := @FMusData[PWord(@FMusData[0])^];
			if(StrLComp(pKaraoke, 'FMC', 3) = 0) then begin
				pKaraoke := pKaraoke + 4;
			end else begin
				pKaraoke := @DummyChar;
      end;
		end;
	finally
		FileClose(F);
	end;
	FPMDWinDraw := True;
	Synchronize(InitDisplay);
end;


//***************************************************************************
// 全画面消去
//***************************************************************************
procedure TPromptThread.InitDisplay;
begin
	(FOwner as TPromptForm).InitDisplay;
end;


//***************************************************************************
// オーナー画面で文字列描画
//***************************************************************************
procedure TPromptThread.DrawDisplay;
begin
	(FOwner as TPromptForm).DrawDisplay(FDrawStr);
end;


//***************************************************************************
// オーナー画面で全画面描画
//***************************************************************************
procedure TPromptThread.FullDraw;
begin
	(FOwner as TPromptForm).FullDraw;
end;


//***************************************************************************
// スレッド実行部分
//***************************************************************************
procedure TPromptThread.Execute;
var
	Msg : TMsg;
	Time1, Time2 : Integer;
begin
	while(Terminated = False) do begin
		Time1 := GetTickCount;
		while(PeekMessage(Msg, Integer(Nil), 0, 0, PM_REMOVE)) do begin
			// メッセージ識別
			case Msg.message of
			WM_PROMPT_MUSICCHANGE:				// 曲変更
				begin
					MusicChange(String(Msg.LParam), TPlayDriver(Msg.WParam));
					StrDispose(PChar(Msg.LParam));
				end;

			WM_PROMPT_PLAYSTART:					// 演奏開始
				PlayStart;

			WM_PROMPT_PLAYSTOP:						// 演奏停止
				PlayStop;

			WM_PROMPT_PLAYPAUSE:					// Pause
				PlayPause;

			WM_PROMPT_POSITIONMOVESTART:	// 演奏位置移動開始
				PositionMoveStart;

			WM_PROMPT_POSITIONMOVEEND:		// 演奏位置移動終了
				PositionMoveEnd;

			end;
		end;

		// 現在の位置まで描画する
		if(FPlayDriver = DRIVER_FMP) then begin						// WinFMP の場合
			if(DisplayPrompt = True) and (FOwner.PositionMove = False) then begin
				DrawFMPPrompt;
      end;
		end else begin																		// PMDWin の場合
			DrawPMDPrompt;
		end;

		if(DisplayPrompt = True) and (FOwner.PositionMove = False) then begin
			Inc(pw);
			if(pw = NumOfDelayBuffer) then pw := 0;
			Inc(pr);
			if(pr = NumOfDelayBuffer) then pr := 0;
		end;

		Time2 := GetTickCount;
		if(FInterval - (Time2 - Time1) > 0) then begin
			Sleep(FInterval - (Time2 - Time1));
		end;
	end;
end;


//###########################################################################
//###########################################################################
// TPromptThread クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// コンストラクタ
//***************************************************************************
constructor TPromptBlinkThread.Create(Owner : TPromptForm);
begin
	FOwner := Owner;
  RemainTime := BlinkTime[0];
  FInterval := 50;
	inherited Create(False);
end;


//***************************************************************************
// スレッド実行部分
//***************************************************************************
procedure TPromptBlinkThread.Execute;
var
	Time1, Time2 : Integer;
begin
	while(Terminated = False) do begin
		Time1 := GetTickCount;
		if(RemainTime <= 0) then begin
	  	FOwner.BlinkOn := not FOwner.BlinkOn;
  	  if(FOwner.BlinkOn = False) then begin		// 点滅→消滅
	      Inc(RemainTime, BlinkTime[1]);
    		Synchronize(BlinkDraw);
    	end else begin                        		// 消滅→点滅
	      Inc(RemainTime, BlinkTime[0]);
    		Synchronize(BlinkDraw);
      end;
    end;
    Dec(RemainTime, FInterval);

		Time2 := GetTickCount;
		if(FInterval - (Time2 - Time1) > 0) then begin
			Sleep(FInterval - (Time2 - Time1));
		end;
  end;
end;


//***************************************************************************
// ブリンク描画
//***************************************************************************
procedure TPromptBlinkThread.BlinkDraw;
begin
	FOwner.BlinkDraw;
end;


//***************************************************************************
// Interval 設定
//***************************************************************************
procedure TPromptBlinkThread.SetInterval(Value : Integer);
begin
	if(Value < 1) then begin
		FInterval := 1;
	end else begin
		FInterval := Value;
	end;
end;


end.

