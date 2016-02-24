
extends Node

const NET_POS = 1

var PlayerName = ""
var is_server = true
var peers = []
var peernames = []
var peer
var dt = 0
var tcpstreams
var playernode_name
var Player_id
var ghost_sound = false

var player_placement # Array or dictionary to hold player values from network

var is_set = false # Has recieved values from lobby

func _ready():
	pass

func make_ghost_sound():
	ghost_sound = true

func get_player_node(var Player_id):
	var node
	if Player_id == 0:
		node = "/root/Map/Ghost"
	elif Player_id == 1:
		node = "/root/Map/Human1"
	elif Player_id == 2:
		node = "/root/Map/Human2"
	elif Player_id == 3:
		node = "/root/Map/Human3"
	elif Player_id == 4:
		node = "/root/Map/Human4"
	return node

func set_from_lobby(name, server_bool, peer_streams, peer_names, camera):
	PlayerName = name
	is_server = server_bool
	tcpstreams = peer_streams
	Player_id = camera
	if is_server:
		peernames = peer_names
		for apeer in peer_streams:
			var newpeer = PacketPeerStream.new()
			newpeer.set_stream_peer(apeer)
			peers.append(newpeer)
	else:
		peer = PacketPeerStream.new()
		peer.set_stream_peer(peer_streams[0])
	
	playernode_name=get_player_node(Player_id)
	
	# Gather some data from above variables, like player count
	# Store this data in new vars, create arrays (or dictionaries or something)
	# and add them to player_placement array
	# Set camera
	
	#print("Passed to network.gd: "+str(PlayerName)+"/"+str(is_server)+"/"+str(peer_streams)+"/"+str(peer_names))
	
	is_set = true
	set_process(true)

func Net_Get_Data(apeer, index):
	var data
	if(tcpstreams[index].is_connected() && apeer.get_available_packet_count() > 0):
		data = apeer.get_var()[0]
		print("got data " + str(data[0]))
	else:
		#print("lost peer? no data?")
		return
	if data != null and data.size() > 0:
		if is_server:
			if(data[0]==NET_POS):
				#send recieved position to other players
				#print ("Got position from player. i=", data[1]," x=", data[2]," y=", data[3]," z=", data[4]," rx=", data[5]," ry=", data[6]," rz=", data[7])
				Net_Send_Data_All(peers, [data])
				#set player position
				if (data[1] == Player_id):
					return #player sent us server position.  this shouldn't happen.
				var vp=Vector3(data[2], data[3], data[4])
				var vr=Vector3(data[5], data[6], data[7])
				var player = get_node(get_player_node(data[1]))
				player.set_translation(vp)
				player.get_node("Cam").set_rotation(vr)
				if player.is_in_group("human"):
					if data[8]:
						player.get_node("Cam/Lantern").lantern_on()
					else:
						player.get_node("Cam/Lantern").lantern_off()
					if data[9]:
						player.get_node("../Ghost/SamplePlayer").play("ghost3m")
		else:
			if(data[0]==NET_POS):
				#print ("Got position from server. i=", data[1]," x=", data[2]," y=", data[3]," z=", data[4]," rx=", data[5]," ry=", data[6]," rz=", data[7])
				if (data[1] == Player_id):
					return #we dont want to set our own position
				#set  player position
				var vp=Vector3(data[2], data[3], data[4])
				var vr=Vector3(data[5], data[6], data[7])
				var player = get_node(get_player_node(data[1]))
				player.set_translation(vp)
				player.get_node("Cam").set_rotation(vr)
				if player.is_in_group("human"):
					if data[8]:
						player.get_node("Cam/Lantern").lantern_on()
					else:
						player.get_node("Cam/Lantern").lantern_off()
					if data[9]:
						player.get_node("../Ghost/SamplePlayer").play("ghost3m")

func Net_Send_Data(apeer, data, index):
	if(tcpstreams[index].is_connected()):
		apeer.put_var(data)
	else:
		#print("lost peer?")
		return

func Net_Send_Data_All(_peers, data):
	var i = 0
	for _peer in _peers:
		Net_Send_Data(_peer, data, i)
		i += 1

func _process(delta):
	# Let's try to receive data ASAP
	
	if is_server:
		# Recieve from clients
		var i=0
		for ipeer in peers:
			Net_Get_Data(ipeer, i)
			i=i+1
	else:
		# Recieve from server
			Net_Get_Data(peer, 0)
	
	# Let's send data less often.
	#print("Send position? " + str(dt))
	if(dt > 0.25):
		#print("Send position")
		
		# Get coords, direction from tree
		var player = get_node(playernode_name)
		var player_coords = player.get_translation()
		var player_rot = player.get_node("Cam").get_rotation()
		var player_num = 0
		var player_lantern
		if player.is_in_group("human"):
			player_lantern = player.get_node("Cam/Lantern").is_visible()
		else:
			player_lantern = false
		var player_data = [[int(NET_POS), int(Player_id), player_coords.x, player_coords.y, player_coords.z, player_rot.x, player_rot.y, player_rot.z, player_lantern, ghost_sound]]
		
		#print(str(player_coords) + str(player_rot))
		if is_server:
			# Send to clients
			#print("Server, send position to clients")
			Net_Send_Data_All(peers, player_data)
		else:
			# Send to server
			#print("Player, send position to server")
			Net_Send_Data(peer, player_data, 0)
		dt = 0
		ghost_sound = false
	else:
		dt += delta


