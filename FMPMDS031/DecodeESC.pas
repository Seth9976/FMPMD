//============================================================================
//                      ESC ƒV[ƒPƒ“ƒXƒfƒR[ƒhƒNƒ‰ƒX
//                      Copyright & Programmed by C60
//============================================================================
unit DecodeESC;

interface

uses
	Windows, SysUtils, Classes, Graphics;

// debug ƒ‚[ƒh‚Ì‚É—LŒø‚É‚·‚é(•s³‚ÈƒGƒXƒP[ƒvƒV[ƒPƒ“ƒX‚Å—áŠO‚ğ¶¬‚·‚é)
//{$DEFINE DEBUG}

type
	PWord = ^Word;
	TZen2ConvertTable1 = Array[$8540..$85fc] of String;
	TZen2ConvertTable2 = Array[$8640..$869e] of String;

const
	//**************************************************************************
	// ‰æ–ÊƒTƒCƒYAƒ^ƒu‹æØ‚è
	//**************************************************************************
	SCREEN_WIDTH  = 80;		// ‰æ–ÊƒTƒCƒY(‰¡)
	SCREEN_HEIGHT = 25;		// ‰æ–ÊƒTƒCƒY(c)
	TABCOLUMN = 8;				// TAB ‹æØ‚è

	//**************************************************************************
	// —áŠO¶¬‚ÌƒGƒ‰[ƒƒbƒZ[ƒW
	//**************************************************************************
	MSG_ERR_STRPOS_WRITE_UNDER     = '•¶š—ñ‚Ì‘‚«‚İˆÊ’u‚ª‚O–¢–‚Å‚·';
	MSG_ERR_STRPOS_WRITE_OVER      = '•¶š—ñ‚Ì‘‚«‚İˆÊ’u‚ª’·‚³‚æ‚è‘å‚«‚¢‚Å‚·';
	MSG_ERR_STRPOS_READ_UNDER      = '•¶š—ñ‚Ì“Ç‚İo‚µˆÊ’u‚ª‚O–¢–‚Å‚·';
	MSG_ERR_STRPOS_READ_OVER       = '•¶š—ñ‚Ì“Ç‚İo‚µˆÊ’u‚ª’·‚³‚æ‚è‘å‚«‚¢‚Å‚·';
	MSG_ERR_LISTINDEX              = 'ƒŠƒXƒg‚ÌƒCƒ“ƒfƒbƒNƒX‚ª”ÍˆÍ‚ğ’´‚¦‚Ä‚¢‚Ü‚·';
	MSG_ERR_NO_SJIS2               = 'SHIFTJIS ‚Ì‚Q•¶š–Ú‚ª‚ ‚è‚Ü‚¹‚ñ';
	MSG_ERR_COLUMN0_SJIS2          = '‚O—ñ‚É SHIFTJIS ‚Ì‚Q•¶š–Ú‚ª‚ ‚è‚Ü‚·';
	MSG_ERR_UNDECODE_ESC           = 'ƒGƒXƒP[ƒvƒV[ƒPƒ“ƒX‚ğ‰ğ“Ç‚Å‚«‚Ü‚¹‚ñ';
	MSG_ERR_SCROOL_BELOW0          = 'ƒXƒNƒ[ƒ‹‚Ì’l‚ª‚O–¢–‚Å‚·';
	MSG_ERR_ATTRIBUTE_OUT_OF_RANGE = '‘®«‚Ì”š‚ª•s³‚Å‚·';
	

	//**************************************************************************
	// ‚QƒoƒCƒg”¼Šp•ÏŠ·ƒe[ƒuƒ‹
	//**************************************************************************
	Zen2ConvertTable1 : TZen2ConvertTable1 = (
		'I', 'h', '”', '', '“', '•', 'f', 'i',		// $8540`$8547
		'j', '–', '{', 'C', '|', 'D', '^', '‚O',		// $8548`$854f
		'‚P', '‚Q', '‚R', '‚S', '‚T', '‚U', '‚V', '‚W',		// $8550`$8557
		'‚X', 'F', 'G', 'ƒ', '', '„', 'H', '—',		// $8558`$855f
		'‚`', '‚a', '‚b', '‚c', '‚d', '‚e', '‚f', '‚g',		// $8560`$8567
		'‚h', '‚i', '‚j', '‚k', '‚l', '‚m', '‚n', '‚o',		// $8568`$856f
		'‚p', '‚q', '‚r', '‚s', '‚t', '‚u', '‚v', '‚w',		// $8570`$8577
		'‚x', '‚y', 'm', '', 'n', 'O', 'Q', 'M',		// $8578`$857f
		'M', '‚', '‚‚', '‚ƒ', '‚„', '‚…', '‚†', '‚‡',		// $8580`$8587
		'‚ˆ', '‚‰', '‚Š', '‚‹', '‚Œ', '‚', '‚', '‚',		// $8588`$858f
		'‚', '‚‘', '‚’', '‚“', '‚”', '‚•', '‚–', '‚—',		// $8590`$8597
		'‚˜', '‚™', '‚š', 'o', 'b', 'p', 'P', 'B',		// $8598`$859f
		'u', 'v', 'A', 'E', 'ƒ’', 'ƒ@', 'ƒB', 'ƒD',		// $85a0`$85a7
		'ƒF', 'ƒH', 'ƒƒ', 'ƒ…', 'ƒ‡', 'ƒb', '[', 'ƒA',		// $85a8`$85af
		'ƒC', 'ƒE', 'ƒG', 'ƒI', 'ƒJ', 'ƒL', 'ƒN', 'ƒP',		// $85b0`$85b7
		'ƒR', 'ƒT', 'ƒV', 'ƒX', 'ƒZ', 'ƒ\', 'ƒ^', 'ƒ`',		// $85b8`$85bf
		'ƒc', 'ƒe', 'ƒg', 'ƒi', 'ƒj', 'ƒk', 'ƒl', 'ƒm',		// $85c0`$85c7
		'ƒn', 'ƒq', 'ƒt', 'ƒw', 'ƒz', 'ƒ}', 'ƒ~', 'ƒ€',		// $85c8`$85cf
		'ƒ', 'ƒ‚', 'ƒ„', 'ƒ†', 'ƒˆ', 'ƒ‰', 'ƒŠ', 'ƒ‹',		// $85d0`$85d7
		'ƒŒ', 'ƒ', 'ƒ', 'ƒ“', 'J', '‹', 'ƒ', 'ƒ‘',		// $85d8`$85df
		'ƒ', 'ƒ•', 'ƒ–', 'ƒ”', 'ƒK', 'ƒM', 'ƒO', 'ƒQ',		// $85e0`$85e7
		'ƒS', 'ƒU', 'ƒW', 'ƒY', 'ƒ[', 'ƒ]', 'ƒ_', 'ƒa',		// $85e8`$85ef
		'ƒd', 'ƒf', 'ƒh', 'ƒo', 'ƒp', 'ƒr', 'ƒs', 'ƒu',		// $85f0`$85f7
		'ƒv', 'ƒx', 'ƒy', 'ƒ{', 'ƒ|'											// $85f8`$85fc
	);

	//**************************************************************************
	// ‚QƒoƒCƒg”¼Šp•ÏŠ·ƒe[ƒuƒ‹
	//**************************************************************************
	Zen2ConvertTable2 : TZen2ConvertTable2 = (
		'@', 'h', 'h', '†¢', '†£', '†¤', '†¥', '†¦',		// $8640`$8647
		'†§', '†¨', '†©', '†ª', '†«', '†¬', '†­', '†®',		// $8648`$864f
		'†¯', '†°', '†±', '†²', '†³', '†´', '†µ', '†¶',		// $8650`$8657
		'†·', '†¸', '†¹', '†º', '†»', '†¼', '†½', '†¾',		// $8658`$865f
		'†¿', '†À', '†Á', '†Â', '†Ã', '†Ä', '†Å', '†Æ',		// $8660`$8667
		'†Ç', '†È', '†É', '†Ê', '†Ë', '†Ì', '†Í', '†Î',		// $8668`$866f
		'†Ï', '†Ğ', '†Ñ', '†Ò', '†Ó', '†Ô', '†Õ', '†Ö',		// $8670`$8677
		'†×', '†Ø', '†Ù', '†Ú', '†Û', '†Ü', '†İ', '@',		// $8678`$867f
		'†Ş', '†ß', '†à', '†á', '†â', '†ã', '†ä', '†å',		// $8680`$8687
		'†æ', '†ç', '†è', '†é', '†ê', '†ë', '†ì', '†í',		// $8688`$868f
		'L', 'N', 'e', 'g', 'k', 'l', 'q', 'r',		// $8690`$8697
		's', 't', 'w', 'x', 'y', 'z', '|'      		// $8698`$869e
	);

type
	//**************************************************************************
	// —áŠO
	//**************************************************************************
	EDecodeESCCommandListError = class(Exception);
	EIntegerListError = class(Exception);
	EStrPosError = class(Exception);
	EDecodeESCSequenceError = class(Exception);

	//**************************************************************************
	// •¶šƒR[ƒhí•Ê
	//**************************************************************************
	TLetterCode = (
		CHAR_ASCII,												// ASCII •¶š
		CHAR_SJIS1,												// SJIS ‚PƒoƒCƒg–Ú
		CHAR_SJIS2,												// SJIS ‚QƒoƒCƒg–Ú
		CHAR_ZEN2,												// ‚QƒoƒCƒg”¼Šp•¶š
    CHAR_GRAPHIC											// ƒOƒ‰ƒtƒBƒbƒN•¶š($80`$9f,$e0`$fc)
	);

	//**************************************************************************
	// ‰æ–Ê‚Ì‚PÀ•W‚ÌƒAƒgƒŠƒrƒ…[ƒg‚ğ•Û‘¶‚·‚éƒŒƒR[ƒhŒ^
	//**************************************************************************
	PDecodeESCAttribute = ^TDecodeESCAttribute;
	TDecodeESCAttribute = record
		Color : TColor;										// •¶šF
		LetterCode : TLetterCode;					// •¶šƒR[ƒhí•Ê
		Attribute_Sub : set of (					// •¶š‚ÌƒAƒgƒŠƒrƒ…[ƒg(‘®«)
			HighLight,												// ƒnƒCƒ‰ƒCƒg
			VerticalLine,											// ƒo[ƒeƒBƒJƒ‹Eƒ‰ƒCƒ“
			UnderLine,												// ƒAƒ“ƒ_[Eƒ‰ƒCƒ“
			Blink,														// ƒuƒŠƒ“ƒN
			Reverse,													// ƒŠƒo[ƒX
			Secret														// ƒV[ƒNƒŒƒbƒg
		);
	end;
	
	//**************************************************************************
	// ‰æ–Ê‚Ì‚PÀ•W‚Ìó‘Ô(•¶šAƒAƒgƒŠƒrƒ…[ƒg)‚ğ•Û‘¶‚·‚éƒŒƒR[ƒhŒ^
	//**************************************************************************
	PDecodeESCVRAM = ^TDecodeESCVRAM;
	TDecodeESCVRAM = record
		Letter : Word;
		Attribute : TDecodeESCAttribute;
	end;

	//**************************************************************************
	// ESC ƒV[ƒPƒ“ƒX‚ÌƒfƒR[ƒhŒ‹‰Ê(DecodeESCSequence ‚Ì–ß‚è’l)‚ğ‘ã“ü‚·‚é
	// ƒŒƒR[ƒhŒ^
	//**************************************************************************
	PDecodeESCCommand = ^TDecodeESCCommand;
	TDecodeESCCommand = record
		Command : (												// ƒRƒ}ƒ“ƒhí•Ê
				DECODEESC_CLEAR,								// Á‹
				DECODEESC_SCROOL,								// ƒXƒNƒ[ƒ‹(or síœ)
				DECODEESC_INSERT,								// ‹ó”’s‘}“ü
				DECODEESC_WRITE									// •¶š•`‰æ
			);
		Rect : TRect;											// DECODEESC_CLEAR ‚ÌÁ‹lŠpŒ`
																			// DECODEESC_SCROOL/INSERT ‚ÌŠJn/I—¹s”(y ‚Ì‚İg—p)
																			// DECODEESC_WRITE ‚Ì•`‰æˆÊ’u
		ScroolLine : Integer;							// DECODEESC_SCROOL/INSERT ‚ÌƒXƒNƒ[ƒ‹^‘}“ü’i”(>0)
		Text : string;										// DECODEESC_WRITE ‚Ì•`‰æ•¶š
		Attribute : TDecodeESCAttribute;	// DECODEESC_WRITE ‚Ì•`‰æ•¶šƒAƒgƒŠƒrƒ…[ƒg
	end;

	//**************************************************************************
	// •¶š—ñ‚Ì’†‚Ì“Á’è‚Ì•¶š‚ğæ“¾‚·‚é‚Æ‚«‚Ég‚¤ƒNƒ‰ƒX
	// ”ÍˆÍŠO‚¾‚Æ—áŠO EStrPosError ‚ğ¶¬‚·‚é
	//**************************************************************************
	TStrPos = class(TObject)
	private
		{ Private éŒ¾ }
		FStr : String;
		FLength : Integer;
	protected
		{ Protected éŒ¾ }
		procedure SetStr(Value : String);
		function GetChar(Index: Integer): Char;
		procedure PutChar(Index: Integer; Item: Char);
	public
		{ Public éŒ¾ }
		constructor Create;
		property Text : String read FStr write SetStr;
		property Items[Index: Integer]: Char read GetChar write PutChar; default;
		property Length : Integer read FLength;
	end;

	//**************************************************************************
	// TDecodeESCCommand —p TListB—v‘f‚Ìƒƒ‚ƒŠŠm•ÛAŠJ•ú‚Í©“®“I‚És‚¤)
	//**************************************************************************
  TDecodeESCCommandList = class(TList)
	protected
    { Protected éŒ¾ }
		function Get(Index: Integer): PDecodeESCCommand;
		procedure Put(Index: Integer; Item: PDecodeESCCommand);
	public
		{ Public éŒ¾ }
		destructor Destroy; override;
		function Add(Item: TDecodeESCCommand): Integer;
		procedure Insert(Index: Integer; Item: TDecodeESCCommand);
		procedure Clear;
		procedure Delete(Index: Integer);
		property Items[Index: Integer]: PDecodeESCCommand read Get write Put; default;
	end;

	//**************************************************************************
	// ”š(Integer)—p TListB—v‘f‚Ìƒƒ‚ƒŠŠm•ÛAŠJ•ú‚Í©“®“I‚És‚¤)
	//**************************************************************************
	TIntegerList = class(TList)
	protected
    { Protected éŒ¾ }
		function Get(Index: Integer): Integer;
		procedure Put(Index: Integer; Item: Integer);
	public
    { Public éŒ¾ }
		destructor Destroy; override;
		function Add(Item: Integer): Integer;
		procedure Insert(Index: Integer; Item: Integer);
		procedure Clear;
		procedure Delete(Index: Integer);
		property Items[Index: Integer]: Integer read Get write Put; default;
	end;

	//**************************************************************************
  // ESC ƒV[ƒPƒ“ƒXƒfƒR[ƒhƒNƒ‰ƒX
	//**************************************************************************
  TDecodeESCSequence = class(TObject)
  private
    { Private éŒ¾ }
		FColor : TColor;
		FPosition : TPoint;
		FSavePosition : TPoint;
		FNowAttribute : TDecodeESCAttribute;
		FSaveAttribute : TDecodeESCAttribute;
		FScreen : Array[0..SCREEN_HEIGHT - 1, 0..SCREEN_WIDTH - 1] of TDecodeESCVRAM;

	protected
		{ Protected éŒ¾ }
    procedure DecodeNum(StrPos : TStrPos; var Pos1 : Integer; IntegerList : TIntegerList);
		procedure Scrool(ScroolLine : Integer; DecodeESCCommandList : TDecodeESCCommandList);
		function GetVRAM(x, y : Integer) : TDecodeESCVRAM;
		function GetScanLine(y : Integer) : PDecodeESCVRAM;
	public
		{ Public éŒ¾ }
		constructor Create;
		destructor Destroy; override;
		procedure Init;																// “à•”ƒoƒbƒtƒ@Á‹•‰Šú‰»
		procedure DecodeESCSequence(										// ƒGƒXƒP[ƒvƒV[ƒPƒ“ƒX‚ÌƒfƒR[ƒh
			const ESCSequence : String;
			DecodeESCList: TDecodeESCCommandList
		);
		property Color : TColor read FColor;
		property Position : TPoint read FPosition;
		property VRAM[x, y : Integer] : TDecodeESCVRAM read GetVRAM;
		property ScanLine[y : Integer] : PDecodeESCVRAM read GetScanLine;
	end;

  
implementation


//###########################################################################
//###########################################################################
// TStrPos ƒNƒ‰ƒX
//###########################################################################
//###########################################################################

//***************************************************************************
// ƒRƒ“ƒXƒgƒ‰ƒNƒ^
//***************************************************************************
constructor TStrPos.Create;
begin
	FStr := '';
	FLength := 0;
end;

//***************************************************************************
// •¶š—ñ‘ã“ü
//***************************************************************************
procedure TStrPos.SetStr(Value : String);
begin
	FStr := Value;
	FLength := System.Length(FStr);
end;


//***************************************************************************
// •¶š‘ã“ü
//***************************************************************************
procedure TStrPos.PutChar(Index: Integer; Item: Char);
begin
	if(Index < 0) then begin
		raise EStrPosError.Create(MSG_ERR_STRPOS_WRITE_UNDER);
	end else if(Index > FLength) then begin
		raise EStrPosError.Create(MSG_ERR_STRPOS_WRITE_OVER);
	end else begin
		FStr[Index] := Item;
	end;
end;


//***************************************************************************
// •¶šæ“¾
//***************************************************************************
function TStrPos.GetChar(Index: Integer): Char;
begin
	if(Index < 0) then begin
		raise EStrPosError.Create(MSG_ERR_STRPOS_READ_UNDER);
	end else if(Index > FLength) then begin
		raise EStrPosError.Create(MSG_ERR_STRPOS_READ_OVER);
	end else begin
		Result := FStr[Index];
	end;
end;



//###########################################################################
//###########################################################################
// TDecodeESCCommandList ƒNƒ‰ƒX
//###########################################################################
//###########################################################################

//***************************************************************************
// ƒfƒXƒgƒ‰ƒNƒ^
//***************************************************************************
destructor TDecodeESCCommandList.Destroy;
begin
	Clear;
	inherited Destroy;
end;


//***************************************************************************
// Item ’Ç‰Á
//***************************************************************************
function TDecodeESCCommandList.Add(Item: TDecodeESCCommand): Integer;
var
	p_DecodeESCCommand : PDecodeESCCommand;
begin
	New(p_DecodeESCCommand);
	p_DecodeESCCommand^ := Item;
	result := inherited Add(p_DecodeESCCommand);
end;


//***************************************************************************
// Item ‘}“ü
//***************************************************************************
procedure TDecodeESCCommandList.Insert(Index: Integer; Item: TDecodeESCCommand);
var
	p_DecodeESCCommand : PDecodeESCCommand;
begin
	New(p_DecodeESCCommand);
	p_DecodeESCCommand^ := Item;
	inherited Insert(Index, p_DecodeESCCommand);
end;


//***************************************************************************
// Item íœ
//***************************************************************************
procedure TDecodeESCCommandList.Delete(Index: Integer);
begin
	if (Index < 0) or (Index >= Count) then begin
		raise EDecodeESCCommandListError.Create(MSG_ERR_LISTINDEX);
	end;

	if(Items[Index] <> nil) then begin
		Dispose(inherited Items[Index]);
		inherited Delete(Index);
		Pack;
	end;
end;


//***************************************************************************
// Item ‘Síœ
//***************************************************************************
procedure TDecodeESCCommandList.Clear;
var
	i : Integer;
begin
	// Item ‚ÌŠJ•ú
	for i := 0 to Count-1 do begin
		if(Items[i] <> nil) then begin
			Dispose(inherited Items[i]);
		end;
	end;
	inherited Clear;
	Pack;
end;


//***************************************************************************
// Item æ“¾
//***************************************************************************
function TDecodeESCCommandList.Get(Index : Integer) : PDecodeESCCommand;
begin
	result := inherited Get(Index);
end;


//***************************************************************************
// Item ‘ã“ü
//***************************************************************************
procedure TDecodeESCCommandList.Put(Index: Integer; Item: PDecodeESCCommand);
begin
	TDecodeESCCommand(inherited Items[Index]^) := Item^;
end;



//###########################################################################
//###########################################################################
// TIntegerList ƒNƒ‰ƒX
//###########################################################################
//###########################################################################

//***************************************************************************
// ƒfƒXƒgƒ‰ƒNƒ^
//***************************************************************************
destructor TIntegerList.Destroy;
begin
	Clear;
	inherited Destroy;
end;


//***************************************************************************
// Item ’Ç‰Á
//***************************************************************************
function TIntegerList.Add(Item: Integer): Integer;
var
	p_IntegerItem : PInteger;
begin
	New(p_IntegerItem);
	p_IntegerItem^ := Item;
	result := inherited Add(p_IntegerItem);
end;


//***************************************************************************
// Item ‘}“ü
//***************************************************************************
procedure TIntegerList.Insert(Index: Integer; Item: Integer);
var
	p_IntegerItem : PInteger;
begin
	New(p_IntegerItem);
	p_IntegerItem^ := Item;
	inherited Insert(Index, p_IntegerItem);
end;


//***************************************************************************
// Item íœ
//***************************************************************************
procedure TIntegerList.Delete(Index: Integer);
begin
	if (Index < 0) or (Index >= Count) then begin
		raise EIntegerListError.Create(MSG_ERR_LISTINDEX);
	end;

	Dispose(inherited Items[Index]);
	inherited Delete(Index);
	Pack;
end;


//***************************************************************************
// Item ‘Síœ
//***************************************************************************
procedure TIntegerList.Clear;
var
	i : Integer;
begin
	// Item ‚ÌŠJ•ú
	for i := 0 to Count-1 do begin
		Dispose(inherited Items[i]);
	end;
	inherited Clear;
	Pack;
end;


//***************************************************************************
// Item æ“¾
//***************************************************************************
function TIntegerList.Get(Index : Integer) : Integer;
begin
	result := PInteger(inherited Get(Index))^;
end;


//***************************************************************************
// Item ‘ã“ü
//***************************************************************************
procedure TIntegerList.Put(Index: Integer; Item: Integer);
begin
	Integer(inherited Items[Index]^) := Item;
end;



//###########################################################################
//###########################################################################
// TDecodeESCSequence ƒNƒ‰ƒX
//###########################################################################
//###########################################################################

//***************************************************************************
// ƒRƒ“ƒXƒgƒ‰ƒNƒ^
//***************************************************************************
constructor TDecodeESCSequence.Create;
begin
	inherited Create;
	FSavePosition.X := 0;
	FSavePosition.Y := 0;
	FSaveAttribute.Color := clWhite;
	FSaveAttribute.LetterCode := CHAR_ASCII;
	FSaveAttribute.Attribute_Sub := [];
	Init
end;


//***************************************************************************
// ƒfƒXƒgƒ‰ƒNƒ^
//***************************************************************************
destructor TDecodeESCSequence.Destroy;
begin
end;


//***************************************************************************
// VRAM ‚Ìæ“¾
//***************************************************************************
function TDecodeESCSequence.GetVRAM(x, y : Integer) : TDecodeESCVRAM;
begin
	Result := FScreen[y, x];
end;


//***************************************************************************
// ScanLine ‚Ìæ“¾
//***************************************************************************
function TDecodeESCSequence.GetScanLine(y : Integer) : PDecodeESCVRAM;
begin
	Result := @FScreen[y, 0];
end;


//***************************************************************************
// ‰Šú‰»A‰æ–ÊÁ‹
//***************************************************************************
procedure TDecodeESCSequence.Init;
var
	x, y : Integer;
	TempVRAM : TDecodeESCVRAM;
begin
	FColor := clWhite;
	FPosition.X := 0;
	FPosition.Y := 0;
	FNowAttribute.Color := clWhite;
	FNowAttribute.LetterCode := CHAR_ASCII;
	FNowAttribute.Attribute_Sub := [];

	TempVRAM.Letter := $20;			// ”¼ŠpƒXƒy[ƒX
	TempVRAM.Attribute := FNowAttribute;
	for y := 0 to SCREEN_HEIGHT - 1 do begin
		for x := 0 to SCREEN_WIDTH - 1 do begin
			FScreen[y, x] := TempVRAM;
		end;
	end;
end;


//***************************************************************************
// ”š‚ğ IntegerList ‚ÖŠi”[
// u;v‚Å‹æØ‚ç‚ê‚½•¡”‚Ì”š‚ğ“Ç‚İ‚İ‰Â
//***************************************************************************
procedure TDecodeESCSequence.DecodeNum(StrPos : TStrPos; var Pos1 : Integer; IntegerList : TIntegerList);
var
	Code : Integer;
begin
	// ”š‚Ì—ñ‚ªI‚í‚é‚Ü‚Åƒ‹[ƒv(??;??;....x)
	while(StrPos[Pos1] in ['0'..'9']) do begin
		// ”š‚ğØ‚èæ‚Á‚Ä Code ‚É‘ã“ü
		Code := 0;
		repeat
			Code := Code * 10 + Ord(StrPos[Pos1]) - Ord('0');
			Inc(Pos1);
    until(Pos1 > StrPos.Length) or not(StrPos[Pos1] in ['0'..'9']);

		// IntegerList ‚É’Ç‰Á
		IntegerList.Add(Code);

		// u;v‚ª‚ ‚Á‚ÄI’[‚¶‚á‚È‚¯‚ê‚ÎŒp‘±
		if(Pos1 <= StrPos.Length) and (StrPos[Pos1] = ';') then begin
			Inc(Pos1);
			if(Pos1 <= StrPos.Length) then Continue;
    end;
		Break;
  end;
end;


//***************************************************************************
// ’PƒƒXƒNƒ[ƒ‹i‘S‰æ–ÊA‡•ûŒü‚Ì‚İj
//***************************************************************************
procedure TDecodeESCSequence.Scrool(
	ScroolLine : Integer;
	DecodeESCCommandList : TDecodeESCCommandList
);
var
	DecodeESCCommand : TDecodeESCCommand;
	x, y : Integer;
	TempVRAM : TDecodeESCVRAM;
begin
	if(ScroolLine > 0) then begin
		DecodeESCCommand.Command := DECODEESC_SCROOL;
    DecodeESCCommand.Rect.Left   := 0;
    DecodeESCCommand.Rect.Top    := 0;
    DecodeESCCommand.Rect.Right  := SCREEN_WIDTH  - 1;
    DecodeESCCommand.Rect.Bottom := SCREEN_HEIGHT - 1;
    DecodeESCCommand.ScroolLine  := ScroolLine;
		DecodeESCCommand.Text := '';
    FNowAttribute.LetterCode := CHAR_ASCII;
		DecodeESCCommand.Attribute := FNowAttribute;

		// ƒRƒ}ƒ“ƒh”­s
		DecodeESCCommandList.Add(DecodeESCCommand);

		// FScreen ‚ğƒXƒNƒ[ƒ‹‚³‚¹‚é
		//@ memcpy ‚Å‚‘¬‰»
		for y := 0 to SCREEN_HEIGHT - 1 - ScroolLine do begin
			for x := 0 to SCREEN_WIDTH - 1 do begin
				FScreen[y, x] := FScreen[y + ScroolLine, x];
			end;
		end;

		// ‹ó‚«‚ÉƒfƒtƒHƒ‹ƒg’l‚ğ–„‚ß‚Ş
		TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
		TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
		for y := SCREEN_HEIGHT - ScroolLine to SCREEN_HEIGHT - 1 do begin
			for x := 0 to SCREEN_WIDTH - 1 do begin
				FScreen[y, x] := TempVRAM;
			end;
		end;
	end else begin
		raise EDecodeESCSequenceError.Create(MSG_ERR_SCROOL_BELOW0);
	end;
end;


//***************************************************************************
// ƒfƒR[ƒh
//***************************************************************************
procedure TDecodeESCSequence.DecodeESCSequence(
	const ESCSequence : String;
	DecodeESCList: TDecodeESCCommandList
);
var
	Pos1 : Integer;													// •¶š—ñ‘–¸—p
	DecodeESCCommand : TDecodeESCCommand;		// ”­s—pƒV[ƒPƒ“ƒX‘ã“ü
	DecodeESCCommand2 : TDecodeESCCommand;	// ”­s—pƒV[ƒPƒ“ƒX‘ã“ü(ƒXƒy[ƒX”­s—p)
	IntegerList : TIntegerList;							// ƒGƒXƒP[ƒvƒV[ƒPƒ“ƒX‚Ì”š‘ã“ü—p
	StrPos : TStrPos;												// •¶š—ñ“Ç‚İo‚µ—p(”ÍˆÍŠO‚Ì—áŠOˆ—‚ ‚è)
	x, y, i : Integer;
  TempStr : String;
	TempVRAM : TDecodeESCVRAM;
	SemiColonFlag : Boolean;

begin
	// Œ»İ‚ÌƒJ[ƒ\ƒ‹ˆÊ’uAAttribute ‚ğƒZƒbƒg
	DecodeESCCommand.Command := DECODEESC_WRITE;
	DecodeESCCommand.ScroolLine := 0;
  DecodeESCCOmmand.Rect.Left := FPosition.X;
  DecodeESCCOmmand.Rect.Top := FPosition.Y;
	DecodeESCCommand.Text := '';
	DecodeESCCommand.Attribute := FNowAttribute;

	Pos1 := 1;
	StrPos := TStrPos.Create;
	IntegerList := TIntegerList.Create;
	try
		StrPos.Text := ESCSequence;

		//=======================================================================
		// •¶š—ñ‘–¸
		//=======================================================================
		while(Pos1 <= StrPos.Length)  do begin
			//---------------------------------------------------------------------
			// 0x07  ƒuƒU[‚ğ‚P•b–Â‚ç‚·i–³‹j
			//---------------------------------------------------------------------
			if(StrPos[Pos1] = #$07) then begin
				Inc(Pos1);

			//---------------------------------------------------------------------
			// 0x08  ƒJ[ƒ\ƒ‹‚ğ‚P•¶š¶‚ÉˆÚ“®
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$08) then begin
				Inc(Pos1);
				Dec(FPosition.X);
				if(FPosition.X < 0) then begin
					if(FPosition.Y > 0) then begin
	        	FPosition.X := SCREEN_WIDTH - 1;
						Dec(FPosition.Y);
					end else begin
						FPosition.X := 0;
            FPosition.Y := 0;
          end;
				end;

			//---------------------------------------------------------------------
			// 0x0a  ƒJ[ƒ\ƒ‹‚ğ‚P•¶š‰º‚ÉˆÚ“®
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] in [#$0a]) then begin
				Inc(Pos1);
				Inc(FPosition.Y);
				if(FPosition.Y >= SCREEN_HEIGHT) then begin
          if(FPosition.Y - SCREEN_HEIGHT + 1 > 0) then begin
	          Scrool(FPosition.Y - SCREEN_HEIGHT + 1, DecodeESCList);
					end;
					FPosition.Y := SCREEN_HEIGHT - 1;
				end;

			//---------------------------------------------------------------------
			// 0x0b  ƒJ[ƒ\ƒ‹‚ğ‚P•¶šã‚ÉˆÚ“®
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$0b) then begin
				Inc(Pos1);
				if(FPosition.Y > 0) then begin
					Dec(FPosition.Y);
				end;

			//---------------------------------------------------------------------
			// 0x0c  ƒJ[ƒ\ƒ‹‚ğ‚P•¶š‰E‚ÉˆÚ“®
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$0c) then begin
				Inc(Pos1);
				Inc(FPosition.X);
				if(FPosition.X >= SCREEN_WIDTH) then begin
					Inc(FPosition.Y);
					if(FPosition.Y >= SCREEN_HEIGHT) then begin
						if(FPosition.Y - SCREEN_HEIGHT + 1 > 0) then begin
            	Scrool(FPosition.Y - SCREEN_HEIGHT + 1, DecodeESCList);
						end;
						FPosition.Y := SCREEN_HEIGHT - 1;
					end;
					FPosition.X := FPosition.X - SCREEN_WIDTH;
				end;

			//---------------------------------------------------------------------
			// 0x0d  ƒJ[ƒ\ƒ‹‚ğs‚Ì“ª‚ÉˆÚ“®
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$0d) then begin
				Inc(Pos1);
				FPosition.X := 0;

			//---------------------------------------------------------------------
			// 0x1a  ‰æ–ÊÁ‹
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$1a) then begin
				Inc(Pos1);

				DecodeESCCommand.Command := DECODEESC_CLEAR;
		    DecodeESCCommand.Rect.Left   := 0;
		    DecodeESCCommand.Rect.Top    := 0;
		    DecodeESCCommand.Rect.Right  := SCREEN_WIDTH  - 1;
    		DecodeESCCommand.Rect.Bottom := SCREEN_HEIGHT - 1;
				DecodeESCCommand.ScroolLine := 0;
				DecodeESCCommand.Text := '';
				FNowAttribute.LetterCode := CHAR_ASCII;
				DecodeESCCommand.Attribute := FNowAttribute;

				// ƒRƒ}ƒ“ƒh”­s
				DecodeESCList.Add(DecodeESCCommand);

				FPosition.X := 0;
				FPosition.Y := 0;

        // ƒNƒŠƒA‚µ‚ÄƒfƒtƒHƒ‹ƒg’l‚ğ–„‚ß‚Ş
				TempVRAM.Letter := $20;
        TempVRAM.Attribute := FNowAttribute;
       	for y := 0 to SCREEN_HEIGHT - 1 do begin
         	for x := 0 to SCREEN_WIDTH - 1 do begin
						FScreen[y, x] := TempVRAM;
 					end;
				end;

			//---------------------------------------------------------------------
			// 0x1b  ƒGƒXƒP[ƒvƒR[ƒh(ESC)
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$1b) then begin
				Inc(Pos1);
				//-------------------------------------------------------------------
				// ESC =lc  ƒJ[ƒ\ƒ‹‚ğ(c,l)ˆÊ’u‚ÉˆÚ“®
				//-------------------------------------------------------------------
				if(StrPos[Pos1] = '=') then begin
					Inc(Pos1);
					FPosition.Y := Ord(StrPos[Pos1]) - $20;
					Inc(Pos1);
					FPosition.X := Ord(StrPos[Pos1]) - $20;
					Inc(Pos1);

					// X, Y ‚Ì”ÍˆÍƒ`ƒFƒbƒN
					if(FPosition.X < 0) then begin
						FPosition.X := 0;
					end else if(FPosition.X >= SCREEN_WIDTH) then begin
						FPosition.X := SCREEN_WIDTH - 1;
					end;

					if(FPosition.Y < 0) then begin
						FPosition.Y := 0;
					end else if(FPosition.Y >= SCREEN_HEIGHT) then begin
						FPosition.Y := SCREEN_HEIGHT - 1;
					end;

				//-------------------------------------------------------------------
				// ESC D  ƒJ[ƒ\ƒ‹‚ğ‚Ps‰º‚ÉˆÚ“®
				//-------------------------------------------------------------------
				end else if(StrPos[Pos1] = 'D') then begin
					Inc(Pos1);
					Inc(FPosition.Y);
					if(FPosition.Y >= SCREEN_HEIGHT) then begin
						Scrool(FPosition.Y - SCREEN_HEIGHT + 1, DecodeESCList);
						FPosition.Y := SCREEN_HEIGHT - 1;
					end;

				//-------------------------------------------------------------------
				// ESC E  ƒjƒ…[ƒ‰ƒCƒ“(=CRLF)
				//-------------------------------------------------------------------
				end else if(StrPos[Pos1] = 'E') then begin
					Inc(Pos1);
					FPosition.X := 0;
					Inc(FPosition.Y);
					if(FPosition.Y >= SCREEN_HEIGHT) then begin
						Scrool(FPosition.Y - SCREEN_HEIGHT + 1, DecodeESCList);
						FPosition.Y := SCREEN_HEIGHT - 1;
					end;

				//-------------------------------------------------------------------
				// ESC M  ƒJ[ƒ\ƒ‹‚ğˆê•¶šã‚ÉˆÚ“®
				//-------------------------------------------------------------------
				end else if(StrPos[Pos1] = 'M') then begin
					Inc(Pos1);
					if(FPosition.Y > 0) then begin
						Dec(FPosition.Y);
					end;

				//-------------------------------------------------------------------
				// ESC *  ƒNƒŠƒAƒXƒNƒŠ[ƒ“
				//-------------------------------------------------------------------

				end else if(StrPos[Pos1] = '*') then begin
					Inc(Pos1);
					DecodeESCCommand.Command := DECODEESC_CLEAR;
			    DecodeESCCommand.Rect.Left   := 0;
			    DecodeESCCommand.Rect.Top    := 0;
			    DecodeESCCommand.Rect.Right  := SCREEN_WIDTH  - 1;
			    DecodeESCCommand.Rect.Bottom := SCREEN_HEIGHT - 1;
          DecodeESCCommand.ScroolLine := 0;
					DecodeESCCommand.Text := '';
					FNowAttribute.LetterCode := CHAR_ASCII;
					DecodeESCCommand.Attribute := FNowAttribute;

					// ƒRƒ}ƒ“ƒh”­s
					DecodeESCList.Add(DecodeESCCommand);

					FPosition.X := 0;
					FPosition.Y := 0;

	        // ƒNƒŠƒA‚µ‚ÄƒfƒtƒHƒ‹ƒg’l‚ğ–„‚ß‚Ş
					TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
					TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
  	     	for y := 0 to SCREEN_HEIGHT - 1 do begin
    	     	for x := 0 to SCREEN_WIDTH - 1 do begin
							FScreen[y, x] := TempVRAM;
	 					end;
					end;

				//-------------------------------------------------------------------
				// ESC [
				//-------------------------------------------------------------------
				end else if(StrPos[Pos1] = '[') then begin
					Inc(Pos1);

					// ”š—pƒŠƒXƒg‚É“Ç‚İ‚İ
					IntegerList.Clear;
					DecodeNum(StrPos, Pos1, IntegerList);

					//-----------------------------------------------------------------
					// ESC [pl;pcH  or ESC [pl;pcf  ƒJ[ƒ\ƒ‹‚ğ(pc,pl)ˆÊ’u‚ÉˆÚ“®
					//-----------------------------------------------------------------
					if(StrPos[Pos1] in ['H','f']) then begin
						Inc(Pos1);

						// ‚Q‚Â‘µ‚Á‚Ä‚È‚¢‚Æ–³ˆÓ–¡
						if(IntegerList.Count >= 2) then begin
							FPosition.X := IntegerList[1] - 1;
							FPosition.Y := IntegerList[0] - 1;

							// ”ÍˆÍŠO‚Ì‚Æ‚«‚Í‰æ–Ê“à‚Éû‚ß‚é
							if(FPosition.X < 0) then begin
								FPosition.X := 0;
							end;
							if(FPosition.X >= SCREEN_WIDTH) then begin
								FPosition.X := SCREEN_WIDTH - 1;
							end;

							if(FPosition.Y < 0) then begin
								FPosition.Y := 0;
							end;
							if(FPosition.Y >= SCREEN_HEIGHT) then begin
								FPosition.Y := SCREEN_HEIGHT - 1;
							end;
						end;

					//-----------------------------------------------------------------
					// ESC [pnA  ƒJ[ƒ\ƒ‹‚ğ pn sƒAƒbƒvipn‚ª‚È‚¢ê‡‚Í‚PsƒAƒbƒvj
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'A') then begin
						Inc(Pos1);
						if(IntegerList.Count > 0) then begin
							Dec(FPosition.Y, IntegerList[0]);
						end else begin
							Dec(FPosition.Y);
						end;

						if(FPosition.Y < 0) then begin
							FPosition.Y := 0;
						end;

					//-----------------------------------------------------------------
					// ESC [pnB  ƒJ[ƒ\ƒ‹‚ğ pn sƒ_ƒEƒ“ipn‚ª‚È‚¢ê‡‚Í‚Psƒ_ƒEƒ“j
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'B') then begin
						Inc(Pos1);
						if(IntegerList.Count > 0) then begin
							Inc(FPosition.Y, IntegerList[0]);
						end else begin
							Inc(FPosition.Y);
						end;

						if(FPosition.Y >= SCREEN_HEIGHT) then begin
							Scrool(FPosition.Y - SCREEN_HEIGHT + 1, DecodeESCList);
							FPosition.Y := SCREEN_HEIGHT - 1;
						end;

					//-----------------------------------------------------------------
					// ESC [pnC  ƒJ[ƒ\ƒ‹‚ğ pn •¶š‰E‚ÉˆÚ“®ipn‚ª‚È‚¢ê‡‚Í‚P•¶šˆÚ“®j
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'C') then begin
						Inc(Pos1);
						if(IntegerList.Count > 0) then begin
							Inc(FPosition.X, IntegerList[0]);
						end else begin
							Inc(FPosition.X);
						end;

						if(FPosition.X >= SCREEN_WIDTH) then begin
							FPosition.X := SCREEN_WIDTH - 1;
						end;

					//-----------------------------------------------------------------
					// ESC [pnD  ƒJ[ƒ\ƒ‹‚ğ pn •¶š¶‚ÉˆÚ“®ipn‚ª‚È‚¢ê‡‚Í‚P•¶šˆÚ“®j
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'D') then begin
						Inc(Pos1);
						if(IntegerList.Count > 0) then begin
							Dec(FPosition.X, IntegerList[0]);
						end else begin
							Dec(FPosition.X);
						end;

						if(FPosition.X < 0) then begin
							FPosition.X := 0;
						end;

					//-----------------------------------------------------------------
					// ESC [s  ƒJ[ƒ\ƒ‹ˆÊ’u‚Æ•¶š‘®«‚ğƒZ[ƒu
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 's') then begin
						Inc(Pos1);
//						¡•`‰æ‚µ‚Ä‚¢‚é•¶š‘®«
						FSavePosition := FPosition;
						FSaveAttribute := FNowAttribute;

					//-----------------------------------------------------------------
					// ESC [u  ƒJ[ƒ\ƒ‹ˆÊ’u‚Æ•¶š‘®«‚ğ–ß‚·
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'u') then begin
						Inc(Pos1);
						FPosition := FSavePosition;
						FNowAttribute := FSaveAttribute;

					//-----------------------------------------------------------------
					// ESC [6n  ƒRƒ“ƒ\[ƒ‹‚ÉƒJ[ƒ\ƒ‹ˆÊ’u‚ğ•Ô‚·(–³‹j
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'n') then begin
						Inc(Pos1);
					
					//-----------------------------------------------------------------
					// ESC [?J  ƒNƒŠƒAis‚ğ‚Ü‚½‚®j
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'J') then begin
						Inc(Pos1);

						// ESC [J ‚Ìê‡‚Í ESC [0J ‚Æ“¯‚¶
						if(IntegerList.Count = 0) then begin
              IntegerList.Add(0);
            end;

						case IntegerList[0] of
						0:
							//-------------------------------------------------------------
							// ESC [0J  ƒJ[ƒ\ƒ‹ˆÊ’u‚©‚çÅIs‚Ì‰E’[‚Ü‚ÅƒNƒŠƒA
							//-------------------------------------------------------------
							begin
								// ƒJ[ƒ\ƒ‹s‚ğÁ‹
								DecodeESCCommand.Command			:= DECODEESC_CLEAR;

								// SJIS2 ‚©‚çÁ‚µn‚ß‚æ‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶š‘O‚©‚çÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS2) then begin
									DecodeESCCommand.Rect.Left		:= FPosition.X - 1;
								end else begin
									DecodeESCCommand.Rect.Left		:= FPosition.X;
								end;
								DecodeESCCommand.Rect.Top			:= FPosition.Y;
								DecodeESCCommand.Rect.Right		:= SCREEN_WIDTH  - 1;
								DecodeESCCommand.Rect.Bottom	:= FPosition.Y;
								DecodeESCCommand.ScroolLine		:= 0;
								FNowAttribute.LetterCode			:= CHAR_ASCII;
								DecodeESCCommand.Attribute		:= FNowAttribute;
								DecodeESCCommand.Text					:= '';

								// ƒRƒ}ƒ“ƒh”­s
								DecodeESCList.Add(DecodeESCCommand);

								TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
								TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
								// SJIS2 ‚©‚çÁ‚µn‚ß‚æ‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶š‘O‚©‚çÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS2) then begin
									for x := FPosition.X - 1 to SCREEN_WIDTH - 1 do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end else begin
									for x := FPosition.X to SCREEN_WIDTH - 1 do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end;

								if(FPosition.Y + 1 <= SCREEN_HEIGHT - 1) then begin
									// ƒJ[ƒ\ƒ‹s‚æ‚è‰º‚Ìs‚ğÁ‹
									DecodeESCCommand.Command			:= DECODEESC_CLEAR;
									DecodeESCCommand.Rect.Left		:= 0;
									DecodeESCCommand.Rect.Top			:= FPosition.Y + 1;
									DecodeESCCommand.Rect.Right		:= SCREEN_WIDTH  - 1;
									DecodeESCCommand.Rect.Bottom	:= SCREEN_HEIGHT - 1;
									DecodeESCCommand.ScroolLine		:= 0;
									FNowAttribute.LetterCode			:= CHAR_ASCII;
									DecodeESCCommand.Attribute		:= FNowAttribute;
									DecodeESCCommand.Text					:= '';

									// ƒRƒ}ƒ“ƒh”­s
									DecodeESCList.Add(DecodeESCCommand);

									TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
									TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
									for y := FPosition.Y + 1 to SCREEN_HEIGHT - 1 do begin
										for  x := 0 to SCREEN_WIDTH - 1 do begin
											FScreen[y, x] := TempVRAM;
										end;
									end;
								end;
							end;

						1:
							//-------------------------------------------------------------
							// ESC [1J  æ“ªs‚Ì¶’[‚©‚çƒJ[ƒ\ƒ‹ˆÊ’u‚Ü‚ÅƒNƒŠƒA
							//-------------------------------------------------------------
							begin
								if(FPosition.Y >= 1) then begin
									// ƒJ[ƒ\ƒ‹s‚æ‚èã‚Ìs‚ğÁ‹
									DecodeESCCommand.Command			:= DECODEESC_CLEAR;
									DecodeESCCommand.Rect.Left		:= 0;
									DecodeESCCommand.Rect.Top			:= 0;
									DecodeESCCommand.Rect.Right		:= SCREEN_WIDTH  - 1;
									DecodeESCCommand.Rect.Bottom	:= FPosition.Y - 1;
									DecodeESCCommand.ScroolLine		:= 0;
									FNowAttribute.LetterCode			:= CHAR_ASCII;
									DecodeESCCommand.Attribute		:= FNowAttribute;
									DecodeESCCommand.Text					:= '';

									// ƒRƒ}ƒ“ƒh”­s
									DecodeESCList.Add(DecodeESCCommand);

									TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
									TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
									for y := 0 to FPosition.Y - 1 do begin
										for  x := 0 to SCREEN_WIDTH - 1 do begin
											FScreen[y, x] := TempVRAM;
										end;
									end;
								end;

								// ƒJ[ƒ\ƒ‹s‚ğÁ‹
								DecodeESCCommand.Command			:= DECODEESC_CLEAR;
								DecodeESCCommand.Rect.Left		:= 0;;
								DecodeESCCommand.Rect.Top			:= FPosition.Y;

								// SJIS1 ‚Ü‚ÅÁ‚»‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶šŒã‚Ü‚ÅÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS1) then begin
									DecodeESCCommand.Rect.Right		:= FPosition.X + 1;
								end else begin
									DecodeESCCommand.Rect.Right		:= FPosition.X;
								end;
								DecodeESCCommand.Rect.Bottom	:= FPosition.Y;
								DecodeESCCommand.ScroolLine		:= 0;
								FNowAttribute.LetterCode			:= CHAR_ASCII;
								DecodeESCCommand.Attribute		:= FNowAttribute;
								DecodeESCCommand.Text					:= '';

								// ƒRƒ}ƒ“ƒh”­s
								DecodeESCList.Add(DecodeESCCommand);

								TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
								TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
								// SJIS1 ‚Ü‚ÅÁ‚»‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶šŒã‚Ü‚ÅÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS1) then begin
									for x := 0 to FPosition.X + 1 do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end else begin
									for x := 0 to FPosition.X do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end;
							end;

						2:
							//-------------------------------------------------------------
							// ESC [2J  ƒNƒŠƒAEƒXƒNƒŠ[ƒ“
							//-------------------------------------------------------------
							begin
								DecodeESCCommand.Command := DECODEESC_CLEAR;
						    DecodeESCCommand.Rect.Left   := 0;
						    DecodeESCCommand.Rect.Top    := 0;
								DecodeESCCommand.Rect.Right  := SCREEN_WIDTH  - 1;
						    DecodeESCCommand.Rect.Bottom := SCREEN_HEIGHT - 1;
                DecodeESCCommand.ScroolLine := 0;
								DecodeESCCommand.Text := '';
								FNowAttribute.LetterCode := CHAR_ASCII;
								DecodeESCCommand.Attribute := FNowAttribute;

								// ƒRƒ}ƒ“ƒh”­s
								DecodeESCList.Add(DecodeESCCommand);

								FPosition.X := 0;
								FPosition.Y := 0;

					      // ƒNƒŠƒA‚µ‚ÄƒfƒtƒHƒ‹ƒg’l‚ğ–„‚ß‚Ş
								TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
								TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
					     	for y := 0 to SCREEN_HEIGHT - 1 do begin
									for x := 0 to SCREEN_WIDTH - 1 do begin
										FScreen[y, x] := TempVRAM;
									end;
								end;
							end;
						else

									// •s³‚ÈƒGƒXƒP[ƒvƒV[ƒPƒ“ƒX
{$IFDEF DEBUG}
							raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
						end;

					//-----------------------------------------------------------------
					// ESC [?K  ƒNƒŠƒAis“àj
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'K') then begin
						Inc(Pos1);

            // ESC [K ‚Ìê‡‚Í ESC [0K ‚Æ“¯‚¶
						if(IntegerList.Count = 0) then begin
              IntegerList.Add(0);
            end;

						case IntegerList[0] of
						0:
							//-------------------------------------------------------------
							// ESC [0K  ƒJ[ƒ\ƒ‹ˆÊ’u‚©‚çs‚Ì‰E’[‚Ü‚Å‚ğƒNƒŠƒA
							//-------------------------------------------------------------
							begin
								DecodeESCCommand.Command			:= DECODEESC_CLEAR;

								// SJIS2 ‚©‚çÁ‚µn‚ß‚æ‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶š‘O‚©‚çÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS2) then begin
									DecodeESCCommand.Rect.Left		:= FPosition.X - 1;
								end else begin
									DecodeESCCommand.Rect.Left		:= FPosition.X;
								end;

								DecodeESCCommand.Rect.Top			:= FPosition.Y;
								DecodeESCCommand.Rect.Right		:= SCREEN_WIDTH  - 1;
								DecodeESCCommand.Rect.Bottom	:= FPosition.Y;
								DecodeESCCommand.ScroolLine		:= 0;
								FNowAttribute.LetterCode			:= CHAR_ASCII;
								DecodeESCCommand.Attribute		:= FNowAttribute;
								DecodeESCCommand.Text					:= '';

								// ƒRƒ}ƒ“ƒh”­s
								DecodeESCList.Add(DecodeESCCommand);

								TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
								TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l

								// SJIS2 ‚©‚çÁ‚µn‚ß‚æ‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶š‘O‚©‚çÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS2) then begin
									for x := FPosition.X - 1to SCREEN_WIDTH - 1 do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end else begin
									for x := FPosition.X to SCREEN_WIDTH - 1 do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end;

							end;

						1:
							//-------------------------------------------------------------
							// ESC [1K  s‚Ì¶’[‚©‚çƒJ[ƒ\ƒ‹ˆÊ’u‚Ü‚Å‚ğƒNƒŠƒA
							//-------------------------------------------------------------
							begin
								DecodeESCCommand.Command			:= DECODEESC_CLEAR;
						    DecodeESCCommand.Rect.Left		:= 0;
						    DecodeESCCommand.Rect.Top			:= FPosition.Y;

								// SJIS1 ‚Ü‚ÅÁ‚»‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶šŒã‚Ü‚ÅÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS1) then begin
									DecodeESCCommand.Rect.Right		:= FPosition.X + 1;
								end else begin
									DecodeESCCommand.Rect.Right		:= FPosition.X;
								end;

								DecodeESCCommand.Rect.Bottom	:= FPosition.Y;
								DecodeESCCommand.ScroolLine		:= 0;
								FNowAttribute.LetterCode			:= CHAR_ASCII;
								DecodeESCCommand.Attribute		:= FNowAttribute;
								DecodeESCCommand.Text					:= '';

								// ƒRƒ}ƒ“ƒh”­s
								DecodeESCList.Add(DecodeESCCommand);

								TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
								TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l

								// SJIS1 ‚Ü‚ÅÁ‚»‚¤‚Æ‚·‚é‚Æ‚«‚Í‚P•¶šŒã‚Ü‚ÅÁ‚·
								if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS1) then begin
									for x := 0 to FPosition.X + 1 do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end else begin
									for x := 0 to FPosition.X do begin
										FScreen[FPosition.Y, x] := TempVRAM;
									end;
								end;
							end;

						2:
							//-------------------------------------------------------------
							// ESC [2K  ƒJ[ƒ\ƒ‹s‚Ì•¶š‚ğ‚·‚×‚ÄƒNƒŠƒA
							//-------------------------------------------------------------
							begin
								DecodeESCCommand.Command			:= DECODEESC_CLEAR;
						    DecodeESCCommand.Rect.Left		:= 0;
						    DecodeESCCommand.Rect.Top			:= FPosition.Y;
						    DecodeESCCommand.Rect.Right		:= SCREEN_WIDTH  - 1;
						    DecodeESCCommand.Rect.Bottom	:= FPosition.Y;
								DecodeESCCommand.ScroolLine		:= 0;
								FNowAttribute.LetterCode			:= CHAR_ASCII;
								DecodeESCCommand.Attribute		:= FNowAttribute;
								DecodeESCCommand.Text					:= '';

								// ƒRƒ}ƒ“ƒh”­s
								DecodeESCList.Add(DecodeESCCommand);

								TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
								TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
								for x := 0 to SCREEN_WIDTH - 1 do begin
									FScreen[FPosition.Y, x] := TempVRAM;
								end;
							end;

						else
							// •s³‚ÈƒGƒXƒP[ƒvƒV[ƒPƒ“ƒX
{$IFDEF DEBUG}
							raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
						end;

					//-----------------------------------------------------------------
					// ESC [pnM  pn síœipn‚ª‚È‚¢ê‡‚Í‚Psíœj
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'M') then begin
						Inc(Pos1);

						// ƒJ[ƒ\ƒ‹s‚æ‚è‰º‚ğƒXƒNƒ[ƒ‹‚³‚¹‚é
						DecodeESCCommand.Command := DECODEESC_SCROOL;
						DecodeESCCommand.Rect.Left    := 0;
						DecodeESCCommand.Rect.Top     := FPosition.Y;
						DecodeESCCommand.Rect.Right   := SCREEN_WIDTH  - 1;
						DecodeESCCommand.Rect.Bottom  := SCREEN_HEIGHT - 1;
						if(IntegerList.Count > 0) then begin
							DecodeESCCommand.ScroolLine := IntegerList[0];
						end else begin
							DecodeESCCommand.ScroolLine := 1;
						end;
						DecodeESCCommand.Text := '';
						FNowAttribute.LetterCode := CHAR_ASCII;
						DecodeESCCommand.Attribute := FNowAttribute;

						// ƒRƒ}ƒ“ƒh”­s
						DecodeESCList.Add(DecodeESCCommand);

						//@ memcpy ‚Å‚‘¬‰»
						for y := FPosition.Y to SCREEN_HEIGHT - 1 - DecodeESCCommand.ScroolLine do begin
							for  x := 0 to SCREEN_WIDTH - 1 do begin
								FScreen[y, x] := FScreen[y + DecodeESCCommand.ScroolLine , x];
							end;
						end;

						TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
						TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
						for y := SCREEN_HEIGHT - DecodeESCCommand.ScroolLine to SCREEN_HEIGHT - 1 do begin
							for  x := 0 to SCREEN_WIDTH - 1 do begin
								FScreen[y, x] := TempVRAM;
							end;
						end;

					//-----------------------------------------------------------------
					// ESC [pnL  pn s•ª‚Ì‹ó”’s‚ğ‘}“ü
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'L') then begin
						Inc(Pos1);
						// ƒJ[ƒ\ƒ‹s‚æ‚è‰º‚É‹ó”’s‚ğ‘}“ü‚·‚é
						DecodeESCCommand.Command := DECODEESC_INSERT;
						DecodeESCCommand.Rect.Left    := 0;
						DecodeESCCommand.Rect.Top     := FPosition.Y;
            DecodeESCCommand.Rect.Right   := SCREEN_WIDTH  - 1;
					  DecodeESCCommand.Rect.Bottom  := SCREEN_HEIGHT - 1;
					  if(IntegerList.Count > 0) then begin
						  DecodeESCCommand.ScroolLine := IntegerList[0];
						end else begin
							DecodeESCCommand.ScroolLine := 1;
						end;
						DecodeESCCommand.Text := '';
					  FNowAttribute.LetterCode := CHAR_ASCII;
						DecodeESCCommand.Attribute := FNowAttribute;

						// ƒRƒ}ƒ“ƒh”­s
            DecodeESCList.Add(DecodeESCCommand);

          	//@ memcpy ‚Å‚‘¬‰»
						for y := SCREEN_HEIGHT - 1 downto FPosition.Y + DecodeESCCommand.ScroolLine do begin
             	for  x := 0 to SCREEN_WIDTH - 1 do begin
								FScreen[y, x] := FScreen[y - DecodeESCCommand.ScroolLine, x];
              end;
						end;

						TempVRAM.Letter := $20;								// ”¼ŠpƒXƒy[ƒX
						TempVRAM.Attribute := FNowAttribute;  // Œ»İ‚Ì’l
						for y := FPosition.Y to FPosition.Y + DecodeESCCommand.ScroolLine - 1 do begin
							for  x := 0 to SCREEN_WIDTH - 1 do begin
								FScreen[y, x] := TempVRAM;
							end;
						end;

					//-----------------------------------------------------------------
					// ESC [ps;...;psm  •¶š‘®«‚Ìİ’èips‚ª‚È‚¢ê‡‚ÍƒfƒtƒHƒ‹ƒg’lj
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'm') then begin
						Inc(Pos1);
						
						// ‰Šú’l‚ğ‘ã“ü
						FNowAttribute.Color := clWhite;
            FNowAttribute.Attribute_Sub := [];

						for i := 0 to IntegerList.Count - 1 do begin
							case IntegerList[i] of
							 0 : ;
							 1 : Include(FNowAttribute.Attribute_Sub, HighLight);
							 2 : Include(FNowAttribute.Attribute_Sub, VerticalLine);
							 4 : Include(FNowAttribute.Attribute_Sub, UnderLine);
							 5 : Include(FNowAttribute.Attribute_Sub, Blink);
							 7 : Include(FNowAttribute.Attribute_Sub, Reverse);
							 8 : Include(FNowAttribute.Attribute_Sub, Secret);
							16 : Include(FNowAttribute.Attribute_Sub, Secret);
							17 : FNowAttribute.Color := clRed;
							18 : FNowAttribute.Color := clBlue;
							19 : FNowAttribute.Color := clFuchsia;
							20 : FNowAttribute.Color := clLime;
							21 : FNowAttribute.Color := clYellow;
							22 : FNowAttribute.Color := clAqua;
							23 : FNowAttribute.Color := clWhite;
							30 : FNowAttribute.Color := clBlack;
							31 : FNowAttribute.Color := clRed;
							32 : FNowAttribute.Color := clLime;
							33 : FNowAttribute.Color := clYellow;
							34 : FNowAttribute.Color := clBlue;
							35 : FNowAttribute.Color := clFuchsia;
							36 : FNowAttribute.Color := clAqua;
							37 : FNowAttribute.Color := clWhite;
							40 :
								begin
									FNowAttribute.Color := clBlack;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							41 :
								begin
									FNowAttribute.Color := clRed;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							42 :
								begin
									FNowAttribute.Color := clLime;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							43 :
								begin
									FNowAttribute.Color := clYellow;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							44 :
								begin
									FNowAttribute.Color := clBlue;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							45 :
								begin
									FNowAttribute.Color := clFuchsia;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							46 :
								begin
									FNowAttribute.Color := clAqua;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							47 :
								begin
									FNowAttribute.Color := clWhite;
									Include(FNowAttribute.Attribute_Sub, Reverse);
								end;
							else
{$IFDEF DEBUG}
								raise EDecodeESCSequenceError.Create(MSG_ERR_ATTRIBUTE_OUT_OF_RANGE);
{$ENDIF}
							end;
						end;

					//-----------------------------------------------------------------
					// ESC [ps;...;psp  ƒL[İ’èi–³‹j
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = 'p') then begin
						Inc(Pos1);

					//-----------------------------------------------------------------
					// ESC [>
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = '>') then begin
						Inc(Pos1);

						IntegerList.Clear;
						SemiColonFlag := False;
						// 'h' ‚Ü‚½‚Í 'l' ‚ªo‚Ä‚­‚é‚Ü‚Å”š‚ğ’T‚µ‚È‚ª‚ç“Ç‚İ‚İ
						while (Pos1 <= StrPos.Length) and (not(StrPos[Pos1] in ['h', 'l'])) do begin
							if(StrPos[Pos1] in ['0'..'9']) then begin
								DecodeNum(StrPos, Pos1, IntegerList);
							end else if(StrPos[Pos1] = ';') then begin
								SemiColonFlag := True;
								Inc(Pos1);
							end else begin
								Inc(Pos1);
							end;
						end;

						if(Pos1 <= StrPos.Length) and (SemiColonFlag = False) and (IntegerList.Count = 1) then begin
							//-------------------------------------------------------------
							// ESC [>?h
							//-------------------------------------------------------------
							if(StrPos[Pos1] = 'h') then begin

								//-----------------------------------------------------------
								// ESC [>1h  Å‰ºs‚ğƒvƒƒOƒ‰ƒ€‚Åg—p‚·‚éi–³‹j
								//-----------------------------------------------------------
								if(IntegerList[0] = 1) then begin
									Inc(Pos1);

								//-----------------------------------------------------------
								// ESC [>3h  ‚P‰æ–Ê‚Q‚Osƒ‚[ƒhi–³‹j
								//-----------------------------------------------------------
								end else if(IntegerList[0] = 3) then begin
									Inc(Pos1);

								//-----------------------------------------------------------
								// ESC [>5h  ƒJ[ƒ\ƒ‹”ñ•\¦ƒ‚[ƒhi–³‹j
								//-----------------------------------------------------------
								end else if(IntegerList[0] = 5) then begin
									Inc(Pos1);
								end else begin
{$IFDEF DEBUG}
									raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
								end;

							//-------------------------------------------------------------
							// ESC [>?l
							//-------------------------------------------------------------
							end else if(StrPos[Pos1] = 'l') then begin

								//-----------------------------------------------------------
								// ESC [>1l  Å‰ºs‚ğƒVƒXƒeƒ€‚Åg—p‚·‚éi–³‹j
								//-----------------------------------------------------------
								if(IntegerList[0] = 1) then begin
									Inc(Pos1);

								//-----------------------------------------------------------
								// ESC [>3l  ‚P‰æ–Ê‚Q‚Tsƒ‚[ƒhi–³‹j
								//-----------------------------------------------------------
								end else if(IntegerList[0] = 3) then begin
									Inc(Pos1);

								//-----------------------------------------------------------
								// ESC [>5l  ƒJ[ƒ\ƒ‹•\¦ƒ‚[ƒhi–³‹j
								//-----------------------------------------------------------
								end else if(IntegerList[0] = 5) then begin
									Inc(Pos1);
								end else begin
{$IFDEF DEBUG}
									raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
								end;
							end;
						end;
					end;

				//-------------------------------------------------------------------
				// ESC )
				//-------------------------------------------------------------------
				end else if(StrPos[Pos1] = ')') then begin
					Inc(Pos1);

					//-----------------------------------------------------------------
					// ESC )0  Š¿š•\¦ƒ‚[ƒh
					//-----------------------------------------------------------------
					if(StrPos[Pos1] = '0') then begin
          	FNowAttribute.LetterCode := CHAR_ASCII;
          	Inc(Pos1);

					//-----------------------------------------------------------------
					// ESC )3  ƒOƒ‰ƒt•¶š•\¦ƒ‚[ƒh
					//-----------------------------------------------------------------
					end else if(StrPos[Pos1] = '3') then begin
          	FNowAttribute.LetterCode := CHAR_GRAPHIC;
						Inc(Pos1);
					end;

				//-------------------------------------------------------------------
				// •s³‚ÈƒGƒXƒP[ƒvƒV[ƒPƒ“ƒXi‰ğ“Ç•s”\)
				//-------------------------------------------------------------------
				end else begin
					Inc(Pos1);
{$IFDEF DEBUG}
					raise EDecodeESCSequenceError.Create(MSG_ERR_UNDECODE_ESC);
{$ENDIF}
				end;

			//---------------------------------------------------------------------
			// ƒJ[ƒ\ƒ‹ƒz[ƒ€(0x1e)
			//---------------------------------------------------------------------
			end else if(StrPos[Pos1] = #$1e) then begin
				Inc(Pos1);
				FPosition.X := 0;
				FPosition.Y := 0;

			//---------------------------------------------------------------------
			// ‚»‚Ì‘¼(•¶šATAB)
			//---------------------------------------------------------------------
			end else begin
				DecodeESCCommand.Command     := DECODEESC_WRITE;
				DecodeESCCommand.Rect.Left   := FPosition.X;
				DecodeESCCommand.Rect.Right  := FPosition.X - 1;
				DecodeESCCommand.Rect.Top    := FPosition.Y;
				DecodeESCCommand.Rect.Bottom := FPosition.Y;
				DecodeESCCommand.Text        := '';
				DecodeESCCommand.Attribute   := FNowAttribute;

				if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS2) then begin
					// SJIS 2•¶š–Ú‚©‚ç‘‚«n‚ß‚È‚Ì‚ÅAƒJ[ƒ\ƒ‹ˆÊ’u‚ğ1•¶š‘O‚É–ß‚µA
					// ”¼ŠpƒXƒy[ƒX‚P•¶š‚Ì‚İ‚ÌƒRƒ}ƒ“ƒh‚ğ”­s‚·‚é(‘®«‚È‚µ‚Å)
					if(FPosition.X <= 0) then begin
						raise EDecodeESCSequenceError.Create(MSG_ERR_COLUMN0_SJIS2);
					end else begin
						DecodeESCCommand2 := DecodeESCCommand;
						Dec(DecodeESCCommand2.Rect.Left);
						DecodeESCCommand2.Rect.Right := DecodeESCCommand2.Rect.Left;
						DecodeESCCommand2.Text := #$20;
						DecodeESCCommand2.Attribute.Attribute_Sub := [];
						FScreen[FPosition.Y, FPosition.X - 1].Letter := $20;			// ”¼ŠpƒXƒy[ƒX
						FScreen[FPosition.Y, FPosition.X - 1].Attribute.Attribute_Sub := [];
						FScreen[FPosition.Y, FPosition.X - 1].Attribute.LetterCode := CHAR_ASCII;
						DecodeESCList.Add(DecodeESCCommand2);
					end;
				end;

				// ƒOƒ‰ƒtƒBƒbƒN•¶š‚Ìˆ—
        if(FNowAttribute.LetterCode = CHAR_GRAPHIC) then begin
        	while(Pos1 <= StrPos.Length)
							and not(StrPos[Pos1] in [#$07, #$08, #$0a, #$0b, #$0c, #$0d, #$1a, #$1b, #$1e])
							and (FPosition.X < SCREEN_WIDTH) do begin

						// Œ»İˆÊ’u‚É•¶š‚ğ‘‚«‚İAAttribute ‚ğİ’è
						// TAB ‚¾‚Á‚½‚ç TABCOLUMN ‚Ü‚ÅƒXƒy[ƒX‚Å–„‚ß‚é
            // (CHAR_GRAPHIC ‚¾‚Á‚½‚ç‘®«‚È‚µ‚Å”¼ŠpƒXƒy[ƒX‚ÌƒRƒ}ƒ“ƒh‚ğ”­s‚·‚éj
						if(StrPos[Pos1] = #$09) then begin																// TAB
							Inc(Pos1);
							repeat
								FScreen[FPosition.Y, FPosition.X].Letter := $20;							// ”¼ŠpƒXƒy[ƒX
								FScreen[FPosition.Y, FPosition.X].Attribute := FNowAttribute;
                FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode := CHAR_ASCII;
								DecodeESCCommand.Text := DecodeESCCommand.Text + #$20;
             		Inc(DecodeESCCommand.Rect.Right);
								Inc(FPosition.X);
							until(FPosition.X mod TABCOLUMN = 0);

             	DecodeESCCommand.Attribute.LetterCode := CHAR_ASCII;
             	DecodeESCList.Add(DecodeESCCommand);
             	DecodeESCCommand.Attribute := FNowAttribute;
              DecodeESCCommand.Text := '';
              DecodeESCCommand.Rect.Left  := FPosition.X;
              DecodeESCCommand.Rect.Right := FPosition.X - 1;

						end else if(StrPos[Pos1] in [#$80..#$9f, #$e0..#$ff]) then begin	// ƒOƒ‰ƒtƒBƒbƒN•¶š
            	while(Pos1 <= StrPos.Length)
              		and (StrPos[Pos1] in [#$80..#$9f, #$e0..#$ff])
                  and (FPosition.X < SCREEN_WIDTH) do begin
								DecodeESCCommand.Text := DecodeESCCommand.Text + StrPos[Pos1];
								FScreen[FPosition.Y, FPosition.X].Letter := Ord(StrPos[Pos1]);
								FScreen[FPosition.Y, FPosition.X].Attribute := FNowAttribute;
								Inc(Pos1);
               	Inc(DecodeESCCommand.Rect.Right);
								Inc(FPosition.X);
              end;
            end else begin																										// ASCII•¶š
            	DecodeESCCommand.Attribute.LetterCode := CHAR_ASCII;
            	while(Pos1 <= StrPos.Length)
									and not(StrPos[Pos1] in [#$07, #$08, #$0a, #$0b, #$0c, #$0d, #$1a, #$1b, #$1e, #$80..#$9f, #$e0..#$ff])
              		and (FPosition.X < SCREEN_WIDTH) do begin
								DecodeESCCommand.Text := DecodeESCCommand.Text + StrPos[Pos1];
								FScreen[FPosition.Y, FPosition.X].Letter := Ord(StrPos[Pos1]);
								FScreen[FPosition.Y, FPosition.X].Attribute := FNowAttribute;
                FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode := CHAR_ASCII;
								Inc(Pos1);
               	Inc(DecodeESCCommand.Rect.Right);
								Inc(FPosition.X);
              end;
            end;
          end;

				// •¶š—ñ‚ªI—¹‚·‚é‚©A‰ğ“Ç‰Â”\‚È“Áê•¶š‚ªo‚Ä‚­‚é‚©A‚QƒoƒCƒg”¼ŠpAƒOƒ‰ƒtƒBƒbƒN•¶šA‚»‚Ì‘¼‚Ì•¶š‚ÌØ‚ê–Ú‚©A‰æ–Ê‚Ì‰E‘¤‚Ü‚ÅƒXƒLƒƒƒ“
				end else if(FNowAttribute.LetterCode = CHAR_SJIS1)
          	or not(((StrPos[Pos1] = #$85) and (StrPos[Pos1+1] in [#$40..#$fc]))
            		or ((StrPos[Pos1] = #$86) and (StrPos[Pos1+1] in [#$40..#$9e]))) then begin		// ƒOƒ‰ƒtƒBƒbƒNA‚QƒoƒCƒg”¼ŠpˆÈŠO‚Ì

					FNowAttribute.LetterCode := CHAR_ASCII;
					DecodeESCCommand.Attribute.LetterCode := CHAR_ASCII;		// ‚Æ‚è‚ ‚¦‚¸ SJIS2 ˆÈŠO‚É
					while(Pos1 <= StrPos.Length)
							and not(StrPos[Pos1] in [#$07, #$08, #$0a, #$0b, #$0c, #$0d, #$1a, #$1b, #$1e])
							and ((FNowAttribute.LetterCode = CHAR_SJIS1) or (
              	not(
                  	 (StrPos[Pos1] = #$85) and (StrPos[Pos1+1] in [#$40..#$fc])
                	or (StrPos[Pos1] = #$86) and (StrPos[Pos1+1] in [#$40..#$9e])
              	)
              ))
							and (FPosition.X < SCREEN_WIDTH) do begin

						// Œ»İˆÊ’u‚É•¶š‚ğ‘‚«‚İAAttribute ‚ğİ’è
						// TAB ‚¾‚Á‚½‚ç TABCOLUMN ‚Ü‚ÅƒXƒy[ƒX‚Å–„‚ß‚é
						if(StrPos[Pos1] = #$09) then begin		// TAB
							Inc(Pos1);
							FNowAttribute.LetterCode := CHAR_ASCII;
							repeat
								FScreen[FPosition.Y, FPosition.X].Letter := $20;	// ”¼ŠpƒXƒy[ƒX
								FScreen[FPosition.Y, FPosition.X].Attribute := FNowAttribute;
								DecodeESCCommand.Text := DecodeESCCommand.Text + #$20;
             		Inc(DecodeESCCommand.Rect.Right);
								Inc(FPosition.X);
							until(FPosition.X mod TABCOLUMN = 0);
						end else begin											// TAB ˆÈŠO‚Ì•¶š
							if(FNowAttribute.LetterCode in [CHAR_ASCII, CHAR_SJIS2]) then begin
								if(StrPos[Pos1] in [#$81..#$9f, #$e0..#$fc]) then begin				// Š¿š‚PƒoƒCƒg–Ú
									FNowAttribute.LetterCode := CHAR_SJIS1;
								end else begin																								// ”¼Šp•¶š
									FNowAttribute.LetterCode := CHAR_ASCII;
								end;
              end else begin
								if(StrPos[Pos1] in [#$40..#$7e, #$80..#$fc]) then begin				// Š¿š‚QƒoƒCƒg–Ú
									FNowAttribute.LetterCode := CHAR_SJIS2;
								end else begin
{$IFDEF DEBUG}
									raise EDecodeESCSequenceError.Create(MSG_ERR_NO_SJIS2);
{$ENDIF}
								end;
							end;

							// Screen, Attribute İ’è
							DecodeESCCommand.Text := DecodeESCCommand.Text + StrPos[Pos1];
							FScreen[FPosition.Y, FPosition.X].Letter := Ord(StrPos[Pos1]);
							FScreen[FPosition.Y, FPosition.X].Attribute := FNowAttribute;
							Inc(Pos1);
              Inc(DecodeESCCommand.Rect.Right);
							Inc(FPosition.X);
						end;
					end;

        end else begin																												// ‚QƒoƒCƒg”¼Šp‚Ì‚Æ‚«
					FNowAttribute.LetterCode := CHAR_ZEN2;
					DecodeESCCommand.Attribute.LetterCode := CHAR_ZEN2;
					// Ÿ‚à‚QƒoƒCƒg”¼Šp‚©‚Ç‚¤‚©”»•Ê
					while(Pos1 <= StrPos.Length)
          	and (
            	   (StrPos[Pos1] = #$85) and (StrPos[Pos1+1] in [#$40..#$fc])
            	or (StrPos[Pos1] = #$86) and (StrPos[Pos1+1] in [#$40..#$9e])
            )
						and (FPosition.X < SCREEN_WIDTH) do begin

						// Screen, Attribute İ’è
            if(StrPos[Pos1] = #$85) then begin		// $8540`$85fc
							TempStr := Zen2ConvertTable1[Ord(StrPos[Pos1]) * $100 + Ord(StrPos[Pos1+1])];
            end else begin												// $8640`$869e
							TempStr := Zen2ConvertTable2[Ord(StrPos[Pos1]) * $100 + Ord(StrPos[Pos1+1])];
            end;



						DecodeESCCommand.Text := DecodeESCCommand.Text + TempStr;
//						FScreen[FPosition.Y, FPosition.X].Letter := Ord(Zen2ConvertTable[Ord(StrPos[Pos1]) * $100 + Ord(StrPos[Pos1+1])]));
						FScreen[FPosition.Y, FPosition.X].Letter := Ord(TempStr[1]) * $100 + Ord(TempStr[2]);
						FScreen[FPosition.Y, FPosition.X].Attribute := FNowAttribute;
						Inc(Pos1, 2);
						Inc(DecodeESCCommand.Rect.Right);
						Inc(FPosition.X);
					end;
				end;

				//-------------------------------------------------------------------
				// •¶š—ñ‚Ì“r’†‚Å‰æ–Ê‚Ì‰E’[‚É“’B‚µ‚½‚©‚Ç‚¤‚©”»•Ê
				//-------------------------------------------------------------------
				if(FPosition.X >= SCREEN_WIDTH) then begin
					// SJIS 2•¶š–Ú‚Ì‚İc‚Á‚½ê‡A‹ó”’•¶š‚ğo—Í‚µ‚Ä
					// Ÿ‚Ìs‚É‰ñ‚·
					if(FNowAttribute.LetterCode = CHAR_SJIS1) then begin
						DecodeESCCommand.Text :=
							Copy(DecodeESCCommand.Text, 1, Length(DecodeESCCommand.Text) - 1) + #$20;	// ”¼ŠpƒXƒy[ƒX
						FScreen[FPosition.Y, SCREEN_WIDTH - 1].Letter := $20;		// ”¼ŠpƒXƒy[ƒX
            FScreen[FPosition.Y, SCREEN_WIDTH - 1].Attribute.LetterCode := CHAR_ASCII;
						DecodeESCCommand.Rect.Right := SCREEN_WIDTH - 1;
						if(Pos1 > 0) then begin
							Dec(Pos1);		// ‚P•¶š–ß‚·
						end;
					end;

					// ƒRƒ}ƒ“ƒh”­s
					DecodeESCList.Add(DecodeESCCommand);

					// Ÿ‚Ì•¶š^s‚ÉƒJ[ƒ\ƒ‹‚ğˆÚ‚·
					FPosition.X := 0;
					Inc(FPosition.Y);
					if(FPosition.Y >= SCREEN_HEIGHT) then begin
						Scrool(FPosition.Y - SCREEN_HEIGHT + 1, DecodeESCList);
						FPosition.Y := SCREEN_HEIGHT - 1;
					end;
				end else begin
					// •¶š—ñ‚Ì“r’†‚Å‰æ–Ê‚Ì‰E’[‚É“’B‚µ‚Ä‚¢‚È‚¢ê‡A
					// SHIFTJIS ‚Ì2•¶š–Ú‚ğc‚µ‚Ä‚¢‚È‚¢‚©”»•Ê‚µ‚Äc‚µ‚Ä‚¢‚½‚ç
					// ”¼ŠpƒXƒy[ƒX‚P•¶š‚Ì‚İ‚ÌƒRƒ}ƒ“ƒh‚ğ”­s‚·‚é(‘®«‚È‚µ‚Å)
					if(FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode = CHAR_SJIS2) then begin
						DecodeESCCommand2 := DecodeESCCommand;
						DecodeESCCommand2.Rect.Left := FPosition.X;
						DecodeESCCommand2.Rect.Right := DecodeESCCommand2.Rect.Left;
						DecodeESCCommand2.Text := #$20;
						DecodeESCCommand2.Attribute.Attribute_Sub := [];
						FScreen[FPosition.Y, FPosition.X].Letter := $20;			// ”¼ŠpƒXƒy[ƒX
						FScreen[FPosition.Y, FPosition.X].Attribute.Attribute_Sub := [];
						FScreen[FPosition.Y, FPosition.X].Attribute.LetterCode := CHAR_ASCII;
						DecodeESCList.Add(DecodeESCCommand2);
					end;

					// ƒRƒ}ƒ“ƒh”­s
					DecodeESCList.Add(DecodeESCCommand);
				end;
			end;
		end;
	finally
		StrPos.Free;
		IntegerList.Free;
	end;
end;


end.

