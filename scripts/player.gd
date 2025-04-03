extends Node2D

@onready var left_arm := $Left_arm
@onready var right_arm := $Right_arm

var fallVelocity = 10

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var unlocked = not left_arm.arm_locked and not right_arm.arm_locked
	
	var velocity = left_arm.velocity + right_arm.velocity
	# set movement to 0 if on an edge
	if velocity < 0 and (left_arm.position.y == left_arm.YMIN and left_arm.arm_locked or right_arm.position.y == right_arm.YMIN and right_arm.arm_locked) or \
	velocity > 0 and (left_arm.arm_locked and left_arm.position.y == left_arm.YMAX or right_arm.arm_locked and right_arm.position.y == right_arm.YMAX):
		left_arm.velocity = 0
		right_arm.velocity = 0
		velocity = 0
	
	# set downwards movement to 0 if at the bottom
	if velocity > 0 and position.y == 0:
		velocity = 0

	if unlocked:
		position.y += fallVelocity
	elif velocity:
		position.y += velocity
		left_arm.move_position(velocity)
		right_arm.move_position(velocity)
	position.y = min(0, position.y)
