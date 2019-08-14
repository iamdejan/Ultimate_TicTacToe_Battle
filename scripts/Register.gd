extends Node2D

func set_user_data(data: Dictionary) -> void:
	Session.data["user"] = data
	pass


func _on_RegisterSubmitButton_pressed():
	#TODO: API call
	
	#This is temporary solution
	var data: Dictionary = {
		"id": int($UserIDText.text),
		"name": $NameText.text
	}
	set_user_data(data)
	get_tree().change_scene(Session.build_scene_URL("Dashboard"))
	pass


func _on_GoBackButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("Home"))
	pass
