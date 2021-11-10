extends Node

onready var grid_container = $Board44/GridContainer

const EMPTY_TYPE = 99
const EFF_TYPE = 100
const P1 = 0
const P2 = 1
var GridSlot = preload("res://scenes/GridSlot.tscn")
var data_board = []
var ui_board = []
var eff_board = []

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
			
	
func on_card_drop(player_id, pos):
	print("on_drop_card_pos: ", str(player_id)," : ", str(pos.x), " , ",str(pos.y))
	
	var slot = ui_board[pos.x][pos.y]
	var card = slot.get_drag_card()
	var eff_num = eff_board[pos.x][pos.y]
	card.update_stats(eff_num)
			
	
