//============================================================================
//                         FFT ユニット Ver.0.10
//							original by 奥村晴彦「C言語によるアルゴリズム入門」
//              Pascal Converted by C60
//============================================================================

unit FFT;

interface

uses SysUtils;

type
	PInteger = ^Integer;
  PDouble = ^Double;

	EFFTError = class(Exception);

	TFFT = class(TObject)
	private
		{ Private 宣言 }
    last_n : Integer;
		sintbl : PDouble;
    bitrev : PInteger;
		procedure make_sintbl(n : Integer; sintbl : PDouble);
  	procedure make_bitrev(n : Integer; bitrev : PInteger);
	public
		{ Public 宣言 }
  constructor Create;
	function FFT(n : Integer; var x, y : array of Double) : Integer;
	end;

implementation


//***************************************************************************
// コンストラクタ
//***************************************************************************
constructor TFFT.Create;
begin
	last_n  := 0;
	bitrev := nil;
	sintbl := nil;
  inherited Create;
end;


procedure TFFT.make_sintbl(n : Integer; sintbl : PDouble);
var
	i, n2, n4, n8 : Integer;
	c, s, dc, ds, t : Double;
begin
	n2 := n div 2; n4 := n div 4; n8 := n div 8;
	t := sin(PI / n);
	dc := 2 * t * t;
	ds := sqrt(dc * (2 - dc));
	t := 2 * dc;

//	sintbl[n4] := 1; c := 1;
//	sintbl[0] := 0; s := 0;
	PDouble(Integer(sintbl) + n4*SizeOf(Double))^ := 1; c := 1;
	sintbl^ := 0; s := 0;

	for i := 1 to n8-1 do begin
  	c := c - dc; dc := dc + t * c;
		s := s + ds; ds := ds - t * s;
//		sintbl[i] := s;	sintbl[n4 - i] := c;
		PDouble(Integer(sintbl) + i*SizeOf(Double))^ := s;
		PDouble(Integer(sintbl) + (n4-i)*SizeOf(Double))^ := c;
	end;

//	if(n8 <> 0) then sintbl[n8] := sqrt(0.5);
  if(n8 <> 0) then PDouble(Integer(sintbl) + n8*SizeOf(Double))^ := sqrt(0.5);
	for i := 0 to n4-1 do begin
//		sintbl[n2 - i] := sintbl[i];
		PDouble(Integer(sintbl) + (n2-i)*SizeOf(Double))^ :=
														    PDouble(Integer(sintbl) + i*SizeOf(Double))^;
	end;

	for i := 0 to n2 + n4 - 1 do begin
//		sintbl[i + n2] := -sintbl[i];
		PDouble(Integer(sintbl) + (i+n2)*SizeOf(Double))^ :=
														    -PDouble(Integer(sintbl) + i*SizeOf(Double))^;
	end;
end;


procedure TFFT.make_bitrev(n : Integer; bitrev : PInteger);
var
	i, j, k, n2 : Integer;
begin
	n2 := n div 2;
	i := 0; j := 0;

	while(True) do begin
//		bitrev[i] := j;
		PInteger(Integer(bitrev) + i*SizeOf(Integer))^ := j;
    Inc(i);
		if(i >= n) then Break;
		k := n2;
		while(k <= j) do begin
			Dec(j, k); k := k div 2;
		end;
		Inc(j, k);
	end;
end;


function TFFT.FFT(n : Integer; var x, y : array of Double) : Integer;
var
	i, j, k, ik, h, d, k2, n4, inverse : Integer;
	t, s, c, dx, dy : Double;
begin
	if(n < 0) then begin
		n := -n;
		inverse := 1;
	end else begin
		inverse := 0;
	end;

	n4 := n div 4;
	if(n <> last_n) or (n = 0) then begin
		last_n := n;
		if(sintbl <> nil) then begin
			FreeMem(sintbl);
		end;
		if(bitrev <> nil) then begin
			FreeMem(bitrev);
		end;

		if(n = 0) then begin
			Result := 0;
			Exit;
    end;

		GetMem(sintbl, (n + n4) * SizeOf(Double));
		GetMem(bitrev, n * SizeOf(Integer));

		if(sintbl = nil) or (bitrev = nil) then begin
	  	raise EFFTError.Create('メモリを取得できません');
		end;

		make_sintbl(n, sintbl);
		make_bitrev(n, bitrev);
	end;

	for i := 0 to n-1 do begin
//		j := bitrev[i];
		j := PInteger(Integer(bitrev) + i*SizeOf(Integer))^;
		if(i < j) then begin
			t := x[i];	x[i] := x[j];	x[j] := t;
			t := y[i];	y[i] := y[j];	y[j] := t;
		end;
	end;

  k := 1;
  while(k < n) do begin
		h := 0; k2 := k + k; d := n div k2;
		for j := 0 to k-1 do begin
//    	c := sintbl[h+n4];
			c := PDouble(Integer(sintbl) + (h+n4)*SizeOf(Double))^;
			if(inverse <> 0) then begin
//      	s := -sintbl[h];
				s := -PDouble(Integer(sintbl) + h*SizeOf(Double))^;
			end else begin
//      	s :=  sintbl[h];
				s :=  PDouble(Integer(sintbl) + h*SizeOf(Double))^;
      end;

      i := j;
      while(i < n) do begin
      	ik := i + k;
				dx := s * y[ik] + c * x[ik];
				dy := c * y[ik] - s * x[ik];
				x[ik] := x[i] - dx; x[i] := x[i] + dx;
				y[ik] := y[i] - dy; y[i] := y[i] + dy;
				Inc(i, k2);
        end;
      Inc(h, d);
		end;
  	k := k + k;
  end;

	if (inverse = 0) then begin
		for i := 0 to n-1 do begin
			x[i] := x[i] / n; y[i] := y[i] / n;
		end;
	end;

	Result := 0;
end;

end.
