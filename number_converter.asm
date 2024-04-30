	.data
asciiart:  .asciiz " _______               ___.                  _________                                   __                \n \\      \\  __ __  _____\\_ |__   ___________  \\_   ___ \\  ____   _______  __ ____________/  |_  ___________ \n /   |   \\|  |  \\/     \\| __ \\_/ __ \\_  __ \\ /    \\  \\/ /  _ \\ /    \\  \\/ // __ \\_  __ \\   __\\/ __ \\_  __ \\\n/    |    \\  |  /  Y Y  \\ \\_\\ \\  ___/|  | \\/ \\     \\___(  <_> )   |  \\   /\\  ___/|  | \\/|  | \\  ___/|  | \\/\n\\____|__  /____/|__|_|  /___  /\\___  >__|     \\______  /\\____/|___|  /\\_/  \\___  >__|   |__|  \\___  >__|   \n        \\/            \\/    \\/     \\/                \\/            \\/          \\/                 \\/       \n"
menu: .asciiz "\n\n1.\tBinary to hexadecimal and decimal\n2.\tHexadecimal to binary and decimal\n3.\tDecimal to binary and hexadecimal\n4.\tExit\n"
invalidInputMsg: .asciiz "\nInvalid input, please enter a valid choice (1-4).\n"
binaryInputMsg: .asciiz "\nPlease enter binary number: 0b"
hexInputMsg: .asciiz "\nPlease enter hexadecimal number: 0x"
decimalInputMsg: .asciiz "\nPlease enter decimal number: "
invalidNumberMsg: .asciiz "\nInvalid input, please enter a valid number.\n"
binaryMsg: .asciiz "\nBinary number: 0b"
decimalMsg: .asciiz "\nDecimal number: "
hexMsg: .asciiz "\nHexadecimal number: 0x"
binaryToHexMap: .asciiz "0123456789ABCDEF"
hexToBinMap: .asciiz "0000000100100011010001010110011110001001101010111100110111101111"
sourceNumber: .space 34
destinationNumber1: .space 33
destinationNumber2: .space 33
binaryBuffer: .space 33

	.text
main:
	jal printArt
	
loop:
	jal listPrompts
	move $a0, $v0
case1:	li $t0, 1
	bne $a0, $t0, case2
	jal convertBinToHexDec
	j loop
case2:	li $t0, 2
	bne $a0, $t0, case3
	jal convertHexToBinDec
	j loop
case3:	li $t0, 3
	bne $a0, $t0, case4
	jal convertDecToBinHex
	j loop
case4:	j endProgram
	
convertBinToHexDec:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	move $s0, $a0
binLoop:
	li $v0, 4
	la $a0, binaryInputMsg
	syscall
	li $v0, 8
	la $a0, sourceNumber
	li $a1, 33
	syscall
	
	la $a0, sourceNumber
	jal trimNewline
	la $a0, sourceNumber
	move $a1, $s0
	jal validateInput
	beqz $v0, invalidBin
	j continueBin
invalidBin:
	jal invalidNumber
	j binLoop
continueBin:
	la $a0, sourceNumber
	la $a1, binaryBuffer
	jal padBinaryString
	la $a0, sourceNumber
	jal convertBinToDec
	move $a0, $v0
	la $a1, destinationNumber2
	jal intToString
	la $a0, sourceNumber
	jal convertBinToHex
	la $a1, destinationNumber2
	la $a2, destinationNumber1
	la $a0, sourceNumber
	jal displayNumbers
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
convertBinToDec:
    	addi $sp, $sp, -8
    	sw $ra, 0($sp)
    	sw $a0, 4($sp)
    	    
    	li $t0, 0 # decimal number

binToDecLoop:
    	lb $t1, 0($a0)
    	beqz $t1, finishedBinToDec
    	subu $t1, $t1, 48
    	sll $t0, $t0, 1
    	add $t0, $t0, $t1
    	addiu $a0, $a0, 1
    	j binToDecLoop

finishedBinToDec:
    	move $v0, $t0

    	lw $ra, 4($sp)
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8
    	jr $ra

convertBinToHex:
    	addi $sp, $sp, -8
    	sw $ra, 0($sp)
    	sw $a0, 4($sp)

    	la $t8, binaryToHexMap
    	la $t9, destinationNumber1
    	li $t3, 0
    	li $t4, 0

binToHexLoop:
    	lb $t0, 0($a0)
    	beqz $t0, processLastGroup
    	subu $t0, $t0, 48
    	sll $t4, $t4, 1
    	or $t4, $t4, $t0
    	addi $t3, $t3, 1
    	addiu $a0, $a0, 1

    	li $t6, 4
    	bne $t3, $t6, binToHexLoop

    	add $t7, $t8, $t4
    	lb $t5, 0($t7)
    	sb $t5, 0($t9)
    	addiu $t9, $t9, 1
    	
    	li $t3, 0
    	li $t4, 0
    	j binToHexLoop

processLastGroup:
    	beqz $t3, finishedBinToHex
    	add $t7, $t8, $t4
    	lb $t5, 0($t7)
    	sb $t5, 0($a2)
    	addiu $t9, $t9, 1

finishedBinToHex:
    	sb $zero, 0($t9)
    	
    	la $v0, destinationNumber1
    	
    	lw $a0, 4($sp)
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8
    	jr $ra
	
convertHexToBinDec:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	move $s0, $a0
hexLoop:
	li $v0, 4
	la $a0, hexInputMsg
	syscall
	li $v0, 8
	la $a0, sourceNumber
	li $a1, 9 # max 8 digits
	syscall
	
	la $a0, sourceNumber
	jal trimNewline
	la $a0, sourceNumber
	move $a1, $s0
	jal validateInput
	beqz $v0, invalidHex
	j continueHex
invalidHex:
	jal invalidNumber
	j hexLoop
continueHex:
	la $a0, sourceNumber
	jal hexToUpper
	la $a0, sourceNumber
	la $a1, destinationNumber1
	jal hexToBin
	la $a0, sourceNumber
	la $a1, destinationNumber2
	jal hexToDec
	la $a0, destinationNumber1
	la $a1, destinationNumber2
	la $a2, sourceNumber
	jal displayNumbers
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
# a0 is hexadecimal string, a1 is destination number
hexToBin:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lb $t1, 0($a0)
    	la $t5, hexToBinMap

hexToBinLoop:
    	beqz $t1, hexToBinEnd
    	blt $t1, 58, hexToBinProcessDigit # 0-9
    	blt $t1, 65, skip
    	blt $t1, 71, hexToBinProcessAlpha # A-F
    	blt $t1, 97, skip
    	blt $t1, 103, hexToBinProcessAlpha # a-f
    
    	j skip

hexToBinProcessDigit:
    	sub $t1, $t1, 48
    	j mapToBinary

hexToBinProcessAlpha:
    	blt $t1, 97, hexToBinUpperAlpha
    	sub $t1, $t1, 87
    	j mapToBinary

hexToBinUpperAlpha:
    	sub $t1, $t1, 55

mapToBinary:
    	sll $t1, $t1, 2
    	add $t1, $t1, $t5
    	li $t3, 4
    	
hexToBinCopyLoop:
    	lb $t2, 0($t1)
    	sb $t2, 0($a1)
    	addiu $t1, $t1, 1
    	addiu $a1, $a1, 1
    	subiu $t3, $t3, 1
    	bnez $t3, hexToBinCopyLoop

skip:
    	addiu $a0, $a0, 1
    	lb $t1, 0($a0)
    	j hexToBinLoop

hexToBinEnd:
    	sb $zero, 0($a1)
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
    	
# a0 is hex string, a1 is destinationNumber
hexToDec:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

    	li $v0, 0

hexToDecloop:
    	lbu $t1, 0($a0)
    	beq $t1, $zero, hexToDecEnd

    	blt $t1, 'A', hexToDecDigit
    	blt $t1, 'a', hexToDecUpperCase
    	addi $t1, $t1, -87
    	j hexToDecProcess

hexToDecDigit:
    	addi $t1, $t1, -48
    	j hexToDecProcess

hexToDecUpperCase:
    	addi $t1, $t1, -55

hexToDecProcess:
    	sll $v0, $v0, 4
    	add $v0, $v0, $t1

    	addiu $a0, $a0, 1
    	j hexToDecloop

hexToDecEnd:
	move $a0, $v0
	jal intToString
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
    	jr $ra

convertDecToBinHex:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	move $s0, $a0
decLoop:
	li $v0, 4
	la $a0, decimalInputMsg
	syscall
	li $v0, 8
	la $a0, sourceNumber
	li $a1, 11 # max 10 digits
	syscall
	
	la $a0, sourceNumber
	jal trimNewline
	la $a0, sourceNumber
	move $a1, $s0
	jal validateInput
	beqz $v0, invalidDec
	j continueDec
invalidDec:
	jal invalidNumber
	j decLoop
continueDec:
	la $a0, sourceNumber
	jal strToInt
	move $s0, $v0
	move $a0, $s0
	la $a1, destinationNumber1
	jal decToBin
	move $a0, $s0
	la $a1, destinationNumber2
	jal decToHex
	la $a0, destinationNumber1
	la $a1, sourceNumber
	la $a2, destinationNumber2
	jal displayNumbers
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
# a0 is decimal integer, a1 is destinationNumber
decToBin:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	li $t0, 31 # start from 32nd bit
	
decToBinLoop:
    	srlv $t1, $a0, $t0
    	andi $t1, $t1, 1
    	li $t2, '0'
    	bnez $t1, bitIsOne
    	j storeBit

bitIsOne:
    	li $t2, '1'

storeBit:
    	sb $t2, 0($a1)
    	addi $a1, $a1, 1
    	addi $t0, $t0, -1
    	bgez $t0, decToBinLoop
    
    	sb $zero, 0($a1)
    
    	lw $ra, 0($sp)
    	lw $a0, 4($sp)
    	addi $sp, $sp, 8
    	jr $ra	

# a0 is decimal number, a1 is hex string buffer
decToHex:
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)

    	li $t3, 8
    	li $t4, 28
    	la $t5, binaryToHexMap

decToHexLoop:
    	move $t0, $a0 
    	srlv $t0, $t0, $t4
    	andi $t0, $t0, 0xF
    	add $t0, $t0, $t5
    	lb $t1, 0($t0)
    	sb $t1, 0($a1)
    	addi $a1, $a1, 1
    	subi $t4, $t4, 4
    	subi $t3, $t3, 1
    	bnez $t3, decToHexLoop

    	sb $zero, 0($a1)
    	
    	lw $s0, 0($sp)
    	lw $ra, 4($sp)
    	addi $sp, $sp, 8
    	jr $ra
	
printArt:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 4
	la $a0, asciiart
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# v0 returns choice
listPrompts:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
readInput:	
	li $v0, 4
	la $a0, menu
	syscall
	
	li $v0, 5
	syscall
	
	li $t1, 1
	blt $v0, $t1, invalidInput
	li $t1, 4
	bgt $v0, $t1, invalidInput
			
	lw $ra 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# a0 binary, a1 decimal, a2 hexadecimal
displayNumbers:
    	addi $sp, $sp, -16
    	sw $ra, 0($sp)
    	sw $a0, 4($sp)
    	sw $a1, 8($sp)
    	sw $a2, 12($sp)
    	
    	move $t0, $a0
    	move $t1, $a1
    	move $t2, $a2

    	li $v0, 4
    	la $a0, binaryMsg
    	syscall
    	li $v0, 4
    	move $a0, $t0
    	syscall

    	li $v0, 4
    	la $a0, decimalMsg
    	syscall
    	li $v0, 4
    	move $a0, $t1
    	syscall
    
    	li $v0, 4
    	la $a0, hexMsg
    	syscall
    	li $v0, 4
    	move $a0, $t2
    	syscall
    
    	lw $ra, 0($sp)
    	lw $a0, 4($sp)
    	lw $a1, 8($sp)
    	lw $a2, 12($sp)
    	addi $sp, $sp, 16
    	jr $ra
	
invalidInput:
	li $v0, 4
	la $a0, invalidInputMsg
	syscall
	j readInput
	
# a0 is binary string, $a1 is binary buffer
padBinaryString:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $t5, $a0
	move $t6, $a1
	
    	li $t0, 0 # Length counter

calculateLength:
    	lb $t1, 0($a0)
    	beqz $t1, determinePadding
    	addiu $t0, $t0, 1
    	addiu $a0, $a0, 1
    	j calculateLength

determinePadding:
    	li $t2, 4
    	rem $t3, $t0, $t2
    	beqz $t3, noPaddingNeeded
    	sub $t3, $t2, $t3

    	li $t4, '0'
padZeros:
    	beqz $t3, copyContent
    	sb $t4, 0($a1)
    	addiu $a1, $a1, 1
    	subiu $t3, $t3, 1
    	j padZeros

copyContent:
    	move $a0, $t5
copyLoop:
    	lb $t1, 0($a0)
    	beqz $t1, copyBack
    	sb $t1, 0($a1)
    	addiu $a0, $a0, 1
    	addiu $a1, $a1, 1
    	j copyLoop

copyBack:
    	sb $zero, 0($a1)
    	li $t0, 33
    	
copyBackLoop:
    	lb $t1, 0($t6)
    	sb $t1, 0($t5)
    	addiu $t6, $t6, 1
    	addiu $t5, $t5, 1
    	subiu $t0, $t0, 1
    	bnez $t0, copyBackLoop
    
noPaddingNeeded:
	lw $ra, 0($sp)
        addi $sp, $sp, 4
    	jr $ra
    	
# a0, is source string
hexToUpper:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
   
upperLoop:
        lb $t1, 0($a0)
        beqz $t1, hexToUpperEnd
        blt $t1, 'a', nextChar
        bgt $t1, 'f', nextChar

        addi $t1, $t1, -32
        sb $t1, 0($a0)

nextChar:
        addiu $a0, $a0, 1
        j upperLoop

hexToUpperEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
        jr $ra
    
# a0 is source number, a1 is destination buffer
intToString:
    	addi $sp, $sp, -8
    	sw $ra, 4($sp)
    	sw $a0, 0($sp)

    	bgez $a0, convertPositive

    	li $t5, '-'
    	sb $t5, 0($a1)
    	addiu $a1, $a1, 1
    	negu $a0, $a0

convertPositive:
    	# temp buffer for conversion
    	addi $sp, $sp, -33
    	move $t4, $sp

intConvertLoop:
    	li $t1, 10
    	div $a0, $t1
    	mflo $t2
    	mfhi $t3
    	addi $t3, $t3, 48
    	sb $t3, 0($t4)
    	addi $t4, $t4, 1
    	move $a0, $t2
    	bnez $a0, intConvertLoop

    	addi $t0, $t4, -1
reverseLoop:
    	lb $t1, 0($t0)
    	sb $t1, 0($a1)
    	addi $a1, $a1, 1
    	addi $t0, $t0, -1
    	bge $t0, $sp, reverseLoop

    	sb $zero, 0($a1)
    	addi $sp, $sp, 33

    	lw $ra, 4($sp)
    	addi $sp, $sp, 8
    	jr $ra
    	
# a0 is decimal string, v0 returns decimal integer
strToInt:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

    	li $v0, 0
    	li $t1, 10
    	lb $t2, 0($a0)
    	li $t3, '-'
    	bne $t2, $t3, strToIntCheckLoop
    	addiu $a0, $a0, 1

strToIntCheckLoop:
    	lbu $t0, 0($a0)
    	beq $t0, $zero, strToIntFinish
    	subi $t0, $t0, '0'
    	mul $v0, $v0, $t1
    	add $v0, $v0, $t0

    	addiu $a0, $a0, 1
    	j strToIntCheckLoop

strToIntFinish:
    	bne $t2, $t3, strToIntReturn
    	neg $v0, $v0
strToIntReturn:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
    	jr $ra
	
# used to trim '\n' from user input string
# a0 is input string
trimNewline:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

    	li $t1, 0

trimLoop:
    	lb $t2, 0($a0)
    	beqz $t2, checkNewline
    	addiu $a0, $a0, 1
    	j trimLoop

checkNewline:
    	subu $a0, $a0, 1
    	lb $t2, 0($a0)
    	li $t3, 10
    	bne $t2, $t3, endTrim
    	sb $zero, 0($a0)

endTrim:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# v0 is 1 valid, 0 invalid
validateInput:
    	addi $sp, $sp, -12
    	sw $ra, 0($sp)
    	sw $a0, 4($sp)
	sw $a1, 8($sp)

    	li $v0, 1

validateLoop:
    	lb $t0, 0($a0)
    	beqz $t0, validateEnd

    	li $t2, 1            # Binary
    	beq $a1, $t2, checkBinary
    	li $t2, 2            # Hexadecimal
    	beq $a1, $t2, checkHex
    	li $t2, 3            # Decimal
    	beq $a1, $t2, checkDecimal

    	j validateEnd

checkBinary:
    	li $t3, '0'
    	li $t4, '1'
    	blt $t0, $t3, invalid
   	bgt $t0, $t4, invalid
    	j continueCheck

checkHex:
    	li $t3, '0'
    	li $t4, '9'
    	blt $t0, $t3, checkAlpha
    	ble $t0, $t4, continueCheck

checkAlpha:
    	li $t3, 'A'
    	li $t4, 'F'
    	li $t5, 'a'
    	li $t6, 'f'
    	blt $t0, $t3, checkLowerAlpha
    	bgt $t0, $t4, checkLowerAlpha
    	j continueCheck

checkLowerAlpha:
    	blt $t0, $t5, invalid
    	bgt $t0, $t6, invalid
    	j continueCheck

checkDecimal:
    	li $t3, '0'
    	li $t4, '9'
    	li $t5, '-'
    	beq $t0, $t5, continueCheck
    	blt $t0, $t3, invalid
    	bgt $t0, $t4, invalid
    	j continueCheck

continueCheck:
    	addi $a0, $a0, 1
    	j validateLoop

invalid:
    	li $v0, 0
    	j validateEnd

validateEnd:
    	lw $ra, 0($sp)
    	lw $a0, 4($sp)
	lw $a1, 8($sp)
    	addi $sp, $sp, 12
    	jr $ra
    
invalidNumber:
    	addi $sp, $sp, -4	
	sw $ra, 0($sp)	
	
	li $v0, 4
	la $a0, invalidNumberMsg
	syscall
	
	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr $ra

endProgram:
	li $v0, 10
	syscall