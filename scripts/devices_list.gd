extends ItemList

var selected_devices: PackedInt32Array

func _ready() -> void:
	clear()

	# TODO: process the output to look nicer + exclude output devices
	var output: Array[String] = []
	OS.execute("python", ["-m", "sounddevice"], output)
	var devices: PackedStringArray = output.pop_back().split("\n")
	for device in devices:
		add_item(device)


func _process(delta: float) -> void:
	selected_devices = get_selected_items()
