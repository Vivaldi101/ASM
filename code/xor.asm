; Cache line size - 64 / 16 = unroll loop by factor of 4 with 4-wide SIMD
XORUnroll = 64
XORIterations = 6

.data

.code


public          SSEXor
SSEXor          proc

    push rbx
    push rsi
    push rdi

    mov rsi, rcx    ; source
    mov rdi, rdx    ; pad

    xor rdx, rdx
    test r8, r8
    je lbl2                 ; exit if zero length
    mov rbx, r8
    mov rax, r8
    and rax, XORUnroll-1    ; left-overs
    shr rbx, XORIterations  ; how many 64 wide iterations to do
    je lbl1

  ; read one cacheline at a time
  lbl0:
    vmovaps zmm0, [rsi+rdx]         ; read the source

    vxorps zmm0, zmm0, [rdi+rdx]    ; xor pad to source

    vmovaps [rsi+rdx], zmm0         ; write result back to source

    add rdx, XORUnroll
    sub rbx, 1
    jne lbl0                        ; all 64 wide iterations done

    cmp r8, rdx                     ; left-overs
    je lbl2

  lbl1:
    ; non mod 64 bytes
    mov cl, BYTE PTR [rdi+rdx]
    xor [rsi+rdx], cl
    add rdx, 1
    sub rax, 1
    jne lbl1

  lbl2:
    ; exit

    pop rdi
    pop rsi
    pop rbx

    ret

SSEXor endp

public              SSEIsAllZero
SSEIsAllZero        proc
    push rbx
    push rdi
    push rsi

    xor rdi, rdi
    xor rsi, rsi
    xor rax, rax                          ; all is not zero by default

    mov rbx, rdx
    mov rsi, rdx
    and rsi, XORUnroll-1
    shr rbx, XORIterations
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
    jne lbl0

  align 4
  lbl1:
    ; Non mod 64 bytes
    mov bl, byte ptr[rcx+rdi]
    test bl, bl
    jne lbl2
    sub rsi, 1
    jne lbl1

    mov rax, 1                          ; all is zero

  lbl2:
    ; exit
    pop rsi
    pop rdi
    pop rbx
    ret

SSEIsAllZero        endp

end
