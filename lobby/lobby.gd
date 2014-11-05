extends Node

var server
var peer
export (String) var host = "127.0.0.1"
export (int) var port = 9999

const NET_NAME = 1
const NET_CHAT = 2


var peers         #array of StreamPeerTCP objects
var peernames     #array of player names

var PlayerName
var HostButton
var JoinButton
var StopServerButton
var DisconnectButton
var LobbyChat
var EnterChat
var PlayerList

var is_server

func _ready():

	# create peer
	peer = StreamPeerTCP.new()

	# create server
	server = TCP_Server.new()
	

	# init text and buttons
	
	PlayerName = get_node("Lobby_Name_Area/Lobby_Player_Name")
	PlayerName.get_node("Lobby_Name_Text").add_text("Name:")
	PlayerName.set_text("Player1")
	
	HostButton = get_node("Lobby_Host_Area/Lobby_Host_Button")
	HostButton.get_node("Lobby_Host_Port_text").add_text("Server Port")
	HostButton.get_node("Lobby_Host_Port").set_text(str(port))
	HostButton.connect("pressed", self, "_on_lobby_host_start")
	
	JoinButton = get_node("Lobby_Join_Area/Lobby_Join_Button")
	JoinButton.get_node("Lobby_Join_IP_text").add_text("Remote IP : Port")
	JoinButton.get_node("Lobby_Join_IP").set_text(host)
	JoinButton.get_node("Lobby_Join_Port").set_text(str(port))
	JoinButton.connect("pressed", self, "_on_lobby_join_start")
	
	StopServerButton = get_node("Lobby_Host_Area/Lobby_Stop_Server_Button")
	StopServerButton.connect("pressed", self, "_on_lobby_stop_server")
	StopServerButton.set_disabled(true)
	
	DisconnectButton = get_node("Lobby_Join_Area/Lobby_Disconnect_Button")
	DisconnectButton.connect("pressed", self, "_on_lobby_disconnect")
	DisconnectButton.set_disabled(true)
	
	LobbyChat = get_node("Lobby_Chat_Area/Lobby_Chat")
	
	EnterChat = get_node("Lobby_Chat_Area/Lobby_Enter_Chat")
	EnterChat.connect("text_entered", self, "_on_enter_chat")
	
	PlayerList = get_node("Lobby_Chat_Area/Lobby_Player_List")
	PlayerList.add_text("Players:")
	PlayerList.newline()
	
	set_process(true)

#add server browser later?
#func _on_selected_item(id):
#	is_server = id == 0


func _chat ( text ):
	LobbyChat.add_text(text)
	LobbyChat.newline()

func _on_enter_chat( text ):
	if is_server:
		text=str("<",PlayerName.get_text(),">",text)
		_chat(text)
		for apeer in peers:
			_net_tcp_send(apeer, NET_CHAT, text)
	else:
		_net_tcp_send(peer, NET_CHAT, text)
	EnterChat.clear()

func _on_lobby_stop_server( ):
	HostButton.set_disabled(false)
	JoinButton.set_disabled(false)
	StopServerButton.set_disabled(true)
	DisconnectButton.set_disabled(true)
	PlayerName.set_editable(true)
	server.stop()
	_chat("[SERVER] stopped.")

func _on_lobby_disconnect( ):
	JoinButton.set_disabled(false)
	DisconnectButton.set_disabled(true)
	PlayerName.set_editable(true)
	peer.disconnect()
	_chat("[PEER] disconnected.")

func _on_lobby_host_start( ):
	HostButton.set_disabled(true)
	JoinButton.set_disabled(true)
	StopServerButton.set_disabled(false)
	DisconnectButton.set_disabled(false)
	_chat("[SERVER] init!")
	peers = []
	peernames = []
	is_server = true
	port=HostButton.get_node("Lobby_Host_Port").get_text()
	PlayerList.add_text(PlayerName.get_text())
	PlayerList.newline()
	server.listen(port)


func _on_lobby_join_start( ):
	var status=0
	var start_time=0
	var check_time=0
	HostButton.set_disabled(true)
	JoinButton.set_disabled(true)
	PlayerName.set_editable(false)
	_chat("[PEER] init!")
	host=JoinButton.get_node("Lobby_Join_IP").get_text()
	port=JoinButton.get_node("Lobby_Join_Port").get_text()
	peer.connect(host, port)
	status=peer.get_status()
	start_time=OS.get_ticks_msec()
	
	#wait for connection, timeout after 5 seconds
	while (status < StreamPeerTCP.STATUS_CONNECTED) && (check_time - start_time < 5000):
		check_time=OS.get_ticks_msec()
		status=peer.get_status()
	
	if status == StreamPeerTCP.STATUS_CONNECTED:
		_chat(str("[PEER] connection to ", host, ":", port, "... SUCCESS!"))
		_net_tcp_send(peer, NET_NAME, PlayerName.get_text())
		DisconnectButton.set_disabled(false)
	else:
		_chat(str("[PEER] connection to ", host, ":", port, "... FAIL!"))
		peer.disconnect()
		JoinButton.set_disabled(false)

func _net_format_data(type, string):
	var len = string.length()
	var raw = RawArray()
	var i=0
	raw.push_back(str(type))
	raw.push_back(0)
	while(i<len):
		raw.push_back( string.ord_at(i) )
		i=i+1
	return raw
	
func _net_tcp_send( apeer, type, text):
	if(type == NET_NAME or type == NET_CHAT):
		var rawdata = _net_format_data(type, text)
		apeer.put_data(rawdata)


func _net_peer_recv():
	var raw_packet=RawArray()
	var raw_err=RawArray()
	var raw_data=RawArray()
	raw_packet=peer.get_partial_data(1024)
	raw_err=raw_packet[0]
	raw_data=raw_packet[1]
	if(raw_err !=0 or raw_data.size() < 4):
		return
	if(raw_data[0]==NET_CHAT):
		var rawtext=RawArray()
		for i in range(2,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		_chat(str(rawtext.get_string_from_utf8()))
		

func _net_server_recv( index, apeer ):
	var raw_packet=RawArray()
	var raw_err=RawArray()
	var raw_data=RawArray()
	raw_packet=apeer.get_partial_data(1024)
	raw_err=raw_packet[0]
	raw_data=raw_packet[1]
	if(raw_err !=0 or raw_data.size() < 4):
		return
	if(raw_data[0]==NET_NAME):
		var name=RawArray()
		for i in range(2,raw_data.size()):
			name.push_back( raw_data[i] )
		peernames.append(name.get_string_from_utf8())
		PlayerList.add_text(name.get_string_from_utf8())
		PlayerList.newline()
		_chat(str(name.get_string_from_utf8(), " joined lobby."))
		#send player join to peers
	if(raw_data[0]==NET_CHAT):
		var rawtext=RawArray()
		var text
		for i in range(2,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		text=str("<",peernames[index],"> ",rawtext.get_string_from_utf8())
		_chat(text)
		for apeer in peers:
			_net_tcp_send(apeer, NET_CHAT, text)


func _process(delta):
	if is_server:
		if server.is_connection_available():
			var newpeer = server.take_connection()
			_chat(str("[SERVER] new peer, ", newpeer.get_connected_host(), ":", newpeer.get_connected_port()))
			peers.append(newpeer)
		var i=0
		for apeer in peers:
			_net_server_recv(i, apeer)
		i=i+1
	else:
		if(peer.is_connected()):
			_net_peer_recv()


