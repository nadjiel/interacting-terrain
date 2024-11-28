extends Node2D

const FOOTPRINT = preload("res://scenes/footprint.tscn")
const WATER_RIPPLE = preload("res://scenes/water_ripple.tscn")
const FLYING_LEAFS = preload("res://scenes/flying_leafs.tscn")

@onready var terrain_detector: TerrainDetector = $".."

var footprint_id: int = 0

var footprint_timer: float = 0.0

var footprint_interval: float = 0.25

var water_ripple: Node

var flying_leafs: Node

func _ready() -> void:
	terrain_detector.terrain_entered.connect(_on_terrain_entered)
	terrain_detector.terrain_exited.connect(_on_terrain_exited)
	pass

func _process(delta: float) -> void:
	footprint_timer += delta
	
	if terrain_detector.is_on_terrain(TerrainDetector.TerrainType.SAND):
		if footprint_timer >= footprint_interval:
			sand_effect()
			footprint_timer = 0.0

func sand_effect() -> void:
	var footprint: Sprite2D = FOOTPRINT.instantiate()
	
	footprint.z_index = 1
	
	footprint.global_position = self.global_position
	
	if footprint_id % 2 != 0:
		footprint.scale.x = -1
	
	get_tree().current_scene.add_child(footprint)
	
	footprint_id += 1

func apply_water_effect() -> void:
	water_ripple = WATER_RIPPLE.instantiate()
	
	add_child(water_ripple)

func remove_water_effect() -> void:
	remove_child(water_ripple)

func apply_leafs_effect() -> void:
	flying_leafs = FLYING_LEAFS.instantiate()
	
	add_child(flying_leafs)

func remove_leafs_effect() -> void:
	remove_child(flying_leafs)

func _on_terrain_entered(terrain: TerrainDetector.TerrainType) -> void:
	match terrain:
		TerrainDetector.TerrainType.WATER: apply_water_effect()
		TerrainDetector.TerrainType.GRASS: apply_leafs_effect()

func _on_terrain_exited(terrain: TerrainDetector.TerrainType) -> void:
	match terrain:
		TerrainDetector.TerrainType.WATER: remove_water_effect()
		TerrainDetector.TerrainType.GRASS: remove_leafs_effect()
