extends Control

var level_scene = preload("res://scenes/Level.tscn")
var how_to_scene =preload("res://scenes/How_to.tscn")

func _process(_delta: float) -> void:
	$Play_button.disabled = $Devices_list.selected_devices.size() != 2

func _on_play_button_pressed() -> void:
	Global.selected_devices = Array($Devices_list.selected_devices)
	get_tree().change_scene_to_packed(level_scene)

func _on_how_to_button_pressed() -> void:
	get_tree().change_scene_to_packed(how_to_scene)
