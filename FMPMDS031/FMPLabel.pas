//============================================================================
//                 TLabel with FMPGaiji support 「FMPLabel」
//                      Copyright & Programmed by C60
//============================================================================
unit FMPLabel;

interface

uses
	Windows, Dialogs, Forms, SysUtils, Classes, StdCtrls, Graphics, Controls;

const
	STR_FMPGAIJI = 'FMP外字';			// フォント名

type
	TFMPLabel = class(TCustomLabel)
	private
		{ Private 宣言 }
		FInstalledFMPFont : Boolean;
	protected
		{ Protected 宣言 }
		procedure Paint; override;
		procedure DoDrawText(var Rect: TRect; Flags: Longint); dynamic;
		procedure FMPDrawText(Canvas : TCanvas; lpString: String; x, y : Integer);
	public
		{ Public 宣言 }
		constructor Create(AOwner : TComponent); override;
		property InstalledFMPFont : Boolean read FInstalledFMPFont;
  published
    { Published 宣言 }
    property Align;
		property Alignment;
    property AutoSize;
    property Caption;
		property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentColor;
    property ParentFont;
		property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
		property ShowHint;
    property Transparent;
    property Visible;
		property WordWrap;
    property OnClick;
		property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

procedure Register;
function GetForm(NowComponent : TComponent) : TForm;
function EnumFontFamiliesExProc(const logfont: TLogFont;
		const textmetric: TTextMetric; dword: DWORD; lparam: LPARAM): Integer; stdcall;


implementation

procedure Register;
begin
   RegisterComponents('Samples', [TFMPLabel]);
end;


function GetForm(NowComponent : TComponent) : TForm;
begin
	while not(NowComponent is TForm) do begin
		NowComponent := NowComponent.Owner;
	end;
	GetForm := NowComponent as TForm;
end;


// EnumFontFamilies 用 callback function
function EnumFontFamiliesExProc(const logfont: TLogFont;
    const textmetric: TTextMetric; dword: DWORD; lparam: LPARAM): Integer;
begin
	if(logfont.lfFaceName = STR_FMPGAIJI) then begin
		result := 0;
	end else begin
		result := 1;
	end;
end;


constructor TFMPLabel.Create(AOwner : TComponent);
var
	DC : HDC;
	p2: TLogFont;
begin
	inherited Create(AOwner);
	
	DC := GetDC(GetForm(AOwner).Handle);
	try
		p2.lfCharSet := DEFAULT_CHARSET;
		p2.lfFaceName  := STR_FMPGAIJI;
		p2.lfPitchAndFamily := 0;
		
		// FMP 外字がインストールされているかどうか調べる
		FInstalledFMPFont := not EnumFontFamiliesEx(DC, p2, @EnumFontFamiliesExProc, 0, 0);
	finally
		ReleaseDC(GetForm(AOwner).Handle, DC);
	end;
end;


procedure TFMPLabel.Paint;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
  WordWraps: array[Boolean] of Word = (0, DT_WORDBREAK);
var
  Rect, CalcRect: TRect;
  DrawStyle: Longint;
begin
  with Canvas do
  begin
		if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(ClientRect);
		end;
    Brush.Style := bsClear;
    Rect := ClientRect;
    { DoDrawText takes care of BiDi alignments }
		DrawStyle := DT_EXPANDTABS or WordWraps[WordWrap] or Alignments[Alignment];
		{ Calculate vertical layout }
		CalcRect := Rect;
		DoDrawText(CalcRect, DrawStyle or DT_CALCRECT);
		OffsetRect(Rect, 0, (Height - CalcRect.Bottom) div 2);
    DoDrawText(Rect, DrawStyle);
  end;
end;

procedure TFMPLabel.DoDrawText(var Rect: TRect; Flags: Longint);
var
  Text: string;
begin
	Text := GetLabelText;
  if (Flags and DT_CALCRECT <> 0) and ((Text = '') or ShowAccelChar and
		(Text[1] = '&') and (Text[2] = #0)) then Text := Text + ' ';
  if not ShowAccelChar then Flags := Flags or DT_NOPREFIX;
	Canvas.Font := Font;
  if not Enabled then
  begin
    Canvas.Font.Color := clBtnHighlight;
    FMPDrawText(Canvas, Text, 1, 1);
    Canvas.Font.Color := clBtnShadow;
    FMPDrawText(Canvas, Text, -1, -1);
  end
  else
    FMPDrawText(Canvas, Text, 0, 0);
end;


// FMP 外字を FMP フォントで表示する DrawText
procedure TFMPLabel.FMPDrawText(Canvas : TCanvas; lpString: String; x, y : Integer);
var
	TempTxt : String;
	i : Integer;
begin
	Canvas.Font.Size := Font.Size;
	Canvas.Font.Name := Font.Name;
	i := 1;
	TempTxt := '';
	while(i <= Length(lpString)) do begin
		Canvas.Font.Name := Font.Name;
		TempTxt := lpString[i];
		Inc(i);
		if(i <= Length(lpString)) then begin
			// ShiftJIS の判別 $81～$9f,$e0～$fc
			if(((TempTxt[1] >= #$81) and (TempTxt[1] <= #$9f))
					or ((TempTxt[1] >= #$e0) and (TempTxt[1] <= #$fc))) then begin
				TempTxt := TempTxt + lpString[i];
				Inc(i);
				
				// FMP 外字の判別：$EB9F ～ $EC9E
				if(((TempTxt[1] = #$eb) and (TempTxt[2] >= #$9f)) or
						((TempTxt[1] = #$ec) and (TempTxt[2] <= #$9e))) then begin
					
					// FMP外字がないときは「・」にする
					if(FInstalledFMPFont = False) then begin
						TempTxt := '・';
					end else begin
						Canvas.Font.Name := STR_FMPGAIJI;
						TempTxt[1] := Chr(Ord(TempTxt[1]) - $60);
					end;
				end;
			end;
		end;

		Canvas.Textout(x, y, TempTxt);
		x := x + Canvas.TextWidth(TempTxt);
	end;
end;


end.


