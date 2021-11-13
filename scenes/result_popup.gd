extends Control

onready var top_title = $Popup/Title/TitleText
onready var player_info = $Popup/VBoxContainer/PlayerInfo2

const P1 = "0"
const P2 = "1"

var _gm

func init_popup(game_master):
	_gm = game_master

func show_result(p1_score, p2_score):
	visible = true
	if p1_score == p2_score:
		top_title.text= "Draw"
	else:
		top_title.text = "You win" if p1_score > p2_score else "You lose"
	player_info.update_score(_gm.get_score(P1))

func show_pause():
	visible = true
	top_title.text = "Pause"
	player_info.update_score(_gm.get_score(P1))
	
		
func _on_ContinueButton_pressed():
	visible = false	
	_gm.continue_game()

func _on_ReplayButton_pressed():
	get_tree().change_scene_to(GlobalGame.GameScene)

func _on_HomeButton_pressed():
	get_tree().change_scene_to(GlobalGame.WelcomeScene)


func _on_CloseButton_pressed():
	print("hide ui")
	visible = false
	_gm.continue_game()
	
