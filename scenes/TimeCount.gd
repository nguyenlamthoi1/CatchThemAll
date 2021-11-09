extends Node

onready var timer = $Timer

func start_show

func _on_Timer_timeout():
	TimeCount.visible = false
