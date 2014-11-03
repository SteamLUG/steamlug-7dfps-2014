extends Node

var server
var peer
export (String) var host
var port

var peers
var netopt
var netstart
var is_server


func _ready():

	host = "127.0.0.1"
	port = 9999

	# create peer
	peer = StreamPeerTCP.new()

	# create server
	server = TCP_Server.new()
	is_server = true


	set_process(true)


func _on_selected_item(id):
	is_server = id == 0


func _on_netmode_start( ):
	if is_server:
		print("server netmode init!")
		peers = []
		server.listen(port)
	else:
		print("peer netmode init!")
		peer.connect(host, port)
		server.stop()

func _process(delta):
	if is_server:
		if server.is_connection_available():
			peers.append(server.take_connection())

