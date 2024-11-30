class_name Level

extends Node3D

@export var enemy_scene: PackedScene

@onready var player: Player = $Player
@onready var spawn_points: Node3D = $SpawnPoints
@onready var wave_label: Label = $UserInterface/WaveLabel
@onready var spawn_timer: Timer = $SpawnTimer

# x10 enemies per wave
var wave_count: int = 1
var spawned_enemies: int = 0

func _ready() -> void:
	await get_tree().create_timer(10).timeout
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if spawned_enemies >= wave_count * 10:
		spawned_enemies = 0
		wave_count += 1
		wave_label.text = "Wave: " + str(wave_count)
		return
	
	# Ensure randomness by seeding
	randomize()
	
	# Get the list of children from spawn_points
	var spawn_points_children: Array[Node] = spawn_points.get_children()
	
	# Select a random child
	var random_child: Node = spawn_points_children[randi() % spawn_points_children.size()]
	
	# Spawn on point
	if random_child is Marker3D:
		var spawn_point: Marker3D = random_child
		
		# Create a new instance of the Mob scene.
		var enemy: Enemy = enemy_scene.instantiate()
		
		enemy.target = player
		enemy.position = spawn_point.position
		
		# Spawn the mob by adding it to the Main scene.
		add_child(enemy)
		spawned_enemies += 1
