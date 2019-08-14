extends Node2D

var player_counter: int = 0

func _ready():
	set_process(false)
	get_events()
	pass

func get_events():
	var URL: String = Session.URL + "/room/" + String(Session.data["room"]["id"]) + "/events/" + Session.data["room"]["last_event_id"]
	var headers = ["Content-Type: application/json"]
	$EventsHTTPRequest.request(URL, headers, false, HTTPClient.METHOD_GET)
	pass

func _on_EventsHTTPRequest_request_completed(result, response_code, headers, body: PoolByteArray):
	if response_code == 200:
		var json_data: Dictionary = JSON.parse(body.get_string_from_utf8()).result
		if json_data["success"] == true:
			var data: Dictionary = json_data["DTO"]
			Session.data["room"]["last_event_id"] = String(data["newLastID"])
			handle_events(data["events"])
			get_events()
	pass

func handle_events(events: Array):
	for event in events:
		var eventDTO: Dictionary
		if event.has("DTO"):
			eventDTO = event["DTO"]
		match event["type"]:
			"JOIN_ROOM":
				join_room(eventDTO["player"])
			"LEAVE_ROOM":
				leave_room(eventDTO["player"])
			"GAME_START":
				start_game(eventDTO["nextPlayerSign"])
				pass
	pass

func join_room(player: Dictionary) -> void:
	var node_name: String = "Player" + String(player_counter) + "Label"
	get_node(node_name).text = player["name"]
	
	Session.data["room"][player["sign"]] = player

	if int(player["id"]) == int(Session.data["user"]["id"]):
		Session.data["room"]["my_sign"] = player["sign"]
	player_counter += 1
	pass

func leave_room(player: Dictionary) -> void:
	if int(player["id"]) == int(Session.data["user"]["id"]):
		Session.reset_room_data()
		get_tree().change_scene(Session.build_scene_URL("Dashboard"))
	pass

func start_game(current_player_sign: String):
	Session.data["room"]["current_player_sign"] = current_player_sign
	get_tree().change_scene(Session.build_scene_URL("Game"))
	pass