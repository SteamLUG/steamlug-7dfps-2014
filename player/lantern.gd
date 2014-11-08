# This should make the light flicker subtly, as lanterns do.

extends SpotLight

var raycasts = []
export (int) var effective_distance = 10

# member variables here, example:
# var a=2
# var b="textvar"
## Begin work on oil status
export(int, 0, 100) var oil = 100			# Start with full oil


func append_rc(rc):
	rc.set_cast_to(rc.get_cast_to() * effective_distance)
	raycasts.append(rc)

func _ready():

	append_rc(get_node("RCMid"))
	append_rc(get_node("RCTop"))
	append_rc(get_node("RCBot"))
	append_rc(get_node("RCLeft"))
	append_rc(get_node("RCRight"))

	set_process(true)
	pass

func _process(dt):
	# TODO: Add code to set brightness levels based on oil level
	# TODO: Setup setter/getters and/or functions to change oil level based on usage
	# TODO: or movement
	# TODO: Check Godot documentation since it seems _process only gets delta of time
	# TODO: since last frame

	# Rays don't collide with the floor since it's been set up as not ray pickable
	for rc in raycasts:
		if rc.is_colliding():
			print( rc.get_name(), ": HIT! ", rc.get_collider().get_name(), ", ", rc.get_collision_point() )
		else:
			print( rc.get_name(), ": no hit" )
	print("\n")
	pass
	
