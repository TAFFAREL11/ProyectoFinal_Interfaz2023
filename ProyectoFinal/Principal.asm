section .data
    ; Constantes
    SYS_exit equ 60
    SYS_read equ 0
    SYS_open equ 2
    SYS_close equ 3
    O_RDONLY equ 0
    BUFF_SIZE equ 255

    matrixFile db 46, 35, 12, 1, 12, 44, 4, 24, 84, 3, 13
               db 36, 78, 97, 17, 64, 47, 85, 28, 64, 22, 74
               db 86, 77, 37, 39, 30, 68, 89, 66, 39, 15, 25
               db 43, 45, 17, 91, 91, 82, 83, 52, 45, 29, 23
               db 46, 34, 6, 52, 82, 8, 49, 65, 13, 13, 35
               db 7, 78, 5, 42, 69, 85, 69, 6, 24, 41, 40
               db 83, 18, 25, 51, 33, 68, 47, 7, 4, 41, 66
               db 99, 89, 60, 4, 5, 14, 89, 22, 28, 18, 59
               db 93, 4, 67, 74, 42, 60, 49, 33, 62, 83, 82
               db 77, 31, 40, 77, 97, 72, 54, 71, 26, 45, 82
               db 74, 88, 23, 97, 91, 21, 75, 82, 36, 24, 15
    numRows dw 0
    numCols dw 0
    matrix_length db 121  ; Maximum size of the matrix is 11x11
    readBuffer times BUFF_SIZE db 0 ; Asegúrate de que BUFF_SIZE está definido

    ; Menu options
    menuPrompt db "Select an operation:", 
    menuOptions db "1 - Calculate mean", 10, 0
                db "2 - Calculate median", 10, 0
                db "3 - Calculate mode", 10, 0
                db "4 - Calculate standard deviation", 10, 0
                db "5 -  Calculate variance", 10, 0
                db "6 - Exit", 10, 0
menuSize equ $ - menuOptions   ; Calculate the length of menuOptions


    invalidOptionMsg db "Invalid option! Please try again.", 0
    fileDesc dq 0

section .text
    global _start
    
_start:
    ; Read the matrix from a file
    call readMatrixFromFile

    ; Main loop
mainLoop:
    ; Display menu options
    call printMenu

    ; Read user's choice
    call readInt
    cmp eax, 1
    jl invalidOption
    cmp eax, 6
    jg invalidOption

    ; Perform the selected operation
    cmp eax, 1
    je calculateMean
    cmp eax, 2
    je calculateMedian
    cmp eax, 3
    je calculateMode
    cmp eax, 4
    je calculateStdDev
    cmp eax, 5
    je calculateVariance
    cmp eax, 6
    je exitProgram

    ; Invalid option
invalidOption:
    ; Display error message
    mov rdi, invalidOptionMsg
    jmp mainLoop

readMatrixFromFile:
    ; Open the file
    mov rax, SYS_open
    mov rdi, matrixFile
    mov rsi, O_RDONLY
    syscall

    ; Check if the file opened successfully
    cmp rax, 0
    jl errorOpenFile
    mov [fileDesc], rax

    ; Read the file
    mov rax, SYS_read
    mov rdi, [fileDesc]
    mov rsi, readBuffer
    mov rdx, BUFF_SIZE
    syscall

    ; Check if the read was successful
    cmp rax, 0
    jl errorReadFile

    ; Process the read data from readBuffer here

    ; Close the file
    mov rax, SYS_close
    mov rdi, [fileDesc]
    syscall

    ret

errorOpenFile:
    ; Handle file open error here
    ret

errorReadFile:
    ; Handle file read error here
    ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calculateMean:
    ; Implementation of mean calculation goes here
    ret

calculateMedian:
    ; Implementation of median calculation goes here
    ret

calculateMode:
    ; Implementation of mode calculation goes here
    ret

calculateStdDev:
    ; Implementation of standard deviation calculation goes here
    ret

calculateVariance:
    ; Implementation of variance calculation goes here
    ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    

exitProgram:
    ; Exit the program
    mov eax, SYS_exit
    xor edi, edi
    syscall

printMenu:
    ; Compute the length of the string
    mov rdi, menuOptions
    sub rdi, 1
    len_loop:
        inc rdi
        cmp byte [rdi], 0
        jne len_loop
    sub rdi, menuOptions

    ; Write the string
    mov rax, 1 ; syscall number (sys_write)
    mov rdi, 1 ; file descriptor (stdout)
    mov rsi, menuOptions ; message address
    mov rdx, menuSize ; message length
    syscall ; call kernel

    jmp exitProgram

readInt:
    ; Implementation of reading an integer goes here
    ; ret
