
extends RigidBody

var walk_speed = 1
var jump_force = 3000
var max_speed = 6
var delta_mouse = Vector2(0,0)
var win_hsize
var camera
var exit_game = false

func _ready():
	camera = get_node("Cam")
	win_hsize = OS.get_video_mode_size()/2
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass


func _integrate_forces(state):

	var forward = camera.get_transform().basis[2]
	var strafe = camera.get_transform().basis[0]
	Input.warp_mouse_pos(win_hsize)

	# Quit game
	if exit_game:
		SceneMainLoop.quit
	if Input.is_action_pressed("game_quit"):
		print("quit")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		exit_game = true

	# Handle movement
	var lv = state.get_linear_velocity()
	if Input.is_action_pressed("player_forward"):
		lv -= forward * walk_speed
	elif Input.is_action_pressed("player_backwards"):
		lv += forward * walk_speed
	if Input.is_action_pressed("player_left"):
		lv -= strafe * walk_speed
	elif Input.is_action_pressed("player_right"):
		lv += strafe * walk_speed

	# Clamp speed
	lv.x = min( max_speed, abs(lv.x) ) * sign(lv.x)
	lv.z = min( max_speed, abs(lv.z) ) * sign(lv.z)

	# Handle jump
	print( state.get_contact_count())
	var onfloor = state.get_contact_count()
	if onfloor and Input.is_action_pressed("player_jump"):
		state.add_force(Vector3(0,jump_force,0), Vector3(0,1,0))

	state.set_linear_velocity(lv)
	#state.set_rotation(state.get_rotation() + Vector3(0, -delta_mouse.x,0) * 0.001)
	#state.set_angular_velocity(state.get_angular_velocity() + Vector3(0,delta_mouse.x,0))
	state.integrate_forces()


func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		delta_mouse = (ev.pos - win_hsize)
		camera.set_rotation(camera.get_rotation() + Vector3(0, -delta_mouse.x,0) * 0.001)
		#set_rotation( get_rotation() + Vector3(delta_mouse.y, delta_mouse.x,0) )
		#camera.set_transform( camera.get_transform().rotated(Vector3(0,1,0),delta_mouse.x))
		print(delta_mouse)