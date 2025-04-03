extends Node2D

# selected audio device (set in each arm)
var device_idx

# UDP server to receive data
var server: UDPServer

var left_arm
var right_arm

func _thread_func(pipe: FileAccess, stream: String):
	# read pipe and print
	while pipe.is_open() and pipe.get_error() == OK:
		var s = pipe.get_line()
		if (pipe.get_error() == OK):
			print("python ", stream, ": ", s)

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
	# create godot server
	var port: int = 4242
	server = UDPServer.new()
	server.listen(port)
	
	# create python client
	var python_script_path = ProjectSettings.globalize_path("res://python/udp_client.py")
	var res = OS.execute_with_pipe("python3", [python_script_path, str(port), str(device_idx)])
	print("created client with pid %s" % res["pid"])
	# create threads to listen to io/err streams
	var thread_io = Thread.new()
	var thread_err = Thread.new()
	thread_io.start(_thread_func.bind(res["stdio"], "stdio"))
	thread_err.start(_thread_func.bind(res["stderr"], "stderr"))
	get_window().close_requested.connect(_clean_func.bind(res["stdio"], res["stderr"], thread_io, thread_err))
	
	left_arm = get_node("../../Left_arm")
	right_arm = get_node("../../Right_arm")

func handle_signal(sig: String) -> void:
	match sig:
		"PITCH_UP":
			left_arm.audioUp = true
			left_arm.audioDown = false
		"PITCH_DOWN":
			left_arm.audioUp = false
			left_arm.audioDown = true
		"PITCH_NONE":
			left_arm.audioUp = false
			left_arm.audioDown = false
		"CLAP":
			left_arm.arm_locked = not left_arm.arm_locked
		"SNAP":
			right_arm.arm_locked = not right_arm.arm_locked

func _process(_delta: float) -> void:
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		var data = packet.get_string_from_utf8()
		#print("Received: '%s' %s:%s" % [
			#data,
			#peer.get_packet_ip(),
			#peer.get_packet_port()
		#])
		handle_signal(data)
