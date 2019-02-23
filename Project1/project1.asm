.data
fileStr: .space 224
newline: .byte '\n'
textData: .space 256
outData: .space 256
zero: .asciiz "zero"
one: .asciiz "one"
two: .asciiz "two"
three: .asciiz "three"
four: .asciiz "four"
five: .asciiz "five"
six: .asciiz "six"
seven:.asciiz "seven"
eight:.asciiz "eight"
nine:.asciiz "nine"
list: .word zero,one,two,three,four,five,six,seven,eight,nine
.text
.globl main
main:
	li $v0, 8 # system call for reading file name
	la $a0, fileStr
	li $a1, 224 #file name can be up to 224-bit characters. 
	syscall #read file name
	jal delete_newline #delete \n(newline character) from input
	#open file
	li $v0, 13 # system call for open file
	la $a0, fileStr # input file name
	li $a1, 0	# Open for reading 
	li $a2, 0	# mode is ignored
	syscall		# open a file
	move $s0,$v0	# save the file descriptor 
	#readfile
	li $v0,14	 # system call for read to file
	move $a0 ,$s0	# file descriptor
	li $a2,256	# hardcoded textData length
	la $a1,textData	#address of textData from which to read
	syscall
	#closefile
	li $v0, 16
	move $a0,$s0
	syscall
####################################################################################
	la $a0, textData #load textData into argument register $a0
   	add $s4,$zero,$a0#save textData into $s4
   	jal strlen  # calculate the size of the textData
	add $s5,$zero,$t0 #save the size of the textData into reg $s5
	la $a0,outData #load outData into argument register $a0
	add $s6,$a0,$zero#save outData into $s6
	add $s3,$zero,$zero#count for indexes of the outData ; k=0
	add $s1,$zero,$zero#count for indexes of the textData i=0
####for loop 
for1st: slt $t0,$s1,$s5 # if i<size $t0=1  (s5 saves the size of the textData)
	beq $t0,$zero,exit1#exit the for loop
####if
# Conditions in first parenthesis: (textData[i]<='9' && textData[i]>='0')
	add $t2,$s4,$s1 # $t2 = textData + i
	lb $t3 ,0($t2)  # $t3 = textData[i]
	slti $t0,$t3,58 # if textData[i]<='9' $t0=1
	beq $t0,$zero,else# go to
	slti $t0,$t3,48 # if textData[i]< 0 $t0=1
	bne $t0,$zero,else# go to else
#Conditions in second parenthesis :(i<=1 || textData[i-2]>'9' || textData[i-2]<'0' || textData[i-1]!='.')
	slti,$t0,$s1,2 # if i<2 t0=1
	bne $t0,$zero,cond3 # if a condition is met, switch to other parenthesis
	lb $t4 ,-2($t2)#t4=textData[i-2]
	slti $t0,$t4,58 #if textData[i-2]>'9' t0=0
	beq $t0,$zero,cond3 # if a condition is met, switch to other parenthesis
	slti $t0,$t4,48 # if textData[i-2]<'0' t0=1
	bne $t0,$zero,cond3 # if a condition is met, switch to other parenthesis
	lb $t4,-1($t2) # t4=textData[i-1]
	addi $t0,$zero,46# t0='.'
	beq $t0,$t4,else# if textData[i-1]=='.' go to else
#Conditions in third parenthesis:(i==0 || textData[i-1]>'9'  ||  textData[i-1]<'0')
cond3:  beq $s1,$zero,cond4 #i==0 : if a condition is met, switch to other parenthesis
	lb $t4,-1($t2) # t4=textData[i-1]
	slti $t0,$t4,58 # if textData[i-1]>'9' t0=0
	beq $t0,$zero,cond4# # if a condition is met, switch to other parenthesis
	slti $t0,$t4,48# if textData[i-1]<'0' t0=1
	beq $t0,$zero,else #go to else
#Conditions in fourth parenthesis:(size-3<i || textData[i+2]>'9' || textData[i+2]<'0' || textData[i+1]!='.')
cond4:	addi $t4,$s5,-3# t4=size-3
	slt $t0,$t4,$s1#if size-3<i t0=1
	bne $t0,$zero,cond5 # if a condition is met, switch to other parenthesis
	lb $t4,2($t2)#t4=textData[i+2]
	slti $t0,$t4,58 #textData[i+2]>'9' t0=0
	beq $t0,$zero,cond5 # if a condition is met, switch to other parenthesis
	slti,$t0,$t4,48 #textData[i+2]<'0' t0=1
	bne $t0,$zero,cond5 # if a condition is met, switch to other parenthesis
	lb $t4,1($t2) # t4=textData[i+1]
	addi $t0,$zero,46# t0='.'
	beq $t0,$t4,else# if textData[i-1]=='.' go to else	
#Conditions in fifth parenthesis:(i==size-1 || textData[i+1]>'9' || textData[i+1]<'0')
cond5:	addi $t4,$s5,-1 # $t4=size-1
	beq $t4,$s1,do_it # i==size-1  ;  # if a condition is met, go to do_it
	lb $t4,1($t2) # t4=textData[i+1]	
	slti $t0,$t4,58 # if textData[i+1]>'9' t0=0
	beq $t0,$zero,do_it# # if a condition is met, go to do_it
	slti $t0,$t4,48 #if textData[i+1]<'0' t0=1
	beq $t0,$zero,else #go to else
##changes number to text
do_it:  la $s7,list	#save list into the reg s7
	addi $t1,$t3,-48 # $t1= textData[i]-'0'
	add  $t1,$t1,$t1 #doubles reg t1
	add  $t1,$t1,$t1 #t1= 4*(textData[i]-'0') :do them to make t1 4 byte 
	add  $t9,$t1,$s7
	lw  $a0,0($t9)# a0 =list+textData[i]-'0' ; in C code:(digits[textData[i]-'0'])
	add $s0,$a0,$zero# save a0 into reg s0. s0=list+textData[i]-'0'
	jal strlen
	add $t5,$t0,$zero ### size2= list[textData[i]-'0']
	add $t4,$zero,$zero ### j=0
#####This for loop is used to traverse the list[textData[i]-'0'].
    for_in_if: slt $t0,$t4,$t5 # if j<size2 t0=1
	   beq $t0,$zero,exit2# go to exit2 to ending for_in_if
	   add $t6,$s0,$t4 ## $t6= j+list[textData[i]-'0']
	   lb $a0,0($t6) # $t7=list[textData[i]-'0'][j]
	   add $t8,$s6,$s2 # $t8=outData+k
	   beq $s1,$zero,L1#start with a capital letter if you have a number at the beginning of the paragraph.
	   addi $t0,$zero,1
	   beq $t0,$s1,L3
	   addi $t0,$zero,46# t0='.'
	   lb $t1,-2($t2)#$t1= textData[i-2]
	   bne $t0,$t1,L2#If the second character before the number is a dot, it starts with a capital letter. else got L2
L3:	   lb $t1,-1($t2)#$t1= textData[i-1]
	   addi $t0,$zero,32#t0=' '
	   bne $t0,$t1,L2#If the first character before the number is a space char, it starts with a capital letter. else got L2
L1:	   bne $t4,$zero,L2#Make only the first letter of the number large
	   jal capital     #makes capital letter
L2:	   sb $a0,0($t8) #$a0 is saved into reg t8
	   addi $s2,$s2,1 ## k++
	   addi $t4,$t4,1 ## j++
	   j for_in_if    ##loop
else: 	add $t8,$s6,$s2 # $t8=outData+k
	sb $t3,0($t8)   # else store textData[i] into outData[k].dont change textData[i] 
	addi $s2,$s2,1 #k++
exit2:
	addi $s1,$s1,1 #i++
	j for1st##loop
exit1:
	add $t8,$s6,$s2 #$t8=outData+k
	sb $0,0($t8)	#store null character to end of the outData
	li $v0,11
	lb $a0,newline #print newline onto console
	syscall
	li $v0,4
	la $a0,outData #print outData onto the console
	syscall
	####################
	jal strlen #calculate the size of the outData to writing into the input file
	jal write #wirte outData into the input file
	li $v0, 10#exit code
	syscall


write:       
  # Open (for writing) a file that does not exist
  li   $v0, 13       # system call for open file
  la   $a0, fileStr     # output file name
  li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0        # mode is ignored
  syscall            # open a file (file descriptor returned in $v0)
  move $s6, $v0      # save the file descriptor 
  # Write to file just opened
  li   $v0, 15       # system call for write to file
  move $a0, $s6      # file descriptor 
  la   $a1, outData   # address of buffer from which to write
  add   $a2,$zero,$t0       # hardcoded buffer length
  syscall            # write to file
  # Close the file 
  li   $v0, 16       # system call for close file
  move $a0, $s6      # file descriptor to close
  syscall            # close file
  jr $ra
  
  
strlen:
    addi $t0, $zero, -1 #initialize count to start with 1 for first character
loop:
    lb $t1, 0($a0) #load the next character to t0
    addi $a0, $a0, 1 #load increment string pointer
    addi $t0, $t0, 1 #increment count
    beqz $t1, exit #end loop if null character is reached
    j loop # return to top of loop
exit: jr $ra


capital:addi $a0,$a0,-32
	jr $ra


delete_newline:
    add $t0,$zero,$zero
    add $t1,$t1,$a0
loop2:	
    lb $a3,0($t1)  
    addi $t1, $t1, 1
    bne $a3,$zero,loop2       # Search the NULL char code
    beq $t1, $a1,exit3   # Check whether the buffer was fully loaded
    subi $t1, $t1, 2    # Otherwise 'remove' the last character
    sb $0, 0($t1)     # and put a NULL instead
exit3:jr $ra		
