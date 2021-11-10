extends HBoxContainer

onready var score_label = $ScoreCounter/ScoreLabel
onready var name_label = $NameBackground/NameLabel

var _name = ""
var _score = 0

func update_name(name):
	name_label.text = name
	name = _name
	
func update_score(score):
	score_label.text = str(score)	
	_score = score

