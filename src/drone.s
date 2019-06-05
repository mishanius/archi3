DRONE_OBJ_SIZE equ 8
DRONE_ID equ 0
DRONE_X equ 4
DRONE_Y equ 8
DRONE_ALPHA equ 12
DRONE_DESTORIED_TARGETS equ 16
MAX_COORDINATE equ 100
SHIFTER_COORDINATE equ 0

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
    extern random_float
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


init_dronee:
;recives drone index 1...N+1
    ;push dword TARGET_OBJ_SIZE
    ;call malloc
    ;mov [TARGET_OBJECT], eax

    ;push dword SHIFTER
    ;push dword MAX_COORDINATE
    ;mov ebx, [TARGET_OBJECT]
    ;lea ebx, [ebx + TARGET_X]
    ;push ebx
    ;call random_float
    ;add esp, 4*3

    ;push dword SHIFTER
    ;push dword MAX_COORDINATE
    ;mov ebx, [TARGET_OBJECT]
    ;lea ebx, [ebx + TARGET_Y]
    ;push ebx
    ;call random_float
    ;add esp, 4*3
