# Programa 1: prueba de instrucciones del Cuadro 1 sin dependencias de datos cercanas.

addi x1, x0, 5
addi x2, x0, 3
addi x8, x0, 1
addi x9, x0, -8
addi x10, x0, 12
nop
nop
add x3, x1, x2
sub x4, x1, x2
sll x5, x2, x8
xor x6, x1, x2
srl x7, x10, x8
sra x11, x9, x8
or x12, x1, x2
and x13, x1, x2
addi x14, x1, 10
slli x15, x2, 2
xori x16, x1, 7
srli x17, x10, 2
srai x18, x9, 2
ori x19, x1, 8
andi x20, x10, 10
lui x21, 0x12345
nop
nop
sw x14, 0(x0)
lw x22, 0(x0)
beq x1, x2, fail
bne x1, x1, fail
blt x1, x2, fail
bge x2, x1, fail
jal x23, after_jal
addi x29, x0, 99
after_jal:
jalr x25, x0, done
addi x30, x0, 99
fail:
addi x31, x0, 0
done:
addi x31, x0, 1
nop
nop
nop
