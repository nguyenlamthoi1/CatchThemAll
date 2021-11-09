extends Node

const P1 = "0"
const P2 = "1"

const COLOR_P1 = Color("#434aff")
const COLOR_P2 = Color("#cd2e26")

const BG_IMG = {
	"LEVEL_0": preload("res://assets/gui/green_background.png"),
	"LEVEL_1": preload("res://assets/gui/blue_background.png"),
	"LEVEL_2": preload("res://assets/gui/yellow_background-export.png")
}

#var _frames = preload("")
onready var _frame = $Background/Frame
onready var _image = $Background/Sprite
onready var _background = $Background
onready var _left = $Background/Left
onready var _top = $Background/Top
onready var _right = $Background/Right
onready var _bottom = $Background/Bottom
onready var _tween = $Tween

var _card_data = {}

func init_card(card_data, owner):
	_card_data = card_data
	
	# frame
	_frame.modulate = COLOR_P1 if owner == P1 else COLOR_P2
	# image
	_image.texture = _card_data.img
	# background
	_background.texture = BG_IMG[_card_data.type]
	# stats
	var use_random_stats = _card_data.use_random
	_left.text = str(_card_data.random_stats[0]) if use_random_stats else str(_card_data.stats[0])
	_top.text = str(_card_data.random_stats[1]) if use_random_stats else str(_card_data.stats[1])
	_right.text = str(_card_data.random_stats[2]) if use_random_stats else str(_card_data.stats[2])
	_bottom.text = str(_card_data.random_stats[3]) if use_random_stats else str(_card_data.stats[3])

func move_from_to(from_pos, to_pos):
	_tween.interpolate_property(self, "global_position", from_pos, to_pos, 0.8)
