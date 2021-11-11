extends Node

onready var top_title = $Popup/Title/TitleText

func show_result(p1_is_winner):
	top_title.text = "You win" if p1_is_winner else "You lose"

func show_pause():
	top_title.text = "Pause"
		
func _on_ContinueButton_pressed():
	pass # Replace with function body.

func _on_ReplayButton_pressed():
	get_tree().change_scene_to(GlobalGame.GameScene)

func _on_HomeButton_pressed():
	get_tree().change_scene_to(GlobalGame.WelcomeScene)
