; Nightbox BIOS
; Written by yeti0904, starting 9th of November 2023
; Expects to be loaded at 0x050000

;;;;;;;;;;;;;;;;;;;;;;;;
;         boot         ;
;;;;;;;;;;;;;;;;;;;;;;;;

; set video mode to 40x40 text mode (mode 0x00)
lda ds 1028
set a 0
wrb ds a
set a 2
set b 77
out a b

; load font
set a 2
set b 70
out a b

; load palette
set a 2
set b 80
out a b

; set screen colours to white text on black background
set a 0x07
lda ds 0x18B5
set c 3200
setl a

; clear screen
lda ds 1029
set c 3200
set a 32
setl a

; print boot message
lda sr boot_msg
lda ds 1029
call print_str

; set up interrupt
lda ab 68
set c 1
incp ab
lda ef interrupt
wra ab ef

; search for disks
set d 0x16 ; iterator
disk_loop:
	actv d
	jnz boot_disk
	inc d
	set a 256
	cmp d a
	jnz no_disk
	jmp disk_loop

boot_disk:
	lda ds 0x060000
	set a 82
	out d a
	set a 0
	out d a
	set a 1
	out d a
	set c 512
	in d

read_disk:
	in d
	wrb ds a
	incp ds
	dec c
	cpr a c
	jnz read_disk
	; jump to booted disk
	set a 34
	jmp 0x060000

no_disk:
	lda ds 1269
	lda sr no_disk_msg
	call print_str
	jmp end

boot_msg:
	db "NightboxBIOS boot                                                               Searching devices..." 0

no_disk_msg:
	db "No disks connected to system, press any key to shut down" 0

end:
	set a 1
	chk a
	jz end
	hlt

;;;;;;;;;;;;;;;;;;;;;;;;
;       functions      ;
;;;;;;;;;;;;;;;;;;;;;;;;

print_str:
	; Parameters
	; sr = string
	; ds = where to print
	; Changes: sr, ds, a
	rdb sr
	jz print_str_end
	wrb ds a
	incp sr
	incp ds
	jmp print_str
print_str_end:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;
;          API         ;
;;;;;;;;;;;;;;;;;;;;;;;;

disk_api:
	; Parameters
	; a = API ID
	; Changes: i
	set i 0
	cmp a i
	jnz disk_api_read_disk
	set i  1
	cmp a i
	jnz disk_api_write_disk
	ret

disk_api_read_disk:
	; Parameters
	; b  = sector start
	; c  = amount of sectors
	; d  = disk
	; ds = location
	; Changes: a, c, f
	set a 82
	out d a
	out d b
	out d c
	set f 512
	mul c f
	in d
disk_api_read_disk_loop:
	in d
	wrb ds d
	dec c
	incp ds
	cpr a c
	jz disk_api_read_disk_end
	jmp disk_api_read_disk_loop
disk_api_read_disk_end:
	ret

disk_api_write_disk:
	; Parameters
	; b  = sector
	; d  = disk
	; sr = location
	; Changes: c
	set a 82
	out d a
	out d b
	set c 512
disk_api_write_disk_loop:
	rdb sr
	out d a
	dec c
	incp sr
	cpr a c
	jz disk_api_write_disk_end
	jmp disk_api_write_disk_loop
disk_api_write_disk_end:
	ret ; why did i not add local labels

interrupt:
	; TODO lol
	ret

