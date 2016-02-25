
extends Node

func set_fixedmat():
	# working for fixed material
	# remember changing quad material to FIXEDMATERIAL!
	var tex = get_node("Viewport").get_render_target_texture()
	get_node("Quad").get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE,tex)

func set_shadermat():
	# not working...
	# remember changing quad material to SHADERMATERIAL!
	# It seems "set" property just don't fail when the property doesn't exist,
	# but still not working for setting any kind of uniform
	var tex = get_node("Viewport").get_render_target_texture()
	get_node("Quad").get_material_override().set("tehscreen", tex)

	var mat = get_node("Quad").get_material_override()
	get_node("Quad").set_material_override(mat)

func _ready():
	# Initalization here
	#set_shadermat()
	set_fixedmat()
	set_process(true)

func _process(dt):
	#set_shadermat()
	set_fixedmat()
