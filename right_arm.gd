extends Node2D

var arm_locked := false
var velocity := 0

func _ready() -> void:
	pass

# moves opposite from the player if locked
func move_position(dist: int) -> void:
	if arm_locked:
		position.y -= dist
		position.y = max(-100, min(100, position.y))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("lock_right"):
		arm_locked = not arm_locked
		
	# red if locked
	if arm_locked:
		$Sprite2D.modulate = Color(1, 0.2, 0.2)
	else:
		$Sprite2D.modulate = Color(1, 1, 1)

	if not arm_locked:
		# regular movement
		if Input.is_key_pressed(KEY_UP):
			position.y = max(-100, position.y - 10)
		elif Input.is_key_pressed(KEY_DOWN):
			position.y = min(100, position.y + 10)
	else:
		# set velocity variable for player to use
		if Input.is_key_pressed(KEY_UP):
			velocity = -10
		elif Input.is_key_pressed(KEY_DOWN):
			velocity = 10
		else:
			velocity = 0
