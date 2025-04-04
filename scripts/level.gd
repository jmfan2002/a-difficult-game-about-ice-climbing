extends Node2D

var started := false

func _process(_delta: float) -> void:
	if $Player.position.y != 0:
		started = true

	# show reset button if player falls down away from the starting area
	$Player/Camera2D/Reset.visible = started and $Player.on_ground and abs($Player.position.x) > 100
