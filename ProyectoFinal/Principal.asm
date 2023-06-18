section .data
    ; Constantes
    SYS_exit equ 60
    SYS_read equ 0
    SYS_open equ 2
    SYS_close equ 3
    O_RDONLY equ 0
    BUFF_SIZE equ 255

    matrix db 46, 35, 12, 1, 12, 44, 4, 24, 84, 3, 13
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

    numRows dw 11
    numCols dw 11
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

section .bss
    printBuf resb 11
    counts resb 256
    buffer resb 10

section .text
    global _start
    
_start:
   

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


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
calculateMean:
  ; Get a pointer to the start of the matrix
  mov rdi, matrix

  ; Get the number of elements
  mov ecx, matrix_length

  ; Initialize rowIndex to 0
  xor esi, esi

calculateMean_loop:
  ; Initialize sum to 0
  xor eax, eax

  ; Initialize counter to numCols
movzx edx, word [numCols]


calculateMean_inner_loop:
  ; Add the current element to the sum
  movzx ebx, byte [rdi]  ; Load the current value (and extend from byte to dword)
  add eax, ebx  ; Add the current value to the sum

  ; Move to the next element
  inc rdi

  ; Decrease the counter
  dec edx

  ; If there are more elements in this row, loop again
  jnz calculateMean_inner_loop

  ; At this point, eax contains the sum of one row
  ; Now we need to divide by the number of elements in the row

  ; Divide the sum by the number of elements
  movzx ecx, word [numCols]  ; Number of elements in the row
  cdq  ; Extend the sign for division
  idiv ecx  ; Divide EDX:EAX by ECX, result in EAX

  ; At this point, eax contains the mean of the row (rounded down to the nearest whole number)
  ; TODO: Do something with eax (e.g., print it, store it, etc.)

  ; Increase the row index
  inc esi

  ; If there are more rows, loop again
  movzx edx, word [numRows]
  cmp esi, edx
  jl calculateMean_loop

  ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

calculateMedian:
; Get a pointer to the start of the matrix
  mov rdi, matrix

  ; Initialize rowIndex to 0
  xor esi, esi

calculateMedian_loop:
  ; Initialize the row pointer
  mov rdx, rdi

  ; Start the outer loop
  outerLoop:
    ; Initialize a flag to 0
    xor ebx, ebx

    ; Start the inner loop
    innerLoop:
      ; Get the current element and the next one
      movzx ecx, byte [rdx]  ; Current element
      movzx eax, byte [rdx+1]  ; Next element

      ; Compare the two elements
      cmp ecx, eax

      ; If the current element is greater than the next one, swap them and set the flag to 1
      jle continueLoop

      mov byte [rdx], al
      mov byte [rdx+1], cl
      mov ebx, 1

    continueLoop:
      ; Move to the next pair of elements
      inc rdx

      ; If there are more pairs of elements in this row, loop again
      mov eax, numCols
      add eax, edi
      dec eax
      cmp edx, eax
      jl innerLoop

    ; If we made a swap, run the outer loop again
    cmp ebx, 1
    je outerLoop

  ; Calculate the median
  ; If numCols is odd
  cmp byte [numCols], 1
  jne even
odd:
  ; Median is the middle element
  mov eax, numCols
shr eax, 1 ; divide por 2
add eax, edi ; suma la base del array
movzx ebx, byte [eax] ; obtén el elemento en el medio

  jmp printMedian
even:
  ; Median is the average of the two middle elements
  mov eax, numCols
  shr eax, 1 ; divide por 2
  add eax, edi ; suma la base del array
  movzx ebx, byte [eax - 1] ; obtén el elemento en el medio - 1

  mov eax, numCols
  shr eax, 1 ; divide por 2
  add eax, edi ; suma la base del array
  movzx ecx, byte [eax] ; obtén el elemento en el medio

  add ebx, ecx
  shr ebx, 1


printMedian:
  ; Convert the median value to a string
  mov edi, printBuf + 10
  mov byte [edi], 0
  mov eax, ebx
print_loop:
  xor edx, edx
  mov ecx, 10
  div ecx
  add dl, "0"
  dec edi
  mov [edi], dl
  test eax, eax
  jnz print_loop

  ; Print the string
  mov eax, 1  ; sys_write
  mov edi, 1  ; file descriptor (stdout)
  mov esi, edi
  mov rdi, printBuf + 10
  sub rdx, rsi
  syscall

  ; Move to the start of the next row
  add rdi, numCols

  ; Increase the row index
  inc esi

  ; If there are more rows, loop again
  cmp esi, numRows
  jl calculateMedian_loop

  ret
  

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

calculateMode:
  ; Get a pointer to the start of the matrix
  mov rdi, matrix

  ; Initialize rowIndex to 0
  xor esi, esi

calculateMode_loop:
  ; Initialize counts array to 0
  ; Assuming counts is a 256-byte array in .bss section
  mov edi, counts
  mov ecx, 256
  xor eax, eax
  rep stosb

  ; Initialize counter to numCols
  movzx edx, word [numCols]

  ; Get a pointer to the start of the row
  push rdi

calculateMode_inner_loop:
  ; Increase the count for the current value
  movzx eax, byte [rdi]
  inc byte [counts + rax]

  ; Move to the next element
  inc rdi

  ; Decrease the counter
  dec edx

  ; If there are more elements in this row, loop again
  jnz calculateMode_inner_loop

  ; At this point, counts array contains the count of each value in the row
  ; Now we need to find the maximum count

  ; Initialize mode and maxCount to 0
  xor eax, eax  ; mode
  xor ebx, ebx  ; maxCount

  ; Initialize counter to 256
  mov ecx, 256

findMode_loop:
  ; If the count for this value is greater than maxCount
  cmp byte [counts + ecx - 1], bl
  jle nextValue

  ; Update mode and maxCount
  mov al, cl
  dec al
  mov bl, byte [counts + ecx - 1]

nextValue:
  ; Decrease the counter
  dec ecx

  ; If there are more values, loop again
  jnz findMode_loop

  ; At this point, eax contains the mode of the row
  ; TODO: Do something with eax (e.g., print it, store it, etc.)

  ; Restore the pointer to the start of the row
  pop rdi

  ; Move to the start of the next row
  add rdi, numCols

  ; Increase the row index
  inc esi

  ; If there are more rows, loop again
  cmp esi, numRows
  jl calculateMode_loop

  ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

calculateStdDev:
  ; Get a pointer to the start of the matrix
  mov rdi, matrix

  ; Initialize rowIndex to 0
  xor esi, esi

calculateStdDev_loop:
  ; Initialize sum to 0
  xor eax, eax

  ; Initialize counter to numCols
  movzx ecx, word [numCols]

calculateStdDev_inner_loop1:
  ; Add the current element to the sum
  movzx ebx, byte [rdi]  ; Load the current value (and extend from byte to dword)
  add eax, ebx  ; Add the current value to the sum

  ; Move to the next element
  inc rdi

  ; Decrease the counter
  dec ecx

  ; If there are more elements in this row, loop again
  jnz calculateStdDev_inner_loop1

  ; Calculate the mean
  movzx ecx, word [numCols]  ; Number of elements in the row
  cdq  ; Extend the sign for division
  idiv ecx  ; Divide EDX:EAX by ECX, result in EAX

  ; Store the mean
  mov ebx, eax

  ; Initialize sum of squares to 0
  xor eax, eax

  ; Get a pointer to the start of the row
  sub rdi, numCols

  ; Initialize counter to numCols
  movzx ecx, word [numCols]

calculateStdDev_inner_loop2:
  ; Subtract the mean from the current element, square the result, and add it to the sum
  movzx edx, byte [rdi]  ; Load the current value (and extend from byte to dword)
  sub edx, ebx
  imul edx, edx
  add eax, edx  ; Add the squared result to the sum

  ; Move to the next element
  inc rdi

  ; Decrease the counter
  dec ecx

  ; If there are more elements in this row, loop again
  jnz calculateStdDev_inner_loop2

  ; At this point, eax contains the sum of the squares of the deviations from the mean
  ; Now we need to divide by the number of elements

  ; Divide the sum by the number of elements
  movzx ecx, word [numCols]  ; Number of elements in the row
  cdq  ; Extend the sign for division
  idiv ecx  ; Divide EDX:EAX by ECX, result in EAX

  ; At this point, eax contains the variance of the row
  ; TODO: Calculate the square root of eax (e.g., using a library or manual implementation)

  ; TODO: Do something with the standard deviation (e.g., print it, store it, etc.)

  ; Increase the row index
  inc esi

  ; If there are more rows, loop again
  cmp esi, numRows
  jl calculateStdDev_loop

  ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

calculateVariance:
  ; Get a pointer to the start of the matrix
  mov rdi, matrix

  ; Initialize rowIndex to 0
  xor esi, esi

calculateVariance_loop:
  ; Initialize sum to 0
  xor eax, eax

  ; Initialize counter to numCols
  movzx ecx, word [numCols]

calculateVariance_inner_loop1:
  ; Add the current element to the sum
  movzx ebx, byte [rdi]  ; Load the current value (and extend from byte to dword)
  add eax, ebx  ; Add the current value to the sum

  ; Move to the next element
  inc rdi

  ; Decrease the counter
  dec ecx

  ; If there are more elements in this row, loop again
  jnz calculateVariance_inner_loop1

  ; Calculate the mean
  movzx ecx, word [numCols]  ; Number of elements in the row
  cdq  ; Extend the sign for division
  idiv ecx  ; Divide EDX:EAX by ECX, result in EAX

  ; Store the mean
  mov ebx, eax

  ; Initialize sum of squares to 0
  xor eax, eax

  ; Get a pointer to the start of the row
  sub rdi, numCols

  ; Initialize counter to numCols
  movzx ecx, word [numCols]

calculateVariance_inner_loop2:
  ; Subtract the mean from the current element, square the result, and add it to the sum
  movzx edx, byte [rdi]  ; Load the current value (and extend from byte to dword)
  sub edx, ebx
  imul edx, edx
  add eax, edx  ; Add the squared result to the sum

  ; Move to the next element
  inc rdi

  ; Decrease the counter
  dec ecx

  ; If there are more elements in this row, loop again
  jnz calculateVariance_inner_loop2

  ; At this point, eax contains the sum of the squares of the deviations from the mean
  ; Now we need to divide by the number of elements

  ; Divide the sum by the number of elements
  movzx ecx, word [numCols]  ; Number of elements in the row
  cdq  ; Extend the sign for division
  idiv ecx  ; Divide EDX:EAX by ECX, result in EAX

  ; TODO: Do something with the variance (e.g., print it, store it, etc.)

  ; Increase the row index
  inc esi

  ; If there are more rows, loop again
  cmp esi, numRows
  jl calculateVariance_loop

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
    ; Read input from user into buffer
    mov eax, 0  ; syscall number (sys_read)
    mov edi, 0  ; file descriptor (stdin)
    mov rsi, buffer  ; buffer address
    mov rdx, 10  ; buffer size
    syscall  ; call kernel

    ; Convert buffer to integer
    mov rdi, buffer
    xor eax, eax  ; Clear eax to store result

readInt_loop:
    movzx ebx, byte [rdi]  ; Load current character (extended from byte to dword)
    cmp bl, 0Ah  ; If character is newline or null, end loop
    je readInt_done
    sub ebx, '0'  ; Convert from ASCII to numeric value
    imul eax, 10  ; Multiply current result by 10
    add eax, ebx  ; Add new digit
    inc rdi  ; Move to next character
    jmp readInt_loop

readInt_done:
    ret
