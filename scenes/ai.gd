extends Reference

class_name MinimaxAI

const EMPTY = 0
const P1 = 1
const P2 = 2

const MAX_DEPTH = 3

class BoardNode:
	var _board_state
	
	func _init(p_board_state):
		_board_state = board_state
		pass
		
	
	func is_leaf() -> bool: # full board<-> leaf node
		var is_full: bool = true
		for r in GlobalGame.COLOMUNS:
			for c in GlobalGame.COLOMUNS:
				if _board_state[r][c] == EMPTY:
					is_full = false 
					break
		return is_full
	
	func get_h_value() -> int:
		var p1_num = 0
		var p2_num = 0
		for r in GlobalGame.COLOMUNS:
			for c in GlobalGame.COLOMUNS:
				if _board_state[r][c] == P1:
					p1_num += 1
				elif _board_state[r][c] == P2:
					p2_num += 1
		var h_value: int = p1_num + p2_num
		return h_value
	
	func get_all_next_nodes(player_id):
		
		var empty_board_pos_arr = []
		for r in GlobalGame.COLOMUNS:
			for c in GlobalGame.COLOMUNS:
				if _board_state[r][c] == EMPTY:
					empty_board_pos_arr.append([r,c])
		for i in empty_board_pos_arr.size():
			var temp_board_state  = _board_state.duplicate()
			var r = empty_board_pos_arr[i][0]
			var c = empty_board_pos_arr[i][1]
			temp_board_state[r][c] = player_id
	
	func _try_catch_others():
		var cur_player = gm.get_player(player_id)
		#var opp_player = gm.get_opponent(player_id)
		var opp_id = gm.get_opponent_id(player_id)
		var cur_pos = Vector2(row, col)
		var directions = [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0)]
	
		var left = GlobalGame.LEFT
		var right =  GlobalGame.RIGHT
		var top = GlobalGame.TOP
		var bottom = GlobalGame.BOTTOM
		
		var check_pairs_stats = [[right, left], [bottom, top], [left, right], [top, bottom]]
	
		var cur_slot = ui_board[row][row] # This is slot		
		#var cur_card = cur_slot.get_hold_card() # This is card we drop on slot
		# Try catch others
		var dir_num = directions.size()
		for i in range(dir_num):
			# Get adjacent one
			var cur_dir = directions[i]
			var adj_pos = cur_pos + cur_dir
			var adj_row = adj_pos.x
			var adj_col = adj_pos.y
			#print("check adject: ", str(adj_row), ",", str(adj_col))
		
			# Check if it a valid adjacent position		
			if _is_pos_in_range(adj_row, adj_col):
				var adj_slot = ui_board[adj_row][adj_col]
				var adj_card = adj_slot.get_hold_card()
				if adj_card != null and cur_card != null: 
					if adj_card.card_owner.id != player_id: # Adjcent card is opponent's
						var adj_stat = check_pairs_stats[i][0]
						var cur_stat = check_pairs_stats[i][1]
					
						#print("[Board] Have one! Try catch it: adj = ", str(adj_card.stats[adj_stat]), " vs cur = ", str(cur_card.stats[cur_stat]))
						
						# Compare 2 cards
						var can_catch = adj_card.stats[adj_stat] < cur_card.stats[cur_stat]
						if can_catch:
							# update new data
							adj_card.update_owner(cur_player)
							data_board[adj_row][adj_col] = P1_TYPE if player_id == P1 else P2_TYPE
							# update score
							player_scores[player_id] += 1 # Player's new score
							player_scores[opp_id] -= 1 #  # Opponent 's new score

							#print("[Board] Catch Success! ")
						else:
							pass
							#print("[Board] Catch Failed!")
					else:
						pass
						#print("[Board] Can't find left one")			
			

var _board_state

func init_ai(board):
	_board_state = board
	
func _mini_max(board_node: BoardNode, maximize_player:bool, depth: int, alpha: int, beta: int):
	if board_node.is_leaf() or depth == MAX_DEPTH:
		return board_node.get_h_value()
	if maximize_player:
		
	pass
#	if node is a leaf
#        return the utility value of node
#     if node is a minimizing node
#        for each child of node
#            beta = min (beta, evaluate (child, alpha, beta))
#            if beta <= alpha
#                return beta
#            return beta
#     if node is a maximizing node
#        for each child of node
#            alpha = max (alpha, evaluate (child, alpha, beta))
#            if beta <= alpha
#                return alpha
#            return alpha
