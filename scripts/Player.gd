extends Node

var score = 0
var hand = [null, null, null, null]
var hand_num = 0
var player_name = ""
var player_mode = ""
var id = 0

var max_hand = 4
var card_slots = []

onready var player_info = $PlayerSecondInfo/PlayerInfo


func init_player(p_id, p_name, p_mode):
	id = p_id
	player_name = p_name
	player_mode = p_mode
	hand = [null, null, null, null]
	score = 0
	
	var slot_container = get_node("PlayerFirstInfo/PlayerGUI/HBoxContainer")
	var slots_children = slot_container.get_children()
	for i in range(slots_children.size()):
		var slot = slots_children[i]
		card_slots.append(slot)
		
	#player_info = $PlayerSecondInfo/PlayerInfo
	
	update_name(player_name)
	update_score(score)
	

func draw_card(from_node, card_instance):
	#var empty_slot = _get_first_empty_slot_2()
	#if empty_slot == null:
	#	return
	var found_empty_idx = _get_first_hand_idx()
	if found_empty_idx < 0:
		return
		
	var empty_slot = card_slots[found_empty_idx]
	empty_slot.add_child(card_instance)
	card_instance.idx_in_hand = found_empty_idx
	card_instance.card_owner = self
	
	hand[found_empty_idx] = card_instance
	hand_num += 1.0
	#card_instance.global_position = empty_slot.global_position
	card_instance.move_from_to(from_node.global_position , empty_slot.rect_global_position)

func _get_first_empty_slot():
	var slot_found = null
	for i in range(card_slots.size()):
		var slot = card_slots[i]
		var child_num = slot.get_node("Holder").get_child_count()
		if (child_num <= 0): # found empty slot
			slot_found = slot
			break
	return slot_found
	
func _get_first_empty_slot_2():
	var slot_found = null
	
	if is_full_hand():
		return slot_found
		
	var found_index = -1
	
	found_index = 0
	for i in range(hand.size()):
		var card = hand[i]
		#print("test_card ", i, card == null)
		if card == null:
			#print("FOUND_CARD_", i)
			found_index = i
			break
		
	slot_found = card_slots[found_index] 
	print('found_empty_at_',found_index," size = " ,hand.size())
	return slot_found
	
func _get_first_hand_idx():
	var found_index = -1
	
	if is_full_hand():
		return found_index
		
	found_index = 0
	
	for i in range(hand.size()):
		var card = hand[i]
		if card == null:
			found_index = i
			break
		
	return found_index
	
func is_full_hand():
	return hand_num >= max_hand
			

func update_name(pname):
	var name_label = player_info.get_node("NameBackground/NameLabel")
	name_label.text = pname
	name = pname
	
func update_score(pscore):
	var score_label = player_info.get_node("ScoreCounter/ScoreLabel")
	score_label.text = str(pscore)	
	score = pscore
