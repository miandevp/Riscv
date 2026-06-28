# Programa 4: control hazards que deben resolverse con flushing.

addi x1, x0, 5
addi x2, x0, 5
nop
nop
beq x1, x2, target_branch
addi x20, x0, 99
addi x21, x0, 88
target_branch:
jal x0, after_jal
addi x22, x0, 77
addi x23, x0, 66
after_jal:
addi x31, x0, 1
nop
nop
nop
