extends Area2D

var travelled_distance = 0

func _physics_process(delta: float) -> void:
	const SPEED = 15.0
	const RANGE = 17
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()
	


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
