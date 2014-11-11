
extends Spatial

var revealed
var mesh
var killbox

func _ready():
	revealed = false
	mesh = get_node("chumpus")
	mesh.hide()
	
	# Killbox follows ghost and marks humans for death. Doesn't work right now :(
	killbox = ResourceLoader.load("res://ghost/killbox.xscn").instance()
	get_node("/root/Map").add_child(killbox)
	killbox.set_ghost(self)
	
	set_process(true)

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
