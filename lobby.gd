extends Node

var server
var peer
export (String) var host = "127.0.0.1"
export (int) var port = 9999

var peers
var netopt
var HostButton
var JoinButton
var is_server

const ERR = 1

func _ready():

	# create peer
	peer = StreamPeerTCP.new()

	# create server
	server = TCP_Server.new()
	

	# init menu buttons
	HostButton = get_node("Lobby_Host_Button")
	HostButton.get_node("Lobby_Host_Port_text").add_text("Server Port")
	HostButton.get_node("Lobby_Host_Port").set_text("9999")
	HostButton.connect("pressed", self, "_on_lobby_host_start")
	
	JoinButton = get_node("Lobby_Join_Button")
	JoinButton.get_node("Lobby_Join_IP_text").add_text("Remote IP : Port")
	JoinButton.get_node("Lobby_Join_IP").set_text("127.0.0.1")
	JoinButton.get_node("Lobby_Join_Port").set_text("9999")
	JoinButton.connect("pressed", self, "_on_lobby_join_start")
	set_process(true)

func _on_selected_item(id):
	is_server = id == 0


func _on_lobby_host_start( ):
	print("[SERVER] init!")
	peers = []
	is_server = true
	port=HostButton.get_node("Lobby_Host_Port").get_text()
	server.listen(port)

func _on_lobby_join_start( ):
	print("[PEER] init!")
	host=JoinButton.get_node("Lobby_Join_IP").get_text()
	port=JoinButton.get_node("Lobby_Join_Port").get_text()
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

