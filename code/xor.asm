; Cache line size - 64 / 16 = unroll loop by factor of 4 with 4-wide SIMD
XORUnroll = 64

.data

.code


public          SSExor
SSExor          proc

    push rbx
    push rsi
    push rdi

    mov rsi, rcx
    mov rdi, rdx
    xor rdx, rdx
    test r8, r8
    je lbl2
    mov rbx, r8
    mov rax, r8
    and rax, XORUnroll-1
    shr rbx, 6                            ; how many iterations to SIMD todo: derive from XORUnroll
    je lbl1

  ; read one cacheline at a time
  align 16
  lbl0:
    movdqa xmm0, [rsi+rdx]                ; read the source
    movdqa xmm1, [rsi+rdx+16]             ; read the source
    movdqa xmm2, [rsi+rdx+32]             ; read the source
    movdqa xmm3, [rsi+rdx+48]             ; read the source

    pxor xmm0, [rdi+rdx]                  ; xor pad to source
    pxor xmm1, [rdi+rdx+16]               ; xor pad to source
    pxor xmm2, [rdi+rdx+32]               ; xor pad to source
    pxor xmm3, [rdi+rdx+48]               ; xor pad to source

    movntdq [rsi+rdx],    xmm0            ; write result back to source
    movntdq [rsi+rdx+16], xmm1            ; write result back to source
    movntdq [rsi+rdx+32], xmm2            ; write result back to source
    movntdq [rsi+rdx+48], xmm3            ; write result back to source

    add rdx, XORUnroll
    sub rbx, 1
    jnz lbl0

    cmp r8, rdx
    je lbl2
    sub r8, rdx
    mov rax, r8

  align 4
  lbl1:
    ; Non mod 64 bytes
    movzx ecx, BYTE PTR [rdi+rdx]
    xor [rsi+rdx], cl
    add edx, 1
    sub rax, 1
    jnz lbl1

  lbl2:
    ; exit
    pop rdi
    pop rsi
    pop rbx
    ret

SSExor endp

public              SSEIsAllZero
SSEIsAllZero        proc
    push rbx
    push rdi
    push rsi

    xor rdi, rdi
    xor rsi, rsi

    xor rax, rax
    mov rbx, rdx
    mov rsi, rdx
    and rsi, XORUnroll-1
    shr rbx, 6                            ; how many iterations to SIMD todo: derive from XORUnroll
    je lbl1

  ; read one cacheline at a time
  align 16
  lbl0:
    movdqa xmm0, [rcx+rdi]                ; read the source
    movdqa xmm1, [rcx+rdi+16]             ; read the source
    movdqa xmm2, [rcx+rdi+32]             ; read the source
    movdqa xmm3, [rcx+rdi+48]             ; read the source

    orpd xmm0, xmm1
    orpd xmm2, xmm3
    orpd xmm0, xmm2
    ptest xmm0, xmm0

    jne lbl2

    add rdi, XORUnroll
    sub rbx, 1
    jnz lbl0

  align 4
  lbl1:
    ; Non mod 64 bytes
    mov bl, byte ptr[rcx+rdi]
    test bl, bl
    jne lbl2
    sub rsi, 1
    jnz lbl1

    mov rax, 1

  lbl2:
    ; exit
    pop rsi
    pop rdi
    pop rbx
    ret

SSEIsAllZero        endp

end
