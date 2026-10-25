//============================================================================
//                       ConvFreq ユニット Ver.0.11
//                      Copyright & Programmed by C60
//============================================================================

/////////////////////////////////////////////////////////////////////////////
//	Convert 時のデータの流れ
//		pbSrc -> pbPre(16bit への変換) -> pbConv(周波数変換)
//																							-> pbSrc(bit, channel の変換)
/////////////////////////////////////////////////////////////////////////////

unit ConvFreq;

interface

uses
	Windows, MMSystem;

const
	TCONVFREQ_SIZEF_SOURCE      = $00000000;			//	source のサイズを求める
	TCONVFREQ_SIZEF_DESTINATION = $00000001;			//	dest のサイズを求める

	TCONVFREQ_CONVF_NOTHING     = $00000000;			//	補完なし
	TCONVFREQ_CONVF_LINEAR      = $00000001;			//	線形補完
	TCONVFREQ_CONVF_FOURTH      = $00000004;			//	４点補完



const
	Depth = 8192;			//	分解能


type
	PMonoral16bit = ^TMonoral16bit;
	TMonoral16bit = SmallInt;
	PStereo16bit = ^TStereo16bit;
	TStereo16bit = packed record
		Left : SmallInt;
		Right : SmallInt;
	end;

	PMonoral8bit = ^TMonoral8bit;
	TMonoral8bit = Byte;
	PStereo8bit = ^TStereo8bit;
	TStereo8bit = packed record
		Left : Byte;
		Right : Byte;
	end;

	TConvFreq = class(TObject)
	private
		{ Private 宣言 }
		pbPre, pbConv : Pointer;
		pbPreS16b1 : PStereo16bit;
		iPre, iConv, iPreS16b1 : Integer;
		
		Prev16BitMonoralData : Array[0..1] of TMonoral16Bit;
		Prev16BitStereoData  : Array[0..1] of TStereo16Bit;
		procedure BitChannelConv(wfxSrc, wfxDst : TWaveFormatEx;
														cbInput : DWORD; pbSrc, pbDst : Pointer);
		procedure MonoralFreqConv(wfxPre, wfxConv : TWaveFormatEx;
							cbInput : DWORD; pbPre, pbConv : PMonoral16bit; fdwConv: DWORD);
		procedure StereoFreqConv(wfxPre, wfxConv : TWaveFormatEx;
							cbInput : DWORD; pbPre, pbConv : PStereo16bit; fdwConv: DWORD);
		function DistToWeight(x : Double) : Double;
	public
		{ Public 宣言 }
		constructor Create;
		destructor Destroy; override;
		function GetSize(const wfxSrc,wfxDst : TWaveFormatEx; cbInput : DWORD;
																											fdwSize: DWORD):Integer;
		procedure Convert(const wfxSrc, wfxDst : TWaveFormatEx;
									cbInput : DWORD; pbSrc, pbDst : Pointer; fdwConv : DWORD);
		procedure FlushBuffer;
	end;

implementation


//***************************************************************************
// コンストラクタ
//***************************************************************************
constructor TConvFreq.Create;
begin
	inherited Create;
	FlushBuffer;
	iPre := 1000;				// 暫定
	iConv := 1000;				// 暫定
	iPreS16b1 := 1000; 	// 暫定
	GetMem(pbPre, iPre);
	GetMem(pbConv, iConv);
	GetMem(pbPreS16b1, iPreS16b1);
end;


//***************************************************************************
// デストラクタ
//***************************************************************************
destructor TConvFreq.Destroy;
begin
	if(iPre <> 0) then FreeMem(pbPre);
	if(iConv <> 0) then FreeMem(pbConv);
	if(iPreS16b1 <> 0) then FreeMem(pbPreS16b1);
end;


//***************************************************************************
// データサイズを得る
//***************************************************************************
function TConvFreq.GetSize(const wfxSrc,wfxDst : TWaveFormatEx;
																		cbInput : DWORD; fdwSize: DWORD):Integer;
{
const
	TCONVFREQ_SIZEF_SOURCE      = $00000000;			//	source のサイズを求める
	TCONVFREQ_SIZEF_DESTINATION = $00000001;			//	dest のサイズを求める
}
var
	Temp : Double;
begin
	case fdwSize of
		TCONVFREQ_SIZEF_SOURCE :
			begin
//				Result := cbInput * 4
      	Temp := cbInput;
        Temp := Temp
						* wfxSrc.nChannels      / wfxDst.nChannels
						* wfxSrc.wBitsPerSample / wfxDst.wBitsPerSample
						* wfxSrc.nSamplesPerSec / wfxDst.nSamplesPerSec;
        Result := Trunc(Temp);
			end;

		TCONVFREQ_SIZEF_DESTINATION :
			begin
//				Result := cbInput * 4
      	Temp := cbInput;
        Temp := Temp
						* wfxDst.nChannels      / wfxSrc.nChannels
						* wfxDst.wBitsPerSample / wfxSrc.wBitsPerSample
						* wfxDst.nSamplesPerSec / wfxSrc.nSamplesPerSec;
        Result := Trunc(Temp);
			end;
  else
	  Result := 0;
  end;
end;


//***************************************************************************
// 変換ルーチン
//***************************************************************************
procedure TConvFreq.Convert(const wfxSrc, wfxDst : TWaveFormatEx;
								cbInput : DWORD; pbSrc, pbDst : Pointer; fdwConv : DWORD);
{
const
	TCONVFREQ_CONVF_NOTHING     = $00000000;			//	補完なし
	TCONVFREQ_CONVF_LINEAR      = $00000001;			//	線形補完
	TCONVFREQ_CONVF_FOURTH      = $00000004;			//	４点補完
}
var
	i, PreBufferSize, ConvBufferSize : Integer;
	pbPre2 : Pointer;
	wfxPre, wfxConv : TWaveFormatEx;

begin
	wfxPre := wfxSrc;
	wfxPre.wBitsPerSample := 16;
	if(wfxDst.nChannels = 1) then wfxPre.nChannels := 1;

	PreBufferSize := GetSize(wfxSrc, wfxPre, cbInput,
																							TCONVFREQ_SIZEF_DESTINATION);

	if(wfxSrc.nChannels = 1) or (wfxPre.nChannels = 1) then begin
																								//	monoral input or output

		if(iPre <> PreBufferSize + SizeOf(Prev16BitMonoralData)) then begin
			FreeMem(pbPre);
			iPre := PreBufferSize + SizeOf(Prev16BitMonoralData);
			GetMem(pbPre, iPre);
		end;

		pbPre2 := pbPre;

		for i := 0 to 2-1 do begin
			PMonoral16Bit(pbPre2)^ := Prev16BitMonoralData[i];
			Inc(PMonoral16Bit(pbPre2));
		end;


		//	monoral 16bit への変換
		BitChannelConv(wfxSrc, wfxPre, cbInput, pbSrc, pbPre2);

		wfxConv := wfxPre;
		wfxConv.nSamplesPerSec := wfxDst.nSamplesPerSec;

		ConvBufferSize := GetSize(wfxPre, wfxConv, PreBufferSize,
																							TCONVFREQ_SIZEF_DESTINATION);
		
		
		if(iConv <> ConvBufferSize) then begin
			FreeMem(pbConv);
			iConv := ConvBufferSize;
			GetMem(pbConv, iConv);
		end;
		
		//	周波数のみ変換
		MonoralFreqConv(wfxPre, wfxConv, PreBufferSize, pbPre, pbConv, fdwConv);

		//	目的の channel, bit への変換

		BitChannelConv(wfxConv, wfxDst, ConvBufferSize, pbConv, pbDst);

	end else begin																//	stereo input, output
		
		if(iPre <> PreBufferSize + SizeOf(Prev16BitStereoData)) then begin
			FreeMem(pbPre);
			iPre := PreBufferSize + SizeOf(Prev16BitStereoData);
			GetMem(pbPre, iPre);
		end;
		
		pbPre2 := pbPre;
		for i := 0 to 2-1 do begin
			PStereo16Bit(pbPre2)^ := Prev16BitStereoData[i];
			Inc(PStereo16Bit(pbPre2));
		end;

		//	stereo 16bit への変換
		BitChannelConv(wfxSrc, wfxPre, cbInput, pbSrc, pbPre2);

		wfxConv := wfxPre;
		wfxConv.nSamplesPerSec := wfxDst.nSamplesPerSec;

		ConvBufferSize := GetSize(wfxPre, wfxConv, PreBufferSize,
																							TCONVFREQ_SIZEF_DESTINATION);
		if(iConv <> ConvBufferSize) then begin
			FreeMem(pbConv);
			iConv := ConvBufferSize;
			GetMem(pbConv, iConv);
		end;
		
		//	周波数のみ変換
		StereoFreqConv(wfxPre, wfxConv, PreBufferSize, pbPre, pbConv, fdwConv);

		//	目的の channel, bit への変換
		BitChannelConv(wfxConv, wfxDst, ConvBufferSize, pbConv, pbDst);
	end;
end;


//***************************************************************************
// bit, チャンネル数変換
//***************************************************************************
procedure TConvFreq.BitChannelConv(wfxSrc, wfxDst : TWaveFormatEx;
														cbInput : DWORD; pbSrc, pbDst : Pointer);
var
	i, cbPre : Integer;
	pbPreS16b2, pbPreS16b3 : PStereo16bit;
	pbSrcM8b2 , pbDstM8b2  : PMonoral8bit;
	pbSrcM16b2, pbDstM16b2 : PMonoral16bit;
	pbSrcS8b2 , pbDstS8b2  : PStereo8bit;
	pbSrcS16b2, pbDstS16b2 : PStereo16bit;

begin
	if(wfxSrc.nChannels = wfxDst.nChannels) and
					(wfxSrc.wBitsPerSample = wfxDst.wBitsPerSample) then begin
		Move(pbSrc^, pbDst^, cbInput);												//	変換なし
	end else begin
		cbPre := cbInput;
		if(wfxSrc.nChannels = 1) then cbPre := cbPre * 2;
		if(wfxSrc.wBitsPerSample = 8) then cbPre := cbPre * 2;

		if(iPreS16b1 <> cbPre) then begin
			FreeMem(pbPreS16b1);
			iPreS16b1 := cbPre;
			GetMem(pbPreS16b1, iPreS16b1);
		end;
    
    pbPreS16b2 := pbPreS16b1;
		pbPreS16b3 := pbPreS16b2;

		// stereo 16bit への変換

		if(wfxSrc.nChannels = 1) then begin
			if(wfxSrc.wBitsPerSample = 8) then begin						//	monoral 8bit
				pbSrcM8b2 := pbSrc;
				for i := 0 to cbPre div 4 - 1 do begin
					pbPreS16b3^.Left  := (pbSrcM8b2^-$80) shl 8;
					pbPreS16b3^.Right := pbPreS16b3^.Left;
					Inc(pbPreS16b3);
					Inc(pbSrcM8b2);
				end;
			end else begin																			//	monoral 16bit
				pbSrcM16b2 := pbSrc;
				for i := 0 to cbPre div 4 - 1 do begin
					pbPreS16b3^.Left  := pbSrcM16b2^;
					pbPreS16b3^.Right := pbPreS16b3^.Left;
					Inc(pbPreS16b3);
					Inc(pbSrcM16b2);
				end;
			end;
		end else if(wfxSrc.wBitsPerSample = 8) then begin			//	stereo 8bit
			pbSrcS8b2 := pbSrc;
			for i := 0 to cbPre div 4 - 1 do begin
				pbPreS16b3^.Left  := (Integer(pbSrcS8b2^.Left-$80)) shl 8;
				pbPreS16b3^.Right := (Integer(pbSrcS8b2^.Right-$80)) shl 8;
				Inc(pbPreS16b3);
				Inc(pbSrcS8b2);
			end;
		end else begin																				//	stereo 16bit
			pbSrcS16b2 := pbSrc;
			Move(pbSrcS16b2^, pbPreS16b3^, cbPre);
		end;

		// 目的の channel, bit への変換

		if(wfxDst.nChannels = 1) then begin
			if(wfxDst.wBitsPerSample = 8) then begin						//	monoral 8bit
				pbDstM8b2 := pbDst;
				for i := 0 to cbPre div 4 - 1 do begin
					pbDstM8b2^ := (Integer(pbPreS16b2^.Left) + pbPreS16b2^.Right)
												div 2 div 256 + $80;
					Inc(pbPreS16b2);
					Inc(pbDstM8b2);
				end;
			end else begin																			//	monoral 16bit
				pbDstM16b2 := pbDst;
				for i := 0 to cbPre div 4 - 1 do begin
					pbDstM16b2^ := (Integer(pbPreS16b2^.Left) + pbPreS16b2^.Right)
												div 2;
					Inc(pbPreS16b2);
					Inc(pbDstM16b2);
				end;
			end;
		end else if(wfxDst.wBitsPerSample = 8) then begin			//	stereo 8bit
			pbDstS8b2 := pbDst;
			for i := 0 to cbPre div 4 - 1 do begin
				pbDstS8b2^.Left  := pbPreS16b2^.Left  div 256 + $80;
				pbDstS8b2^.Right := pbPreS16b2^.Right div 256 + $80;
				Inc(pbPreS16b2);
				Inc(pbDstS8b2);
			end;
		end else begin																				//	stereo 16bit
			Move(pbPreS16b2^, pbDst^, cbPre);
		end;
	end;
end;


//***************************************************************************
// monoral, 16bit の周波数変換
//***************************************************************************
procedure TConvFreq.MonoralFreqConv(wfxPre, wfxConv : TWaveFormatEx;
						cbInput : DWORD; pbPre, pbConv : PMonoral16bit; fdwConv : DWORD);
var
	i, cbPre : Integer;
	Carry : Cardinal;
	Delta : Cardinal;
	pbPre2 : PMonoral16bit;
	Temp : Double;
	Carry2, Delta2 : Double;
begin
	Delta := GetSize(wfxPre, wfxConv, Depth, TCONVFREQ_SIZEF_SOURCE);
	Carry := 0;

	if(wfxPre.nSamplesPerSec = wfxConv.nSamplesPerSec) then begin	//	変換なし
		Inc(pbPre);
		Inc(pbPre);
		Move(pbPre^, pbConv^, cbInput);
	end else begin
		wfxConv.nChannels := wfxPre.nChannels;
    wfxConv.wBitsPerSample := wfxPre.wBitsPerSample;
		cbPre := GetSize(wfxPre, wfxConv, cbInput, TCONVFREQ_SIZEF_DESTINATION);

		if(fdwConv = TCONVFREQ_CONVF_NOTHING) then begin						//	補完なし
			Inc(pbPre);
			Inc(pbPre);
			for i := 0 to cbPre div 2-1 do begin
				Inc(Carry, Delta);
				while(Carry >= Depth) do begin
					Dec(Carry, Depth);
					Inc(pbPre);
				end;
				pbConv^ := pbPre^;
				Inc(pbConv);
			end;
		end else if(fdwConv = TCONVFREQ_CONVF_LINEAR) then begin		//	線形補完
			Inc(pbPre);
			for i := 0 to cbPre div 2-1 do begin
				Inc(Carry, Delta);
				while(Carry >= Depth) do begin
					Dec(Carry, Depth);
					Inc(pbPre);
				end;

				pbPre2 := pbPre;
				Inc(pbPre2);
				pbConv^ := (pbPre^ * (Depth - Carry) + pbPre2^ * Carry) div Depth;
				Inc(pbConv);
			end;
		end else begin																							//	４点補完
			Carry2 := 0.0;
			Delta2 := wfxPre.nSamplesPerSec / wfxConv.nSamplesPerSec;
			for i := 0 to cbPre div 2-1 do begin
				Carry2 := Carry2 + Delta2;
				while(Carry2 >= 1.0) do begin
					Carry2 := Carry2 - 1.0;
					Inc(pbPre);
				end;

				pbPre2 := pbPre;
				Temp := pbPre2^ * DistToWeight(1.0+Carry2);
				Inc(pbPre2);

				Temp := Temp + pbPre2^ * DistToWeight(Carry2);
				Inc(pbPre2);

				Temp := Temp + pbPre2^ * DistToWeight(1.0-Carry2);
				Inc(pbPre2);

				Temp := Temp + pbPre2^ * DistToWeight(2.0-Carry2);

				pbConv^ := Round(Temp);
				Inc(pbConv);
			end;
		end;
	end;

	for i := 2-1 downto 0 do begin
		Dec(pbPre);
		Prev16BitMonoralData[i] := pbPre^;
	end;
end;


//***************************************************************************
// stereo, 16bit の周波数変換
//***************************************************************************
procedure TConvFreq.StereoFreqConv(wfxPre, wfxConv : TWaveFormatEx;
						cbInput : DWORD; pbPre, pbConv : PStereo16bit; fdwConv: DWORD);
var
	i, cbPre : Integer;
	Carry : Cardinal;
	Delta : Cardinal;
	pbPre2 : PStereo16bit;
	TempLeft : Double;
	TempRight : Double;
	Carry2, Delta2 : Double;
begin
	Delta := GetSize(wfxPre, wfxConv, Depth, TCONVFREQ_SIZEF_SOURCE);
	Carry := 0;

	if(wfxPre.nSamplesPerSec = wfxConv.nSamplesPerSec) then begin	//	変換なし
		Inc(pbPre);
		Inc(pbPre);
		Move(pbPre^, pbConv^, cbInput);
	end else begin
		wfxConv.nChannels := wfxPre.nChannels;
    wfxConv.wBitsPerSample := wfxPre.wBitsPerSample;
		cbPre := GetSize(wfxPre, wfxConv, cbInput, TCONVFREQ_SIZEF_DESTINATION);
		if(fdwConv = TCONVFREQ_CONVF_NOTHING) then begin						//	補完なし
			Inc(pbPre);
			Inc(pbPre);
			for i := 0 to cbPre div 4-1 do begin
				Inc(Carry, Delta);
				while(Carry >= Depth) do begin
					Dec(Carry, Depth);
					Inc(pbPre);
				end;
				pbConv^.Left  := pbPre^.Left;
				pbConv^.Right := pbPre^.Right;
				Inc(pbConv);
			end;
		end else if(fdwConv = TCONVFREQ_CONVF_LINEAR) then begin		//	線形補完
			Inc(pbPre);
			for i := 0 to cbPre div 4-1 do begin
				Inc(Carry, Delta);
				while(Carry >= Depth) do begin
					Dec(Carry, Depth);
					Inc(pbPre);
				end;

				pbPre2 := pbPre;
				Inc(pbPre2);
				pbConv^.Left  := (pbPre^.Left  * (Depth - Carry) +
																						pbPre2^.Left  * Carry) div Depth;
				pbConv^.Right := (pbPre^.Right * (Depth - Carry) +
																						pbPre2^.Right * Carry) div Depth;
				Inc(pbConv);
			end;
		end else begin																							//	４点補完
			Carry2 := 0.0;
			Delta2 := wfxPre.nSamplesPerSec / wfxConv.nSamplesPerSec;
			for i := 0 to cbPre div 2-1 do begin
				Carry2 := Carry2 + Delta2;
				while(Carry2 >= 1.0) do begin
					Carry2 := Carry2 - 1.0;
					Inc(pbPre);
				end;

				pbPre2 := pbPre;
				TempLeft := pbPre2^.Left * DistToWeight(1.0+Carry2);
				TempRight := pbPre2^.Right * DistToWeight(1.0+Carry2);
				Inc(pbPre2);

				TempLeft := TempLeft + pbPre2^.Left * DistToWeight(Carry2);
				TempRight := TempRight + pbPre2^.Right * DistToWeight(Carry2);
				Inc(pbPre2);

				TempLeft := TempLeft + pbPre2^.Left * DistToWeight(1.0-Carry2);
				TempRight := TempRight + pbPre2^.Right * DistToWeight(1.0-Carry2);
				Inc(pbPre2);

				TempLeft := TempLeft + pbPre2^.Left * DistToWeight(2.0-Carry2);
				TempRight := TempRight + pbPre2^.Right * DistToWeight(2.0-Carry2);

				pbConv^.Left := Round(TempLeft);
				pbConv^.Right := Round(TempRight);
				Inc(pbConv);
			end;
		end;
	end;

	for i := 2-1 downto 0 do begin
		Dec(pbPre);
		Prev16BitStereoData[i] := pbPre^;
	end;
end;


//***************************************************************************
// 距離 -> 重みの変換（４点変換用）
//***************************************************************************
function TConvFreq.DistToWeight(x : Double) : Double;
begin
	if(x < 0) then x := -x;
	if(x < 1) then x := 1 - 2*x*x + x*x*x
	else if(x < 2) then x := 4 - 8*x + 5*x*x - x*x*x
	else x := 0.0;

	Result := x;
end;


//***************************************************************************
// バッファのフラッシュ
//***************************************************************************
procedure TConvFreq.FlushBuffer;
var
	i : Integer;
begin
	for i := 0 to 2-1 do begin
		Prev16BitMonoralData[i]      :=   0;
		Prev16BitStereoData[i].Left  :=   0;
		Prev16BitStereoData[i].Right :=   0;
	end;
end;


end.
