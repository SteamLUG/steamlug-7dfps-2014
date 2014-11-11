
extends Node

const NET_POS = 1

var PlayerName
var is_server
var peers
var peernames
var peer
var dt
var tcpstreams

var player_placement # Array or dictionary to hold player values from network

var is_set # Has recieved values from lobby

func _ready():
	PlayerName = ""
	is_server = true
	dt = 0
	peers = []
	peernames = []
	# Set the rest of the things
	
	is_set = false

func set_from_lobby(name, server_bool, peer_streams, peer_names):
	PlayerName = name
	is_server = server_bool
	tcpstreams = peer_streams
	if is_server:
		peernames = peer_names
		for apeer in peer_streams:
			var newpeer = PacketPeerStream.new()
			newpeer.set_stream_peer(apeer)
			peers.append(newpeer)
	else:
		peer = PacketPeerStream.new()
		peer.set_stream_peer(peer_streams[0])
	
	# Gather some data from above variables, like player count
	# Store this data in new vars, create arrays (or dictionaries or something)
	# and add them to player_placement array
	# Set camera
	
	print("Passed to network.gd: "+str(PlayerName)+"/"+str(is_server)+"/"+str(peer_streams)+"/"+str(peer_names))
	
	is_set = true
	set_process(true)

func Net_Get_Data(apeer, index):
	var data
	if(tcpstreams[index].is_connected()):
		data=apeer.get_var()
	else:
		pint("lost peer?")
		return
	if data != null and data.size() > 0:
		if is_server:
			if(data[0]==NET_POS):
				#send recieved position to other players
				print ("Got position from player: i=", data[1]," x=", data[2]," y=", data[3]," z=", data[4]," r=", data[5])
				var i=0
				for ipeer in peers:
					data[1] = i
					ipeer.put_var(data)
					i=i+1
				#TODO: set player position
		else:
			if(data[0]==NET_POS):
				print ("Got ", peernames[data[1]], "position. i=", data[1]," x=", data[2]," y=", data[3]," z=", data[4]," r=", data[5])
				#TODO: set  player position

func Net_Send_Data(apeer, data, index):
	if(tcpstreams[index].is_connected()):
		apeer.put_var(data)
	else:
		pint("lost peer?")
		return

func _process(delta):
	# Let's try to receive data ASAP
	if is_server:
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
	if(delta - dt > 500):
		# Get coords, direction from scene
		var player = get_node("/root/Spatial/Player")
		var player_coords = player.get_translation()
		var player_rot = player.get_node("Cam").get_rotation()
		var player_num = 0
		var player_data = [[int(NET_POS), int(player_num), player_coords.x, player_coords.y, player_coords.z, player_rot.x]]
		
		#print(str(player_coords) + str(player_rot))
		if is_server:
			# Send to clients
			var i=0
			for ipeer in peers:
				Net_Send_Data(ipeer, player_data, i)
				i=i+1
		else:
			# Send to server
			Net_Send_Data(peer, player_data, 0)
		dt=delta


	
	# Set player coords from updated player_placement
	#for something in player_placement
	#	get_node(player_object).set_translation(from_array)
	#	get_node(player_object).set_rotation(from_array)

