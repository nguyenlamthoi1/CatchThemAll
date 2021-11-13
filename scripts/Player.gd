extends Node

enum {AI_EASY, AI_HARD}

var score = 0
var hand = [null, null, null, null]
var hand_num = 0
var player_name = ""
var player_mode = ""
var id = 0

var max_hand = 4
var card_slots = []

var ai_mode = AI_EASY
var with_ai = false

#actions
var can_drag_card = false
var can_think = true
var start_think = false
var found_sol = false
var _gm
onready var player_info = $PlayerSecondInfo/PlayerInfo

#thread and ai
var thread

var rng = RandomNumberGenerator.new()

func init_player(p_id, p_name, p_mode, gm):
	_gm = gm
	id = p_id
	player_name = p_name
	player_mode = p_mode
	hand = [null, null, null, null]
	score = 0
	
	var slot_container = get_node("PlayerFirstInfo/PlayerGUI/HBoxContainer")
	var slots_children = slot_container.get_children()
	for i in range(slots_children.size()):
		var slot = slots_children[i]
		card_slots.append(slot)
		
	#player_info = $PlayerSecondInfo/PlayerInfo
	
	update_name(player_name)
	update_score(score)
	
	if player_mode == GlobalGame.GAME_MODE.PVP:
		with_ai = false
	else:
		if player_mode == GlobalGame.GAME_MODE.AI_RANDOM:
			ai_mode = AI_EASY
			with_ai = true
			print("creating AI Mode: Easy: ", player_name)
			
		elif GlobalGame._game_mode == GlobalGame.GAME_MODE.AI_RANDOM:
			ai_mode = AI_HARD
			with_ai = true
			print("creating AI Mode: Hard: ", player_name)
		else:
			ai_mode = AI_EASY
			with_ai = true
			print("creating AI Mode: Easy: ")
			

func draw_card(from_node, card_instance):
	#var empty_slot = _get_first_empty_slot_2()
	#if empty_slot == null:
	#	return
	var found_empty_idx = _get_first_hand_idx()
	if found_empty_idx < 0:
		return
		
	var empty_slot = card_slots[found_empty_idx]
	empty_slot.add_child(card_instance)
	card_instance.idx_in_hand = found_empty_idx
	card_instance.card_owner = self
	
	hand[found_empty_idx] = card_instance
	hand_num += 1
	#card_instance.global_position = empty_slot.global_position
	if with_ai:
		card_instance.connect("arrived", self, "start_thinking")
		card_instance.move_from_to(from_node.global_position , empty_slot.rect_global_position, true)
		#card_instance.move_from_to(from_node.global_position , empty_slot.rect_global_position)
	else:
		card_instance.move_from_to(from_node.global_position , empty_slot.rect_global_position)
		
func _get_first_empty_slot():
	var slot_found = null
	for i in range(card_slots.size()):
		var slot = card_slots[i]
		var child_num = slot.get_node("Holder").get_child_count()
		if (child_num <= 0): # found empty slot
			slot_found = slot
			break
	return slot_found
	
func _get_first_empty_slot_2():
	var slot_found = null
	
	if is_full_hand():
		return slot_found
		
	var found_index = -1
	
	found_index = 0
	for i in range(hand.size()):
		var card = hand[i]
		#print("test_card ", i, card == null)
		if card == null:
			#print("FOUND_CARD_", i)
			found_index = i
			break
		
	slot_found = card_slots[found_index] 
	print('found_empty_at_',found_index," size = " ,hand.size())
	return slot_found
	
func _get_first_hand_idx():
	var found_index = -1
	
	if is_full_hand():
		return found_index
		
	found_index = 0
	
	for i in range(hand.size()):
		var card = hand[i]
		if card == null:
			found_index = i
			break
		
	return found_index
	
func is_full_hand():
	return hand_num >= max_hand
			

func update_name(pname):
	var name_label = player_info.get_node("NameBackground/NameLabel")
	name_label.text = pname
	name = pname
	
func update_score(pscore):
	var score_label = player_info.get_node("ScoreCounter/ScoreLabel")
	score_label.text = str(pscore)	
	score = pscore
	
func enable_turn(enable):
	can_drag_card = enable
	var can_think = true
	
func start_thinking():
	#print("try thinking")
	if can_think and with_ai:
		#print("start thinking")
		
		thread = Thread.new()
		# Third argument is optional userdata, it can be any variable
		if ai_mode == AI_EASY:
			thread.start(self, "easy_thinking", player_name)
			#easy_thinking(player_name)
			#thread.start(self, "hard_thinking", player_name)
		if ai_mode == AI_HARD:
			thread.start(self, "hard_thinking", player_name)
func easy_thinking(player_name):
	print(player_name, " easy thinking...")
	
	var EMPTY_TYPE = 99
	var EFF_TYPE = 100
	var P1_TYPE = 0
	var P2_TYPE = 1
	var board_ui = _gm._board_ui
	
	var empty_board_array = []
	var my_data_board = board_ui.data_board.duplicate(true)
	for r in GlobalGame.ROWS:
		for c in GlobalGame.COLUMNS:
			if my_data_board[r][c] == EMPTY_TYPE:
				empty_board_array.append([r,c])
	rng.randomize()
	var rand_i = rng.randi_range(0, empty_board_array.size() - 1)
	var found_sol = true
	var sol_pos = empty_board_array[rand_i]
	
	var hand_array = []
	for i in range(hand.size()):
		if hand[i] != null:
			hand_array.append(i)
	
	
	var rand_hand_id  =rng.randi_range(0, hand_array.size() - 1)
	#print(player_name, " make decision! at")	
	#do_drop_card_at(hand_array[rand_hand_id], sol_pos)
	
	# while true if want to wait 3s
	while true:
		#
		#print("while true")
		var cur_time = _gm.get_time()
		if  cur_time < GlobalGame.AI_LIMIT_THINKING_TIME  or cur_time < GlobalGame.PLAYER_TURN_TIME - 3.0:
			print(player_name, " make decision! at ", str(cur_time), " : ", str(sol_pos[0]),",",str(sol_pos[1]))
			found_sol = false
			do_drop_card_at(rand_hand_id, sol_pos)
			return
		#elif found_sol:
		#	found_sol = false
		#	return
	return

func hard_thinking(player_name):
	print(player_name, " hard thinking...")
	
	var EMPTY_TYPE = 99
	var EFF_TYPE = 100
	var P1_TYPE = 0
	var P2_TYPE = 1
	
	var board_ui = _gm._board_ui
	
	var empty_board_array = []
	
	var my_data_board = board_ui.data_board.duplicate()
	var my_eff_board = board_ui.eff_board.duplicate()
	var my_ui_booard = board_ui.ui_board
	
	# Minmax AI all steps:
	# 1. create board_state = [ <Slot> ]
	var board_state = []
	for r in GlobalGame.ROWS:
		for c in GlobalGame.COLUMNS:
			var ui_slot = board_ui.get_ui_slot(r, c)
			var slot
			if my_data_board[r][c] == EMPTY_TYPE:
				slot = MaxMinAI.Slot.new()
			else:
				var ui_card = board_ui.get_card_at(r, c)				
				var card_id = ui_card.get_id()
				var base_stats = ui_card.get_base_stats()
				var eff_buff = my_eff_board[r][c]
				
				var owner_id = 0
				match ui_card.card_owner.id:
					"0": #P1
						owner_id = 1
					"1": #P2
						owner_id = 2
						
				slot = MaxMinAI.Slot.new(card_id, base_stats, eff_buff, owner_id)
				
			board_state.append(slot)
	# 2. create board root node
	var board_root_node = MaxMinAI.BoardNode.new(board_state)
	
	# 3. execute ai algorithm
	var ai_executer = MaxMinAI.new(_gm)
	var sol = ai_executer.find_sol(board_root_node)
	var chosen_pos = sol[0]
	var max_value = sol[1]
				

	do_drop_card_at(rand_hand_id, sol_pos)
	return

func do_drop_card_at(hand_card_id, drop_pos):
	print("do drop: ", hand_card_id, " at ", str(drop_pos[0], " , " , str(drop_pos[1])))
	var r = drop_pos[0]
	var c = drop_pos[1]
	
	var drop_card = hand[hand_card_id]
	hand_num -= 1
	
	var board_ui = _gm._board_ui
	var drop_slot = board_ui.ui_board[r][c]
	
	var from_pos = drop_card.global_position
	var to_pos =	 drop_slot.marker.global_position
	drop_card.set_can_drop(drop_slot, Vector2(drop_pos[0], drop_pos[1]))
	drop_card.on_drop_card()
	
	drop_card.move_from_to(from_pos, to_pos)


