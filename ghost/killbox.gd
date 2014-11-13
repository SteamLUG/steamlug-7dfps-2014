
# *Grumble* This entire script shouldn't be needed.
extends CollisionObject

var ghost
var is_set = false

# This doesn't work right now, don't know why
func _on_killbox_body_enter(body):
	if body.is_in_group("human"):
		print ( " ******* GHOST ******** " )
		#body.die()

func set_ghost(node):
	ghost = node
	is_set = true
	set_process(true)

func reveal():
	#ghost.reveal()
	if is_set:
		ghost.get_resource("ghostmat2.mtl")
	else:
		pass

func _process():
	if is_set:
		set_translation(ghost.get_translation())
		set_rotation(ghost.get_rotation())
