extends Node

onready var grid_container = $Board44/GridContainer

const EMPTY_TYPE = 99
const EFF_TYPE = 100
const P1_TYPE = 0
const P2_TYPE = 1

var GridSlot = preload("res://scenes/GridSlot.tscn")
var data_board = []
var ui_board = []
var eff_board = []
var gm = null

var player_score = {
	"0" : 0,
	"1" : 0,
}


const P1 = "0"
const P2 = "1"

var rng = RandomNumberGenerator.new()
func init_board():
	for i in GlobalGame.ROWS:
		data_board.append([])
		ui_board.append([])
		eff_board.append([])
		
		for j in GlobalGame.COLUMNS:
			
			# create slot ui
			var new_grid = GridSlot.instance()
			grid_container.add_child(new_grid)
			new_grid.init_grid(0, EMPTY_TYPE, Vector2(i, j))
			new_grid.board = self
			
			
			data_board[i].append(EMPTY_TYPE)			
			ui_board[i].append(new_grid)
			eff_board[i].append(0)
	
	for i in GlobalGame.NUM_EFF_AREA:
		rng.randomize()
		
		var rand_col = rng.randi_range(0, GlobalGame.ROWS - 1)
		var rand_row = rng.randi_range(0, GlobalGame.ROWS - 1)
		var slot = ui_board[rand_row][rand_col]
		
		if slot.type == EMPTY_TYPE:
			rng.randomize()
			var eff_val = rng.randi_range(0, 1)
			eff_val = -1 if eff_val == 0 else 1
			slot.init_grid(eff_val, EFF_TYPE, slot.pos)
			eff_board[rand_row][rand_col] = eff_val
			
	
func on_card_drop(player_id, cur_card, pos):
	var row = pos.x
	var col = pos.y
	var cur_player = gm.get_player(player_id)
	
	print("[Board] ", str(player_id), "On card dropped at ,", " : ", str(row), " , ",str(col))
	
	# Get grid slot at pos
	var cur_slot = ui_board[row][col] # This is slot
	#var cur_card = cur_slot.get_hold_card() # This is card we drop on slot
	
	# Update new stats
	var eff_num = eff_board[pos.x][pos.y] 
	cur_card.update_stats(eff_num)
	
	# Assign new card owner
	cur_slot.grid_owner = cur_player
	
	# Update data insdie
	#player_score[player_id] += 1 # player's new score
	data_board[pos.x][pos.y] = P1_TYPE if player_id == P1 else P2_TYPE
	
	# find and catch adjacent cards
	_try_catch_ones(player_id, cur_card, row, col)
	
			
func _try_catch_ones(player_id, cur_card, row, col):
	var cur_player = gm.get_player(player_id)
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
		# Check if it a valid adjacent position
		print("check adject: ", str(adj_row), ",", str(adj_col))
		if _is_pos_in_range(adj_row, adj_col):
			var adj_slot = ui_board[adj_row][adj_col]
			var adj_card = adj_slot.get_hold_card()
			if adj_card != null and cur_card != null: 
				var adj_stat = check_pairs_stats[i][0]
				var cur_stat = check_pairs_stats[i][1]
				print("[Board] Have one! Try catch it: adj = ", str(adj_card.stats[adj_stat]), " vs cur = ", str(cur_card.stats[cur_stat]))
				# Compare 2 cards
				var can_catch = adj_card.stats[adj_stat] < cur_card.stats[cur_stat]
				if can_catch:
					# update new data
					adj_card.update_owner(cur_player)
					data_board[adj_row][adj_col] = P1_TYPE if player_id == P1 else P2_TYPE
					print("[Board] Catch Success! ")
				else:
					print("[Board] Catch Failed!")
			else:
				print("[Board] Can't find left one")
	
			

func _is_pos_in_range(row, col):
	var valid_row = 0 <= row and row < GlobalGame.ROWS
	var valid_col = 0 <= col and col < GlobalGame.COLUMNS
	return valid_row and valid_col
	
