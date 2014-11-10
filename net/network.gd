
extends Node

var PlayerName
var is_server
var peers
var peernames

var player_placement

var is_set

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
	
	is_set = true

func _process(delta):
	# Data probably should not be set every tick, add logic to replace true
	if true:
		# Get coords, direction from scene
		pass
		if is_server:
			# Send to clients
			pass
		else:
			# Send to server
			pass
	
	# Set player coords from updated player_placement

