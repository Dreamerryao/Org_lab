.text 0x0000
start:
addi $sp, $zero, 16384
addi $s3, $zero, 53248
lui $s4, 12  //s4 = 0x000C0000 vga_text
lui $s5,13
lui $s1,240
srl $s1,$s1,8 //s1 = F000,ps2-ascall list
addi $s2,$s1,0xF00 //s2 = FF00 number-ascall list

add $a0,$zero,$zero
ori $a0,$a0,0xF0A0
addi $a1,$zero,0x40
jal showCircle

j over
showCircle:
addi $sp,$sp,65496
sw $t0,($sp)
sw $t1,4($sp)
sw $t2,8($sp)
sw $t3,12($sp)
sw $t4,16($sp)
sw $t5,20($sp)
sw $t6,24($sp)
sw $t7,28($sp)
sw $t8,32($sp)
sw $ra,36($sp)

addi $t0,$zero,255
and $t2,$a0,$t0 //t2 = y
srl $a0,$a0,8
and $t1,$a0,$t0 //t1 = x
srl $a0,$a0,8
sub $t3,$t1,$a1 //t3 = x-r
add $t4,$t1,$a1 //t4 = x+r
sub $t5,$t2,$a1
add $t6,$t2,$a1
mult $a1,$a1
mflo $a1
Loop_wai:

add $t7,$zero,$t5
Loop_nei:
//t3,t7 t1,t2 distance
sub $s6,$t3,$t1
slt $t0,$s6,$zero
beq $t0,$zero,S6_big0
sub $s6,$zero,$s6
S6_big0:
sub $s7,$t7,$t2
slt $t0,$s7,$zero
beq $t0,$zero,S7_big0
sub $s7,$zero,$s7
S7_big0:
mult $s6,$s6
mflo $s6
mult $s7,$s7
mflo $s7
add $t8,$s7,$s6
slt $t0,$t8,$a1
beq $t0,$zero,circle_failed
add $a0,$zero,$zero
add $a0,$zero,$t3
sll $a0,$a0,8
add $a0,$a0,$t7
jal showPoint
circle_failed:
addi $t7,$t7,1
slt $t0,$t7,$t6
bne $t0,$zero,Loop_nei

addi $t3,$t3,1
slt $t0,$t3,$t4
bne $t0,$zero,Loop_wai

lw $t0,($sp)
lw $t1,4($sp)
lw $t2,8($sp)
lw $t3,12($sp)
lw $t4,16($sp)
lw $t5,20($sp)
lw $t6,24($sp)
lw $t7,28($sp)
lw $t8,32($sp)
lw $ra,36($sp)
addi $sp,$sp,40
jr $ra


showPoint:
addi $sp,$sp,65496
sw $t0,($sp)
sw $t1,4($sp)
sw $t2,8($sp)
sw $t3,12($sp)
sw $t4,16($sp)
sw $t5,20($sp)
sw $t6,24($sp)
sw $t7,28($sp)
sw $t8,32($sp)
sw $ra,36($sp)
add $v0,$zero,$zero
add $t1,$zero,$zero
add $t2,$zero,$zero
addi $t0,$zero,255
and $t0,$a0,$t0 //t0 = y
srl $a0,$a0,8 //a0 = x
addi $t3,$zero,640
mult $t0,$t3
mflo $t3
add $t2,$t3,$a0
sll $t2,$t2,1
add $t2,$s5,$t2
lui $t5,0xFF
sw $t5,($t2)
lw $t0,($sp)
lw $t1,4($sp)
lw $t2,8($sp)
lw $t3,12($sp)
lw $t4,16($sp)
lw $t5,20($sp)
lw $t6,24($sp)
lw $t7,28($sp)
lw $t8,32($sp)
lw $ra,36($sp)
addi $sp,$sp,40
jr $ra

over:
add $zero,$zero,$zero