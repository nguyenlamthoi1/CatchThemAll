extends Node

var CardTemp = preload("res://scenes/Card.tscn")

var game_mode = GlobalGame.GAME_MODE.PVP

var _current_player
var _deck = []
var _card_dict = []

onready var _players = {
	"0": $VBoxContainer/Player2, # Player at bottom screen
	"1": $VBoxContainer/Player1, # Player at top screen
}
onready var _draw_pos = $DrawPosition



const P1 = "0"
const P2 = "1"

var rng = RandomNumberGenerator.new()

func _ready():
	print("[Main Game] ready!")
	rng.randomize()
	
	_deck = []
	_card_dict = GlobalGame.CARD_DICT
	
	start_game(GlobalGame.GAME_MODE.PVP)

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
	_players[P1].init_player(P1, "Player 1", GlobalGame.GAME_MODE.PVP)
	_players[P2].init_player(P2, "Player 2", GlobalGame.GAME_MODE.PVP)
	
	for player_id in _players:
		var cur_player = _players[player_id]
		if !cur_player.is_full_hand():		
			# create new card
			var drawn_card_data = _deck.pop_back()
			var new_card = CardTemp.instance()
			new_card.init_card(drawn_card_data, player_id)
			cur_player.draw_card(_draw_pos, new_card)
		
		
	
	

	
