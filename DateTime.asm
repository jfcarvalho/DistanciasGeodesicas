;	Universidade Federal da Bahia
;	Departamento de Ciência da Computação
;
;	Disciplina:	MAT149 Linguagens de montagem
;	Professor:	Luiz Eduardo
;
;	Data e horario
;
;	16 de Agosto de 2005
;	28 de Marco de 2007	Novas PROC DateToBin, TimeToBin, DateToAsc, TimeToAsc
;
;	tasm DateTime /l

		INCLUDE	XCall.mac
		.MODEL	SMALL
		DOSSEG
		.386

		.DATA

dayBin		DD	?
monthBin	DD	?
yearBin		DD	?

hoursBin	DD	?
minutesBin	DD	?
secondsBin	DD	?
hundredthsBin	DD	?

dayAsc		DB	2  DUP (?)
monthAsc	DB	2  DUP (?)
yearAsc		DB	4  DUP (?)

hoursAsc	DB	2  DUP (?)
minutesAsc	DB	2  DUP (?)
secondsAsc	DB	2  DUP (?)
hundredthsAsc	DB	2  DUP (?)

monthTable	DB	31,28,31,30,31,30,31,31,20,31,30,31

dateAsc		DB	10 DUP (?)
timeAsc		DB	6  DUP (?)

four		DD	4
hundred		DD	100

argLeng		DD	?
rC		DD	?

		.CODE
		PUBLIC	GetDateBin,GetTimeBin,GetDateAsc,GetTimeAsc
		PUBLIC	DateToBin,TimeToBin,DateToAsc,TimeToAsc
		EXTRN	AscToInt:FAR,IntToAsc:FAR


GetDateBin	PROC	FAR

;	+-------------------------------------------------------------------------+
;	| Chamada:	XCALL	GetDateBin,dayBin,monthBin,yearBin		  |
;	|									  |
;	|		dateBin		DD	?		-->		  |
;	|		monthBin	DD	?		-->		  |
;	|		yearBin		DD	?		-->		  |
;	|									  |
;	+-------------------------------------------------------------------------+

		MOV	AH,2Ah				; Get system date
		INT	21h

GetDateBinDay:
		CMP	DWORD PTR [EBX+4],0
		JE	GetDateBinMonth

		MOVZX	EAX,DL
		MOV	EDI,DWORD PTR [EBX+4]		; day
		MOV	DWORD PTR [EDI],EAX

GetDateBinMonth:
		CMP	DWORD PTR [EBX+8],0
		JE	GetDateBinYear

		MOVZX	EAX,DH
		MOV	EDI,DWORD PTR [EBX+8]		; month
		MOV	DWORD PTR [EDI],EAX

GetDateBinYear:
		CMP	DWORD PTR [EBX+12],0
		JE	GetDateBinReturn

		MOVZX	EAX,CX
		MOV	EDI,DWORD PTR [EBX+12]		; year
		MOV	DWORD PTR [EDI],EAX

GetDateBinReturn:
		RET

		ENDP


GetTimeBin	PROC	FAR

;	+---------------------------------------------------------------------------------------+
;	| Chamada:	XCALL	GetTimeBin,hoursBin,minutesBin,secondsBin,hundredthsBin 	|
;	|									 		|
;	|		hoursBin	DD	?		-->		  		|
;	|		minutesBin	DD	?		-->		  		|
;	|		secondsBin	DD	?		-->		  		|
;	|		hundredthsBin	DD	?		-->		  		|
;	|									  		|
;	+---------------------------------------------------------------------------------------+

		MOV	AH,2Ch				; Get system time
		INT	21h

GetTimeBinHours:
		CMP	DWORD PTR [EBX+4],0
		JE	GetTimeBinMinutes

		MOVZX	EAX,CH
		MOV	EDI,DWORD PTR [EBX+4]		; hours
		MOV	DWORD PTR [EDI],EAX

GetTimeBinMinutes:
		CMP	DWORD PTR [EBX+8],0
		JE	GetTimeBinSeconds

		MOVZX	EAX,CL
		MOV	EDI,DWORD PTR [EBX+8]		; minutes
		MOV	DWORD PTR [EDI],EAX

GetTimeBinSeconds:
		CMP	DWORD PTR [EBX+12],0
		JE	GetTimeBinHundredths

		MOVZX	EAX,DH
		MOV	EDI,DWORD PTR [EBX+12]		; seconds
		MOV	DWORD PTR [EDI],EAX

GetTimeBinHundredths:
		CMP	DWORD PTR [EBX+16],0
		JE	GetTimeBinReturn

		MOVZX	EAX,DL
		MOV	EDI,DWORD PTR [EBX+16]		; hundredths
		MOV	DWORD PTR [EDI],EAX

GetTimeBinReturn:
		RET

		ENDP


GetDateAsc	PROC	FAR

;	+-------------------------------------------------------------------------+
;	| Chamada:	XCALL	GetDateAsc,dayAsc,monthAsc,yearAsc		  |
;	|									  |
;	|		dateAsc		DB	2 DUP (?)	-->		  |
;	|		monthAsc	DB	2 DUP (?)	-->		  |
;	|		yearAsc		DB	4 DUP (?)	-->		  |
;	|									  |
;	+-------------------------------------------------------------------------+

		XCALL	GetDateBin,dayBin,monthBin,yearBin

GetDateAscDay:
		CMP	DWORD PTR [EBX+4],0
		JE	GetDateAscMonth
		MOV	dayAsc[0],'0'
		MOV	argLeng,2
		XCALL	IntToAsc,dayBin,dayAsc,argLeng
		MOV	AX,WORD PTR dayAsc
		MOV	EDI,DWORD PTR [EBX+4]
		MOV	WORD PTR [EDI],AX

GetDateAscMonth:
		CMP	DWORD PTR [EBX+8],0
		JE	GetDateAscYear
		MOV	monthAsc[0],'0'
		MOV	argLeng,2
		XCALL	IntToAsc,monthBin,monthAsc,argLeng
		MOV	AX,WORD PTR monthAsc
		MOV	EDI,DWORD PTR [EBX+8]
		MOV	WORD PTR [EDI],AX

GetDateAscYear:
		CMP	DWORD PTR [EBX+12],0
		JE	GetDateAscReturn
		MOV	yearAsc[0],'0'
		MOV	argLeng,4
		XCALL	IntToAsc,yearBin,yearAsc,argLeng
		MOV	EAX,DWORD PTR yearAsc
		MOV	EDI,DWORD PTR [EBX+12]
		MOV	DWORD PTR [EDI],EAX

GetDateAscReturn:
		RET

		ENDP


GetTimeAsc	PROC	FAR

;	+---------------------------------------------------------------------------------------+
;	| Chamada:	XCALL	GetTimeAsc,hoursAsc,minutesAsc,secondsAsc,hundredthsAsc		|
;	|									 		|
;	|		hoursAsc	DB	2 DUP (?)	-->		  		|
;	|		minutesAsc	DB	2 DUP (?)	-->		  		|
;	|		secondsAsc	DB	2 DUP (?)	-->		  		|
;	|		hundredthsAsc	DB	2 DUP (?)	-->		  		|
;	|									  		|
;	+---------------------------------------------------------------------------------------+

		XCALL	GetTimeBin,hoursBin,minutesBin,secondsBin,hundredthsBin

GetTimeAscHours:
		CMP	DWORD PTR [EBX+4],0
		JE	GetTimeAscMinutes
		MOV	hoursAsc[0],'0'
		MOV	argLeng,2
		XCALL	IntToAsc,hoursBin,hoursAsc,argLeng
		MOV	AX,WORD PTR hoursAsc
		MOV	EDI,DWORD PTR [EBX+4]
		MOV	WORD PTR [EDI],AX

GetTimeAscMinutes:
		CMP	DWORD PTR [EBX+8],0
		JE	GetTimeAscSeconds
		MOV	minutesAsc[0],'0'
		MOV	argLeng,2
		XCALL	IntToAsc,minutesBin,minutesAsc,argLeng
		MOV	AX,WORD PTR MinutesAsc
		MOV	EDI,DWORD PTR [EBX+8]
		MOV	WORD PTR [EDI],AX

GetTimeAscSeconds:
		CMP	DWORD PTR [EBX+12],0
		JE	GetTimeAscHundredths
		MOV	secondsAsc[0],'0'
		MOV	argLeng,2
		XCALL	IntToAsc,secondsBin,secondsAsc,argLeng
		MOV	AX,WORD PTR secondsAsc
		MOV	EDI,DWORD PTR [EBX+12]
		MOV	WORD PTR [EDI],AX

GetTimeAscHundredths:
		CMP	DWORD PTR [EBX+16],0
		JE	GetTimeAscReturn
		MOV	hundredthsAsc[0],'0'
		MOV	argLeng,2
		XCALL	IntToAsc,hundredthsBin,hundredthsAsc,argLeng
		MOV	AX,WORD PTR hundredthsAsc
		MOV	EDI,DWORD PTR [EBX+16]
		MOV	WORD PTR [EDI],AX

GetTimeAscReturn:
		RET

		ENDP


DateToBin	PROC	FAR

;	+---------------------------------------------------------------------------------------+
;	| Chamada:	XCALL	DateToBin,dateAsc,dateBin,rC                                    |
;	|											|
;	|		dateAsc		DB	nn DUP (?)		<--			|
;	|		dateBin		DB	?		day	-->			|
;	|				DB	?		month	-->			|
;	|				DW	?		year	-->			|
;	|		rc		DD	?			-->			|
;	|											|
;	+---------------------------------------------------------------------------------------+

		MOV	ESI,DWORD PTR[EBX+4]
		MOV	AL,BYTE PTR[ESI+2]
		CMP	AL,'/'
		JE	DateSeparator
		CMP	AL,'-'
		JE	DateSeparator
		CMP	AL,'.'
		JE	DateSeparator
		CMP	AL,' '
		JE	DateSeparator
		JMP	InvalidDate

DateSeparator:
		CMP	BYTE PTR[ESI+5],AL
		JNE	InvalidDate

		CLD
		LEA	EDI,dateAsc
		MOV	ECX,10
		REP	MOVSB

ExtractDayAsc:
		MOV	argLeng,2
		XCALL	AscToInt,dateAsc[0],argLeng,dayBin,rC
		CMP	rC,0
		JNE	InvalidDate
		CMP	dayBin,1
		JL	InvalidDate
		CMP	dayBin,31
		JG	InvalidDate

ExtractMonthAsc:
		MOV	argLeng,2
		XCALL	AscToInt,dateAsc[3],argLeng,monthBin,rC
		CMP	rC,0
		JNE	InvalidDate
		CMP	monthBin,1
		JL	InvalidDate
		CMP	monthBin,12
		JG	InvalidDate

ExtractYearAsc:
		MOV	argLeng,4
		XCALL	AscToInt,dateAsc[6],argLeng,YearBin,rC
		CMP	rC,0
		JNE	InvalidDate

VerifyDate:
		CMP	dayBin,28
		JNG	ValidDate
		CMP	monthBin,2
		JNE	VerifyDay

February:
		MOV	monthTable[1],28
		MOV	EDX,0
		MOV	EAX,yearBin
		DIV	four
		CMP	EDX,0
		JNE	VerifyDay
		MOV	EAX,yearBin
		DIV	hundred
		CMP	EDX,0
		JNE	LeapYear
		DIV	four
		CMP	EDX,0
		JNE	VerifyDay

LeapYear:
		MOV	monthTable[1],29

VerifyDay:
		MOV	ESI,monthBin
		MOV	EAX,dayBin
		CMP	AL,monthTable[ESI-1]
		JG	InvalidDate

ValidDate:
		MOV	EDI,DWORD PTR[EBX+8]
		MOV	EAX,dayBin
		MOV	BYTE PTR[EDI],AL
		MOV	EAX,monthBin
		MOV	BYTE PTR[EDI+1],AL
		MOV	EAX,yearBin
		MOV	WORD PTR[EDI+2],AX
		MOV	EDI,DWORD PTR[EBX+12]
		MOV	DWORD PTR[EDI],0
		RET

InvalidDate:
		MOV	EDI,DWORD PTR[EBX+12]
		MOV	DWORD PTR[EDI],1
		RET

		ENDP


TimeToBin	PROC	FAR

;	+---------------------------------------------------------------------------------------+
;	| Chamada:	XCALL	TimeToBin,timeAsc,timeBin,rC                                    |
;	|											|
;	|		timeAsc		DB	nn DUP (?)		<--			|
;	|		timeBin		DB	?		hours	-->			|
;	|				DB	?		mimutes	-->			|
;	|		rc		DD	?			-->			|
;	|											|
;	+---------------------------------------------------------------------------------------+

		MOV	ESI,DWORD PTR[EBX+4]
		MOV	AL,BYTE PTR[ESI+2]
		CMP	AL,':'
		JE	ExtractHoursAsc
		CMP	AL,'-'
		JE	ExtractHoursAsc
		CMP	AL,'.'
		JE	ExtractHoursAsc
		CMP	AL,' '
		JE	ExtractHoursAsc
		JMP	InvalidTime

ExtractHoursAsc:
		CLD
		LEA	EDI,timeAsc
		MOV	ECX,5
		REP	MOVSB

		MOV	argLeng,2
		XCALL	AscToInt,timeAsc[0],argLeng,hoursBin,rC
		CMP	rC,0
		JNE	InvalidTime
		CMP	hoursBin,0
		JL	InvalidTime
		CMP	hoursBin,23
		JG	InvalidTime

ExtractMinutesAsc:
		MOV	argLeng,2
		XCALL	AscToInt,timeAsc[3],argLeng,minutesBin,rC
		CMP	rC,0
		JNE	InvalidTime
		CMP	minutesBin,0
		JL	InvalidTime
		CMP	minutesBin,59
		JG	InvalidTime

ValidTime:
		MOV	EDI,DWORD PTR[EBX+8]
		MOV	EAX,hoursBin
		MOV	BYTE PTR[EDI],AL
		MOV	EAX,minutesBin
		MOV	BYTE PTR[EDI+1],AL

		MOV	EDI,DWORD PTR[EBX+12]
		MOV	DWORD PTR[EDI],0
		RET

InvalidTime:
		MOV	EDI,DWORD PTR[EBX+12]
		MOV	DWORD PTR[EDI],1
		RET

		ENDP


DateToAsc	PROC	FAR

;	+---------------------------------------------------------------------------------------+
;	| Chamada:	XCALL	DateToAsc,dateBin,dateAsc[,separator]                           |
;	|											|
;	|		dateBin		DB	?		day	<--			|
;	|				DB	?		month	<--			|
;	|				DW	?		year	<--			|
;	|		dateAsc		DB	10 DUP (?)		-->			|
;	|		separator	DB	?			<-- default = '/'	|
;	|											|
;	+---------------------------------------------------------------------------------------+

		MOV	ESI,DWORD PTR[EBX+4]
		MOV	EDI,DWORD PTR[EBX+8]

ExtractDayBin:
		MOVZX	EAX,BYTE PTR[ESI]
		MOV	dayBin,EAX
		MOV	argLeng,2
		MOV	dateAsc[0],'0'
		XCALL	IntToAsc,dayBin,dateAsc[0],argLeng

ExtractMonthBin:
		MOVZX	EAX,BYTE PTR[ESI+1]
		MOV	monthBin,EAX
		MOV	argLeng,2
		MOV	dateAsc[3],'0'
		XCALL	IntToAsc,monthBin,dateAsc[3],argLeng


ExtractYearBin:
		MOVZX	EAX,WORD PTR[ESI+2]
		MOV	yearBin,EAX
		MOV	argLeng,4
		MOV	dateAsc[6],'0'
		XCALL	IntToAsc,yearBin,dateAsc[6],argLeng

		MOV	dateAsc[2],'/'
		MOV	dateAsc[5],'/'

		CMP	DWORD PTR[EBX+12],0
		JE	MoveDateAsc

		MOV	ESI,DWORD PTR[EBX+12]
		MOV	AL,BYTE PTR[ESI]
		MOV	dateAsc[2],AL
		MOV	dateAsc[5],AL

MoveDateAsc:
		CLD
		LEA	ESI,dateAsc
		MOV	ECX,10
		REP	MOVSB

		RET

		ENDP


TimeToAsc	PROC	FAR

;	+---------------------------------------------------------------------------------------+
;	| Chamada:	XCALL	TimeToAsc,TimeBin,timeAsc[,separator]                           |
;	|											|
;	|		timeBin		DB	?		hours	<--			|
;	|				DB	?		minutes	<--			|
;	|		timeAsc		DB	6 DUP (?)		-->			|
;	|		separator	DB	?			<-- default = ':'	|
;	|											|
;	+---------------------------------------------------------------------------------------+

		MOV	ESI,DWORD PTR[EBX+4]
		MOV	EDI,DWORD PTR[EBX+8]

ExtractHoursBin:
		MOVZX	EAX,BYTE PTR[ESI]
		MOV	hoursBin,EAX
		MOV	argLeng,3
		MOV	timeAsc[0],'0'
		XCALL	IntToAsc,hoursBin,timeAsc[0],argLeng
		CMP	timeAsc[0],'0'
		JNE	ExtractMinutesBin
		MOV	timeAsc[0],' '

ExtractMinutesBin:
		MOVZX	EAX,BYTE PTR[ESI+1]
		MOV	minutesBin,EAX
		MOV	argLeng,2
		MOV	timeAsc[4],'0'
		XCALL	IntToAsc,minutesBin,timeAsc[4],argLeng

		MOV	timeAsc[3],':'

		CMP	DWORD PTR[EBX+12],0
		JE	MoveTimeAsc

		MOV	ESI,DWORD PTR[EBX+12]
		MOV	AL,BYTE PTR[ESI]
		MOV	timeAsc[3],AL

MoveTimeAsc:
		CLD
		LEA	ESI,timeAsc
		MOV	ECX,6
		REP	MOVSB

		RET

		ENDP


		END
