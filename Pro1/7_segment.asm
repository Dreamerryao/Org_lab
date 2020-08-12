.text 0x0000
start:
//0xFFFFFE00;0xE0000000 7-segment地址
//0xF0000004 ->counter地址
//ff7f f7ff
addi $sp, $zero, 16384
lui $s2,0xE000 //s2 = E000 0000,7-segment接口
lui $s3,0xF000
ori $s3,$s3,4 //s3 = F000 0004
addi $t6,$zero,1000
loop:
sw $t6,0($s3)

lui $t1,0x7FFF
ori $t1,$t1,0x7FF7//t1 = FFFFFFFF
lui $t0,0xFFFF
ori $t0,$t0,0xFFFF //t0,低四位正常显示
sw $t0,0($s2)
sw $t1,1($s2) //图形界面高四位
