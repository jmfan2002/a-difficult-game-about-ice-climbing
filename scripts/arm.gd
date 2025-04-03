extends Node2D

# virtual vars set in each arm
var action
var keyUp
var keyDown

var audioUp = false
var audioDown = false

var arm_locked := false
var velocity := 0

const YMAX = -100
const YMIN = 100
const armVelocity = 1  # velocity that the arm moves when unlocked
const pullVelocity = 1  # velocity contributed by the arm to the player's movement when locked 

func _ready() -> void:
	pass

# moves opposite from the player if locked
func move_position(dist: int) -> void:
	if arm_locked:
		position.y -= dist
		position.y = max(YMAX, min(YMIN, position.y))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(action):
		arm_locked = not arm_locked
		
	# red if locked
	if arm_locked:
		$Sprite2D.modulate = Color(1, 0.2, 0.2)
	else:
		$Sprite2D.modulate = Color(1, 1, 1)

	if not arm_locked:
		# regular movement
		if Input.is_key_pressed(keyUp) or audioUp:
			position.y = max(YMAX, position.y - armVelocity)
		elif Input.is_key_pressed(keyDown) or audioDown:
			position.y = min(YMIN, position.y + armVelocity)
	else:
		# set velocity variable for player to use
		if Input.is_key_pressed(keyUp) or audioUp:
			velocity = -pullVelocity
		elif Input.is_key_pressed(keyDown) or audioDown:
			velocity = pullVelocity
		else:
			velocity = 0
