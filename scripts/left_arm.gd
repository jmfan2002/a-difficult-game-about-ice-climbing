extends "res://scripts/arm.gd"

func _init() -> void:
	action = "lock_left"
	keyUp = KEY_W
	keyDown = KEY_S
	keyLeft = KEY_A
	keyRight = KEY_D
	YMAX = -220
	YMIN = 200
	XMAX = -20
	XMIN = -350
