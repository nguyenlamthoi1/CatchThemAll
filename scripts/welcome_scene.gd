extends Node


func _on_PvpButton_pressed():
	GlobalGame.set_game_mode(GlobalGame.GAME_MODE.PVP)
	get_tree().change_scene_to(GlobalGame.GameScene)


func _on_EasyButton_pressed():
	GlobalGame.set_game_mode(GlobalGame.GAME_MODE.AI_RANDOM)
	get_tree().change_scene_to(GlobalGame.GameScene)


func _on_HardButton_pressed():
	pass # Replace with function body.
