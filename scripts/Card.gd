extends Node2D

const P1 = "0"
const P2 = "1"

const COLOR_P1 = Color("#434aff")
const COLOR_P2 = Color("#cd2e26")

const BG_IMG = {
	"0": preload("res://assets/gui/green_background.png"),
	"1": preload("res://assets/gui/blue_background.png"),
	"2": preload("res://assets/gui/yellow_background-export.png")
}

var gm = null

var holdable = false
var holding = false
var on_slot = false

var can_drop = false
var touch_pos = Vector2()
var last_pos = Vector2()
var drop_slot = null
var pos = Vector2()


var delta_x
var delta_y
var new_delta_x
var new_delta_y

var idx_in_hand = -1
var card_owner = null

#var _frames = preload("")
var _frame
var _image
var _background
var _left
var _top
var _right
var _bottom
var _tween

var stats = [0, 0, 0, 0]
var eff_num = 0
var _card_data = {}

func init_card(card_data, owner):
	_frame = $Background/Frame
	_image = $Background/Sprite
	_background = $Background
	_left = $Background/Left
	_top = $Background/Top	
	_right = $Background/Right
	_bottom = $Background/Bottom
	_tween = $Tween
	
	_card_data = card_data
	
	# frame
	_frame.modulate = COLOR_P1 if owner == P1 else COLOR_P2
	# image
	_image.texture = _card_data.img
	# background
	_background.texture = BG_IMG[str(_card_data.type)]
	# stats
	var use_random_stats = _card_data.use_random
	stats[0] =_card_data.random_stats[0] if use_random_stats else _card_data.stats[0]
	stats[1] =_card_data.random_stats[1] if use_random_stats else _card_data.stats[1]
	stats[2] =_card_data.random_stats[2] if use_random_stats else _card_data.stats[2]
	stats[3] =_card_data.random_stats[3] if use_random_stats else _card_data.stats[3]
	
	_left.text = str(stats[0])
	_top.text = str(stats[1])
	_right.text = str(stats[2])
	_bottom.text = str(stats[3])
	
	
func move_from_to(from_pos, to_pos):
	holdable = false
	_tween.interpolate_property(self, "global_position", from_pos, to_pos, 0.8)
	_tween.start()


func _on_Tween_tween_completed(object, key):
	holdable = true


func _on_Area2D_input_event(viewport, event, shape_idx):
	if true:
		holding = true
		if event is InputEventMouseButton :
			
		#if event is InputEventScreenTouch and event.is_pressed():
			print("touch_on_screen")
			
			#touch_pos = event.set_position()
			#delta_x = touch_pos.x - position.x
			#delta_y = touch_pos.y - position.y
		#if event is InputEventScreenDrag:
			#touch_pos = event.set_position()
			#new_delta_x = touch_pos.x - delta_x
			#new_delta_y = touch_pos.y - delta_y
			#position = Vector2(new_delta_x, new_delta_y)
		
			


func _on_TouchScreenButton_pressed():
	holding = true
	last_pos = Vector2(0.0, 0.0)
	
	
func _on_TouchScreenButton_released():
	holding = false
	if !can_drop:
		position = last_pos
	elif !on_slot:
		# set up ui for card
		var new_parent = drop_slot
		get_parent().remove_child(self)
		new_parent.add_child(self)
		self.position = Vector2(0,0)
		unset_can_drop()
		holding = false
		on_slot = true
		# update hand
		card_owner.hand[idx_in_hand] = null
		card_owner.hand_num -= 1
		if card_owner.hand_num < 0: card_owner.hand_num = 0
		# notify for game_master
		gm._on_card_drop(card_owner.id, pos)
	
func _input(event):
	if holding and !on_slot:
		if event is InputEventScreenTouch and event.is_pressed():
			#last_pos = event.get_position()
			touch_pos = event.get_position()
			delta_x = touch_pos.x - position.x
			delta_y = touch_pos.y - position.y
		elif event is InputEventScreenDrag:
			touch_pos = event.get_position()
			new_delta_x = touch_pos.x - delta_x
			new_delta_y = touch_pos.y - delta_y
			position = Vector2(new_delta_x, new_delta_y)
			
func set_can_drop(slot, p_pos):
	drop_slot = slot
	pos = p_pos
	can_drop = true
	
func unset_can_drop():
	drop_slot = null
	#pos = null
	can_drop = false
	#holding = false
		

func update_stats(p_eff_num):
	eff_num = p_eff_num
	stats[0] += eff_num
	stats[1] += eff_num
	stats[2] += eff_num
	stats[3] += eff_num
	_left.text = str(stats[0])
	_top.text = str(stats[1])
	_right.text = str(stats[2])
	_bottom.text = str(stats[3])
	
