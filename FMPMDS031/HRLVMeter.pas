//============================================================================
//                       HRLVMeter ユニット Ver.0.11
//                      Copyright & Programmed by C60
//============================================================================


unit HRLVMeter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, StdCtrls, CommCtrl, ComCtrls, ShellAPI, MMSystem, PinForm,
	ConvFreq, LowLVPCM, FMPMDPlayDefine;

type
	TLvMeterRectArray = Array[0..1] of TRect;

const
	Samples = 50; 			// 50サンプルで計算
	CInterval = 20;			// 20msec の分解能
  CGensui1 = 15;			// 減衰率(分子）
	CGensui2 = 16; 			// 減衰率(分母）
  Log_v2_Max = 1024;	// Log 変換後の最大値
	NumOfLogScale = 32;			// レベルメーター → log 変換テーブルの要素数

  BaseLvMeterRect : TLvMeterRectArray = (			 			// LvMeter のオリジナルの位置
  	(Left : 15; Top :  5; Right : 300; Bottom : 16),
    (Left : 15; Top : 24; Right : 300; Bottom : 35)
  );

  BaseLabelRect : TLvMeterRectArray = (			 				// Label のオリジナルの位置
  	(Left : 3; Top :  3; Right : 10; Bottom : 17),
    (Left : 2; Top : 22; Right : 11; Bottom : 36)
  );

  BaseLabelHeight = 15;

  BaseWindowClientRect : TRect = (			 						// ClientRect のオリジナルのサイズ
  	Left : 0; Top : 0; Right : 304; Bottom : 39
	);

	LogScale : Array[0..NumOfLogScale - 1] of Integer = (
			  128,   150,   175,   205,   239,   280,   327,   383,
			  448,   524,   612,   716,   837,   979,   1145, 1339,
			 1566,  1831,  2142,  2505,  2929,  3425,  4005,  4684,
			 5478,  6406,  7491,  8760, 10245, 11980, 14010, 16384
  );

type
	THRLVThread = class(TThread)
	private
		{ Private 宣言 }
		FLowLVPCM1 : TLowLVPCM;
    FGensui1 : Integer;		// 減衰率(分子）
		FGensui2 : Integer;		// 減衰率(分母）
    FInterval : Integer;
    FOwnerForm : TForm;		// 描画フォーム
		FFullDraw : Boolean;														// 画面再描画フラグ
		FLvMeterFullDraw : Array[0..1] of Boolean;      // レベルメーター再描画フラグ
    FPreviousNumOfBlock : Array[0..1] of Integer;		// 前回描画したブロック数
    DisplayMeter : Boolean;
		ConvertFreq : TConvFreq;
    old : Array[0..1] of Integer;
	protected
		{ Protected 宣言 }
		procedure Execute; override;
    procedure LvMeter_Draw(Part : Integer; OrgLvMeterRect : TRect; v2 : Integer);
    procedure LVMeter_DrawClient;
		procedure LvMeter_DrawBackGround(DC : HDC; LvMeterRect : TRect);
		procedure LVMeter_DrawMeterFull(DC : HDC; Part : Integer; LvMeterRect : TRect; v2 : Integer);
		procedure LVMeter_DrawMeterPart(DC : HDC; Part : Integer; LvMeterRect : TRect; v2 : Integer);
    function LVMeter_CalcBlockWidth(LvMeterRect : TRect) : Integer;
	public
		{ Public 宣言 }
		constructor Create(Owner : TForm);
		destructor Destroy;	override;
    property Gensui1 : Integer read FGensui1 write FGensui1 default CGensui1;
    property Gensui2 : Integer read FGensui2 write FGensui2 default CGensui2;
    property Interval : Integer read FInterval write FInterval default CInterval;
    property FullDraw : BOolean read FFullDraw write FFullDraw;
		procedure Start(LowLVPCM1 : TLowLVPCM);
		procedure Stop;
	end;


	THRLVMeterForm = class(TForm)
		PinForm1: TPinForm;
		procedure FormCreate(Sender: TObject);
		procedure FormHide(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private 宣言 }
		HRLVThread : THRLVThread;
  protected
		{ Protected 宣言 }
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		procedure SetPriority(Value : TThreadPriority);
		function GetPriority : TThreadPriority;
		procedure SetGensui1(Value : Integer);
		procedure SetGensui2(Value : Integer);
		function GetGensui1 : Integer;
		function GetGensui2 : Integer;
    procedure SetInterval(Value : Integer);
		function GetInterval : Integer;
	public
    { Public 宣言 }
    procedure Start(LowLVPCM1 : TLowLVPCM);
    procedure Stop;
		property Priority : TThreadPriority read GetPriority write SetPriority
																															default tpNormal;
    property Gensui1 : Integer read GetGensui1 write SetGensui1 default CGensui1;
    property Gensui2 : Integer read GetGensui2 write SetGensui2 default CGensui2;
    property Interval : Integer read GetInterval write SetInterval default 20;

	end;

var
	HRLVMeterForm: THRLVMeterForm;

implementation

uses Main;


{$R *.DFM}


//###########################################################################
//###########################################################################
// THRLVMeterForm クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// コンストラクタ
//***************************************************************************
procedure THRLVMeterForm.FormCreate(Sender: TObject);
begin
	HRLVThread := THRLVThread.Create(Self);
	DragAcceptFiles(Handle, True);
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
procedure THRLVMeterForm.FormDestroy(Sender: TObject);
begin
	HRLVThread.Terminate;
	HRLVThread.WaitFor;
	HRLVThread.Free;
end;


//***************************************************************************
// フォームを閉じたときの処理
//***************************************************************************
procedure THRLVMeterForm.FormHide(Sender: TObject);
begin
	HRLVThread.Stop;
end;


//***************************************************************************
// フォーム再描画
//***************************************************************************
procedure THRLVMeterForm.FormPaint(Sender: TObject);
begin
	if Assigned(HRLVThread) then begin
  	HRLVThread.FullDraw := True;
	end;
end;


//***************************************************************************
// サイズ変更
//***************************************************************************
procedure THRLVMeterForm.FormResize(Sender: TObject);
begin
	if Assigned(HRLVThread) then begin
    HRLVThread.FullDraw := True;
	end;
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure THRLVMeterForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
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
procedure THRLVMeterForm.DropFiles(var Msg:TWMDROPFILES);
begin
	FMPMDForm.DropFiles(Msg);
end;


//***************************************************************************
// フォームを開いたとき
//***************************************************************************
procedure THRLVMeterForm.FormActivate(Sender: TObject);
begin
	FMPMDForm.LevelMeterMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure THRLVMeterForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
	FMPMDForm.LevelMeterMenu.Checked := False;
end;


//***************************************************************************
// レベルメーター開始
//***************************************************************************
procedure THRLVMeterForm.Start(LowLVPCM1 : TLowLVPCM);
begin
	HRLVThread.Start(LowLVPCM1);
  Show;
end;


//***************************************************************************
// レベルメーター停止
//***************************************************************************
procedure THRLVMeterForm.Stop;
begin
	HRLVThread.Stop;
  Hide;
end;


//***************************************************************************
// Priority 取得
//***************************************************************************
function THRLVMeterForm.GetPriority : TThreadPriority;
begin
	Result := HRLVThread.Priority;
end;


//***************************************************************************
// Priority 設定
//***************************************************************************
procedure THRLVMeterForm.Setpriority(Value : TThreadPriority);
begin
	HRLVThread.Priority := Value;
end;


//***************************************************************************
// Gensui1 取得
//***************************************************************************
function THRLVMeterForm.GetGensui1 : Integer;
begin
	Result := HRLVThread.Gensui1;
end;


//***************************************************************************
// Gensui2 取得
//***************************************************************************
function THRLVMeterForm.GetGensui2 : Integer;
begin
	Result := HRLVThread.Gensui2;
end;


//***************************************************************************
// Gensui1 設定
//***************************************************************************
procedure THRLVMeterForm.SetGensui1(Value : Integer);
begin
	HRLVThread.Gensui1 := Value;
end;


//***************************************************************************
// Gensui2 設定
//***************************************************************************
procedure THRLVMeterForm.SetGensui2(Value : Integer);
begin
	HRLVThread.Gensui2 := Value;
end;


//***************************************************************************
// Interval 取得
//***************************************************************************
function THRLVMeterForm.GetInterval : Integer;
begin
	Result := HRLVThread.Interval;
end;


//***************************************************************************
// Interval 設定
//***************************************************************************
procedure THRLVMeterForm.SetInterval(Value : Integer);
begin
	HRLVThread.Interval := Value;
end;



//###########################################################################
//###########################################################################
// THRLVThread クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// スレッドコンストラクタ
//***************************************************************************
constructor THRLVThread.Create(Owner : TForm);
begin
	FOwnerForm := Owner;
	ConvertFreq := TConvFreq.Create;
  FGensui1 := CGensui1;
  FGensui2 := CGensui2;
  FInterval := CInterval;
	FreeOnTerminate := False;
	DisplayMeter := False;
  FPreviousNumOfBlock[0] := 0;
  FPreviousNumOfBlock[1] := 0;
	old[0] := 0;
	old[1] := 0;

	inherited Create(False);

	Priority := tpNormal;
	FFullDraw := True;
  FLvMeterFullDraw[0] := True;
  FLvMeterFullDraw[1] := True;
end;


//***************************************************************************
// スレッドデストラクタ
//***************************************************************************
destructor THRLVThread.Destroy;
begin
	ConvertFreq.Destroy;
	inherited Destroy;
end;


//***************************************************************************
// スレッド実行部分
//***************************************************************************
procedure THRLVThread.Execute;
var
	Buf : Array[0..Samples-1] of TStereo16bit;	// 50 サンプル(0.05sec)
	MemSize, PreSize : Integer;
	PreBuf : Pointer;
  wfxSrc,wfxDst : TWaveFormatEx;
  v : Array[0..1] of Integer;						// 左右のレベルメーターの触れ幅
  v2 : Array[0..1] of Integer;          // 左右のレベルメーターの触れ幅(対数)
	i, j : Integer;
  Time1, Time2 : Integer;
begin
  MemSize := 8192;					// 仮
	GetMem(PreBuf, MemSize);	// とりあえず確保しておく

	try
		while(Terminated = False) do begin
			Time1 := GetTickCount;
			if(DisplayMeter = True) then begin
				with wfxSrc do begin
					wFormatTag      :=WAVE_FORMAT_PCM;
			    nChannels       := FLowLVPCM1.nChannels;
			    nSamplesPerSec  := FLowLVPCM1.nSamplesPerSec;
			    wBitsPerSample  := FLowLVPCM1.wBitsPerSample;
			    nBlockAlign     := nChannels * wBitsPerSample div 8;
					nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
					cbSize          := 0;
			  end;

				with wfxDst do begin
					wFormatTag      :=WAVE_FORMAT_PCM;
			    nChannels       := 2;
			    nSamplesPerSec  := Samples * FInterval;
			    		// サンプリング周波数 1000 Hz に変換
			    wBitsPerSample  := 16;
			    nBlockAlign     := nChannels * wBitsPerSample div 8;
					nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
					cbSize          := 0;
			  end;

				PreSize := ConvertFreq.GetSize(wfxSrc, wfxDst, SizeOf(Buf),
			  																									TCONVFREQ_SIZEF_SOURCE);

	      if(PreSize <> MemSize) then begin		// 確保し直し
	      	FreeMem(PreBuf);
					GetMem(PreBuf, PreSize);
          MemSize := PreSize;
				end;

				if(FLowLVPCM1.GetBufferData(PreBuf, PreSize) = PreSize) then begin
			  	ConvertFreq.Convert(wfxSrc, wfxDst, PreSize, PreBuf, @Buf[0],
																												TCONVFREQ_CONVF_NOTHING);

          v[0] := 0;
          v[1] := 0;

          for i := 0 to Samples-1 do begin
				   	Inc(v[0], Abs(Buf[i].Left));
				 	  Inc(v[1], Abs(Buf[i].Right));
				  end;
			  end else begin
          v[0] := 0;
          v[1] := 0;
			  end;

        if(FFullDraw = True) then begin		// 背景再描画
        	FFullDraw := False;
        	FLvMeterFullDraw[0] := True;
        	FLvMeterFullDraw[1] := True;
          LVMeter_DrawClient;
        end;

        for j := 0 to 1 do begin
					v[j] := v[j] div Samples;		// v[j] < 32768;

				  // 対数変換(32段階)
          v2[j] := NumOfLogScale - 1;

				  for i := 0 to NumOfLogScale - 1 do begin
						if(LogScale[i] >= v[j]) then begin
              v2[j] := i;
			    	  break;
				    end;
				  end;

					v2[j] := v2[j] * Log_v2_max div NumOfLogScale;			//		v2[j] < Log_v2_max(=1024)
					old[j] := old[j] * Gensui1 div Gensui2;

	        if(v2[j] < old[j]) then begin
  	       	LvMeter_Draw(j, BaseLvMeterRect[j], old[j]);
					end else begin
      	   	LvMeter_Draw(j, BaseLvMeterRect[j], v2[j]);
						old[j] := v2[j];
					end;
        end;
      end;

			Time2 := GetTickCount;
		  if(FInterval - (Time2 - Time1) > 0) then begin
				Sleep(FInterval - (Time2 - Time1));
			end;
		end;

	finally
		FreeMem(PreBuf);
	end;
end;


//***************************************************************************
// レベルメーター描画(Full)
//***************************************************************************
procedure THRLVThread.LVMeter_DrawClient;
var
  DC : HDC;
	br, Oldbr : HBRUSH;
	Font, OldFont : HFont;
	p1: TLogFont;
begin
  DC := GetDC(FOwnerForm.Handle);
	try
	// クライアント領域全体を塗りつぶす
	br := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
  Oldbr := SelectObject(DC, br);
  Windows.FillRect(DC, FOwnerForm.ClientRect, br);
  SelectObject(DC, Oldbr);
  DeleteObject(br);

  // 文字描画
	with p1 do begin
		lfHeight := BaseLabelHeight * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom;
		lfWidth := 0;
		lfEscapement := 0;
		lfOrientation := 0;
		lfWeight := FW_NORMAL;
		lfItalic := 0;
		lfUnderline := 0;
		lfStrikeOut := 0;
		lfCharSet := ANSI_CHARSET;
		lfOutPrecision := OUT_DEVICE_PRECIS;
		lfClipPrecision := CLIP_DEFAULT_PRECIS;
		lfQuality := DEFAULT_QUALITY;
		lfPitchAndFamily := FIXED_PITCH or FF_MODERN;
		lfFaceName := 'ＭＳ Ｐゴシック';
	end;
	Font := CreateFontIndirect(p1);
	OldFont := SelectObject(DC, Font);
  SetTextColor(DC, GetSysColor(COLOR_BTNTEXT));
	SetBkColor(DC, GetSysColor(COLOR_BTNFACE));

	Windows.Textout(DC,
  	BaseLabelRect[0].Left * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom,
    BaseLabelRect[0].Top  * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom,
    'L', 1
  );

	Windows.Textout(DC,
  	BaseLabelRect[1].Left * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom,
    BaseLabelRect[1].Top  * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom,
    'R', 1
  );
	SelectObject(DC, OldFont);

  finally
  	ReleaseDC(FOwnerForm.Handle, DC);
  end;

end;

//***************************************************************************
// レベルメーター描画
//***************************************************************************
procedure THRLVThread.LvMeter_Draw(Part : Integer; OrgLvMeterRect : TRect; v2 : Integer);
var
	LvMeterRect : TRect;
  DC : HDC;
begin
	LvMeterRect.Left   := OrgLvMeterRect.Left   * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom;
	LvMeterRect.Top    := OrgLvMeterRect.Top    * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom;
	LvMeterRect.Right  := FOwnerForm.ClientWidth - (BaseWindowClientRect.Right - OrgLvMeterRect.Right)
  																						* FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom;
	LvMeterRect.Bottom := OrgLvMeterRect.Bottom * FOwnerForm.ClientHeight div BaseWindowClientRect.Bottom;

  DC := GetDC(FOwnerForm.Handle);
  try
		if(FLvMeterFullDraw[Part] = True) then begin
  	  // レベルメーター背景を描画
  		LVMeter_DrawBackGround(DC, LvMeterRect);

		  // レベルメーター本体を描画(Full)
  		LVMeter_DrawMeterFull(DC, Part, LvMeterRect, v2);

			FLvMeterFullDraw[Part] := False;
  	end else begin
	  	// レベルメーター本体を描画(差分)
	  	LVMeter_DrawMeterPart(DC, Part, LvMeterRect, v2);
  	end;
  finally
  	ReleaseDC(FOwnerForm.Handle, DC);
  end;
end;


//***************************************************************************
// レベルメーター背景描画
//***************************************************************************
procedure THRLVThread.LvMeter_DrawBackGround(DC : HDC; LvMeterRect : TRect);
var
	br, Oldbr : HBRUSH;
  pen, Oldpen : HPEN;
begin
	// 背景を塗りつぶす
	br := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));

  Oldbr := SelectObject(DC, br);
  Windows.FillRect(DC, LvMeterRect, br);
  SelectObject(DC, Oldbr);
  DeleteObject(br);

	// ふちを描画
	pen := CreatePen(PS_SOLID, 1, GetSysColor(COLOR_3DSHADOW));
  Oldpen := SelectObject(DC, pen);
  MoveToEx(DC, LvMeterRect.Left, LvMeterRect.Top, Nil);
  LineTo(DC, LvMeterRect.Left, LvMeterRect.Bottom - 1);
  MoveToEx(DC, LvMeterRect.Left, LvMeterRect.Top, Nil);
  LineTo(DC, LvMeterRect.Right - 1, LvMeterRect.Top);
  SelectObject(DC, Oldpen);
  DeleteObject(pen);

	pen := CreatePen(PS_SOLID, 1, GetSysColor(COLOR_3DHILIGHT));
  Oldpen := SelectObject(DC, pen);
  MoveToEx(DC, LvMeterRect.Left, LvMeterRect.Bottom - 1, Nil);
  LineTo(DC, LvMeterRect.Right, LvMeterRect.Bottom - 1);
  MoveToEx(DC, LvMeterRect.Right - 1, LvMeterRect.Top, Nil);
  LineTo(DC, LvMeterRect.Right - 1, LvMeterRect.Bottom);

  SelectObject(DC, Oldpen);
  DeleteObject(pen);
end;


//****************************************************************************
//	ブロックの幅を計算
//****************************************************************************
function THRLVThread.LVMeter_CalcBlockWidth(LvMeterRect : TRect) : Integer;
begin
	if((LvMeterRect.Bottom - LvMeterRect.Top) * 2 div 3 < LvMeterRect.Right - LvMeterRect.Left) then begin
  	Result := (LvMeterRect.Bottom - LvMeterRect.Top) * 2 div 3;
  end else begin
  	Result := LvMeterRect.Right - LvMeterRect.Left;
  end;

  if(Result < 3) then begin
  	Result := 3;
  end;
end;


//***************************************************************************
// レベルメーター描画(Full)
//***************************************************************************
procedure THRLVThread.LVMeter_DrawMeterFull(DC : HDC; Part : Integer; LvMeterRect : TRect; v2 : Integer);
var
	LvMeterPosition : Integer;		// グラフィック座標での描画位置(ドット単位)
	BlockWidth : Integer;				// Block の幅
  NumOfBlock : Integer;       // 描画ブロック数
  BlockRect : TRect;					// ブロックの四角の範囲
	i : Integer;
	br, Oldbr : HBRUSH;
begin
	// 周りを１ドット小さくする
	LvMeterRect.Left   := LvMeterRect.Left   + 1;
	LvMeterRect.Right  := LvMeterRect.Right  - 1;
	LvMeterRect.Top    := LvMeterRect.Top    + 1;
	LvMeterRect.Bottom := LvMeterRect.Bottom - 1;

	LvMeterPosition := (LvMeterRect.Right * v2 + LvMeterRect.Left * (Log_v2_max - v2)) div Log_v2_max;

	BlockWidth := LVMeter_CalcBlockWidth(LvMeterRect);

  // ブロックを何個描くか計算(切り捨て)
  if(v2 = Log_v2_max) then begin
  	// 全部書く(切り上げ)
  	NumOfBlock := (LvMeterRect.Right - LvMeterRect.Left + BlockWidth - 1) div BlockWidth;
  end else begin
  	NumOfBlock := (LvMeterPosition - LvMeterRect.Left) div BlockWidth;
  end;

  BlockRect.Top := LvMeterRect.Top + 1;
  BlockRect.Bottom := LvMeterRect.Bottom - 1;

	// ブロックを描画する
	br := CreateSolidBrush(GetSysColor(COLOR_ACTIVECAPTION));
  Oldbr := SelectObject(DC, br);

  for i := 0 to NumOfBlock - 1 do begin
    BlockRect.Left := LvMeterRect.Left + i * BlockWidth + 1;
    BlockRect.Right := LvMeterRect.Left + (i + 1) * BlockWidth - 1;
    Windows.FillRect(DC, BlockRect, br);
  end;

  SelectObject(DC, Oldbr);
  DeleteObject(br);

  FPreviousNumOfBlock[Part] := NumOfBlock;
end;


//***************************************************************************
// レベルメーター描画(差分)
//***************************************************************************
procedure THRLVThread.LVMeter_DrawMeterPart(DC : HDC; Part : Integer; LvMeterRect : TRect; v2 : Integer);
var
	LvMeterPosition : Integer;		// グラフィック座標での描画位置(ドット単位)
	BlockWidth : Integer;				// Block の幅
  NumOfBlock : Integer;       // 描画ブロック数
  BlockRect : TRect;					// ブロックの四角の範囲
	i : Integer;
	br, Oldbr : HBRUSH;
begin
	// 周りを１ドット小さくする
	LvMeterRect.Left   := LvMeterRect.Left   + 1;
	LvMeterRect.Right  := LvMeterRect.Right  - 1;
	LvMeterRect.Top    := LvMeterRect.Top    + 1;
	LvMeterRect.Bottom := LvMeterRect.Bottom - 1;

	LvMeterPosition := (LvMeterRect.Right * v2 + LvMeterRect.Left * (Log_v2_max - v2)) div Log_v2_max;

	BlockWidth := LVMeter_CalcBlockWidth(LvMeterRect);

  // ブロックを何個描くか計算(切り捨て)
  if(v2 = Log_v2_max) then begin
  	// 全部書く(切り上げ)
  	NumOfBlock := (LvMeterRect.Right - LvMeterRect.Left + BlockWidth - 1) div BlockWidth;
  end else begin
  	NumOfBlock := (LvMeterPosition - LvMeterRect.Left) div BlockWidth;
  end;

  BlockRect.Top := LvMeterRect.Top + 1;
  BlockRect.Bottom := LvMeterRect.Bottom - 1;

	// ブロックを描画する
  if(FPreviousNumOfBlock[Part] < NumOfBlock) then begin							// 前より増えた
		br := CreateSolidBrush(GetSysColor(COLOR_ACTIVECAPTION));
  	Oldbr := SelectObject(DC, br);
	  for i := FPreviousNumOfBlock[Part] to NumOfBlock - 1 do begin
  	  BlockRect.Left := LvMeterRect.Left + i * BlockWidth + 1;
    	BlockRect.Right := LvMeterRect.Left + (i + 1) * BlockWidth - 1;
	    Windows.FillRect(DC, BlockRect, br);
  	end;
	  SelectObject(DC, Oldbr);
  	DeleteObject(br);
  end else if(NumOfBlock < FPreviousNumOfBlock[Part]) then begin		// 前より減った
		br := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
  	Oldbr := SelectObject(DC, br);
	  for i := FPreviousNumOfBlock[Part]-1 downto NumOfBlock do begin
  	  BlockRect.Left := LvMeterRect.Left + i * BlockWidth + 1;
    	BlockRect.Right := LvMeterRect.Left + (i + 1) * BlockWidth - 1;
	    Windows.FillRect(DC, BlockRect, br);
  	end;
	  SelectObject(DC, Oldbr);
  	DeleteObject(br);
  end;

  FPreviousNumOfBlock[Part] := NumOfBlock;
end;


//***************************************************************************
// レベルメーター表示開始
//***************************************************************************
procedure THRLVThread.Start(LowLVPCM1 : TLowLVPCM);
begin
	FLowLVPCM1 := LowLVPCM1;
	old[0] := 0;
	old[1] := 0;
	LvMeter_Draw(0, BaseLvMeterRect[0], 0);
	LvMeter_Draw(0, BaseLvMeterRect[1], 0);
	DisplayMeter := True;
end;


//***************************************************************************
// レベルメーター表示停止
//***************************************************************************
procedure THRLVThread.Stop;
begin
	DisplayMeter := False;
	old[0] := 0;
	old[1] := 0;
end;


end.

