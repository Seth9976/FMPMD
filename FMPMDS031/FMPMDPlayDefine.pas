//============================================================================
//                          FMPMD 全体の定数定義
//                      Copyright & Programmed by C60
//============================================================================
unit FMPMDPlayDefine;

interface

uses
  Messages;
  
const
	FMPMD_Version           = 031;		// FMPMD の Version

	PlayListExt = '.m3u';							// PlayList の拡張子(半角小文字)


  // フォント名
  STR_98GRAPHICS = '98Graphics';
  STR_98LINE     = '98罫線';

	// システムで使う PlayList のファイル名
	PlayListFileName = 'PlayList.m3u';

	// フィルタの設定
	NumOfFilter = 12;
	FilterStr : array[0..NumOfFilter * 2 -1] of String = (
		'すべての曲ﾌｧｲﾙ(*.opi,*.ovi,*.ozi,*.m,*.m2,*.mz,*.mp,*.ms,*.m3u)',
													'*.opi;*.ovi;*.ozi;*.m;*.m2;*.mz;*.mp;*.ms;*.m3u',
		'PlayListﾌｧｲﾙ(*.m3u)',								'*.m3u',
		'FMP曲ﾌｧｲﾙ(*.opi,*.ovi,*.ozi)', 			'*.opi;*.ovi;*.ozi',
		'PMD曲ﾌｧｲﾙ(*.m,*.m2,*.mz,*.mp,*.ms)', '*.m;*.m2;*.mz;*.mp;*.ms',
		'FMP(OPN)曲ﾌｧｲﾙ(*.opi)',							'*.opi',
		'FMP(OPNA)曲ﾌｧｲﾙ(*.ovi)',							'*.ovi',
		'FMP(PPZ)曲ﾌｧｲﾙ(*.ozi)',							'*.ozi',
		'PMD(OPN)曲ﾌｧｲﾙ(*.m)',								'*.m',
		'PMD(OPNA)曲ﾌｧｲﾙ(*.m2)',							'*.m2',
		'PMD(PPZ)曲ﾌｧｲﾙ(*.mz)',								'*.mz',
		'PMD(PPS)曲ﾌｧｲﾙ(*.mp,*.ms)',					'*.mp;*.ms',
		'すべてのﾌｧｲﾙ(*.*)',									'*.*'
	);

	PLAY_STOP_AFTER_MUSIC_STOP = 3000;	// 曲が終わってから演奏を止めるまでの時間(ms)
	PREV_MUSIC_PLAY = 500;	// Prev ボタンを押した時に前の曲を演奏する時間の範囲(ms)
	DLGFILENAME_BUF = 8192;	// GetOpenFileName 用 buffer

	// エラーメッセージ
  MSG_ERR_LISTINDEX						= 'リストのインデックスが範囲を超えています';
	MSG_ERROR_COMMANDLINE       = 'コマンドライン文字列が不正です';
	MSG_ERROR_SET_PCMDIR        = 'PCMディレクトリを設定できませんでした';
	MSG_ERROR_OPEN_FMPMDDATA    = '曲データを開けませんでした';
	MSG_ERROR_NOT_FMPMDDATA     = 'FMP または PMD の曲データではありません';
	MSG_ERROR_NOT_READ_PPCDATA  = ' を読み込めませんでした';
	MSG_ERROR_NOT_READ_P86DATA  = ' を読み込めませんでした';
	MSG_ERROR_NOT_READ_PPSDATA  = ' を読み込めませんでした';
	MSG_ERROR_NOT_READ_PPZ1DATA = ' を読み込めませんでした';
	MSG_ERROR_NOT_READ_PPZ2DATA = ' を読み込めませんでした';
	MSG_ERROR_NOT_READ_RHYTHM   = 'リズム音の wave を読み込めませんでした';

	MSG_WARNING_ALREADY_READ_PPCDATA  = ' はすでに読み込まれています';
	MSG_WARNING_ALREADY_READ_P86DATA  = ' はすでに読み込まれています';
	MSG_WARNING_ALREADY_READ_PPSDATA  = ' はすでに読み込まれています';
	MSG_WARNING_ALREADY_READ_PPZ1DATA = ' はすでに読み込まれています';
	MSG_WARNING_ALREADY_READ_PPZ2DATA = ' はすでに読み込まれています';

	MSG_ERROR_NOT_PPCDATA       = ' の形式が異なっています';
	MSG_ERROR_NOT_P86DATA       = ' の形式が異なっています';
	MSG_ERROR_NOT_PPSDATA       = ' の形式が異なっています';
	MSG_ERROR_NOT_PPZ1DATA      = ' の形式が異なっています';
	MSG_ERROR_NOT_PPZ2DATA      = ' の形式が異なっています';

	MSG_ERROR_OUT_OF_MEMORY     = 'メモリが足りません';
	MSG_ERROR_OTHER							= 'その他のエラーです';

	MSG_ERROR_NOT_OPEN_SAVEFILE = ' をオープンできません';
	MSG_ANNOUNCE_READ_FMPMDDATA = '曲データを読み込んでください';
	MSG_ANNOUNCE_CHANGE_RHYTHMDIR = 'リズム音源のwaveのディレクトリを変更しました'
						+#13#10+'変更を有効にするにはFMPMD を再起動する必要があります';


  // PopUpMenu のメッセージ
	MSG_POPUP_MINIMIZE          = '最小化(&M)';
  MSG_POPUP_RESTORE						= '元のサイズに戻す(&V)';

	// ダイアログメッセージ
	IDD_COMDLG32    =  100;
	IDE_SELECTED1   = 1022;
	IDE_SELECTED2   = 1023;
	IDE_SELECTED3   = 1024;

	AMAX_BUF=255;
	MutexName	= 'FMPMDMutex';
	FMPMDWindowClass = 'TFMPMDForm';
  GlobalAtomUniqueName = 'FMPMDGlobalAtom';

	WM_SETVOLDOWN 				= WM_USER + $100;		// Volume を PMDWin の値にセットする
	WM_SETTIMER   				= WM_USER + $101;		// スライダー、表示をセットする
	WM_PLAYNEXT  					= WM_USER + $102;		// 次の曲を演奏
	WM_DRIVERCHANDE				= WM_USER + $103;		// ドライバーが変わった(FMP <--> PMD)
	WM_PLAYSTART					= WM_USER + $104;		// 演奏開始時のメッセージ
	WM_PLAYSTOP						= WM_USER + $105;		// 演奏停止時のメッセージ
	WM_PLAYPAUSE					= WM_USER + $106;		// Pause時のメッセージ
	WM_POSITIONMOVE_START = WM_USER + $107;		// 再生位置変更処理開始時のメッセージ(to Prompt)
	WM_POSITIONMOVE_END   = WM_USER + $108;		// 再生位置変更処理終了時のメッセージ(to Prompt)


type
	TPlayDriver = (DRIVER_FMP, DRIVER_PMD);		// 現在演奏している曲データの種類

	TWavFormat = packed record
		RIFFstr					: array[0..3] of Char;	// 'RIFF'
		RIFFsize				: longint;              //	filesize - 8
		WAVEstr					: array[0..3] of Char;	// 'WAVE'
		fmtstr					: array[0..3] of Char;	// 'fmt '
		fmtsize					: longint;              //
		formatID 				: word;									//	format ID(PCM = 1)
		nChannels  			: word;									//  channel(Mono : 1, Stereo : 2)
		nSamplesPerSec	: longint;							//  sampling rate
		nAvgBytesPerSec	:	longint;							//	平均データ転送速度
		nBlockAlign			: word;                 //  block 境界
		wBitsPerSample	: word;                 //  8 or 16 bit
		datastr					: array[0..3] of Char;	// 'data'
		datasize				: longint;              //
	end;


implementation

end.
