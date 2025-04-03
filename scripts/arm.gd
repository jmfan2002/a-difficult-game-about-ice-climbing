extends Node2D

# virtual vars set in each arm
var action
var keyUp
var keyDown
var keyLeft
var keyRight

var pitchUp = false
var pitchDown = false
var volUp = false
var volDown = false

var arm_locked := false
var velocity := 0

const YMAX = -100
const YMIN = 100
const XMAX = 150
const XMIN = -150
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
		if Input.is_key_pressed(keyUp) or pitchUp:
			position.y = max(YMAX, position.y - armVelocity)
		elif Input.is_key_pressed(keyDown) or pitchDown:
			position.y = min(YMIN, position.y + armVelocity)
			
		if Input.is_key_pressed(keyLeft) or volDown:
			position.x = max(XMIN, position.x - armVelocity)
		elif Input.is_key_pressed(keyRight) or volUp:
			position.x = min(XMAX, position.x + armVelocity)
	else:
		# set velocity variable for player to use
		if Input.is_key_pressed(keyUp) or pitchUp:
			velocity = -pullVelocity
		elif Input.is_key_pressed(keyDown) or pitchDown:
			velocity = pullVelocity
		else:
			velocity = 0
