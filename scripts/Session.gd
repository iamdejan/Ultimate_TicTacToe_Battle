extends Node

const URL = "http://localhost:3000"

var data: Dictionary = {
	"user": {
		"id": -1,
		"name": ""
	},
	"room": {
		"id": -1,
		"my_sign": "",
		"last_event_id": "-1",
		"X": {},
		"O": {},
		"current_player_sign": ""
	}
}

func reset_room_data():
	self.data["room"].clear()
	self.data["room"] = {
		"ID": -1
	}
	pass

func build_scene_URL(name) -> String:
	return "res://scenes/" + name + ".tscn"