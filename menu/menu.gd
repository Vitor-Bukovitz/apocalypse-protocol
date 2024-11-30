class_name Menu

extends Node

const INDUSTRIAL_LEVEL: PackedScene = preload("res://scenes/industrial_level/industrial_level.tscn")

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(INDUSTRIAL_LEVEL)
