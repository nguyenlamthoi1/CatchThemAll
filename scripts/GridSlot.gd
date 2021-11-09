extends Node

const EMPTY_TYPE = 99
const EFF_TYPE = 100

const EMPTY_IMG = preload("res://assets/gui/empty_area.png")
const EFF_IMG = preload("res://assets/gui/effect_area.png")

var holder
var num_label

var effect_num = 0
var type = EMPTY_TYPE

func init_grid(ef_num, p_type):
	type = p_type
	effect_num = ef_num
	
	var holder = $Holder
	var num_label = $Holder/CenterContainer/Label
	
	if type == EMPTY_TYPE:
		holder.texture = EMPTY_IMG
		num_label.visible = false
	elif type == EFF_TYPE:
		holder.texture = EMPTY_IMG
		num_label.visible = true
		
	
