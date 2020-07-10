#
# This file demonstrates a bug with the RARS's Keyboard and Display MMIO Simulator. 
#
# To reproduce the bug follow these steps:
#
#	1. Open the "Keyboard and Display MMIO Simulator" from the "Tools" menu
#	2. Assemble the program
#	3. Connect the Keyboard and Display Simulator to the program
#	4. Run the program
#	5. Begin entering characters into the KEYBOARD section
#
# RARS should freeze after one or two keypresses.
#


.text
main:
#	load MMIO register addresses
li	s0, 0xFFFF0008		# s0 <- Adr[DISPLAY_CONTROL]
li	s1, 0xFFFF000C		# s1 <- Adr[DISPLAY_DATA]
	
#	load characters that will be stored in DISPLAY_DATA later
li	s2, 0x30		# s2 <- 0x00000030
li	s3, 0x7			# s3 <- 0x00000007
	
forever:	
		#	wait for display to be ready to move cursor
		lw	t0, 0(s0)		# t0 <- DISPLAY_CONTROL
		andi	t0, t0, 0x1		# t0 <- 0th bit of DISPLAY_CONTROL
		beqz	t0, forever		# if (t0 == 0) goto forever
	
	#	move cursor to row=0 and col=0
	sw	s3, 0(s1)		# DISPLAY_DATA <- 0x00000007
	
waitForDisplay2:	
		#	wait for display to be ready to print '0'
		lw	t0, 0(s0)		# t0 <- DISPLAY_CONTROL
		andi	t0, t0, 0x1		# t0 <- 0th bit of DISPLAY_CONTROL
		beqz	t0, waitForDisplay2	# if (t0 == 0) goto waitForDisplay2
	
	#	print '0'
	sb	s2, 0(s1)		# DISPLAY_DATA <- 0x00000030
	
	j	forever			# goto forever
