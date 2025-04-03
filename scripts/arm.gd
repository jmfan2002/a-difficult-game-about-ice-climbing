extends Node2D

@onready var line := $Line2D
@onready var sprite := $Sprite2D

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
var velocityX := 0
var velocityY := 0

const YMAX = -100
const YMIN = 100
const XMAX = 150
const XMIN = -150
const armVelocity = 3  # velocity that the arm moves when unlocked
const pullVelocity = 3  # velocity contributed by the arm to the player's movement when locked 

const SEGMENTS := 20  # how many points in the noodle
const DROOP := 40     # how much it sags in the middle
const LAG := 100.0      # smoothness (lower is slower)
var points := []

func _ready() -> void:
	for i in SEGMENTS:
		points.append(get_parent().global_position.lerp(sprite.global_position, float(i) / (SEGMENTS - 1)))

func _physics_process(delta):
	for i in SEGMENTS:
		var t = float(i) / (SEGMENTS - 1)

		# Ideal straight-line position
		var ideal = get_parent().global_position.lerp(sprite.global_position, t)

		# Add droop (more in the middle)
		var droop_offset = Vector2(0, sin(t * PI) * DROOP)

		# Smoothly move current point toward the droopy target
		points[i] = points[i].lerp(ideal + droop_offset, delta * LAG)

	line.points = points.map(func(p): return to_local(p))

# moves opposite from the player if locked
func move_position(x: int, y: int) -> void:
	if arm_locked:
		position.x -= x
		position.x = min(XMAX, max(XMIN, position.x))
		position.y -= y
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
			velocityY = -pullVelocity
		elif Input.is_key_pressed(keyDown) or pitchDown:
			velocityY = pullVelocity
		else:
			velocityY = 0

		if Input.is_key_pressed(keyLeft) or volDown:
			velocityX = -pullVelocity
		elif Input.is_key_pressed(keyRight) or volUp:
			velocityX = pullVelocity
		else:
			velocityX = 0
