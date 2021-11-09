extends Node

var score = 0
var hand = []
var player_name = ""
var player_mode = ""
var id = 0

var max_hand = 4
var card_slots = []


func init_player(p_id, p_name, p_mode):
	id = p_id
	player_name = p_name
	player_mode = p_mode
	hand = []
	score = 0
	
	var slot_container = get_node("PlayerFirstInfo/PlayerGUI/HBoxContainer")
	var slots_children = slot_container.get_children()
	for i in range(slots_children.size()):
		var slot = slots_children[i]
		card_slots.append(slot)

func draw_card(from_node, card_instance):
	var empty_slot = _get_first_empty_slot()
	if empty_slot == null:
		return
		
	empty_slot.add_child(card_instance)
	hand.append(card_instance)
	#card_instance.global_position = empty_slot.global_position
	card_instance.move_from_to(from_node.rect_global_position , empty_slot.global_position)

func _get_first_empty_slot():
	var slot_found = null
	for i in range(card_slots.size()):
		var slot = card_slots[i]
		var child_num = slot.get_node("Holder").get_child_count()
		if (child_num <= 0): # found empty slot
			slot_found = slot
			break
	return slot_found
	
func is_full_hand():
	return hand.size() >= max_hand
			
