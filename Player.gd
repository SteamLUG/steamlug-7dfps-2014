
extends RigidBody

var walk_speed = 4
var jump_force = 100

func _ready():
	print("hahahaha")
	pass

func _integrate_forces(state):

	# Handle movement
	var lv = state.get_linear_velocity()
	if( Input.is_action_pressed("player_forward") ):
		lv.z = -walk_speed
	elif( Input.is_action_pressed("player_backwards") ):
		lv.z = walk_speed
	if( Input.is_action_pressed("player_left") ):
		lv.x = -walk_speed
	elif( Input.is_action_pressed("player_right") ):
		lv.x = walk_speed

	# Handle jump
	print( state.get_contact_count())
	var onfloor = state.get_contact_count()
	if Input.is_action_pressed("player_jump"):
		state.add_force(Vector3(0,jump_force,0), Vector3(0,1,0))

	state.set_linear_velocity(lv)
	state.integrate_forces()

