# This should make the light flicker subtly, as lanterns do.

extends SpotLight

# member variables here:

var raycasts = []
export (int) var effective_distance = 10

export(int) var oil = 350			# Start with full oil
export(int) var oil_decay = 1			# Allow for different types of lamps in the future
var rate_of_decay = oil_decay

func lantern_off():
	rate_of_decay = 0
	
func lantern_on():
	rate_of_decay = oil_decay

func add_oil( bottle_holds_how_much ):
	oil += bottle_holds_how_much

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
	
	# Rays don't collide with the floor since it's been set up as not ray pickable
	for rc in raycasts:
		if rc.is_colliding():
			print( rc.get_name(), ": HIT! ", rc.get_collider().get_name(), ", ", rc.get_collision_point() )
		else:
			print( rc.get_name(), ": no hit" )
	print("\n")
	
	# Reduce oil by decay amount
	if (oil - rate_of_decay > 0):
		oil -= rate_of_decay
		self.show()
	else:
		oil = 0
		lantern_off()
		self.hide()

	get_node("/root/Spatial/OilLevel").set_text( "Oil level: " + str(oil) )	
	pass
