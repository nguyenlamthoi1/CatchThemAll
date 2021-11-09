extends Node

var score = 0
var hand = []
var player_name = ""
var player_mode = ""
var id = 0

func init_player(p_id, p_name, p_mode):
	id = p_id
	player_name = p_name
	player_mode = p_mode
	hand = []
	score = 0

func draw_card(from_w_pos, to_w_pos, card_instance):
	card_instance.move_from_to(from_w_pos, to_w_pos)
