;    Universidade Federal da Bahia
;    Departamento de Ciência da Computação
;
;    Disciplina:    MAT149 Linguagens de montagem
;    Professor:    Luiz Eduardo
;
;    Grava coordenadas geográficas
;
;    4 de abril de 2012
;
;    tasm  GeoGrav /z
;    tlink GeoGrav+DateTime+ScreKeyb+IntNum+FileDisk /3

        INCLUDE    XCall.mac
        INCLUDE    Macros.mac

        .MODEL SMALL
        .386
        DOSSEG
        .STACK    256
        .DATA

        DD    12 DUP (?)

cabecalho    DB    'Universidade Federal da Bahia'
        DB    30 DUP (' ')
cabDay        DB    2  DUP ('0')
        DB    '/'
cabMonth    DB    2  DUP ('0')
        DB    '/'
cabYear        DB    4  DUP ('0')
        DB    '  '
cabHours    DB    2  DUP ('0')
        DB    ':'
cabMinutes    DB    2  DUP ('0')
        DB    ':'
cabSeconds    DB    2  DUP ('0')
        DB    10,13
        DB    'Departamento de Ciencia da Computacao',10,13
        DB    'MATA49 Programacao de software basico',10,10,13
        DB    'Gravacao de coordenadas geograficas',10,13
tamCabecalho    EQU    $-cabecalho


geoCoord EQU $
geoCoordLocal             DB     30 DUP (?) ; nome da localidade
geoCoordLatGra            DB     ? ; latitude graus (0-90)
geoCoordLatMin            DB     ? ; latitude minutos (0-59)
geoCoordLatOri            DB     ? ; latitude orientação ('N'|'S')
geoCoordLonGra            DB     ? ; longitude graus (0-180)
geoCoordLonMin            DB     ? ; longitude minutos (0-59)
geoCoordLonOri            DB     ? ; longitude orientação ('E'|'W')
tamanhogeoCoord            DD    36




pedearquivocoordenadas            DB    13,10
                                DB    'Arquivo de coordenadas ou <ENTER> para abandonar      :  '
tamanhopedearquivocoordenadas   EQU    $-pedearquivocoordenadas

pedelocalidade                DB    10,13   
                            DB    'Nome da localidade                                    :  '
tamanhopedelocalidade        EQU    $-pedelocalidade

pedelatitude            DB    'Latitude  <graus, minutos, orientacao>                :  '
tamanhopedelatitude        EQU    $-pedelatitude

pedelongitude            DB    'Longitude <graus, minutos, orientacao>                :  '
tamanhopedelongitude        EQU    $-pedelongitude

errolatitude            DB    'Latitude invalida - repita a operacao',10,13
tamanhoerrolatitude        EQU    $-errolatitude


errolongitude            DB    'Longitude invalida - repita a operacao',10,13
tamanhoerrolongitude        EQU    $-errolongitude




tamanho                DD    ?
buffer                DB     30 DUP(' ')
handArquivo            DD   ?
inteiro                DD    ?
rC                    DD    ?













        .CODE   
        EXTRN    AscToInt:FAR,IntToAsc:FAR
        EXTRN    DateToBin:FAR,TimeToBin:FAR
        EXTRN    GetDateAsc:FAR,GetTimeAsc:FAR
        EXTRN    ScreenClear:FAR,ScreenWrite:FAR,KeyboardRead:FAR
        EXTRN    FileCreate:FAR,FileWrite:FAR,FileClose:FAR

        INIPROG

        XCALL    GetDateAsc,cabDay,cabMonth,cabYear
        XCALL    GetTimeAsc,cabHours,cabMinutes,cabSeconds

        MOV    tamanho,tamCabecalho
        ID    cabecalho,tamanho

        CLD





        recebearquivocoordenadas:
            MOV    tamanho,tamanhopedearquivocoordenadas
            XCALL    ScreenWrite, pedearquivocoordenadas, tamanho
            MOV    tamanho, SIZE buffer
            XCALL    KeyboardRead, buffer, tamanho
            CMP    tamanho,2
            JG    criaarquivocoordenadas
            ENDPROG

        criaarquivocoordenadas:
            MOV    EDI,tamanho
            MOV    buffer[EDI-2],0
            XCALL    FileCreate,handArquivo,buffer
            CMP    handArquivo,0
            JL    recebearquivocoordenadas
           
       
        recebelocalidade: 
		 MOV AL,20h
  		 MOV ECX,36
  		 LEA EDI,geoCoordLocal
  		 REP STOSB
            MOV    tamanho,tamanhopedelocalidade
            XCALL   ScreenWrite, pedelocalidade, tamanho
            MOV    tamanho, SIZE buffer
            XCALL    KeyboardRead, buffer, tamanho
            CMP    tamanho, 2
            JLE    fechaarquivo
            ;grava o local na estrutura
            MOV     ECX, tamanho
              SUB     ECX,2
              LEA     ESI,buffer
              LEA     EDI,geoCoordLocal
              REP      movsb
            JMP    recebeLatitude


        recebelatitude:  
            MOV    tamanho,tamanhopedelatitude
                   XCALL   ScreenWrite,pedelatitude,tamanho
                   LEA        ESI,buffer
                   MOV        tamanho,SIZE buffer
                   XCALL   KeyboardRead,buffer,tamanho
                  CMP        tamanho,2
                   JLE        recebeLatitude
       

        latitudegrau:   ;verifica se o grau esta correto
            XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLatitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLatitudeInvalida
                CMP        EAX,90
                JG        ErrLatitudeInvalida
                MOV        geoCoordLatGra,AL
                ADD        ESI,tamanho ;ponto chave aqui
                MOV        tamanho,SIZE buffer ;ponto chave aqui
           


        latitudeminutos:
                  XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLatitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLatitudeInvalida
                CMP        EAX,59
                JG        ErrLatitudeInvalida
                 MOV        geoCoordLatMin,AL
				 ADD     ESI,tamanho
               MOV     tamanho,SIZE buffer
               
   
       
        latitudeorientacao:
            INC    ESI
            MOV    BL,BYTE PTR [ESI]
            MOV    geoCoordLatOri,BL
            AND    geoCoordLatOri,11011111b
            CMP    geoCoordLatOri,'N'
            JE     recebeLongitude
            CMP    geoCoordLatOri,'S'
            JE     recebeLongitude
            JMP    errLatitudeInvalida

       
        recebelongitude:  
                MOV        tamanho,tamanhopedelongitude
                   XCALL   ScreenWrite,pedelongitude,tamanho
                   LEA        ESI,buffer
                   MOV        tamanho,SIZE buffer
                   XCALL   KeyboardRead,buffer,tamanho
                  CMP        tamanho,2
                  JNG       recebeLongitude
           

        longitudedegrau:   ;verifica se o grau esta correto
            XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLongitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLongitudeInvalida
                CMP        EAX,180
                JG        ErrLongitudeInvalida
                MOV        geoCoordLonGra,AL
                ADD        ESI,tamanho
                MOV        tamanho,SIZE buffer
           


        longitudeminutos:
                  XCALL   AscToInt,[ESI],tamanho,inteiro,rC
                CMP        rC,0
                JNE        ErrLongitudeInvalida
                MOV        EAX,inteiro
                CMP        EAX,0
                JL        ErrLongitudeInvalida
                CMP        EAX,59
                JG        ErrLongitudeInvalida
                MOV        geoCoordLonMin,AL
				ADD     ESI,tamanho
               MOV     tamanho,SIZE buffer
    
               
   
       
        longitudeorientacao:
            INC    ESI
            MOV    BL,BYTE PTR [ESI]
            MOV    geoCoordLonOri,BL
            AND    geoCoordLonOri,11011111b
            CMP    geoCoordLonOri,'W'
            JE    gravaarquivo
            CMP    geoCoordLonOri,'E'
            JE    gravaarquivo
            JMP   ErrLongitudeInvalida
           
        gravaarquivo:
            XCALL    FileWrite,handarquivo,geoCoord,tamanhogeoCoord 
            JMP      recebelocalidade



        ErrLatitudeInvalida:
            MOV    tamanho, tamanhoerrolatitude
            XCALL    ScreenWrite, errolatitude, tamanho
            JMP    recebelatitude
       
        ErrLongitudeInvalida:
            MOV    tamanho, tamanhoerrolongitude
            XCALL    ScreenWrite, errolongitude, tamanho
            JMP    recebelongitude
           


        fechaarquivo:
            XCALL    FileClose, handArquivo
            ENDPROG


ENDPROG
END