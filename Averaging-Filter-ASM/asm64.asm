PUBLIC ApplyAverageFilter

.DATA
input_data_pointer QWORD 0
output_data_pointer QWORD 0
widthk QWORD 0
height QWORD 0
radius DWORD 0
x DWORD 0
y DWORD 0
ky DWORD 0
kx DWORD 0
rSUM DWORD 0
gSUM DWORD 0
bSUM DWORD 0
count DWORD 0
nx DWORD 0
ny DWORD 0


.CODE


; Funkcja ApplyAverageFilter
; Argumenty:
; RCX - wskaŸnik na dane wejœciowego obrazu
; RDX - wskaŸnik na dane wyjœciowego obrazu
; R8  - szerokoœæ obrazu
; R9  - wysokoœæ obrazu
; Na stosie:
;  [rsp+8] - promieñ filtru (int)


ApplyAverageFilter proc
    mov input_data_pointer, rcx
    mov output_data_pointer, rdx
    mov widthk, r8
    mov height, r9
    mov eax, DWORD PTR [rsp+40]              ; Za³aduj promieñ filtru do eax
    mov radius, eax                           ; Zapisz promieñ filtru do zmiennej globalnej

loopY:
    mov eax, y
    cmp rax, height
    jge endloopY

    xor eax, eax
    mov x, eax
    loopX:
        mov eax, x
        cmp rax, widthk
        jge endloopX
        mov rSUM, 0
        mov gSUM, 0
        mov bSUM, 0
        mov count, 0

        xor eax, eax
        sub eax, radius
        mov ky, eax

        loopKY:
            mov eax, ky
            cmp eax, radius
            jg endloopKY

            xor eax, eax
            sub eax, radius
            mov kx, eax

            loopKX:
                mov eax, kx
                cmp eax, radius
                jg endloopKX
                ;------------------D
                mov eax, x
                mov ebx, kx
                add eax, ebx
                mov nx, eax
                
                
                mov eax, y
                mov ebx, ky
                add eax, ebx
                mov ny, eax

                cmp nx, 0
                jl IFniespelniony
                mov eax, nx
                cmp rax, widthk
                jge IFniespelniony

                cmp ny, 0
                jl IFniespelniony
                mov eax, ny
                cmp rax, height
                jge IFniespelniony

                ; Getpixel             ; pobiera zle wartosci pixeli, powinno pobieraæ wartosci pixeli zalezne od nx i ny
                mov rbx, [input_data_pointer]
                ;mov eax, [rbx]
                xor rax, rax
                xor rdx, rdx
                mov eax, nx
                imul eax, 4             ; moze nie dzialac ale powinno
                mov ecx, eax
                mov eax, ny
                mov rdx, widthk
                imul eax, edx
                imul eax, 4
                add eax, ecx
                mov eax, [rbx + rcx]
             

                ;mov eax, [rbx + 1024]           
                ;mov eax, [rbx + 4]
                ;mov eax, [rbx + 8]
                ;mov eax, [rbx + 12]
                ;mov eax, DWORD ptr [input_data_pointer]
                ;------------------)
    IFniespelniony:

                inc kx
                jmp loopKX
            endloopKX:
                   

        inc ky
        jmp loopKY
        endloopKY:
        
    inc x
    jmp loopX
    endloopX:
    
inc y
jmp loopY
endloopY:



    


    ret
    
    ApplyAverageFilter endp

    END
