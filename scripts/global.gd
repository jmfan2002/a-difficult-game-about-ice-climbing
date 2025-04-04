extends Node

var selected_devices: Array
# TODO: terrible
var python: String = \
	"/Users/ethanpronev/miniconda3/bin/python3" if OS.get_name() == "macOS" else "python3"

var done := false

var start_time: int
