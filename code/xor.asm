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
    shr rbx, 6                            ; int divide ln by XORUnroll
    je lbl1

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
    movzx ecx, BYTE PTR [rdi+rdx]
    xor [rsi+rdx], cl
    add edx, 1
    sub rax, 1
    jnz lbl1

  lbl2:
    pop rdi
    pop rsi
    pop rbx
    ret

SSExor endp

end
