;	Universidade Federal da Bahia
;	Departamento de Ciência da Computação
;
;	Disciplina:	MAT149 Linguagens de montagem
;	Professor:	Luiz Eduardo
;
;	Arquivos
;
;	25 de setembro de 2003
;
;	tasm FileDisk /l

		INCLUDE	XCall.mac

		.MODEL	SMALL
		DOSSEG
		.386

		.DATA


msgOld		DB	'Arquivo ja existe. Extender (E), ignorar (I) ou cancelar (C): '
tamMsgOld	EQU	$-msgOld

buffer		DB	16 DUP (' ')

handle		DW	?

tabErro		DB	01,'Funcao invalida                         '
		DB	02,'Arquivo nao encontrado                  '
		DB	03,'Caminho nao existe                      '
		DB	04,'Muitos arquivos abertos                 '
		DB	05,'Acesso negado                           '
		DB	06,'Handle invalido                         '
		DB	07,'Bloco de controle (memoria) destruido   '
		DB	08,'Memoria insuficiente                    '
		DB	09,'Endereco invalido de bloco de controle  '
		DB	10,'Ambiente nao suportado                  '
		DB	11,'Formato invalido                        '
		DB	12,'Codigo de acesso invalido               '
		DB	13,'Dados invalidos                         '
		DB	15,'Especificacao invalida de drive         '
		DB	16,'Tentativa de remover diretorio          '
		DB	17,'Nao e o mesmo dispositivo               '
		DB	18,'Nao mais arquivos                       '
		DB	19,'Disco protegido contra gravacao         '
		DB	20,'Unidade desconhecida                    '
		DB	21,'Dispositivo nao esta pronto             '
		DB	22,'Comando desconhecido                    '
		DB	23,'Erro de CRC                             '
		DB	24,'Tamanho invalido de estrutura           '
		DB	25,'Erro de seek no disco                   '
		DB	26,'Tipo de midia desconhecido              '
		DB	27,'Setor do disco nao encontrado           '
		DB	28,'Impressora sem papel                    '
		DB	29,'Falha de gravacao                       '
		DB	30,'Falha de leitura                        '
		DB	31,'Falha geral do sistema                  '
		DB	32,'Violacao de compartilhamento            '
		DB	33,'Violacao de seguranca                   '
		DB	34,'Alteracao invalida de disco             '
		DB	35,'FCB indisponivel                        '
		DB	36,'Buffer compartilhado esgotado           '
		DB	51,'Arquivo nao formatado como randomico    '
		DB	52,'Espaco esgotado em arquivo randomico    '
		DB	99,'Erro nao codificado                     '

errCode		DW	?


		.CODE
		PUBLIC	FileCreate,FileOpen,FileRead,FileWrite,FileClose,FileError
		EXTRN	ScreenWrite:FAR


FileCreate	PROC	FAR

;	+--------------------------------------------------------------+
;	| Chamada:	XCALL	FileCreate,handler,fileName            |
;	+--------------------------------------------------------------+

		MOV	EDI,DWORD PTR [EBX+4]
		MOV	EDX,DWORD PTR [EBX+8]

		MOV	AH,3Dh
		MOV	AL,01000010b
		MOV	ECX,0
		INT	21h
		JC	NewFile

		MOV	handle,AX
		PUSH	EDI
		PUSH	EDX

OldFile:
		LEA	EDX,msgOld
		MOV	ECX,tamMsgOld
		MOV	EAX,0
		MOV	AH,40h
		MOV	EBX,1
		INT	21h

		LEA	EDX,buffer
		MOV	ECX,6
		MOV	EAX,0
		MOV	AH,3Fh
		MOV	EBX,0
		INT	21h

		CMP	EAX,2
		JNG	OldFile
		CMP	buffer[0],'E'
		JE	Extend
		CMP	buffer[0],'e'
		JE	Extend
		CMP	buffer[0],'I'
		JE	Ignore
		CMP	buffer[0],'i'
		JE	Ignore
		CMP	buffer[0],'C'
		JE	Cancel
		CMP	buffer[0],'c'
		JE	Cancel
		JMP	OldFile

Extend:
		POP	EDX
		POP	EDI

		MOV	AH,42h
		MOV	AL,02h
		MOV	BX,handle
		MOV	ECX,0
		MOV	EDX,0
		INT	21h
		JC	ErrorDescription

		MOV	AX,handle
		MOV	WORD PTR [EDI],AX
		RET

Ignore:
		POP	EDX
		POP	EDI

		MOV	AH,3Eh
		MOV	BX,handle
		INT	21h
		JC	ErrorDescription

NewFile:
		MOV	AH,3Ch
		MOV	CX,00100000b
		INT	21h
		JC	ErrorDescription

		MOV	WORD PTR [EDI],AX
		RET

Cancel:
		POP	EDX
		POP	EDI

		MOV	WORD PTR [EDI],-1
		RET

		ENDP


FileOpen	PROC	FAR

;	+--------------------------------------------------------------+
;	| Chamada:	XCALL	FileOpen,handle,fileName	       |
;	+--------------------------------------------------------------+

		MOV	EDI,DWORD PTR [EBX+4]
		MOV	EDX,DWORD PTR [EBX+8]
		MOV	AH,3Dh
		MOV	AL,00000010b
		MOV	ECX,0
		INT	21h
		JC	ErrorDescription
		MOV	WORD PTR [EDI],AX
		RET

		ENDP


FileRead	PROC	FAR

;	+--------------------------------------------------------------+
;	| Chamada:	XCALL	FileRead,handle,buffer,bufferLength    |
;	+--------------------------------------------------------------+

		MOV	EDX,DWORD PTR [EBX+8]
		MOV	ESI,DWORD PTR [EBX+12]
		MOV	ECX,DWORD PTR [ESI]
		MOV	EDI,ESI
		MOV	ESI,DWORD PTR [EBX+4]
		MOV	BX,WORD PTR [ESI]
		MOV	EAX,0
		MOV	AH,3Fh
		INT	21h
		JC	ErrorDescription
		MOV	DWORD PTR [EDI],EAX
		RET

		ENDP


FileWrite	PROC	FAR

;	+--------------------------------------------------------------+
;	| Chamada:	XCALL	FileWrite,handle,buffer,bufferLength   |
;	+--------------------------------------------------------------+

		MOV	EDX,DWORD PTR [EBX+8]
		MOV	ESI,DWORD PTR [EBX+12]
		MOV	ECX,DWORD PTR [ESI]
		MOV	EDI,ESI
		MOV	ESI,DWORD PTR [EBX+4]
		MOV	BX,WORD PTR [ESI]
		MOV	AH,40h
		INT	21h
		JC	ErrorDescription
		RET

		ENDP


FileClose	PROC	FAR

;	+--------------------------------------------------------------+
;	| Chamada:	XCALL	FileClose,handle		       |
;	+--------------------------------------------------------------+

		MOV	ESI,DWORD PTR [EBX+4]
		MOV	BX,WORD PTR [ESI]
		MOV	AH,3Eh
		INT	21h
		JC	ErrorDescription
		RET

		ENDP


FileError	PROC	FAR

;	+--------------------------------------------------------------+
;	| Chamada:	XCALL	FileError,errCode		       |
;	+--------------------------------------------------------------+

		MOV	ESI,DWORD PTR [EBX+4]
		MOV	AX,WORD PTR [ESI]
		MOV	ECX,38
		MOV	ESI,0

ErrorSearch:
		CMP	tabErro[ESI],AL
		JE	ErrorText
		ADD	ESI,41
		LOOP	ErrorSearch

ErrorText:
		LEA	EDX,tabErro[ESI+1]
		MOV	ECX,40
		MOV	EAX,0
		MOV	AH,40h
		MOV	EBX,1
		INT	21h

		RET


ErrorDescription:
		MOV	DWORD PTR [EDI],-1
		MOV	errCode,AX
;		XCALL	FileError,errCode

		RET

		ENDP

		END
