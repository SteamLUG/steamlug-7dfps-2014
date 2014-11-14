
# *Grumble* This entire script shouldn't be needed. This is messy.
extends CollisionObject

var ghost
var is_set = false
var revealed = false
var mesh

func _ready():
	mesh = get_node("chumpus")
	set_process(true)

# This doesn't work right now, don't know why
func _on_body_enter(body):
	if body.is_in_group("human"):
		print ( " ******* GHOST ******** " )
		#body.die()

func set_ghost(node):
	ghost = node
	is_set = true
	set_process(true)

func reveal():
	if is_set:
		ghost.reveal()
	else:
		revealed = true

func _process(delta):
	if is_set:
		set_translation(ghost.get_translation())
		set_rotation(ghost.get_rotation())
	elif revealed:
		mesh.show()
		revealed = false
	else:
		mesh.hide()
		pass
