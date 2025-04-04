extends Node2D

# selected audio device (set in each arm)
var device_idx: int

var port: int

# arm control
var arm: Area2D
var last_clap_snap: int = 0  # ms
const clap_snap_timeout: int = 500  # ms

func _thread_func(pipe: FileAccess, stream: String):
	# read pipe and print
	while pipe.is_open() and pipe.get_error() == OK:
		var s = pipe.get_line()
		if (pipe.get_error() == OK):
			if (stream == "stderr"):
				print("python debug: ", s)
			else:
				handle_signal(s)

func _clean_func(pipe_io: FileAccess, pipe_err: FileAccess, thread_io: Thread, thread_err: Thread):
	print("closing...")
	# send newline to python client to terminate it
	pipe_io.store_8(0x08)
	# close pipes and cleanup
	pipe_io.close()
	pipe_err.close()
	thread_io.wait_to_finish()
	thread_err.wait_to_finish()

func _ready() -> void:
	# create python client
	var python_script_path = ProjectSettings.globalize_path("res://python/godot_client.py")
	var res = OS.execute_with_pipe(Global.python, [python_script_path, str(port), str(device_idx)])
	print("created client with pid %s" % res["pid"])
	# create threads to listen to io/err streams
	var thread_io = Thread.new()
	var thread_err = Thread.new()
	thread_io.start(_thread_func.bind(res["stdio"], "stdio"))
	thread_err.start(_thread_func.bind(res["stderr"], "stderr"))
	get_window().close_requested.connect(_clean_func.bind(res["stdio"], res["stderr"], thread_io, thread_err))
	
	arm = get_parent()

func handle_signal(sig: String) -> void:
	if (sig == "PITCH_NONE"):
		# always handle pitch none events
		arm.pitchUp = false
		arm.pitchDown = false
	elif (sig == "VOL_NONE"):
		arm.volUp = false
		arm.volDown = false
	else:
		var ts = Time.get_ticks_msec()
		if (ts - last_clap_snap < clap_snap_timeout):
			# ignore all other events during the cooldown after a clap/snap
			return
		match sig:
			"PITCH_UP":
				arm.pitchUp = true
				arm.pitchDown = false
			"PITCH_DOWN":
				arm.pitchUp = false
				arm.pitchDown = true
			"VOL_UP":
				arm.volUp = true
				arm.volDown = false
			"VOL_DOWN":
				arm.volUp = false
				arm.volDown = true
			"CLAP":
				if arm.has_overlapping_areas():
					arm.trigger_anim = true
					last_clap_snap = ts
			"SNAP":
				if arm.has_overlapping_areas():
					arm.trigger_anim = true
					last_clap_snap = ts

func _process(_delta: float) -> void:
	pass
