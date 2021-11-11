extends Control

onready var top_title = $Popup/Title/TitleText

var _gm

func init_popup(game_master):
	_gm = game_master

func show_result(p1_score, p2_score):
	visible = true
	if p1_score == p2_score:
		top_title.text("Drawn")
	else:
		top_title.text = "You win" if p1_score > p2_score else "You lose"

func show_pause():
	visible = true
	top_title.text = "Pause"
		
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
