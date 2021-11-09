extends Node

const EMPTY_TYPE = 99
const EFF_TYPE = 100

const EMPTY_IMG = preload("res://assets/gui/empty_area.png")
const EFF_IMG = preload("res://assets/gui/effect_area.png")

var holder
var num_label

var effect_num = 0
var type = EMPTY_TYPE
var pos = Vector2(0, 0)

func init_grid(ef_num, p_type, p_pos):
	type = p_type
	effect_num = ef_num
	pos = p_pos
	
	var holder = $Holder
	var num_label = $Holder/CenterContainer/Label
	
	if type == EMPTY_TYPE:
		holder.texture = EMPTY_IMG
		num_label.visible = false
	elif type == EFF_TYPE:
		holder.texture = EFF_IMG
		num_label.visible = true
		num_label.text = "+" + str(effect_num) if effect_num > 0 else str(effect_num)
		
		
	
