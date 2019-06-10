TARGET_X equ 0
TARGET_Y equ 4

section .rodata
    format_print: db 0,"this is print",10, 0   ; format string
    init_print: db 0,"init print",10, 0   ; format string
    target_format: db "%.2f,%.2f",10, 0   ; format string
    drone_format: db "%d,%.2f,%.2f,%.2f,%d",10, 0   ; format string
section .data
    CELL_i : dd 0
section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern TARGET_OBJECT
    extern DRONE_OBJECT_ARRAY
    extern DRONE_X
    extern DRONE_Y
    extern DRONE_ALPHA
    extern DRONE_ID
    extern DRONE_SCORE
    extern NUMBER_OF_DRONES
    extern resume
    extern ONE_HUNDRED_EIGHTY
    global print

print:
    push dword 1
    push init_print
    call    printf
    add esp, 4*2
    xor ecx, ecx
.continue:
    push dword 1
    push format_print
    call    printf
    add esp, 4*2
.target:
    mov ebx,[TARGET_OBJECT]
    lea ebx, [ebx+ TARGET_Y]
    sub esp, 4*2
    fld  dword  [ebx]
    fstp qword [esp]

    mov ebx,[TARGET_OBJECT]
    lea ebx, [ebx+ TARGET_X]
    sub esp, 4*2
    fld  dword  [ebx]
    fstp qword [esp]
    
    push target_format

    call printf
    add esp, 4*5

    mov ecx, [NUMBER_OF_DRONES]  ;init  counter for the loop
    
    mov ebx, [DRONE_OBJECT_ARRAY] ;move address of first elemnt
    mov [CELL_i], ebx ;now cell_i holds address of drone 0 struct

    xor ebx, ebx

.drone:
    push ecx
    mov ebx,[CELL_i] ;get address of drone i struct
    mov dword ebx, [ebx] ;get the drone i
    mov eax, ebx ;ebx and eax holds the address of the first field in the struct

    lea ebx, [eax + DRONE_SCORE]
    push dword [ebx]

    lea ebx, [eax + DRONE_ALPHA]
    sub esp, 4*2
    fld  dword  [ebx]
    fldpi
    fdiv
    fimul dword [ONE_HUNDRED_EIGHTY]
    fstp qword [esp]

    lea ebx, [eax + DRONE_Y]
    sub esp, 4*2
    fld  dword  [ebx]
    fstp qword [esp]

    lea ebx, [eax + DRONE_X]
    sub esp, 4*2
    fld  dword  [ebx]
    fstp qword [esp]

    
    lea ebx, [eax + DRONE_ID]
    push dword [ebx]
    
    push drone_format

    call printf
    add esp, 4*9

    add dword [CELL_i], 4*1
    
    pop ecx
    dec ecx
    jnz print.drone

.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp print.continue
