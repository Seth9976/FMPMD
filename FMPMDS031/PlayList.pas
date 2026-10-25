//============================================================================
//                           PlayList ユニット
//                      Copyright & Programmed by C60
//============================================================================
unit PlayList;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, CommDlg, ShellAPI, Menus, FileCtrl, Main, FMPMDPlayDefine, PinForm;

const
	MSG_ERR_LISTINDEX = 'リストのインデックスが範囲を超えています';

type
	// PlayList のアイテム
	PPlayListItem = ^TPlayListItem;
	TPlayListItem = record
		FileName : string;		// ファイルネーム
		PlayIndex : Integer;	// 演奏順
	end;

	// TPlayList(TPlayListItem 用 TList。要素のメモリ確保、開放は自動的に行う)
	TPlayList = class(TList)
	protected
		function Get(Index: Integer): PPlayListItem;
		procedure Put(Index: Integer; Item: PPlayListItem);
	public
		destructor Destroy; override;
		function Add(Item: TPlayListItem): Integer;
		procedure Clear;
		procedure Delete(Index: Integer);
		procedure Insert(Index: Integer; Item: TPlayListItem);
		property Items[Index: Integer]: PPlayListItem read Get write Put; default;
	end;

	// 例外
	EPlayListError = class(Exception);

	TPlayListForm = class(TForm)
		ListBox1: TListBox;
		PinForm1: TPinForm;
		PopupMenu1: TPopupMenu;
		CutPopup: TMenuItem;
		CopyPopup: TMenuItem;
		PastePopup: TMenuItem;
		N1: TMenuItem;
		SelectAllPopup: TMenuItem;
		procedure FormCreate(Sender: TObject);
		procedure ListBox1DblClick(Sender: TObject);
		procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure ListBox1DragOver(Sender, Source: TObject; X, Y: Integer;
			State: TDragState; var Accept: Boolean);
		procedure ListBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
		procedure FormDestroy(Sender: TObject);
		procedure PopupMenu1Popup(Sender: TObject);
		procedure Cut(Sender: TObject);
		procedure Copy(Sender: TObject);
		procedure Paste(Sender: TObject);
		procedure SelectAll(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
	private
		{ Private 宣言 }
		FPlayList : TPlayList;		// PlayList の実体
		FPlayCount : Integer;			// 演奏中の曲の番号(TPlayListItem.PlayIndex に対応)
		FPlayListCount : Integer;	// PlayList 曲数(FPlayList.Count)
		FSelectExt : TStringList;	// フォルダ中の識別拡張子('.'を含む)
		FLoop : Boolean;
		FRandom : Boolean;
		FOnSelect : TNotifyEvent;
		FStrClip : TStringList;		// クリップ
	protected
		procedure WindowPosChanging(var Msg : TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
		procedure DropFiles(var Msg:TWMDROPFILES); message WM_DROPFILES;
		function GetPlayFileName : String;
		function GetCount : Integer;
		procedure SetRandom(Value : Boolean);
		procedure OnlySelect(Index : Integer);
		procedure SetPlayIndex(Value : Integer);
		function GetPlayIndex : Integer;
		procedure SetSelectExt(Value : TStrings);
		function GetSelectExt : TStrings;
	public
		{ Public 宣言 }
		procedure Add(Item: String);
		procedure AddStrings(Strings: TStrings);
		procedure Insert(Index: Integer; Item : String);
		procedure InsertStrings(Index: Integer; Strings: TStrings);
		procedure InsertStringsSub(Index: Integer; Strings: TStrings);
		procedure Clear;
		procedure Delete(Index : Integer);
		function Next : Boolean;
		function Prev : Boolean;
		procedure LoadFromFile(const FileName: string);
		procedure SaveToFile(const FileName: string);
		property PlayFileName : string read GetPlayFileName;
		property Loop : Boolean read FLoop write FLoop;
		property Random : Boolean read FRandom write SetRandom;
		property Count : Integer read GetCount;
		property PlayIndex : Integer read GetPlayIndex write SetPlayIndex;
		property SelectExt : TStrings read GetSelectExt write SetSelectExt;
		property OnSelect : TNotifyEvent read FOnSelect write FOnSelect;
	end;

var
	PlayListForm: TPlayListForm;

implementation

{$R *.DFM}


//###########################################################################
//###########################################################################
// TPlayList クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// デストラクタ
//***************************************************************************
destructor TPlayList.Destroy;
(*
var
	i : Integer;
*)
begin
(*
	// Item の開放
	for i := 0 to Count-1 do begin
		Dispose(inherited Items[i]);
	end;
*)
	Clear;
	inherited Destroy;
end;


//***************************************************************************
// Item 追加
//***************************************************************************
function TPlayList.Add(Item: TPlayListItem): Integer;
var
	p_PlayListItem : PPlayListItem;
begin
	New(p_PlayListItem);
	p_PlayListItem^ := Item;
	result := inherited Add(p_PlayListItem);
end;


//***************************************************************************
// Item 挿入
//***************************************************************************
procedure TPlayList.Insert(Index: Integer; Item: TPlayListItem);
var
	p_PlayListItem : PPlayListItem;
begin
	New(p_PlayListItem);
	p_PlayListItem^ := Item;
	inherited Insert(Index, p_PlayListItem);
end;


//***************************************************************************
// Item 削除
//***************************************************************************
procedure TPlayList.Delete(Index: Integer);
begin
	if (Index < 0) or (Index >= Count) then EPlayListError.Create(MSG_ERR_LISTINDEX);
	if(Items[Index] <> nil) then begin
		Dispose(inherited Items[Index]);
		inherited Delete(Index);
		Pack;
	end;
end;


//***************************************************************************
// Item 全削除
//***************************************************************************
procedure TPlayList.Clear;
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
function TPlayList.Get(Index : Integer) : PPlayListItem;
begin
	result := inherited Get(Index);
end;


//***************************************************************************
// Item 代入
//***************************************************************************
procedure TPlayList.Put(Index: Integer; Item: PPlayListItem);
begin
	TPlayListItem(inherited Items[Index]^) := Item^;
end;


//###########################################################################
//###########################################################################
// TPlayListForm クラス
//###########################################################################
//###########################################################################

//***************************************************************************
// コンストラクタ
//***************************************************************************
procedure TPlayListForm.FormCreate(Sender: TObject);
begin
	DragAcceptFiles(Handle, True);
	FOnSelect := Nil;
	FPlayCount := 0;
	FPlayListCount := 0;
	FLoop := False;
	FRandom := False;
	FPlayList := TPlayList.Create;
	FStrClip := TStringList.Create;
	FSelectExt := TStringList.Create;
	Randomize;
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
procedure TPlayListForm.FormDestroy(Sender: TObject);
begin
	FPlayList.Destroy;
	FStrClip.Destroy;
	FSelectExt.Destroy;
end;


//***************************************************************************
// Window への D&D
//***************************************************************************
procedure TPlayListForm.DropFiles(var Msg:TWMDROPFILES);
var
	FileName: array[0..1024] of Char;
	i, Files : Integer;
	StrList : TStringList;
begin
	StrList := TStringList.Create;
	try
		// ﾄﾞﾛｯﾌﾟされたﾌｧｲﾙ数を取得
		Files:= DragQueryFile(Msg.Drop, $ffffffff, nil, 0);
		// ファイルのリストをListBoxに代入する
		for i:= 0 to Files - 1 do begin
			DragQueryFile(Msg.Drop, i, FileName, Sizeof(FileName) - 1);
			StrList.Add(FileName);
		end;
		// 終了処理
		DragFinish(Msg.Drop);
		AddStrings(StrList);
	finally
		Msg.result := 0;
		StrList.Destroy;
	end;
end;


//***************************************************************************
// フォームを開いたとき
//***************************************************************************
procedure TPlayListForm.FormActivate(Sender: TObject);
begin
	FMPMDForm.PlayListMenu.Checked := True;
end;


//***************************************************************************
// フォームを閉じたとき
//***************************************************************************
procedure TPlayListForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
	FMPMDForm.PlayListMenu.Checked := False;
end;


//***************************************************************************
// 演奏中ファイルの取得
//***************************************************************************
function TPlayListForm.GetPlayFileName : String;
var
	i : Integer;
begin
	if(FPlayCount < FPlayListCount) then begin
		for i := 0 to FPlayListCount-1 do begin
			if(FPlayCount = FPlayList[i].PlayIndex) then begin
				result := FPlayList[i].FileName;
				break;
			end;
		end;
		OnlySelect(FPlayCount);
	end else begin
		result := '';
	end;
end;


//***************************************************************************
// プレイリストの曲数の取得
//***************************************************************************
function TPlayListForm.GetCount : Integer;
begin
	// Thread 対策で VCL を使わずに取得
	result := FPlayListCount;
end;


//***************************************************************************
// Random を設定
//***************************************************************************
procedure TPlayListForm.SetRandom(Value : Boolean);
var
	i, j, k, temp : Integer;
	FPlayCount2 : Integer;
begin
	if(Value = True) then begin
		// PlayList をシャッフルする
		// 今演奏している曲の PlayIndex を 0、それ以外の曲の PlayIndex を一旦
		// -1 にセットし、後で -1 の部分に番号を振っていく
		for i := 0 to FPlayListCount-1 do begin
			if(FPlayList[i].PlayIndex = FPlayCount) then begin
				FPlayList[i].PlayIndex := 0;
			end else begin
				FPlayList[i].PlayIndex := -1;
			end;
		end;
		FPlayCount := 0;

		for i := 1 to FPlayListCount-1 do begin
			temp := System.Random(FPlayListCount - i) + 1;
			k := 0;
			for j := 0 to FPlayListCount-1 do begin
				if(FPlayList[j].PlayIndex < 0) then begin
					Inc(k);
					if(k = temp) then begin
						FPlayList[j].PlayIndex := i;
						break;
					end;
				end;
			end;
		end;
	end else begin
		// 現在演奏中の曲の FPlayList での位置を探す
		FPlayCount2 := -1;
		for i := 0 to FPlayListCount - 1 do begin
			if(FPlayList[i].PlayIndex = FPlayCount) then begin
				FPlayCount2 := i;
				break;
			end;
		end;

		// PlayList のシャッフルを戻す
		for i := 0 to FPlayListCount - 1 do begin
			FPlayList[i].PlayIndex := i;
		end;

		// 現在演奏中の曲の FPlayList での位置を設定し直す
		if(FPlayListCount > 0) and (FPlayCount2 >= 0) then begin
			FPlayCount := FPlayCount2;
		end else begin
			FPlayCount := 0;
		end;
	end;
	FRandom := Value;
end;


//***************************************************************************
// SelectExt(フォルダを選択したときの選択拡張子)を設定
//***************************************************************************
procedure TPlayListForm.SetSelectExt(Value : TStrings);
var
	i : Integer;
begin
	FSelectExt.Clear;

	for i := 0 to Value.Count - 1 do begin
		if(Value[i][1] = '.') then begin				// '.' がある場合
			FSelectExt.Add(LowerCase(Value[i]));
		end else begin													// '.' がない場合
			FSelectExt.Add(LowerCase('.' + Value[i]));
		end;
	end;
end;


//***************************************************************************
// SelectExt(フォルダを選択したときの選択拡張子)を取得
//***************************************************************************
function TPlayListForm.GetSelectExt : TStrings;
begin
	Result := FSelectExt;
end;


//***************************************************************************
// 曲（１つ）をプレイリストに追加
//***************************************************************************
procedure TPlayListForm.Add(Item: String);
var
	StrList : TStringList;
begin
	StrList := TStringList.Create;
	StrList.Add(Item);
	InsertStrings(FPlayListCount, StrList);
	StrList.Destroy;
end;


//***************************************************************************
// 曲（１つ）をプレイリストに挿入
//***************************************************************************
procedure TPlayListForm.Insert(Index: Integer; Item: String);
var
	StrList : TStringList;
begin
	StrList := TStringList.Create;
	StrList.Add(Item);
	InsertStrings(Index, StrList);
	StrList.Destroy;
end;


//***************************************************************************
// 曲（複数）をプレイリストに追加
//***************************************************************************
procedure TPlayListForm.AddStrings(Strings: TStrings);
begin
	InsertStrings(FPlayListCount, Strings);
end;


//***************************************************************************
// 曲（複数）をプレイリストに挿入
//***************************************************************************
procedure TPlayListForm.InsertStrings(Index: Integer; Strings: TStrings);
var
	i, j, k, temp : Integer;
begin
	InsertStringsSub(Index, Strings);
	
	if(FRandom = True) then begin
		// Random の場合、現在演奏中の曲以降をシャッフルする
		// （現在0曲の場合全部シャッフル）
		// 今演奏している曲以降の PlayIndex を一旦 -1 にセットし、後で
		// -1 の部分に番号を振っていく
		if(FPlayListCount = 0) then begin
			for i := 0 to FPlayList.Count-1 do begin
				FPlayList[i].PlayIndex := -1;
			end;

			FPlayCount := 0;

			for i := 0 to FPlayList.Count-1 do begin
				temp := System.Random(FPlayList.Count - i) + 1;
				k := 0;
				for j := 0 to FPlayList.Count-1 do begin
					if(FPlayList[j].PlayIndex < 0) then begin
						Inc(k);
						if(k = temp) then begin
							FPlayList[j].PlayIndex := i;
							break;
						end;
					end;
				end;
			end;
		end else begin
			for i := 0 to FPlayList.Count-1 do begin
				if(FPlayList[i].PlayIndex > FPlayCount) then begin
					FPlayList[i].PlayIndex := -1;
				end;
			end;

			for i := FPlayCount + 1 to FPlayList.Count-1 do begin
				temp := System.Random(FPlayList.Count - i) + 1;
				k := 0;
				for j := 0 to FPlayList.Count-1 do begin
					if(FPlayList[j].PlayIndex < 0) then begin
						Inc(k);
						if(k = temp) then begin
							FPlayList[j].PlayIndex := i;
							break;
						end;
					end;
				end;
			end;
		end;
	end else begin
		// Random ではない場合、順番を打ち直して現在演奏中のファイルを
		// FPlayCount にセットする
		for i := 0 to FPlayList.Count-1 do begin
			FPlayList[i].PlayIndex := i;
		end;

		if(FPlayCount > Index) then begin
			Inc(FPlayCount, Index);
		end;
	end;

	FPlayListCount := FPlayList.Count;
	OnlySelect(FPlayCount);
end;


//***************************************************************************
// 曲（複数）をプレイリストに挿入(下請け・挿入部分のみ)
//***************************************************************************
procedure TPlayListForm.InsertStringsSub(Index: Integer; Strings: TStrings);
var
	StrList : TStringList;
	FolderList : TStringList;
	i, j : Integer;
	InsertCount : Integer;									// ファイルを挿入した数
	PlayListItem : TPlayListItem;
  SearchRec: TSearchRec;
  Rslt : Integer;
begin
	InsertCount := Index;
	StrList := TStringList.Create;
	FolderList := TStringList.Create;
	
	// ListBox 更新を抑制
	ListBox1.Items.BeginUpdate;
	
	// PlayList を展開、FPlayList へ格納
	for i := 0 to Strings.Count-1 do begin
		if(LowerCase(ExtractFileExt(Strings[i])) = PlayListExt) then begin
			// PlayList の場合：展開して格納
			StrList.Clear;
			StrList.LoadFromFile(Strings[i]);

			for j := 0 to StrList.Count-1 do begin
				if(StrList[j][1] <> '#') then begin
					if(FileExists(StrList[j])) then begin
						// FPlayList へ格納
						PlayListItem.FileName := StrList[j];
						PlayListItem.PlayIndex := FPlayList.Count;
						FPlayList.Insert(InsertCount, PlayListItem);
						ListBox1.Items.Insert(InsertCount, StrList[j]);
						Inc(InsertCount);
					end;
				end;
			end;
		end else if(DirectoryExists(Strings[i]) = True) then begin
			// フォルダの場合：一旦 FolderList に保存して
			// 後から処理(ファイルの処理順の関係)
			FolderList.Add(Strings[i]);
		end else begin
			// 曲データの場合
			if(FileExists(Strings[i])) then begin
				// FPlayList へ格納
				PlayListItem.FileName := Strings[i];
				PlayListItem.PlayIndex := FPlayList.Count;
				FPlayList.Insert(InsertCount, PlayListItem);
				ListBox1.Items.Insert(InsertCount, Strings[i]);
				Inc(InsertCount);
			end;
		end;
	end;
	
	// ListBox 更新を再開
	ListBox1.Items.EndUpdate;
	
	// 下位フォルダから指定拡張子（＋フォルダ）のファイルを
	// 選択して StrList に保存
	StrList.Clear;		// 使いまわし
	
	for i := 0 to FolderList.Count - 1 do begin
		Rslt := FindFirst(FolderList[i]+'\*.*',
			faReadOnly+faHidden+faSysFile+faDirectory+faArchive, SearchRec);
		if(Rslt = 0) then begin
			while(Rslt = 0) do begin
				if((SearchRec.Attr and faDirectory) > 0) then begin
					// フォルダの場合 '.' または '..' でなければ無条件に追加
					if(SearchRec.Name <> '.') and (SearchRec.Name <> '..') then begin
						StrList.Add(FolderList[i] + '\' + SearchRec.Name);
					end;
				end else if(FSelectExt.Count = 0) then begin
					// FSelectExt が設定されていなければ無条件に追加
					StrList.Add(FolderList[i] + '\' + SearchRec.Name);
				end else begin
					// ファイルの場合、FSelectExt にあれば追加
					if(FSelectExt.IndexOf(LowerCase(ExtractFileExt(SearchRec.Name))) >= 0)
							then begin
						StrList.Add(FolderList[i] + '\' + SearchRec.Name);
					end;
				end;
				Rslt := FindNext(SearchRec);
			end;
			
			FindClose(SearchRec);
		end;
	end;
	
	// 再帰呼び出し
	if(StrList.Count > 0) then begin
		InsertStringsSub(FPlayList.Count, StrList);
	end;
	
	FolderList.Destroy;
	StrList.Destroy;
	
end;


//***************************************************************************
// 曲をプレイリストから削除
//***************************************************************************
procedure TPlayListForm.Delete(Index : Integer);
var
	i : Integer;
begin
	// 削除するものより後の Item の PlayIndex を１つ前へずらす
	for i := 0 to FPlayListCount-1 do begin
		if(FPlayList[i].PlayIndex > FPlayList[Index].PlayIndex) then begin
			Dec(FPlayList[i].PlayIndex);
		end;
	end;

	// 削除処理
	if(FPlayList[Index].PlayIndex <= FPlayCount) then begin
		Dec(FPlayCount);
		if(FPlayCount < 0) then begin
			FPlayCount := 0;
		end;
	end;

	FPlayList.Delete(Index);
	ListBox1.Items.Delete(Index);
	Dec(FPlayListCount);
end;


//***************************************************************************
// 次の曲へシーク
//	return :	曲数が０か、曲リストの最後で
//						loop flag が立っていなかったら false
//***************************************************************************
function TPlayListForm.Next : Boolean;
begin
	result := True;
	if(FPlayListCount > 0) then begin
		if(FPlayCount + 1>= FPlayListCount) then begin
			if(FLoop = False) then begin
				result := False;
			end else begin
				FPlayCount := 0;
				OnlySelect(FPlayCount);
			end;
		end else begin
			Inc(FPlayCount);
			OnlySelect(FPlayCount);
		end;
	end else begin
		Result := False;
	end;
end;


//***************************************************************************
// 前の曲へシーク
//	return :	曲数が０か、曲リストの先頭で
//						loop flag が立っていなかったら false
//***************************************************************************
function TPlayListForm.Prev : Boolean;
begin
	result := True;
	if(FPlayListCount > 0) then begin
		if(FPlayCount = 0) then begin
			if(FLoop = False) then begin
				result := False;
			end else begin
				FPlayCount := FPlayListCount - 1;
				OnlySelect(FPlayCount);
			end;
		end else begin
			Dec(FPlayCount);
			OnlySelect(FPlayCount);
		end;
	end else begin
		Result := False;
	end;
end;


//***************************************************************************
// 曲をクリア
//***************************************************************************
procedure TPlayListForm.Clear;
begin
	FPlayList.Clear;
	ListBox1.Clear;
	FPlayListCount := 0;
	FPlayCount := 0;
end;


//***************************************************************************
// PlayList を読み込み(M3U形式)
//***************************************************************************
procedure TPlayListForm.LoadFromFile(const FileName: string);
begin
	Clear;
	Add(FileName);
end;


//***************************************************************************
// PlayList を保存(M3U形式)
//***************************************************************************
procedure TPlayListForm.SaveToFile(const FileName: string);
var
	i : Integer;
	F: TextFile;
begin
	AssignFile(F, FileName);
	ReWrite(F);

	for i := 0 to FPlayListCount-1 do begin
		Writeln(F, FPlayList[i].FileName);
	end;
	CloseFile(F);
end;


//***************************************************************************
// 演奏曲を取得(ListBox 整列順)
//***************************************************************************
function TPlayListForm.GetPlayIndex : Integer;
var
	i : Integer;
begin
	if(FPlayListCount = 0) then begin
		result := 0;
	end else begin
		// 現在演奏中の曲の FPlayList での位置を取得する
		result := -1;
		for i := 0 to FPlayListCount - 1 do begin
			if(FPlayList[i].PlayIndex = FPlayCount) then begin
				result := i;
				break;
			end;
		end;

		// 見つからなかった
		if(result < 0) then result := 0;
	end;
end;


//***************************************************************************
// 演奏曲を指定(ListBox 整列順)
//***************************************************************************
procedure TPlayListForm.SetPlayIndex(Value : Integer);
begin
	if(Value >= FPlayListCount) then begin
		FPlayCount := 0;
	end else begin
		FPlayCount := FPLayList[Value].PlayIndex;
		OnlySelect(FPlayCount);
	end;
end;


//***************************************************************************
// ListBox から１項目のみ選択
//***************************************************************************
procedure TPlayListForm.OnlySelect(Index : Integer);
var
	i : Integer;
begin
	for i := 0 to FPlayListCount-1 do begin
		if(FPlayList[i].PlayIndex = Index) then begin
			ListBox1.Selected[i] := True;
			SendMessage(ListBox1.Handle, LB_SETCARETINDEX, i, 0);
		end else begin
			if(ListBox1.Selected[i] = True) then begin
				ListBox1.Selected[i] := False;
			end;
		end;
	end;
end;


//***************************************************************************
// Window のスナップ
//***************************************************************************
procedure TPlayListForm.WindowPosChanging(var Msg : TWMWindowPosChanging);
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
// リストボックスをダブルクリックされた
//***************************************************************************
procedure TPlayListForm.ListBox1DblClick(Sender: TObject);
begin
	if Assigned(FOnSelect) then begin
		FPlayCount := FPlayList[ListBox1.ItemIndex].PlayIndex;
		FOnSelect(Self);
	end;
end;


//***************************************************************************
// Popup メニュー表示時の動作
//***************************************************************************
procedure TPlayListForm.PopupMenu1Popup(Sender: TObject);
begin
	if(ListBox1.ItemIndex < 0) or (FPlayListCount = 0) then begin
		CutPopup.Enabled := False;
		CopyPopup.Enabled := False;
	end else begin
		CutPopup.Enabled := True;
		CopyPopup.Enabled := True;
	end;

	if(FStrClip.Count <= 0) then begin
		PastePopup.Enabled := False;
	end else begin
		PastePopup.Enabled := True;
	end;

	if(FPlayListCount <= 0) then begin
		SelectAllPopup.Enabled := False;
	end else begin
		SelectAllPopup.Enabled := True;
	end;
end;


//***************************************************************************
// キー処理
//***************************************************************************
procedure TPlayListForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
var
	i : Integer;
begin
	if(Key = VK_RETURN) then begin
		// Enter キーが押された
		if(ListBox1.ItemIndex >= 0) and Assigned(FOnSelect) then begin
			FPlayCount := FPlayList[ListBox1.ItemIndex].PlayIndex;
			FOnSelect(Self);
		end;
	end else if(Key = VK_DELETE) then begin
		// Delete キーが押された
		for i := FPlayListCount-1 downto 0 do begin
			if(ListBox1.Selected[i] = True) then begin
				Delete(i);
			end;
		end;
	end else if(Shift = [ssCtrl]) then begin
		case Chr(Key) of
			'X', 'x' : Cut(Self);					// CTRL + X
			'C', 'c' : Copy(Self);        // CTRL + C
			'V', 'v' : Paste(Self);       // CTRL + V
			'A', 'a' : SelectAll(Self);   // CTRL + A
		end;
	end;
end;


//***************************************************************************
// 切り取り
//***************************************************************************
procedure TPlayListForm.Cut(Sender: TObject);
var
	i : Integer;
begin
	FStrClip.Clear;
	i := 0;
	while(i < FPlayListCount) do begin
		if(ListBox1.Selected[i] = True) then begin
			FStrClip.Add(FPlayList[i].FileName);
			Delete(i);
		end else begin
			Inc(i);
		end;
	end;
end;


//***************************************************************************
// コピー
//***************************************************************************
procedure TPlayListForm.Copy(Sender: TObject);
var
	i : Integer;
begin
	FStrClip.Clear;
	i := 0;
	while(i < FPlayListCount) do begin
		if(ListBox1.Selected[i] = True) then begin
			FStrClip.Add(FPlayList[i].FileName);
		end;
		Inc(i);
	end;
end;


//***************************************************************************
// 貼り付け
//***************************************************************************
procedure TPlayListForm.Paste(Sender: TObject);
begin
	if(ListBox1.ItemIndex < 0) then begin
		AddStrings(FStrClip);
	end else begin
		InsertStrings(ListBox1.ItemIndex + 1, FStrClip);
	end;
end;


//***************************************************************************
// すべて選択
//***************************************************************************
procedure TPlayListForm.SelectAll(Sender: TObject);
var
	i : Integer;
begin
	for i := 0 to FPlayListCount-1 do begin
		ListBox1.Selected[i] := true;
	end;
end;


//***************************************************************************
// ドロップ受け入れ
//***************************************************************************
procedure TPlayListForm.ListBox1DragOver(Sender, Source: TObject; X,
	Y: Integer; State: TDragState; var Accept: Boolean);
begin
//	Accept := True;
end;


//***************************************************************************
// ドロップされた際の入れ替え
//***************************************************************************
procedure TPlayListForm.ListBox1DragDrop(Sender, Source: TObject; X,
	Y: Integer);
//var
//	i : Integer;
begin
(*
	if(Sender is TListBox) and (Source is TListBox) then begin

		//@ 行の入れ替え（挿入先の取得法は？）
		for i := FPlayListCount-1 downto 0 do begin
			if(ListBox1.Selected[i] = True) then begin
				Delete(i);
			end;
		end;
	end;
*)
end;


end.
