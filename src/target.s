TARGET_OBJ_SIZE equ 8
TARGET_X equ 0
TARGET_Y equ 4


section .rodata
    format_target: db 0,"random target (%.2f, %.2f) ",10, 0   ; format string

section .data
    MAX: dd 100 

section .text ;here is my code
    extern MAX_CORV2
    extern CORD_SHIFTER


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
    global random_target
    global TARGET_OBJ_SIZE

target:
.continue:
    call random_target
.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp target.continue





random_target:
    pushad
    push dword [CORD_SHIFTER]
    push dword [MAX_CORV2]
    mov ebx, [TARGET_OBJECT]
    lea ebx, [ebx + TARGET_X]
    push ebx
    call random_float
    add esp, 4*3

    push dword [CORD_SHIFTER]
    push dword [MAX_CORV2]
    mov ebx, [TARGET_OBJECT]
    lea ebx, [ebx + TARGET_Y]
    push ebx
    call random_float
    add esp, 4*3

;---------DEBUG----------

    mov ebx, [TARGET_OBJECT]

    sub esp,8
    fld dword [ebx + TARGET_Y]
    fst qword [esp]

    sub esp,8
    fld dword [ebx + TARGET_X]
    fst qword [esp]

    push format_target
    call printf
    add esp, 20
;---------DEBUG----------

    popad
    ret