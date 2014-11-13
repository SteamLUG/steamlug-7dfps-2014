
extends Node

var server
var peer
export (String) var host = "127.0.0.1"
export (int) var port     #Set the port in the Godot inspector

const NET_NAME = 1  # player name
const NET_CHAT = 2  # chat message
const NET_JOIN = 3  # new player joined
const NET_PART = 4  # player left
const NET_STOP = 5  # server stopped
const NET_REDY = 6  # peer toggled ready status
const NET_OKGO = 7  # launch map

const PROTOCOL="H2" #haunt protocol version 2

# Constants used to define which camera to use
const GHOST = 0
const HUMAN1 = 1
const HUMAN2 = 2
const HUMAN3 = 3
const HUMAN4 = 4

var ids = range(GHOST, HUMAN4)

var peers        #array of StreamPeerTCP objects
var peernames    #array of player names
var peerready    #array of player ready status
var current_time

var map   #tree to launch

var _this_id = 99

#widgets
var DebugButton
var HostButton
var JoinButton
var StopServerButton
var DisconnectButton
var ReadyButton
var LaunchButton
var LobbyChat
var EnterChat
var PlayerList
var PlayerNameBox
var QuitButton
var SelectMap

var is_server = false
var ready = false
var launched = false

var win_hsize

var available_maps = ["map1", "test"]



func _ready():
	# create peer
	peer = StreamPeerTCP.new()
	# create server
	server = TCP_Server.new()
	peers = []
	peernames = []
	peerready = []
	current_time = ""
	
	map = "res://map1/map1.xscn"
	
	win_hsize = OS.get_video_mode_size()/2
	
	# init text and buttons
	DebugButton = get_node("Debug")
	DebugButton.connect("pressed", self, "_debug")
	
	PlayerNameBox = get_node("Lobby_Name_Area/Lobby_Player_Name")
	PlayerNameBox.get_node("Lobby_Name_Text").add_text("Name:")
	PlayerNameBox.set_text("Player1")
	
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
	
	LaunchButton = get_node("Lobby_Host_Area/Lobby_Launch_Button")
	LaunchButton.connect("pressed", self, "_on_lobby_launch")
	LaunchButton.set_disabled(true)
	
	DisconnectButton = get_node("Lobby_Join_Area/Lobby_Disconnect_Button")
	DisconnectButton.connect("pressed", self, "_on_lobby_disconnect")
	DisconnectButton.set_disabled(true)
	
	ReadyButton = get_node("Lobby_Chat_Area/Lobby_Ready_Button")
	ReadyButton.connect("pressed", self, "_on_lobby_ready")
	ReadyButton.get_node("Lobby_Ready_Text").add_text("NO")
	ReadyButton.set_disabled(true)
	
	LobbyChat = get_node("Lobby_Chat_Area/Lobby_Chat")
	
	EnterChat = get_node("Lobby_Chat_Area/Lobby_Enter_Chat")
	EnterChat.connect("text_entered", self, "_on_enter_chat")
	
	SelectMap = get_node("Lobby_Host_Area/Lobby_Map_Selection")
	SelectMap.add_item("Map1", 0)
	SelectMap.add_item("Test", 1)
	SelectMap.connect("item_selected", self, "_on_map_select")
	
	PlayerList = get_node("Lobby_Chat_Area/Lobby_Player_List")
	
	QuitButton = get_node("Quit")
	QuitButton.connect("pressed", self, "_quit")

	set_process_input(true)
	set_process(true)
	
	randomize()

#add server browser later?
#func _on_selected_item(id):
#	is_server = id == 0

func _on_map_select(id):
	if id == 0:
		map = "res://map1/map1.xscn"
	elif id == 1:
		map = "res://test/test.xscn"

func _quit():
	_on_lobby_disconnect()
	OS.get_main_loop().quit()

func _debug():
	_chat("peer names:")
	for i in range(0,peernames.size()):
		_chat(peernames[i])

func _pop_rand_id():
	var pos = randi() % ids.size()
	var ret = ids[pos]
	ids.remove(pos)
	return ret

func _on_lobby_launch():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_chat("Launching map..")
	_this_id = _pop_rand_id()
	for apeer in peers:
			var selected_id = _pop_rand_id()
			_net_tcp_send(apeer, NET_OKGO, String(selected_id))
	launched=true

	print("ok, I'll take ", _this_id)
	
	#Switch trees while passing info from lobby
	#TODO: Logic to replace the last argument with a number that represents which player to control
	#0 is ghost, 1-4 are humans
	get_node("/root/tree_switcher").net_goto_map(PlayerNameBox.get_text(), is_server, peers, peernames, map, _this_id)

func _on_lobby_ready():
	var text
	if is_server:
		if ready:
			text=(str("<",PlayerNameBox.get_text(),"> is NOT ready."))
		else:
			text=(str("<",PlayerNameBox.get_text(),"> is ready!"))
		_chat(text)
		for apeer in peers:
			_net_tcp_send(apeer, NET_CHAT, text)
	else:
		_net_tcp_send(peer, NET_REDY, "rdy")
	ReadyButton.get_node("Lobby_Ready_Text").clear()
	if ready:
		ready=false
		ReadyButton.get_node("Lobby_Ready_Text").add_text("NO")
	else:
		ready=true
		ReadyButton.get_node("Lobby_Ready_Text").add_text("YES")

func _chat ( text ):
	current_time = str(OS.get_time().hour) + ":" + str(OS.get_time().minute)
	LobbyChat.add_text(current_time + " " + text)
	LobbyChat.newline()

func _on_enter_chat( text ):
	if is_server:
		text=str("<",PlayerNameBox.get_text(),">",text)
		_chat(text)
		for apeer in peers:
			_net_tcp_send(apeer, NET_CHAT, text)
	else:
		_net_tcp_send(peer, NET_CHAT, text)
	EnterChat.clear()

func _on_lobby_stop_server( ):
	for apeer in peers:
		_net_tcp_send(apeer, NET_STOP, "bye")
	server.stop()
	peernames.clear()
	_update_player_list()
	_chat("[SERVER] stopped.")
	HostButton.set_disabled(false)
	JoinButton.set_disabled(false)
	StopServerButton.set_disabled(true)
	PlayerNameBox.set_editable(true)
	ReadyButton.set_disabled(true)

func _on_lobby_disconnect( ):
	_net_tcp_send(peer, NET_PART, "bye")
	peernames.clear()
	peer.disconnect()
	_update_player_list()
	_chat("[PEER] disconnected.")
	JoinButton.set_disabled(false)
	DisconnectButton.set_disabled(true)
	PlayerNameBox.set_editable(true)
	ReadyButton.set_disabled(true)

func _on_lobby_host_start( ):
	_chat("[SERVER] init!")
	is_server = true
	port=HostButton.get_node("Lobby_Host_Port").get_text()
	_update_player_list()
	server.listen(port)
	HostButton.set_disabled(true)
	JoinButton.set_disabled(true)
	StopServerButton.set_disabled(false)
	ReadyButton.set_disabled(false)
	LaunchButton.set_disabled(false)


func _on_lobby_join_start( ):
	var status=0
	var start_time=0
	var check_time=0
	HostButton.set_disabled(true)
	JoinButton.set_disabled(true)
	PlayerNameBox.set_editable(false)
	ReadyButton.set_disabled(false)
	_chat("[PEER] init!")
	host=IP.resolve_hostname(JoinButton.get_node("Lobby_Join_IP").get_text())
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
		_net_tcp_send(peer, NET_NAME, PlayerNameBox.get_text())
		DisconnectButton.set_disabled(false)
	else:
		_chat(str("[PEER] connection to ", host, ":", port, "... FAIL!"))
		peer.disconnect()
		JoinButton.set_disabled(false)

func _update_player_list():
	PlayerList.clear()
	PlayerList.add_text("Players:")
	PlayerList.newline()
	if is_server:
		PlayerList.add_text(PlayerNameBox.get_text())
		PlayerList.newline()
	for i in range(0,peernames.size()):
		PlayerList.add_text(peernames[i])
		PlayerList.newline()

func _net_tcp_send(apeer, type, text):
	var rawdata = RawArray()
	var len = text.length()
	var i=0
	if(len>254):
		len=254  #no data over 254 bytes
	rawdata.push_back(PROTOCOL.ord_at(0))
	rawdata.push_back(PROTOCOL.ord_at(1))
	rawdata.push_back((len+1))
	rawdata.push_back(str(type))
	while(i<len):
		rawdata.push_back( text.ord_at(i) )
		i=i+1
	rawdata.push_back(0)
	apeer.put_data(rawdata)

func _net_peer_recv():
	var len=0
	var type
	var raw_packet=RawArray()
	var raw_err=RawArray()
	var raw_data=RawArray()
	var Protocol=RawArray()
	raw_packet=peer.get_partial_data(4)
	raw_err=raw_packet[0]
	raw_data=raw_packet[1]
	if(raw_err !=0 or raw_data.size() < 4):
		#error or no data this frame
		return
	Protocol.push_back(raw_data[0])
	Protocol.push_back(raw_data[1])
	if(Protocol.get_string_from_utf8() != PROTOCOL):
		_chat(str("[ERR] version missmatch ", Protocol.get_string_from_utf8()))
		peer.disconnect()
		return
	len=raw_data[2]
	type=raw_data[3]
	if(len<1):
		return
	raw_packet=peer.get_data(len)
	raw_err=raw_packet[0]
	raw_data=raw_packet[1]
	if(type==NET_CHAT):
		var rawtext=RawArray()
		for i in range(0,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		_chat(str(rawtext.get_string_from_utf8()))
	if(type==NET_JOIN):
		var rawtext=RawArray()
		for i in range(0,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		var name=rawtext.get_string_from_utf8()
		peernames.append(name)
		_chat(str(name, " joined lobby."))
		_update_player_list()
	if(type==NET_PART):
		var rawtext=RawArray()
		for i in range(0,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		var index=rawtext.get_string_from_utf8()
		_chat(str(peernames[index.to_int()]," disconnected."))
		peernames.remove(index.to_int())
		_update_player_list()
	if(type==NET_STOP):
		peer.disconnect()
		_chat("Disconnected: Server stopped.")
		peernames.clear()
		_update_player_list()
		JoinButton.set_disabled(false)
		DisconnectButton.set_disabled(true)
		PlayerNameBox.set_editable(true)
	if(type==NET_OKGO):
		_chat("Launching map..")
		var rawtext=RawArray()
		for i in range(0,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		var id=rawtext.get_string_from_utf8().to_int()
		_this_id = id
		print("my id is ", _this_id, "!")
		
		peers.append(peer) #evil++
		get_node("/root/tree_switcher").net_goto_map(PlayerNameBox.get_text(), is_server, peers, peernames, map)
		#switch tree


func _net_server_recv( index, apeer ):
	var len=0
	var type
	var raw_packet=RawArray()
	var raw_err=RawArray()
	var raw_data=RawArray()
	var Protocol=RawArray()
	raw_packet=apeer.get_partial_data(4)
	raw_err=raw_packet[0]
	raw_data=raw_packet[1]
	if(raw_err !=0 or raw_data.size() < 4):
		#error or no data this frame
		return
	Protocol.push_back(raw_data[0])
	Protocol.push_back(raw_data[1])
	if(Protocol.get_string_from_utf8() != PROTOCOL):
		_chat(str("[ERR] version missmatch ", Protocol.get_string_from_utf8()))
		apeer.disconnect()
		return
	len=raw_data[2]
	type=raw_data[3]
	if(len<1):
		return
	raw_packet=apeer.get_data(len)
	raw_err=raw_packet[0]
	raw_data=raw_packet[1]
	if(type==NET_NAME):
		var name=RawArray()
		for i in range(0,raw_data.size()):
			name.push_back( raw_data[i] )
		var newname=name.get_string_from_utf8()
		peernames.append(newname)
		peerready.append(0)
		_chat(str(newname, " joined lobby."))
		_update_player_list()
		#send player join to all peers
		for ipeer in peers:
			_net_tcp_send(ipeer, NET_JOIN, newname)
	if(type==NET_CHAT):
		var rawtext=RawArray()
		var text
		for i in range(0,raw_data.size()):
			rawtext.push_back( raw_data[i] )
		text=str("<",peernames[index],"> ",rawtext.get_string_from_utf8())
		_chat(text)
		#send chat message to all peers
		for ipeer in peers:
			_net_tcp_send(ipeer, NET_CHAT, text)
	if(type==NET_PART):
		_chat(str(peernames[index]," disconnected."))
		peernames.remove(index)
		peerready.remove(index)
		_update_player_list()
		apeer.disconnect()
		peers.remove(index)
		#tell everyone else which player left
		for ipeer in peers:
			_net_tcp_send(ipeer, NET_PART, str(index+1))
	if(type==NET_REDY):
		var text
		if peerready[index]==0:
			peerready[index]=1
			text=(str("<",peernames[index],"> is ready!"))
			var count=0
			for i in range(0,peerready.size()):
				if(peerready[i]==1):
					count=count+1
			if count==peerready.size():
				LaunchButton.set_disabled(false)
		else:
			peerready[index]=0
			text=(str("<",peernames[index],"> is NOT ready."))
			LaunchButton.set_disabled(true)
		_chat(text)
		for apeer in peers:
			_net_tcp_send(apeer, NET_CHAT, text)


var prevhit = false

func _process(delta):

	var nowhit = Input.is_action_pressed("switch_lobby_visible")

	if nowhit and !prevhit:
		if is_hidden():
			show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			hide()

	prevhit = nowhit

	if is_hidden():
		Input.warp_mouse_pos(win_hsize)

	if is_server:
		print("ok, I'll take ", _this_id)
		if(launched==false && server.is_connection_available()):
			var newpeer = server.take_connection()
			_chat(str("[SERVER] new peer, ", newpeer.get_connected_host(), ":", newpeer.get_connected_port()))
			peers.append(newpeer)
			LaunchButton.set_disabled(true)
			#send server player name to new peer
			_net_tcp_send(newpeer, NET_JOIN, PlayerNameBox.get_text())
			#send other player names to new peer
			for i in range (0, peernames.size()):
				_net_tcp_send(newpeer, NET_JOIN, peernames[i])
		#process new data from peers
		var i=0
		for apeer in peers:
			_net_server_recv(i, apeer)
			i=i+1
	else:
		#process new data from server
		if(peer.is_connected()):
			_net_peer_recv()


