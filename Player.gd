
extends RigidBody

var speed = 4

func _ready():
	print("hahahaha")
	pass

func _integrate_forces(state):

	var lv = state.get_linear_velocity()

	if( Input.is_action_pressed("player_forward") ):
		lv.z = -speed
	elif( Input.is_action_pressed("player_backwards") ):
		lv.z = speed

	if( Input.is_action_pressed("player_left") ):
		lv.x = -speed
	elif( Input.is_action_pressed("player_right") ):
		lv.x = speed

	state.set_linear_velocity(lv)
	state.integrate_forces()

