DRONE_OBJ_SIZE equ 8
DRONE_ID equ 0
DRONE_SCORE equ 4
DRONE_X equ 8
DRONE_Y equ 12
DRONE_ALPHA equ 16
DRONE_DESTORIED_TARGETS equ 16
MAX_COORDINATE equ 100
SHIFTER_COORDINATE equ 0


section .rodata
    format_drone: db 0,"this is drone %d",10, 0   ; format string
    init_drone: db 0,"init drone %d",10, 0   ; format string
    init_drone_f: db 0,"init drone %.2f",10, 0   ; format string
    drone_f: db 0,"drone number %d (%.2f,%.2f) direction %.2f tempt Dist %.2f new direction %.2f",10, 0   ; format string
    drone_calc: db 0,"drone calculation number %d dist: %.2f, dist_x^2: %.2f dist_y^2: %.2f tarrrget:(%.2f,%.2f)",10, 0;   format string
    dist_f: db 0,"DIST IS %.2f ",10, 0   ; format string
    mod_increse_s: db 0,"MOD increse op2 is %.2f, op1 %.2f mod %.2f ", 0   ; format string
    res_s: db 0,"res %.2f ",10, 0   ; format string
    x_cor_string: db 0,"X is %.2f ",0   ; format string
    foubd_IAM: db "foubd_IAM",10,0
    y_cor_string: db 0,"Y is %.2f ",10, 0   ; format string
    xdist_f: db 0,"X DIST IS %.2f ",10, 0   ; format string
    may_str: db 0,"may destroy!!!!!!!!!!!!!!1###############%%%%%%%%%%%%%%5",10, 0 ; format string
    winner:db "Drone id %d: I am a winner",10, 0   ; format string
    target_x:db 0,"TX %.2f ",10, 0   ; format string
    stack: db 0,"esp %p",10, 0
    abs_gamma: db 0,"#####ABS_GAMA %.2f ",  10,10, 0
    abs_gammaf: db 0,"FIX  ->ABS_GAMA %.2f ",  10,10, 0

section .data
    MAX_COR: dd 100
    ONE_HUNDRED_EIGHTY: dd 180
    EBP_TEMP: dd 0
    MOD_ANGLE:dd 0
    MOD_CORDINATE:dd 100
    MAX_DELTA_D: dd 50
    FLOAT_ANGLE_SHIFT: dd 0
    MAX_ANGLE: dd 0
    TEMP_ALPHA: dd 0
    RADIAN_BETHA: dd 0
    CURR_DRONE: dd 0
    IAM: dd 0
    DRONE_SCORE_ADDRESS: dd 0
    TEMP_D: dd 0
    THREE: dd 3
    TWO: dd 2
    MINUS_ONE: dd -1
    CURR_CELL: dd 0
    TEMP_GAMMA: dd 0
    GAMMA_IS_GREATER: dd 0

section .text ;here is my code
    
    extern printf
    extern free
    extern SPMAIN
    extern TARGET_RUTINE
    extern end_co
    extern SHOULD_STOP
    extern DRONE_NUMBER
    extern SCHEDULER_RUTINE
    extern DRONE_OBJECT_ARRAY
    extern PRINT_RUTINE
    extern TARGET_OBJECT
    extern BETHA
    extern DRONE_RUTINE_ARRAY
    extern KILL_RANGE
    extern resume
    extern NUMBER_OF_DRONES
    extern random_float
    extern NUMBER_OF_TARGETS
    extern FIRST_ARG
    extern TARGET_X
    extern TARGET_Y
    extern exit
    global ONE_HUNDRED_EIGHTY
    global drone

drone:

    finit ;init fpu (delete all stored)
    fldpi ;load pi
    push dword 2
    fimul dword [esp]
    fstp dword [MOD_ANGLE] ;store in MOD_ANGLE 2*pi
    add esp,4 ;restore stack

    fild dword [BETHA]
    fidiv dword [ONE_HUNDRED_EIGHTY]
    fldpi
    fmul
    fstp dword [RADIAN_BETHA]

.continue:
    
    push esp
    push stack
    call printf
    add esp,4*2
    mov dword [EBP_TEMP], esp


    push eax
    push ebx

    

    mov eax, [DRONE_OBJECT_ARRAY]
    mov ebx, [DRONE_NUMBER]    
    mov eax, [eax + (ebx-1)*4] ;now eax holds the address of the drone struct
    mov ebx, eax ;both ebx and eax hold the address
    ;------------- generate alpha -----------
    fldpi                   ;load pi 
    fidiv dword [THREE]     ;divide by integer 3 
                                                            ;fimul dword [MINUS_ONE] ;mult by -1 we get -pi/3 by shifting the range we will get range [-pi/3,pi/3] 
    sub esp,4*1             ;make room on stack
    fstp dword [esp]        ;store shift value in stack by shifting the range we will get range [-pi/3,pi/3]

    fldpi                   ;store pi
    fidiv dword [THREE]     ;div by integer 3 
    fimul dword [TWO]       ;mult by integer 2 -> we get 2pi/3
    sub esp,4*1             ;make room on stack
    fstp dword [esp]        ;move max angle to stack we will get the range [0,2pi/3] after shift [-pi/3,pi/3]

    push dword TEMP_ALPHA

    call random_float
    add esp, 4*3 ;restore stack

    ;------------- done with alpha -------------------


    ;------------- generate d -----------
    push dword 0; we dont need to shift the range it is [0,100]

    fild dword [MAX_DELTA_D] ;load integer MAX_COORDINATE
    sub esp, 4*1 ;make room for float in stack
    fstp dword [esp] ;store (float)MAX_COORDINATE in stack 

    push dword TEMP_D ;push address to return the random value

    call random_float
    add esp, 4*3 ;restore stack

    ;------------- done with d -------------------
    ;--------here we print for debug-----------------
    sub esp, 4*2
    fld  dword  [TEMP_ALPHA]
    fstp qword [esp]

    sub esp, 4*2
    fld  dword  [TEMP_D]
    fstp qword [esp]

    sub esp, 4*2
    fld  dword  [ebx+DRONE_ALPHA]
    fstp qword [esp]

    sub esp, 4*2
    fld  dword  [ebx+DRONE_Y]
    fstp qword [esp]

    sub esp, 4*2
    fld  dword  [ebx+DRONE_X]
    fstp qword [esp]

    push dword [DRONE_NUMBER]

    push drone_f
    call printf
    add esp, 4*11
    ;------------------------------------------------
    
    lea eax, [ebx + DRONE_ALPHA] ;eax is now an address to degree field

    ;-------add ALPHA TO DEGREE--------------
    push dword [MOD_ANGLE]
    push dword [TEMP_ALPHA]
    push eax
    call mod_increase
    add esp, 4*3
    ;--------------end of ALPHS ADITION------------
    
    ;--------------calculate the new X COORDINATE--------------------
    sub esp,    4                   ;make room on stack
    fild dword [MOD_CORDINATE]
    fstp dword [esp]
    sub esp,    4                   ;make room on stack
    finit             
    fld dword [eax] 
    fcos                        ;cos([eax])
    fld   dword [TEMP_D]        
    fmul                      ;[TEMP_D]*cos([eax])
    fstp dword [esp]

    lea eax, [ebx + DRONE_X] ;eax is now a address to X field

    push eax
    call mod_increase
    add esp, 4*3

    fld dword [ebx + DRONE_X]
    sub esp, 4*2
    fstp qword [esp]
    push x_cor_string
    call printf
    add esp, 4*3
    ;------------------------------------------------------------
    
    lea eax, [ebx + DRONE_ALPHA] ;eax is now an address to degree field

    ;------------------------CALCULATE THE Y---------------------
    sub esp,    4                   ;make room on stack
    fild dword [MOD_CORDINATE]
    fstp dword [esp]
    sub esp,    4                   ;make room on stack
    finit              
    fld dword [eax] 
    fsin                        ;sin([eax])
    fld   dword [TEMP_D]        
    fmul                       ;[TEMP_D]*cos([eax])
    fstp dword [esp]

    lea eax, [ebx + DRONE_Y] ;eax is now a address to X field

    push eax
    call mod_increase
    add esp, 4*3


    fld dword [ebx + DRONE_Y]
    sub esp, 4*2
    fstp qword [esp]
    push y_cor_string
    call printf
    add esp, 4*3
    ;--------------------------------------------------------------


    push ebx
    call may_destroy
    pop ebx
    cmp eax, 1
    jnz drone.didnt_destried
    inc dword [ebx + DRONE_SCORE]
    mov ebx, [ebx + DRONE_SCORE]
    cmp ebx, [NUMBER_OF_TARGETS]
    jnz drone.didnt_win
    
    add esp,4
    pop ebx
    pop eax
    
    push dword [DRONE_NUMBER]
    push winner
    call printf
    add esp, 4*2
    
    mov dword [SHOULD_STOP], 1
    jmp drone.end

.didnt_win:
    mov ebx, [TARGET_RUTINE]
    call resume
    jmp drone.continue
.didnt_destried:
    add esp,4

    pop ebx
    pop eax
.end:

    push esp
    push stack
    call printf
    add esp,4*2

    mov ebx, [SCHEDULER_RUTINE]
    call resume
    jmp drone.continue


mod_increase:
;third mod float
;second operand 2 is a dword float
;first operand 1 is address
    push ebp
    mov ebp,esp
    pushad
    
    sub esp, 4*(2)
    fld dword [ebp + 4 + 4*3] ;mod value
    fst qword [esp] ;mod on esp
    
    sub esp, 4*(2)
    mov ebx, [ebp + 4 + 4*1] ;address of operand to ebx
    fld dword [ebx] ;get the actual operand
    fst qword [esp]  ;operand 1 on esp

    sub esp, 4*(2)
    fld dword [ebp + 4 + 4*2]
    fst qword [esp]  ;operand 2 on esp

    push mod_increse_s
    call printf
    add esp, 4*7 ;restore


    fadd  ;make the adition
    fldz 
    fcomi st0, st1 ;compare with zero
    jbe mod_increase.not_neg
    fadd ;remove the zero
    fadd ;the modulo is already on stack
    jmp mod_increase.exit
.not_neg:
    fadd ; remove the zero
    fcomi st0, st1 ;compare to modulu already on stack
    jb mod_increase.exit ;if below we are ok
    fsubr ;subtract the modulu
.exit:
    mov ebx, [ebp + 4 + 4*1] ;get address
    fst dword [ebx];save the output back to its address

    sub esp, 4*2
    fstp qword [esp]
    push res_s
    call printf
    add esp, 4*3

    popad
    mov esp, ebp
    pop ebp
    ret










may_destroy:
    ;arg1: address of drone object
    push ebp
    mov ebp, esp
    push ebx

    fld dword [RADIAN_BETHA]            ; (buttom)betha(top)

    mov eax, [ebp + FIRST_ARG]          ;eax holds address of drone object
    fld dword [eax + DRONE_ALPHA]       ;stack is (buttom)betha|alpha(top)
;------------------Calculate gama-----------------------------

    mov eax, [TARGET_OBJECT]            
    fld dword [eax + TARGET_Y]          ;stack is (buttom)betha|alpha|target_y(top)
    mov eax, [ebp + FIRST_ARG]
    fld dword [eax + DRONE_Y]           ;stack is (buttom)betha|alpha|target_y|drone_y(top)
    fsub                  ;stack is (buttom)betha|alpha|drone_y-target_y(top)

    mov eax, [TARGET_OBJECT]            
    fld dword [eax + TARGET_X]  ;stack is (buttom)betha|alpha|target_y-drone_y|target_x(top)
    mov eax, [ebp + FIRST_ARG]
    fld dword [eax + DRONE_X]   ;stack is (buttom)betha|alpha|target_y-drone_y|target_x|drone_x(top)
    fsub 

                           ;stack is (buttom)betha|alpha|target_y-drone_y|drone_x-target_x(top)
    fpatan                       ;stack is (buttom)betha|alpha|gamma(top)

    fcomi st0, st1                      ;cmpare calculated gamma with alpha
    jb may_destroy.calculate_alpha_minus_gamma ;gamma is smaller

    sub esp,4                                    ; all we need to do is reverce
    fstp dword [esp] ;this is gamma
    sub esp,4
    fstp dword [esp]  ; this is alpha
    fld dword [esp + 4]
    fld dword [esp]
    add esp,4*2
    mov dword [GAMMA_IS_GREATER], 1

;------------------------------------------
.calculate_alpha_minus_gamma:

    fsub       ;bigger - smaller it is allways positive

    fldpi
    fcomip st0, st1      ;check if greater then pi to fix if needed and pop pi
    ja may_destroy.dont_fix
    fild dword [TWO]
    fldpi
    fmul
    fsub

.dont_fix: 
    fabs        ; abs(bigger - smaller)
    sub esp, 4*2
    fst qword [esp]
    push abs_gamma
    call printf
    add esp,4*3

    fcomi st0, st1  ;(buttom)betha|abs(bigger- smaller)(top)
    jnb may_destroy.exit_false ;if below we are ok
    jmp may_destroy.calculate_distance
;------------------Calculate distance-----------------------------
.calculate_distance:

    finit
    mov eax, [TARGET_OBJECT]
    fld dword [eax + TARGET_Y]

    mov eax, [ebp + FIRST_ARG]
    fld dword [eax + DRONE_Y]
    fsub

    sub esp,4
    fst dword [esp]
    fld dword [esp]
    add esp,4
    fmul


    mov eax, [TARGET_OBJECT]
    fld dword [eax + TARGET_X]

    mov eax, [ebp + FIRST_ARG]
    fld dword [eax + DRONE_X]
    fsub
    sub esp,4
    fst dword [esp]
    fld dword [esp]
    add esp,4
    fmul

    fadd
    fsqrt

    fild dword [KILL_RANGE]

    fcomi st0, st1 ;compare
    jb may_destroy.exit_false ;if below the range is to big
    


    push may_str
    call printf
    add esp,4

    mov eax, 1
    jmp may_destroy.exit

;-----------------------------------------------------------------



.exit_false:
    mov eax, 0
.exit:
    pop ebx
    mov esp, ebp
    pop ebp
    ret





