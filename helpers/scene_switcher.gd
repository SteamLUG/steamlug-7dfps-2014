
extends Node

var current_scene
var root

func _ready():
	root = get_scene().get_root()
	current_scene = root.get_child( root.get_child_count() - 1 )

func goto_scene(scene):
	var new_scene = ResourceLoader.load(scene)
	current_scene.queue_free()
	current_scene = new_scene.instance()
	root.add_child(current_scene)

# This does not not unload current scene, need to manually hide
func goto_scene_nofree(scene):
	var new_scene = ResourceLoader.load(scene)
	var old_scene = current_scene
	current_scene = new_scene.instance()
	root.add_child(current_scene)
	pass

# Passes info to network script and hides lobby
func net_goto_map(PlayerName, is_server, peers, peernames, scene):
	get_node("/root/network").set_from_lobby(PlayerName, is_server, peers, peernames)
	current_scene.get_child(0).hide()
	goto_scene_nofree(scene)
