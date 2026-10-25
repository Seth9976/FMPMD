//============================================================================
//                        WinFMP.dll include file
//                      Copyright & Programmed by C60
//============================================================================
unit WinFMP;

interface

// COM 風インターフェイスをテストする場合に有効にする
//{$DEFINE TESTCOMINTERFACE}


{$IFDEF VER90}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Delphi 2.0J
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uses
	Windows, Dialogs, PCMMusDriver, FMPMDDefine;
{$ELSE}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Delphi3 以降
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uses
	Windows, Dialogs, ActiveX, PCMMusDriver, FMPMDDefine;
{$ENDIF}

//=============================================================================
// 定数定義
//=============================================================================
const
	//--------------------------------------------------------------------------
	//	エラーメッセージ等
	//--------------------------------------------------------------------------

	WINFMP_DLLNAME							= 'WinFMP.dll';
	WINFMP_MININTERFACEVERSION	= 010;		// Ver 0.10 以上
	WINFMP_MAXINTERFACEVERSION	= 100;		// Ver 1.00 未満
	WINFMP_MSG_DLLNOTFOUND			= WINFMP_DLLNAME + 'が見つかりません';
	WINFMP_MSG_DLLBROKEN				= WINFMP_DLLNAME + 'が異常です';
	WINFMP_MSG_ERROR_LOWER			= 'Ver 0.10 以降の WinFMP.dll を使用してください';
	WINFMP_MSG_ERORR_UPPER			= 'Ver 1.00 未満の WinFMP.dll を使用してください';
  WINFMP_MSG_COMNOTFOUND			= 'WinFMP の COM インスタンスを確保できませんでした';


	//--------------------------------------------------------------------------
	//	バージョン情報
	//--------------------------------------------------------------------------
	FMP_InterfaceVersion					= 010;		// WinFMP.dll のインターフェイスバージョン

	//--------------------------------------------------------------------------
	//	DLL の戻り値
	//--------------------------------------------------------------------------
	WINFMP_OK											=   0;		// 正常終了
	FMP_ERR_OPEN_MUSIC_FILE				=   1;		// 曲 データを開けなかった
	FMP_ERR_WRONG_MUSIC_FILE			=   2;		// PMD の曲データではなかった
	FMP_ERR_OPEN_PVI_FILE			 	  =   3;		// PVI を開けなかった
	FMP_ERR_OPEN_PPZ1_FILE			 	=   6;		// PPZ1 を開けなかった
	FMP_ERR_WRONG_PVI_FILE		 		=   8;		// PVI ではなかった
	FMP_ERR_WRONG_PPZ1_FILE			 	=  11;		// PVI ではなかった(PPZ1)
	FMP_WARNING_PVI_ALREADY_LOAD	=  13;		// PVI はすでに読み込まれている
	FMP_WARNING_PPZ1_ALREADY_LOAD	=  16;		// PPZ1 はすでに読み込まれている

	FMP_ERR_WRONG_PARTNO			 		=  30;		// パート番号が不適
//	FMP_ERR_ALREADY_MASKED			 	=  31;		// 指定パートはすでにマスクされている
	FMP_ERR_NOT_MASKED				 		=  32;		// 指定パートはマスクされていない
	FMP_ERR_MUSIC_STOPPED			 		=  33;		// 曲が止まっているのにマスク操作をした

	FMP_ERR_OUT_OF_MEMORY			 		=  99;		// メモリが足りない

	//--------------------------------------------------------------------------
	//	ＷＩＮＦＭＰ専用の定義
	//--------------------------------------------------------------------------
	FMP_MAX_PCMDIR					 			=  64;
	
	//--------------------------------------------------------------------------
	//	その他定義
	//--------------------------------------------------------------------------
	FMP_NumOfFMPart								=   6;
	FMP_NumOfSSGPart							=   3;
	FMP_NumOfADPCMPart						=   1;
	FMP_NumOFOPNARhythmPart				=   1;
	FMP_NumOfExtPart							=   3;
	FMP_NumOfPPZ8Part							=   8;
	FMP_NumOfAllPart							= (FMP_NumOfFMPart+FMP_NumOfSSGPart+FMP_NumOfADPCMPart+FMP_NumOFOPNARhythmPart+FMP_NumOfExtPart+FMP_NumOfPPZ8Part);

	FMP_MUSDATASIZE				  		= 65536;		// 最大曲データサイズ
	FMP_COMMENTDATASIZE	 		   	=  8192;		// 最大３行コメントサイズ

	//--------------------------------------------------------------------------
	//	ＦＭＰ各種状態保持ｂｉｔ
	//
	//            fedcba98 76543210
	// FMP_sysbit xxxxxxxx xxxxxxxx
	//            |||||||| |||||||+---　
	//            |||||||| ||||||+----　
	//            |||||||| |||||+-----　
	//            |||||||| ||||+------　ＰＰＺ８でＰＶＩエミュレート中
	//            |||||||| |||+-------　
	//            |||||||| ||+--------　
	//            |||||||| |+---------　ＰＰＺ８演奏中
	//            |||||||| +----------　
	//            ||||||||
	//            |||||||+------------　
	//            ||||||+-------------　
	//            |||||+--------------　
	//            ||||+---------------　
	//            |||+----------------　
	//            ||+-----------------　フェードアウト中
	//            |+------------------　ループした
	//            +-------------------　演奏停止中
	//
	//--------------------------------------------------------------------------
	FMP_SYS_PPZ8PVI							= $0008;	// ＰＰＺ８エミュレート中
	FMP_SYS_PPZ8USE							= $0040;	// ＰＰＺ８ファイル使用中
	FMP_SYS_FADE								= $2000;	// フェードアウト中
	FMP_SYS_LOOP								= $4000;	// ループした
	FMP_SYS_STOP								= $8000;	// 演奏停止中
	FMP_SYS_INIT								= FMP_SYS_STOP;

	//--------------------------------------------------------------------------
	//	ＰＣＭ定義フラグ
	//--------------------------------------------------------------------------
	FMP_PCM_USEV1								= $0001;	// ＰＶＩ１使用中
	FMP_PCM_USEZ1								= $0010;	// ＰＰＺ１使用中

	FMP_WLFO_SYNC								= $0080;	// シンクロビット
																				// 下位４ビットがスロットマスク


type
	//==========================================================================
	//	ＬＦＯワーク構造体定義
	//==========================================================================
	//--------------------------------------------------------------------------
	//	ビブラートワーク構造体
	//--------------------------------------------------------------------------
	PLFOS = ^TLFOS;
	TLFOS = record
		LfoSdelay					: Integer; // ビブラート ディレイ値
		LfoSspeed					: Integer; // ビブラート スピード
		LfoScnt_dly				: Integer; // ビブラート ディレイカウンタ
		LfoScnt_spd				: Integer; // ビブラート スピードカウンタ
		LfoSdepth					: Integer; // ビブラート ずらしカウント値
		LfoScnt_dep				: Integer; // ビブラート ずらしカウンタ
		LfoSrate1					: Integer; // ビブラート かかり値
		LfoSrate2					: Integer; // ビブラート かかり値（サブ）
		LfoSwave					: Integer; // ビブラート 波形
	end;

	//--------------------------------------------------------------------------
	//	トレモロワーク構造体
	//--------------------------------------------------------------------------
	PTALFOS = ^TALFOS;
	TALFOS = record
		AlfoSdelay				: Integer; // トレモロ ディレイ値
		AlfoSspeed				: Integer; // トレモロ スピード
		AlfoScnt_dly			: Integer; // トレモロ ディレイカウンタ
		AlfoScnt_spd			: Integer; // トレモロ スピード
		AlfoSdepth				: Integer; // トレモロ 変化量
		AlfoScnt_dep			: Integer; // トレモロ 変化量カウンタ
		AlfoSrate					: Integer; // トレモロ かかり値
		AlfoSrate_org			: Integer; // トレモロ かかり値
	end;

	//--------------------------------------------------------------------------
	//	ワウワウワーク構造体
	//--------------------------------------------------------------------------
	PWLFOS = ^TWLFOS;
	TWLFOS = record
		WlfoSdelay				: Integer; // ワウワウ ディレイ値
		WlfoSspeed				: Integer; // ワウワウ スピード
		WlfoScnt_dly			: Integer; // ワウワウ ディレイカウンタ
		WlfoScnt_spd			: Integer; // ワウワウ スピードカウンタ
		WlfoSdepth				: Integer; // ワウワウ 変化量
		WlfoScnt_dep			: Integer; // ワウワウ 変化量カウンタ
		WlfoSrate					: Integer; // ワウワウ かかり値
		WlfoSrate_org			: Integer; // ワウワウ 現在のずらし値
		WlfoSrate_now			: Integer; // ワウワウ 現在のずらし値
		WlfoSsync					: Integer; // ワウワウ シンクロ／マスク
	end;

	//==========================================================================
	//	ピッチベンドワーク構造体定義
	//==========================================================================
	PPITS = ^TPITS;
	TPITS = record
		PitSdat						: Integer; // ピッチベンド変化値
		PitSdelay					: Integer; // ディレイ値
		PitSspeed					: Integer; // スピード
		PitScnt						: Integer; // スピードカウンタ
		PitSwave					: Integer; // 目標周波数
		PitStarget				: Integer; // 目標音階
	end;

	//--------------------------------------------------------------------------
	//	ＳＳＧエンベロープワーク構造体
	//--------------------------------------------------------------------------
	PENVS = ^TENVS;
	TENVS = record
		EnvSsv						: Integer; // スタートヴォユーム
		EnvSar						: Integer; // アタックレート
		EnvSdr						: Integer; // ディケイレート
		EnvSsl						: Integer; // サスティンレベル
		EnvSsr						: Integer; // サスティンレート
		EnvSrr						: Integer; // リリースレート
	end;

	//==========================================================================
	//	パートワーク構造体定義
	//==========================================================================
	PCPATS  = ^TCPATS;
	TCPATS = record
		PartSlfo_f				: Integer; // ＬＦＯ状態フラグ
		PartSdeflen				: Integer; // デフォルトの音長

		PartSvol					: Integer; // 現在の音量
		PartSdat_q				: Integer; // ゲート処理比較値
		
		PartScnt					: Integer; // 音長基準カウンタ
		PartSorg_q				: Integer; // ゲート処理用カウンタ
		
		PartStmpvol				: Integer; // 実際の出力音量
		PartSdat_k				: Integer; // Ｋｅｙｏｎを遅らせる値
		
		PartScnt_k				: Integer; // Ｋｅｙｏｎ遅らせ処理用カウンタ
		PartSbefore				: Integer; // １つ前の音程
		
		PartSstatus				: Integer; // 状態フラグ
		PartSsync					: Integer; // シンクロフラグ
		
		PartSdetune				: Integer; // デチューン値
		
		PartSpitch				: TPITS;   // ピッチベンド用ワーク
		PartSlfo					: Array[0..3-1] of TLFOS;
												         // ビブラートＬＦＯ（＃０，＃１，＃２）
		PartSwave					: Integer; // 実際の出力周波数
	
		PartSwave2				: Integer; // １つ前の出力周波数

		PartSxtrns				: Integer; // 音階のずれ用
		PartStone					: Integer; // 現在の音色番号

		PartSkeyon				: Integer; // 外部Ｋｅｙｏｎ取得用

		PartSpan					: Integer; // パン取得用
		PartSalg					: Integer; // 現在のアルゴリズム番号

		PartSio						: Integer; // 出力Ｉ／Ｏアドレス
		PartSpoint				: Pointer; // 読み込みポインタ
		PartSloop					: Pointer; // くり返しポインタ
		PartSchan					: Integer; // チャンネル識別用
		PartSbit					: Integer; // チャンネル制御bit
		PartSport					: Integer; // ＦＭ裏アドレスアクセス用

	end;

	//--------------------------------------------------------------------------
	//	ＦＭパートワーク構造体
	//--------------------------------------------------------------------------
	PFPATS = ^TFPATS;
	TFPATS = record
		FpatSaddr					: Pointer; // ＴＬアドレス
		FpatSalfo					: TALFOS;  // トレモロ用ワーク
		FpatSwlfo					: TWLFOS;  // ワウワウ用ワーク
		FpatS_hdly				: Integer; // ＨＬＦＯディレイ
		FpatS_hdlycnt			: Integer; // ＨＬＦＯカウンタ
		FpatS_hfreq				: Integer; // ＨＬＦＯ　ｆｒｅｑ
		FpatS_hapms				: Integer; // ＨＬＦＯ　ＰＭＳ／ＡＭＳ
		FpatSextend				: Integer; // extendモード
		FpatSslot_v				: Array[0..4-1] of Integer; // スロットごとの相対値
	end;

	//--------------------------------------------------------------------------
	//	ＳＳＧパートワーク構造体
	//--------------------------------------------------------------------------
	PSPATS = ^TSPATS;
	TSPATS = record
		SpatSnow_vol			: Integer; // 現在の音量
		SpatSflg					: Integer; // エンヴェロープ状態フラグ
		SpatSoct					: Integer; // オクターブ
		SpatSvol					: Integer; // 現在の出力音量
		SpatSenv					: TENVS;   // ソフトウェアエンベロープ
		SpatSenvadr				: PENVS;   // SSG Env pattern Address
	end;

	//--------------------------------------------------------------------------
	//	ＡＤＰＣＭパートワーク構造体
	//--------------------------------------------------------------------------
	PAPATS = ^TAPATS;
	TAPATS = record
		ApatSstart				: Integer; // ＰＣＭ スタートアドレス
		ApatSend					: Integer; // ＰＣＭ エンドアドレス
		ApatSdelta				: Integer; // ＰＣＭ ΔＮ値
	end;

	//--------------------------------------------------------------------------
	//	パートワーク構造体
	//--------------------------------------------------------------------------
	PPARTS = ^TPARTS;
	TPARTS = record
		CPatS							: TCPATS;  // 共通ワーク
		case Integer of
			0: (
				FPatS		 			: TFPATS;  // ＦＭパートワーク構造体
			);
			1: (
				SPatS		 			: TSPATS;  // ＳＳＧパートワーク構造体
			);
			2: (
				APatS		 			: TAPATS;  // ＡＤＰＣＭパートワーク構造体
			);
	end;

	//--------------------------------------------------------------------------
	//	フェードアウトデータ構造体
	//--------------------------------------------------------------------------
	PFADES = ^TFADES;
	TFADES = record
		FadeSfm						: Integer;
		FadeSssg					: Integer;
		FadeSrhy					: Integer;
		FadeSapcm					: Integer;
	end;

	//--------------------------------------------------------------------------
	//	外部同期ワーク構造体
	//--------------------------------------------------------------------------
	PSYNCS = ^TSYNCS;
	TSYNCS = record
		SyncSdat					: Integer; // 同期データ
		SyncScnt					: Integer; // 同期カウント
	end;

	//--------------------------------------------------------------------------
	//	ＦＭＰ内部ワーク構造体
	//--------------------------------------------------------------------------
	PFMPS = ^TFMPS;
	TFMPS = record
		FmpStempo					: Integer; // 00 現在のテンポ
		FmpSsync					: TSYNCS;  // 01 外部同期データ
		FmpSsysbit				: Integer; // 0a ＦＭＰステータスｂｉｔ
		FmpScnt_c					: Integer; // 0c 曲演奏中クロック
		FmpScnt_t					: Integer; // 0e 待ちカウンタ
		FmpSfade					: TFADES;  // 0f フェードアウト音量
		FmpSfade_o				: TFADES;  // 13 フェードアウト音量（オリジナル）
		FmpSloop_c				: Integer; // 14 曲ループ回数
		FmpStempo_t				: Integer; // 17 現在のテンポ（予備）
		FmpSmix_s					: Integer; // 18 ??FEDFED
		FmpStimer					: Integer; // 19 タイマーロード値
		FmpSnoise					: Integer; // 1a ＳＳＧのノイズ周波数
		FmpSsho						: Integer; // 1b 小節カウンタ
		FmpSpcmuse				: Integer; // 1d ＰＣＭ使用状況
		FmpScnt_ct				: Integer; // 1f 曲全体カウント数
		FmpScnt_cl				: Integer; // 23 曲ループカウント数
		FmpSmix_e					: Integer; // 29 効果音処理中のmixer
		FmpStempo_e				: Integer; // 2a 効果音時のデフォルトテンポ
	end;

	//--------------------------------------------------------------------------
	//	全体ワーク
	//--------------------------------------------------------------------------
	PWORKS = ^TWORKS;
	TWORKS = record
		ExtBuff						: TFMPS;   // 外部参照許可ワーク
		_F : Array[0..FMP_NumOfFMPart  -1] of TPARTS; // ＦＭ音源ワーク
		_A																	: TPARTS; // ＡＤＰＣＭ音源ワーク
		_X : Array[0..FMP_NumOfExtPart -1] of TPARTS; // ＦＭextendワーク
		_P : Array[0..FMP_NumOfPPZ8Part-1] of TPARTS; // ＰＣＭ(ppz8)音源ワーク
		_S : Array[0..FMP_NumOfSSGPart -1] of TPARTS; // ＳＳＧ音源ワーク

		//------------------------------------------------------------------------
		//	リズム音源部ワーク
		//------------------------------------------------------------------------
		R_key							: Array[0..16-1] of Integer; // 絶対に変えられない
		R_mask						: Integer;
		R_Oncho_cnt				: Integer;
		R_Oncho_def				: Integer;
		RTL_vol						: Integer;
		R_vol							: Array[0..6-1] of Integer;
		R_pan							: Array[0..6-1] of Integer;
		R_Loop_now				: Integer;
		R_Sync_flg				: Integer;
		R_State_flg				: Integer; // イネーブルフラグ
		_R								: TPARTS;

		//------------------------------------------------------------------------
		//	ｂｙｔｅデータワーク
		//------------------------------------------------------------------------
		TotalLoop					: Integer; // ループ終了カウンタ
		Loop_cnt					: Integer; // ループ終了回数
		Int_fcT						: Integer; // 割り込みフェードカウンタ
		Int_fc						: Integer; // 割り込みフェードカウンタ
		TimerA_cnt				: Integer; // Ｔｉｍｅｒディレイ
		Ver								: Integer; // 曲データバージョン
		NowPPZmode				: Integer; // 現在のＰＰＺの再生モード
		MusicClockCnt			: Integer; // 曲のクロックカウント(C??)
		ClockCnt					: Integer; // クロックカウント
		PcmHardVol				: Integer; // ＰＣＭハード音量
		ExtendKeyon				: Integer; // extend状態の3chのkeyon
		ExtendAlg					: Integer; // extendチャンネルのアルゴリズム

		//------------------------------------------------------------------------
		//	ｗｏｒｄデータワーク
		//------------------------------------------------------------------------
		FM_effect_dat : Array[0..4-1] of Integer;		// 効果音モードずらし値
		Play_flg					: Integer; // 演奏中フラグ
		Loop_flg					: Integer; // ループフラグ
		Int_CX						: Integer; // 割り込みフェードカウンタ

		//------------------------------------------------------------------------
		//	チャンネル別ワークアドレステーブル
		//------------------------------------------------------------------------
		Chan_tbl_R				: PPARTS;  // リズム
		Chan_tbl : Array[0..FMP_NumOfFMPart+FMP_NumOfSSGPart+FMP_NumOfPPZ8Part+1+FMP_NumOfExtPart+1-1] of PPARTS;

		//------------------------------------------------------------------------
		//	ＳＳＧエンベロープワーク
		//------------------------------------------------------------------------
		EnvAddr : Array[0..FMP_NumOfSSGPart - 1] of TENVS;

		//------------------------------------------------------------------------
		//	演奏中の曲のファイル名
		//------------------------------------------------------------------------
		Music_name : Array[0.._MAX_PATH-1] of Char;	// 演奏中の曲のファイル名

		//------------------------------------------------------------------------
		//	現在のＰＶＩファイル名
		//------------------------------------------------------------------------
		PVI_name : Array[0.._MAX_PATH-1] of Char;   // 現在のＰＣＭファイル名

		//------------------------------------------------------------------------
		//	ＷＩＮＦＭＰ専用データ
		//------------------------------------------------------------------------
		rate							: Integer; //	PCM 出力周波数(11k, 22k, 44k, 55k)
		ppz8ip						: Boolean; // PPZ8 で補完するか
		fadeout2_speed		: Integer; // fadeout(高音質)speed(>0で fadeout)
		lastSyncExtTime		: Integer; // 最後に Sync_Ext を実行した時間(ms/カラオケ用）
		pcmdir : Array[0..FMP_MAX_PCMDIR+1-1, 0.._MAX_PATH-1] of char;	//	PCM 検索ディレクトリ
	end;


	//--------------------------------------------------------------------------
	//	全体ワーク（－ファイル名部分他）
	//--------------------------------------------------------------------------
	PWORKS2 = ^TWORKS2;
	TWORKS2 = record
		ExtBuff						: TFMPS;   // 外部参照許可ワーク
		_F : Array[0..FMP_NumOfFMPart  -1] of TPARTS; // ＦＭ音源ワーク
		_A																	: TPARTS; // ＡＤＰＣＭ音源ワーク
		_X : Array[0..FMP_NumOfExtPart -1] of TPARTS; // ＦＭextendワーク
		_P : Array[0..FMP_NumOfPPZ8Part-1] of TPARTS; // ＰＣＭ(ppz8)音源ワーク
		_S : Array[0..FMP_NumOfSSGPart -1] of TPARTS; // ＳＳＧ音源ワーク

		//------------------------------------------------------------------------
		//	リズム音源部ワーク
		//------------------------------------------------------------------------
		R_key							: Array[0..16-1] of Integer; // 絶対に変えられない
		R_mask						: Integer;
		R_Oncho_cnt				: Integer;
		R_Oncho_def				: Integer;
		RTL_vol						: Integer;
		R_vol							: Array[0..6-1] of Integer;
		R_pan							: Array[0..6-1] of Integer;
		R_Loop_now				: Integer;
		R_Sync_flg				: Integer;
		R_State_flg				: Integer; // イネーブルフラグ
		_R								: TPARTS;

		//------------------------------------------------------------------------
		//	ｂｙｔｅデータワーク
		//------------------------------------------------------------------------
		TotalLoop					: Integer; // ループ終了カウンタ
		Loop_cnt					: Integer; // ループ終了回数
		Int_fcT						: Integer; // 割り込みフェードカウンタ
		Int_fc						: Integer; // 割り込みフェードカウンタ
		TimerA_cnt				: Integer; // Ｔｉｍｅｒディレイ
		Ver								: Integer; // 曲データバージョン
		NowPPZmode				: Integer; // 現在のＰＰＺの再生モード
		MusicClockCnt			: Integer; // 曲のクロックカウント(C??)
		ClockCnt					: Integer; // クロックカウント
		PcmHardVol				: Integer; // ＰＣＭハード音量
		ExtendKeyon				: Integer; // extend状態の3chのkeyon
		ExtendAlg					: Integer; // extendチャンネルのアルゴリズム

		//------------------------------------------------------------------------
		//	ｗｏｒｄデータワーク
		//------------------------------------------------------------------------
		FM_effect_dat : Array[0..4-1] of Integer;		// 効果音モードずらし値
		Play_flg					: Integer; // 演奏中フラグ
		Loop_flg					: Integer; // ループフラグ
		Int_CX						: Integer; // 割り込みフェードカウンタ

		//------------------------------------------------------------------------
		//	チャンネル別ワークアドレステーブル
		//------------------------------------------------------------------------
		Chan_tbl_R				: PPARTS;  // リズム
		Chan_tbl : Array[0..FMP_NumOfFMPart+FMP_NumOfSSGPart+FMP_NumOfPPZ8Part+1+FMP_NumOfExtPart+1-1] of PPARTS;
	end;

	//--------------------------------------------------------------------------
	//	３行コメントポインタワーク
	//--------------------------------------------------------------------------
	PComment = ^TComment;
	TComment = Array[0..3-1] of PChar;


{$IFDEF VER90}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Delphi 2.0J
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	//===========================================================================
	// IWINFMP : WINFMP の Interface Class
	//===========================================================================
	IWINFMP = class(IFMPMD)
		function maskon(rhythm_flag : Boolean; ah : Integer) : Integer; virtual; stdcall; abstract;
		function maskoff(rhythm_flag : Boolean; ah : Integer) : Integer; virtual; stdcall; abstract;
		procedure setfmvoldown(voldown : Integer); virtual; stdcall; abstract;
		procedure setssgvoldown(voldown : Integer); virtual; stdcall; abstract;
		procedure setrhythmvoldown(voldown : Integer); virtual; stdcall; abstract;
		procedure setadpcmvoldown(voldown : Integer); virtual; stdcall; abstract;
		procedure setppzvoldown(voldown : Integer); virtual; stdcall; abstract;
		function getfmvoldown : Integer; virtual; stdcall; abstract;
		function getssgvoldown : Integer; virtual; stdcall; abstract;
		function getrhythmvoldown : Integer; virtual; stdcall; abstract;
		function getadpcmvoldown : Integer; virtual; stdcall; abstract;
		function getppzvoldown : Integer; virtual; stdcall; abstract;
		function getcomment(dest : PChar; musdata : Pointer; size : Integer) : PChar; virtual; stdcall; abstract;
		function getcomment2(dest : PChar; musdata : Pointer; size : Integer) : PChar; virtual; stdcall; abstract;
		function getcomment3(dest : TComment; musdata : Pointer; size : Integer) : PComment; virtual; stdcall; abstract;
		function fgetcomment(dest : PChar; filename : PChar) : Integer; virtual; stdcall; abstract;
		function fgetcomment2(dest : PChar; filename : PChar)  : Integer; virtual; stdcall; abstract;
		function fgetcomment3(dest : TComment; filename : PChar)  : Integer; virtual; stdcall; abstract;
		function getdefinedpcmfilename(dest : PChar; musdata : Pointer; size : Integer) : PChar; virtual; stdcall; abstract;
		function getdefinedppzfilename(dest : PChar; musdata : Pointer; size : Integer; bufnum : Integer) : PChar; virtual; stdcall; abstract;
		function fgetdefinedpcmfilename(dest : PChar; filename : PChar) : Integer; virtual; stdcall; abstract;
		function fgetdefinedppzfilename(dest : PChar; filename : PChar; bufnum : Integer) : Integer; virtual; stdcall; abstract;
		function getsyncscnt : Integer; virtual; stdcall; abstract;
		function getlastsyncexttime : Integer; virtual; stdcall; abstract;
		function getworks : PWORKS; virtual; stdcall; abstract;
		procedure setadpcmppz8emulate(flag : Boolean); virtual; stdcall; abstract;
	end;


{$ELSE}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// Delphi3 以降
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	//===========================================================================
	// IWINFMP : WINFMP の Interface Class
	//===========================================================================
	IWINFMP = interface(IFMPMD)
		['{B7910277-0295-4052-9A65-5AD48D0F3477}']
		function maskon(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
		function maskoff(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
		procedure setfmvoldown(voldown : Integer); stdcall;
		procedure setssgvoldown(voldown : Integer); stdcall;
		procedure setrhythmvoldown(voldown : Integer); stdcall;
		procedure setadpcmvoldown(voldown : Integer); stdcall;
		procedure setppzvoldown(voldown : Integer); stdcall;
		function getfmvoldown : Integer; stdcall;
		function getssgvoldown : Integer; stdcall;
		function getrhythmvoldown : Integer; stdcall;
		function getadpcmvoldown : Integer; stdcall;
		function getppzvoldown : Integer; stdcall;
		function getcomment(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
		function getcomment2(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
		function getcomment3(dest : TComment; musdata : Pointer; size : Integer) : PComment; stdcall;
		function fgetcomment(dest : PChar; filename : PChar) : Integer; stdcall;
		function fgetcomment2(dest : PChar; filename : PChar)  : Integer; stdcall;
		function fgetcomment3(dest : TComment; filename : PChar)  : Integer; stdcall;
		function getdefinedpcmfilename(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
		function getdefinedppzfilename(dest : PChar; musdata : Pointer; size : Integer; bufnum : Integer) : PChar; stdcall;
		function fgetdefinedpcmfilename(dest : PChar; filename : PChar) : Integer; stdcall;
		function fgetdefinedppzfilename(dest : PChar; filename : PChar; bufnum : Integer) : Integer; stdcall;
		function getsyncscnt : Integer; stdcall;
		function getlastsyncexttime : Integer; stdcall;
		function getworks : PWORKS; stdcall;
		procedure setadpcmppz8emulate(flag : Boolean); stdcall;
	end;

{$ENDIF}


//=============================================================================
// Interface ID(IID) & Class ID(CLSID)
//=============================================================================
const
	// GUID of IWINFMP Interface ID
	IID_IWINFMP : TIID =
		(D1:$B7910277; D2:$0295; D3:$4052; D4:($9A,$65,$5A,$D4,$8D,$0F,$34,$77));

	// GUID of WINFMP Class ID
	CLSID_WINFMP : TCLSID =
		(D1:$3E7816B4; D2:$EB8F; D3:$435F; D4:($BC,$37,$01,$CE,$DB,$F4,$22,$87));



//=============================================================================
// DLL Interface
//=============================================================================
var
	HWinFMP : HMODULE;
{$IFDEF TESTCOMINTERFACE}
	pWinFMP  : IWINFMP;
	pWinFMP2 : IWINFMP;
{$ENDIF}
	
	fmp_getversion : function : Integer; stdcall;
	fmp_getinterfaceversion : function : Integer; stdcall;
	fmp_CoCreateInstance : function(const rclsid: TCLSID; pUnkOuter: IUnknown;
		dwClsContext: Longint; const riid: TIID; var ppv): HResult; stdcall;

{$IFDEF TESTCOMINTERFACE}
	function fmp_init(path : PChar) : Boolean; stdcall;
	function fmp_load(filename : PChar) : Integer; stdcall;
	function fmp_load2(musdata : Pointer; size : Integer) : Integer; stdcall;
	procedure fmp_start; stdcall;
	procedure fmp_stop; stdcall;
	procedure fmp_getpcmdata(buf : PSmallInt; nsamples : Integer); stdcall;
	function fmp_maskon(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
	function fmp_maskoff(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
	function fmp_loadrhythmsample(path : PChar) : Boolean; stdcall;
	function fmp_setpcmdir(pcmdir : PChar) : Boolean ; stdcall;
	procedure fmp_setpcmrate(rate : Integer); stdcall;
	procedure fmp_setppzrate(rate : Integer); stdcall;
	procedure fmp_fadeout(speed : Integer); stdcall;
	procedure fmp_fadeout2(speed : Integer); stdcall;
	procedure fmp_setfmcalc55k(flag : Boolean); stdcall;
	procedure fmp_setppzinterpolation(ip : Boolean); stdcall;
	procedure fmp_setadpcmppz8emulate(flag : Boolean); stdcall;
	function fmp_getcomment(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
	function fmp_getcomment2(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
	function fmp_getcomment3(dest : TComment; musdata : Pointer; size : Integer) : PComment; stdcall;
	function fmp_fgetcomment(dest : PChar; filename : PChar) : Integer; stdcall;
	function fmp_fgetcomment2(dest : PChar; filename : PChar) : Integer; stdcall;
	function fmp_fgetcomment3(dest : TComment; filename : PChar) : Integer; stdcall;
	function fmp_getdefinedpcmfilename(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
	function fmp_getdefinedppzfilename(dest : PChar; musdata : Pointer; size : Integer; bufnum : Integer) : PChar; stdcall;
	function fmp_fgetdefinedpcmfilename(dest : PChar; filename : PChar) : Integer; stdcall;
	function fmp_fgetdefinedppzfilename(dest : PChar; filename : PChar; bufnum : Integer) : Integer; stdcall;
	function fmp_getmusicfilename(dest : PChar) : PChar; stdcall;
	function fmp_getpcmfilename(dest : PChar) : PChar; stdcall;
	function fmp_getppzfilename(dest : PChar; bufnum : Integer) : PChar; stdcall;
	procedure fmp_setfmvoldown(voldown : Integer); stdcall;
	procedure fmp_setssgvoldown(voldown : Integer); stdcall;
	procedure fmp_setrhythmvoldown(voldown : Integer); stdcall;
	procedure fmp_setadpcmvoldown(voldown : Integer); stdcall;
	procedure fmp_setppzvoldown(voldown : Integer); stdcall;
	function fmp_getfmvoldown : Integer; stdcall;
	function fmp_getssgvoldown : Integer; stdcall;
	function fmp_getrhythmvoldown : Integer; stdcall;
	function fmp_getadpcmvoldown : Integer; stdcall;
	function fmp_getppzvoldown : Integer; stdcall;
	procedure fmp_setpos(pos : Integer); stdcall;
	procedure fmp_setpos2(pos : Integer); stdcall;
	function fmp_getpos : Integer; stdcall;
	function fmp_getpos2 : Integer; stdcall;
	function fmp_getlength(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
	function fmp_getlength2(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
	function fmp_getloopcount : Integer; stdcall;
	procedure fmp_setfmwait(nsec : Integer); stdcall;
	procedure fmp_setssgwait(nsec : Integer); stdcall;
	procedure fmp_setrhythmwait(nsec : Integer); stdcall;
	procedure fmp_setadpcmwait(nsec : Integer); stdcall;
	function fmp_getsyncscnt : Integer; stdcall;
	function fmp_getlastsyncexttime : Integer; stdcall;
	function fmp_getworks : PWORKS; stdcall;
	
{$ELSE}
	fmp_init : function(path : PChar) : Boolean; stdcall;
	fmp_load : function(filename : PChar) : Integer; stdcall;
	fmp_load2 : function(musdata : Pointer; size : Integer) : Integer; stdcall;
	fmp_start : procedure; stdcall;
	fmp_stop : procedure; stdcall;
	fmp_getpcmdata : procedure(buf : PSmallInt; nsamples : Integer); stdcall;
	fmp_maskon : function(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
	fmp_maskoff : function(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
	fmp_loadrhythmsample : function(path : PChar) : Boolean; stdcall;
	fmp_setpcmdir : function(pcmdir : PChar) : Boolean ; stdcall;
	fmp_setpcmrate : procedure(rate : Integer); stdcall;
	fmp_setppzrate : procedure(rate : Integer); stdcall;
	fmp_fadeout : procedure(speed : Integer); stdcall;
	fmp_fadeout2 : procedure(speed : Integer); stdcall;
	fmp_setfmcalc55k : procedure(flag : Boolean); stdcall;
	fmp_setppzinterpolation : procedure(ip : Boolean); stdcall;
	fmp_setadpcmppz8emulate : procedure(flag : Boolean); stdcall;
	fmp_getcomment : function(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
	fmp_getcomment2 : function(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
	fmp_getcomment3 : function(dest : TComment; musdata : Pointer; size : Integer) : PComment; stdcall;
	fmp_fgetcomment : function(dest : PChar; filename : PChar) : Integer; stdcall;
	fmp_fgetcomment2 : function(dest : PChar; filename : PChar) : Integer; stdcall;
	fmp_fgetcomment3 : function(dest : TComment; filename : PChar) : Integer; stdcall;
	fmp_getdefinedpcmfilename : function(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
	fmp_getdefinedppzfilename : function(dest : PChar; musdata : Pointer; size : Integer; bufnum : Integer) : PChar; stdcall;
	fmp_fgetdefinedpcmfilename : function(dest : PChar; filename : PChar) : Integer; stdcall;
	fmp_fgetdefinedppzfilename : function(dest : PChar; filename : PChar; bufnum : Integer) : Integer; stdcall;
	fmp_getmusicfilename : function(dest : PChar) : PChar; stdcall;
	fmp_getpcmfilename : function(dest : PChar) : PChar; stdcall;
	fmp_getppzfilename : function(dest : PChar; bufnum : Integer) : PChar; stdcall;
	fmp_setfmvoldown : procedure(voldown : Integer); stdcall;
	fmp_setssgvoldown : procedure(voldown : Integer); stdcall;
	fmp_setrhythmvoldown : procedure(voldown : Integer); stdcall;
	fmp_setadpcmvoldown : procedure(voldown : Integer); stdcall;
	fmp_setppzvoldown : procedure(voldown : Integer); stdcall;
	fmp_getfmvoldown : function : Integer; stdcall;
	fmp_getssgvoldown : function : Integer; stdcall;
	fmp_getrhythmvoldown : function : Integer; stdcall;
	fmp_getadpcmvoldown : function : Integer; stdcall;
	fmp_getppzvoldown : function : Integer; stdcall;
	fmp_setpos : procedure(pos : Integer); stdcall;
	fmp_setpos2 : procedure(pos : Integer); stdcall;
	fmp_getpos : function : Integer; stdcall;
	fmp_getpos2 : function : Integer; stdcall;
	fmp_getlength : function(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
	fmp_getlength2 : function(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
	fmp_getloopcount : function : Integer; stdcall;
	fmp_setfmwait : procedure(nsec : Integer); stdcall;
	fmp_setssgwait : procedure(nsec : Integer); stdcall;
	fmp_setrhythmwait : procedure(nsec : Integer); stdcall;
	fmp_setadpcmwait : procedure(nsec : Integer); stdcall;
	fmp_getsyncscnt : function : Integer; stdcall;
	fmp_getlastsyncexttime : function : Integer; stdcall;
	fmp_getworks : function : PWORKS; stdcall;
{$ENDIF}


implementation

//----------------------------------------------------------------------------
// 関数アドレスが取得できないと強制終了
//----------------------------------------------------------------------------
function GetProcAddress2(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;
begin
	Result := GetProcAddress(hModule, lpProcName);
	if(result = nil) then begin
		ShowMessage(WINFMP_MSG_DLLBROKEN);
		Halt;
	end;
end;


{$IFDEF TESTCOMINTERFACE}
//----------------------------------------------------------------------------
// 関数を COM風インターフェイス呼び出しに変換するだけの関数群
//----------------------------------------------------------------------------
function fmp_init(path : PChar) : Boolean; stdcall;
begin
	pWINFMP2.init(path);
	Result := pWINFMP.init(path);

(*
	pWINFMP2.setfmwait(0);				// 曲長計算高速化のため
	pWINFMP2.setssgwait(0);				// 曲長計算高速化のため
	pWINFMP2.setrhythmwait(0);		// 曲長計算高速化のため
	pWINFMP2.setadpcmwait(0);			// 曲長計算高速化のため
*)
end;


function fmp_load(filename : PChar) : Integer; stdcall;
begin
	Result := pWINFMP.music_load(filename);
end;


function fmp_load2(musdata : Pointer; size : Integer) : Integer; stdcall;
begin
	Result := pWINFMP.music_load2(musdata, size);
end;


procedure fmp_start; stdcall;
begin
	pWINFMP.music_start;
end;


procedure fmp_stop; stdcall;
begin
	pWINFMP.music_stop;
end;


procedure fmp_getpcmdata(buf : PSmallInt; nsamples : Integer); stdcall;
begin
	pWINFMP.getpcmdata(buf, nsamples);
end;


function fmp_maskon(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
begin
	Result := pWINFMP.maskon(rhythm_flag, ah);
end;


function fmp_maskoff(rhythm_flag : Boolean; ah : Integer) : Integer; stdcall;
begin
	Result := pWINFMP.maskoff(rhythm_flag, ah);
end;


function fmp_loadrhythmsample(path : PChar) : Boolean; stdcall;
begin
	Result := pWINFMP.loadrhythmsample(path);
end;


function fmp_setpcmdir(pcmdir : PChar) : Boolean ; stdcall;
begin
	Result := pWINFMP.setpcmdir(pcmdir);
end;


procedure fmp_setpcmrate(rate : Integer); stdcall;
begin
	pWINFMP.setpcmrate(rate);
end;


procedure fmp_setppzrate(rate : Integer); stdcall;
begin
	pWINFMP.setppzrate(rate);
end;


procedure fmp_fadeout(speed : Integer); stdcall;
begin
	pWINFMP.fadeout(speed);
end;


procedure fmp_fadeout2(speed : Integer); stdcall;
begin
	pWINFMP.fadeout2(speed);
end;


procedure fmp_setfmcalc55k(flag : Boolean); stdcall;
begin
	pWINFMP.setfmcalc55k(flag);
end;


procedure fmp_setppzinterpolation(ip : Boolean); stdcall;
begin
	pWINFMP.setppzinterpolation(ip);
end;


procedure fmp_setadpcmppz8emulate(flag : Boolean); stdcall;
begin
	pWINFMP.setadpcmppz8emulate(flag);
end;


function fmp_getcomment(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
begin
	Result := pWINFMP.getcomment(dest, musdata, size);
end;


function fmp_getcomment2(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
begin
	Result := pWINFMP.getcomment2(dest, musdata, size);
end;


function fmp_getcomment3(dest : TComment; musdata : Pointer; size : Integer) : PComment; stdcall;
begin
	Result := pWINFMP.getcomment3(dest, musdata, size);
end;


function fmp_fgetcomment(dest : PChar; filename : PChar) : Integer; stdcall;
begin
	Result := pWINFMP.fgetcomment(dest, filename);
end;


function fmp_fgetcomment2(dest : PChar; filename : PChar) : Integer; stdcall;
begin
	Result := pWINFMP.fgetcomment2(dest, filename);
end;


function fmp_fgetcomment3(dest : TComment; filename : PChar) : Integer; stdcall;
begin
	Result := pWINFMP.fgetcomment3(dest, filename);
end;


function fmp_getdefinedpcmfilename(dest : PChar; musdata : Pointer; size : Integer) : PChar; stdcall;
begin
	Result := pWINFMP.getdefinedpcmfilename(dest, musdata, size);
end;


function fmp_getdefinedppzfilename(dest : PChar; musdata : Pointer; size : Integer; bufnum : Integer) : PChar; stdcall;
begin
	Result := pWINFMP.getdefinedppzfilename(dest, musdata, size, bufnum);
end;


function fmp_fgetdefinedpcmfilename(dest : PChar; filename : PChar) : Integer; stdcall;
begin
	Result := pWINFMP.fgetdefinedpcmfilename(dest, filename);
end;


function fmp_fgetdefinedppzfilename(dest : PChar; filename : PChar; bufnum : Integer) : Integer; stdcall;
begin
	Result := pWINFMP.fgetdefinedppzfilename(dest, filename, bufnum);
end;


function fmp_getmusicfilename(dest : PChar) : PChar; stdcall;
begin
	Result := pWINFMP.getmusicfilename(dest);
end;


function fmp_getpcmfilename(dest : PChar) : PChar; stdcall;
begin
	Result := pWINFMP.getpcmfilename(dest);
end;


function fmp_getppzfilename(dest : PChar; bufnum : Integer) : PChar; stdcall;
begin
	Result := pWINFMP.getppzfilename(dest, bufnum);
end;


procedure fmp_setfmvoldown(voldown : Integer); stdcall;
begin
	pWINFMP.setfmvoldown(voldown);
end;


procedure fmp_setssgvoldown(voldown : Integer); stdcall;
begin
	pWINFMP.setssgvoldown(voldown);
end;


procedure fmp_setrhythmvoldown(voldown : Integer); stdcall;
begin
	pWINFMP.setrhythmvoldown(voldown);
end;


procedure fmp_setadpcmvoldown(voldown : Integer); stdcall;
begin
	pWINFMP.setadpcmvoldown(voldown);
end;


procedure fmp_setppzvoldown(voldown : Integer); stdcall;
begin
	pWINFMP.setppzvoldown(voldown);
end;


function fmp_getfmvoldown : Integer; stdcall;
begin
	Result := pWINFMP.getfmvoldown;
end;


function fmp_getssgvoldown : Integer; stdcall;
begin
	Result := pWINFMP.getssgvoldown;
end;


function fmp_getrhythmvoldown : Integer; stdcall;
begin
	Result := pWINFMP.getrhythmvoldown;
end;


function fmp_getadpcmvoldown : Integer; stdcall;
begin
	Result := pWINFMP.getadpcmvoldown;
end;


function fmp_getppzvoldown : Integer; stdcall;
begin
	Result := pWINFMP.getppzvoldown;
end;


procedure fmp_setpos(pos : Integer); stdcall;
begin
	pWINFMP.setpos(pos);
end;


procedure fmp_setpos2(pos : Integer); stdcall;
begin
	pWINFMP.setpos2(pos);
end;


function fmp_getpos : Integer; stdcall;
begin
	Result := pWINFMP.getpos;
end;


function fmp_getpos2 : Integer; stdcall;
begin
	Result := pWINFMP.getpos2;
end;


function fmp_getlength(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
begin
	Result := pWINFMP2.getlength(filename, length, loop);
end;


function fmp_getlength2(filename : PChar; var length : Integer; var loop : Integer) : Boolean; stdcall;
begin
	Result := pWINFMP2.getlength2(filename, length, loop);
end;


function fmp_getloopcount : Integer; stdcall;
begin
	Result := pWINFMP.getloopcount;
end;


procedure fmp_setfmwait(nsec : Integer); stdcall;
begin
	pWINFMP.setfmwait(nsec);
end;


procedure fmp_setssgwait(nsec : Integer); stdcall;
begin
	pWINFMP.setssgwait(nsec);
end;


procedure fmp_setrhythmwait(nsec : Integer); stdcall;
begin
	pWINFMP.setrhythmwait(nsec);
end;


procedure fmp_setadpcmwait(nsec : Integer); stdcall;
begin
	pWINFMP.setadpcmwait(nsec);
end;


function fmp_getsyncscnt : Integer; stdcall;
begin
	Result := pWINFMP.getsyncscnt;
end;


function fmp_getlastsyncexttime : Integer; stdcall;
begin
	Result := pWINFMP.getlastsyncexttime;
end;


function fmp_getworks : PWORKS; stdcall;
begin
	Result := pWINFMP.getworks;
end;

{$ENDIF}

initialization
//=============================================================================
// DLL 読み込み＆関数アドレス取得
//=============================================================================
	HWinFMP := LoadLibrary(WINFMP_DLLNAME);
	if(HWinFMP = 0) then begin
		ShowMessage(WINFMP_MSG_DLLNOTFOUND);
		Halt;
	end;

	// バージョンチェック
	fmp_getversion := GetProcAddress2(HWinFMP, 'fmp_getversion');
	fmp_getinterfaceversion := GetProcAddress2(HWinFMP, 'fmp_getinterfaceversion');


	if(fmp_getinterfaceversion < WINFMP_MININTERFACEVERSION) then begin
		ShowMessage(WINFMP_MSG_ERROR_LOWER);
		Halt;
	end;

	if(fmp_getinterfaceversion >= WINFMP_MAXINTERFACEVERSION) then begin
		ShowMessage(WINFMP_MSG_ERORR_UPPER);
		Halt;
	end;
	
	
	// インスタンス取得関数
	fmp_CoCreateInstance := GetProcAddress2(HWinFMP, 'fmp_CoCreateInstance');


{$IFDEF TESTCOMINTERFACE}
//=============================================================================
// インスタンス取得
//=============================================================================

	if(fmp_CoCreateInstance(CLSID_WINFMP, Nil, CLSCTX_ALL, IID_IWINFMP, pWINFMP) <> S_OK) then begin
		ShowMessage(WINFMP_MSG_COMNOTFOUND);
	end;

	if(fmp_CoCreateInstance(CLSID_WINFMP, Nil, CLSCTX_ALL, IID_IWINFMP, pWINFMP2) <> S_OK) then begin
		ShowMessage(WINFMP_MSG_COMNOTFOUND);
	end;

{$ELSE}

	// 残りの関数アドレスの取得
	fmp_init := GetProcAddress2(HWinFMP, 'fmp_init');
	fmp_load := GetProcAddress2(HWinFMP, 'fmp_load');
	fmp_load2 := GetProcAddress2(HWinFMP, 'fmp_load2');
	fmp_start := GetProcAddress2(HWinFMP, 'fmp_start');
	fmp_stop := GetProcAddress2(HWinFMP, 'fmp_stop');
	fmp_getpcmdata := GetProcAddress2(HWinFMP, 'fmp_getpcmdata');
	fmp_maskon := GetProcAddress2(HWinFMP, 'fmp_maskon');
	fmp_maskoff := GetProcAddress2(HWinFMP, 'fmp_maskoff');
	fmp_loadrhythmsample := GetProcAddress2(HWinFMP, 'fmp_loadrhythmsample');
	fmp_setpcmdir := GetProcAddress2(HWinFMP, 'fmp_setpcmdir');
	fmp_setpcmrate := GetProcAddress2(HWinFMP, 'fmp_setpcmrate');
	fmp_setppzrate := GetProcAddress2(HWinFMP, 'fmp_setppzrate');
	fmp_fadeout := GetProcAddress2(HWinFMP, 'fmp_fadeout');
	fmp_fadeout2 := GetProcAddress2(HWinFMP, 'fmp_fadeout2');
	fmp_setfmcalc55k := GetProcAddress2(HWinFMP, 'fmp_setfmcalc55k');
	fmp_setppzinterpolation := GetProcAddress2(HWinFMP, 'fmp_setppzinterpolation');
	fmp_setadpcmppz8emulate := GetProcAddress2(HWinFMP, 'fmp_setadpcmppz8emulate');
	fmp_getcomment := GetProcAddress2(HWinFMP, 'fmp_getcomment');
	fmp_getcomment2 := GetProcAddress2(HWinFMP, 'fmp_getcomment2');
	fmp_getcomment3 := GetProcAddress2(HWinFMP, 'fmp_getcomment3');
	fmp_fgetcomment := GetProcAddress2(HWinFMP, 'fmp_fgetcomment');
	fmp_fgetcomment2 := GetProcAddress2(HWinFMP, 'fmp_fgetcomment2');
	fmp_fgetcomment3 := GetProcAddress2(HWinFMP, 'fmp_fgetcomment3');
	fmp_getdefinedpcmfilename := GetProcAddress2(HWinFMP, 'fmp_getdefinedpcmfilename');
	fmp_getdefinedppzfilename := GetProcAddress2(HWinFMP, 'fmp_getdefinedppzfilename');
	fmp_fgetdefinedpcmfilename := GetProcAddress2(HWinFMP, 'fmp_fgetdefinedpcmfilename');
	fmp_fgetdefinedppzfilename := GetProcAddress2(HWinFMP, 'fmp_fgetdefinedppzfilename');
	fmp_getmusicfilename := GetProcAddress2(HWinFMP, 'fmp_getmusicfilename');
	fmp_getpcmfilename := GetProcAddress2(HWinFMP, 'fmp_getpcmfilename');
	fmp_getppzfilename := GetProcAddress2(HWinFMP, 'fmp_getppzfilename');
	fmp_setfmvoldown := GetProcAddress2(HWinFMP, 'fmp_setfmvoldown');
	fmp_setssgvoldown := GetProcAddress2(HWinFMP, 'fmp_setssgvoldown');
	fmp_setrhythmvoldown := GetProcAddress2(HWinFMP, 'fmp_setrhythmvoldown');
	fmp_setadpcmvoldown := GetProcAddress2(HWinFMP, 'fmp_setadpcmvoldown');
	fmp_setppzvoldown := GetProcAddress2(HWinFMP, 'fmp_setppzvoldown');
	fmp_getfmvoldown := GetProcAddress2(HWinFMP, 'fmp_getfmvoldown');
	fmp_getssgvoldown := GetProcAddress2(HWinFMP, 'fmp_getssgvoldown');
	fmp_getrhythmvoldown := GetProcAddress2(HWinFMP, 'fmp_getrhythmvoldown');
	fmp_getadpcmvoldown := GetProcAddress2(HWinFMP, 'fmp_getadpcmvoldown');
	fmp_getppzvoldown := GetProcAddress2(HWinFMP, 'fmp_getppzvoldown');
	fmp_setpos := GetProcAddress2(HWinFMP, 'fmp_setpos');
	fmp_setpos2 := GetProcAddress2(HWinFMP, 'fmp_setpos2');
	fmp_getpos := GetProcAddress2(HWinFMP, 'fmp_getpos');
	fmp_getpos2 := GetProcAddress2(HWinFMP, 'fmp_getpos2');
	fmp_getlength := GetProcAddress2(HWinFMP, 'fmp_getlength');
	fmp_getlength2 := GetProcAddress2(HWinFMP, 'fmp_getlength2');
	fmp_getloopcount := GetProcAddress2(HWinFMP, 'fmp_getloopcount');
	fmp_setfmwait := GetProcAddress2(HWinFMP, 'fmp_setfmwait');
	fmp_setssgwait := GetProcAddress2(HWinFMP, 'fmp_setssgwait');
	fmp_setrhythmwait := GetProcAddress2(HWinFMP, 'fmp_setrhythmwait');
	fmp_setadpcmwait := GetProcAddress2(HWinFMP, 'fmp_setadpcmwait');
	fmp_getsyncscnt := GetProcAddress2(HWinFMP, 'fmp_getsyncscnt');
	fmp_getlastsyncexttime := GetProcAddress2(HWinFMP, 'fmp_getlastsyncexttime');
	fmp_getworks := GetProcAddress2(HWinFMP, 'fmp_getworks');
	
{$ENDIF}


//----------------------------------------------------------------------------
// DLL 開放
//----------------------------------------------------------------------------
finalization

{$IFDEF TESTCOMINTERFACE}
	{$IFDEF VER90}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// Delphi 2.0J
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		pWINFMP.Release;
		pWINFMP2.Release;
	{$ELSE}
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	// Delphi3 以降
	//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 		pWINFMP := nil;
 		pWINFMP2 := nil;

	{$ENDIF}
{$ENDIF}

	if(HWinFMP <> 0) then begin
		FreeLibrary(HWinFMP);
	end;


end.
