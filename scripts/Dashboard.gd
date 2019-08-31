extends Node2D

func _ready():
	$UserDataLabel.text = "User ID: " + String(Session.data["user"]["id"])
	$UserDataLabel.text += "\n"
	$UserDataLabel.text += "Name: " + Session.data["user"]["name"]
	pass

func _on_CreateRoomButton_pressed():
	$CreateRoomButton.disabled = true
	#TODO:
	#1. Create Room Request
	var headers = ["Content-Type: application/json"]
	$CreateRoomHTTPRequest.request(Session.URL + "/room/create", headers, false, HTTPClient.METHOD_GET)
	pass

func _on_CreateRoomHTTPRequest_request_completed(result, response_code, headers, body):
	var json_data: Dictionary
	if response_code == 200:
		json_data = JSON.parse(body.get_string_from_utf8()).result
		if json_data["success"] == true:
			set_room_data(json_data["DTO"])
			self_join()
		else:
			$CreateRoomButton.disabled = false
	else:
		$CreateRoomButton.disabled = false
	pass

func set_room_data(room_data: Dictionary) -> void:
	Session.data["room"]["id"] = int(room_data["id"])
	pass

func self_join():
	var data: Dictionary = Session.data["user"]
	var json_sent = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	$JoinRoomHTTPRequest.request(Session.URL + "/room/" + String(Session.data["room"]["id"]) + "/join", headers, false, HTTPClient.METHOD_POST, json_sent)
	pass

func _on_JoinRoomHTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		get_tree().change_scene(Session.build_scene_URL("WaitingRoom"))
	pass


func _on_JoinRoomButton_pressed():
	set_room_data({
		"id": $RoomIDText.text
	})
	self_join()
	pass
