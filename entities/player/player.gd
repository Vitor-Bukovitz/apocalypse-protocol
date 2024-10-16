class_name Player

extends CharacterBody3D

# Speed Constants
const WALKING_SPEED: float = 5.0
const SPRINT_SPEED: float = 8.0
const CROUCH_SPEED: float = 3.0

# Movement Constants
const JUMP_VELOCITY: float = 4.5

const LERP_SPEED: float = 15.0
const AIR_LERP_SPEED: float = 3.0
const CROUCH_DEPTH: float = -0.5

const MOUSE_SENSITIVITY: float = 0.1

# Head Bobbing Constants
const HEAD_BOBBING_SPEED: Dictionary = {
	PlayerState.SPRINTING: 22.0,
	PlayerState.WALKING: 14.0,
	PlayerState.CROUCHING: 10.0
}
const HEAD_BOBBING_INTENSITY: Dictionary = {
	PlayerState.SPRINTING: 0.2,
	PlayerState.WALKING: 0.1,
	PlayerState.CROUCHING: 0.05
}

# Head Bobbing Variables
var head_bobbing_vector: Vector3 = Vector3.ZERO
var head_bobbing_index: float = 0.0
var head_bobbing_current_intensity: float = 0.0

# Input Variables
var current_speed: float = 5.0
var direction: Vector3 = Vector3.ZERO
var player_state: PlayerState = PlayerState.WALKING

var was_on_floor_last_frame: bool = false
var snapped_to_stairs_last_frame: bool = false

# On Ready Variables
@onready var head: Node3D = $Head
@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision
@onready var head_ray_cast_3d: RayCast3D = $HeadRayCast3D
@onready var gun_ray_cast_3d: RayCast3D = $Head/Camera3D/GunRayCast3D
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var gun: Gun = $Head/Gun

enum PlayerState {
	WALKING, SPRINTING, CROUCHING
}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	_handle_collisions(delta)
	_handle_shoot()
	_handle_jump()
	_head_bobbing(delta)
	_movement(delta)
	_snap_to_stairs()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _handle_collisions(delta: float) -> void:
	# Define the speed depending on what button is pressed
	if Input.is_action_pressed("crouch"):
		player_state = PlayerState.CROUCHING
		current_speed = CROUCH_SPEED
		standing_collision.disabled = true
		crouching_collision.disabled = false
		head.position.y = lerp(head.position.y, 0.75 + CROUCH_DEPTH, delta * LERP_SPEED)
	elif not head_ray_cast_3d.is_colliding():
		standing_collision.disabled = false
		crouching_collision.disabled = true
		head.position.y = lerp(head.position.y, 0.75, delta * LERP_SPEED)
		if Input.is_action_pressed("sprint"):
			player_state = PlayerState.SPRINTING
			current_speed = SPRINT_SPEED
		else:
			player_state = PlayerState.WALKING
			current_speed = WALKING_SPEED

func _handle_shoot() -> void:
	if Input.is_action_just_pressed("shoot"):
		gun.shoot()
		if gun_ray_cast_3d.is_colliding():
			var target: Node3D = gun_ray_cast_3d.get_collider()
			if target is Enemy:
				target.hit()

#region Movement Functions
func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * LERP_SPEED)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * AIR_LERP_SPEED)
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()

func _head_bobbing(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	head_bobbing_current_intensity = HEAD_BOBBING_INTENSITY[player_state]
	head_bobbing_index += HEAD_BOBBING_SPEED[player_state] * delta
	if is_on_floor() and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		camera_3d.position.y = lerp(camera_3d.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2.0), delta * LERP_SPEED)
		camera_3d.position.x = lerp(camera_3d.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, delta * LERP_SPEED)
	else:
		camera_3d.position.y = lerp(camera_3d.position.y, 0.0, delta * LERP_SPEED)
		camera_3d.position.x = lerp(camera_3d.position.x, 0.0, delta * LERP_SPEED)

func _snap_to_stairs() -> void:
	var did_snap: bool = false
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame):
		var body_test_result: PhysicsTestMotionResult3D = PhysicsTestMotionResult3D.new()
		var params: PhysicsTestMotionParameters3D = PhysicsTestMotionParameters3D.new()
		var max_step_down: float = -0.5
		params.from = global_transform
		params.motion = Vector3(0, max_step_down, 0)
		if PhysicsServer3D.body_test_motion(get_rid(), params, body_test_result):
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			did_snap = true
	
	snapped_to_stairs_last_frame = did_snap
	was_on_floor_last_frame = is_on_floor()
#endregion
