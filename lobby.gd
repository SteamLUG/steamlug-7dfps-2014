extends Node

var server
var peer
var host
var port

var peers
var netopt
var netstart
var is_server

const ERR = 1


func _ready():

	host = "127.0.0.1"
	port = 9999

	# create peer
	peer = StreamPeerTCP.new()

	# create server
	server = TCP_Server.new()
	is_server = true

	# init netmode option
	netopt = get_node("NetOption")
	netopt.connect("item_selected", self, "_on_selected_item")
	netopt.add_item("server", 0)
	netopt.add_item("peer", 1)

	# init netmode start button
	netstart = get_node("StartButton")
	netstart.connect("pressed", self, "_on_netmode_start")

	set_process(true)


func _on_selected_item(id):
	is_server = id == 0


func _on_netmode_start( ):
	if is_server:
		print("[SERVER] init!")
		peers = []
		server.listen(port)
	else:
		print("[PEER] init!")
		if peer.connect(host, port) == ERR:
			print("[PEER] connection to ", host, ":", port, "... FAIL!")
		else:
			print("[PEER] connection to ", host, ":", port, "... SUCCESS!")
		server.stop()

func _process(delta):
	if is_server:
		if server.is_connection_available():
			var newpeer = server.take_connection()
			print("[SERVER] new peer, ", newpeer)
			peers.append(newpeer)

