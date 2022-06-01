         [bits 32]

extern   _printf
extern   _exit
extern   _scanf

exit     equ 0
min      equ 1
max      equ 6

section  .bss

ocena    resq 1  ; [00 00 00 00 00 00 00 00]              ; reserve quadruple word

section  .data

prompt   db "%d ocena = ", 0
input    db "%lf", 0
srednia  db "srednia = %.2lf", 0xA, 0
testt    db "Wczytana liczba: %lf", 0xA, 0

section  .text

global   _main

_main:
         mov esi, 1        ; esi = 1

         finit             ; fpu init

petla:
         push esi
         push prompt

;        esp -> [prompt][esi][ret]

         call _printf      ; printf(prompt, esi);

         add esp, 2*4      ; esp = esp + 8

;        esp -> [ret]

         push ocena
         push input
         
;        esp -> [input][ocena][ret]

         call _scanf       ; scanf(input, &ocena);

         add esp, 8        ; esp = esp + 8
         
;        esp -> [ret]
         
         fld qword[ocena]  ; *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0] = [ocena]

         push exit
         
;        esp -> [exit][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         je end             ; jump if equal ; ZF = 1
         
         fld qword[ocena]  ; *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0] = [ocena]

         push min
         
;        esp -> [min][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         jb petla           ; jump if equal ; ZF = 1

         fld qword[ocena]  ; *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0] = [ocena]

         push max
         
;        esp -> [min][ret]

         ficomp dword[esp]  ; st0 - esp ; st0 - 0 ; ZF PF CF affected
         
;        st = [ ]

         add esp, 4         ; esp = esp + 4
         
;        esp -> [ret]

         fstsw ax           ; ax = fpu_status_word ; fpu store status word
         sahf               ; eflags(SF:ZF:AF:PF:CF) = ah
         ja petla           ; jump if equal ; ZF = 1
         
         fld qword[ocena]  ; *(double*)addr_ocena = ocena -> st ; fpu load floating-point
         
;        st = [st0] = [ocena]
         
         cmp esi, 1         ; esi - 1 ; OF SF ZF AF PF CF affected

         jnz continue       ; jump if not zero  ; ZF = 0

         jmp skip           ; jump always
         
continue:
;        st = [st0, st1] = [ocena, suma_poprzednich]

         faddp st1           ; [st0, st1] => [st0, st1 + st0] => [st1 + st0] = [suma_poprzenich + ocena]
         
;        st = [st0] = [suma]
skip:
         inc esi
         jnz petla

end:
         dec esi             ; esi--

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

         push srednia
         
         call _printf
         
         add esp, 4*4

         push 0      ; esp -> [0][ret]
         call _exit  ; exit(0);

%ifdef COMMENT
Kompilacja:

nasm srednia_exe.asm -o srednia.o -f win32

ld srednia.o -o srednia.exe c:\windows\system32\msvcrt.dll -m i386pe

lub:

nasm srednia_exe.asm -o srednia.o -f win32

gcc srednia.o -o srednia.exe -m32
%endif

