.MODEL SMALL
.386

.DATA
TEN DD 10.0
TEMP DW ?
RESULT DD ?
FIRST DD ?
SECOND DD ?
SIGN DB ?   ;a�Ƿ�Ϊ������0Ϊ��1Ϊ��
BUFFERX DD ?
BUFFERA1 DD ?
BUFFERA2 DD ?
BUFFERA3 DD ?
FPUSTATUS DW ?
ERRORMESSAGE  DB "Error: x<0!$"
CRLF  DB 0AH,0DH,"$"

.CODE
INPUT	PROC NEAR
	MOV	AH, 1
	INT	21H
      RET
INPUT	ENDP  ;���뵥���ַ�

OUTPUT PROC NEAR
	MOV	AH, 2
	MOV	DL, AL
	INT 21H
	RET
OUTPUT ENDP ;���AL��Ӧ���ַ�

.STARTUP
	FLDZ	          ;ջ��Ϊ0
	CALL INPUT      ;��ʼ����x
	.IF AL == '-'   ;����������ת
	JMP ERROR
	.ENDIF
	JMP NEXT

ERROR:
      LEA EDX,CRLF   ;����
	MOV AH,9
	INT 21H  
	LEA EDX, ERRORMESSAGE;���������Ϣ
	MOV AH, 09H
	INT 21H
	MOV AH, 4CH
	INT 21H    ;��ֹ

NEXT:
	.REPEAT        ;�������֣�����ջ��
	FMUL TEN       ;��λ��10
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP     ;���ϵ�λ
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'  ;0��9�����ֹͣ���룬���ȫ������Ĭ���Իس���ֹ�����Զ��ָ�x��a1

	CMP AL, '.'                ;����Ƿ���С����
	JNE NEXTAONE	
	FLD1	                  ;С�����֣�ѹ��Ȩ��
	.WHILE 1
	FDIV TEN                ;��ǰȨ�س���10
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'  ;0��9�����ֹͣ���룬Ĭ���Իس���ֹ�����Զ��ָ�x��a1
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP      ;����ѹ��ջ
	FMUL ST, ST(1) ;����Ȩ��
	FADD ST(2), ST ;������������
	FCOMP      ;����ʱ���ֵ���
	.ENDW

	FCOMP      ;��Ȩ�ص���
NEXTAONE:
	FSTP  BUFFERX
LOOPA11:
	MOV SIGN,0
	FLDZ	      ;��0��ջ
	CALL INPUT
	.IF AL == '-'
	MOV SIGN, 1	
	CALL INPUT
	.ENDIF

	.REPEAT
	FMUL TEN  
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP	
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'	

	CMP	AL, '.'
	JNE	LOOPA12
	FLD1
	.WHILE 1
	FDIV TEN
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP
	FMUL ST, ST(1)
	FADD ST(2), ST
	FCOMP
	.ENDW
	FCOMP

LOOPA12:
	.IF SIGN == 1
	FCHS   ;�ı����λ
	.ENDIF
	FSTP  BUFFERA1

LOOPA21:
	MOV SIGN,0
	FLDZ	
	CALL INPUT
	.IF AL == '-'
	MOV SIGN, 1	
	CALL INPUT
	.ENDIF
	.REPEAT
	FMUL TEN
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP	
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'	
	CMP	AL, '.'
	JNE	LOOPA22
	FLD1
	.WHILE 1
	FDIV TEN
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP
	FMUL ST, ST(1)
	FADD ST(2), ST
	FCOMP
	.ENDW
	FCOMP
LOOPA22:
	.IF SIGN == 1
	FCHS
	.ENDIF
	FSTP  BUFFERA2
LOOPA31:
	MOV SIGN,0
	FLDZ	
	CALL INPUT
	.IF AL == '-'
	MOV SIGN, 1	
	CALL INPUT
	.ENDIF
	.REPEAT
	FMUL TEN
	MOV AH,0
	SUB AL, 30H
	MOV TEMP, AX
	FIADD TEMP	
	CALL INPUT
	.UNTIL AL<'0' || AL>'9'	
	CMP	AL, '.'
	JNE	LOOPA32
	FLD1
	.WHILE 1
	FDIV TEN
	CALL INPUT
	.BREAK  .IF AL<'0' || AL>'9'
	MOV AH, 0
	SUB AL, 30H
	MOV TEMP, AX
	FILD TEMP
	FMUL ST, ST(1)
	FADD ST(2), ST
	FCOMP
	.ENDW
	FCOMP
LOOPA32:
	.IF SIGN == 1
	FCHS
	.ENDIF
	FSTP  BUFFERA3
;�������
	FLD BUFFERX
	FSQRT
	FLD  BUFFERA1
	FMUL
	FST RESULT

	FLD BUFFERA2
	FLD BUFFERX
	FYL2X
	FADD RESULT
	FST RESULT

	FLD BUFFERX
	FSIN
	FLD BUFFERA3
	FMUL
	FADD RESULT
	FSTP RESULT
;������ϣ������RESULT
	FSTCW	FPUSTATUS	
	OR	FPUSTATUS,0C00H  ;FPU�����ֵ�RC=11,��������ȡ��ʱ��0���루ֱ����ȥС�����֣�
	FLDCW	FPUSTATUS

	FLD	RESULT
	FTST
	FSTSW	AX
      AND   AX, 4500H  ;FPU״̬��C0��C2��C3
	CMP	AX, 0100H  ;����ǰ��Ӧ�ÿ���AND 0100H?
	JNZ	NOTMINUS
	MOV	AL, '-'   ;���Ϊ��
	CALL	OUTPUT
	FABS ;ȡ����ֵ

NOTMINUS:
	FLD	ST
	FRNDINT
	FIST	FIRST	;������������
	FSUBR      
	FABS
	FSTP	SECOND	;����С������
	MOV	EAX, FIRST
	MOV	EBX, 10
	MOV	CX, 0  ;��¼����λ��
	PUSH	BX
LOOPER1:
	MOV	EDX, 0
	DIV	EBX
	ADD	DL, 30H ;ȡ����push
	PUSH	DX
	INC	CX     ;ѭ��������Loop��
	CMP	EAX, 0
	JNZ	LOOPER1
PRINTER:
	POP	AX
	CALL	OUTPUT	;��ջ���������£������������
	LOOP	PRINTER
	MOV	AL, '.'
	CALL	OUTPUT	
	MOV	EAX, SECOND      ;����������

	FSTCW	FPUSTATUS
	XOR	FPUSTATUS, 0C00H     ;RC=00�����뵽���
	FLDCW	FPUSTATUS

	FLD	SECOND
	FXTRACT  ;�� ST(0) �ڵ���ֵ�ĳ� X*2��Y�Σ�Ȼ��� Y ��� ST(0)��ٰ� X ѹ���ջ��������� ST(0)Ϊ��Ч��X��ST(1) Ϊ�� 2 Ϊ�׵�ָ��Y
	FSTP	SECOND     ;X��ջ
	FABS             ;ָ��ȡ����ֵ
	FISTP	FIRST	     ;Y��ջ
	MOV	ECX, FIRST
	MOV	EAX, SECOND
	SAL	EAX, 9	;��Ŀ�Ĳ�����˳������9λ���ǵ�IEEE����λ�ͽ�λ,�������ƺ��߼����Ƶȼ�
	RCR	EAX, CL     ;EAX+CFѭ�����ƣ��ȼ��ڳ���ָ������ֵ�ε�2��ע����ѭ�����������CFλ��1�����ǲ�ȷ��CF������ô��1?
;���ڵõ��ĵȼ��ڷ�IEEE��������С��
LOOPER2:
	MUL	EBX  ;����С����ÿ�γ�10
	PUSH	EAX
	XCHG	EAX, EDX ;�����ĸ�λEDX��С����ǰ��һλ����AL�����
	ADD	AL, 30H
	CALL	OUTPUT
	POP	EAX        ;��С�����Ľضϲ�����ջ��������
	CMP	EAX, 0     
	JNZ	LOOPER2    ;С�������0��˵��������
	
QUIT:
	MOV AH, 4CH
	INT 21H 
END