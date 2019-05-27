section .rodata
    format_drone: db "this is drone %d",10, 0   ; format string
    init_drone: db "init drone %d",10, 0   ; format string

section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern resume
    global drone

drone:
    push dword [DRONE_NUMBER]
    push init_drone
    call    printf
    add esp, 4*2
.continue:
    push dword [DRONE_NUMBER]
    push format_drone
    call    printf
    add esp, 4*2
.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp drone.continue
