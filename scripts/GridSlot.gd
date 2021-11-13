extends Control

const EMPTY_TYPE = 99
const EFF_TYPE = 100

const EMPTY_IMG = preload("res://assets/gui/empty_area.png")
const EFF_IMG = preload("res://assets/gui/effect_area.png")

var num_label

var effect_num = 0
var type = EMPTY_TYPE
var pos = Vector2(0, 0)

var grid_owner = null

var _drag_card = null

onready var selected_area = $SelectedArea
onready var holder = $Holder
onready var marker = $Marker

var board = null

func init_grid(ef_num, p_type, p_pos):
	type = p_type
	effect_num = ef_num
	pos = p_pos
	
	#var holder = $Holder
	var num_label = $Holder/CenterContainer/Label
	
	if type == EMPTY_TYPE:
		holder.texture = EMPTY_IMG
		num_label.visible = false
	elif type == EFF_TYPE:
		holder.texture = EFF_IMG
		num_label.visible = true
		num_label.text = "+" + str(effect_num) if effect_num > 0 else str(effect_num)
		
		
	

func _input(event):
		if event is InputEventScreenTouch and event.is_pressed():
			pass
		elif event is InputEventScreenDrag:
			var my_rect_pos = holder.get_global_rect()
			var contain_point = my_rect_pos.has_point(event.get_position())
			if _drag_card != null:
				if contain_point :
					selected_area.visible = true
					_drag_card.set_can_drop(self, pos)
				else:
					selected_area.visible = false
					_drag_card.unset_can_drop()
			else:
				selected_area.visible = false
				#_drag_card.unset_can_drop()


func _on_Area2D_area_entered(area):
		#print("body_in: ", str(pos.x), "-",str(pos.y))
		if area.is_in_group("Card"):
			_drag_card = area


func _on_Area2D_area_exited(area):
	#print("leave at", str(pos.x), "-",str(pos.y))
	if _drag_card != null:
		_drag_card.unset_can_drop()	
	_drag_card = null
	selected_area.visible = false

func get_drag_card():
	return _drag_card
	
func get_hold_card():
	if _drag_card == null: # try find child of holder node
		for i in range(get_child_count()):
			var child = get_child(i)
			if child.name == "Card":
				_drag_card = child
	return _drag_card
		
