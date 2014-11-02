extends Node

var server

func _ready():
	server = TCP_Server.new()
	set_process(true)
	pass

func _process(delta):
	print("asd")