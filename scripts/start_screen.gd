extends Control

var next_scene = preload("res://scenes/Level.tscn")

func _process(delta: float) -> void:
	$Play_button.disabled = $Devices_list.selected_devices.size() != 2

func _on_play_button_pressed() -> void:
	Global.selected_devices = Array($Devices_list.selected_devices)
	get_tree().change_scene_to_packed(next_scene)
