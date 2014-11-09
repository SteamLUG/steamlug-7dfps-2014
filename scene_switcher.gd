
extends Node

var current_scene
var root

func _ready():
	root = get_scene().get_root()
	current_scene = root.get_child( root.get_child_count() - 1 )

func goto_scene(scene):
	var new_scene = ResourceLoader.load(scene);
	current_scene.queue_free();
	current_scene = new_scene.instance();
	root.add_child(current_scene)

func net_goto_scene(PlayerName, is_server, peers, peernames, scene):
	# Switch to scene while passing along important info from lobby to
	# a networking script, which isn't set up yet.
	#goto_scene(scene)

