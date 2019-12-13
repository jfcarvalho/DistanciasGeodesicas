;	Universidade Federal da Bahia
;	Departamento de Ciência da Computação
;
;	Disciplina:	MAT149 Linguagens de montagem
;	Professor:	Luiz Eduardo
;
;	Calcula distâncias geodésicas
;
;	24 de Maio de 2012
;
;	tasm  GeoCalc /z
;	tlink GeoCalc+DateTime+ScreKeyb+IntNum+FpuNum+FileDisk /3

		INCLUDE	XCall.mac
		INCLUDE	Macros.mac

		.MODEL SMALL
		.386
		DOSSEG
		.STACK	256
		.DATA

		DD	12 DUP (?)

cabecalho	DB	'Universidade Federal da Bahia'
		DB	30 DUP (' ')
cabDay		DB	2  DUP ('0')
		DB	'/'
cabMonth	DB	2  DUP ('0')
		DB	'/'
cabYear		DB	4  DUP ('0')
		DB	'  '
cabHours	DB	2  DUP ('0')
		DB	':'
cabMinutes	DB	2  DUP ('0')
		DB	':'
cabSeconds	DB	2  DUP ('0')
		DB	13,10
		DB	'Departamento de Ciencia da Computacao',13,10
		DB	'MATA49 Programacao de software basico',13,10,13,10
		DB	'Calculo de distancias geodesicas',13,10
tamCabecalho	EQU	$-cabecalho




OgeoCoord EQU $
OgeoCoordLocal             DB     30 DUP (?) ; nome da localidade
OgeoCoordLatGra            DB     ? ; latitude graus (0-90)
OgeoCoordLatMin            DB     ? ; latitude minutos (0-59)
OgeoCoordLatOri            DB     ? ; latitude orientação ('N'|'S')
OgeoCoordLonGra            DB     ? ; longitude graus (0-180)
OgeoCoordLonMin            DB     ? ; longitude minutos (0-59)
OgeoCoordLonOri            DB     ? ; longitude orientação ('E'|'W')

DgeoCoord EQU $
DgeoCoordLocal             DB     30 DUP (?) ; nome da localidade
DgeoCoordLatGra            DB     ? ; latitude graus (0-90)
DgeoCoordLatMin            DB     ? ; latitude minutos (0-59)
DgeoCoordLatOri            DB     ? ; latitude orientação ('N'|'S')
DgeoCoordLonGra            DB     ? ; longitude graus (0-180)
DgeoCoordLonMin            DB     ? ; longitude minutos (0-59)
DgeoCoordLonOri            DB     ? ; longitude orientação ('E'|'W')
DtamanhogeoCoord            DD    36

tamanhogeoCoord            DD    36


pedelatitude            DB    'Latitude  <graus, minutos, orientacao>                        : '
tamanhopedelatitude       EQU    $-pedelatitude

pedelongitude           DB    'Longitude <graus, minutos, orientacao>                        : '
tamanhopedelongitude        EQU    $-pedelongitude

errolatitude            DB    'Latitude invalida - repita a operacao',10,13
tamanhoerrolatitude        EQU    $-errolatitude


errolongitude            DB    'Longitude invalida - repita a operacao',10,13
tamanhoerrolongitude        EQU    $-errolongitude


pedelocalidadeorigem	DB		13,10
						DB		'Localidade origem ou <ENTER>=FIM	                      :'
tamanhopedelocalidadeorigem		EQU	$-pedelocalidadeorigem

Dpedelocalidadeorigem	DB		13,10
						DB		'Localidade origem ou <ENTER>=CONTINUAR	                      :'
Dtamanhopedelocalidadeorigem		EQU	$-Dpedelocalidadeorigem

pedenomearquivo			DB		13,10
						DB		'Arquivo de coordenadas ou localidade ou <ENTER>=FIM    	      :'
tamanhopedenomearquivo	EQU		$-pedenomearquivo


pederelatorio			DB		13,10
						DB		'Arquivo para gravar relatorio ou <ENTER> = monitor       :'    
tamanhopederelatorio	EQU		$-pederelatorio

Orelatorio			DB		13,10
					DB		'Localidade origem            Latitude         Longitude',10,13    
Otamanhorelatorio	EQU		$-Orelatorio

Drelatorio			DB		13,10
					DB		'Localidade                   Latitude         Longitude    Distancia <km>',10,13    
Dtamanhorelatorio	EQU		$-Drelatorio

espaco				DB		' '
tamanhoespaco		EQU		$-espaco

espacogrande		DB		'         '
tamanhoespacogrande	EQU		$-espacogrande

pulalinha			DB	10,13
tamanhopulalinha	EQU	$-pulalinha

Um   	DB '1'
tamUm	EQU $- Um
reserva DD	?
tamanho                DD    ?
buffer                DB     30 DUP(' ')
handArquivo            DD   ?
handRelatorio			DD	?
handArquivoLido			DD	?
inteiro                DD    ?
rC                    DD    ?
lol					DW	?
centoeoitenta		DW	180
radlatori			DW	?
radlonori			DW	?
radlatdest			DW	?
radlondest			DW	?


oriDestLat DB ?
oriDestLon DB 	?
oriOrigemLon DB ?
oriOrigemLat DB ?

grauOrigemLat DW ?
minOrigemLat DW ?
grauOrigemLon DW ?
minOrigemLon DW ?

grauDestLat DW ?
minDestLat DW ?
grauDestLon DW ?
minDestLon DW ?

radianos DQ ? ;conversao para radianos
sessenta DW 60
centoOitenta DW 180
radianoLatOri DQ ?
radianoLonOri DQ ?
radianoLatLoc DQ ?
radianoLonLoc DQ ?
radianoA DQ ?
lenght DD ?
Raio DD 6371
distancia DQ ?
arcoA DQ ? ;arcotangente (sen(a)/cos(a))
bRad DQ ?
cRad DQ ?
ARad DQ ?
grausLatPolo DD 90 ; NY
minutosLatPolo DD 0

;senos e cossenos necessarios para aplicar a lei dos cossenos para achar aCos.
bCos DQ ?
cCos DQ ?
bSin DQ ?
cSin DQ ?
CosA DQ ?
aCos DQ ?
aSin DQ ?


bcosvezesccos DQ ?
bsinvezescsin DQ ?
bcvezescosa DQ ?


precision DD 64
notation DB 'D'
decimal DD 4
numAsc DB 12 DUP (?)




		.CODE	
		EXTRN	AscToInt:FAR,IntToAsc:FAR
		EXTRN	AscToFpu:FAR,FpuToAsc:FAR
		EXTRN	GetDateAsc:FAR,GetTimeAsc:FAR
		EXTRN	DateToAsc:FAR,TimeToAsc:FAR
		EXTRN	ScreenClear:FAR,ScreenWrite:FAR,KeyboardRead:FAR
		EXTRN	FileCreate:FAR,FileOpen:FAR,FileRead:FAR,FileWrite:FAR,FileClose:FAR

		INIPROG

		XCALL	GetDateAsc,cabDay,cabMonth,cabYear
		XCALL	GetTimeAsc,cabHours,cabMinutes,cabSeconds

		MOV	tamanho,tamCabecalho
		ID	cabecalho,tamanho

		CLD

		recebelocalidadeorigem: 
		 MOV AL,20h
  		 MOV ECX,36
  		 LEA EDI,OgeoCoordLocal
  		 REP STOSB
            MOV    tamanho,tamanhopedelocalidadeorigem
            XCALL   ScreenWrite, pedelocalidadeorigem, tamanho
            MOV    tamanho, SIZE buffer
            XCALL    KeyboardRead, buffer, tamanho
            CMP    tamanho, 2
            JLE    encerraprograma
            ;grava o local na estrutura
            MOV     ECX, tamanho
              SUB     ECX,2
              LEA     ESI,buffer
              LEA     EDI,OgeoCoordLocal
              REP      movsb
            JMP    recebeLatitudeorigem


        recebelatitudeorigem:  
            MOV    tamanho,tamanhopedelatitude
                   XCALL   ScreenWrite,pedelatitude,tamanho
                   LEA        ESI,buffer
                   MOV        tamanho,SIZE buffer
                   XCALL   KeyboardRead,buffer,tamanho
                  CMP        tamanho,2
                   JLE        recebeLatitudeorigem
       

        latitudegrauorigem:   ;verifica se o grau esta correto
            XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLatitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLatitudeInvalida
                CMP        EAX,90
                JG        ErrLatitudeInvalida
                MOV        OgeoCoordLatGra,AL
                ADD        ESI,tamanho
                MOV        tamanho,SIZE buffer
           


        latitudeminutosorigem:
                  XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLatitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLatitudeInvalida
                CMP        EAX,59
                JG        ErrLatitudeInvalida
                 MOV        OgeoCoordLatMin,AL
				 ADD     ESI,tamanho
               MOV     tamanho,SIZE buffer
               
   
       
        latitudeorientacaoorigem:
            INC    ESI
            MOV    BL,BYTE PTR [ESI]
            MOV    OgeoCoordLatOri,BL
            AND    OgeoCoordLatOri,11011111b
            CMP    OgeoCoordLatOri,'N'
            JE     recebeLongitudeorigem
            CMP    OgeoCoordLatOri,'S'
            JE     recebeLongitudeorigem
            JMP    errLatitudeInvalida

       
        recebelongitudeorigem:  
                MOV        tamanho,tamanhopedelongitude
                   XCALL   ScreenWrite,pedelongitude,tamanho
                   LEA        ESI,buffer
                   MOV        tamanho,SIZE buffer
                   XCALL   KeyboardRead,buffer,tamanho
                  CMP        tamanho,2
                  JNG       recebeLongitudeorigem
           

        longitudedegrauorigem:   ;verifica se o grau esta correto
            XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLongitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLongitudeInvalida
                CMP        EAX,180
                JG        ErrLongitudeInvalida
                MOV        OgeoCoordLonGra,AL
                ADD        ESI,tamanho
                MOV        tamanho,SIZE buffer
           


        longitudeminutosorigem:
                  XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLongitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLongitudeInvalida
                CMP        EAX,59
                JG        ErrLongitudeInvalida
                MOV        OgeoCoordLonMin,AL
				ADD     ESI,tamanho
               MOV     tamanho,SIZE buffer
    
               
   
       
        longitudeorientacaoorigem:
            INC    ESI
            MOV    BL,BYTE PTR [ESI]
            MOV    OgeoCoordLonOri,BL
            AND    OgeoCoordLonOri,11011111b
            CMP    OgeoCoordLonOri,'W'
            JE    recebenomearquivo
            CMP    OgeoCoordLonOri,'E'
            JE    recebenomearquivo
            JMP   ErrLongitudeInvalida
		
			
		recebenomearquivo: 
		
			 MOV AL,20h
			MOV ECX,SIZE buffer
			LEA EDI,buffer
			REP STOSB
		
            MOV    tamanho,tamanhopedenomearquivo
            XCALL   ScreenWrite, pedenomearquivo, tamanho
            MOV    tamanho, SIZE buffer
            XCALL    KeyboardRead, buffer, tamanho
            CMP    tamanho, 2
            JLE    encerraprograma
            JMP    abriarquivo
           
		abriarquivo:
			MOV		handArquivo,00000h
			MOV     EDI,tamanho
			MOV     buffer[EDI-2],0
			XCALL   FileOpen,handArquivo,buffer
			CMP     handArquivo,0
			JL    	arquivosemsucesso
			JMP 	recebenomerelatorio       ;eh pra pular para a parte de ler as variaveis do arquivo e de gravar o arquivo com a solucao
			
			
			
			
			relatorioemtela:
			
					;EMBOLOU TUDO O_o
			
			XCALL	ScreenClear
			
				XCALL	GetDateAsc,cabDay,cabMonth,cabYear
				XCALL	GetTimeAsc,cabHours,cabMinutes,cabSeconds

				MOV	tamanho,tamCabecalho
				ID	cabecalho,tamanho
			
			
			MOV tamanho,Otamanhorelatorio
			XCALL ScreenWrite,Orelatorio,tamanho
			MOV	tamanho,30
			XCALL	ScreenWrite,OgeoCoordLocal,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLatGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
  
			XCALL     ScreenWrite,lol,tamanho
			 MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLatMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,OgeoCoordLatOri,tamanho
			
			
			MOV		tamanho,tamanhoespacogrande
			XCALL	ScreenWrite,espacogrande,tamanho
			
			CMP 	OgeocoordLonGra,100
			JA  	 maiorquecem
			JMP 	menorquecem
			
			menorquecem:
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
			XCALL     ScreenWrite,lol,tamanho
			JMP		gambiarralouca
			
			maiorquecem:
			MOV 	tamanho,tamUm
			XCALL   ScreenWrite,Um,tamanho
			SUB 	OgeocoordLonGra,100
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL   ScreenWrite,lol,tamanho
			ADD		OgeocoordLonGra,100
  
		gambiarralouca:
  
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,OgeoCoordLonOri,tamanho
			
			
			
			
			
			MOV		tamanho,tamanhopulalinha
			XCALL	ScreenWrite,pulalinha,tamanho
			
			MOV tamanho,Dtamanhorelatorio
			XCALL ScreenWrite,Drelatorio,tamanho
			
			;ACIMA EMBOLOU TUDO o-O
			
			lerarquivodeverdade:
			MOV  	 tamanhogeoCoord,36
			XCALL   FileRead,handArquivo,DgeoCoord,tamanhogeoCoord
			CMP  	 tamanhogeoCoord,0
			JZ   	 recebenovaorigem			
			JMP 	imprimerelatorio   ;  le do relatorio 36 , e depois imprime informaceos na tela puxando da estrutura
			
			
			
			;AKI VAI ESTAR SENDO O MODO ITERATIVO ONDE NAO FOI ENCONTRADO O ARQUIVO E O USUARIO DIGITARA A LOCALIDADE DESTINO
			arquivosemsucesso:
				MOV AL,20h
				MOV ECX,36
				LEA EDI,DgeoCoordLocal
				REP STOSB
				MOV 	ECX,tamanho
				SUB 	ECX,2
				LEA 	ESI,buffer
				LEA 	EDI,DgeoCoordLocal
				REP 	movsb
				JMP		recebelatitudedestino
			
			recebelatitudedestino:  
					MOV    tamanho,tamanhopedelatitude
                   XCALL   ScreenWrite,pedelatitude,tamanho
                   LEA        ESI,buffer
                   MOV        tamanho,SIZE buffer
                   XCALL   KeyboardRead,buffer,tamanho
				   CMP        tamanho,2
                   JLE        recebeLatitudedestino
       

        latitudegraudestino:   ;verifica se o grau esta correto
				XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLatitudeInvalidax
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLatitudeInvalidax
                CMP        EAX,90
                JG        ErrLatitudeInvalidax
                MOV        DgeoCoordLatGra,AL
                ADD        ESI,tamanho
                MOV        tamanho,SIZE buffer
           


        latitudeminutosdestino:
                XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLatitudeInvalidax
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLatitudeInvalidax
                CMP        EAX,59
                JG        ErrLatitudeInvalidax
                 MOV        DgeoCoordLatMin,AL
				 ADD     ESI,tamanho
               MOV     tamanho,SIZE buffer
               
   
       
        latitudeorientacaodestino:
            INC    ESI
            MOV    BL,BYTE PTR [ESI]
            MOV    DgeoCoordLatOri,BL
            AND    DgeoCoordLatOri,11011111b
            CMP    DgeoCoordLatOri,'N'
            JE     recebeLongitudedestino
            CMP    DgeoCoordLatOri,'S'
            JE     recebeLongitudedestino
            JMP    errLatitudeInvalidax

       
        recebelongitudedestino:  
                MOV        tamanho,tamanhopedelongitude
                   XCALL   ScreenWrite,pedelongitude,tamanho
                   LEA        ESI,buffer
                   MOV        tamanho,SIZE buffer
                   XCALL   KeyboardRead,buffer,tamanho
                  CMP        tamanho,2
                  JNG       recebeLongitudedestino
           

        longitudedegraudestino:   ;verifica se o grau esta correto
            XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLongitudeInvalidax
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLongitudeInvalidax
                CMP        EAX,180
                JG        ErrLongitudeInvalidax
                MOV        DgeoCoordLonGra,AL
                ADD        ESI,tamanho
                MOV        tamanho,SIZE buffer
           


        longitudeminutosdestino:
                  XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLongitudeInvalidax
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLongitudeInvalidax
                CMP        EAX,59
                JG        ErrLongitudeInvalidax
                MOV        DgeoCoordLonMin,AL
				ADD     ESI,tamanho
               MOV     tamanho,SIZE buffer
    
               
   
       
        longitudeorientacaodestino:
            INC    ESI
            MOV    BL,BYTE PTR [ESI]
            MOV    DgeoCoordLonOri,BL
            AND    DgeoCoordLonOri,11011111b
            CMP    DgeoCoordLonOri,'W'
            JZ    imprimeinfonatela
            CMP    DgeoCoordLonOri,'E'
            JZ    imprimeinfonatela
            JMP   ErrLongitudeInvalidax
				
		;AGORA APRENSENTA O RELATORIO, POIS AS DUAS ESTRUTURAS JA ESTAO GRAVADAS (CASO ONDE O USUARIO DIGITA TUDO)	
			
			
			;AKI SERA A LEITURA DO ARQUIVO CASO O USUARIO TENHA DIGITADO O NOME DE UM ARQUIVO E O ARQUIVO FOI ABERTO COM SUCESSO
			
			;aki tenho que saber como ler as variaveis do arquivo para estrutura
			
			recebenomerelatorio: 
					MOV    tamanho,tamanhopederelatorio
					XCALL   ScreenWrite, pederelatorio, tamanho
					MOV    tamanho, SIZE buffer
					XCALL    KeyboardRead, buffer, tamanho
					CMP    tamanho, 2
					JLE    relatorioemtela  ;EH PRA MANDAR IMPRIMIR NO MONITOR
					JMP 	criarelatorio ;AKIIII

			criarelatorio:
					MOV    EDI,tamanho
					MOV    buffer[EDI-2],0
					XCALL    FileCreate,handRelatorio,buffer
					CMP    handRelatorio,0
					JL	recebenomerelatorio
					JMP    gravarelatorio
					
			
			
			
			;AGORA APRENSENTA O RELATORIO, POIS AS DUAS ESTRUTURAS JA ESTAO GRAVADAS (CASO ONDE O USUARIO DIGITA O NOME DE UM ARQUIVO CORRETAMENTE)
		
		encerraprograma:
			ENDPROG
			
		ErrLatitudeInvalida:
            MOV    tamanho, tamanhoerrolatitude
            XCALL    ScreenWrite, errolatitude, tamanho
            JMP    recebelatitudeorigem
       
        ErrLongitudeInvalida:
            MOV    tamanho, tamanhoerrolongitude
            XCALL    ScreenWrite, errolongitude, tamanho
            JMP    recebelongitudeorigem
			
		ErrLatitudeInvalidax:
            MOV    tamanho, tamanhoerrolatitude
            XCALL    ScreenWrite, errolatitude, tamanho
            JMP    recebelatitudedestino
       
        ErrLongitudeInvalidax:
            MOV    tamanho, tamanhoerrolongitude
            XCALL    ScreenWrite, errolongitude, tamanho
            JMP    recebelongitudedestino	
		
		
		recebenovaorigem: 
			 MOV AL,20h
			MOV ECX,SIZE buffer
			LEA EDI,buffer
			REP STOSB
            MOV    tamanho,Dtamanhopedelocalidadeorigem
            XCALL   ScreenWrite, Dpedelocalidadeorigem, tamanho
            MOV    tamanho, SIZE buffer
            XCALL    KeyboardRead, buffer, tamanho
            CMP    tamanho, 2
            JLE    recebenomearquivo
			 MOV AL,20h
			MOV ECX,36
			LEA EDI,OgeoCoordLocal
			REP STOSB
            ;grava o local na estrutura
            MOV     ECX, tamanho
              SUB     ECX,2
              LEA     ESI,buffer
              LEA     EDI,OgeoCoordLocal
              REP      movsb
            JMP    recebeLatitudeorigem
		
		
		;ABAIXO  EH QYANDO PEGA DO ARQUIVO E IMPRIME NA TELA
		imprimerelatorio:   ;implementar para arquivo, quando digita um nome que existe no arquivo, abre lendo ele
			
			MOV	tamanho,30
			XCALL	ScreenWrite,DgeoCoordLocal,tamanho
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLatGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
  
			XCALL     ScreenWrite,lol,tamanho
			 MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLatMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,DgeoCoordLatOri,tamanho
			
			MOV		tamanho,tamanhoespacogrande
			XCALL	ScreenWrite,espacogrande,tamanho
			
			
			CMP 	DgeocoordLonGra,100
			JA  	 maiorquecemx
			JMP 	menorquecemx
			
			menorquecemx:
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
			XCALL     ScreenWrite,lol,tamanho
			JMP		gambiarraloucax
			
			maiorquecemx:
			MOV 	tamanho,tamUm
			XCALL   ScreenWrite,Um,tamanho
			SUB 	DgeocoordLonGra,100
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL   ScreenWrite,lol,tamanho
			ADD 	DgeocoordLonGra,100
  
		gambiarraloucax:
  
		
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,DgeoCoordLonOri,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
					
				
				
				;colocar distancia aki   (pi*(graus+minutos)/60)/180


MOV AX,00000h
MOV AL,OgeoCoordLatGra
MOV grauOrigemLat,AX
MOV AX,00000h
MOV AL,OgeoCoordLatMin
MOV minOrigemLat,AX
MOV AX,00000h
MOV AL,OgeoCoordLONGra
MOV grauOrigemLon,AX
MOV AX,00000h
MOV AL,OgeoCoordLonMin
MOV minOrigemLon,AX
MOV EAX,00000h
MOV AL,DgeoCoordLatGra
MOV grauDestLat,AX
MOV EAX,00000h
MOV AL,DgeoCoordLatMin
MOV minDestLat,AX
MOV EAX,00000h
MOV AL,DgeoCoordLONGra
MOV grauDestLon,AX
MOV EAX,00000h
MOV AL,DgeoCoordLonMin
MOV minDestLon,AX


MOV  BX,0000h
MOV  BL,OgeoCoordLatOri
MOV  oriOrigemLat,BL
MOV  BX,0000h
MOV  BL,OgeoCoordLonOri
MOV  oriOrigemLon,BL


MOV  BX,0000h
MOV  BL,DgeoCoordLatOri
MOV  oriDestLat,BL
MOV  BX,0000h
MOV  BL,DgeoCoordLonOri
MOV  oriDestLon,BL	
		
FILD grausLatPolo
FLDPI
FMULP
FILD centoOitenta
FDIVP
FSTP radianoA




FILD minOrigemLat
FILD sessenta
FDIVP
FILD grauOrigemLat
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,OgeoCoordLatOri
CMP AL,'S'
JZ trocasinalssss
JMP pegaradianossss

trocasinalssss:
FCHS

pegaradianossss:
FSTP radianoLatOri



FILD minOrigemLon
FILD sessenta
FDIVP
FILD grauOrigemLon
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,OgeoCoordLonOri
CMP AL,'W'
JZ trocasinals
JMP pegaradianos

trocasinals:
FCHS

pegaradianos:
FSTP radianoLonOri


FILD minDestLat
FILD sessenta
FDIVP
FILD grauDestLat
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,DgeoCoordLatOri
CMP AL,'S'
JZ trocasinalss
JMP pegaradianoss

trocasinalss:
FCHS

pegaradianoss:
FSTP radianoLatLoc



FILD minDestLon
FILD sessenta
FDIVP
FILD grauDestLon
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,DgeoCoordLonOri
CMP AL,'W'
JZ trocasinalsss
JMP pegaradianosss

trocasinalsss:
FCHS

pegaradianosss:
FSTP radianoLonLoc




FLD radianoA
FLD radianoLatOri
FSUBP
FSTP bRad

FLD radianoA
FLD radianoLatLoc
FSUBP
FSTP cRad


FLD radianoLonLoc
FLD radianoLonOri
FSUBP
FSTP ARad


FLD bRad
FCOS
FSTP bCos

FLD cRad
FCOS
FSTP cCos

FLD bRad
FSIN
FSTP bSin

FLD cRad
FSIN
FSTP cSin

FLD ARad
FCOS
FSTP CosA



FLD bCos
FLD cCos
FMULP
FSTP bcosvezesccos

FLD bSin
FLD Csin
FMULP
FSTP bsinvezescsin

FLD bsinvezescsin;acho que nao precisava pois ja esta em ST0, mas nao tenho certeza se FSTP tira de lá
FLD CosA
FMULP
FSTP bcvezescosa

FLD bcvezescosa ;denovoacho que nao precisava, mas nao custa nada colocar rsrs
FLD bcosvezesccos
FADDP
FSTP aCos ;resultado pronto


FLD aCos
FLD aCos
FMULP ST(1),ST(0)
FLD1
FSUBP
FABS
FSQRT
FSTP aSin ;resultado pronto


FLD aSin
FLD aCos
FPATAN
FILD Raio
FMULP
FSTP distancia

MOV lenght,12
XCALL FpuToAsc,precision,distancia,numAsc,lenght,notation,decimal
XCALL ScreenWrite,numAsc,lenght		
		
				
				;colocar distancia aki   (pi*(graus+minutos)/60)/180	
					
					
			MOV		tamanho,tamanhopulalinha
			XCALL	ScreenWrite,pulalinha,tamanho
			JMP lerarquivodeverdade 
			
			;ABAIXO EH QUANDO O USUARIO DIGITA TUDO
			
		imprimeinfonatela: 
			XCALL	ScreenClear
			
				XCALL	GetDateAsc,cabDay,cabMonth,cabYear
				XCALL	GetTimeAsc,cabHours,cabMinutes,cabSeconds

				MOV	tamanho,tamCabecalho
				ID	cabecalho,tamanho
			
			
			MOV tamanho,Otamanhorelatorio
			XCALL ScreenWrite,Orelatorio,tamanho
			MOV	tamanho,30
			XCALL	ScreenWrite,OgeoCoordLocal,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLatGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
  
			XCALL     ScreenWrite,lol,tamanho
			 MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLatMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,OgeoCoordLatOri,tamanho
			
			
			MOV		tamanho,tamanhoespacogrande
			XCALL	ScreenWrite,espacogrande,tamanho
			
			CMP 	OgeocoordLonGra,100
			JA  	 maiorquecemxx
			JMP 	menorquecemxx
			
			menorquecemxx:
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
			XCALL     ScreenWrite,lol,tamanho
			JMP		gambiarraloucaxx
			
			maiorquecemxx:
			MOV 	tamanho,tamUm
			XCALL   ScreenWrite,Um,tamanho
			SUB 	OgeocoordLonGra,100
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL   ScreenWrite,lol,tamanho
			ADD		OgeocoordLonGra,100
  
		gambiarraloucaxx:
  
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,OgeoCoordLonOri,tamanho
			
			
			
			
			
			MOV		tamanho,tamanhopulalinha
			XCALL	ScreenWrite,pulalinha,tamanho
			
			
			;agora o destino
			
			MOV tamanho,Dtamanhorelatorio
			XCALL ScreenWrite,Drelatorio,tamanho
			MOV	tamanho,30
			XCALL	ScreenWrite,DgeoCoordLocal,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLatGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
  
			XCALL     ScreenWrite,lol,tamanho
			 MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLatMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,DgeoCoordLatOri,tamanho
			
			MOV		tamanho,tamanhoespacogrande
			XCALL	ScreenWrite,espacogrande,tamanho
			
			
			CMP 	DgeocoordLonGra,100
			JA  	 maiorquecemxz
			JMP 	menorquecemxz
			
			menorquecemxz:
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
			XCALL     ScreenWrite,lol,tamanho
			JMP		gambiarraloucaxz
			
			maiorquecemxz:
			MOV 	tamanho,tamUm
			XCALL   ScreenWrite,Um,tamanho
			SUB 	DgeocoordLonGra,100
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL   ScreenWrite,lol,tamanho
			ADD 	DgeocoordLonGra,100
  
		gambiarraloucaxz:
  
		
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL     ScreenWrite,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL   ScreenWrite,DgeoCoordLonOri,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL   ScreenWrite,espaco,tamanho
			XCALL   ScreenWrite,espaco,tamanho
			XCALL   ScreenWrite,espaco,tamanho
					
					

				;colocar distancia aki   (pi*(graus+minutos)/60)/180




				



MOV AX,00000h
MOV AL,OgeoCoordLatGra
MOV grauOrigemLat,AX
MOV AX,00000h
MOV AL,OgeoCoordLatMin
MOV minOrigemLat,AX
MOV AX,00000h
MOV AL,OgeoCoordLONGra
MOV grauOrigemLon,AX
MOV AX,00000h
MOV AL,OgeoCoordLonMin
MOV minOrigemLon,AX
MOV EAX,00000h
MOV AL,DgeoCoordLatGra
MOV grauDestLat,AX
MOV EAX,00000h
MOV AL,DgeoCoordLatMin
MOV minDestLat,AX
MOV EAX,00000h
MOV AL,DgeoCoordLONGra
MOV grauDestLon,AX
MOV EAX,00000h
MOV AL,DgeoCoordLonMin
MOV minDestLon,AX


MOV  BX,0000h
MOV  BL,OgeoCoordLatOri
MOV  oriOrigemLat,BL
MOV  BX,0000h
MOV  BL,OgeoCoordLonOri
MOV  oriOrigemLon,BL


MOV  BX,0000h
MOV  BL,DgeoCoordLatOri
MOV  oriDestLat,BL
MOV  BX,0000h
MOV  BL,DgeoCoordLonOri
MOV  oriDestLon,BL

;TENHO QUE APRENDER A COLOCAR NA ESTRUTURA O VALOR INTEIRO DAS COISAS






radianodopolo:
FILD grausLatPolo
FLDPI
FMULP
FILD centoOitenta
FDIVP
FSTP radianoA

RadianosOritemEDestino:

transformagrauemradianoorigemlatitude:
FILD minOrigemLat
FILD sessenta
FDIVP
FILD grauOrigemLat
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,oriOrigemLat
CMP AL,'S'
JZ trocasinal
JMP pegaradiano

trocasinal:
FCHS

pegaradiano:
FSTP radianoLatOri


transformagrauemradianoorigemlongitude:
FILD minOrigemLon
FILD sessenta
FDIVP
FILD grauOrigemLon
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,oriOrigemLon
CMP AL,'W'
JZ trocasinalx
JMP pegaradianox

trocasinalx:
FCHS

pegaradianox:
FSTP radianoLonOri

transformagrauemradianodestinolatitude:
FILD minDestLat
FILD sessenta
FDIVP
FILD grauDestLat
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,oriDestLat
CMP AL,'S'
JZ trocasinalxx
JMP pegaradianoxx

trocasinalxx:
FCHS

pegaradianoxx:
FSTP radianoLatLoc


transformagrauemradianodestinolongitude:
FILD minDestLon
FILD sessenta
FDIVP
FILD grauDestLon
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,oriDestLon
CMP AL,'W'
JZ trocasinalxxx
JMP pegaradianoxxx

trocasinalxxx:
FCHS

pegaradianoxxx:
FSTP radianoLonLoc


CalculaSubtacoes:

FLD radianoA
FLD radianoLatOri
FSUBP
FSTP bRad

FLD radianoA
FLD radianoLatLoc
FSUBP
FSTP cRad


FLD radianoLonLoc
FLD radianoLonOri
FSUBP
FSTP ARad

achandofuncoestrigonometricas:
FLD bRad
FCOS
FSTP bCos

FLD cRad
FCOS
FSTP cCos

FLD bRad
FSIN
FSTP bSin

FLD cRad
FSIN
FSTP cSin

FLD ARad
FCOS
FSTP CosA

calculacosa:

FLD bCos
FLD cCos
FMULP
FSTP bcosvezesccos

FLD bSin
FLD Csin
FMULP
FSTP bsinvezescsin

FLD bsinvezescsin;acho que nao precisava pois ja esta em ST0, mas nao tenho certeza se FSTP tira de lá
FLD CosA
FMULP
FSTP bcvezescosa

FLD bcvezescosa ;denovoacho que nao precisava, mas nao custa nada colocar rsrs
FLD bcosvezesccos
FADDP
FSTP aCos ;resultado pronto

calculasenoa:
FLD aCos
FLD aCos
FMULP ST(1),ST(0)
FLD1
FSUBP
FABS
FSQRT
FSTP aSin ;resultado pronto

calculadistancia:
FLD aSin
FLD aCos
FPATAN
FILD Raio
FMULP
FSTP distancia

MOV lenght,12
XCALL FpuToAsc,precision,distancia,numAsc,lenght,notation,decimal
XCALL ScreenWrite,numAsc,lenght
			
				;colocar distancia aki   (pi*(graus+minutos)/60)/180	
					
					
			MOV		tamanho,tamanhopulalinha
			XCALL	ScreenWrite,pulalinha,tamanho
			
			;acabou
		
			JMP recebenovaorigem
			
			

			
			
		gravarelatorio:     ;implementar

		
		
				;EMBOLOU TUDO O_o
		

			MOV	tamanho,tamCabecalho
			XCALL  FileWrite,handRelatorio,cabecalho,tamanho
			; PQ NAO ESTA PULANDO LINHA?
			
			MOV tamanho,Otamanhorelatorio
			XCALL  FileWrite,handRelatorio,Orelatorio,tamanho
				MOV		tamanho,tamanhopulalinha
			XCALL	FileWrite,handRelatorio,pulalinha,tamanho
			MOV	tamanho,30
			XCALL  FileWrite,handRelatorio,OgeoCoordLocal,tamanho
		
			

			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLatGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
  
			XCALL  FileWrite,handRelatorio,lol,tamanho
			 MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLatMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL  FileWrite,handRelatorio,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL  FileWrite,handRelatorio,OgeoCoordLatOri,tamanho
			
			
			MOV		tamanho,tamanhoespacogrande
			XCALL  FileWrite,handRelatorio,espacogrande,tamanho
			
			CMP 	OgeocoordLonGra,100
			JA  	 Rmaiorquecem
			JMP 	Rmenorquecem
			
			Rmenorquecem:
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
			XCALL  FileWrite,handRelatorio,lol,tamanho
			JMP		Rgambiarralouca
			
			Rmaiorquecem:
			MOV 	tamanho,tamUm
			XCALL  FileWrite,handRelatorio,Um,tamanho
			SUB 	OgeocoordLonGra,100
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL  FileWrite,handRelatorio,lol,tamanho
			ADD		OgeocoordLonGra,100
  
		Rgambiarralouca:
  
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,OgeocoordLonMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL   FileWrite,handRelatorio,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL  FileWrite,handRelatorio,OgeoCoordLonOri,tamanho
			
			
			
			
			
			MOV		tamanho,tamanhopulalinha
			XCALL  FileWrite,handRelatorio,pulalinha,tamanho
			
			
			MOV		tamanho,tamanhopulalinha
			XCALL	FileWrite,handRelatorio,pulalinha,tamanho
			
			MOV tamanho,Dtamanhorelatorio
			XCALL  FileWrite,handRelatorio,Drelatorio,tamanho
			
			;ACIMA EMBOLOU TUDO o-O
			
			Rlerarquivodeverdade:
			MOV  	 tamanhogeoCoord,36
			XCALL   FileRead,handArquivo,DgeoCoord,tamanhogeoCoord
			MOV		tamanho,tamanhopulalinha
			XCALL	FileWrite,handRelatorio,pulalinha,tamanho
			CMP  	 tamanhogeoCoord,0
			JZ   	 recebenovaorigem			
			JMP 	Rimprimerelatorio   ;  le do relatorio 36 , e depois imprime informaceos na tela puxando da estrutura
		
			Rfechararquivo:
			 XCALL    FileClose, handRelatorio   ;ultimo comando do grava relatorio
			 JMP	  recebenovaorigem
			 
			 
			 
			 
			 Rimprimerelatorio:   ;implementar para arquivo, quando digita um nome que existe no arquivo, abre lendo ele
			
			MOV	tamanho,30
			XCALL  FileWrite,handRelatorio,DgeoCoordLocal,tamanho
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLatGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
  
			XCALL  FileWrite,handRelatorio,lol,tamanho
			 MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLatMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL  FileWrite,handRelatorio,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			
			MOV 	tamanho,1
			XCALL  FileWrite,handRelatorio,DgeoCoordLatOri,tamanho
			
			MOV		tamanho,tamanhoespacogrande
			XCALL  FileWrite,handRelatorio,espacogrande,tamanho
			
			
			CMP 	DgeocoordLonGra,100
			JA  	 Rmaiorquecemx
			JMP 	Rmenorquecemx
			
			Rmenorquecemx:
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX;
			XCALL  FileWrite,handRelatorio,lol,tamanho
			JMP		Rgambiarraloucax
			
			Rmaiorquecemx:
			MOV 	tamanho,tamUm
			XCALL   ScreenWrite,Um,tamanho
			SUB 	DgeocoordLonGra,100
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonGra
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL  FileWrite,handRelatorio,lol,tamanho
			ADD 	DgeocoordLonGra,100
  
		Rgambiarraloucax:
  
		
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			
			MOV 	tamanho,2
			MOV 	BL,10
			MOV 	AX,00000000
			MOV 	AL,DgeocoordLonMin
			DIV 	BL
			ADD 	AL,48 
			ADD 	AH,48 
			MOV 	lol,AX
			XCALL  FileWrite,handRelatorio,lol,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho

			
			
			MOV 	tamanho,1
			XCALL  FileWrite,handRelatorio,DgeoCoordLonOri,tamanho
			MOV     tamanho,tamanhoespaco
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			XCALL  FileWrite,handRelatorio,espaco,tamanho
			MOV		tamanho,tamanhopulalinha
			XCALL	FileWrite,handRelatorio,pulalinha,tamanho
			
		
				;colocar distancia aki   (pi*(graus+minutos)/60)/180

				
	
MOV AX,00000h
MOV AL,OgeoCoordLatGra
MOV grauOrigemLat,AX
MOV AX,00000h
MOV AL,OgeoCoordLatMin
MOV minOrigemLat,AX
MOV AX,00000h
MOV AL,OgeoCoordLONGra
MOV grauOrigemLon,AX
MOV AX,00000h
MOV AL,OgeoCoordLonMin
MOV minOrigemLon,AX
MOV EAX,00000h
MOV AL,DgeoCoordLatGra
MOV grauDestLat,AX
MOV EAX,00000h
MOV AL,DgeoCoordLatMin
MOV minDestLat,AX
MOV EAX,00000h
MOV AL,DgeoCoordLONGra
MOV grauDestLon,AX
MOV EAX,00000h
MOV AL,DgeoCoordLonMin
MOV minDestLon,AX


MOV  BX,0000h
MOV  BL,OgeoCoordLatOri
MOV  oriOrigemLat,BL
MOV  BX,0000h
MOV  BL,OgeoCoordLonOri
MOV  oriOrigemLon,BL


MOV  BX,0000h
MOV  BL,DgeoCoordLatOri
MOV  oriDestLat,BL
MOV  BX,0000h
MOV  BL,DgeoCoordLonOri
MOV  oriDestLon,BL			
				
				
				
			
FILD grausLatPolo
FLDPI
FMULP
FILD centoOitenta
FDIVP
FSTP radianoA




FILD minOrigemLat
FILD sessenta
FDIVP
FILD grauOrigemLat
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,OgeoCoordLatOri
CMP AL,'S'
JZ trocasina
JMP pegaradian

trocasina:
FCHS

pegaradian:
FSTP radianoLatOri



FILD minOrigemLon
FILD sessenta
FDIVP
FILD grauOrigemLon
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,OgeoCoordLonOri
CMP AL,'W'
JZ trocasinalv
JMP pegaradianov

trocasinalv:
FCHS

pegaradianov:
FSTP radianoLonOri


FILD minDestLat
FILD sessenta
FDIVP
FILD grauDestLat
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,DgeoCoordLatOri
CMP AL,'S'
JZ trocasinalvv
JMP pegaradianovv

trocasinalvv:
FCHS

pegaradianovv:
FSTP radianoLatLoc



FILD minDestLon
FILD sessenta
FDIVP
FILD grauDestLon
FADDP
FLDPI
FMULP
FILD centoOitenta
FDIVP

;verificando sinal

MOV AL,DgeoCoordLonOri
CMP AL,'W'
JZ trocasinalvvv
JMP pegaradianovvv

trocasinalvvv:
FCHS

pegaradianovvv:
FSTP radianoLonLoc




FLD radianoA
FLD radianoLatOri
FSUBP
FSTP bRad

FLD radianoA
FLD radianoLatLoc
FSUBP
FSTP cRad


FLD radianoLonLoc
FLD radianoLonOri
FSUBP
FSTP ARad


FLD bRad
FCOS
FSTP bCos

FLD cRad
FCOS
FSTP cCos

FLD bRad
FSIN
FSTP bSin

FLD cRad
FSIN
FSTP cSin

FLD ARad
FCOS
FSTP CosA



FLD bCos
FLD cCos
FMULP
FSTP bcosvezesccos

FLD bSin
FLD Csin
FMULP
FSTP bsinvezescsin

FLD bsinvezescsin;acho que nao precisava pois ja esta em ST0, mas nao tenho certeza se FSTP tira de lá
FLD CosA
FMULP
FSTP bcvezescosa

FLD bcvezescosa ;denovoacho que nao precisava, mas nao custa nada colocar rsrs
FLD bcosvezesccos
FADDP
FSTP aCos ;resultado pronto


FLD aCos
FLD aCos
FMULP ST(1),ST(0)
FLD1
FSUBP
FABS
FSQRT
FSTP aSin ;resultado pronto


FLD aSin
FLD aCos
FPATAN
FILD Raio
FMULP
FSTP distancia

MOV lenght,12
XCALL FpuToAsc,precision,distancia,numAsc,lenght,notation,decimal
XCALL FileWrite,handRelatorio,numAsc,lenght	
MOV		tamanho,tamanhopulalinha
XCALL	FileWrite,handRelatorio,pulalinha,tamanho				
				
				
				
				
				
				
				
				
				
				;colocar distancia aki   (pi*(graus+minutos)/60)/180	

			JMP Rlerarquivodeverdade
			 
			 
			 
			 
			 
	
		Rfechaarquivo:
		ENDPROG
END
