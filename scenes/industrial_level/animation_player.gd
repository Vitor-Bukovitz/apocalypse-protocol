extends AnimationPlayer

@onready var player: Player = %Player
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	play("cutscene")
	player.hide_ui()
	audio_stream_player.play()
	await get_tree().create_timer(10).timeout
	player.show_ui()
