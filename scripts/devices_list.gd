extends ItemList

var selected_devices: PackedInt32Array
var devices_lookup: Array

var python_cmd := "import sounddevice as sd; import json;
device_dict = {}
for index, dev in enumerate(sd.query_devices()):
	if dev['max_input_channels'] > 0 and dev['name'] not in device_dict:
		device_dict[dev['name']] = index
print(json.dumps(device_dict))"

func _ready() -> void:
	clear()

	var output: Array[String] = []
	OS.execute(Global.python, ["-c", python_cmd], output)
	var devices: Dictionary = JSON.parse_string(output.pop_back())
	print(devices)
	for device_name in devices:
		add_item(device_name)
		devices_lookup.push_back(devices[device_name])

func _process(_delta: float) -> void:
	var items := get_selected_items()
	selected_devices = Array(items).map(func(idx): return devices_lookup[idx])
