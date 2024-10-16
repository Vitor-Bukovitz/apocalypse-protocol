class_name Gun

extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func shoot() -> void:
	if not animation_player.is_playing():
		animation_player.play("shoot")
