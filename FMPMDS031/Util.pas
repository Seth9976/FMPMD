//============================================================================
//                               小物ツール
//                      Copyright & Programmed by C60
//============================================================================
unit util;

interface

function addand(src : String) : String;
function zenspc2spc(src : String) : String;
function spc3tospc2(src : String) : String;


implementation


//***************************************************************************
// 文字列中の「&」を「&&」にする
//***************************************************************************
function addand(src : String) : String;
var
	i : Integer;
begin
	result := '';
	
	for i := 1 to Length(src) do begin
		result := result + src[i];
		if(src[i] = '&') then begin
			result := result + src[i];
		end;
	end;
end;


//***************************************************************************
// 文字列中の全角スペースを半角スペース×２にする
//***************************************************************************
function zenspc2spc(src : String) : String;
var
	dest : String;
	i : Integer;
begin
	dest := '';

	i := 1;
	while(i <= Length(src)) do begin
		if(src[i] = #$81) and (i < Length(src)) then begin
			if(src[i+1] = #$40) then begin
				// 全角スペース
				dest := dest + '  ';
				Inc(i, 2);
				continue;
			end;
		end;

		dest := dest + src[i];
		Inc(i);
	end;

	result := dest;
end;


//***************************************************************************
// スペース３文字以上をスペース×２になるまで削る（半角スペースのみ）
//***************************************************************************
function spc3tospc2(src : String) : String;
var
	dest : String;
	i : Integer;
begin
	dest := '';

	i := 1;
	while(i <= Length(src)) do begin
		if(src[i] = ' ') and (i < Length(src) - 1) then begin
			if(src[i+1] = ' ') and (src[i+2] = ' ') then begin
				// スペース×３
				dest := dest + '  ';
				Inc(i, 3);
 				while(i <= Length(src)) and (src[i] = ' ') do begin
					Inc(i);
				end;
				continue;
			end;
		end;

		dest := dest + src[i];
		Inc(i);
	end;

	result := dest;
end;


end.
