TARGET_OBJ_SIZE equ 21
TARGET_IS_DEAD equ 0
TARGET_X equ 1
TARGET_Y equ 11

section .rodata
    format_target: db "this is target %d",10, 0   ; format string
    init_target: db "init target",10, 0   ; format string

section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern resume
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
    mov ebx, [TARGET_OBJECT]
    mov [ebx], 0
    call generate_random
    mov [ebx + TARGET_X], eax
    call generate_random
    mov [ebx + TARGET_Y], eax
.continue:
    call generate_random
    push eax
    push format_target
    call    prisntf
    add esp, 4*2
.end:
    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp target.continue

generate_random:
;generates random 16 bit number, stores it in eax
    push ebx
    push ecx
    push edx
    xor eax,eax
    mov ax, [SEED]
    mov bx, ax
    mov cx, ax
    mov dx, ax
    shr bx, 2
    shr cx, 3
    shr dx, 5
    xor bx, ax
    xor bx, cx
    xor bx, dx
    shr ax, 1
    shl bx, 15
    or ax, bx
    mov [SEED], eax
    pop edx
    pop ecx
    pop ebx
    ret
    