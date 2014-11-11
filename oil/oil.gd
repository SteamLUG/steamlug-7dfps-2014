
extends Spatial

func _ready():
	# Initalization here
	pass

func _on_col_body_enter(body):
	if body.is_in_group("human"):
		body.get_node("Cam/Lantern").add_oil()
		get_node("sound").play("pop")
		queue_free()
	pass
