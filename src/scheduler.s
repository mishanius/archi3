section .rodata
    scheduler_str: db "this is scheduler",10, 0   ; format string

section .text ;here is my code
    
    extern printf
    extern SPMAIN
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern NUMBER_OF_DRONES
    extern DRONE_RUTINE_ARRAY
    extern CURR_STEP_K
    extern NUMBER_OF_STEPS
    extern resume
    extern PRINT_RUTINE
    extern TARGET_RUTINE
    global scheduler

scheduler:
    mov dword [CURR_STEP_K], 0

.continue:
    mov eax, [DRONE_NUMBER]
    mov ebx, [DRONE_RUTINE_ARRAY]
    mov ebx, [ebx + (eax-1)*4]
    call resume

    cmp byte [SHOULD_STOP], 1
    jz scheduler.end

    inc dword [CURR_STEP_K]
    mov eax, [CURR_STEP_K]
    cmp eax, [NUMBER_OF_STEPS]
    jnz scheduler.after_print
    mov ebx, [PRINT_RUTINE]
    call resume
    mov dword [CURR_STEP_K], 0 
    

.after_print:
    inc dword [DRONE_NUMBER]
    mov eax, [DRONE_NUMBER]
    cmp eax, [NUMBER_OF_DRONES]
    jbe scheduler.continue

    mov dword [DRONE_NUMBER], 1
    jmp scheduler.continue

.end:
	mov esp, [SPMAIN]
	jmp end_co

    
