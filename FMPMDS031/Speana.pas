//============================================================================
//                       Speana ユニット Ver.0.11
//                      Copyright & Programmed by C60
//============================================================================
unit Speana;

interface

//{$DEFINE DEBUG}
//{$DEFINE USEFFT2}			// 高速 FFT を使用

{$IFDEF USEFFT2}
uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ShellAPI, MMSystem, FMPMDPlayDefine, LowLVPCM, ConvFreq, ExtCtrls, FFT2, PinForm;
{$ELSE}
uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ShellAPI, MMSystem, FMPMDPlayDefine, LowLVPCM, ConvFreq, ExtCtrls, FFT, PinForm;
{$ENDIF}

type
	TSpeanaLevel = (SPLow, SPMiddle, SPHigh, SPSuper, SPHyper);

const
	MaxSamples =  4096;		// Max 4096 サンプルで計算
	SPFreq     = 22050;		// 22050Hz に変換
	MaxBand    =   128;		// Max 128 バンド構成
	
	// バンド数
	Band : Array[0..Integer(SPHyper)] of Integer = (
				  8,   16,   32,   64,  128
	);
	
	// FFTサンプル数
	Samples : Array[0..Integer(SPHyper)] of Integer = (
				256,  512, 1024, 2048, 4096
	);
	
	// グラフの棒の幅
	GraphWidth : Array[0..Integer(SPHyper)] of Integer = (
				 32,   16,    8,    4,    2
	);
	
	// グラフ間の間隔
	GraphPitchBefore : Array[0..Integer(SPHyper)] of Integer = (
					3,    2,    1,    0,    0
	);

	// グラフ間の間隔
	GraphPitchAfter : Array[0..Integer(SPHyper)] of Integer = (
					3,    2,    1,    1,    1
	);


	// スペアナのバンドのスケール
	BandScale : Array[0..Integer(SPHyper), 0..MaxBand-1] of Integer = (
		// SPLow
			(
				   2,    3,    4,    6,   11,   21,   39,   73,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127,
				 127,  127,  127,  127,  127,  127,  127,  127
			),
		
		// SPMiddle
			(
				   2,    3,    4,    5,    7,    9,   12,   17,
				  23,   31,   42,   57,   78,  106,  145,  199,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255,
				 255,  255,  255,  255,  255,  255,  255,  255
			),
		
		// SPHigh
			(
				   3,    4,    5,    6,    7,    8,   10,   12,
				  14,   16,   19,   22,   25,   29,   34,   40,
				  47,   54,   63,   73,   85,   99,  115,  134,
				 155,  180,  209,  243,  282,  328,  380,  441,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511,
				 511,  511,  511,  511,  511,  511,  511,  511
			),
		
		// SPSuper
			(
				   6,    7,    8,    9,   10,   11,   12,   13,
				  14,   15,   16,   18,   19,   21,   22,   24,
				  26,   28,   30,   33,   36,   38,   42,   45,
				  49,   52,   57,   61,   66,   72,   77,   84,
				  90,   98,  105,  114,  123,  133,  144,  156,
				 168,  182,  196,  212,  229,  248,  268,  289,
				 313,  338,  365,  395,  427,  461,  499,  539,
				 582,  629,  680,  735,  794,  858,  928, 1003,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023,
				1023, 1023, 1023, 1023, 1023, 1023, 1023, 1023
			),
		
		// SPHyper
			(
				  12,   13,   14,   15,   16,   17,   18,   19,
				  20,   21,   22,   23,   24,   25,   26,   27,
				  28,   29,   30,   31,   33,   34,   35,   37,
				  38,   40,   41,   43,   45,   46,   48,   50,
				  52,   54,   56,   59,   61,   63,   66,   68,
				  71,   74,   77,   80,   83,   86,   90,   93,
				  97,  101,  105,  109,  113,  118,  123,  127,
				 132,  138,  143,  149,  155,  161,  167,  174,
				 181,  188,  195,  203,  211,  219,  228,  237,
				 246,  256,  266,  277,  288,  299,  311,  323,
				 336,  349,  363,  378,  393,  408,  424,  441,
				 459,  477,  496,  515,  536,  557,  579,  602,
				 626,  650,  676,  703,  731,  760,  790,  821,
				 854,  887,  923,  959,  997, 1036, 1078, 1120,
				1165, 1211, 1259, 1308, 1360, 1414, 1470, 1528,
				1589, 1652, 1717, 1785, 1856, 1929, 2005, 2085
			)
		);


type
	TSPThread = class(TThread)
	private
		{ Private 宣言 }
		FSect1 : TRTLCriticalSection;
		FLowLVPCM1 : TLowLVPCM;
		FHandle : HWND;
		FOwner : TComponent;
		FNumOfBand : TSpeanaLevel;
		FNumOfBandReceived : TSpeanaLevel;		// 変数受け入れ用
		FFullDraw : Boolean;
		FDecay : Double;
		FInterval : Integer;
		FUseHummingWindow : Boolean;
		ConvertFreq : TConvFreq;
		FFT : TFFT;
		HummngWindow : Array[0..MaxSamples-1] of Double;
		Prev2 : Array[0..MaxBand-1] of Double;
		Previ2 : Array[0..MaxBand-1] of Integer;
		DisplaySpeana : Boolean;						// スペアナ表示中は true
		procedure SetNumOfBand(Value : TSpeanaLevel);
		procedure SetFullDraw(Value : Boolean);
		procedure CalcHummingWindow(WindowSize : Integer);
	protected
		procedure Execute; override;
	public
		{ Public 宣言 }
		constructor Create(Owner : TComponent);
		destructor Destroy;	override;
		property FullDraw : Boolean read FFullDraw write SetFullDraw default True;
		property NumOfBand : TSpeanaLevel
				read FNumOfBandReceived write SetNumOfBand default SPHigh;
		property Decay : Double read FDecay write FDecay;
		property Interval : Integer read FInterval write FInterval default 20;
		property UseHummingWindow : boolean read FUseHummingWindow write FUseHummingWindow;
		procedure Start(LowLVPCM1 : TLowLVPCM);
		procedure Stop;
	end;


	TSPForm = class(TForm)
		PinForm1: TPinForm;
		procedure FormCreate(Sender: TObject);
		procedure FormHide(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure FormPaint(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
	private
		{ Private 宣言 }
		SPThread : TSPThread;
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		procedure SetNumOfBand(Value : TSpeanaLevel);
		function GetNumOfBand : TSpeanaLevel;
		procedure SetPriority(Value : TThreadPriority);
		function GetPriority : TThreadPriority;
		procedure SetDecay(Value : Double);
		function GetDecay : Double;
		procedure SetInterval(Value : Integer);
		function GetInterval : Integer;
		procedure SetHummingWindow(Value : Boolean);
		function GetHummingWindow : Boolean;
	public
		{ Public 宣言 }
		procedure Start(LowLVPCM1 : TLowLVPCM);
		procedure Stop;
		property NumOfBand : TSpeanaLevel read GetNumOfBand write SetNumOfBand
																															default SPHigh;
		property Priority : TThreadPriority read GetPriority write SetPriority
																															default tpNormal;
		property Decay : Double read GetDecay write SetDecay;
		property Interval : Integer read GetInterval write SetInterval default 20;
		property UseHummingWindow : boolean read GetHummingWindow write SetHummingWindow;
	end;

var
	SPForm: TSPForm;

implementation

uses Main;

{$R *.DFM}

//***************************************************************************
// コンストラクタ
//***************************************************************************
procedure TSPForm.FormCreate(Sender: TObject);
begin
	DragAcceptFiles(Handle, True);

	if not Assigned(SPThread) then begin
		SPThread := TSPThread.Create(Self);
	end;
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
procedure TSPForm.FormDestroy(Sender: TObject);
begin
	SPThread.Terminate;
	SPThread.WaitFor;
	SPThread.Free;
end;

//***************************************************************************
// フォームを閉じたときの処理
//***************************************************************************
procedure TSPForm.FormHide(Sender: TObject);
begin
	SPThread.Stop;
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure TSPForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
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
procedure TSPForm.DropFiles(var Msg:TWMDROPFILES);
begin
	FMPMDForm.DropFiles(Msg);
end;


//***************************************************************************
// フォームを開いたとき
//***************************************************************************
procedure TSPForm.FormActivate(Sender: TObject);
begin
	FMPMDForm.SpeanaMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure TSPForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	FMPMDForm.SpeanaMenu.Checked := False;
end;


//***************************************************************************
// サイズ変更
//***************************************************************************
procedure TSPForm.FormResize(Sender: TObject);
begin
	if Assigned(SPThread) then begin
		SPThread.FullDraw := True;
	end;
end;


//***************************************************************************
// フォーム再描画
//***************************************************************************
procedure TSPForm.FormPaint(Sender: TObject);
begin
	SPThread.FullDraw := True;
end;


//***************************************************************************
// レベルメーター開始
//***************************************************************************
procedure TSPForm.Start(LowLVPCM1 : TLowLVPCM);
begin
	FormResize(Self);
	Show;
	SPThread.FullDraw := True;
	SPThread.Start(LowLVPCM1);
end;


//***************************************************************************
// レベルメーター停止
//***************************************************************************
procedure TSPForm.Stop;
begin
	SPThread.Stop;
	Hide;
end;


//***************************************************************************
// NumOfBand 取得
//***************************************************************************
function TSPForm.GetNumOfBand : TSpeanaLevel;
begin
	Result := SPThread.NumOfBand;
end;


//***************************************************************************
// NumOfBand 設定
//***************************************************************************
procedure TSPForm.SetNumOfBand(Value : TSpeanaLevel);
begin
	SPThread.NumOfBand := Value;
end;


//***************************************************************************
// Priority 取得
//***************************************************************************
function TSPForm.GetPriority : TThreadPriority;
begin
	Result := SPThread.Priority;
end;

//***************************************************************************
// Priority 設定
//***************************************************************************
procedure TSPForm.Setpriority(Value : TThreadPriority);
begin
	SPThread.Priority := Value;
end;


//***************************************************************************
// Decay 取得
//***************************************************************************
function TSPForm.GetDecay : Double;
begin
	Result := SPThread.Decay;
end;

//***************************************************************************
// Decay 設定
//***************************************************************************
procedure TSPForm.SetDecay(Value : Double);
begin
	SPThread.Decay := Value;
end;


//***************************************************************************
// Interval 取得
//***************************************************************************
function TSPForm.GetInterval : Integer;
begin
	Result := SPThread.Interval;
end;


//***************************************************************************
// Interval 設定
//***************************************************************************
procedure TSPForm.SetInterval(Value : Integer);
begin
	SPThread.Interval := Value;
end;


//***************************************************************************
// Humming 窓を使っているかどうか取得
//***************************************************************************
function TSPForm.GetHummingWindow : Boolean;
begin
	Result := SPThread.UseHummingWindow;
end;


//***************************************************************************
// Humming 窓を使うかどうか設定
//***************************************************************************
procedure TSPForm.SetHummingWindow(Value : Boolean);
begin
	SPThread.UseHummingWindow := Value;
end;


//***************************************************************************
// スレッドコンストラクタ
//***************************************************************************
constructor TSPThread.Create(Owner : TComponent);
begin
	FOwner := Owner;
	FHandle := (Owner as TForm).Handle;
	ConvertFreq := TConvFreq.Create;
	FFT := TFFT.Create;
	FDecay := 0.95;
	FInterval := 20;
	FUseHummingWindow := False;
	FreeOnTerminate := False;
	DisplaySpeana := False;
	inherited Create(False);
	Priority := tpNormal;

	FNumOfBand := SPHigh;
	FNumOfBandReceived := SPHigh;

	CalcHummingWindow(Samples[Integer(FNumOfBand)]);

	// クリティカルセクションオブジェクトの作成
	InitializeCriticalSection(FSect1);

	FFullDraw := True;
end;


//***************************************************************************
// スレッドデストラクタ
//***************************************************************************
destructor TSPThread.Destroy;
begin
	ConvertFreq.Destroy;
	FFT.Destroy;

	// クリティカルセクションオブジェクトの破棄
	DeleteCriticalSection(FSect1);

	inherited Destroy;
end;


//***************************************************************************
// Humming Window の計算
//***************************************************************************
procedure TSPThread.CalcHummingWindow(WindowSize : Integer);
var
	i : Integer;
begin
	for i := 0 to WindowSize-1 do begin
		HummngWindow[i] := (0.54 - 0.46 * cos(2*PI*i/WindowSize));
	end;
end;


//***************************************************************************
// FullDwaw の設定
//***************************************************************************
procedure TSPThread.SetFullDraw(Value : Boolean);
begin
	EnterCriticalSection(FSect1);
	FFullDraw := True;
	LeaveCriticalSection(FSect1);
end;


//***************************************************************************
// スレッド実行部分
//***************************************************************************
procedure TSPThread.Execute;
var
	Buf : Array[0..MaxSamples-1] of TMonoral16bit;	// 最大 4096 サンプル(約0.2sec)
	x, y, v : Array[0..MaxSamples-1] of Double;		// FFT 実数部，虚数部，２乗和
{$IFDEF USEFFT2}
	energy, phi : Array[0..MaxSamples-1] of Double;	// ２乗和と位相
{$ENDIF}
	v2 : Array[0..MaxBand-1] of Double;						// スペアナの各 band の高さ
	vi2 : Array[0..MaxBand-1] of Integer;					// スペアナの各 band の高さ(画面上での値)
//	A : Double;
	MemSize, PreSize : Integer;
	DataSize : Integer;
	PreBuf : Pointer;
	wfxSrc,wfxDst : TWaveFormatEx;
	i, j : Integer;
	DC, MemDC : HDC;
	br : HBRUSH;
	BMP, MemBMP, OldBMP : HBitmap;
	Time1, Time4 : Integer;
{$IFDEF DEBUG}
	Time2, Time3 : Integer;
	Font, OldFont : HFont;
	p1: TLogFont;
{$ENDIF}
begin
	MemSize := 8192;					// 仮
	GetMem(PreBuf, MemSize);	// とりあえず確保しておく
	try
		while(Terminated = False) do begin
			Time1 := GetTickCount;

			if(FNumOfBand <> FNumOfBandReceived) then begin
				FNumOfBand := FNumOfBandReceived;
				CalcHummingWindow(Samples[Integer(FNumOfBand)]);

				for i := 0 to Band[Integer(FNumOfBand)]-1 do begin
					Prev2[i] := 0;
				end;

				FFullDraw := True;
			end;

			if(DisplaySpeana = True) then begin

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
					nChannels       := 1;
					nSamplesPerSec  := SPFreq;			// サンプリング周波数 22050 Hz に変換
					wBitsPerSample  := 16;
					nBlockAlign     := nChannels * wBitsPerSample div 8;
					nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
					cbSize          := 0;
				end;
				
				// スペアナにかけるサンプル数を計算
				PreSize := ConvertFreq.GetSize(wfxSrc, wfxDst, 
					SizeOf(TMonoral16bit) * Samples[Integer(FNumOfBand)], TCONVFREQ_SIZEF_SOURCE);

				if(PreSize <> MemSize) then begin		// 確保し直し
					FreeMem(PreBuf);
					GetMem(PreBuf, PreSize);
					MemSize := PreSize;
				end;

				DataSize := FLowLVPCM1.GetBufferData(PreBuf, PreSize);

				if(DataSize = PreSize) then Begin
					// データ数が十分ある場合
					FillChar(Buf[0], SizeOf(Buf), 0);
					ConvertFreq.Convert(wfxSrc, wfxDst, DataSize, PreBuf, @Buf[0],
																										TCONVFREQ_CONVF_NOTHING);

					if(FUseHummingWindow = True) then begin		// Humming 窓をかけるか？
						for i := 0 to Samples[Integer(FNumOfBand)]-1 do begin
							x[i] := buf[i] * HummngWindow[i];
							y[i] := 0.0;
						end;
					end else begin
						for i := 0 to Samples[Integer(FNumOfBand)]-1 do begin
							x[i] := buf[i];
							y[i] := 0.0;
						end;
					end;
					
					// FFT をかける
{$IFDEF USEFFT2}
					FFT.FFT(x, y, Energy, phi, Samples[Integer(FNumOfBand)]);
					{$ELSE}
					FFT.FFT(Samples[Integer(FNumOfBand)], x, y);
{$ENDIF}

{$IFDEF DEBUG}
					Time2 := GetTickCount;
{$ENDIF}
					
					// それぞれの band の高さを計算
					j := 0;
					for i := 0 to Band[Integer(FNumOfBand)]-1 do begin
						v2[i] := 0.0;
					end;

					for i := 1 to Samples[Integer(FNumOfBand)] div 2 - 1 do begin
	//					v[i] := x[i]*x[i] + y[i]*y[i];
						if(i = bandscale[Integer(FNumOfBand), j]) then begin
							if(j = 0) then begin
								v2[j] := v2[j] / (bandscale[Integer(FNumOfBand), j]);
							end else begin
								v2[j] := v2[j] / (bandscale[Integer(FNumOfBand), j]
										- bandscale[Integer(FNumOfBand), j-1]);
							end;
							Inc(j);
							if(j = Band[Integer(FNumOfBand)]) then Break;
						end;
						
{$IFDEF USEFFT2}
						v2[j] := v2[j] + energy[i];
						{$ELSE}
						v2[j] := v2[j] + x[i]*x[i] + y[i]*y[i];
{$ENDIF}
					end;
					
					// 対数スケールに変換
					for i := 0 to Band[Integer(FNumOfBand)]-1 do begin
{$IFDEF USEFFT2}
						v2[i] := ln(v2[i] / Samples[Integer(FNumOfBand)] / Samples[Integer(FNumOfBand)
								* Band[Integer(FNumOfBand)] / 4.0 + 1.00) * 10.0 - 60.0;
						{$ELSE}
						v2[i] := ln(v2[i] * Band[Integer(FNumOfBand)] / 4.0 + 1.00) * 10.0 - 60.0;
{$ENDIF}

					// 前回の値を減衰させたものと比較し、
					// 前回の値の方が高ければそちらを採用する
						if(v2[i] < Prev2[i] * FDecay) then begin
							v2[i] := Prev2[i] * FDecay;
						end;
					end;
				end else begin
					// データ数が足りない場合(演奏停止時など)：前回のデータを減衰させた値を採用
					for i := 0 to Band[Integer(FNumOfBand)]-1 do begin
						v2[i] := Prev2[i] * FDecay;
					end;
				end;

{$IFDEF DEBUG}
				Time3 := GetTickCount;
{$ENDIF}

				// 整数＆画面での高さに変換
				for i := 0 to Band[Integer(FNumOfBand)] - 1 do begin
					vi2[i] := (FOwner as TForm).ClientHeight - Round(v2[i]
							* (FOwner as TForm).ClientHeight / 148.0);
				end;

				// 画面描画
				if(FFullDraw = True) then begin
					// 全画面書き換え
					EnterCriticalSection(FSect1);

					// 前回の値を計算する(初めてなので前回の値がない)
					for i := 0 to Band[Integer(FNumOfBand)] - 1 do begin
						Previ2[i] :=  (FOwner as TForm).ClientHeight - Round(v2[i]
								* (FOwner as TForm).ClientHeight / 148.0);
					end;

					// グラフの棒を描画
					DC := GetDC(FHandle);
					MemDC := CreateCompatibleDC(DC);
					MemBmp := CreateCompatibleBitmap(DC, (FOwner as TForm).ClientWidth,
							(FOwner as TForm).ClientHeight);
					OldBMP := SelectObject(MemDC, MemBmp);

					br := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
					SelectObject(MemDC, br);
					Windows.FillRect(MemDC, RECT(0, 0, (FOwner as TForm).ClientWidth,
							(FOwner as TForm).ClientHeight), br);
					DeleteObject(br);

					br := CreateSolidbrush(GetSysColor(COLOR_ACTIVECAPTION));
					SelectObject(MemDC, br);

					for i := 0 to Band[Integer(FNumOfBand)]-1 do begin
						Windows.FillRect(MemDC,
							RECT((i*GraphWidth[Integer(FNumOfBand)]*(FOwner as TForm).ClientWidth div 256)
								+ GraphPitchBefore[Integer(FNumOfBand)], vi2[i],
							((i+1)*GraphWidth[Integer(FNumOfBand)]*(FOwner as TForm).ClientWidth div 256)
								- GraphPitchAfter[Integer(FNumOfBand)], (FOwner as TForm).ClientHeight), br
							);
					end;

					DeleteObject(br);

					BitBlt(DC, 0, 0, (FOwner as TForm).ClientWidth, (FOwner as TForm).ClientHeight, MemDC, 0, 0, SRCCOPY);
					SelectObject(MemDC, OldBMP);
					DeleteObject(MemBmp);
					DeleteDC(MemDC);
					ReleaseDC(FHandle, DC);

					FFullDraw := False;
					LeaveCriticalSection(FSect1);

				end else begin
					// 部分書き換え
					DC := GetDC(FHandle);
					br := CreateSolidBrush(GetSysColor(COLOR_BTNFACE));
					for i := 0 to Band[Integer(FNumOfBand)] - 1 do begin
						if(vi2[i] > Previ2[i]) then begin
							Windows.FillRect(DC,
								RECT(
									(i*GraphWidth[Integer(FNumOfBand)]*(FOwner as TForm).ClientWidth div 256)
										+ GraphPitchBefore[Integer(FNumOfBand)], vi2[i],
									((i+1)*GraphWidth[Integer(FNumOfBand)]*(FOwner as TForm).ClientWidth div 256)
										- GraphPitchAfter[Integer(FNumOfBand)], Previ2[i]), br
									);
						end;
					end;
					DeleteObject(br);

					br := CreateSolidbrush(GetSysColor(COLOR_ACTIVECAPTION));
					for i := 0 to Band[Integer(FNumOfBand)] - 1 do begin
						if(vi2[i] < Previ2[i]) then begin
							Windows.FillRect(DC,
								RECT(
									(i*GraphWidth[Integer(FNumOfBand)]*(FOwner as TForm).ClientWidth div 256)
										+ GraphPitchBefore[Integer(FNumOfBand)], Previ2[i],
									((i+1)*GraphWidth[Integer(FNumOfBand)]*(FOwner as TForm).ClientWidth div 256)
										- GraphPitchAfter[Integer(FNumOfBand)], vi2[i]), br
								);
						end;
					end;
					DeleteObject(br);

					ReleaseDC(FHandle, DC);
				end;

				for i := 0 to Band[Integer(FNumOfBand)]-1 do begin
					Prev2[i] := v2[i];
					Previ2[i] := vi2[i];
				end;
			end;

			Time4 := GetTickCount;
{$IFDEF DEBUG}
			DC := GetDC(FHandle);

			with p1 do begin
				lfHeight := 14;
				l(FOwner as TForm).ClientWidth := 0;
				lfEscapement := 0;
				lfOrientation := 0;
				lfWeight := FW_DONTCARE;
				lfItalic := 0;
				lfUnderline := 0;
				lfStrikeOut := 0;
				lfCharSet := ANSI_CHARSET;
				lfOutPrecision := OUT_TT_PRECIS;
				lfClipPrecision := CLIP_DEFAULT_PRECIS;
				lfQuality := PROOF_QUALITY;
				lfPitchAndFamily := DEFAULT_PITCH + 4;
				lfFaceName := 'Century';
			end;
			Font := CreateFontIndirect(p1);
			OldFont := SelectObject(DC, Font);

			Windows.Textout(DC,   0, 0, PChar(Format('%.5d', [Time2-Time1])), 5);
			Windows.Textout(DC,  50, 0, PChar(Format('%.5d', [Time3-Time2])), 5);
			Windows.Textout(DC, 100, 0, PChar(Format('%.5d', [Time4-Time3])), 5);

			SelectObject(DC, OldFont);
			DeleteObject(Font);
			ReleaseDC(FHandle, DC);
{$ENDIF}
			if(FInterval - (Time4 - Time1) > 0) then begin
				Sleep(FInterval - (Time4 - Time1));
			end;
		end;

	finally
		FreeMem(PreBuf);
	end;
end;


//***************************************************************************
// スペアナ表示開始
//***************************************************************************
procedure TSPThread.Start(LowLVPCM1 : TLowLVPCM);
var
	i : Integer;
begin
	FLowLVPCM1 := LowLVPCM1;
	for i := 0 to band[Integer(FNumOfBand)]-1 do begin
		Prev2[i] := 0.0;
		previ2[i] := 0;
	end;
	DisplaySpeana := True;

end;


//***************************************************************************
// スペアナ表示停止
//***************************************************************************
procedure TSPThread.Stop;
begin
	DisplaySpeana := False;
end;


//***************************************************************************
// NumOfBand設定
//***************************************************************************
procedure TSPThread.SetNumOfBand(Value : TSpeanaLevel);
begin
	FNumOfBandReceived := Value;
end;


end.



