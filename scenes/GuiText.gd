extends Node

onready var timer = $Timer
onready var log_text = $LogLabel

func start_show(msg):
	timer.start()
	log_text.text = msg
	log_text.visible = true

func _on_Timer_timeout():
	log_text.visible = false
