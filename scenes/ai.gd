class_name MaxMinAI

const EMPTY = 0
const P1 = 1
const P2 = 2

const P1_HAND = 0
const P2_HAND = 1

const MAX_DEPTH = 5

var _gm

class Slot:
	var _cur_card_id = -1
	var _eff_buff = 0
	var _base_stats = [0, 0, 0, 0]	
	#var _real_stats = [0, 0, 0, 0]
	var _owner_id = 0 # 1 -> p1 , 2 -> p2, 0 -> empty
	var _pos = Vector2(0.0, 0.0)
	
	func _init(card_id = -1, base_stats = [0,0,0,0], p_effect_buff = 0, owner_id = 0):
		_cur_card_id = card_id
		_base_stats = base_stats
		_eff_buff = p_effect_buff
		_owner_id = owner_id
	
	func set_position(r, c):
		_pos = Vector2(r, c)
		
	func set_eff_buff(buff):
		_eff_buff = buff
	
	func is_empty():
		return _owner_id == 0 or _cur_card_id < 0
	
	func check_owner(owner_id):
		return _owner_id == owner_id 
	
	func set_owner(owner_id):
		_owner_id = owner_id
		
	func get_stat(stat_id):
		return _base_stats[stat_id] + _eff_buff
		
	func add_new_card(card_id, base_stats, owner_id):
		if is_empty():
			_cur_card_id = card_id
			_base_stats = base_stats
			_owner_id = owner_id
	
	func get_clone():
		var clone = Slot.new()
		clone._cur_card_id = _cur_card_id
		clone._eff_buff = _eff_buff
		clone._base_stats = _base_stats.duplicate()
		clone._owner_id = _owner_id
		clone._pos = _pos
		return clone
	
	func print_data():
		var msg = "("
		msg += str(_cur_card_id) + " , "
		#msg += str(_eff_buff) + " , "		
		#msg += str(_base_stats) + " , "		
		msg += str(_owner_id) + " , "
		
		msg += ")"
		print(str(_pos.x), " - ", str(_pos.y), " : ", msg)

class Hand:
	var _cards = [] 

class BoardNode:
	var _board_state = [] # [<Slot>]
	var _hands
	
	func print_data():
		var str_r = ""
		for r in 4:
			str_r = ""
			for c in 4 :
				var ch = str(_board_state[r][c]._owner_id)
				str_r += " " + ch
			print(str(r), " : ", str_r)
	
	func _init(p_board_state, p1_hand, p2_hand):
		_hands = [p1_hand, p2_hand]
		_board_state = p_board_state
	
	func is_leaf() -> bool: # full board<-> leaf node
		var is_full: bool = true
		for r in GlobalGame.ROWS:
			for c in GlobalGame.COLUMNS:
				var slot =_board_state[r][c]
				if slot.is_empty():
					is_full = false 
					break
		return is_full
	
	func get_h_value() -> int:
		var p1_num = 0
		var p2_num = 0
		for r in GlobalGame.ROWS:
			for c in GlobalGame.COLUMNS:
				var slot = _board_state[r][c]
				if  slot.check_owner(P1):
					p1_num += 1
				elif slot.check_owner(P2):
					p2_num += 1
		var h_value: int = p2_num - p1_num # P2 start with MAximize
		return h_value
	
	func _copy_board_state():
		var copy_board_state = []
		for r in 4:
			copy_board_state.append([])
			for c in 4:
				copy_board_state[r].append(_board_state[r][c].get_clone())
				
		return copy_board_state
	
	func get_all_next_nodes(player_id):
		var player_hand = _hands[P1_HAND] if player_id == P1 else _hands[P2_HAND]
		#player_hand = player_hand.duplicate(true)
		
		var opp_hand  = _hands[P1_HAND] if player_id == P1 else _hands[P2_HAND]
		opp_hand = opp_hand.duplicate(true)
		
		var child_nodes = []
		var empty_board_pos_arr = []
		for r in GlobalGame.ROWS:
			for c in GlobalGame.COLUMNS:
				var slot = _board_state[r][c]
				if slot.is_empty():
					empty_board_pos_arr.append([r,c])
		for hand_idx in 4:
			if player_hand[hand_idx].card_id < 0: # no need check this card
				continue
				
			for i in empty_board_pos_arr.size():
				#var checking_board  = _board_state.duplicate(true)
				var checking_board = _copy_board_state()
				
				var card_data = player_hand[hand_idx]
				
				var r = empty_board_pos_arr[i][0]
				var c = empty_board_pos_arr[i][1]
				var chosen_slot = checking_board[r][c]
				
				if chosen_slot.is_empty():
					chosen_slot.set_owner(player_id)
				else:
					continue
				
				_try_catch_others(checking_board, card_data, player_id, r, c)
				
				# removing dropped card
				var new_player_hand = player_hand.duplicate(true)
				#new_player_hand.remove(hand_idx)
				new_player_hand[hand_idx].card_id = -1
				
				# create child node with data of new board and new player_hand
				var child_node
				if player_id == P1:
					child_node = BoardNode.new(checking_board, new_player_hand, opp_hand)
				elif player_id == P2:
					child_node = BoardNode.new(checking_board, opp_hand, new_player_hand)
					
				var chosen_hand_idx = hand_idx
				
				child_nodes.append([child_node, [r, c], chosen_hand_idx])
			
		return child_nodes
	
	func _try_catch_others(checking_board, card_data, player_id, row, col):
		var left = GlobalGame.LEFT
		var right =  GlobalGame.RIGHT
		var top = GlobalGame.TOP
		var bottom = GlobalGame.BOTTOM
		
		var check_pairs_stats = [[right, left], [bottom, top], [left, right], [top, bottom]]
		var directions = [[0, -1], [-1, 0], [0, 1], [1, 0]]
		
		var dropped_card_id = card_data.card_id
		var dropped_card_base_stats = card_data.base_stats
		
		# try add new card to checking slot
		var cur_slot = checking_board[row][col] # This is slot		
		cur_slot.add_new_card(dropped_card_id, dropped_card_base_stats, player_id)
		
		var dir_num = directions.size()
		for i in range(dir_num):
			# Get adjacent one
			var cur_dir = directions[i]
			var adj_row = row + cur_dir[0]
			var adj_col = col + cur_dir[1]
			
			# Check if it a valid adjacent position		
			if _is_pos_in_range(adj_row, adj_col):
				#print("check _ true: ", str(adj_row), " , ", str(adj_col))
				var adj_slot = checking_board[adj_row][adj_col]
				if !adj_slot.is_empty() and !adj_slot.check_owner(player_id):
					var adj_stat = check_pairs_stats[i][0]
					var cur_stat = check_pairs_stats[i][1]
					
					var adj_slot_stat =  adj_slot.get_stat(adj_stat)
					var cur_slot_stat = cur_slot.get_stat(cur_stat)
					var can_catch = adj_slot_stat < cur_slot_stat
					#print('compare: ', str(adj_slot.get_stat(adj_stat)), " vs ",cur_slot.get_stat(adj_stat) )
					if can_catch:
						# update new data
						adj_slot.set_owner(player_id)
			else:
				pass
		
	func _is_pos_in_range(row, col):
		var valid_row = 0 <= row and row < GlobalGame.ROWS
		var valid_col = 0 <= col and col < GlobalGame.COLUMNS
		return valid_row and valid_col	
			
func _init(gm):
	_gm = gm			
			
func find_sol(board_node: BoardNode, maximize_player:bool, player_id, depth: int, alpha: int, beta: int):
	if board_node.is_leaf() or depth == MAX_DEPTH  or _gm.get_time() < GlobalGame.PLAYER_TURN_TIME - 3.0:
		#.. or _gm.get_time() < GlobalGame.PLAYER_TURN_TIME - 3.0
		var hvalue = board_node.get_h_value()
		return [hvalue]
	if maximize_player:
		#var value = -INF
		var value = -1000
		var pos = null
		var chosen_hand_idx = -1
		
		var children = board_node.get_all_next_nodes(player_id)
		
		for i in children.size():
			var child_node = children[i][0]
			#pos = children[i][1]
			#chosen_hand_idx = children[i][2]
			
			var find_s = find_sol (child_node, false, _get_opp_id(player_id), depth + 1, alpha, beta)
			
			var new_value = find_s[0]
			if new_value > value:
				value = find_s[0]
				pos = children[i][1]
				chosen_hand_idx = children[i][2]
			
			alpha = max(alpha, value)
			if value >= beta:
				break
				
		return [value, pos, chosen_hand_idx]
		
	else:
		#var value = INF
		var value = 1000
		var pos = null
		var chosen_hand_idx = -1		
		
		var children = board_node.get_all_next_nodes(player_id)
		
		for i in children.size():
			var child_node = children[i][0]
			#pos = children[i][1]
			#chosen_hand_idx = children[i][2]
			
			var find_s = find_sol (child_node, true,_get_opp_id(player_id), depth + 1, alpha, beta)
			var new_value = find_s[0]
			if new_value < value:
				value = find_s[0]
				pos = children[i][1]
				chosen_hand_idx = children[i][2]
			
			beta = min(beta, value)
			if value <= alpha:
				break
				
		return [value, pos, chosen_hand_idx]
		
func _get_opp_id(player_id):
	return P1 if player_id == P2 else P2
