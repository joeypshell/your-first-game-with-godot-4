extends Node2D

const TREE_SCENE = preload ("res://pine_tree.tscn")

const CHUNK_SIZE = 1000
const LOAD_RADIUS = 2
const TREES_PER_CHUNK = 8

var generated_chunks = {}
var rng = RandomNumberGenerator.new()

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	


func _on_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true
	
func world_to_chunk(world_position: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_position.x / CHUNK_SIZE),
		floori(world_position.y / CHUNK_SIZE)
	)

func chunk_seed(chunk: Vector2i) -> int:
	return hash(str(chunk.x) + "," + str(chunk.y))
	
func generate_tree_chunk(chunk: Vector2i) -> void:
	generated_chunks[chunk] = true
	
	rng.seed = chunk_seed(chunk)
	
	var chunk_origin = Vector2(chunk.x * CHUNK_SIZE, chunk.y * CHUNK_SIZE)
	
	for i in TREES_PER_CHUNK:
		var tree = TREE_SCENE.instantiate()
		
		var random_position = Vector2(
			rng.randf_range(0, CHUNK_SIZE),
			rng.randf_range(0, CHUNK_SIZE)
		)
		
		tree.global_position = chunk_origin + random_position
		$Trees.add_child(tree)

func update_tree_chunks() -> void:
	var player_chunk = world_to_chunk($Player.global_position)
	for x in range(player_chunk.x - LOAD_RADIUS, player_chunk.x + LOAD_RADIUS + 1):
		for y in range(player_chunk.y - LOAD_RADIUS, player_chunk.y + LOAD_RADIUS + 1):
			var chunk = Vector2i(x, y)
			if not generated_chunks.has(chunk):
				generate_tree_chunk(chunk)
				
