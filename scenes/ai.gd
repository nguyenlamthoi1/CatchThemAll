
class_name MaxMinAI

const EMPTY = 0
const P1 = 1
const P2 = 2

const MAX_DEPTH = 3

class Slot:
	var _cur_card_id = -1
	var _eff_buff = 0
	var _base_stats = [0, 0, 0, 0]	
	#var _real_stats = [0, 0, 0, 0]
	var _owner_id = 0 # 1 -> p1 , 2 -> p2, 0 -> empty
	
	func _init(card_id = -1, base_stats = [0,0,0,0], p_effect_buff = 0, owner_id = 0):
		_cur_card_id = card_id
		_base_stats = base_stats
		_eff_buff = p_effect_buff
		_owner_id = owner_id
		
	
	func is_empty():
		return _owner_id == 0
	
	func check_owner(owner_id):
		return _owner_id == owner_id
	
	func set_owner(owner_id):
		_owner_id == owner_id
		
	func get_stat(stat_id):
		return _base_stats[stat_id] + _eff_buff

class BoardNode:
	var _board_state
	
	func _init(p_board_state):
		_board_state = p_board_state
	
	func is_leaf() -> bool: # full board<-> leaf node
		var is_full: bool = true
		for r in GlobalGame.COLOMUNS:
			for c in GlobalGame.COLOMUNS:
				var slot =_board_state[r][c]
				if slot.is_empty():
					is_full = false 
					break
		return is_full
	
	func get_h_value() -> int:
		var p1_num = 0
		var p2_num = 0
		for r in GlobalGame.COLOMUNS:
			for c in GlobalGame.COLOMUNS:
				var slot = _board_state[r][c]
				if  slot.check_owner(P1):
					p1_num += 1
				elif slot.check_owner(P2):
					p2_num += 1
		var h_value: int = p1_num + p2_num
		return h_value
	
	func get_all_next_nodes(player_id):
		var child_nodes = []
		var empty_board_pos_arr = []
		for r in GlobalGame.COLOMUNS:
			for c in GlobalGame.COLOMUNS:
				var slot = _board_state[r][c]
				if slot.is_empty():
					empty_board_pos_arr.append([r,c])
		for i in empty_board_pos_arr.size():
			var checking_board  = _board_state.duplicate(true)
			var r = empty_board_pos_arr[i][0]
			var c = empty_board_pos_arr[i][1]
			var chosen_slot = checking_board[r][c]
			chosen_slot.set_owner(player_id)
			_try_catch_others(checking_board, player_id, r, c)
			var child_node = BoardNode.new(checking_board)
	
	func _try_catch_others(checking_board, player_id, row, col):
		var left = GlobalGame.LEFT
		var right =  GlobalGame.RIGHT
		var top = GlobalGame.TOP
		var bottom = GlobalGame.BOTTOM
		
		var check_pairs_stats = [[right, left], [bottom, top], [left, right], [top, bottom]]
		var directions = [[0, -1], [-1, 0], [0, 1], [1, 0]]
		
		var cur_slot = checking_board[row][col] # This is slot		
		# Try catch others
		var dir_num = directions.size()
		for i in range(dir_num):
			# Get adjacent one
			var cur_dir = directions[i]
			var adj_row = row + cur_dir[0]
			var adj_col = col + cur_dir[1]
			
			# Check if it a valid adjacent position		
			if _is_pos_in_range(adj_row, adj_col):
				var adj_slot = checking_board[adj_row][adj_col]
				if !adj_slot.is_empty() and !adj_slot.check_owner(player_id):
					var adj_stat = check_pairs_stats[i][0]
					var cur_stat = check_pairs_stats[i][1]
					var can_catch = adj_slot.get_stat[adj_stat] < cur_slot.get_stat[cur_stat]
					if can_catch:
						# update new data
						adj_slot.update_owner(player_id)
	func _is_pos_in_range(row, col):
		var valid_row = 0 <= row and row < GlobalGame.ROWS
		var valid_col = 0 <= col and col < GlobalGame.COLUMNS
		return valid_row and valid_col
			
			
func find_sol(board_node: BoardNode, maximize_player:bool, player_id, depth: int, alpha: int, beta: int):
	if board_node.is_leaf() or depth == MAX_DEPTH:
		return board_node.get_h_value()
	if maximize_player:
		var value = -INF
		var child_nodes = board_node.get_all_next_nodes(player_id)
		for i in child_nodes.size():
			var child_node = child_nodes[i]
			value = max(value, find_sol (child_node, false, _get_opp_id(player_id), depth - 1, alpha, beta))
			if value >= beta:
				break
			alpha = max(alpha, value)
		return value
	else:
		var value = INF
		var child_nodes = board_node.get_all_next_nodes(player_id)
		for i in child_nodes.size():
			var child_node = child_nodes[i]
			value = min(value, find_sol (child_node, true,_get_opp_id(player_id), depth - 1, alpha, beta))
			if value <= alpha:
				break
			beta = min(beta, value)
		return value
		
func _get_opp_id(player_id):
	return 1 if player_id == 2 else 1
