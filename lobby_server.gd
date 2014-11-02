extends Node

var server
var clients

func _ready():
	clients = []
	server = TCP_Server.new()
	set_process(true)
	pass

func _process(delta):
	server.listen(666)
	if server.is_connection_available():
		clients.append(server.take_connection())
