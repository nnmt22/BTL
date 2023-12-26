.data
    input_file: .asciiz "D:/INT2.BIN"
    result_str: .asciiz "Kết quả: "
    buffer: .space 4    # Khai báo buffer với kích thước 4 byte

	.text
	.globl main

main:
    	# Mở file để đọc
    	li $v0, 13           # system call cho mở file
    	la $a0, input_file   # tên file
    	li $a1, 0            # cờ cho việc đọc
	li $a2, 0            # mode (bị bỏ qua)
    	syscall
    
    	move $s0, $v0        # lưu file descriptor
    
	# Đọc số nguyên 32-bit đầu tiên
	li $v0, 14           # system call cho đọc từ file
	move $a0, $s0        # file descriptor
	la $a1, buffer       # bộ đệm để đọc vào
	li $a2, 4            # số byte cần đọc
	
	# Chắc chắn rằng địa chỉ bộ nhớ là bội số của 4
	andi $t0, $a1, 0x3    # $t0 chứa phần dư khi chia địa chỉ cho 4
	bnez $t0, not_aligned_buffer
	nop

	# Địa chỉ là bội số của 4, thực hiện lệnh đọc
	lw $t0, 0($a1)       # nạp số nguyên đầu tiên vào $t0
	syscall
	j end_read
	nop

	not_aligned_buffer:
    	# Địa chỉ không phải là bội số của 4, sử dụng địa chỉ mới được căn chỉnh
    	sub $a1, $a1, $t0
    	lw $t0, 0($a1)     # nạp số nguyên đầu tiên vào $t0
    	syscall

	end_read:

	# Đọc số nguyên 32-bit thứ hai
	li $v0, 14           # system call cho đọc từ file	
	move $a0, $s0        # file descriptor
	la $a1, buffer + 4   # bộ đệm để đọc vào, di chuyển đến phần byte thứ 5
	li $a2, 4            # số byte cần đọc

	# Chắc chắn rằng địa chỉ bộ nhớ là bội số của 4
	andi $t1, $a1, 0x3    # $t1 chứa phần dư khi chia địa chỉ cho 4
	bnez $t1, not_aligned_buffer2
	nop

	# Địa chỉ là bội số của 4, thực hiện lệnh đọc
	lw $t1, 0($a1)       # nạp số nguyên thứ hai vào $t1
	syscall
	j end_read2
	nop

	not_aligned_buffer2:
    # Địa chỉ không phải là bội số của 4, sử dụng địa chỉ mới được căn chỉnh
    sub $a1, $a1, $t1
    lw $t1, 0($a1)     # nạp số nguyên thứ hai vào $t1
    syscall

	end_read2:
    
    # Đóng file
    li $v0, 16           # system call cho đóng file
    move $a0, $s0        # file descriptor
    syscall
    
    # Thực hiện phép chia
    div $t1, $t0          # chia $t1 cho $t0
    mflo $t2              # phần thương trong $t2
    mfhi $t3              # phần dư trong $t3
    
    # In kết quả
    li $v0, 4            # system call cho in chuỗi
    la $a0, result_str   # load địa chỉ của result_str vào $a0
    syscall
    
    li $v0, 1            # system call cho in số nguyên
    move $a0, $t2        # load phần thương vào $a0
    syscall
    
    # Thoát chương trình
    li $v0, 10           # system call cho thoát
    syscall
