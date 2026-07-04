extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func play_idle_animation() -> void:
	_play_animation(&"idle")


func play_walk_animation() -> void:
	_play_animation(&"walk")


func _play_animation(animation_name: StringName) -> void:
	if animated_sprite.animation != animation_name:
		animated_sprite.play(animation_name)
	elif not animated_sprite.is_playing():
		animated_sprite.play()
