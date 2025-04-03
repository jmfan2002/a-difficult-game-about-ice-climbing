extends Node2D

@onready var left_arm := $Left_arm
@onready var right_arm := $Right_arm

var fallVelocity = 10

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var unlocked = not left_arm.arm_locked and not right_arm.arm_locked
	
	var velocityY = left_arm.velocityY + right_arm.velocityY
	var velocityX = left_arm.velocityX + right_arm.velocityX

	# set movement to 0 if on an edge
	if velocityY < 0 and (left_arm.position.y == left_arm.YMIN and left_arm.arm_locked or right_arm.position.y == right_arm.YMIN and right_arm.arm_locked) or \
	velocityY > 0 and (left_arm.arm_locked and left_arm.position.y == left_arm.YMAX or right_arm.arm_locked and right_arm.position.y == right_arm.YMAX):
		left_arm.velocityY = 0
		right_arm.velocityY = 0
		velocityY = 0
		
	# set movement to 0 if on an edge
	if velocityX > 0 and (left_arm.position.x == left_arm.XMIN and left_arm.arm_locked or right_arm.position.x == right_arm.XMIN and right_arm.arm_locked) or \
	velocityX < 0 and (left_arm.arm_locked and left_arm.position.x == left_arm.XMAX or right_arm.arm_locked and right_arm.position.x == right_arm.XMAX):
		left_arm.velocityX = 0
		right_arm.velocityX = 0
		velocityX = 0
	
	# set downwards movement to 0 if at the bottom
	if velocityY > 0 and position.y == 0:
		velocityY = 0

	if unlocked:
		position.y += fallVelocity
	elif velocityY or velocityX:
		position.y += velocityY
		position.x += velocityX
		left_arm.move_position(velocityX, velocityY)
		right_arm.move_position(velocityX, velocityY)
	
	# don't fall through the ground
	position.y = min(0, position.y)
