extends Node2D

@onready var left_arm := $Left_arm
@onready var right_arm := $Right_arm

var on_ground := true

const gravity = 0.2
const defaultFallVelocity = 10
var fallVelocity = 10
const endHeight = -3600

func _ready() -> void:
	pass

func format_time_ms(ms: int) -> String:
	var total_seconds: int = ms / 1000
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]

func _process(_delta: float) -> void:
	if not Global.done:
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
			fallVelocity = defaultFallVelocity

		if unlocked:
			position.y += fallVelocity
			if not on_ground:
				fallVelocity += gravity
		elif velocityY or velocityX:
			fallVelocity = defaultFallVelocity
			position.y += velocityY
			position.x += velocityX
			left_arm.move_position(velocityX, velocityY)
			right_arm.move_position(velocityX, velocityY)

		# don't fall through the ground
		position.y = min(0, position.y)

		on_ground = position.y == 0
		if position.y < endHeight:
			Global.done = true
			var time = format_time_ms(Time.get_ticks_msec() - Global.start_time)
			$"Camera2D/End_screen/End_text".text = "Congratulations, you have summited the mountain!\nYou summited in " + time
			$"Camera2D/End_screen".visible = true


func _on_reset_pressed() -> void:
	position = Vector2(0, 0)
