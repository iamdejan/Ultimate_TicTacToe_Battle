extends TextureButton

func setup_data() -> String:
	var position = self.name.trim_prefix("Cell").trim_suffix("Button").split("")[0]
	var data: Dictionary = {
		"row": int(position[0]),
		"column": int(position[1])
	}
	var json_sent: String = JSON.print(data)
	return json_sent

func _on_CellButton_pressed():
	if is_my_turn() != true:
		return
	
	var URL: String = Session.URL + "/room/" + String(Session.data["room"]["id"]) + "/player/" + Session.data["room"]["my_sign"] + "/move"
	var json_sent: String = setup_data()
	var headers = ["Content-Type: application/json"]
	$SubmitMoveHTTPRequest.request(URL, headers,false,HTTPClient.METHOD_POST, json_sent)
	pass

func is_my_turn() -> bool:
	return Session.data["room"]["current_player_sign"] == Session.data["room"]["my_sign"]