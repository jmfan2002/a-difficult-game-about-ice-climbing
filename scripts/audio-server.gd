extends Node

var server: UDPServer
var client_pid: int

func _ready() -> void:
	# create godot server
	var port: int = 4242
	server = UDPServer.new()
	server.listen(port)
	
	# create python client
	client_pid = OS.create_process("wc", ["1"])
	#client_pid = OS.create_process("/Users/ethanpronev/miniconda3/bin/python3", ["res://python/client.py.txt", str(port)], true)
	print(client_pid)

func _process(_delta: float) -> void:
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		print("Received: '%s' %s:%s" % [packet.get_string_from_utf8(), peer.get_packet_ip(), peer.get_packet_port()])

		peer.put_packet("Hello from Godot!".to_utf8_buffer())
