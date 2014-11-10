
extends Spatial

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initalization here
	pass




func _on_col_body_enter( body ):
	if body.get_name() == "Player":
		print ( " ******* GHOST ******** " )
		# Ideally, call routine in Player object for "possession/fainting/death"
	pass # replace with function body
