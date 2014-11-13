
extends Control

func _ready():
	pass

func _on_goto_test_pressed():
	get_node("/root/tree_switcher").goto_tree("res://test/test.xscn")

func _on_goto_multi_pressed():
	get_node("/root/tree_switcher").goto_tree("res://net/lobby.xscn")
