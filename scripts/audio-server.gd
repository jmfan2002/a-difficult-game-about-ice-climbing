extends Node2D

# UDP server to receive data
var server: UDPServer

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
	var res = OS.execute_with_pipe("/Users/ethanpronev/miniconda3/bin/python3", [python_script_path, str(port)])
	print("created client with pid %s" % res["pid"])
	# create threads to listen to io/err streams
	var thread_io = Thread.new()
	var thread_err = Thread.new()
	thread_io.start(_thread_func.bind(res["stdio"], "stdio"))
	thread_err.start(_thread_func.bind(res["stderr"], "stderr"))
	get_window().close_requested.connect(_clean_func.bind(res["stdio"], res["stderr"], thread_io, thread_err))

func _process(_delta: float) -> void:
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		print("Received: '%s' %s:%s" % [
			packet.get_string_from_utf8(),
			peer.get_packet_ip(),
			peer.get_packet_port()
		])
