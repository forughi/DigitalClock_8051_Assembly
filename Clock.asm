; ***** Digital Clock, A. F. Forughi, Aug. 2006 *****
; This code was developed for Atmel AT89C5X microcontrollers
; Hardware Pin connection: Second Blinking LED= P1.7 ***** Time: HH:MM => (P0)(P3):(P2)(P1) (only first 4-bite of each port)
; Switches: Minute set (add) SW= P1.6  ***  Minute reset (zero) SW= P2.4  ***   Hour set SW= P1.5 *** Pause SW= p1.4 

org 00h
mov tmod,#1b
m1 equ 20h
m3 equ 22h

;Testing the seven segments:
mov p0,#0d
mov p1,#0d
mov p2,#0d
mov p3,#0d
mov p0,#15d
mov p1,#15d
mov p2,#15d
mov p3,#15d
lcall halfsec
mov p1,#8d
lcall halfsec
mov p1,#15d
mov p2,#8d
lcall halfsec
mov p2,#15d
mov p3,#8d
lcall halfsec
mov p0,#8d
mov p3,#15d
lcall halfsec

; Kernel:
mov p0,#0b
mov p1,#0b
mov p2,#0b
mov p3,#0b

ljmp clock
clock:

	mov m3,#60d
	ljmp secview
	secview:
	
		;set keys
		jb p1.6,ovminp
		jb p1.5,uperfiveminp
		ljmp pause
		pause:jb p1.4,pausep
		jb p2.4,minrst

		lcall halfsec
		setb p1.7
		lcall halfsec
		clr p1.7
		djnz m3,secview

	ljmp ovmin
	ovmin:
		mov a,p1
		;clr for p1=9 not p1>9
		clr acc.6
		cjne a,#9d,undertenmin
		ljmp upertenmin

	pausep:
		mov m3,#60d
		ljmp pause

	undertenmin:
		inc p1
		ljmp clock

	upertenmin:
		mov a,p2
		cjne a,#5d,underfivemin
		ljmp uperfivemin

	underfivemin:
		mov p1,#0d
		inc p2
		ljmp clock

	uperfivemin:
		;Now the clock shows: XX:59 => add to hour

		mov p1,#0d
		mov p2,#0d

		mov a,p3
		cjne a,#3d,uneqfourhour
		ljmp eqfourhour

	uneqfourhour:
		mov a,p3
		cjne a,#9d,undertenhour
		ljmp upertenhour

	undertenhour:
		inc p3
		ljmp clock

	upertenhour:
		mov p3,#0d
		inc p0
		ljmp clock

	eqfourhour:
		mov a,p0
		cjne a,#2d,untwentyfour
		ljmp twentyfour

	untwentyfour:
		inc p3
		ljmp clock

	twentyfour:
		mov p3,#0d
		mov p0,#0d
		ljmp clock

	ovminp:
		lcall halfsec
		ljmp ovmin

	uperfiveminp:
		lcall halfsec
		ljmp uperfivemin

	minrst:
		mov p1,#0b
		mov p2,#0b
		ljmp pause

; ************** Half a sec delay for a 12MHz Xtal (Error=20us/day) *******************
; 10101111 +7 => 10110110 +52 => 11101010 -44 => 10111110 -6=> 10111000 +3=> 10111011 -1=> 10111010 -1=> 10111001
halfsec:
	mov m1,#10d
	ljmp loops
	loops:
		clr tr0
		clr tf0
		mov tl0,#10111001b
		mov th0,#111100b
		setb tr0
	loots: jnb tf0,loots
		djnz m1,loops
ret
;*************************************************************************

end
