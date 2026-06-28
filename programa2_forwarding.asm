# Programa 2: dependencias RAW que deben resolverse con forwarding.

addi x1, x0, 5
addi x2, x0, 7
add x3, x1, x2
add x4, x3, x2
sub x5, x4, x1
sw x5, 4(x0)
addi x31, x0, 1
nop
nop
nop
