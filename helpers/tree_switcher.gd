
extends Node

# Constants used to define which camera to use
const GHOST = 0
const HUMAN1 = 1
const HUMAN2 = 2
const HUMAN3 = 3
const HUMAN4 = 4 

var current_tree
var root

func _ready():
	root = get_tree().get_root()
	current_tree = root.get_child( root.get_child_count() - 1 )

# Completely removes current tree
func goto_tree(tree, camera=HUMAN1, player_count=1):
	var new_tree = ResourceLoader.load(tree)
	current_tree.queue_free()
	current_tree = new_tree.instance()
	root.add_child(current_tree)
	if current_tree.get_name() == "Map":
		set_camera(current_tree, camera)

# This does not not unload current tree, need to manually hide
func goto_tree_nofree(tree, camera=HUMAN1, player_count=1):
	var new_tree = ResourceLoader.load(tree)
	var old_tree = current_tree
	current_tree = new_tree.instance()
	root.add_child(current_tree)
	set_camera(current_tree, camera)

# Passes info to network script and hides lobby, removes unused players.
func net_goto_map(PlayerName, is_server, peers, peernames, tree, camera):
	get_node("/root/network").set_from_lobby(PlayerName, is_server, peers, peernames, camera)
	current_tree.get_child(0).hide()
	goto_tree_nofree(tree, camera)
	
	var player_count = peernames.size() + 1
	for node in get_node("/root/Map").get_children():
		var human_num
		if node.is_in_group("human"):
			human_num = node.get_name().right(5).to_int()
			if human_num >= player_count && player_count > 1:
				node.queue_free()
			elif human_num > player_count:
				node.queue_free()

func set_camera(tree, camera):
	var player
	var is_ghost = false
	
	if camera == GHOST:
		player = tree.get_node("Ghost")
		is_ghost = true
	elif camera == HUMAN1:
		player = tree.get_node("Human1")
	elif camera == HUMAN2:
		player = tree.get_node("Human2")
	elif camera == HUMAN3:
		player = tree.get_node("Human3")
	elif camera == HUMAN4:
		player = tree.get_node("Human4")
	else:
		printerr("Wrong camera value: " + str(camera))
	
	player.get_node("Cam").make_current()
	
	if is_ghost:
		player.set_script(load("res://ghost/ghost.gd"))
	else:
		player.set_script(load("res://player/player.gd"))
	
	player._ready()
	
