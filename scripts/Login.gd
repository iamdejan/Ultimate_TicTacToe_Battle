extends Node2D

func _on_GoBackButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("Home"))
	pass
