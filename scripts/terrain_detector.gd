
class_name TerrainDetector
extends Area2D

signal terrain_entered(terrain_type: TerrainType)
signal terrain_exited(terrain_type: TerrainType)

enum TerrainType {
	NONE,
	GRASS,
	TALL_GRASS,
	WATER,
	DEEP_WATER,
	SAND
}

var current_terrain: TerrainType = TerrainType.NONE

var overlapping_tiles := DictSet.new()

var overlapping_terrains := DictSet.new():
	set = set_overlapping_terrains

func set_overlapping_terrains(new_terrains: DictSet) -> void:
	var old_terrains: DictSet = overlapping_terrains
	
	overlapping_terrains = new_terrains
	
	print(old_terrains.get_as_array())
	print(new_terrains.get_as_array())
	
	if old_terrains != null:
		var exited_terrains: DictSet = old_terrains.difference(new_terrains)
		
		for terrain: TerrainType in exited_terrains.get_as_array():
			terrain_exited.emit(terrain)
	
	if new_terrains != null:
		var entered_terrains: DictSet = new_terrains.difference(old_terrains)
		
		for terrain: TerrainType in entered_terrains.get_as_array():
			terrain_entered.emit(terrain)

func get_tile_data(tile_rid: RID, tile_map: TileMapLayer) -> TileData:
	var tile_coords: Vector2i = tile_map.get_coords_for_body_rid(tile_rid)
	var tile_data: TileData = tile_map.get_cell_tile_data(tile_coords)
	
	return tile_data

func get_tile_terrain(tile_rid: RID, tile_map: TileMapLayer) -> TerrainType:
	var tile_data: TileData = get_tile_data(tile_rid, tile_map)
	
	if tile_data == null:
		return TerrainType.NONE
	
	return tile_data.get_custom_data("Terrain")

func is_on_terrain(terrain_id: TerrainType) -> bool:
	for tile: Dictionary in overlapping_tiles.get_as_array():
		if get_tile_terrain(tile.tile_rid, tile.tile_map) == terrain_id:
			return true
	
	return false

func on_tile_map_entered(tile_rid: RID, tile_map: TileMapLayer) -> void:
	overlapping_tiles.set_element({
		"tile_map": tile_map,
		"tile_rid": tile_rid
	})
	
	var new_overlapping_terrains: DictSet = overlapping_terrains.copy()
	new_overlapping_terrains.set_element(get_tile_terrain(tile_rid, tile_map))
	
	overlapping_terrains = new_overlapping_terrains

func on_tile_map_exited(tile_rid: RID, tile_map: TileMapLayer) -> void:
	overlapping_tiles.remove_element({
		"tile_map": tile_map,
		"tile_rid": tile_rid
	})
	
	var tile_terrain: TerrainType = get_tile_terrain(tile_rid, tile_map)
	
	if not is_on_terrain(tile_terrain):
		var new_overlapping_terrains: DictSet = overlapping_terrains.copy()
		new_overlapping_terrains.remove_element(tile_terrain)
		
		overlapping_terrains = new_overlapping_terrains

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		on_tile_map_entered(body_rid, body as TileMapLayer)

func _on_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		on_tile_map_exited(body_rid, body as TileMapLayer)
