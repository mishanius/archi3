TARGET_X equ 0
TARGET_Y equ 4

section .rodata
    format_print: db "this is print",10, 0   ; format string
    init_print: db "init print",10, 0   ; format string
    target_format: db "target:%.2f, %.2f",10, 0   ; format string

section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern TARGET_OBJECT
    extern resume
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
    lea ebx, [ebx+ TARGET_X]
    sub esp, 4*2
    fld  dword  [ebx]
    fstp qword [esp]

    mov ebx,[TARGET_OBJECT]
    lea ebx, [ebx+ TARGET_Y]
    sub esp, 4*2
    fld  dword  [ebx]
    fstp qword [esp]
    
    push target_format

    call printf
    add esp, 4*5

.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp print.continue
