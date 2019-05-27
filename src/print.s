section .rodata
    format_print: db "this is print",10, 0   ; format string
    init_print: db "init print",10, 0   ; format string

section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern resume
    global print

print:
    push dword 1
    push init_print
    call    printf
    add esp, 4*2
.continue:
    push dword 1
    push format_print
    call    printf
    add esp, 4*2
.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp print.continue
