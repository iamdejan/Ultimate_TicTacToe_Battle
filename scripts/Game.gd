extends Node2D

var is_game_finished: bool = false

const LOCAL_BOARD = "LocalBoard"
const GLOBAL_BOARD = "GlobalBoard"
const SIZE = 9

var allow_all_squares: bool

# TODO: later refactor
#class Position:
#	func __init__(row, column):
#		self.co
#		pass

func _ready():
	allow_all_squares = true
	$CurrentSignLabel.text = "X"
	$WinnerLabel.text = ""
	$GoBackButton.disabled = true
	$GoBackButton.visible = false
	set_process(false)

	set_title()

	get_events()

	pass

func set_title():
	$TitleLabel.text = Session.data["room"]["X"]["name"]
	$TitleLabel.text += "\nVS\n"
	$TitleLabel.text += Session.data["room"]["O"]["name"]
	pass

func get_events():
	var URL: String = Session.URL + "/room/" + String(Session.data["room"]["id"]) + "/events/" + Session.data["room"]["last_event_id"]
	var headers = ["Content-Type: application/json"]
	$EventsHTTPRequest.request(URL, headers, false, HTTPClient.METHOD_GET)
	pass

func _on_EventsHTTPRequest_request_completed(result, response_code, headers, body: PoolByteArray):
	var data: Dictionary = JSON.parse(body.get_string_from_utf8()).result

	if response_code == 200:
		var DTO: Dictionary = data["DTO"]
		Session.data["room"]["last_event_id"] = String(DTO["newLastID"])
		handle_events(DTO["events"])
		if is_game_finished != true:
			get_events()
	else:
		print("Error! Response code: " + String(response_code))
		print("Message error:" + data["message"])
	pass

func build_node_name(position: Dictionary) -> String:
	return "Cell" + String(position["row"]) + String(position["column"]) + "Button"

func settle_square(position: Dictionary, player_sign: String):
	var button_name: String = build_node_name(position)
	var button_node: TextureButton = get_node(LOCAL_BOARD + "/" + button_name)
	button_node.disabled = true

	var button_label: Sprite = get_node(LOCAL_BOARD + "/" + button_name + "/" + player_sign)
	button_label.visible = true

func find_center(position: Dictionary) -> Dictionary:
	var row = floor(position["row"] / 3)
	var column = floor(position["column"] / 3)

	row *= 3
	row += 1

	column *= 3
	column += 1

	return {"row": row, "column": column}

func find_delta(a: Dictionary, b: Dictionary) -> Dictionary:
	var row = a["row"] - b["row"]
	var column = a["column"] - b["column"]
	return {"row": row, "column": column}

func traverse_all_squares(disabled_status: bool):
	for row in range(SIZE):
		for column in range(SIZE):
			var node_name = build_node_name({"row": row, "column": column})
			var node = get_node(LOCAL_BOARD + "/" + node_name)
			if node.visible:
				node.disabled = disabled_status
			pass
		pass
	pass

func enable_all_squares():
	traverse_all_squares(false)

func disable_all_squares():
	traverse_all_squares(true)

func calculate_new_global_position(position, center_position) -> Dictionary:
	var new_position: Dictionary = find_delta(position, center_position)
	new_position["row"] += 1
	new_position["column"] += 1
	return new_position

func apply_move(position: Dictionary, player_sign: String) -> void:
	settle_square(position, player_sign)
	var center_position: Dictionary = find_center(position)
	var new_position: Dictionary = calculate_new_global_position(position, center_position)
	allow_all_squares = is_local_board_won(new_position, player_sign)

	# TODO: if allow all squares, open all squares
	if allow_all_squares:
		enable_all_squares()
	else:
		disable_all_squares()
		for i in range(3):
			for j in range(3):
				var row = new_position["row"] * 3 + i
				var column = new_position["column"] * 3 + j
				var node_name = build_node_name({"row": row, "column": column})
				var node = get_node(LOCAL_BOARD + "/" + node_name)
				if node.visible:
					node.disabled = false
				pass
			pass
		pass

func fill_local_board(global_position: Dictionary, player_sign: String):
	var row = int(global_position["row"]) * 3
	var column = int(global_position["column"]) * 3

	for i in range(3):
		for j in range(3):
			var node_name: String = build_node_name({"row": (row + i), "column": (column + j)})
			settle_square({"row": (row + i), "column": (column + j)}, player_sign)
			get_node(LOCAL_BOARD + "/" + node_name).set_visible(false)

	pass

func win_local_board(global_position: Dictionary, player_sign: String):
	var button_node: TextureButton = get_node(GLOBAL_BOARD + "/" + build_node_name(global_position))
	button_node.disabled = true
	button_node.visible = true

	var button_label: Sprite = get_node(GLOBAL_BOARD + "/" + build_node_name(global_position) + "/" + player_sign)
	button_label.visible = true
	pass

func handle_events(events: Array):
	print(events)
	for event in events:
		var eventDTO: Dictionary
		if event.has("DTO"):
			eventDTO = event["DTO"]
			if eventDTO.has("nextPlayerSign"):
				Session.data["room"]["current_player_sign"] = eventDTO["nextPlayerSign"]
				$CurrentSignLabel.text = eventDTO["nextPlayerSign"]
		match event["type"]:
			"VALID_MOVE":
				var position: Dictionary = eventDTO["position"]
				apply_move(position, eventDTO["playerSign"])
			"WIN_LOCAL_BOARD":
				fill_local_board(eventDTO["globalPosition"], eventDTO["playerSign"])
				win_local_board(eventDTO["globalPosition"], eventDTO["playerSign"])
			"GAME_ENDS":
				$WinnerLabel.text = Session.data["room"][eventDTO["winner"]["playerSign"]]["name"] + " (" + eventDTO["winner"]["playerSign"] + ")" + " wins!"
				is_game_finished = true
				$GoBackButton.disabled = false
				$GoBackButton.visible = true
	pass

func is_local_board_won(position: Dictionary, player_sign: String) -> bool:
	var node_name = GLOBAL_BOARD + "/" + build_node_name(position)
	return get_node(node_name).visible == true


func _on_GoBackButton_pressed():
	get_tree().change_scene(Session.build_scene_URL("Dashboard"))
	pass
