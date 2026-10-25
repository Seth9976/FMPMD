//============================================================================
//                 WinFMP, PMDWin Music Player「FMPMD2000」
//                      Copyright & Programmed by C60
//============================================================================
program FMPMD;

uses
	Windows,
  Messages,
	Forms,
	FMPMDPlayDefine in 'FMPMDPlayDefine.pas',
	GlobalAtom in 'GlobalAtom.pas',
	PMDWin in 'PMDWin.pas',
	WinFMP in 'WinFMP.pas',
	Main in 'Main.pas' {FMPMDForm},
	Version in 'Version.pas' {VersionForm},
	Env in 'Env.pas' {EnvForm},
	Volume in 'Volume.pas' {VolumeForm},
	Speana in 'speana.pas' {SPForm},
	HRLVMeter in 'HRLVMeter.pas' {HRLVMeterForm},
	PlayList in 'PlayList.pas' {PlayListForm},
	PartMask in 'PartMask.pas' {PartMaskForm},
	Status in 'STATUS.PAS' {StatusForm},
	Prompt in 'Prompt.pas' {PromptForm},
	DecodeESC in 'DecodeESC.pas';

{$R *.RES}

var
	hMutex: THandle;
	Wnd, AppWnd: HWnd;
begin
	{ ミューテックスをオープンしてみる }
	hMutex := OpenMutex(MUTEX_ALL_ACCESS, False, MutexName);

	if hMutex <> 0 then begin
		{ オープン出来るなら既に実行されている     }

		{ クラス名で既にオープンされているフォームを探します }
		Wnd := FindWindow(FMPMDWindowClass, nil);
		if Wnd <> 0 then begin
//      SetForegroundWindow(Wnd); { 前面に移動してアクティブ化 }
			if ParamCount>=1 then

				// グローバルアトム設定と旧モジュールへの送信
				PutGlobalAtom2(Wnd, ParamCount, GlobalAtomUniqueName);

			{ TApplicationのウィンドウハンドルを取得 }
			AppWnd := GetWindowLong(Wnd, GWL_HWNDPARENT);
      if AppWnd <> 0 then Wnd := AppWnd;
      if IsIconic(Wnd) then { アイコン状態なら元に戻す }
        SendMessage(AppWnd, WM_SYSCOMMAND, SC_RESTORE, -1);
    end;

    { ミューテックスを閉じる }
    CloseHandle(hMutex);
	end else begin
    { ミューテックスを作成 }
		hMutex := CreateMutex(nil, False, MutexName);

		Application.Initialize;
		Application.Title := 'FMPMD2000';
		Application.CreateForm(TFMPMDForm, FMPMDForm);
		Application.CreateForm(TEnvForm, EnvForm);
		Application.CreateForm(TVersionForm, VersionForm);
		Application.CreateForm(TVolumeForm, VolumeForm);
		Application.CreateForm(TSPForm, SPForm);
		Application.CreateForm(THRLVMeterForm, HRLVMeterForm);
		Application.CreateForm(TPlayListForm, PlayListForm);
		Application.CreateForm(TPartMaskForm, PartMaskForm);
		Application.CreateForm(TStatusForm, StatusForm);
		Application.CreateForm(TPromptForm, PromptForm);
		Application.Run;

		{ ミューテックスを開放 }
		ReleaseMutex(hMutex);
	end;

end.

