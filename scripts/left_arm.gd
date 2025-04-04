extends "res://scripts/arm.gd"

func _init() -> void:
	action = "lock_left"
	keyUp = KEY_W
	keyDown = KEY_S
	keyLeft = KEY_A
	keyRight = KEY_D
	YMAX = -160
	YMIN = 130
	XMAX = -20
	XMIN = -250
	lock_anim = "left_axe_lock"
	unlock_anim = "left_axe_unlock"
