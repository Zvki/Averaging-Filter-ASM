PUBLIC ApplyAverageFilter

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
    push rbx                ; Zapisujemy rejestry
    push rbp
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15

    ; Ustawienie stosu
    mov rbp, rsp

    ; Pobranie argumentów
    mov rsi, rcx            ; WskaŸnik na dane wejœciowe
    mov rdi, rdx            ; WskaŸnik na dane wyjœciowe
    mov r10, r8             ; Szerokoœæ obrazu
    mov r11, r9             ; Wysokoœæ obrazu
    mov eax, dword ptr [rbp+8] ; Promieñ filtru (radius)
    mov r12d, eax           ; Promieñ filtru

    ; Obliczenie wymiaru okna
    imul r12d, 2            ; Promieñ * 2
    add r12d, 1             ; (2*radius + 1)

    xor rbx, rbx            ; Licznik wierszy Y
OuterLoop:
    xor rcx, rcx            ; Licznik kolumn X

InnerLoop:
    ; Reset sum dla R, G, B i licznika pikseli
    xor r8, r8              ; Suma R
    xor r9, r9              ; Suma G
    xor r15, r15            ; Suma B
    xor r13, r13            ; Licznik pikseli

    ; Iteracja w oknie filtru
    mov r14, rbx            ; Start Y
    sub r14, r12            ; Y - radius (teraz oba operandy maj¹ ten sam rozmiar)

FilterLoopY:
    mov rdx, r14
    add rdx, r12            ; Y + radius (64-bitowy rejestr u¿yty zamiast 32-bitowego)
    cmp rdx, 0              ; SprawdŸ doln¹ granicê
    jl SkipRow
    cmp rdx, r11            ; SprawdŸ górn¹ granicê
    jge SkipRow

    mov r15, rcx            ; Start X
    sub r15, r12           ; X - radius

FilterLoopX:
    mov rdx, r15
    add rdx, r12           ; X + radius
    cmp rdx, 0              ; SprawdŸ lew¹ granicê
    jl SkipPixel
    cmp rdx, r10            ; SprawdŸ praw¹ granicê
    jge SkipPixel

    ; Obliczenie wskaŸnika do danych piksela
    mov rax, r14            ; Wiersz
    imul rax, r10           ; Wiersz * szerokoœæ
    add rax, r15            ; Kolumna
    imul rax, 3             ; Rozmiar piksela (RGB)

    ; Dodanie wartoœci R, G, B
    add r8b, byte ptr [rsi+rax]      ; Dodanie wartoœci R (8-bitowy rejestr)
    add r9b, byte ptr [rsi+rax+1]    ; Dodanie wartoœci G (8-bitowy rejestr)
    add r15b, byte ptr [rsi+rax+2]   ; Dodanie wartoœci B (8-bitowy rejestr)
    inc r13                         ; Licznik pikseli

SkipPixel:
    inc r15            ; Nastêpna kolumna w oknie
    cmp r15, rcx
    jl FilterLoopX

SkipRow:
    inc r14            ; Nastêpny wiersz w oknie
    cmp r14, rbx
    jl FilterLoopY

    ; Œrednia pikseli
    test r13, r13      ; Sprawdzenie liczby pikseli
    jz SkipWrite       ; Uniknij dzielenia przez 0

    mov eax, r8d       ; Suma R
    cdq                ; Przygotowanie do dzielenia
    idiv r13d          ; R = R / liczba pikseli
    imul rax, rcx, 3                ; rax = rcx * 3
    mov byte ptr [rdi+rax], al      ; Zapisz wartoœæ AL do adresu

    mov eax, r9d       ; Suma G
    cdq
    idiv r13d          ; G = G / liczba pikseli
    imul rax, rcx, 3             ; rax = rcx * 3
    mov byte ptr [rdi+rax+1], al ; Zapisz wartoœæ AL do adresu (przesuniêcie +1)

    mov eax, r15d      ; Suma B
    cdq
    idiv r13d          ; B = B / liczba pikseli
    imul rax, rcx, 3             ; rax = rcx * 3
    mov byte ptr [rdi+rax+2], al ; Zapisz wartoœæ AL pod adresem (rdi + rax + 2)

SkipWrite:
    inc rcx
    cmp rcx, r10
    jl InnerLoop

    inc rbx
    cmp rbx, r11
    jl OuterLoop

    ; Przywrócenie rejestrów
    mov rsp, rbp
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbp
    pop rbx

    ret
    
    ApplyAverageFilter endp

    END
