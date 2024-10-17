extends Node3D

@export var enemy_scene: PackedScene

@onready var player: Player= $Player

func _on_monster_spawner_timeout() -> void:
	# Create a new instance of the Mob scene.
	var enemy: Enemy = enemy_scene.instantiate()
	
	enemy.position.y = 2.1
	enemy.target = player
	# Spawn the mob by adding it to the Main scene.
	add_child(enemy)
