extends "res://scripts/arm.gd"

func _init() -> void:
	action = "lock_right"
	keyUp = KEY_UP
	keyDown = KEY_DOWN
	keyLeft = KEY_LEFT
	keyRight = KEY_RIGHT
	YMAX = -220
	YMIN = 200
	XMAX = 350
	XMIN = 20
