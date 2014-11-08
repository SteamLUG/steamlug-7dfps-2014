# This should make the light flicker subtly, as lanterns do.

extends SpotLight

# member variables here, example:
# var a=2
# var b="textvar"
## Begin work on oil status
export(int, 0, 100) var oil = 100			# Start with full oil

func _ready():
	pass

func _process():
	# TODO: Add code to set brightness levels based on oil level
	# TODO: Setup setter/getters and/or functions to change oil level based on usage
	# TODO: or movement
	# TODO: Check Godot documentation since it seems _process only gets delta of time
	# TODO: since last frame
	pass