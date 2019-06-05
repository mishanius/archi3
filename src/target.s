TARGET_OBJ_SIZE equ 8
TARGET_X equ 0
TARGET_Y equ 4
MAX_COORDINATE equ 100
SHIFTER equ 0

section .rodata
    format_target: db "this is target is (%.2f) ",10, 0   ; format string
    init_target: db "init target",10, 0   ; format string

section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern malloc
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern resume
    extern random_float
    extern SEED
    extern TARGET_OBJECT
    global target

target:
    push dword 1
    push init_target
    call    printf
    add esp, 4*2
    push dword TARGET_OBJ_SIZE
    call malloc
    mov [TARGET_OBJECT], eax

    push dword SHIFTER
    push dword MAX_COORDINATE
    mov ebx, [TARGET_OBJECT]
    lea ebx, [ebx + TARGET_X]
    push ebx
    call random_float
    add esp, 4*3

    push dword SHIFTER
    push dword MAX_COORDINATE
    mov ebx, [TARGET_OBJECT]
    lea ebx, [ebx + TARGET_Y]
    push ebx
    call random_float
    add esp, 4*3



.continue:
    push dword SHIFTER
    push dword MAX_COORDINATE
    mov ebx, [TARGET_OBJECT]
    lea ebx, [ebx + TARGET_X]
    push ebx
    call random_float
    add esp, 4*3

    push dword SHIFTER
    push dword MAX_COORDINATE
    mov ebx, [TARGET_OBJECT]
    lea ebx, [ebx + TARGET_Y]
    push ebx
    call random_float
    add esp, 4*3

.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp target.continue
    