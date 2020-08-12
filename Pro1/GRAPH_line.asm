.text 0x0000
start:
addi $sp, $zero, 16384
addi $s3, $zero, 53248
lui $s4, 12  //s4 = 0x000C0000 vga_text
lui $s5,13
lui $s1,240
srl $s1,$s1,8 //s1 = F000,ps2-ascall list
addi $s2,$s1,0xF00 //s2 = FF00 number-ascall list


lui $a0,0x1010
ori $a0,$a0,0xF0F0
jal showLine

lui $a0,0x1010
ori $a0,$a0,0xF080 //0202 2020
lui $a1,0xF0F0
ori $a1,$a1,0x10F0 //2030 0230
jal showPol
j over

showPol:
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
add $t1,$zero,$a0
add $t2,$zero,$a1
add $a0,$zero,$t1
//add $t9,$zero,$a1
jal showLine
add $a0,$zero,$t2
jal showLine
srl $t3,$t1,16 //0202
andi $t1,$t1,0xFFFF //2020
srl $t4,$t2,16
andi $t2,$t2,0xFFFF
sll $t3,$t3,16
sll $t4,$t4,16
add $a0,$t3,$t2
jal showLine
add $a0,$t1,$t4
jal showLine
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

showLine:
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
and $t6,$a0,$t0 //t6 = y2
srl $a0,$a0,8
and $t5,$a0,$t0 //t5 = x2
srl $a0,$a0,8
and $t4,$a0,$t0 //t4 = y1
srl $a0,$a0,8
and $t3,$a0,$t0 //t3 = x1
beq $t6,$t4,Y_equal
sub $t2,$t5,$t3 //t2 = x2-x1
slt $t0,$t2,$zero
beq $t0,$zero,T2_big0
sub $t2,$zero,$t2
T2_big0:
sub $t1,$t6,$t4 //t1 = y2-y1
slt $t7,$t1,$zero
beq $t7,$zero,T1_big0
sub $t1,$zero,$t1
T1_big0:
div $t2,$t1
mflo $t8
andi $t8,$t8,0xFF
beq $t0,$t7,k_zheng
addi $t0,$zero,640
sub $t0,$t0,$t8
j k_next
k_zheng:
addi $t0,$zero,640
add $t0,$t0,$t8 //t0 = add per loop
j k_next
Y_equal:
addi $t0,$zero,1
k_next:
addi $t1,$zero,640
mult $t4,$t1
mflo $t4
add $t4,$t4,$t3 //t4 = address
//add $t4,$t4,$s5
mult $t6,$t1
mflo $t6
add $t6,$t6,$t5 //t6 = address
//add $t6,$t6,$s5
slt $t3,$t4,$t6
beq $t3,$zero,swap_xy
j swap_next
swap_xy:
add $t5,$t6,$zero
add $t6,$t4,$zero
add $t4,$t5,$zero
swap_next:
add $t5,$t4,$zero //t5 = t4
lui $t1,0xFF //color
Loop_showLine:
sll $t3,$t5,1
add $t3,$t3,$s5 //t3 = address
sw $t1,($t3)
add $t5,$t0,$t5
slt $t3,$t5,$t6
bne $t3,$zero,Loop_showLine

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
