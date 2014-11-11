
extends Spatial

var revealed
var mesh

func _ready():
	revealed = false
	mesh = get_node("chumpus")
	mesh.hide()
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
