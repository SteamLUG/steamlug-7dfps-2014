
extends Spatial

var revealed
var mesh
var killbox

var exit_game = false
var win_hsize

# From player.gd
export var walk_speed = 10
export var jump_force = 10

# Camera
var camera
var rotation = Vector2(0,0)
var max_pitch = deg2rad(80)

# Speed modifier
var speed_mod

func _ready():
	revealed = false
	mesh = get_node("chumpus")
	mesh.hide()
	
	# Killbox follows ghost and marks humans for death. Doesn't work right now :(
	killbox = ResourceLoader.load("res://ghost/killbox.xscn").instance()
	get_node("/root/Map").add_child(killbox)
	killbox.set_ghost(self)
	
	# Setup camera
	var rot = get_rotation()
	rotation.x = rot.y
	rot.y = 0
	set_rotation(rot)
	camera = get_node("Cam")
	win_hsize = OS.get_video_mode_size()/2
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	speed_mod = 2.0
	set_process_input(true)
	
	set_process(true)

func _integrate_forces(state):
	
	# Reset mouse
	Input.warp_mouse_pos(win_hsize)
	
	# Get directions
	var forward = camera.get_transform().basis[2]
	forward = Vector3(forward.x, 0, forward.z).normalized()
	var strafe = camera.get_transform().basis[0]
	strafe = Vector3(strafe.x, 0, strafe.z).normalized()
	
	# Quit game
	if exit_game:
		OS.get_main_loop().quit()
	if Input.is_action_pressed("game_quit"):
		print("quit")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		exit_game = true

	# Handle movement
	var lv = state.get_linear_velocity()
	if Input.is_action_pressed("player_forward"):
		lv -= (forward * walk_speed * speed_mod)
	elif Input.is_action_pressed("player_backwards"):
		lv += (forward * walk_speed * speed_mod)
	if Input.is_action_pressed("player_left"):
		lv -= (strafe * walk_speed * speed_mod)
	elif Input.is_action_pressed("player_right"):
		lv += (strafe * walk_speed * speed_mod)
	
	# Clamp speed
	var tmp = Vector3( lv.x, 0, lv.z )
	if tmp.length() > walk_speed:
		tmp = tmp.normalized() * walk_speed
		lv.x = tmp.x
		lv.z = tmp.z
	
	# Handle jump
	var onfloor = state.get_contact_count()
	if onfloor and Input.is_action_pressed("player_jump"):
		lv.y = jump_force
		# if we use forces, jump_force should be over 9000
		#state.add_force(Vector3(0,jump_force,0), Vector3(0,1,0))
	
	# Apply walk velocity
	state.set_linear_velocity(lv)
	
	# Clamp pitch
	rotation.y = min( max_pitch, abs(rotation.y) ) * sign( rotation.y )
	
	# Rotate camera by using transform
	var rot = Matrix3().rotated(Vector3(0,1,0), rotation.x).rotated(Vector3(1,0,0),rotation.y)
	var transf = camera.get_transform()
	transf.basis = rot
	camera.set_transform(transf)
	
	# Commit!
	state.integrate_forces()

func _input(ev):
	if ev.type == InputEvent.MOUSE_MOTION:
		rotation += (ev.pos - win_hsize) * 0.001

# Called by lantern when raycast hits ghost.
func reveal():
	revealed = true

func _process(delta):
	if revealed:
		mesh.show()
		revealed = false
	else:
		mesh.hide()
		pass
	
	pass
