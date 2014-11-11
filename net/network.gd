
extends Node

var PlayerName
var is_server
var peers
var peernames

var player_placement # Array or dictionary to hold player values from network

var is_set # Has recieved values from lobby

func _ready():
	PlayerName = ""
	is_server = true
	
	# Set the rest of the things
	
	is_set = false

func set_from_lobby(name, server_bool, peer_stream, peer_names):
	PlayerName = name
	is_server = server_bool
	peers = peer_stream
	peernames = peer_names	
	
	# Gather some data from above variables, like player count
	# Store this data in new vars, create arrays (or dictionaries or something)
	# and add them to player_placement array
	# Set camera
	
	print("Passed to network.gd: "+str(PlayerName)+"/"+str(is_server)+"/"+str(peer_stream)+"/"+str(peer_names))
	
	is_set = true
	set_process(true)

func _process(delta):
	# Data probably should not be set every tick, add logic to replace true
	if true:
		# Get coords, direction from scene
		var player = get_node("/root/Spatial/Player")
		var player_coords = player.get_translation()
		var player_rot = player.get_node("Cam").get_rotation()
		
		print(str(player_coords) + str(player_rot))
		if is_server:
			# Send and recieve to/from clients
			pass
		else:
			# Send and recieve to/from server
			pass
	
	# Set player coords from updated player_placement
	#for something in player_placement
	#	get_node(player_object).set_translation(from_array)
	#	get_node(player_object).set_rotation(from_array)
	pass
