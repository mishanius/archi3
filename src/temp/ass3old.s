SPP equ 4
DRONE_OBJ_SIZE equ 20
DRONE_ID equ 0
DRONE_SCORE equ 4
DRONE_X equ 8
DRONE_Y equ 12
DRONE_ALPHA equ 16
DRONE_DESTORIED_TARGETS equ 16
MAX_COORDINATE equ 100
SHIFTER_COORDINATE equ 0

section .text ;here is my code
    extern printf
    extern malloc
    extern sscanf
    extern scheduler
    extern drone
    extern print
    extern target
    global SHOULD_STOP
    global DRONE_X
    global DRONE_Y
    global DRONE_ALPHA
    global DRONE_ID
    global DRONE_OBJECT_ARRAY
    global DRONE_SCORE
    global main
    global SPMAIN
    global end_co
    global SCHEDULER_RUTINE
    global resume
    global DRONE_NUMBER
    global DRONE_RUTINE_ARRAY
    global NUMBER_OF_DRONES
    global NUMBER_OF_STEPS
    global DRONE_OBJECT_ARRAY
    global CURR_STEP_K
    global PRINT_RUTINE
    global SEED
    global TARGET_RUTINE
    global TARGET_OBJECT
    global random_float



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
    shl eax, 2 ; each array cell is 4 byte (address)    
    push eax
    call malloc ; eax holds ptr to new address
    add esp,    4*1   ;restore esp

    mov [DRONE_RUTINE_ARRAY], eax
    mov [CURR_CELL], eax
    
    ;create drone object array
    mov eax, [NUMBER_OF_DRONES]
    shl eax, 2 ; each array cell is 4 byte    
    push eax
    call malloc ; eax holds ptr to new address of drone strut
    add esp,    4*1   ;restore esp

    mov [DRONE_OBJECT_ARRAY], eax
    mov [CURR_DRONE_STRUCT], eax
    mov dword [DRONE_NUMBER], 1

    mov ecx, [NUMBER_OF_DRONES]  ;init  counter for the loop
    xor ebx, ebx

.loopstart:
    push drone
    cmp ecx,1
    jnz next
ecxone:
    mov ecx,1
next:
    call init_rutine ; now eax hold the rutine struct
    add esp , 4*1
    mov ebx, [CURR_CELL]
    mov [ebx], eax
    add dword [CURR_CELL], 4*1 ;curr_cell is address of the cell each cell is size 4 so add 4 to move to next cell
jnz_m:
    call init_drone ; now eax hold the drone struct
    add esp , 4*1
    mov ebx, [CURR_DRONE_STRUCT]
    mov [ebx], eax
    add dword [CURR_DRONE_STRUCT], 4*1
    add dword [DRONE_NUMBER], 1
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
    push debug
    call printf
    add esp,4
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

init_rutine: ;create drone co-rutine adress stored in EAX 
    push ebp
    mov ebp, esp

    push ebx 

    call alloc_rutine ; this will allocate a new rutine struct and store its address in eax
    mov ebx, eax

    call alloc_stack ; this will aloocate a new stack for the rutine address stored in eax
dbg_afterallocstack:
    add eax, RUTINE_STACK_SIZE; go to top of stack
    mov [ebx+4], eax ;store address of co-rutine stack

    mov [SPT], esp
    mov esp, [ebx + 4]
dgb_ebp_plus:
    mov edx, [ebp + 8]
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
dbg_allocstack_after_mal:
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


alloc_drone: ;allocate a drone struct (size 16 bytes) address stored in eax
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push dword DRONE_OBJ_SIZE
    call malloc 
    add esp,    4   ;restore esp
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret

init_drone:
    
    call alloc_drone ;now eax holds the drone struct
    push ebx ;we dont want to change ebx
    mov ebx, eax ;eax and ebx hold ptr to struct
    
    push ecx ;we dont want to change ecx
    mov ecx, [DRONE_NUMBER]
    mov [ebx+DRONE_ID], ecx
    pop ecx
    
    mov dword [ebx+DRONE_SCORE], 0
    
    ;------------- generate x -----------
    push dword 0; we dont need to shift the range it is [0,100]

    fild dword [MAX_COR] ;load integer MAX_COORDINATE
    sub esp, 4*1 ;make room for float in stack
    fstp dword [esp] ;store (float)MAX_COORDINATE in stack 

    lea eax, [ebx + DRONE_X] ;load address of &(*(eax+DRONE_x))
    push eax ;push address to return the random value

    call random_float
    add esp, 4*3 ;restore stack
    ;------------- done with x -------------------

    ;------------- generate y -----------
    push dword 0; we dont need to shift the range it is [0,100]

    fild dword [MAX_COR] ;load integer MAX_COORDINATE
    sub esp, 4*1 ;make room for float in stack
    fstp dword [esp] ;store (float)MAX_COORDINATE in stack 

    lea eax, [ebx + DRONE_Y] ;load address of &(*(eax+DRONE_Y))
    push eax ;push address to return the random value

    call random_float
    add esp, 4*3 ;restore stack
    ;------------- done with y -------------------

    ;------------- generate ALPHA -----------
    fldpi ;load pi in x87
    fidiv dword [THREE] ;divide by integer 3 
    fimul dword [MINUS_ONE] ;mult by -1 we get -pi/3 by shifting the range we will get range [-pi/3,pi/3] 
    sub esp,4*1
    fstp dword [esp];store shift value in stack

    fldpi ;store pi in x87
    fidiv dword [THREE] ;div by integer 3 
    fimul dword [TWO]   ;mult by integer 2 -> we get 2pi/3
    sub esp,4*1
    fstp dword [esp] ;move max angle to stack

    lea eax, [ebx + DRONE_ALPHA] ;load address of &(*(eax+DRONE_ALPHA))
    push eax ;push address to return the random value

    call random_float
    add esp, 4*3 ;restore stack
    ;------------- done with ALPHA -------------------


    xchg ebx,eax
    pop ebx ;restore ebx
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

random_float:
;input first arg (big address) - high limit
;input second arg (mid address) - low limit
;input third arg (smallest address) -address to store the 10 bit number
    push   ebp
    mov    ebp,esp
    pushfd
    pushad
    mov ebx, [ebp + 4 + 4*1] ;address to store number
    mov [address_to_return], ebx
    mov ecx, [ebp + 4 + 4*2] ;high limit
    mov edx, [ebp + 4 + 4*3] ;shifter

    call generate_random
    ;mov eax, 0XFFFF1FF2
    and eax, 0xFFFF ;mask to take only 16 bit
    mov [tmpfloat], eax

    fild dword  [tmpfloat]
    fild dword  [MAXNUM]
    fdiv
    ;and ecx, 0xFFFF ;mask to take only 16 bit
    mov dword [tmpfloat], ecx
    ;fild dword [tmpfloat]
    fld dword [tmpfloat]
    fmul
    mov dword [tmpfloat], edx
    fld dword [tmpfloat]
    fsub
gavno:
    fstp dword [ebx] ;move result to destanetion

    popad
    popfd
    mov    esp,ebp
    pop    ebp                                ; restore registers
    ret

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


;push ebp
;mov ebp, esp

;mov esp, ebp
;pop ebp
;ret
section .rodata
    format_num: db "%d",10, 0   ; format string
    format_float: db "debug float:%.2f",10, 0   ; format string
    debug: db "debug",10, 0   ; format string
    RUTINE_STACK_SIZE: dd 5*1024 
    RUTINE_SIZE: dd 8
    

section .bss
    SPMAIN: resd 1 ;
    SPT: resd 1 ;TEMP STACK PTR
    CURR: resd 1
    SHOULD_STOP: resb 1
    DRONE_NUMBER: resd 1
    CURR_DRONE_STRUCT: resd 1

    DRONE_RUTINE_ARRAY: resd 1 ;array ptr is an adress hence double-word
    PRINT_RUTINE: resd 1 ;array ptr is an adress hence double-word
    CURR_CELL: resd 1 ;current array cell
    SCHEDULER_RUTINE: resd 1 
    TARGET_RUTINE: resd 1 

    TARGET_OBJECT: resd 1 ;pointer to target object
    DRONE_OBJECT_ARRAY: resd 1 ;array ptr is an adress hence double-word

    NUMBER_OF_DRONES: resd 1
    NUMBER_OF_TARGETS: resd 1
    NUMBER_OF_STEPS: resd 1
    CURR_STEP_K: resd 1
    KILL_RANGE: resd 1
    BETHA: resd 1
    SEED: resd 1

section .data
    tmpfloat:   dd  0
    address_to_return:   dq  0
    MAXNUM:     dd  0XFFFF
    MAX_TARGET_COR: dd 100 
    MAX_COR: dd 100 
    TWO:          dd  2
    THREE:          dd  3
    MINUS_ONE:          dd  -1
    MAX_FLOAT:dd 0
    SHIFT_FLOAT:dd 0