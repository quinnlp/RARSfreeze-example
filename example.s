.text
main:
# 	enable user-level interrupts
csrwi	0, 0x1			# ustatus <- 0x00000001
	
#	enable user-level external interrupts
csrwi	4, 0x100		# uie <- 0x00000100
	
#	store handler address
la	t0, handler		# t0 <- Addr[handler]
csrw	t0, 5			# utvec <- Addr[handler]
	
#	enable keyboard interrupts
#li	t0, 0xFFFF0000		# t0 <- Addr[KEYBOARD_CONTROL]
#li	t1, 0x2			# t1 <- 0x00000002
#sw	t1, 0(t0)		# KEYBOARD_CONTROL <- 0x00000002
	
#	load MMIO register addresses
li	s0, 0xFFFF0008		# s0 <- Adr[DISPLAY_CONTROL]
li	s1, 0xFFFF000C		# s1 <- Adr[DISPLAY_DATA]
	
#	load characters that will be stored in DISPLAY_DATA later
li	s2, 0x31		# s2 <- 0x00000031
li	s3, 0x7			# s3 <- 0x00000007
	
	
forever:	
		#	wait for display to be ready to move cursor
		lw	t0, 0(s0)		# t0 <- DISPLAY_CONTROL
		andi	t0, t0, 0x1		# t0 <- 0th bit of DISPLAY_CONTROL
		beqz	t0, forever		# if (t0 == 0) goto forever
	
	#	move cursor to row=0 and col=0
	sw	s3, 0(s1)		# DISPLAY_DATA <- 0x00000007

waitForDisplay2:	
		#	wait for display to be ready to print '1'
		lw	t0, 0(s0)		# t0 <- DISPLAY_CONTROL
		andi	t0, t0, 0x1		# t0 <- 0th bit of DISPLAY_CONTROL
		beqz	t0, waitForDisplay2	# if (t0 == 0) goto waitForDisplay2
	
	#	print '1'
	sb	s2, 0(s1)		# DISPLAY_DATA <- 0x00000031
	
	j	forever			# goto forever


handler:
	uret			# return execution
