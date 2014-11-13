
extends SpotLight

var raycasts = []
export (int) var effective_distance = 10

export(float) var oil = 10.0    # Start with full oil
export(int) var oil_decay = 1   # Allow for different types of lamps in the future
var rate_of_decay = oil_decay
var oil_amount = oil

func lantern_off():
	rate_of_decay = 0
	# Turn off raycasts
	for rc in raycasts:
		rc.set_enabled(false)
	hide()

func lantern_on():
	if oil == 0:
		lantern_off()
		return
	rate_of_decay = oil_decay
	# Turn on raycasts
	for rc in raycasts:
			rc.set_enabled(true)
	show()

func add_oil( bottle_holds_how_much ):
	oil += bottle_holds_how_much
	get_node("../../SamplePlayer").play("pop")

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

# If ghost is hit, reveal it.
func check_raycasts():
	for rc in raycasts:
		if rc.is_colliding():
			var hit = rc.get_collider()
			if hit.is_in_group("ghost"):
				hit.reveal()
			#print( rc.get_name(), ": HIT! ", rc.get_collider().get_name(), ", ", rc.get_collision_point() )
		else:
			#print( rc.get_name(), ": no hit" )
			pass
	#print("\n")

func _process(dt):
	# Check if this player is even active first
	if get_node("../").is_current():
		check_raycasts()
		
		# Reduce oil by decay amount
		if (oil - rate_of_decay > 0):
			oil -= rate_of_decay * dt
		else:
			oil = 0
			lantern_off()
		get_node("../../HUD/OilLevel").set_text( "Oil level: " + str(int(oil)) )
	
	# Make lantern flicker
	var new_energy = get_parameter(4) + rand_range(-.5,5)
	if new_energy < 3 && new_energy > 1.5:
		set_parameter(4, new_energy)
