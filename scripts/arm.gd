extends Area2D

@onready var line := $Line2D
@onready var sprite := $Sprite2D

# virtual vars set in each arm
var action: String
var keyUp: Key
var keyDown: Key
var keyLeft: Key
var keyRight: Key
var YMAX: int
var YMIN: int
var XMAX: int
var XMIN: int
var lock_anim: String
var unlock_anim: String

var pitchUp = false
var pitchDown = false
var volUp = false
var volDown = false

var arm_locked := false
var trigger_anim := false
var velocityX := 0
var velocityY := 0

const armVelocity = 5  # velocity that the arm moves when unlocked
const pullVelocity = 5  # velocity contributed by the arm to the player's movement when locked 

# for generating the arm line
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
	if not Global.done:
		# only lockable if the character is overlapping with a lockable wall
		if Input.is_action_just_pressed(action) and has_overlapping_areas():
			trigger_anim = true

		if trigger_anim:
			arm_locked = not arm_locked
			var anim_player: AnimationPlayer = get_node(^"/root/Level/Player/AnimationPlayer")
			var anim := lock_anim if arm_locked else unlock_anim
			anim_player.play(anim)
			trigger_anim = false

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
