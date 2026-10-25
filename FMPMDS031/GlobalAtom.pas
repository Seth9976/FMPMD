//============================================================================
//                     GlobalAtom によるプロセス間通信
//                   Copyright & Programmed by Kennywell
//============================================================================
unit GlobalAtom;

interface

uses
	Windows,Classes,Messages,Dialogs,Forms,SysUtils, FMPMDPlayDefine;


procedure PutGlobalAtom1(Wnd: HWnd; aUnique: string);
procedure PutGlobalAtom2(Wnd: HWnd; aParamCount: integer; aUnique: string);

procedure SplitAtomReceivedStr(var Dest : TStrings; pcDat: PChar);


implementation

{=========================================================}
function GetFromString(var vStr: string; ch: char): string;
{vStr を頭から見て、chで区切られたところまでを返す
 vStr には残りが戻る}
var
	PosC : integer;
begin
	PosC:=Pos(ch,vStr);
	if PosC=0 then begin
		Result:=vStr; vStr:='';
	end else begin
		Result:=Copy(vStr,1,PosC-1);
		vStr:=Copy(vStr,PosC+1,System.Length(vStr)-PosC);
	end;
end; {GetFromString}


{=========================================================}
procedure ParamsToData(
					aParamCount: integer;  {=ParamCount}
					var pcData: PChar);    {収納変数}
var
	i: integer;
begin
	StrCopy(pcData,'');
	for i:=1 to aParamCount do begin
		if i=1 then
			StrCat(pcData,PChar(ParamStr(i)))
		else begin
			if(StrLen(pcData) + 1 + Length(ExtractFilename(ParamStr(i)))
																				< AMAX_BUF*2 + 1) then begin
				StrCat(pcData,'|');
				StrCat(pcData,PChar(ExtractFilename(ParamStr(i))));
			end;
		end;
  end;
end; {ParamsToData}


{=======================================================}
function TailLongName(FullPathName: String; Attr: integer): String;
var
  SearchRec: TSearchRec;
begin
	if FindFirst(FullPathName,Attr,SearchRec)=0 then
		Result:=SearchRec.Name
	else
		Result:='';
	FindClose(SearchRec);
end; {TailLongName}


{=========================================================}
function PutYenMark(vDir: TFilename): TFilename;
var
	Len: Integer;
	DestSize : Integer;
	pwvDir : PWideChar;
begin
	Len :=Length(vDir);
	Result := vDir;
	
	DestSize := Len * 2 + 16;
	GetMem(pwvDir, DestSize);
	try
		StringToWideChar(vDir, pwvDir, DestSize);
		if(pwvDir[Len - 1] <> WideChar('\')) then begin
			Result := Result + '\';
		end;
	finally
		Dispose(pwvDir);
	end;
(*
	if vDir[Len]<>'\' then Result:=vDir+'\' // 日本語 dir 対応
	else Result:=vDir;
*)
end; {PutYenMark}


{=======================================================}
function GetLongDirName(DirName:String): String;
var
	LongDirName: String;
begin
	// ファイルが存在しない場合はそのまま返す
	if(FileExists(DirName) = False) then begin
		Result := DirName;
	end else begin
		if (Length(Dirname)=2) or (Length(Dirname)=3) then
			Result:=Dirname
		else begin
			LongDirName:=
				TailLongName(DirName,faDirectory+faHidden+faSysFile);
			DirName:=ExtractFileDir(DirName);
			Result:=PutYenMark(GetLongDirName(Dirname))+LongDirName;
		end;
	end;
end; {GetLongDirName}


{=======================================================}
function GetLongFullPathName(ShortFullPath:String): String;
{ShortFullPathはディレクトリー名 NG}
Var
	aDir: String;
begin
	if(ExtractFileDir(ShortFullPath) <> '') then begin
		aDir := GetLongDirName(ExtractFileDir(ShortFullPath));
		if(Length(aDir) > 2) then begin
			aDir := PutYenMark(aDir);
		end;
	end else begin
		aDir := PutYenMark(GetCurrentDir);
	end;
//	Result := aDir + TailLongName(ShortFullPath,faAnyfile);
	Result := aDir +ExtractFileName(ShortFullPath);
end; {GetLongFullPathName}


{=========================================================}
{２重起動の場合のドラッグファイル名保存}
procedure PutGlobalAtom1(
					Wnd: HWnd;       {旧モジュールウィンドウハンドル}
					aUnique: string);{登録メッセージ}
var
	pcAtom1: PChar;
	anAtom1: TAtom;
	MsgID: UINT;

begin {PutGlobalAtom1}
	pcAtom1:=StrAlloc(AMAX_BUF);   {アトムテーブル用文字列}
	StrPCopy(pcAtom1,ParamStr(1));
										 {この場合はコマンドラインの第1引数}
	anAtom1:=GlobalAddAtom(pcAtom1);{アトムテーブルに格納}
	MsgID:=RegisterWindowMessage(PChar(aUnique));
										 {アプリ間通信のためのメッセージ登録}
	if (anAtom1<>INVALID_ATOM) then
		SendMessage(Wnd,MsgID,WPARAM(anAtom1),0);
										 {旧モジュールに送信}
	GlobalDeleteAtom(anAtom1);
										 {グローバルアトム参照数を1減らす}
	StrDispose(pcAtom1);
end; {PutGlobalAtom1}



{=========================================================}
procedure PutGlobalAtom2(
					Wnd: HWnd;       {旧モジュールウィンドウハンドル}
					aParamCount: integer; {ドロップファイル数}
					aUnique: string);{登録メッセージ}
var
	pcAtom1,pcAtom2: PChar;
	anAtom1,anAtom2: TAtom;
	MsgID: UINT;

	{-------------------------------------------------------}
	procedure GAddAtom(var anAtom1,anAtom2: TAtom;
										 pc1 : PChar;
										 var pc2 : PChar;
										 var ID: UINT);
	begin
		pc2:=nil;
		if (StrLen(pc1)>AMAX_BUF) then
			pc2:=pc1+AMAX_BUF;        {pc1後半をポイント}
		anAtom2:=GlobalAddAtom(pc2);{グローバルアトムテーブルに格納}
		if (StrLen(pc1)>AMAX_BUF) then
			pc1[AMAX_BUF]:=#0;        {pc1後半を殺す}
		anAtom1:=GlobalAddAtom(pc1);{グローバルアトムテーブルに格納}
		ID:=RegisterWindowMessage(PChar(aUnique));
		if (anAtom1<>INVALID_ATOM) then begin
			SendMessage(Wnd,ID,WPARAM(anAtom1),LPARAM(anAtom2));
			//SendMessage(Wnd,ID,MakeLong(anAtom1,anAtom2),0);
				{アトム2つで32-bitのlongint値を作って送信}
		end;
		GlobalDeleteAtom(anAtom1); {ｸﾞﾛｰﾊﾞﾙｱﾄﾑ参照数を1減らす}
		GlobalDeleteAtom(anAtom2);
	end; {GAddAtom}

{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
{PutGlobalAtom2}
begin
	pcAtom1:=StrAlloc(AMAX_BUF*2+1);

	{以下は何をしているかというと、ドロップされたファイル名を、
	 一旦pcAtom1に入れ、256文字以上のとき、後半をpcAtom2でポ
	 イントする。
	 パスは同じと考え、最初のファイル名だけはフルパス、残りは
	 ファイル名だけで、ファイル名の間に区切り記号として'|'を
	 入れている。}

	ParamsToData(aParamCount,pcAtom1);
	GAddAtom(anAtom1,anAtom2,pcAtom1,pcAtom2,MsgID);

	StrDispose(pcAtom1);
end; {PutGlobalAtom2}


{=========================================================}
{受信文字列を'|'で分解して、ロングネームで Dest に放り込み}
procedure SplitAtomReceivedStr(var Dest : TStrings; pcDat: PChar);
var
	i: integer;
	sLeft,
	sRest: string;
	CurDir : String;
begin
	CurDir := '';
	sRest:=StrPas(pcDat);
	i:=1;
	while (sRest<>'') do begin
		sLeft:=GetFromString(sRest,'|');
		if i=1 then begin
			sLeft:=GetLongFullPathName(sLeft);
			CurDir:=ExtractFilePath(sLeft);
			Dest.Add(sLeft);
		end else begin
			sLeft:=	GetLongFullPathName(CurDir+sLeft);
			Dest.Add(sLeft);
		end;
		inc(i);
	end;
end; {DropedStrs}




end.
