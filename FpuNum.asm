;	Universidade Federal da Bahia
;	Departamento de Ciência da Computação
;
;	Disciplina:	MAT149 Linguagens de montagem
;	Professor:	Luiz Eduardo
;
;	Conversao de tipo numericos - reais FPU
;
;	9 de Setembro de 2005
;
;	tasm FpuNum /l

		INCLUDE	XCall.mac

		.MODEL	SMALL
		DOSSEG
		.386

		.DATA

saveEnvironment	DB	108 DUP (?)
setEnvironment	DB	108 DUP (?)
fpuCw		DW	?

precision	DD	?
notation	DB	?
sigNum		DB	?
sigExp		DB	?

digit		DD	?
decimal		DD	?
exponent	DD	?

maxSingle	DQ	1.7E+38,-38.0,+38.0
maxDouble	DQ	8.9E+307,-307.0,+307.0
maxIst		DQ	9223372036854775807

maxNum		DQ	?
minExp		DQ	?
maxExp		DQ	?

decLim		DD	?
lowLim		DD	?

float		DQ	?

integerCount	DD	?
integerFpu	DD	36 DUP (?)

zero		DQ	0.0
one		DQ	1.0
ten		DQ	10.0
halfBilion	DQ	500000000.0
bilion		DQ	1000000000.0
nines		DQ	999999999.0

intTen		DD	10

zeroAsc		DB	'0,'
		DB	63 DUP ('0')

		.CODE
		PUBLIC	AscToFpu,FpuToAsc


AscToFpu	PROC	FAR

; +---------------------------------------------------------------------+
; | Chamada:	XCALL	AscToFpu[,precision],numAsc,length,numFpu,rC	|
; |									|
; |		numAsc		DB	nnn DUP (?)		<--	|
; |		precision	DD	32 ou 64 default=64	<--	|
; |		length		DD	nnn			<--	|
; |		numFpu		DD/Q	?			-->	|
; |		rC		DD	?			-->	|
; |									|
; | Retorno:	rC = 0: numFpu <-- numAsc				|
; |		rC = 1: numAsc excede maximo				|
; |		rC = 2: numAsc nao numerico				|
; |		rC = 3: precision invalido				|
; +---------------------------------------------------------------------+

		CLD
		FSAVE	saveEnvironment

		CMP	DWORD PTR [EBX+4],0
		JE	DoublePrecision
		MOV	ESI,DWORD PTR [EBX+4]		; precision

SetPrecision:
		CMP	DWORD PTR [ESI],32
		JE	SinglePrecision
		CMP	DWORD PTR [ESI],64
		JE	DoublePrecision
		JMP	InvalidPrecision

SinglePrecision:
		MOV	precision,32
		FLD	maxSingle[0]
		FSTP	maxNum
		FLD	maxSingle[8]
		FSTP	minExp
		FLD	maxSingle[16]
		FSTP	maxExp
		JMP	CaptureParameters

DoublePrecision:
		MOV	precision,64
		FLD	maxDouble[0]
		FSTP	maxNum
		FLD	maxDouble[8]
		FSTP	minExp
		FLD	maxDouble[16]
		FSTP	maxExp

CaptureParameters:
		MOV	ESI,DWORD PTR [EBX+12]		; length
		MOV	ECX,DWORD PTR [ESI]
		MOV	ESI,DWORD PTR [EBX+8]		; numAsc

		PUSH	EBX

SearchNumber:
		CMP	BYTE PTR [ESI],' '
		JE	NextChar
		CMP	BYTE PTR [ESI],13		; CR
		JE	NextChar
		CMP	BYTE PTR [ESI],10		; LF
		JE	NextChar
		CMP	BYTE PTR [ESI],9		; \t
		JE	NextChar
		JMP	BeginNumber

NextChar:
		INC	ESI
		LOOP	SearchNumber
		JMP	InvalidNumber

BeginNumber:
		FLDZ
		MOV	EBX,0
		MOV	EDX,0
		MOV	decimal,0
		MOV	exponent,0

		MOV	sigNum,'+'
		CMP	BYTE PTR [ESI],'+'
		JE	signalNumber
		CMP	BYTE PTR [ESI],'-'
		JNE	NotSignalNumber
		MOV	sigNum,'-'

SignalNumber:
		INC	ESI
		DEC	ECX

NotSignalNumber:
		CMP	ECX,0
		JNG	InvalidNumber
		CMP	BYTE PTR [ESI],','
		JE	TranslateNumber
		CMP	BYTE PTR [ESI],'0'
		JB	InvalidNumber
		CMP	BYTE PTR [ESI],'9'
		JA	InvalidNumber

TranslateNumber:
		CMP	BYTE PTR [ESI],' '
		JE	InsertFpuSignal
		CMP	BYTE PTR [ESI],13		; CR
		JE	InsertFpuSignal
		CMP	BYTE PTR [ESI],10		; LF
		JE	InsertFpuSignal
		CMP	BYTE PTR [ESI],9		; \t
		JE	InsertFpuSignal
		CMP	BYTE PTR [ESI],','
		JE	DecimalPart
		CMP	BYTE PTR [ESI],'E'
		JE	ExponentPart
		CMP	BYTE PTR [ESI],'e'
		JE	ExponentPart
		CMP	BYTE PTR [ESI],'0'
		JB	InvalidNumber
		CMP	BYTE PTR [ESI],'9'
		JA	InvalidNumber
		MOV	BL,BYTE PTR [ESI]
		SUB	BL,30h
		MOVZX	EAX,BL
		MOV	digit,EAX
		FMUL	ten
		FIADD	digit
		FCOM	maxNum
		FSTSW	AX
		SAHF
		JA	OutRangeNumber
		INC	ESI
		LOOP	TranslateNumber
		JMP	InsertFpuSignal

Decimalpart:
		INC	ESI
		DEC	ECX

TranslateDecimal:
		CMP	BYTE PTR [ESI],' '
		JE	FinalDecimal
		CMP	BYTE PTR [ESI],13		; CR
		JE	FinalDecimal
		CMP	BYTE PTR [ESI],10		; LF
		JE	FinalDecimal
		CMP	BYTE PTR [ESI],9		; \t
		JE	FinalDecimal
		CMP	BYTE PTR [ESI],'E'
		JE	ExponentPart
		CMP	BYTE PTR [ESI],'e'
		JE	ExponentPart
		CMP	BYTE PTR [ESI],'0'
		JB	InvalidNumber
		CMP	BYTE PTR [ESI],'9'
		JA	InvalidNumber
		MOV	BL,BYTE PTR [ESI]
		SUB	BL,30h
		MOVZX	EAX,BL
		MOV	digit,EAX
		FMUL	ten
		FIADD	digit
		FCOM	maxNum
		FSTSW	AX
		SAHF
		JA	OutRangeNumber
		INC	decimal
		INC	ESI
		LOOP	TranslateDecimal

FinalDecimal:
		CMP	decimal,0
		JE	InsertFpuSignal

		FILD	decimal

		FCOMP	maxExp
		FSTSW	AX
		SAHF
		JA	OutRangeNumber

		MOV	ECX,decimal
		FLD1

DecimalFpuMultiply:
		FMUL	ten
		LOOP	DecimalFpuMultiply

		FDIVP	ST(1),ST(0)
		JMP	InsertFpuSignal

ExponentPart:
		INC	ESI
		DEC	ECX
		CMP	ECX,0
		JNG	InvalidNumber

		FLDZ
		MOV	EBX,0
		MOV	EDX,0

		MOV	sigExp,'+'
		CMP	BYTE PTR [ESI],'+'
		JE	signalExponent
		CMP	BYTE PTR [ESI],'-'
		JNE	NotSignalExponent
		MOV	sigExp,'-'

SignalExponent:
		INC	ESI
		DEC	ECX

NotSignalExponent:
		CMP	ECX,0
		JNG	InvalidNumber
		CMP	BYTE PTR [ESI],'0'
		JB	InvalidNumber
		CMP	BYTE PTR [ESI],'9'
		JA	InvalidNumber

TranslateAscExponent:
		CMP	BYTE PTR [ESI],' '
		JE	CalculateExponent
		CMP	BYTE PTR [ESI],13		; CR
		JE	CalculateExponent
		CMP	BYTE PTR [ESI],10		; LF
		JE	CalculateExponent
		CMP	BYTE PTR [ESI],9		; \t
		JE	CalculateExponent
		CMP	BYTE PTR [ESI],'0'
		JB	InvalidNumber
		CMP	BYTE PTR [ESI],'9'
		JA	InvalidNumber
		MOV	BL,BYTE PTR [ESI]
		SUB	BL,30h
		MOVZX	EAX,BL
		MOV	digit,EAX
		FMUL	ten
		FIADD	digit
		INC	ESI
		LOOP	TranslateAscExponent

CalculateExponent:
		CMP	sigExp,'+'
		JE	FinalExponent
		FCHS

FinalExponent:
		FISUB	decimal
		FCOM	minExp
		FSTSW	AX
		SAHF
		JB	OutRangeNumber

		FCOM	maxExp
		FSTSW	AX
		SAHF
		JA	OutRangeNumber

		FISTP	exponent

		CMP	exponent,0
		JE	InsertFpuSignal
		MOV	ECX,exponent
		FLD1
		CMP	ECX,0
		JNL	ExponentFpuMultiply
		NEG	ECX

ExponentFpuMultiply:
		FMUL	ten
		LOOP	ExponentFpuMultiply

		CMP	exponent,0
		JL	NegativeExponent

PositiveExponent:
		FMULP	ST(1),ST(0)
		JMP	InsertFpuSignal

NegativeExponent:
		FDIVP	ST(1),ST(0)
		
InsertFpuSignal:
		CMP	sigNum,'+'
		JE	ReturnOkFpu
		FCHS

ReturnOkFpu:
		POP	EBX
		MOV	EDI,DWORD PTR [EBX+20]		; rC
		MOV	DWORD PTR [EDI],0

		MOV	EDI,DWORD PTR [EBX+16]		; numFpu
		CMP	precision,32
		JE	ReturnSingleFpu

ReturnDoubleFpu:
		FSTP	QWORD PTR [EDI]
		JMP	ReturnFpu

ReturnSingleFpu:
		FSTP	DWORD PTR [EDI]
		JMP	ReturnFpu

OutRangeNumber:
		POP	EBX
		MOV	EDI,DWORD PTR [EBX+20]		; rC
		MOV	DWORD PTR [EDI],1
		JMP	ReturnFpu

InvalidNumber:
		POP	EBX
		MOV	EDI,DWORD PTR [EBX+20]		; rC
		MOV	DWORD PTR [EDI],2
		JMP	ReturnFpu

InvalidPrecision:
		POP	EBX
		MOV	EDI,DWORD PTR [EBX+20]		; rC
		MOV	DWORD PTR [EDI],3

ReturnFpu:
		MOV	EDI,DWORD PTR [EBX+12]		; length
		SUB	ESI,DWORD PTR [EBX+8]		; ascNum
		MOV	DWORD PTR[EDI],ESI		; exact length
		FRSTOR	saveEnvironment
		RET

		ENDP

					
FpuToAsc	PROC	FAR

; +-------------------------------------------------------------------------------------+
; | Chamada:	XCALL	FpuToAsc[,precision],numFpu,numAsc,length[,notation][,decimal]	|
; |											|
; |		precision	DD	32 ou 64	; default=64	<--		|
; |		numFpu		DQ	?				<--		|
; |		numAsc		DB	nnn DUP (?)			-->		|
; |		length		DD	?				<--		|
; |		notation	DB	'D' ou 'E'	; default='D'	<--		|
; |		decimal		DD	?		; default=0	<--		|
; +-------------------------------------------------------------------------------------+

		CLD
		FSAVE	saveEnvironment

		FSTCW	fpuCw
		OR	fpuCw,0000110000000000b
		FLDCW	fpuCw

		FSAVE	setEnvironment
		FRSTOR	setEnvironment

		MOV	precision,64
		CMP	DWORD PTR [EBX+4],0
		JE	ReceiveFpu

		MOV	ESI,DWORD PTR [EBX+4]		; precision
		CMP	DWORD PTR [ESI],64
		JE	ReceiveFpu
		MOV	precision,32

ReceiveFpu:
		MOV	ESI,DWORD PTR [EBX+8]		; numFpu

		CMP	precision,64
		JE	ReceiveDoubleFpu

ReceiveSingleFpu:
		FLD	DWORD PTR [ESI]
		JMP	NumberSignal

ReceiveDoubleFpu:
		FLD	QWORD PTR [ESI]

NumberSignal:
		MOV	sigNum,'+'
		FCOM	zero
		FSTSW	AX
		SAHF
		JNB	ReceiveNotation
		MOV	sigNum,'-'
		FCHS

ReceiveNotation:
		MOV	notation,'D'
		CMP	DWORD PTR [EBX+20],0
		JE	ReceiveDecimal
		MOV	ESI,DWORD PTR [EBX+20]		; notation
		AND	BYTE PTR [ESI],11011111b
		CMP	BYTE PTR [ESI],'E'
		JNE	ReceiveDecimal
		MOV	notation,'E'

ReceiveDecimal:
		MOV	decimal,0
		MOV	decLim,0
		MOV	lowLim,0
		CMP	DWORD PTR [EBX+24],0
		JE	InitializeAsc
		MOV	ESI,DWORD PTR [EBX+24]		; decimal
		MOV	EAX,DWORD PTR [ESI]
		MOV	decimal,EAX
		CMP	decimal,0
		JNL	InitializeAsc
		MOV	decimal,0

InitializeAsc:
		MOV	EDI,DWORD PTR [EBX+12]		; numAsc
		MOV	ESI,DWORD PTR [EBX+16]		; length
		MOV	ECX,DWORD PTR [ESI]

		SUB	ECX,decimal
		SUB	ECX,2

		MOV	ESI,EDI
		LODSB
		REP	STOSB

		MOV	ECX,decimal
		ADD	ECX,2
		LEA	ESI,zeroAsc
		REP	MOVSB
		DEC	EDI

NormalizeFpu:
		FST	float
		FCOM	zero
		FSTSW	AX
		SAHF
		JE	ReturnAsc
		MOV	exponent,0

NormalizeMultiply:
		FCOM	one
		FSTSW	AX
		SAHF
		JNB	NormalizeDivide
		FMUL	ten
		DEC	exponent
		JMP	NormalizeMultiply

NormalizeDivide:
		FCOM	one
		FSTSW	AX
		SAHF
		JB	NormalizeExponent
		FDIV	ten
		INC	exponent
		JMP	NormalizeDivide

NormalizeExponent:
		CMP	notation,'D'
		JE	DecimalNotation

ScientificNotation:
		FILD	decimal
		FCOMP	maxExp
		FSTSW	AX
		SAHF
		JNA	ExponentSignal
		FLD	maxExp
		FISTP	decimal

ExponentSignal:
		MOV	EAX,exponent
		MOV	sigExp,'+'
		CMP	EAX,0
		JNL	TranslateFpuExponent
		MOV	sigExp,'-'
		NEG	EAX

TranslateFpuExponent:
		MOV	EDX,0
		DIV	intTen
		ADD	DL,30h
		MOV	BYTE PTR [EDI],DL
		DEC	EDI
		CMP	EAX,0
		JG	TranslateFpuExponent

		MOV	DL,sigExp
		MOV	BYTE PTR [EDI],DL
		MOV	BYTE PTR [EDI-1],'E'
		SUB	EDI,2
		MOV	exponent,0
		CMP	decimal,0
		JE	ReturnAsc

DecimalNotation:
		MOV	ECX,decimal
		MOV	decLim,ECX
		ADD	ECX,exponent
		CMP	ECX,0
		JNG	IntegerConvert

		FLD1

		MOV	decimal,ECX
		FILD	decimal
		FCOMP	maxExp
		FSTSW	AX
		SAHF
		JNA	DecimalAscMultiply
		FLD	maxExp
		FISTP	decimal

DecimalAscMultiply:
		FMUL	ten
		LOOP	DecimalAscMultiply

		FMULP	ST(1),ST(0)

IntegerConvert:
		PUSH	EDI
		LEA	EDI,IntegerFpu
		MOV	ECX,36
		MOV	EAX,0
		REP	STOSD

		LEA	EDI,IntegerFpu
		MOV	IntegerCount,1
		MOV	ECX,1

IntegerFpuDivide:
		FCOM	bilion
		FSTSW	AX
		SAHF
		JB	IntegerFpuExtract
		FDIV	bilion
		INC	integerCount
		INC	ECX
		JMP	IntegerFpuDivide

IntegerFpuExtract:
		FIST	IntegerFpu[EDI]
		FMUL	bilion
		FILD	IntegerFpu[EDI]
		FMUL	bilion
		FSUBP	ST(1),ST(0)
		ADD	EDI,4
		FCOM	nines
		FSTSW	AX
		SAHF
		JB	LoopIntegerFpuExtract
		INC	IntegerFpu[EDI-4]
		FSUB	nines

LoopIntegerFpuExtract:
		LOOP	IntegerFpuExtractNear

		SUB	EDI,4
		MOV	ECX,integerCount
		FCOMP	halfBilion
		FSTSW	AX
		SAHF
		JB	TranslateFpu
		INC	IntegerFpu[EDI]
		JMP	TranslateFpu

IntegerFpuExtractNear:
		JMP	IntegerFpuExtract

TranslateFpu:
		MOV	ESI,EDI
		POP	EDI
		MOV	EAX,IntegerFpu[ESI]
		MOV	lowLim,9
		CMP	ECX,1
		JG	TranslateFpuDigit
		MOV	EBX,decLim
		MOV	lowLim,EBX

TranslateFpuDigit:
		MOV	EDX,0
		DIV	intTen
		ADD	DL,30h
		MOV	BYTE PTR [EDI],DL
		DEC	EDI
		DEC	lowLim
		DEC	decLim
		JNZ	NoDecimalPoint
		MOV	BYTE PTR [EDI],','
		DEC	EDI

NoDecimalPoint:
		CMP	EAX,0
		JG	TranslateFpuDigit
		CMP	lowLim,0
		JG	TranslateFpuDigit
		SUB	ESI,4
		MOV	EAX,IntegerFpu[ESI]
		MOV	lowLim,9
		CMP	ECX,2
		JG	LoopTranslateFpu
		MOV	EBX,decLim
		MOV	lowLim,EBX

LoopTranslateFpu:
		LOOP	TranslateFpuDigit

InsertAscSignal:
		CMP	notation,'E'
		JE	FinalScientificNotation
		CMP	BYTE PTR [EDI+1],','
		JE	InsertAscZero
		CMP	decLim,0
		JG	InsertAscZero
		CMP	sigNum,'+'
		JE	ReturnAsc
		MOV	BYTE PTR [EDI],'-'
		JMP	ReturnAsc

InsertAscZero:
		MOV	BYTE PTR [EDI],'0'
		DEC	EDI
		DEC	decLim
		JNZ	InsertAscSignal
		MOV	BYTE PTR [EDI+1],','
		JMP	InsertAscSignal

FinalScientificNotation:
		MOV	BYTE PTR [EDI],'0'
		MOV	DL,sigNum
		MOV	BYTE PTR [EDI-1],DL
		JMP	ReturnAsc

ReturnAsc:
		FRSTOR	saveEnvironment
		RET
	
		ENDP		

		END
