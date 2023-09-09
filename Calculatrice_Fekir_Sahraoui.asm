include "emu8086.inc"
;PUTC    MACRO   char
        ;PUSH    AX
        ;MOV     AL, char
        ;MOV     AH, 0Eh
        ;INT     10h     
        ;POP     AX
;ENDM



DIS MACRO STR 
push ax 
push dx
 
MOV AH,09H
LEA DX,STR
INT 21H  

pop dx 
pop ax 
ENDM   
;-----------------------------------------------------
            ; print colored string
;-----------------------------------------------------
PrtC MACRO STR ; print contenue de dx
    ; avant : lea dx, message !  
    push ax
    push bx
    push dx 
    
    lea dx , STR 
    xor ax,ax ;same as, mov ax,0
    mov bl,Mycolor ;different number will produce different colours
    mov ah, 9
    int 10h   ;interrupt for colours
    int 21h
    
    ; retourneer couleur originale
    xor ax,ax 
    mov bl,07 ;different number will produce different colours
    mov ah, 9
    int 10h   ;interrupt for colours
    
    
    pop dx       
    pop bx
    pop ax
    
ENDM 
;-------------------------------------------------------
data segment 
   intro db '          Bienvenu dansle programme CALCULATRICE : $'
   realisePar db '  CE PROJET EST REALISE PAR FEKIR NABILA CHEHLA ET ABIR SAHRAOUI$'
   askMode db 'Choisisez une base (tapez: B|D|H)$'
   askOperateur db 'Choisisez un operateur (tapez: +|-|*|/)$'
   enterN1 db 'Entrez le premier nombre : $'
   enterN2 db 'Entrez le deuxieme nombre:$' 
   sommeMsg db  'La somme des deux nombres est : $'
   soustrMsg db 'La soustraction des deux nombres est  : $'
   multipMsg db 'La multiplication des deux nombres est: $' 
   divisMsg db 'La division des deux nombres est : $'     
   invaidMsg db 'ERROR:input invalide! reintroduire le nombre: $'
   MSGBIN DB 'Resultat binaire de l operation: $'
   separation db '----------------------------------------------------------------$'
   askContinue db 'Voulez vous continuer?(Si oui Tapez y)$'   
   msgH1 db  "Enter le premier nombre hexadecimal: $"
   msgH2 db  "Enter le seconde nombre hexadecimal: $"
   MresultHexa db "Le resultat hexadecimal de l'operation est: $" 
    
    
   nombre1 dw 0
   nombre2 dw 1
        
   TEMP DB 20 DUP('$')
   BinStr DB 20 DUP('$') 
   NO DW 10
   BconvertiD DW 0 ; result. 
   BinValInit DB "00000000", 0 
   resultOP DW 0
   Mycolor db 07
; 0 = black 1 = blue
; 2 = green 3 = cyan
; 4 = red 5 = magenta
; 6 = brown 7 = white
; 8 = gray 9 = br. blue
; 10 = lt.green 11 = lt.cyan
; 12 = lt.red 13 = lt.magenta
; 14 = yellow 15 = br. white

   sautLigne db 0Dh,0Ah,'$' 
   chooseOp db ?  
   chooseMod db ?
   
ends 

stack segment 
    dw dup 128 (?)
ends

code segment


assume cs:code,ds:data,ss:stack

starts :

mov ax,data 
mov ds,ax
mov ax,stack
mov ss,ax

        mov MyColor,14 ; yellow
        PrtC realisePar
        call MENU_CALCULATOR
                         

mov ah,4Ch
int 21h  
;------------------------------------------
         ;Calculatrice 
;------------------------------------------ 
MENU_CALCULATOR PROC 

DEBUT: 

    
   DIS SAUTLIGNE 
   mov MyColor,03 ; cyan 
   PrtC separation
   DIS SAUTLIGNE 
   PrtC intro
   DIS SAUTLIGNE
   PrtC separation
   DIS SAUTLIGNE     
    ;-------------------------
     ; choisir une base :
    ;------------------------- 

    call CHOOSE_MOD 
    
    DIS SAUTLIGNE  
    ;-------------------------
     ; choisir un operateur : 
    ;------------------------- 

    call CHOOSE_OP
    ;-------------------------
    ;Entrer num1 et num2 : 
    ;------------------------- 
             cmp chooseMod , 'B'
             JE modeBinEtiq 
             cmp chooseMod , 'D'
             JE modeDecEtiq
            ;sinon hex input : 
             call INPUT_HEX 
             JMP calculeEtiq
            
modeBinEtiq: call INPUT_BIN
             JMP calculeEtiq  
modeDecEtiq: call INPUT_Dec 
             JMP calculeEtiq 
            

calculeEtiq: cmp chooseOp,'+' 
             JE additionEtiq 
             cmp chooseOp,'-'
             JE soustractEtq
             cmp chooseOp,'*'
             JE multipliEtq
             JMP divisionEtq 
additionEtiq:call SOMME_DECIMALE
             JMP affichageEtq  
soustractEtq:call SOUSTRACTION_DECIMALE  
             JMP affichageEtq  
multipliEtq: call MULT_DECIMALE
             JMP affichageEtq
divisionEtq: call DIV_DECIMALE
affichageEtq: 
             cmp chooseMod, 'D'
             JE  FinMenu
             cmp chooseMod, 'B'
             JE afficheBin 
             ; sinon hexa affichage : 
             JMP etiqHexAff

   
 afficheBin:
            call TO_BINARY 
            JMP FinMenu 
             
etiqHexAff: 
            call AFFICHER_HEX 
    ; again ?   

FinMenu:    DIS sautLigne
            DIS askContinue
           ; scan char 
            mov ah, 01h     ; set the function code for reading input
            int 21h 
            cmp al,'y'  
            JE DEBUT           
          ; DIS sautLigne  
          ; DIS sautLigne    
    
            RET   
 
MENU_CALCULATOR ENDP
;------------------------------------------
   ; Input nombre1 et nombre2 Decimale
;------------------------------------------  
INPUT_Dec PROC
    push ax
    push dx 
    push cx  
        ; Lecture : ---------------------------
    DIS SAUTLIGNE 
    lea dx,enterN1
    mov ah,09h
    int 21h 
    
    
    PUTC ' ' 
    call SCAN_NUM 
    mov nombre1 , cx 
    
    DIS SAUTLIGNE 
    lea dx,enterN2
    mov ah,09h
    int 21h
    
    PUTC ' '
    call SCAN_NUM 
    mov nombre2 , cx
    
    pop cx
    pop dx
    pop ax  
    
    RET 
    
INPUT_Dec ENDP
;------------------------------------------
   ; Input nombre1 et nombre2 in Bin
;------------------------------------------ 
 INPUT_BIN  PROC
  PUSH ax
      
      DIS SautLigne
      DIS enterN1 
      PUTC ' ' 

      call CONVERT_BIN_TO_DEC 
      mov ax,BconvertiD
      mov nombre1,ax  
      
      DIS SautLigne
      DIS enterN2  
      PUTC ' ' 
      mov  BconvertiD, 0      
      call CONVERT_BIN_TO_DEC 
      mov ax,BconvertiD
      mov nombre2,ax
  POP ax
  RET  
      
 INPUT_BIN ENDP
;------------------------------------------
;Calcule division 2 OP Decimale->resultOP 
;------------------------------------------ 
DIV_DECIMALE PROC 
    push ax 
    push dx
    push bx 
     
    mov resultOP , 0
     ; Ecriture : --------------------------                         
                
    DIS SAUTLIGNE 
    mov MyColor , 14                
    PRTC divisMsg
 
    
    PUTC ' '
    cmp nombre1, 0
    JE DivParZero   
    
    MOV AX,nombre1
    MOV BX,nombre2 
    div Bl ; overflow    

         
    mov resultOP, ax
    ; afficher la somme : 
    call AFFICHER_NUM 
 
    
    
DivParZero :
    pop bx       
    pop dx 
    pop ax 
    
    RET
DIV_DECIMALE ENDP 
;------------------------------------------
;Calcule multiplication 2 OP Dec->resultOP 
;------------------------------------------ 
MULT_DECIMALE PROC 
    push ax 
    push dx 
    push bx 
     
    mov resultOP , 0 
     ; Ecriture : --------------------------                         
                
    DIS SAUTLIGNE  
    mov MyColor, 14             
    PRTC multipMsg
 
    
    PUTC ' '

    MOV AX,nombre2
    MOV BX,nombre1 
    MUL BX

        
    mov resultOP, ax
    ; afficher la somme : 
    call AFFICHER_NUM
   
    
    
    pop bx
    pop dx 
    pop ax 
    
    RET
MULT_DECIMALE ENDP 



;------------------------------------------
;Calcule somme 2 OP Decimale->resultOP 
;------------------------------------------ 

SOMME_DECIMALE PROC 
    push ax 
    push dx
 
    DIS SAUTLIGNE
    mov resultOP , 0
     ; Ecriture : --------------------------                         
                
    DIS SAUTLIGNE                 
    mov MyColor , 14                
    PRTC sommeMsg 
    
    PUTC ' ' 
    xor dx,dx
    add dx,nombre1 
    add dx,nombre2 
    ; afficher la somme : 
    mov ax,dx 
    mov resultOP, ax 
    call AFFICHER_NUM

    pop dx 
    pop ax 
    
    RET
SOMME_DECIMALE ENDP 

;------------------------------------------
;Calcule differance 2 OP Decimale->resultOP 
;------------------------------------------ 

SOUSTRACTION_DECIMALE PROC 
    push ax 
    push dx
    push bx 
     
    mov resultOP , 0
     ; Ecriture : --------------------------                         
                
    DIS SAUTLIGNE
    mov MyColor , 14                
    PRTC soustrMsg                  
 
    
    PUTC ' ' 
    xor dx,dx
    mov dx,nombre1
    cmp dx,nombre2
    JGE etiq1:
     ; afficher (-) 
    mov bl,dl
    mov dl, 2Dh      ; move the value of A into the DL register
    mov ah, 02h     ; set the function code for writing output
    int 21h         ; call the BIOS interrupt to write the character to standard output            
    mov dl,bl
           
    XCHG dx,nombre2
    

etiq1:SUB dx,nombre2 
    ; afficher la somme : 
    mov ax,dx  
    mov resultOP, ax 
    call AFFICHER_NUM

    
    pop bx
    pop dx 
    pop ax 
    
    RET
SOUSTRACTION_DECIMALE ENDP
;------------------------------------------
  ; Choose Mode :chooseMod<-Mode
;------------------------------------------ 

CHOOSE_MOD PROC 
    ; modifier contenue de ax et dx !  
    push ax 
    push dx
; lire char -----------------------
choixModeEnCours: 

    ; affiche message : 

DIS askMode 
   
mov ah, 01h     ; set the function code for reading input
int 21h         ; call the BIOS interrupt to read a character from standard input
mov chooseMod , al       ; move the character read from input (stored in the AL register) into the variable A

         DIS SAUTLIGNE

   


 mov dl,chooseMod 
                cmp dl , 'B'
                JZ  ModeModeChoisi 
                cmp dl, 'D'
                JZ  ModeModeChoisi
                cmp dl, 'H'
                JZ  ModeModeChoisi   

                
                JMP choixModeEnCours
     
ModeModeChoisi:
    pop dx 
    pop ax 
    
    RET
CHOOSE_MOD ENDP

;------------------------------------------
   ; Choose operator :chooseOp<-operateur
;------------------------------------------
CHOOSE_OP PROC 
    ; modifier contenue de ax et dx !  
    push ax 
    push dx
 ; lire char ----------------------- 

choixOpEnCours:

           
    DIS askOperateur
     
         PUTC ' ' 
         mov ah, 01h     ; set the function code for reading input
         int 21h         ; call the BIOS interrupt to read a character from standard input
         mov chooseOp , al       ; move the character read from input (stored in the AL register) into the variable A
         DIS SAUTLIGNE 


             mov dl,chooseOp 
             
                cmp dl , '/'
                JZ  ModeOpChoisi 
                cmp dl, '-'
                JZ  ModeOpChoisi
                cmp dl, '+' 
                JZ  ModeOpChoisi 
                cmp dl, '*'
                JZ  ModeOpChoisi 
                JMP choixOpEnCours
                
     
ModeOpChoisi: 
                pop dx 
                pop ax 
    
                RET
CHOOSE_OP ENDP

;------------------------------------------
            ; SCAN NUM : 
;------------------------------------------


      SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 13  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
ten             DW      10      ; used as multiplier.
SCAN_NUM        ENDP
  
;-----------------------------------------------
         ;fonction afficher num: 
;-----------------------------------------------


AFFICHER_NUM PROC   ; attention faut des saut de ligne avant ! 
    ; afficher contenue de ax
  
    push cx 
    push dx
    push ax 
    push bx 
    
    mov cx , 0  
    mov dx , 0
    mov bx,10
     
    
    empiler:
    div bx;    ax=ax/10    
    add dx,48
    push dx 
    mov dx,0
    inc cx
    cmp ax,0
    jne empiler
    
    
    depiler:
    pop dx 
    mov ah,02h ; service affichage des char 
    int 21h    ; it pour afficher 
    loop depiler
            
            ; print d suffix 
            PUTC 'd'
            
    pop bx 
    pop ax
    pop dx 
    pop cx  
    
    RET
AFFICHER_NUM ENDP  

;------------------------------------------------
          ; Convert Bin -> Dec 
;------------------------------------------------
CONVERT_BIN_TO_DEC  PROC   
push ax 
push cx 
push bx
push dx 
push di
push si



Getstring: 


mov BconvertiD , 0 ; store reslt here 

MOV DX, 9 ; buffer size (1+ for zero terminator).
LEA DI, BinValInit
CALL GET_STRING  


     mov dl,9h ; afficher espace
     mov ah,2  ; num service affichage char
     int 21h 

; Check that we really got 8 chars,
; this check is optional:
MOV CX, 8
MOV SI, 0
check_s:
; Terminated before
; reaching 9th char?
CMP BinValInit[SI], 0
JNE ok1 

JMP error_not_valid
ok1:
; Wrong digit? Not 1/0?
CMP BinValInit[SI], 31h
JNA ok2
JMP error_not_valid
ok2:
INC SI
LOOP check_s


; Start the conversion from
; string to value in SUM variable.

MOV BL, 1 ; multiplier.
MOV SI, 7 ; index.
MOV CX, 8 ; counter for a loop.

nxt_digit:

MOV AL, BinValInit[SI] ; get digit.
SUB AL, 30h
MUL BL ; no change to AX.
ADD BconvertiD, AX
SHL BL, 1
DEC SI ; go to previous digit.
LOOP nxt_digit

; Done. Converted number is in SUM.



; Print the result:
MOV AX, BconvertiD
CALL PRINT_NUM_UNS
JMP stp_program


error_not_valid:
;PRINTN " " 

;PRINT "ERROR: NOT VALID INPUT!" 
DIS SautLigne 
mov MyColor,4
PRTC invaidMsg
pop SI 
pop DI

push DI
push SI  
JMP Getstring


stp_program:
; fin 

pop si 
pop di
pop dx
pop bx
pop cx 
pop ax


  
RET
CONVERT_BIN_TO_DEC ENDP	
;---------------------------------------------------
;Convert number in resultOP to bin->result in BinStr  
;---------------------------------------------------

TO_BINARY PROC
    
    PUSH AX
    PUSH BX  
    PUSH CX 
    PUSH SI 
    PUSH DI 
 
         LEA SI,TEMP
         MOV AX,resultOP
         MOV BH,00
         MOV BL,2
      L1:DIV BL
         ADD AH,'0'
         MOV BYTE PTR[SI],AH
         MOV AH,00
         INC SI
         INC BH        
         CMP AL,00
         JNE L1

         MOV CL,BH
         LEA SI,TEMP
         LEA DI,BinStr
         MOV CH,00
         ADD SI,CX
         DEC SI

      L2:MOV AH,BYTE PTR[SI]
         MOV BYTE PTR[DI],AH
         DEC SI
         INC DI
         LOOP L2

         DIS sautLigne
         MOV MyColor,14
         PrtC MSGBIN 
         DIS sautLigne
         PRTC BinStr 
         PUTC 'b'

         
         POP DI
         POP SI 
         POP CX
         POP BX 
         POP AX 
RET
TO_BINARY ENDP

;-------------------------------------------------
           ; Hexadecimal input in BX  
;-------------------------------------------------




INPUTNUM1_HEX PROC ; resultat dans BX 

Deb:   
    push dx
    push cx 
  ;  push bx
    push ax
    
         
    MOV BX ,0
    MOV CL,4
    ; enter hex num 
    MOV AH , 1 
    
    FOR1: 
        INT 21h ; read a char 
        CMP AL,0Dh ; si ok 
        JE END_FOR
        
        CMP AL , 41h ; si lettre enter 
        JGE LETTER
        
        ; digit 
        CMP AL , 30h
        JL Re
        CMP AL , 39h 
        JG Re
        SUB AL,48 ; donc chiffre
        JMP SHIFT
        
        LETTER:
            CMP AL,46h
            JG Re
            SUB AL , 37h 
            
            
        SHIFT: 
        
            SHL BX, CL 
            OR BL, AL   ; le contenu est dans BL 
        JMP FOR1
        
        Re: 
            DIS SautLigne 
            mov MyColor,4
            PRTC invaidMsg
            pop ax
            pop cx
            pop dx
            JMP Deb   
        
        
    END_FOR:    
    
    
    pop ax
  ;  pop bx
    pop cx              
    pop dx 
    
    RET 

    
INPUTNUM1_HEX ENDP 





;-------------------------------------------------
    ; Hexadecimal input in number1 and number2 
;-------------------------------------------------



INPUT_HEX PROC 
    
    push dx
    push cx 
    push bx
    push ax   
      
      DIS SautLigne
      DIS msgH1
      call INPUTNUM1_HEX
      mov nombre1 , BX 
      DIS SautLigne
      DIS msgH2
      call INPUTNUM1_HEX
      mov nombre2 , BX 
      DIS SautLigne
    
    pop ax
    pop bx
    pop cx              
    pop dx
    
    
    RET 
    
INPUT_HEX ENDP 



;----------------------------------------------------
            ;Afficher en hexadecimale    
;----------------------------------------------------

AFFICHER_HEX PROC  ; affiche contenu resultOP en hexa
   ; PRINTN 
    
    
    push dx
    push cx 
    push bx
    push ax
    
     DIS SautLigne 
     mov MyColor,14
     PRTC MresultHexa
     mov BX , resultOP 
    
    ;XOR CH , CH
    MOV CX , 4
    MOV AH , 2
    
    FOR2:
        MOV DL,BH
        SHR DL,4
        SHL BX,4
        
        CMP DL,10
        JGE LETTER2
        
      ;   DIGIT 
        
        ADD DL,48
        INT 21h
        JMP END_OF_LOOP2
        
        LETTER2:
        ADD DL,55
        INT 21h
        
        END_OF_LOOP2:
   LOOP FOR2 
            ; print suffix : 
                PUTC 'h'    
    DIS SautLigne
    
    pop ax
    pop bx
    pop cx              
    pop dx     
    
    RET 
AFFICHER_HEX ENDP

;---------------------------------------------
; Definition of procedures
; from Emu8086.inc: 
;---------------------------------------------

DEFINE_GET_STRING
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM_UNS