.text 0x0000
start:
addi $sp, $zero, 16384
addi $s3, $zero, 53248
lui $s4, 12  //s4 = 0x000C0000 vga_text
lui $s5,13 //s5  = D0000 vga_graph
lui $s1,240
srl $s1,$s1,8 //s1 = F000,ps2-ascall list
addi $s2,$s1,0xF00 //s2 = FF00 number-ascall list
clear: //clear the vga
addi $t0,$zero,1887 //"_"
add $t9,$zero,$zero //t9:address of cursor
//addi $t2,$zero,1837  //t2 = "-" for debug
addi $t3,$zero,9596
sw $t0,($s4) //first "_"
add $t0,$zero,$zero
//loop_clear: //loop for clear
//addi $t0,$t0,4
//add $t1,$t0,$s4
////sw $t2,($t1)
//sw $zero,($t1)
//bne $t0,$t3,loop_clear
//graph
addi $a0,$zero,0x4687
jal showPoint
lui $a0,0x2020
ori $a0,$a0,0xE0E0
jal showLine
lui $a0,0x1010
ori $a0,$a0,0xF080 //0202 2020
lui $a1,0xF0F0
ori $a1,$a1,0x10F0 //2030 0230
jal showPol

add $a0,$zero,$zero
add $a1,$zero,$zero
ori $a0,$a0,0xFF80
addi $a1,$zero,0x20
jal showCircle

//text
show: // read data from ps2
jal dataProcess //function move and read data from ps2
add $a0,$zero,$t9
jal showRegister //show one register
add $a0,$zero,$s1
//addi $a0,$zero,64512
jal showMemory //show memory S1
addi $a0,$zero,64512 //FFFF FC00 ->button adress
jal showButton //show button
addi $a0,$zero,0xF0
jal Todecimal//binary to decimal
addi $a0,$zero,0x42
jal showAscll //show Ascall
beq $v0,$zero,show

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
addi $sp,$sp,65500
sw $t0,($sp)
sw $t1,4($sp)
sw $t2,8($sp)
sw $t3,12($sp)
sw $t4,16($sp)
sw $t5,20($sp)
sw $t6,24($sp)
sw $t7,28($sp)
sw $t8,32($sp)
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
addi $sp,$sp,36
jr $ra


showButton:
lw $a0,($a0)
add $v0,$zero,$zero
addi $t0,$zero,0x2500
add $t0,$s4,$t0 //t0 = target address
addi $t0,$t0,32
addi $t6,$zero,0xF //t6 = 0xF
and $t5,$a0,$t6 //t5 = number
add $t7,$zero,$zero
Loop_findList_button:
add $t8,$t7,$s2 //t8 = address
lw $t2,($t8)//t2 ->word
srl $t1,$t2,8
beq $t1,$t5,findNum_success_button
addi $t7,$t7,4
j Loop_findList_button
findNum_success_button:
andi $t2,$t2,0xFF
addi $t2,$t2,24832
sw $t2,($t0)

jr $ra


showAscll: //show $a0 ->ascall
add $v0,$zero,$zero
addi $t0,$zero,0x24B4
add $t0,$s4,$t0
addi $t2,$zero,127
and $t2,$a0,$t2 //t2 = ascll
addi $t2,$t2,22272
sw $t2,($t0)
jr $ra

Todecimal:
add $v0,$zero,$zero
addi $t0,$zero,0x2474
add $t1,$zero,$zero
add $t0,$s4,$t0 //t0 = target address
Loop_thousand:
slti $t2,$a0,1000
bne $t2,$zero,Loop_hundred
addi $a0,$a0,64536
addi $t1,$t1,0x1000
j Loop_thousand
Loop_hundred:
slti $t2,$a0,100
bne $t2,$zero,Loop_ten
addi $a0,$a0,65436
addi $t1,$t1,0x100
j Loop_hundred
Loop_ten:
slti $t2,$a0,10
bne $t2,$zero,Loop_one
addi $a0,$a0,65526
addi $t1,$t1,0x10
j Loop_ten
Loop_one:
slti $t2,$a0,1
bne $t2,$zero,next_decimal
addi $a0,$a0,65535
addi $t1,$t1,0x1
j Loop_one
next_decimal:
add $a0,$zero,$t1
add $t4,$zero,$zero //t4 = counter for Loop
addi $t6,$zero,0xF //t6 = 0xF
Loop_decimal:
and $t5,$a0,$t6 //t5 = number
add $t7,$zero,$zero
Loop_findList_dec:
add $t8,$t7,$s2 //t8 = address
lw $t2,($t8)//t2 ->word
srl $t1,$t2,8
beq $t1,$t5,findNum_success_dec
addi $t7,$t7,4
j Loop_findList_dec
findNum_success_dec:
andi $t2,$t2,0xFF
addi $t2,$t2,24832
sw $t2,($t0)
addi $t0,$t0,65532
addi $t4,$t4,1
slti $t3,$t4,8
srl $a0,$a0,4
bne $t3,$zero,Loop_decimal
jr $ra

showMemory:
lw $a0,($a0)
add $v0,$zero,$zero
addi $t0,$zero,0x2370
add $t0,$s4,$t0 //t0 = target address
addi $t0,$t0,32
add $t4,$zero,$zero //t4 = counter for Loop
addi $t6,$zero,0xF //t6 = 0xF
Loop_showMemory:
and $t5,$a0,$t6 //t5 = number
add $t7,$zero,$zero
Loop_findList_mem:
add $t8,$t7,$s2 //t8 = address
lw $t2,($t8)//t2 ->word
srl $t1,$t2,8
beq $t1,$t5,findNum_success_mem
addi $t7,$t7,4
j Loop_findList_mem
findNum_success_mem:
andi $t2,$t2,0xFF
addi $t2,$t2,24832
sw $t2,($t0)
addi $t0,$t0,65532
addi $t4,$t4,1
slti $t3,$t4,8
srl $a0,$a0,4
bne $t3,$zero,Loop_showMemory
jr $ra

showRegister:
add $v0,$zero,$zero
addi $t0,$zero,0x2230
add $t0,$s4,$t0 //t0 = target address
addi $t3,$zero,28928
addi $t3,$t3,0x74
sw $t3,($t0)
addi $t0,$t0,4
addi $t3,$zero,28928
addi $t3,$t3,0x39
sw $t3,($t0)
addi $t0,$t0,4
addi $t3,$zero,28928
addi $t3,$t3,0x3A
sw $t3,($t0)
addi $t0,$t0,32
add $t4,$zero,$zero //t4 = counter for Loop
addi $t6,$zero,0xF //t6 = 0xF
Loop_showRegister:
and $t5,$a0,$t6 //t5 = number
add $t7,$zero,$zero
Loop_findList:
add $t8,$t7,$s2 //t8 = address
lw $t2,($t8)//t2 ->word
srl $t1,$t2,8
beq $t1,$t5,findNum_success
addi $t7,$t7,4
j Loop_findList
findNum_success:
andi $t2,$t2,0xFF
addi $t2,$t2,28928
sw $t2,($t0)
addi $t0,$t0,65532
addi $t4,$t4,1
slti $t3,$t4,8
srl $a0,$a0,4
bne $t3,$zero,Loop_showRegister
jr $ra

dataProcess:
addi $sp,$sp,65524
sw $t0,($sp)
sw $t1,4($sp)
sw $t3,8($sp)
add $v0,$zero,$zero
lw $t3,($s3)
lui $t0,32768
and $t1,$t3,$t0
bne $t1,$t0,over
readData:
addi $t0,$zero,255
and $t3,$t3,$t0
addi $t0,$zero,240
beq $t3,$t0,ToF0
addi $t0,$zero,224
beq $t3,$t0,ToE0
addi $t0,$zero,0x75 //up button
beq $t3,$t0,Up
addi $t0,$zero,0x72 //down button
beq $t3,$t0,Down
addi $t0,$zero,0x74 //right button
beq $t3,$t0,Right
addi $t0,$zero,0x6B //left button
beq $t3,$t0,Left
addi $t0,$zero,0x5A //enter button
beq $t3,$t0,Enter
addi $t0,$zero,0x7D //pageup
beq $t3,$t0,PageUp
addi $t0,$zero,0x7A //pagedown
beq $t3,$t0,PageDown
addi $t0,$zero,0x6C //home
beq $t3,$t0,CLEAR
j print
CLEAR: //clear the vga
addi $t0,$zero,1887 //"_"
add $t9,$zero,$zero //t9:address of cursor
//addi $t2,$zero,1837  //t2 = "-" for debug
addi $t3,$zero,9596
sw $t0,($s4) //first "_"
add $t0,$zero,$zero
loop_CLEAR: //loop for clear
addi $t0,$t0,4
add $t1,$t0,$s4
//sw $t2,($t1)
sw $zero,($t1)
bne $t0,$t3,loop_CLEAR
j over
PageUp:
add $t0,$zero,$zero
addi $t1,$zero,0x2080
Loop_pageup:
add $t6,$t0,$s4 //t2 = address
addi $t2,$t6,320
lw $t4,($t2)
sw $t4,($t6)
addi $t0,$t0,4
bne $t0,$t1,Loop_pageup
addi $t1,$zero,0x21BC
Loop_zero_up:
add $t6,$t0,$s4 //t2 = address
sw $zero,($t6)
addi $t0,$t0,4
bne $t0,$t1,Loop_zero_up
addi $t9,$t9,65216
j over
PageDown:
addi $t0,$zero,0x207C
add $t1,$zero,$zero
Loop_pagedown:
add $t6,$t0,$s4 //t2 = address
addi $t2,$t6,320
lw $t4,($t6)
sw $t4,($t2)
addi $t0,$t0,65532
bne $t0,$t1,Loop_pagedown
add $t6,$t0,$s4 //t2 = address
addi $t2,$t6,320
lw $t4,($t6)
sw $t4,($t2)
addi $t0,$zero,316
add $t1,$zero,$zero
Loop_zero_down:
add $t6,$t0,$s4 //t2 = address
sw $zero,($t6)
addi $t0,$t0,65532
bne $t0,$t1,Loop_zero_down
add $t6,$t0,$s4 //t2 = address
sw $zero,($t6)
addi $t9,$t9,320
j over
Up:
slti $t0,$t9,80
beq $t0,$zero,up_next
j over
up_next:
add $t0,$s4,$t9 //compute address
sw $zero,($t0)
addi $t9,$t9,65216
add $t0,$s4,$t9
addi $t1,$zero,1887
sw $t1,($t0)
j over
Down:
slti $t0,$t9,9276
bne $t0,$zero,down_next
j over
down_next:
add $t0,$s4,$t9 //compute address
sw $zero,($t0)
addi $t9,$t9,320
add $t0,$s4,$t9
addi $t1,$zero,1887
sw $t1,($t0)
j over
Left:
slti $t0,$t9,4
beq $t0,$zero,left_next
j over
left_next:
add $t0,$s4,$t9 //compute address
sw $zero,($t0)
addi $t9,$t9,65532
add $t0,$s4,$t9
addi $t1,$zero,1887
sw $t1,($t0)
j over
Right:
slti $t0,$t9,19192
bne $t0,$zero,right_next
j over
right_next:
add $t0,$s4,$t9 //compute address
sw $zero,($t0)
addi $t9,$t9,4
add $t0,$s4,$t9
addi $t1,$zero,1887
sw $t1,($t0)
j over
Enter:
slti $t0,$t9,0x2440
bne $t0,$zero,Enter_next
j over
Enter_next:
add $t0,$s4,$t9 //compute address
sw $zero,($t0)
addi $t1,$zero,320
add $t3,$zero,$t9
Loop_sub:
slt $t2,$t3,$t1
bne $t2,$zero,enter_loop_next
addi $t3,$t3,65216
j Loop_sub
enter_loop_next:
sub $t9,$t9,$t3
add $t9,$t9,$t1
add $t0,$s4,$t9
addi $t1,$zero,1887
sw $t1,($t0)
j over
ToE0:
lw $t3, ($s3)
j readData
ToF0:
lw $t3, ($s3)
j over
print:
add $t5,$zero,$zero
add $t6,$zero,$zero
addi $t0,$zero,38 //list has 37 numbers
Loop_list://loop for find ascall
sll $t7,$t6,2
add $t7,$s1,$t7
lw $t5,($t7)//t5 ->word
srl $t8,$t5,8
beq $t8,$t3,find_success
addi $t6,$t6,1
bne $t6,$t0,Loop_list
j find_failed
find_success:
addi $t0,$zero,255
and $t3,$t5,$t0
find_failed:
addi $t3,$t3,1792
add $t0,$s4,$t9 //compute address
sw $t3,($t0)
addi $t9,$t9,4 //t9 store the cursor address
addi $t1,$zero,1887
add $t0,$s4,$t9
sw $t1,($t0)
readAgain:
lw $t3,($s3)
add $t0,$zero,$zero
lui $t0,32768
and $t1,$t3,$t0
bne $t1,$t0,readAgain
addi $t0,$zero,255
and $t3,$t3,$t0
addi $t0,$zero,240
beq $t3,$t0,ToF0
j readData
over:
lw $t0,($sp)
lw $t1,4($sp)
lw $t3,8($sp)
addi $sp,$sp,12
jr $ra
.data 0xF000 //ascall-ps2 list
.word 0x1C41
.word 0x3242
.word 0x2143
.word 0x2344
.word 0x2445
.word 0x2B46
.word 0x3447
.word 0x3348
.word 0x4349
.word 0x3B4A
.word 0x424B
.word 0x4B4C
.word 0x3A4D
.word 0x314E
.word 0x444F
.word 0x4D50
.word 0x1551
.word 0x2D52
.word 0x1B53
.word 0x2C54
.word 0x3C55
.word 0x2A56
.word 0x1D57
.word 0x2258
.word 0x3559
.word 0x1A5A
.word 0x4530
.word 0x1631
.word 0x1E32
.word 0x2633
.word 0x2534
.word 0x2E35
.word 0x3636
.word 0x3D37
.word 0x3E38
.word 0x4639
.word 0x2920
.data 0xFF00 //number-ascall list
.word 0x0030
.word 0x0131
.word 0x0232
.word 0x0333
.word 0x0434
.word 0x0535
.word 0x0636
.word 0x0737
.word 0x0838
.word 0x0939
.word 0x0A41
.word 0x0B42
.word 0x0C43
.word 0x0D44
.word 0x0E45
.word 0x0F46
