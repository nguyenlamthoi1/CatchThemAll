extends Node

var CardTemp = preload("res://scenes/Card.tscn")

var game_mode = GlobalGame.GAME_MODE.PVP
var _pausing_state_game

var _current_player
var _deck = []
var _card_dict = []

var _cur_time := 0.0
var _max_time_turn := 0.0
var _time_ready := 2.0
var _state_game = 0

const GAME_PAUSED = 0
const GAME_RUN = 1
const GAME_READY = 2
const GAME_OVER = 3


onready var _players = {
	"0": $VBoxContainer/Player2, # Player at bottom screen
	"1": $VBoxContainer/Player1, # Player at top screen
}
onready var _draw_pos = $DrawPosition
onready var _time_count = $TimeCount
onready var _gui_text = $GuiText
onready var _board_ui = $BoardContainer
onready var _result_popup = $PopupContainer

const P1 = "0"
const P2 = "1"

var rng = RandomNumberGenerator.new()

func _ready():
	print("[Main Game] ready!")
	rng.randomize()
	
	_players[P1].init_player(P1, "Player 1", GlobalGame.GAME_MODE.PVP)
	_players[P2].init_player(P2, "Player 2", GlobalGame.GAME_MODE.PVP)
	
	_deck = []
	_card_dict = GlobalGame.CARD_DICT
	_max_time_turn = GlobalGame.PLAYER_TURN_TIME
	_cur_time = _time_ready
	
	_board_ui.init_board()
	_board_ui.gm = self
	
	_result_popup.init_popup(self)
	
	_state_game = GAME_READY
	
	_gui_text.start_show("Start game")
	#start_game(GlobalGame.GAME_MODE.PVP)

func _process(delta):
	if _state_game == GAME_PAUSED:
		return
	elif _state_game == GAME_READY:
		_cur_time = _cur_time - delta
		#print("cur_time" + str(_cur_time))
		if _cur_time <= 0:
			_cur_time = _max_time_turn
			_state_game == GAME_RUN
			print("start_game")
			start_game(GlobalGame.GAME_MODE.PVP)
	elif _state_game == GAME_RUN:
		_cur_time = _cur_time - delta
		if _cur_time <= 0 :
			_switch_turn()
	elif _state_game == GAME_OVER:
		pass
		#print("Game over!")
	
	
	if _state_game == GAME_RUN:
		_time_count.text = str(round(_cur_time))
	
	_time_count.text = str(round(_cur_time))
	

func start_game(mode):
	game_mode = mode
	
	_prepair_deck()
	
	if game_mode == GlobalGame.GAME_MODE.PVP:
		_start_pvp_game()

func _prepair_deck():
	var level = GlobalGame.LEVEL_0
	var str_level = "LEVEL_" + str(level)
	var max_num = GlobalGame.LV_DECK_NUM[str_level]
	var cur_num = 0
	var card_list = GlobalGame.CARD_DICT[str_level]
	#GlobalGame.DECK_NUM
	for i in range(GlobalGame.DECK_NUM): # Pick a random card
		if cur_num >= max_num: # Increase level of picked card
			level += 1
			str_level ="LEVEL_" + str(level)
			max_num = GlobalGame.LV_DECK_NUM[str_level]
			cur_num = 0
			card_list = GlobalGame.CARD_DICT[str_level]
		rng.randomize()
		# Get random card
		var rand_i = rng.randi_range(0, card_list.size() - 1)
		var pick_card = card_list[rand_i]
		var pick_card_index = rand_i
		# Add to deck at random position
		rng.randomize()	
		rand_i = rng.randi_range(0, _deck.size() - 1)
		rand_i = 0 if rand_i < 0 else rand_i
		_deck.insert(rand_i, pick_card.duplicate())
		#_deck.insert(rand_i, pick_card_index)
		#print("test_i inser at:  "+ str(rand_i)+" with " + str(i) + " id = " + str(pick_card_index) + " - size :" + str(_deck.size()))
		
		cur_num += 1				
			
	# For debug only
	var num_0 = 0
	var num_1 = 0
	var num_2 = 0
	#print("[Deck] total = " + str(_deck.size()))
	for i in range(_deck.size()):
		pass
		#print("[Deck] has: " + str(_deck[i]))
		num_0 = num_0 + 1 if _deck[i].type == 0 else num_0
		num_1 = num_1 + 1 if _deck[i].type == 1 else num_1 
		num_2 = num_2 + 1 if _deck[i].type == 2 else num_2 
	print("[Deck] total = " + str(_deck.size()) + " - " + str(num_0)+ "," +  str(num_1)+ "," +  str(num_2)+ ",")
	# --
		
func _start_pvp_game():
	for player_id in _players:
		var cur_player = _players[player_id]
		if !cur_player.is_full_hand():		
			_do_deal_card(player_id)
	
	var random_first_id = str(rng.randi_range(0, 1))
	_current_player = _players[random_first_id]
	var next_player = get_opponent(random_first_id)
	_current_player.enable_turn(true)
	next_player.enable_turn(false)
	
	var msg = _current_player.name + " go first"
	_gui_text.start_show(msg)	
	_state_game = GAME_RUN
	
	
func _do_deal_card(player_id):
	var cur_player = _players[player_id]
	if cur_player.is_full_hand():
		return
		
	# create new card
	var drawn_card_data = _deck.pop_back()
	var new_card = CardTemp.instance()
	new_card.gm = self
	new_card.init_card(drawn_card_data, player_id)
	cur_player.draw_card(_draw_pos, new_card)
	
func _switch_turn():
	#print("test curret: ", _current_player.id, "- ", P1, " - ", P2)
	_cur_time = _max_time_turn
	
	var new_turn_id = -1
	if _current_player.id == P1:
		new_turn_id = P2
	else:
		new_turn_id = P1
		
	_current_player = _players[new_turn_id]
	var old_player = get_opponent(new_turn_id)
	
	# Enable drag card
	_current_player.enable_turn(true)
	old_player.enable_turn(false)
	
	# Notify
	var msg = "Turn of\n" + _current_player.name
	#print("switch_turn ",new_turn_id)
	_gui_text.start_show(msg)
	
	# Try draw card
	if _deck.size() - 1 > 0:
		_do_deal_card(new_turn_id)
	else:
		#print("Game over: out of deck")		
		#_do_over_state()
		pass

func _on_card_drop(player_id, drop_card, pos):
	# do drop card on board
	_board_ui.on_card_drop(player_id, drop_card, pos)
	# check if board is full
	if _board_ui.is_full():
		print("Game over: found winner!")
		_do_over_state()
		return
	else:
		_switch_turn()
	
func get_player(player_id):
	return _players[player_id]

func get_opponent(player_id):
	var opponent_id = P1 if player_id == P2 else P2
	return _players[opponent_id]
	
func get_opponent_id(player_id):
	return P1 if player_id == P2 else P2
	
func update_score_from_board():
	for player_id in _players:
		var new_score = _board_ui.player_scores[player_id]
		var player = _players[player_id]
		player.update_score(new_score)		
	
func pause():
	_pausing_state_game = _state_game
	_state_game = GAME_PAUSED # Stop counting time
	if _current_player:
		_current_player.enable_turn(false) # Stop interacting
	
func continue_game():
	_state_game = _pausing_state_game
	if _current_player:
		_current_player.enable_turn(true)


func _on_PauseButton_pressed():
	pause()
	_result_popup.show_pause()
	
func _do_over_state():
	_current_player.enable_turn(false) # Stop interacting
	get_opponent(_current_player.id).enable_turn(false)
	_state_game = GAME_OVER		
	var p1_score = _board_ui.player_scores[P1]
	var p2_score = _board_ui.player_scores[P2]
	
	_result_popup.show_result(p1_score, p2_score)
	
	
