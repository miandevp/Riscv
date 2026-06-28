# Programa 3: dependencia load-use que debe insertar un stall.

addi x1, x0, 21
nop
nop
sw x1, 0(x0)
lw x2, 0(x0)
add x3, x2, x2
addi x4, x3, 1
add x5, x4, x3
addi x31, x0, 1
nop
nop
nop
