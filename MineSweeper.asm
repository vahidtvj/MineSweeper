######################################################################
#			MineSweeper!!!!				     #
######################################################################
#   Programmed by Ali Pourpanah & Amirahmad Amjadi & Vahid Jahandar  #
######################################################################
#	This program requires the Keyboard and Display MMIO          #
#       and the Bitmap Display to be connected to MIPS		     #
#	and necessary files that include images RGB colors to load.  #

# ***********          Bitmap Display Settings:          *********** #
#	Unit Width: 2						     #
#	Unit Height: 2						     #
#	Display Width: 512					     #
#	Display Height: 512					     #
#	Base address for Display: 0x10040000(heap)		     #
# ***********						 *********** #

# ***************            Key Bindings            *************** #
#	LEFT		->	  A
#	RIGHT		->	  D
#	UP		->	  W
#	DOWN		->	  S
#	Flag/UnFlag	->	  F
#	Reveal Cell	->	Space
# ***********						 *********** #

.data
	# Assets
	backgroundImage:	.asciiz "assets/BackGroundImage-hexadecimal"
	.align 2
	loseImage:		.asciiz "assets/loseEmoji-hexadecimal"
	.align 2
	winImage:		.asciiz "assets/winEmoji-hexadecimal"
	.align 2
	flagImage:		.asciiz "assets/Flag-hexadecimal"
	.align 2
	unflagImage:		.asciiz "assets/unflag-hexadecimal"
	.align 2
	explodedMineImage:	.asciiz "assets/ExplodedMine-hexadecimal"
	.align 2
	emptyBlockImage:	.asciiz "assets/EmptyBlock-hexadecimal"
	.align 2
	mineImage:		.asciiz "assets/Mine-hexadecimal"
	.align 2
	f_negativeImage:	.asciiz "assets/Negative-hexadecimal"
	.align 2
	f_plusImage:		.asciiz "assets/Plus-hexadecimal"
	.align 2
	f_num0Image:		.asciiz "assets/Num0-hexadecimal"
	.align 2
	f_num1Image:		.asciiz "assets/Num1-hexadecimal"
	.align 2
	f_num2Image:		.asciiz "assets/Num2-hexadecimal"
	.align 2
	f_num3Image:		.asciiz "assets/Num3-hexadecimal"
	.align 2
	f_num4Image:		.asciiz "assets/Num4-hexadecimal"
	.align 2
	f_num5Image:		.asciiz "assets/Num5-hexadecimal"
	.align 2
	f_num6Image:		.asciiz "assets/Num6-hexadecimal"
	.align 2
	f_num7Image:		.asciiz "assets/Num7-hexadecimal"
	.align 2
	f_num8Image:		.asciiz "assets/Num8-hexadecimal"
	.align 2
	f_num9Image:		.asciiz "assets/Num9-hexadecimal"
	.align 2
	num1Image:		.asciiz "assets/Number1-hexadecimal"
	.align 2
	num2Image:		.asciiz "assets/Number2-hexadecimal"
	.align 2
	num3Image:		.asciiz "assets/Number3-hexadecimal"
	.align 2
	num4Image:		.asciiz "assets/Number4-hexadecimal"
	.align 2
	num5Image:		.asciiz "assets/Number5-hexadecimal"
	.align 2
	num6Image:		.asciiz "assets/Number6-hexadecimal"
	.align 2
	num7Image:		.asciiz "assets/Number7-hexadecimal"
	.align 2
	num8Image:		.asciiz "assets/Number8-hexadecimal"
	.align 2
	
	#base addresses
	savedColor_address:	.space 128
	sfb_address:		.word 0x10050828		#selected first block base address(line)
	file_address:		.word 0x10080000		#base address of loaded file
	display_address:	.word 0x10040000		#base address of display
	block_address:	.word 0x1004d028		#base address of first block
	fcs_address:		.word 0x10043840		#base address of sign of flag counter
	fct_address:		.word 0x10043878		#base address of ten of flag counter
	fco_address:		.word 0x100438b0		#base address of one of flag counter
	th_address:		.word 0x100439a8		#base address of hundreds of timer
	tt_address:		.word 0x100439e0		#base address of tens of timer
	to_address:		.word 0x10043a18		#base address of one of timer
	emoji_address:	.word 0x10043918		#base address of emoji
	#move addresses
	nextLine_move:	.word 0x00000400		
	vertical_move:	.word 0x00004000		#for moving vertically add to base address
	#buffer size
	buffer:		.word 1048576
	#colors
	sb_color:		.word 0x00A2E8		#selected block color
	
	# array[9][9]
	matrix: 		.space 324		# ( matrix size ^ 2 ) * 4
	helperMatrix: 		.space 324		# 0-close 1-flag 2-open (-1 for helper)	
	matrixSize: 		.word 81
	size: 			.word 9
	mineCount: 		.word 10
	openCount:		.word 71		# win on zero	
	startTime:		.word -1	
	delayCount:		.word 10000
	delay:			.word 10000
	
	# selectedIndex
	X:			.word 0			# selected row started from 0
	Y:			.word 0			# selected column started from 0
.text 
.globl main	
###########################################################
#		draw body of minesweeper		  #
###########################################################
main:
	jal Init
	lw $a0, mineCount
	jal setRandomMines
	jal generateNeighborNumbers
	jal debugPrintBoard
	loopApp:
		# start timer if not set
		jal keyboard
		lw $t0, startTime
		bne $t0, -1, continue$17
			move $s0, $v0
			jal GetTime
			sw $v0, startTime
			move $v0, $s0
		continue$17:
		beq $v0, 4, GoOpen
		beq $v0, 5, GoFlag
		j Move
	GoOpen:
		jal OpenIndex
		j loopApp
	GoFlag:
		jal FlagIndex
		j loopApp
	Move:
		beq $v0, 0, GoUp
		beq $v0, 2, GoDown
		beq $v0, 1, GoRight
		beq $v0, 3, GoLeft
		j loopApp
		GoUp:
			lw $t0, Y
			beq $t0, $zero, loopApp
			subi $t0, $t0, 1
			sw $t0, Y
			j endMove
		GoDown:
			lw $t0, Y
			lw $t1, size
			subi $t1, $t1, 1
			beq $t0, $t1, loopApp
			addi $t0, $t0, 1
			sw $t0, Y
			j endMove
		GoLeft:
			lw $t0, X
			beq $t0, $zero, loopApp
			subi $t0, $t0, 1
			sw $t0, X
			j endMove	
		GoRight:
			lw $t0, X
			lw $t1, size
			subi $t1, $t1, 1
			beq $t0, $t1, loopApp
			addi $t0, $t0, 1
			sw $t0, X
			j endMove	
		endMove:		# if a move is valid
			move $a0, $v0
			jal SelectBlock
			j loopApp										
###########################################################
#			Exit				  #
###########################################################	
exit:
	li $v0, 10
	syscall 	
###########################################################
#		    Keyboard Read			  #
###########################################################
keyboard:				# return: $v0 = 0 = up, 1 = right, 2 = down, 3 = left 4 = open, 5 = flag
	lui $t0, 0xffff
	keyboard$1:
	move $s3, $t0
	# delay
	lw $t8, delay
	subi $t8, $t8, 1
	sw $t8, delay
	bne $t8, $zero, continue$19	# no timer check
	lw $t8, delayCount
	sw $t8, delay
	# update timer
	move $s0, $ra
	jal GetTime
	move $ra, $s0
	
	lw $t8, startTime
	blt $t8, $zero, continue$19
	sub $t9, $v0, $t8
	
	bge $t9, $zero, continue$18	# sign changed
		addi $t9, $t9, 1000	# normalize sign
	continue$18:  
		move $a0, $t9
		move $s0, $ra
		jal ShowTimer
		move $ra, $s0
	continue$19:
	
	# continue
	move $t0, $s3
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001
	beq $t1, $zero, keyboard$1
	lw $v0, 4($t0)
	# check v0 condition if a key is present
	beq $v0, 87, upPressed		# W
	beq $v0, 119, upPressed		# w
	
	beq $v0, 83, downPressed	# S
	beq $v0, 115, downPressed	# s
	
	beq $v0, 68, rightPressed	# D
	beq $v0, 100, rightPressed	# d
	
	beq $v0, 65, leftPressed	# A
	beq $v0, 97, leftPressed	# a
	
	beq $v0, 70, flagPressed	# F
	beq $v0, 102, flagPressed	# f
	
	beq $v0, 32, openPressed	# space
	
	j keyboard$1
	
	upPressed:
		li $v0, 0
		j endKeyboard
	downPressed:
		li $v0, 2
		j endKeyboard
	rightPressed:
		li $v0, 1
		j endKeyboard
	leftPressed:
		li $v0, 3
		j endKeyboard
	openPressed:
		li $v0, 4
		j endKeyboard
	flagPressed:
		li $v0, 5
		j endKeyboard
	endKeyboard:
	jr $ra
###########################################################
#		      Functions			  	  #
###########################################################
getRandomNumber:		# $a1 as upper bound, return $v0
	subi $sp, $sp, 4
	sw $a0, 0($sp)		# store used registers
	
	li $v0, 42   		# random number generator
	syscall  	      	# store random number in ---> ($a0)
	move $v0, $a0
	
	lw $a0, 0($sp)		# load used registers
	addi $sp, $sp, 4
	jr $ra
	
setRandomMines:			# $a0 as mine count
	subi $sp, $sp, 12
	sw $a1, 8($sp)
	sw $v0, 4($sp)		# save used registers
	sw $ra, 0($sp)		# save return address
	move $t1, $a0
	
	lw $a1, matrixSize	# random number upper bound
	# loop to fill 2D array with random numbers 
	loopArray$1:
		beq $t1, $zero, exitLoopArray$1	# loop for number of desired mines
		jal getRandomNumber		# store random in $v0
		mulu $v0, $v0, 4
		
		lw $t0, matrix($v0)
		beq $t0, -1, loopArray$1	# check whether it is already a mine or not
		
		li $t0, -1			# -1 for mine 0 when empty
		sw $t0, matrix($v0)
		
		subi $t1, $t1, 1		# loop
		j loopArray$1
	exitLoopArray$1:	
	
	lw $a1, 8($sp)
	lw $v0, 4($sp)		# load used registers
	lw $ra, 0($sp)		# load return address
	addi $sp, $sp, 8
	jr $ra	
	
generateNeighborNumbers:
	subi $sp, $sp, 4	
	sw $ra, 0($sp)				# store return address
	
	lw $t0, matrixSize			# t0 as counter
	subi $t0, $t0, 1			# start with last index
	mul $t0, $t0, 4
	
	lw $t1, size				# size of rows and columns
	subi $t4, $t1, 1
	mul $t1, $t1, 4
	# loop to calculate 2D array values
	loopArray$2:				# find mines and increase neighbor values
		blt $t0, $zero, exitLoopArray$2	# loop through matrix
		lw $t7, matrix($t0)
		bne $t7, -1, continue$1		# if not a mine continue
		
			divu $t2, $t0, $t1	# t2 is i (row)
			mfhi $t3		
			divu $t3, $t3, 4	# t3 is j (columns)
			
			beq $t2, $zero, continue$2	# dont check upper if not in bound
				sub $t0, $t0, $t1	# go to upper row
				jal checkRow
				add $t0 ,$t0, $t1
			continue$2:
			beq $t2, $t4, continue$3	# dont check lower if not in bound
				add $t0, $t0, $t1	# go to lower row
				jal checkRow
				sub $t0 ,$t0, $t1
			continue$3:
			jal checkRow
			
			j continue$1
			
			checkRow:	# check this row and ( left this right) inc values if not mine
				# check current
				move $t8, $t0
				lw $t9, matrix($t8)
				beq $t9, -1, endCheckCurrent	# if mine dont increase
				addi $t9, $t9, 1
				sw $t9, matrix($t8)		# increase neighbor value
				endCheckCurrent:
				# check Left
				beq $t3, $zero, endCheckLeft
				subi $t8, $t0, 4
				lw $t9, matrix($t8)
				beq $t9, -1, endCheckLeft	# if mine dont increase
				addi $t9, $t9, 1
				sw $t9, matrix($t8)		# increase neighbor value
				endCheckLeft:
				# check Right
				beq $t3, $t4, endCheckRight
				addi $t8, $t0, 4
				lw $t9, matrix($t8)
				beq $t9, -1, endCheckRight	# if mine dont increase
				addi $t9, $t9, 1
				sw $t9, matrix($t8)		# increase neighbor value
				endCheckRight:
				jr $ra
			# end check Row
			
		continue$1:	
		subi $t0, $t0, 4
		j loopArray$2
	exitLoopArray$2:
		
	lw $ra, 0($sp)		# store return address
	addi $sp, $sp, 4
	jr $ra
###########################################################
#		         Debug			  	  #
###########################################################	
debugPrintBoard:
	subi $sp, $sp, 8
	sw $a0, 4($sp)
	sw $v0, 0($sp)
	
	lw $t0, matrixSize
	mul $t0, $t0, 4
	li $t1, 0				# counter
	lw $t2, size
	li $t3, 1				# endLine Counter
	loopArray$3:
		beq $t1, $t0, exitLoopArray$3
		
		lw $a0, matrix($t1)
		li $v0, 1			# print integer
		bne $a0, -1, continue$5
			li $v0, 11		# print char
			li $a0, 42		# char *
		continue$5:			
		syscall				
		
		li $a0, 32			# print space
		li $v0, 11
		syscall
		
		bne $t3, $t2, continue$4	# print endline
			li $t3, 0
			li $a0, 10
			syscall
		continue$4:
		addi $t3, $t3, 1
		addi $t1, $t1, 4
		j loopArray$3
	exitLoopArray$3:
	lw $a0, 4($sp)
	lw $v0, 0($sp)
	addi $sp, $sp, 8
	jr $ra	
###########################################################
#		      Open an index 		  	  #
###########################################################	
OpenIndex:
	subi $sp, $sp, 28
	sw $a0, 24($sp)
	sw $a1, 20($sp)
	sw $a2, 16($sp)			
	sw $s0, 12($sp)	
	sw $s1, 8($sp)
	sw $s2, 4($sp)		
	sw $ra, 0($sp)				# save return address
	
	lw $a0, Y				# Row		0
	lw $a1, X				# Column	0
	
	lw $s0, size				# rows | columns count
	subi $s1, $s0, 1
	
	mulu $t0, $a0, $s0
	add $t0, $t0, $a1
	mulu $t0, $t0, 4
	
	mulu $s0, $s0, 4			# make word address (size as word address)
	
	lw $t1, helperMatrix($t0)
	bne $t1, $zero, continue$11
	lw $t1, matrix($t0)
	bne $t1, -1, continue$11		# !flag && mine
		li $a2, -2
		move $s2, $t0
		lw $s1, matrixSize
		mul $s1, $s1, 4
		jal DrawBlockImage
		# say kaboooooooom!!!!!!!!!!!!!!!
		li $a0, 0
		jal ShowResult
		loopKaboom:				# print all bombs
			beq $s1, $zero, exit
			subi $s1, $s1, 4
			beq $s1, $s2, loopKaboom	# already printed	 		
			lw $a2, matrix($s1)
			bne $a2, -1, loopKaboom		# not a mine
			
			divu $a0, $s1, $s0
			mfhi $a1
			divu $a1, $a1, 4		# calculate position
			
			jal DrawBlockImage
			j loopKaboom
		j exit
	continue$11:
	
	move $s2, $sp				# save stack pointer (s2 == sp then stack empty)
	
	subi $sp, $sp, 4
	sw $t0, 0($sp)
	
	loopHoles$1:	 
		beq $s2, $sp, exitLoopHoles$1	# stack empty
		
		lw $t2, 0($sp)			# load from stack
		addi $sp, $sp, 4
		
		lw $t3, helperMatrix($t2)	# check helperMatrix
		beq $t3, 1, loopHoles$1		# continue if open 
		beq $t3, -1, loopHoles$1	# continue if visited
		beq $t3, 2, loopHoles$1		# continue if flag
		
		lw $a2, matrix($t2)		# check value itself
		beq $a2, -1, loopHoles$1	# continue if mine
		
		divu $a0, $t2, $s0		# t0 is i (row)
		mfhi $a1		
		divu $a1, $a1, 4		# t1 is j (columns)
		
		bne $a2, $zero, continue$6	# if not 0 dont check neighbors

			# check neighbors 
			jal checkRow$2
			
			beq $a0, $zero, continue$9	# check upper
				sub $t2, $t2, $s0
				subi $sp, $sp, 4
				sw $t2, 0($sp)
				jal checkRow$2
				add $t2, $t2, $s0 
			continue$9:
			beq $a0, $s1, continue$10	# check lower
				add $t2, $t2, $s0
				subi $sp, $sp, 4
				sw $t2, 0($sp)
				jal checkRow$2
				sub $t2, $t2, $s0
			continue$10:
			j continue$6
			
			checkRow$2:	# check givin row
				beq $a1, $zero, continue$7	# check left
					subi $t8, $t2, 4
					subi $sp, $sp, 4
					sw $t8, 0($sp)
				continue$7:	
				beq $a1, $s1, continue$8	# check right
					addi $t8, $t2, 4
					subi $sp, $sp, 4
					sw $t8, 0($sp)
				continue$8:
				jr $ra
		continue$6:
		li $t8, -1
		sw $t8, helperMatrix($t2)	# set visited
		jal DrawBlockImage
		j loopHoles$1
	exitLoopHoles$1:
	
	lw $t0, matrixSize
	subi $t0, $t0, 1
	mul $t0, $t0, 4
	li $t1, 2				# initial value for open
	lw $t3, openCount
	loopHelperMatrix$1:			# loop through helper and reset values
		blt $t0, $zero, exitOpenIndex	
		
		lw $t2, helperMatrix($t0)
		bne $t2, -1, continue$12	# continue if not visited
			sw $t1, helperMatrix($t0)	# set open if visited
			subi $t3, $t3, 1
			sw $t3, openCount
		continue$12:
		subi $t0, $t0, 4
		j loopHelperMatrix$1
	exitOpenIndex:
	lw $t0, openCount
	bne $t0, $zero, continue$15	# check win status
		li $a0, 1
		jal ShowResult	
		j exit
	continue$15:
	lw $a0, 24($sp)
	lw $a1, 20($sp)
	lw $a2, 16($sp)			
	lw $s0, 12($sp)	
	lw $s1, 8($sp)
	lw $s2, 4($sp)	
	lw $ra, 0($sp)				# load return address
	addi $sp, $sp, 28
	jr $ra
###########################################################
#		      Flag an index 		  	  #
###########################################################	
FlagIndex:
	subi $sp, $sp, 20
	sw $s0, 16($sp)
	sw $a2, 12($sp)
	sw $a0, 8($sp)
	sw $a1, 4($sp)
	sw $ra, 0($sp)
	
	lw $a0, Y				# Row
	lw $a1, X				# Column
	
	# calculate address
	lw $t0, size
	lw $t3, mineCount
	mul $t1, $a0, $t0
	add $t1, $t1, $a1
	mul $t1, $t1, 4				
	
	lw $t2, helperMatrix($t1)
	beq $t2, 2, endFlagIndex		# do nothing if already open
	beq $t2, $zero, continue$13
		li $t2, 0			# set not flag
		addi $t3, $t3, 1
		j continue$14
	continue$13:
		li $t2, 1			# set flag
		subi $t3, $t3, 1
	continue$14:			
	sw $t2, helperMatrix($t1)	
	sw $t3, mineCount
	move $s0, $t3
	
	subi $a2, $t2, 4
	jal DrawBlockImage 
	
	move $a0, $s0
	jal ShowFlagNumber
	
	endFlagIndex:
	lw $s0, 16($sp)
	lw $a2, 12($sp)
	lw $a0, 8($sp)
	lw $a1, 4($sp)			
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	jr $ra	
######################################################################
#####	initialize(load bgImage)
#####	used regs: $sp,$a0 to $a3
Init:
	li	$a0,256			#width
	li	$a1,256			#height
	lw	$a2,display_address		#base address of pixel to starting to draw
	la	$a3,backgroundImage		#file name
	addi	$sp,$sp,-4			
	sw 	$ra,0($sp)			#save reg ra in stack
	jal	DrawImage
	lw 	$ra,0($sp)
	addi 	$sp,$sp ,4
	jr	$ra

######################################################################
#####	select current block	
#####	used regs: $t0 to $t7
SelectCurrentBlock:
	li	$t3,2
	lw	$t1,sfb_address
	lw	$t2,sb_color
	la	$t5,savedColor_address
	
	lw	$t7,0($t1)
	beq	$t7,$t2,init_end2	#if current color is blue(selected before) we should not save it
	
	init_sl1:
	beqz	$t3,init_end2
	#body of first loop
	li	$t0,16
	move	$t4,$t1
	init_sl2:
	beqz	$t0,init_end
	#body of second loop
	#first save older color
	lw	$t6,0($t4)
	sw	$t6,0($t5)
	addi	$t5,$t5,4
	#store new color
	sw	$t2,0($t4)	
		
	addi	$t4,$t4,4
	addi	$t0,$t0,-1
	j init_sl2
	init_end:
	addi	$t1,$t1,1024			#4*256
	addi	$t3,$t3,-1
	j init_sl1
	init_end2:
	
	jr	$ra
######################################################################
#####	select the block
#####	Inputs: $a0 = Direction to move(0 = up, 1 = right, 2 = down, 3 = left)
#####	used regs: $a0 to $a3,$t0 to $t9
SelectBlock:
	#first change sfb_address
	lw	$t1,sfb_address
	move	$t0,$t1
	la	$t9,sfb_address
	move	$t8,$zero		#to compare to input
	bne	$a0,$t8,selectBlock_l1	#if reg a0 =0
	subi	$t1,$t1,16384			#4*256*16
	sw	$t1,0($t9)
	j	selectBlock_e4
	selectBlock_l1:
	addi	$t8,$t8,1
	bne	$a0,$t8,selectBlock_l2	#if reg a0 =1
	addi	$t1,$t1,64			#4*256
	sw	$t1,0($t9)
	j	selectBlock_e4
	selectBlock_l2:
	addi	$t8,$t8,1
	bne	$a0,$t8,selectBlock_l3	#if reg a0 =2
	addi	$t1,$t1,16384			#4*256*16
	sw	$t1,0($t9)
	j	selectBlock_e4
	selectBlock_l3:
	addi	$t8,$t8,1
	bne	$a0,$t8,selectBlock_end2	#if reg a0 =3
	subi	$t1,$t1,64			#4*256
	sw	$t1,0($t9)
	selectBlock_e4:
	
	move	$t7,$t0
	li	$t3,2
	lw	$t2,sb_color
	la	$t5,savedColor_address
	selectBlock_sl1:
	beqz	$t3,selectBlock_end2
	li	$t0,16
	move	$t4,$t1
	move	$t8,$t7
	selectBlock_sl2:
	beqz	$t0,selectBlock_end
	#load and display old colors
	lw	$t9,0($t5)
	sw	$t9,0($t8)
	addi	$t8,$t8,4
	#save older color
	lw	$t6,0($t4)
	sw	$t6,0($t5)
	addi	$t5,$t5,4
	#store new color
	sw	$t2,0($t4)	
		
	addi	$t4,$t4,4
	addi	$t0,$t0,-1
	j selectBlock_sl2
	selectBlock_end:
	addi	$t1,$t1,1024			#4*256
	addi	$t7,$t7,1024			#4*256
	addi	$t3,$t3,-1
	j selectBlock_sl1
	selectBlock_end2:
	jr	$ra
######################################################################
#####	Show timer
#####	Inputs: $a0 = time
ShowTimer:
	addi 	$sp,$sp,-4			
	sw 	$ra,0($sp)			#save reg ra in stack
	addi 	$sp,$sp,-4
	sw 	$s0,0($sp)			#save reg s0 in stack
	addi 	$sp,$sp,-4
	sw 	$s1,0($sp)			#save reg s1 in stack
	addi 	$sp,$sp,-4
	sw 	$s2,0($sp)			#save reg s2 in stack
	addi 	$sp,$sp,-4
	sw 	$s3,0($sp)			#save reg s3 in stack
	#divide and get hundred, ten and one of number
	div	$s3,$a0,100
	mfhi	$s2
	div	$s2,$s2,10
	mfhi	$s1
	#first show hundred of number
	li	$s0,0
	bne	$s3,$s0,showtimer_if0	# if hundreds of number is 0
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num0Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if0:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if1	# if hundreds of number is 1
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num1Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if1:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if2	# if hundreds of number is 2
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num2Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if2:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if3	# if hundreds of number is 3
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num3Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if3:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if4	# if hundreds of number is 4
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num4Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if4:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if5	# if hundreds of number is 5
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num5Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if5:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if6	# if hundreds of number is 6
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num6Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if6:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if7	# if hundreds of number is 7
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num7Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if7:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_if8	# if hundreds of number is 8
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num8Image		#file name
	jal	DrawImage
	j	showtimer_end1
	showtimer_if8:
	addi	$s0,$s0,1
	
	bne	$s3,$s0,showtimer_end1	# if hundreds of number is 9
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,th_address		#base address of pixel
	la	$a3,f_num9Image		#file name
	jal	DrawImage
	j	showtimer_end1
	
	showtimer_end1:
	
	
	#second show tens of number
	li	$s0,0
	bne	$s2,$s0,showtimer_if10	# if tens of number is 0
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num0Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if10:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if11	# if tens of number is 1
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num1Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if11:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if12	# if tens of number is 2
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num2Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if12:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if13	# if tens of number is 3
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num3Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if13:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if14	# if tens of number is 4
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num4Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if14:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if15	# if tens of number is 5
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num5Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if15:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if16	# if tens of number is 6
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num6Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if16:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if17	# if tens of number is 7
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num7Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if17:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_if18	# if tens of number is 8
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num8Image		#file name
	jal	DrawImage
	j	showtimer_end2
	showtimer_if18:
	addi	$s0,$s0,1
	
	bne	$s2,$s0,showtimer_end2	# if tens of number is 9
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,tt_address		#base address of pixel
	la	$a3,f_num9Image		#file name
	jal	DrawImage

	showtimer_end2:
	
	#third show one of number
	li	$s0,0
	bne	$s1,$s0,showtimer_if20	# if one of number is 0
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num0Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if20:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if21	# if one of number is 1
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num1Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if21:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if22	# if one of number is 2
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num2Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if22:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if23	# if one of number is 3
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num3Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if23:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if24	# if one of number is 4
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num4Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if24:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if25	# if one of number is 5
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num5Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if25:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if26	# if one of number is 6
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num6Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if26:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if27	# if one of number is 7
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num7Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if27:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_if28	# if one of number is 8
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num8Image		#file name
	jal	DrawImage
	j	showtimer_end3
	showtimer_if28:
	addi	$s0,$s0,1
	
	bne	$s1,$s0,showtimer_end3	# if one of number is 9
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,to_address		#base address of pixel
	la	$a3,f_num9Image		#file name
	jal	DrawImage

	showtimer_end3:
	
	lw 	$s3,0($sp)			#save reg s3 in stack
	addi 	$sp,$sp,4			
	lw 	$s2,0($sp)			#save reg s2 in stack
	addi 	$sp,$sp,4
	lw 	$s1,0($sp)			#save reg s3 in stack
	addi 	$sp,$sp,4
	lw 	$s0,0($sp)			#save reg s3 in stack
	addi 	$sp,$sp,4
	lw 	$ra,0($sp)			#save reg ra in stack
	addi 	$sp,$sp,4
	
	jr	$ra
######################################################################
#####	Draw flag counter images
#####	Inputs: $a0 = flag counter
ShowFlagNumber:
	addi 	$sp,$sp,-4			
	sw 	$ra,0($sp)			#save reg ra in stack
	addi 	$sp,$sp,-4
	sw 	$s1,0($sp)			#save reg s1 in stack
	addi 	$sp,$sp,-4
	sw 	$s2,0($sp)			#save reg s2 in stack
	
	move	$s1,$a0			#store the number
	slti 	$t0,$a0,0
	beq	$t0,1,showflagnumber_else1	#if number is more or equal than zero
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fcs_address		#base address of pixel
	la	$a3,f_plusImage		#file name
	jal	DrawImage		
	j	showflagnumber_end_if1
	
	showflagnumber_else1:		#if number is less than zero
	li	$t2,-1
	mul	$s1,$s1,$t2
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fcs_address		#base address of pixel
	la	$a3,f_negativeImage		#file name
	jal	DrawImage

	showflagnumber_end_if1:
	
	#show ten of number			(number=10=> $s1=1, $s2 =0)
	div	$s1,$s1,10			#reg s1 is ten of the number
	mfhi	$s2				#reg s2 is one of the number
	
	li	$s3,0
	bne	$s1,$s3,showflagnumber_if1	#if ten of number is 0
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num0Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if1:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if2	#if ten of number is 1
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num1Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if2:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if3	#if ten of number is 2
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num2Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if3:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if4	#if ten of number is 3
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num3Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if4:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if5	#if ten of number is 4
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num4Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if5:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if6	#if ten of number is 5
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num5Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if6:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if7	#if ten of number is 6
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num6Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if7:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if8	#if ten of number is 7
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num7Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if8:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_if9	#if ten of number is 8
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num8Image		#file name
	jal	DrawImage
	j	showflagnumber_end
	showflagnumber_if9:
	addi	$s3,$s3,1
	
	bne	$s1,$s3,showflagnumber_end	#if ten of number is 9
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fct_address		#base address of pixel
	la	$a3,f_num9Image		#file name
	jal	DrawImage
	showflagnumber_end:
	
	#show one of number
	li	$s3,0
	bne	$s2,$s3,showflagnumber_if10	#if one of number is 0
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num0Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if10:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if11	#if one of number is 1
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num1Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if11:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if12	#if one of number is 2
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num2Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if12:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if13	#if one of number is 3
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num3Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if13:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if14	#if one of number is 4
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num4Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if14:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if15	#if one of number is 5
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num5Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if15:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if16	#if one of number is 6
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num6Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if16:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if17	#if one of number is 7
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num7Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if17:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if18	#if one of number is 8
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num8Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if18:
	addi	$s3,$s3,1
	
	bne	$s2,$s3,showflagnumber_if19	#if one of number is 9
	li	$a0,14				#width
	li	$a1,24				#height
	lw	$a2,fco_address		#base address of pixel
	la	$a3,f_num9Image		#file name
	jal	DrawImage
	j	showflagnumber_end2
	showflagnumber_if19:
	addi	$s3,$s3,1
	
	showflagnumber_end2:
	lw 	$s2,0($sp)		#load reg s2 from stack
	addi 	$sp,$sp ,4
	lw 	$s1,0($sp)		#load reg s1 from stack
	addi 	$sp,$sp ,4
	lw 	$ra,0($sp)		#load reg ra from stack
	addi 	$sp,$sp ,4
	jr	$ra
######################################################################
#####	Draw block images
#####	Inputs: $a0 = row, $a1 = column, $a3 = block number
DrawBlockImage:
	#first calculating row of base address
	lw	$t0,block_address
	move	$t1,$a0
	mul	$t1,$t1,16384
	add	$t0,$t1,$t0
	#second calculating column of base address
	move	$t1,$a1
	mul	$t1,$t1,64
	add	$t0,$t1,$t0
	#set the file name
	li	$t1,-4
	
	bne	$a2,$t1,drawImageBlock_end_if1
	la	$t2,unflagImage				#if number block is -4
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if1:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if2
	la	$t2,flagImage					#if number block is -3
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if2:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if3
	la	$t2,explodedMineImage			#if number block is -2
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if3:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if4
	la	$t2,mineImage					#if number block is -1
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if4:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if5
	la	$t2,emptyBlockImage				#if number block is 0
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if5:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if6
	la	$t2,num1Image					#if number block is 1
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if6:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if7
	la	$t2,num2Image					#if number block is 2
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if7:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if8
	la	$t2,num3Image					#if number block is 3
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if8:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if9
	la	$t2,num4Image					#if number block is 4
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if9:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if10
	la	$t2,num5Image					#if number block is 5
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if10:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if11
	la	$t2,num6Image					#if number block is 6
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if11:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if12
	la	$t2,num7Image					#if number block is 7
	j	drawImageBlock_end_if_all
	drawImageBlock_end_if12:
	addi	$t1,$t1,1
	
	bne	$a2,$t1,drawImageBlock_end_if13
	la	$t2,num8Image					#if number block is 8
	j	drawImageBlock_end_if_all
	
	drawImageBlock_end_if_all:
	#and finally draw final image
	addi $sp,$sp,-4			
	sw $ra,0($sp)			#save reg ra in stack
	
	li	$a0,16			#width
	li	$a1,16			#height
	move	$a2,$t0		#base address of pixel
	move	$a3,$t2		#file name
	jal	DrawImage
	
	lw 	$ra,0($sp)
	addi 	$sp,$sp ,4		#load reg ra from stack
	
	drawImageBlock_end_if13:
	jr	$ra
######################################################################
#####	Draw Image
#####	Inputs: $a0 = Width, $a1 = Height, $a2 = address of pixel to starting to draw
#####		$a3 = file name
#####	used regs: $sp,$a0 to $a3,$t0 to $t8
DrawImage:

	move	$t0,$a1		#height
	move	$t1,$a0		#width
	move 	$t2,$a2		#address of pixel
	lw	$t5,file_address
	#first load the image
	addi $sp,$sp,-4			
	sw $ra,0($sp)			#save reg ra in stack

	move	$a0,$a3
	jal	ORC			#load from file
	
	sl_1:
	beqz	$t0,el_1	#if $t0 == 0 then go end of first loop
	#body of first loop
	move	$t4,$t2
	move	$t7,$t1
	sl_2:
	beqz	$t7,el_2
	#body of scond loop
	#getting the color
	lw	$t6,0($t5)
	sll	$t6, $t6, 8
	lw	$t8,4($t5)
	add	$t6,$t6,$t8
	sll	$t6, $t6, 8
	lw	$t8,8($t5)
	add	$t6,$t6,$t8
	
	sw	$t6,0($t4)	#store the color
	
	addi	$t5,$t5,12
	addi	$t4,$t4,4
	addi	$t7,$t7,-1
	j sl_2
	el_2:			# end of first loop
	addi	$t2,$t2,1024
	addi	$t0,$t0,-1
	j sl_1
	el_1:			# end of second loop	
	
	jal	SelectCurrentBlock	
	
	lw 	$ra,0($sp)
	addi 	$sp,$sp ,4	#load reg ra from stack
							
	jr	$ra												
######################################################################
#####	Open Read Close
#####	Inputs: $a0 = Address of file name
#####	used regs: $s0
ORC:
	subi $sp, $sp, 4
	sw $s0, 0($sp)
	#open
  	li	$v0, 13         # system call for open file
  	move	$a0, $a0        # file name
  	li	$a1, 0          # Open for reading (flags are 0: read, 1: write)
  	syscall			# open a file (file descriptor returned in $v0)
  	move $s0,$v0
  	#read
  	li	$v0, 14		# system call for read from file
  	move	$a0, $s0	# file descriptor 
  	lw 	$a1,file_address	#$a1 = address of input buffer
  	lw	$a2,buffer	#$a2 = maximum number of characters to read(buffer size)
  	syscall     
  	#close       	# read from file
  	li	$v0, 16		# system call for close file
	move	$a0, $s0
	syscall
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr	$ra
######################################################################
#####	show result emoji
#####	Inputs: $a0 = result(if a0 = 0 => lose, else if a0 = 1 => win)
ShowResult:
	addi	$sp,$sp,-4			
	sw 	$ra,0($sp)			#save reg ra in stack
	
	beqz	$a0,showresult_lose
	li	$a0,24				#width
	li	$a1,24				#height
	lw	$a2,emoji_address		#base address of pixel
	la	$a3,winImage			#file name
	jal	DrawImage
	j	showresult_end
	showresult_lose:
	li	$a0,24				#width
	li	$a1,24				#height
	lw	$a2,emoji_address		#base address of pixel
	la	$a3,loseImage			#file name
	jal	DrawImage
	showresult_end:
	lw 	$ra,0($sp)
	addi 	$sp,$sp ,4
	jr	$ra
###########################################################
#		         get time		  	  #
###########################################################
GetTime:	# uses a1:a0 returns v0 3 second digits only
	li $v0, 30
	syscall
	divu $a1, $a0, 1000
	divu $a0, $a1, 1000
	mfhi $v0
	jr $ra	
