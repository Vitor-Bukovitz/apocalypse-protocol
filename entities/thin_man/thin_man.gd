class_name ThinMan

extends "res://entities/abstract_enemy/enemy.gd"

@onready var animation_player: AnimationPlayer = $ThinMan/AnimationPlayer

func _ready() -> void:
	super._ready()
	animation_player.play("mixamo_com")
