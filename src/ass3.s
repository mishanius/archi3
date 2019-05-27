SPP equ 4
section .text ;here is my code
    extern printf
    extern malloc
    extern sscanf
    extern scheduler
    extern drone
    extern print
    extern target
    global SHOULD_STOP
    global main
    global SPMAIN
    global end_co
    global SCHEDULER_RUTINE
    global resume
    global DRONE_NUMBER
    global DRONE_RUTINE_ARRAY
    global NUMBER_OF_DRONES
    global NUMBER_OF_STEPS
    global CURR_STEP_K
    global PRINT_RUTINE
    global SEED
    global TARGET_RUTINE
    global TARGET_OBJECT


main:
    push ebp
    mov ebp, esp
    mov ebx, dword [ebp + 4*3]
    
    pushad

    push NUMBER_OF_DRONES
    push format_num
    push dword [ebx + 4*1] ; N 
    call sscanf ; will store the N value in eax
    add esp, 4*3;

    push NUMBER_OF_TARGETS
    push format_num
    push dword [ebx + 4*2] ; T 
    call sscanf ; will store the T value in eax
    add esp, 4*3;

    push NUMBER_OF_STEPS
    push format_num
    push dword [ebx + 4*3] ; K 
    call sscanf ; will store the K value in eax
    add esp, 4*3;

    push KILL_RANGE
    push format_num
    push dword [ebx + 4*4] ; KILL_RANGE 
    call sscanf ; will store the KILL_RANGE value in eax
    add esp, 4*3;

    push BETHA
    push format_num
    push dword [ebx + 4*5] ; BETHA 
    call sscanf ; will store the BETHA value in eax
    add esp, 4*3;

    push SEED
    push format_num
    push dword [ebx + 4*6] ; SEED 
    call sscanf ; will store the SEED value in eax
    add esp, 4*3;

    ;create scheduler rutine
    push scheduler
    call init_rutine ;now eax holds the rutine struct
    add esp, 4*1
    mov [SCHEDULER_RUTINE], eax

    ;create print rutine
    push print
    call init_rutine ;now eax holds the rutine struct
    add esp, 4*1
    mov [PRINT_RUTINE], eax

    ;create target rutine
    push target
    call init_rutine ;now eax holds the rutine struct
    add esp, 4*1
    mov [TARGET_RUTINE], eax

    ;create array of drone rutines
    mov eax, [NUMBER_OF_DRONES]
    shl eax, 3 ; each drone rutine is 8 byte    
    push eax
    call malloc ; eax holds ptr to new address
    add esp,    4*1   ;restore esp

    mov [DRONE_RUTINE_ARRAY], eax
    mov [CURR_CELL], eax

    mov ecx, [NUMBER_OF_DRONES] 
    
    xor ebx, ebx

.loopstart:
    push drone
    call init_rutine ; now eax hold the rutine struct
    add esp , 4*1
    mov ebx, [CURR_CELL]
    mov [ebx], eax
    add dword [CURR_CELL], 4
    ;call [eax+0] 
    dec ecx
    jnz main.loopstart

    mov dword [DRONE_NUMBER], 1
    mov byte [SHOULD_STOP], 0
    pushad
    ;push end_co
    mov [SPMAIN], esp
    mov ebx, [SCHEDULER_RUTINE]
    jmp resume.do_resume
    ;TODO free assets
end_co:
    popad

    mov esp, ebp
    pop ebp
    ret
    


someFunc:
    push ebp
    mov ebp, esp
    pushad
    push dword [NUMBER_OF_TARGETS]
    push format_num
    call    printf
    add esp, 4*2
    popad
    mov esp, ebp
    pop ebp
    ret

start_drone:

start_scheduler:

init_rutine: ;create drone co-rutine adress stored in EAX 
    push ebp
    mov ebp, esp

    push ebx 

    call alloc_rutine ; this will allocate a new rutine struct and store its address in eax
    mov ebx, eax

    call alloc_stack ; this will aloocate a new stack for the rutine address stored in eax
    
    add eax, RUTINE_STACK_SIZE; go to top of stack
    mov [ebx+4], eax ;store address of co-rutine stack

    mov [SPT], esp
    mov esp, [ebx + 4]
    push dword [ebp + 8] ; function address
    mov edx, -1
    pushfd
    pushad
    mov [ebx + 4], esp 
    mov esp, [SPT]
    
    xchg ebx, eax

    push ecx 
    mov ecx, [ebp + 8]
    mov dword [eax + 0], ecx ;store address of co-rutine function
    pop ecx
    
    pop ebx

    mov esp, ebp
    pop ebp
    ret

alloc_stack: ;allocate a stack for the new co-rutine store result in EAX
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push RUTINE_STACK_SIZE
    call malloc 
    add esp,    4   ;restore esp
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

alloc_rutine: ;allocate a co-rutine struct (size 8 bytes) address stored in eax
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push RUTINE_SIZE
    call malloc 
    add esp,    4   ;restore esp
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

resume:
    pushfd
    pushad
    mov edx, [CURR]
    mov [edx+SPP], esp
resume.do_resume:
    mov esp, [ebx + SPP]
    mov dword [CURR], ebx
    popad
    popfd
    ret



;push ebp
;mov ebp, esp

;mov esp, ebp
;pop ebp
;ret
section .rodata
    format_num: db "%d",10, 0   ; format string
    RUTINE_STACK_SIZE: dd 16*1024 
    RUTINE_SIZE: dd 8
    

section .bss
    SPMAIN: resd 1 ;
    SPT: resd 1 ;TEMP STACK PTR
    CURR: resd 1
    SHOULD_STOP: resb 1
    DRONE_NUMBER: resd 1

    DRONE_RUTINE_ARRAY: resd 1 ;array ptr is an adress hence double-word
    PRINT_RUTINE: resd 1 ;array ptr is an adress hence double-word
    CURR_CELL: resd 1 ;current array cell
    SCHEDULER_RUTINE: resd 1 
    TARGET_RUTINE: resd 1 

    TARGET_OBJECT: resd 1 ;pointer to target object

    NUMBER_OF_DRONES: resd 1
    NUMBER_OF_TARGETS: resd 1
    NUMBER_OF_STEPS: resd 1
    CURR_STEP_K: resd 1
    KILL_RANGE: resd 1
    BETHA: resd 1
    SEED: resd 1