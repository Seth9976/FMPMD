//=============================================================================
//								Music Driver Interface Class : IPCMMusicDriver
//                      Copyright & Programmed by C60
//============================================================================
unit PCMMusDriver;

interface

{$IFDEF VER90}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Delphi 2.0J
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uses
	OLE2, FMPMDDefine;

type

//=============================================================================
// IPCMMUSICDRIVER : 音源ドライバの基本的なインターフェイスを定義したクラス
//=============================================================================
	IPCMMUSICDRIVER = class(IUnknown)
	public
		function init(path : PChar) : Boolean; virtual; stdcall; abstract;
		function music_load(filename : PChar) : Integer; virtual; stdcall; abstract;
		function music_load2(musdata : Pointer; size : Integer) : Integer; virtual; stdcall; abstract;
		function getmusicfilename(dest : PChar): PChar; virtual; stdcall; abstract;
		procedure music_start; virtual; stdcall; abstract;
		procedure music_stop; virtual; stdcall; abstract;
		function getloopcount : Integer; virtual; stdcall; abstract;
		function getlength(filename : PChar; var length : Integer; var loop : Integer) : Boolean; virtual; stdcall; abstract;
		function getpos : Integer; virtual; stdcall; abstract;
		procedure setpos(pos : Integer); virtual; stdcall; abstract;
		procedure getpcmdata(buf : PSmallInt; nsamples : Integer); virtual; stdcall; abstract;
	end;


//=============================================================================
// IFMPMD : WinFMP, PMDWin に共通なインターフェイスを定義したクラス
//=============================================================================
	IFMPMD = class(IPCMMUSICDRIVER)
		function loadrhythmsample(path : PChar) : Boolean; virtual; stdcall; abstract;
		function setpcmdir(pcmdir : PChar) : Boolean; virtual; stdcall; abstract;
		procedure setpcmrate(rate : Integer); virtual; stdcall; abstract;
		procedure setppzrate(rate : Integer); virtual; stdcall; abstract;
		procedure setfmcalc55k(flag : Boolean); virtual; stdcall; abstract;
		procedure setppzinterpolation(ip : Boolean); virtual; stdcall; abstract;
		procedure setfmwait(nsec : Integer); virtual; stdcall; abstract;
		procedure setssgwait(nsec : Integer); virtual; stdcall; abstract;
		procedure setrhythmwait(nsec : Integer); virtual; stdcall; abstract;
		procedure setadpcmwait(nsec : Integer); virtual; stdcall; abstract;
		procedure fadeout(speed : Integer); virtual; stdcall; abstract;
		procedure fadeout2(speed : Integer); virtual; stdcall; abstract;
		function getlength2(filename : PChar; var length : Integer; var loop : Integer) : Boolean; virtual; stdcall; abstract;
		function getpos2 : Integer; virtual; stdcall; abstract;
		procedure setpos2(pos : Integer); virtual; stdcall; abstract;
		function getpcmfilename(dest : PChar) : PChar; virtual; stdcall; abstract;
		function getppzfilename(dest : PChar; bufnum : Integer) : PChar; virtual; stdcall; abstract;
	end;


{$ELSE}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Delphi3 以降
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

uses
	ActiveX, FMPMDDefine;


type
//=============================================================================
// IPCMMUSICDRIVER : 音源ドライバの基本的なインターフェイスを定義したクラス
//=============================================================================
	IPCMMUSICDRIVER = interface(IUnknown)
  	['{9D4D6317-F40A-455E-9E2C-CB517556BA02}']
		function init(path : PChar) : Boolean; stdcall;
		function music_load(filename : PChar) : Integer; stdcall;
		function music_load2(musdata : Pointer; size : Integer) : Integer; stdcall;
		function getmusicfilename(dest : PChar): PChar; stdcall;
		procedure music_start; stdcall;
		procedure music_stop; stdcall;
		function getloopcount : Integer; stdcall;
		function getlength(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
		function getpos : Integer; stdcall;
		procedure setpos(pos : Integer); stdcall;
		procedure getpcmdata(buf : PSmallInt; nsamples : Integer); stdcall;
	end;



//=============================================================================
// IFMPMD : WinFMP, PMDWin に共通なインターフェイスを定義したクラス
//=============================================================================
	IFMPMD = interface(IPCMMUSICDRIVER)
  	['{81977D60-9496-4F20-A3BB-19B19943DA6D}']
		function loadrhythmsample(path : PChar) : Boolean; stdcall;
		function setpcmdir(pcmdir : PChar) : Boolean; stdcall;
		procedure setpcmrate(rate : Integer); stdcall;
		procedure setppzrate(rate : Integer); stdcall;
		procedure setfmcalc55k(flag : Boolean); stdcall;
		procedure setppzinterpolation(ip : Boolean); stdcall;
		procedure setfmwait(nsec : Integer); stdcall;
		procedure setssgwait(nsec : Integer); stdcall;
		procedure setrhythmwait(nsec : Integer); stdcall;
		procedure setadpcmwait(nsec : Integer); stdcall;
		procedure fadeout(speed : Integer); stdcall;
		procedure fadeout2(speed : Integer); stdcall;
		function getlength2(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
		function getpos2 : Integer; stdcall;
		procedure setpos2(pos : Integer); stdcall;
		function getpcmfilename(dest : PChar) : PChar; stdcall;
		function getppzfilename(dest : PChar; bufnum : Integer) : PChar; stdcall;
	end;

{$ENDIF}



//=============================================================================
// Interface ID(IID)
//=============================================================================
const
	// GUID of IPCMMUSICDRIVER Interface ID
	IID_IPCMMUSICDRIVER : TIID =
		(D1:$9D4D6317; D2:$F40A; D3:$455E; D4:($9E,$2C,$CB,$51,$75,$56,$BA,$02));

// GUID of IFMPMD Interface ID
	IID_IFMPMD : TIID =
		(D1:$81977D60; D2:$9496; D3:$4F20; D4:($A3,$BB,$19,$B1,$99,$43,$DA,$6D));


implementation

end.
