extends "res://scripts/arm.gd"

func _init() -> void:
	action = "lock_right"
	keyUp = KEY_UP
	keyDown = KEY_DOWN
	keyLeft = KEY_LEFT
	keyRight = KEY_RIGHT
	YMAX = -160
	YMIN = 130
	XMAX = 250
	XMIN = 20
	lock_anim = "right_axe_lock"
	unlock_anim = "right_axe_unlock"
