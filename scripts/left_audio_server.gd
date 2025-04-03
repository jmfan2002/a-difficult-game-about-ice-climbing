extends "res://scripts/audio-server.gd"

func _init() -> void:
	device_idx = Global.selected_devices[0]
	port = 4242
