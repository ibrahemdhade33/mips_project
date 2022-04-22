#STRINGS
.data
#define the data for project


odd_level: .float 0.5 , 1.5,1.5,0.5
read_levels: .asciiz "please enter the number of levels\n"
error_message: .asciiz "\nthe number of levels you enter is incorrect\n"
even_level: .float 1.5 ,0.5, 0.5 ,1.5
fileName: .asciiz "input.txt"
fileNameResult: .asciiz "output.txt"
fileWords: .space 1024
sizes :    .word 2

final_result: .space 9600
temp_result: .space 9600
file1: .asciiz "##############################################################################\n\nthe array after down sampling :\n\n"
file2: .asciiz "\n\n##############################################################################\n\n"

	.text
	.globl main

	
		
			
				
					
##################################################################################################################################						
							
									
main:
	jal read_file_and_store
	la $a0,read_levels
	
	li $v0,4
	syscall
	li $v0,5
	syscall
	move $s1,$v0
	move $t0,$zero
	la $a0,sizes
	lw $t1,0($a0)
	lw $t2,4($a0)
	move $t3,$zero
	li $t4,2
	
	check:
		div $t1,$t4
		mfhi $t5	
		bgt $t5,0,end_check
		mflo $t1
		
		div $t2,$t4
		mfhi $t5
		bgt $t5,0,end_check
		mflo $t2
		
		addiu $t3,$t3,1
		
	b check
	end_check:
	#move $a0,$t3
	#li $v0,1
	#syscall
	ble $s1,$t3,no_error_message
	
		la $a0,error_message
		li $v0,4
		syscall
		b end
	no_error_message:
		jal down_sampling_arithmatic_mean
		#jal down_samling_using_median
		jal double2str_and_print_to_file
	end:
	li $v0,10
	syscall

down_sampling_arithmatic_mean:
###############################################################################################################################

	
	
	li $t0,2
	move $s5,$t0
	li $t0,4
	move $s6,$t0
	move $t5,$zero	#count number of levels
	mtc1 $t0,$f3
	cvt.s.w $f3,$f3
	level_count:
		beq $t5,$s1,end_level_count
		la $a0,sizes	#get the address of sizes array
		lw $t0,0($a0)	#number of rows
		lw $t1,4($a0)	#number of coloumns
		li $t4,2	#load t4 to 2
		div $t0,$t4	#get the new size for rows for the next level
		mflo $t6	#get the result of devision in t6
		sw $t6,0($a0)	#update the size array
		sll $t6,$t6,2	#for dynamic allocation for the array in the next level
		div $t1,$t4	#get the new size for coloumns for the next level
		mflo $t7	#get the result of devision in t7
		sw $t7,4($a0)	#update the number of coloumns in the size array
		mul $t7,$t7,$t6 #get the size for the new array in the current level
		move $a0,$t7	#dynamic allocation for the new array in the cuurent level
		li $v0,9
		syscall
		move $s4,$v0
		#subiu $t0,$t0,2	#decrease the number rows by 2
		#subiu $t1,$t1,2	#decrese the number of coloumns by 2
		move $s2,$t0	#save the number of rows
		move $s3,$t1	#save the number of coloumns
		move $t3,$zero	#count for number of rows
		move $t4,$zero	#count for number of coloumns
		#addiu $t1,$t1 get the number of coloumns for the matrix
		move $t0,$s0	#get the address of the array in $t0
		move $t7,$s4
		rows_count:
		beq $t3,$s2,end_rows_count
		
			columns_count:
				mtc1 $zero,$f0	#set the sum 0
				beq $t4,$s3,end_columns_count 
				div $t5,$s5	#to check if it is even level or odd
				mfhi $t6	
				bne $t6,0,odd
				#even level
				
				la $a0,even_level
				
				b end_odd_even
				odd:
				#odd level
				la $a0,odd_level
				b end_odd_even
			
				end_odd_even:
					mul $t6,$t3,$t1		# i*number of coloumns
					addu $t6,$t6,$t4	# j+ i*number of coloumns
					mul $t6,$t6,$s6		# (j+ i*number of coloumns)*4
					addu $t6,$t6,$t0	# &arr + (j+ i*number of coloumns)*4
					lwc1 $f1,0($t6)		# get the arr[i][j]
					lwc1 $f2,0($a0)
					mul.s $f1,$f1,$f2
					add.s $f0,$f0,$f1	# add the result of multipilcation to f0
					lwc1 $f1,4($t6)		# get the arr[i][j+1]
					lwc1 $f2,4($a0)
					mul.s $f1,$f1,$f2
					add.s $f0,$f0,$f1	# add the result of multipication to $f0
					mul $t2,$t1,$s6		# get the third element of the window by add the number of coloumns to the array base address
					addu $t6,$t6,$t2
					lwc1 $f1,0($t6)		# get the third element of the window 
					lwc1 $f2,8($a0)
					mul.s $f1,$f1,$f2
					add.s $f0 ,$f0,$f1	# increase the sum
					lwc1 $f1,4($t6)		# get the fourth element of the window 
					lwc1 $f2,12($a0)
					mul.s $f1,$f1,$f2
					add.s $f0 ,$f0,$f1	# increase the sum
					div.s $f0,$f0,$f3	# find the average
					swc1 $f0,0($t7)		# store the result in the array
					#move $a1,$v0
					#mov.s $f12,$f0
					#li $v0,2
					#syscall
					#move $a2,$a0
					#li $a0,'\n'
					#li $v0,11
					#syscall
					#move $v0,$a1
					#move $a0,$a2
					addiu $t7,$t7,4		# increase the count for storing by 4
					addiu $t4,$t4,2
					b columns_count		# back to loop
			end_columns_count:
		addiu $t3,$t3,2	# increase rows cont by 1(i++)
		move $t4,$zero
		b rows_count
		end_rows_count:
	addiu $t5,$t5,1
	move $s0,$s4
	move $t3,$zero
	b level_count
	end_level_count:
	#lwc1 $f12,0($s0)
	#li $v0,2
	#syscall

	jr $ra
	
		
			
				
					
						
							
								
									
										
											
													
down_samling_using_median:
###############################################################################################################################

# this function do down sampling my find the sum of the window then find the min and the max in the window,
# after that subtract the min and max from the sum,and devide by 2
	li $t0,2
	move $s5,$t0
	mtc1 $t0,$f5
	cvt.s.w $f5,$f5
	li $t0,4
	move $s6,$t0
	move $t5,$zero	#count number of levels
	mtc1 $t0,$f3
	cvt.s.w $f3,$f3
	level_count1:
		beq $t5,$s1,end_level_count
		la $a0,sizes	# get the address of sizes array
		lw $t0,0($a0)	# number of rows
		lw $t1,4($a0)	# number of coloumns
		li $t4,2	# load t4 to 2
		div $t0,$t4	# get the new size for rows for the next level
		mflo $t6	# get the result of devision in t6
		sw $t6,0($a0)	# update the size array
		sll $t6,$t6,2	# for dynamic allocation for the array in the next level
		div $t1,$t4	# get the new size for coloumns for the next level
		mflo $t7	# get the result of devision in t7
		sw $t7,4($a0)	# update the number of coloumns in the size array
		mul $t7,$t7,$t6 # get the size for the new array in the current level
		move $a0,$t7	# dynamic allocation for the new array in the cuurent level
		li $v0,9
		syscall
		move $s4,$v0 
		#subiu $t0,$t0,2	# decrease the number rows by 2
		#subiu $t1,$t1,2	# decrese the number of coloumns by 2
		move $s2,$t0	# save the number of rows
		move $s3,$t1	# save the number of coloumns
		move $t3,$zero	# count for number of rows
		move $t4,$zero	# count for number of coloumns
		#addiu $t1,$t1 get the number of coloumns for the matrix
		move $t0,$s0	# get the address of the array in $t0
		move $t7,$s4	# counter to store in the new array
		rows_count1:
		beq $t3,$s2,end_rows_count1
		
			columns_count1:
				
				mtc1 $zero,$f0	# set the sum 0
				beq $t4,$s3,end_columns_count1 
				
					mul $t6,$t3,$t1		# i*number of coloumns
					addu $t6,$t6,$t4	# j+ i*number of coloumns
					mul $t6,$t6,$s6		# (j+ i*number of coloumns)*4
					addu $t6,$t6,$t0	# &arr + (j+ i*number of coloumns)*4
					lwc1 $f1,0($t6)		# get the arr[i][j]
					add.s $f0,$f0,$f1	# add the result of multipilcation to f0
					################################################
					mov.s $f3,$f1 #set the min and max for the filrs elenet of the window
					mov.s $f4,$f1
					##############################################
					lwc1 $f1,4($t6)		# get the arr[i][j+1]
					add.s $f0,$f0,$f1	# add the result of multipication to $f0
					c.lt.s $f1,$f4
					bc1t setmin1
					b not_min1
					setmin1: 
						mov.s $f4,$f1
					not_min1:
						c.lt.s $f3,$f1
						bc1t set_max1
					b not_max1
					set_max1:
						mov.s $f3,$f1
					not_max1:
					##############################################
					mul $t2,$t1,$s6		 #get the third element of the window by add the number of coloumns to the array base address
					addu $t6,$t6,$t2
					##############################################
					lwc1 $f1,0($t6)		# get the third element of the window 
					add.s $f0 ,$f0,$f1	# increase the sum
					c.lt.s $f1,$f4
					bc1t setmin2
					b not_min2
					setmin2: 
						mov.s $f4,$f1
					not_min2:
						c.lt.s $f3,$f1
						bc1t set_max2
					b not_max2
					set_max2:
						mov.s $f3,$f1
					not_max2:
					#################################################
					lwc1 $f1,4($t6)		# get the fourth element of the window 
					add.s $f0 ,$f0,$f1	# increase the sum
					c.lt.s $f1,$f4
					bc1t setmin3
					b not_min3
					setmin3: 
						mov.s $f4,$f1
					not_min3:
						c.lt.s $f3,$f1
						bc1t set_max3
					b not_max3
					set_max3:
						mov.s $f3,$f1
					not_max3:
					#################################################
					sub.s $f0,$f0,$f3
					sub.s $f0,$f0,$f4
					div.s $f0,$f0,$f5
					swc1 $f0,0($t7)		# store the result in the array
					addiu $t7,$t7,4		# increase the count for storing by 4
					addiu $t4,$t4,2
					b columns_count1		# back to loop
					
			end_columns_count1:
		addiu $t3,$t3,2	#increase rows cont by 1(i++)
		move $t4,$zero
		b rows_count1
		end_rows_count1:
	addiu $t5,$t5,1
	move $s0,$s4
	move $t3,$zero
	b level_count1
	end_level_count1:
	
	#lwc1 $f12,0($s0)
	#li $v0,2
	#syscall
	jr $ra
		
###############################################################################################################################
read_file_and_store:		 		#read the file and store the data
###############################################################################################################################
			li $v0,13           	# open_file syscall code = 13
    			la $a0,fileName     	# get the file name
    			li $a1,0           	# file flag = read (0)
    			syscall
    			move $s0,$v0        	# save the file descriptor. $s0 = file
			
			#read the file
			li $v0, 14		# read_file syscall code = 14
			move $a0,$s0		# file descriptor
			la $a1,fileWords  	# The buffer that holds the string of the WHOLE file
			la $a2,1024		# hardcoded buffer length
			syscall
			move $s1,$v0	
			# print whats in the file
			li $v0, 4	# read_string syscall code = 4
			la $a0,fileWords
			move $s1,$a0
			#Close the file
    			li $v0, 16         		# close_file syscall code
    			move $a0,$s0      		# file descriptor to close
    			syscall		
    			move $t1,$s1 	# the number of chars in string readen from file
			move $t2,$s1    #the address of the string
			# dynamic allocation array of size 20 bytes to store the size of the matrix as char
			li $a0,20
			li $v0,9
			syscall
			move $t4,$v0 	# get the address of the allocated array in the heap in t4
			move $s2 ,$t4	#save the address to where the temporary data stored
			
			
				#get th size of the matrix
				la $t5,sizes
				move $s1,$ra 		#save the link register
			loop: 	lb $t3, 0($t2) 		# $t3 = A[i]
				addiu $t2, $t2, 1 	# t2++
				beq $t3, '\n', done	# (i == \n)? branch to done
				beq $t3, '\r', else	# (str[i] == \r || str[i] == space )? branch to else
				beq $t3,' ',else   
				sb $t3,0($t4)	  	#store the value at address in t4
				addiu $t4, $t4, 1 	# t4++
				b loop
				else : 
					move $a0,$s2		#geth theaddress of the string and but it in a0
					jal str2int		#go to function to get the value as int
					sw $v0,0($t5)		#save the number of coulomns and number of rows in the sizes array
					addiu $t5, $t5, 4	# increase the address in t5 by 4 bytes
					li $a0,20      		#reallocate t4 to store another string
					li $v0,9
					syscall
					move $t4,$v0 		#get the address of the allocated array in the heap in t4
					move $s2 ,$t4
				
				j loop 	# jump backwards to loop
			done: 
				
			la $t6,sizes		# sizes array address in t6
			lw $t0,0($t6)		# the number of rows
			#move $a0,$s1
			addiu $t6, $t6,4 	# increase the address in t5 by 4 bytes
			lw $t1,0($t6)		#the number of coulomns
			sll $t0,$t0,2		# multibly by 4
			mult $t0,$t1		#get the size of the array
			mflo $t0		
			move $a0,$t0		#dynamic allocation for the array 
			li $v0,9		
			syscall		
			move $t5,$v0		# t5 hold the address for the array to store the values from array as doubles
			move $s0,$v0		# save the value of t1 in the save register 
			
			# note :don't use s0 for any thing after this stage
			# note :don't use s1 any more in this function
			# dynamic allocation for array of size 20 bytes to store the chars
			li $a0,20
			li $v0,9
			syscall
			move $t4,$v0 			# get the address of the allocated array in the heap in t4
			move $s2 ,$t4			#save the address to where the temporary data stored
			 				#save the link register
			loop1: 	lb $t3, 0($t2) 		# $t3 = A[i]
				addiu $t2, $t2, 1 	# t2++
				beq $t3, '\n', done1	# (i == \n)? branch to done
				beq $t3, '\r', else1	# (str[i] == \r || str[i] == space )? branch to else
				beq $t3,' ',else1   
				sb $t3,0($t4)	  	# store the value at address in t4
				addiu $t4, $t4, 1 	# t4++
				b loop1
				else1 : 
					move $a0,$s2		# get the address of the string and but it in a0
					jal str2double		# go to function to get the value as int
					swc1 $f2,0($t5)		# save the number of coulomns and number of rows in the sizes array
					
					addiu $t5, $t5, 4	# increase the address in t5 by 4 bytes
					li $a0,20      		# reallocate t4 to store another string
					li $v0,9
					syscall
					move $t4,$v0 		# get the address of the allocated array in the heap in t4
					move $s2 ,$t4
				
				j loop1 	# jump backwards to loop
			done1: 	
			
			#lwc1 $f12 ,8($s0)
			#li $v0,2
			#syscall
			move $ra,$s1		#get the saved link register
			jr $ra
			
			
			
########################################################################################################################
			
			
	
    	
 str2int :						#function to convert string to int	
########################################################################################################################
 			li $v0, 0 	# Initialize: $v0 = sum = 0
 
			li $t6, 10 	# Initialize: $t6 = 10
			
			L1: lb $t0, 0($a0) 	# load $t0 = str[i]
			
				blt $t0, '0', done2 	# exit loop if ($t1 < '0')
			
				bgt $t0, '9', done2 	# exit loop if ($t1 > '9')
				
				addiu $t0, $t0, -48 	# Convert character to digit
			
				mul $v0, $v0, $t6 	# $v0 = sum * 10
			
				addu $v0, $v0, $t0 	# $v0 = sum * 10 + digit
			
				addiu $a0, $a0, 1 	# $a0 = address of next char
			
				j L1 # loop back
			
			done2: 
			
			jr $ra # return to caller

 
 
 ########################################################################################################################
 
 
 
 
 
 				

 str2double :				 		#function to convert string to fraction
 ########################################################################################################################
 					# this function work by genrate the in value for the floating point number
 					# when '.' is the current value the reg t7 keep multibly by 10 from '.' to end of the string
 					# after finish we get the the int part of the number by divide it into t7
 					# we get the cotioent by convert the reminder of the divition to floating point and convert t7 
 					# to floating point and find the devsin of them
 					# convert the int part to floating point then add it to the last value
 					
 			li $v0, 0 	# Initialize: $v0 = sum = 0
 
			li $t6, 10	 # Initialize: $t6 = 10
			
			li $t7,1	# Initialize: $t7 = 1
			
			L2: 
				lb $t0, 0($a0) 		# load $t1 = str[i]
				bne $t0,'.',no_point
				li $s7,1
				addiu $a0, $a0, 1 	# $a0 = address of next char
				j L2
				no_point:	
				blt $t0, '0', done3 	# exit loop if ($t1 < '0')
			
				bgt $t0, '9', done3 	# exit loop if ($t1 > '9')
				beq $s7,1,  equ
				
				b nequ
				equ :
					
					
					mul $t7, $t7, $t6
					
					addiu $t0, $t0, -48 	# Convert character to digit
			
					mul $v0, $v0, $t6 	# $v0 = sum * 10
			
					addu $v0, $v0, $t0 	# $v0 = sum * 10 + digit
			
					addiu $a0, $a0, 1 	# $a0 = address of next char
					j L2
				nequ :
				addiu $t0, $t0, -48 	# Convert character to digit
			
				mul $v0, $v0, $t6 	# $v0 = sum * 10
			
				addu $v0, $v0, $t0 	# $v0 = sum * 10 + digit
			
				addiu $a0, $a0, 1 	# $a0 = address of next char
			
				j L2 # loop back
			
			done3: 

			
			div $v0,$t7
			mflo $v0

			mfhi $t0 
			
			mtc1 $t0, $f0		# convert reminder to floating point 
  			cvt.s.w $f0, $f0
  			mtc1 $t7, $f1		# convert t7 to floating point 
  			cvt.s.w $f1, $f1	
  			mtc1 $v0, $f2		# convert v0 to floating point 
  			cvt.s.w $f2, $f2
  			div.s $f0,$f0,$f1	# find the devesion of reminder by t7
  			#move $a0,$t7
  			
  			add.s $f2,$f2,$f0	#add the devesion to the result
  			mfc1  $v0,$f2		#get the floating point number
  			
			move $s7,$zero
			
			jr $ra 		# return to caller

 ########################################################################################################################	  	

double2str_and_print_to_file:							#this function to convert from double to str to print th result as str to file

	move $t0,$zero # counter for end of the array
	la $a0,sizes	# get the address of the of the sizes array in a0
	lw $t1,0($a0)	# set the number of rows and the number of columns to t1 and t2 
	lw $t2,4($a0)
	mul $t2,$t2,$t1	#get the size of the array in t2
	move $s1,$t2	#save the size in $s1
	move $t1,$s0	# set t0 to the addres of the result array
	li $t2,10000	# to get three numbers after . in the floating point number
	mtc1 $t2,$f0
	cvt.s.w $f0,$f0		#set the number 1000 in float
	
	la $t4,temp_result	#t4= address of the reuslt string
	move $s3,$t4		
	li $t5,10
	la $a1,sizes
	lw $s7,4($a1)
	la $t7,final_result
	loop_array:	#loop for traversing the result array
	
		beq $t0,$s1,end_loop_array	# if t0 equal the size of the array branch to end loop
		lwc1 $f1,0($t1)
		addiu $t1,$t1,4
		mul.s $f1,$f1,$f0	# mul the number in floating point by 1000 to get three numbers after .
		cvt.w.s $f1,$f1
		mfc1 $t3,$f1		# get the number as int
		
		move $t2,$zero
		convert_loop:
			
			beq $t2,4,set_fraction
			
			div $t3,$t5	
			mflo $t3	# update t3 value
			mfhi $t6 
			addiu $t6,$t6,48
			
			sb $t6,0($t4)
			addiu $t4,$t4,1
			beq $t3,0,end_convert_loop
			b no_fraction
		set_fraction:
			
			li $t6,46
			sb $t6,0($t4)
			addiu $t2,$t2,1
			addiu $t4,$t4,1
			b convert_loop
		no_fraction:
		addiu $t2,$t2,1
		b convert_loop
		end_convert_loop:
		
		#addiu $t0,$t0,1
			
		#lw $t6,4($a1)
		div $t0,$s7
		mfhi $t6
		#subiu $t0,$t0,1
		beq $t6,0,set_new_line
		b no_set_new_line
		
		set_new_line:
			li $t6,10
			sb $t6,0($t4)
			addiu $t4,$t4,1
			addiu $t0,$t0,1
			move $t6,$t4
			subiu $t6,$t6,1
			move $s6,$t1
			b revers_loop
		no_set_new_line:
			li $t6,32
			sb $t6,0($t4)
			addiu $t4,$t4,1
			addiu $t0,$t0,1
			move $t6,$t4
			subiu $t6,$t6,1
			move $s6,$t1
			revers_loop:
				beq $t6,$s3,end_revers_loop
				lb $t1,0($t6)
				sb $t1,0($t7)
				subiu $t6,$t6,1
				addiu $t7,$t7,1
			b revers_loop
			end_revers_loop:
			move $s3,$t4
			move $t1,$s6
		b loop_array
	end_loop_array:
	
	subiu $t4,$t4,2
	
	
	la $a0,final_result
	li $v0,4
	syscall
	
	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileNameResult     # get the file name
    	li $a1,9           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,file1	# the string that will be written
    	la $a2,1024		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall
	
	

	
	
	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileNameResult     # get the file name
    	li $a1,9           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,final_result	# the string that will be written
    	la $a2,9600		# length of the toWrite string
    	syscall
    	
	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall
	
	
	
	
	
	
	
	
	
	#open file 
    	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileNameResult     # get the file name
    	li $a1,9           	# file flag = write (1)
    	syscall
    	move $s1,$v0        	# save the file descriptor. $s0 = file
    	
    	#Write the file
    	li $v0,15		# write_file syscall code = 15
    	move $a0,$s1		# file descriptor
    	la $a1,file2		# the string that will be written
    	la $a2,1024		# length of the toWrite string
    	syscall
    	
    	
    	#MUST CLOSE FILE IN ORDER TO UPDATE THE FILE
    	li $v0,16         		# close_file syscall code
    	move $a0,$s1      		# file descriptor to close
    	syscall
    	
    	
	jr $ra
























