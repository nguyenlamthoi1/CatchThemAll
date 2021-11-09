extends Node

var CardTemp = preload("res://scenes/Card.tscn")

var game_mode = GlobalGame.GAME_MODE.PVP

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

onready var _players = {
	"0": $VBoxContainer/Player2, # Player at bottom screen
	"1": $VBoxContainer/Player1, # Player at top screen
}
onready var _draw_pos = $DrawPosition
onready var _time_count = $TimeCount
onready var _gui_text = $GuiText
onready var _board_ui = $VBoxContainer/BoardContainer

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
			_cur_time = _max_time_turn
			_switch_turn()
	
	
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
	_state_game = GAME_RUN
		
func _do_deal_card(player_id):
	var cur_player = _players[player_id]
	
	# create new card
	var drawn_card_data = _deck.pop_back()
	var new_card = CardTemp.instance()
	new_card.init_card(drawn_card_data, player_id)
	cur_player.draw_card(_draw_pos, new_card)
	
func _switch_turn():
	print("test curret: ", _current_player.id, "- ", P1, " - ", P2)
	var new_turn_id = -1
	if _current_player.id == P1:
		new_turn_id = P2
	else:
		new_turn_id = P1
		
	_current_player = _players[new_turn_id]
	var msg = "Turn of\n" + _current_player.name
	print("switch_turn ",new_turn_id)
	
	_gui_text.start_show(msg)
	
	_do_deal_card(P1)
	_do_deal_card(P2)
	
	

	
