<<<<<<< HEAD
[bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

min      equ 2
max      equ 5
zero     equ 0
trzyplus equ __?float32?__(3.5)
czteryplus equ __?float32?__(4.5)

         mov esi, 1  ; esi = 1

         finit       ; fpu init

ocena:
         push esi
         
;        esp -> [esi][ret]

         call getaddr  ; push on the stack the run-time address of format and jump to getaddr
format:
         db "%d ocena = ", 0
getaddr:

;        esp -> [format][esi][ret]

         call [ebx+3*4]  ; printf("%d ocena = ", esi);

;        esp -> [ocena][esi][ret] ; zmienna ocena, adres format nie jest juz potrzebny

         push esp

;        esp -> [addr_ocena][ocena][esi][ret]

         call getaddr2
format2:
         dd "%lf", 0
getaddr2:

;        esp -> [format2][addr_ocena][ocena][esi][ret]

         call [ebx+4*4]     ; scanf("%d", &a);
         add esp, 2*4       ; esp = esp + 8

;        esp -> [ocena][esi][ret]

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point

;        st = [st0] = [ocena]

         push zero          ; check to leave the program

;        esp -> [0][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ocena][esi][ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         je end             ; jump if equal ; ZF = 1
         
         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0] = [ocena]

         push min           ; minimal note
         
;        esp -> [1][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ocena][esi][ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         jb ocena           ; jump if below              ; jump if CF = 1

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point

;        st = [st0] = [ocena]

         push max           ; maximum note

;        esp -> [6][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected

;        st = [ ]

         add esp, 4         ; esp = esp + 4

;        esp -> [ocena][esi][ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         ja ocena           ; jump if above  ; jump if CF = 0 and ZF = 0

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point

;        st = [st0] = [ocena]

;        now we know the number is in <1, 6> range

;        checking if correct note

         fld st0
         
;        st = [st0, st1] = [ocena, ocena]
         
         frndint
         
;        st = [st0, st1] = [*(int*)ocena, ocena]

         fsubp st1           ; st1 = st1-st0
         
;        st = [st0] = [ocena - *(int*)ocena]

         push zero

;        esp -> [zero][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected

;        st = [ ]

         add esp, 4
         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0]  = [ocena]
         
         je load            ; jump if equal ; ZF = 1


         call getaddr_trzyplus

         a_trzyplus dd trzyplus

         getaddr_trzyplus:

         mov eax, [esp]

         fld dword[eax]

         add esp, 4
         fcomp st1
         
         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah

         je load            ; jump if equal ; ZF = 1


         call getaddr_czteryplus

         a_czteryplus dd czteryplus

         getaddr_czteryplus:

         mov eax, [esp]

         fld dword[eax]

         add esp, 4
         fcomp st1

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah

         je load
         
         fcomp              ; pop st0
         
         jmp ocena

load     cmp esi, 1         ; esi - 1 ; OF SF ZF AF PF CF affected

         jnz continue       ; jump if not zero  ; ZF = 0

         jmp skip           ; jump always

continue:

;        st = [st0, st1] = [ocena, suma_poprzednich]

         faddp st1           ; [st0, st1] => [st0, st1 + st0] => [st1 + st0] = [suma_poprzenich + ocena]
         
;        st = [st0] = [suma]

skip:    add esp, 8          ; esp = esp + 4

;        esp -> [ret]

         inc esi             ; esi++
         
         jmp ocena           ; jump always

end:     dec esi             ; esi--

         push esi

;        esp -> [esi][ret]

         test esi, esi       ; esi & esi  ; OF=0 SF ZF PF CF=0 affected
         jz print

         fild dword[esp]     ; *(int*)esp = *(int*)addr_esi = esi -> st ; fpu load integer
         
;        st = [st0, st1] = [esi, suma]

         fdivp st1           ; [st0, st1] => [st0, st1 / st0] => [st1 / st0] = [suma / esi]

;        st = [st0] = [suma / esi]

         fstp qword[esp]     ; *(double*)(esp) <- st = [suma / esi]  ; fpu store top element and pop fpu stack

;        st = [ ]
;                           +4
;        esp -> [suma / esi][ ][esi][ret]

         jmp done

print:   push zero

done:
         call getaddr3
format3:
         db "srednia = %.2lf", 0xA, 0
getaddr3:

;        esp -> [format3][suma / esi][ ][esi][ret]

         call [ebx+3*4]  ; printf("srednia = %.21f\n", suma / esi);
         add esp, 4*4    ; esp = esp + 16

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call [ebx+0*4]  ; exit(0);

; asmloader API
;
; ESP wskazuje na prawidlowy stos
; argumenty funkcji wrzucamy na stos
; EBX zawiera pointer na tablice API
;
; call [ebx + NR_FUNKCJI*4] ; wywolanie funkcji API
;
; NR_FUNKCJI:
;
; 0 - exit
; 1 - putchar
; 2 - getchar
; 3 - printf
; 4 - scanf
;
; To co funkcja zwr?ci jest w EAX.
; Po wywolaniu funkcji sciagamy argumenty ze stosu.
;
; https://gynvael.coldwind.pl/?id=387

=======
[bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

min      equ 2
max      equ 5
zero     equ 0
pol      equ __?float32?__(0.5)

         mov esi, 1  ; esi = 1

         finit       ; fpu init

ocena:
         push esi
         
;        esp -> [esi][ret]

         call getaddr  ; push on the stack the run-time address of format and jump to getaddr
format:
         db "%d ocena = ", 0
getaddr:

;        esp -> [format][esi][ret]

         call [ebx+3*4]  ; printf("%d ocena = ", esi);

;        esp -> [ocena][esi][ret] ; zmienna ocena, adres format nie jest juz potrzebny

         push esp

;        esp -> [addr_ocena][ocena][esi][ret]

         call getaddr2
format2:
         dd "%lf", 0
getaddr2:

;        esp -> [format2][addr_ocena][ocena][esi][ret]

         call [ebx+4*4]     ; scanf("%d", &a);
         add esp, 2*4       ; esp = esp + 8

;        esp -> [ocena][esi][ret]

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point

;        st = [st0] = [ocena]

         push 0             ; check to leave the program

;        esp -> [0][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ocena][esi][ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         je end             ; jump if equal ; ZF = 1
         
         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0] = [ocena]

         push 1             ; minimal note
         
;        esp -> [1][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ocena][esi][ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         jb ocena           ; jump if below              ; jump if CF = 1

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point

;        st = [st0] = [ocena]

         push 6             ; maximum note

;        esp -> [6][ocena][esi][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected

;        st = [ ]

         add esp, 4         ; esp = esp + 4

;        esp -> [ocena][esi][ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         ja ocena           ; jump if above  ; jump if CF = 0 and ZF = 0

         fld qword[esp]     ; *(double*)(esp) = *(double*)addr_ocena = ocena -> st ; fpu load floating-point

;        st = [st0] = [ocena]

;        now we know the number is in <1, 6> range

;        checking if correct note

         fld st0
         
         frndint

         fsub st1

         push zero

;        esp -> [zero][ocena][esi][ret]

         ficomp dword[esp]
         add esp, 4
         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         jne ocena
         je load

load     cmp esi, 1         ; esi - 1 ; OF SF ZF AF PF CF affected

         jnz continue       ; jump if not zero  ; ZF = 0

         jmp skip           ; jump always

continue:

;        st = [st0, st1] = [ocena, suma_poprzednich]

         faddp st1           ; [st0, st1] => [st0, st1 + st0] => [st1 + st0] = [suma_poprzenich + ocena]
         
;        st = [st0] = [suma]

skip:    add esp, 8          ; esp = esp + 4

;        esp -> [ret]

         inc esi             ; esi++
         
         jmp ocena           ; jump always

end:     dec esi             ; esi--

         push esi

;        esp -> [esi][ret]

         fild dword[esp]     ; *(int*)esp = *(int*)addr_esi = esi -> st ; fpu load integer
         
;        st = [st0, st1] = [esi, suma]

         fdivp st1           ; [st0, st1] => [st0, st1 / st0] => [st1 / st0] = [suma / esi]

;        st = [st0] = [suma / esi]

         fstp qword[esp]     ; *(double*)(esp) <- st = [suma / esi]  ; fpu store top element and pop fpu stack
         
;        st = [ ]
;                           +4
;        esp -> [suma / esi][ ][esi][ret]

         call getaddr3
format3:
         db "srednia = %.2lf", 0xA, 0
getaddr3:

;        esp -> [format3][suma / esi][ ][esi][ret]

         call [ebx+3*4]  ; printf("srednia = %.21f\n", suma / esi);
         add esp, 4*4    ; esp = esp + 16

;        esp -> [ret]

         push 0          ; esp -> [0][ret]
         call [ebx+0*4]  ; exit(0);

; asmloader API
;
; ESP wskazuje na prawidlowy stos
; argumenty funkcji wrzucamy na stos
; EBX zawiera pointer na tablice API
;
; call [ebx + NR_FUNKCJI*4] ; wywolanie funkcji API
;
; NR_FUNKCJI:
;
; 0 - exit
; 1 - putchar
; 2 - getchar
; 3 - printf
; 4 - scanf
;
; To co funkcja zwr?ci jest w EAX.
; Po wywolaniu funkcji sciagamy argumenty ze stosu.
;
; https://gynvael.coldwind.pl/?id=387
>>>>>>> a55fedfc5d690fdc726afe9a664f801756803d92
