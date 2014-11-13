

extends Spatial

var BOTTLE_AMOUNT = 10.0

func _ready():
	# Initalization here
	pass

func _on_col_body_enter(body):
	if body.is_in_group("human"):
		body.get_node("Cam/Lantern").add_oil( BOTTLE_AMOUNT )
		queue_free()
	pass
