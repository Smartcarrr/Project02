.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0
	sub $a1, $s0, $a1	# numScores - drop
	move $a0, $s2
	jal calcSum	# Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	# Your code here to compute average and print it
	
	div $v0, $a1           # Divide sum ($v0) by remaining scores ($a1)
    	mflo $t2

    	# Print the result
    	li $v0, 4              # syscall to print string
    	la $a0, str5           # Load address of "Average (rounded down) with dropped scores removed: "
    	syscall

    	li $v0, 1              # syscall to print integer
    	move $a0, $t2          # Move the computed average into $a0 for printing
    	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	
	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.
printArray:
	# Your implementation of printList here	
	move $t0, $zero
	move $t1, $zero
	move $t2, $a0
printStart:
	beq $t0, $a1, printEnd
	sll $t1, $t0, 2
	addu $t1, $t1, $t2
	lw $a0, 0($t1)
	li $v0, 1
	syscall
	li $a0, 32
	li $v0, 11
	syscall
	addiu $t0, $t0, 1
	j printStart
printEnd:
	li $a0, 10
	li $v0, 11
	syscall
	jr $ra
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
	# Your implementation of selSort here
	move $t2, $zero	 #t2 == i
	
	selLoop1:
	bge $t2, $a0, selInit	# if not equal to size of array then branch to sel_init
	sll $s5, $t2, 2  	# t5 is offset
		
	add $t6, $s1, $s5
	add $t7, $s2, $s5
		
	
	lw $t8, 0($t6)
	sw $t8, 0($t7)

	addi $t2, $t2, 1	# i++
	j selLoop1
		
	selInit:
	# initialization of i, j, temp 
	move $t2, $zero	 	# t2 == i
	move $t3, $zero	 	# t3 == j
	move $t4, $zero	 	# t4 == temp
	addi $t9, $a0, -1  # len-1 # t9 == len - 1
		
	selLoop2:
	bge $t2, $t9, selEnd # if i == len - 1, branch to end
	add $t1, $t2, $zero # t1 == maxIndex
		
	addi $t3, $t2, 1  # j = i + 1
	selLoop3:
	bge $t3, $a0, selSwap # if j == len, branch to end of loop3 (swapping)
				# load sorted[j]
	sll $t5, $t3, 2
	add $t5, $t5, $s2 
	lw $t5, 0($t5)
			
	#load sorted[maxIndex]
	sll $t6, $t1, 2
	add $t6, $t6, $s2 
	lw $t6, 0($t6)
			
	# if (sorted[j] > sorted[maxIndex])
	ble $t5, $t6, selEnd3
	add $t1, $t3, $zero # maxIndex == j
			
	j selLoop3 # loop
		
	selEnd3:
	addi $t3, $t3, 1 # j++
	j selLoop3 # loop
			
	selSwap:
	#  temp == sorted[maxIndex]
	sll $t7, $t1, 2
	add $t7, $t7, $s2
	lw $t9, ($t7)
	add $t4, $t9, $zero 
			
	# sorted[maxIndex] == sorted[i]
	sll $t8, $t2, 2
	add $t8, $t8, $s2
	lw $s7, ($t8)
	sw $s7, ($t7)
						
	#sorted[i] == temp
	sw $t4, ($t8)
		
	addi $t2, $t2, 1
	j selLoop2
	
selEnd:
jr $ra
    		    
		
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
    move $v0, $zero          # initialize sum to 0
    move $t0, $zero          # index i = 0

sumStart:
    bge $t0, $a1, sumEnd     

    # Calculate the address of the current element
    sll $t1, $t0, 2          # Multiply index by 4 (word size)
    add $t2, $a0, $t1        # Address of current element
    lw $t3, 0($t2)           # Load element from array into $t3

    # Add the current element to the sum
    add $v0, $v0, $t3        # Add current element to running sum

    addi $t0, $t0, 1         # Increment index (i = i + 1)
    j sumStart               # Continue recursion

sumEnd:
    jr $ra                   # Return from the recursive function
