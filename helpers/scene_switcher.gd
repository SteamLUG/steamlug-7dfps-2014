
extends Node

# Constants used to define which camera to use
const GHOST = 0
const HUMAN1 = 1
const HUMAN2 = 2
const HUMAN3 = 3
const HUMAN4 = 4 

var current_scene
var root

func _ready():
	root = get_scene().get_root()
	current_scene = root.get_child( root.get_child_count() - 1 )

# Completely removes current scene
func goto_scene(scene, camera=HUMAN1):
	var new_scene = ResourceLoader.load(scene)
	current_scene.queue_free()
	current_scene = new_scene.instance()
	root.add_child(current_scene)
	if current_scene.get_name() == "Map":
		set_camera(current_scene, camera)

# This does not not unload current scene, need to manually hide
func goto_scene_nofree(scene, camera=HUMAN1):
	var new_scene = ResourceLoader.load(scene)
	var old_scene = current_scene
	current_scene = new_scene.instance()
	root.add_child(current_scene)
	set_camera(current_scene, camera)

# Passes info to network script and hides lobby
func net_goto_map(PlayerName, is_server, peers, peernames, scene, camera):
	get_node("/root/network").set_from_lobby(PlayerName, is_server, peers, peernames, camera)
	current_scene.get_child(0).hide()
	goto_scene_nofree(scene, camera)

func set_camera(scene, camera):
	var player
	var is_ghost = false
	
	if camera == GHOST:
		player = scene.get_node("Ghost")
		is_ghost = true
	elif camera == HUMAN1:
		player = scene.get_node("Human1")
	elif camera == HUMAN2:
		player = scene.get_node("Human2")
	elif camera == HUMAN3:
		player = scene.get_node("Human3")
	elif camera == HUMAN4:
		player = scene.get_node("Human4")
	else:
		printerr("Wrong camera value: " + str(camera))
	
	player.get_node("Cam").make_current()
	
	if is_ghost:
		player.set_script(load("res://ghost/ghost.gd"))
	else:
		player.set_script(load("res://player/player.gd"))
	
	player._ready()
	
