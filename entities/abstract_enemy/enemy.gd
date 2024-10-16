class_name Enemy

extends CharacterBody3D

@export var health: float = 100.0
@export var speed: float = 3.0
@export var target: Node3D

@onready var label: Label = $SubViewport/Label
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	_update_label()

func _process(delta: float) -> void:
	navigation_agent_3d.target_position = target.global_transform.origin
	var next_position: Vector3 = navigation_agent_3d.get_next_path_position()
	velocity = (next_position - transform.origin).normalized() * speed
	
	# Calculate the look_at position
	var look_direction: Vector3 = next_position - global_position
	look_direction.y = 0  # Ignore vertical difference
	
	if look_direction.length_squared() > 0.001:  # Check if the direction vector is significant
		var look_target: Vector3 = global_position + look_direction.normalized()
		var current_rotation: Quaternion = global_transform.basis.get_rotation_quaternion()
		var target_rotation: Quaternion = Quaternion(global_transform.looking_at(look_target, Vector3.UP).basis)
		var smoothed_rotation: Quaternion = current_rotation.slerp(target_rotation, 3 * delta)
		global_transform.basis = Basis(smoothed_rotation)
	
	
	move_and_slide()

func hit() -> void:
	health -= 10
	_update_label()
	if health <= 0:
		queue_free()

func _update_label() -> void:
	label.text = str(health)
