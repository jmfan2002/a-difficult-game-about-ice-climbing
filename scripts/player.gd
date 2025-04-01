extends Node2D

var left_arm
var right_arm

func _ready() -> void:
	left_arm = get_node("Left_arm")
	right_arm = get_node("Right_arm")

func _process(delta: float) -> void:
	var unlocked = not left_arm.arm_locked and not right_arm.arm_locked
	
	var velocity = left_arm.velocity + right_arm.velocity
	# set movement to 0 if on an edge
	if velocity < 0 and (left_arm.position.y == 100 or right_arm.position.y == 100) or velocity > 0 and (left_arm.position.y == -100 or right_arm.position.y == -100):
		left_arm.velocity = 0
		right_arm.velocity = 0
		velocity = 0

	if unlocked:
		position.y += 10
	elif velocity:
		position.y += velocity
		left_arm.move_position(velocity)
		right_arm.move_position(velocity)
	position.y = min(0, position.y)
