
class_name TerrainDetector
extends Area2D

## The [signal terrain_entered] signal is emitted when this [TerrainDetector]
## detects a collision with a tile that has a terrain anottated in its data.
signal terrain_entered(terrain_type: TerrainType)

## The [signal terrain_exited] signal is emitted when this [TerrainDetector]
## detects that it is no longer colliding with any tiles of a given terrain.
signal terrain_exited(terrain_type: TerrainType)

## The [enum TerrainType] enum lists the possible
## types of terrains that can be found. [br]
## Each one of them is represented by an [code]integer[/code] power of
## [code]2[/code], so that bit calculations can be made to detect whether a
## tile has more than one terrains.
enum TerrainType {
	NONE = 0,
	GRASS = 1,
	TALL_GRASS = 2,
	WATER = 4,
	DEEP_WATER = 8,
	SAND = 16
}

## The [member overlapping_tiles] property stores a [DictSet] with information
## about all the tiles with which this [TerrainDetector] is currently colliding.
var overlapping_tiles := DictSet.new()

## The [member overlapping_terrains] property stores a [DictSet]
## with information about the terrains that are currently detected
## by this [TerrainDetector].
var overlapping_terrains := DictSet.new():
	set = set_overlapping_terrains

func set_overlapping_terrains(new_terrains: DictSet) -> void:
	var old_terrains: DictSet = overlapping_terrains
	
	overlapping_terrains = new_terrains
	
	if old_terrains != null:
		var exited_terrains: DictSet = old_terrains.difference(new_terrains)
		
		for terrain: TerrainType in exited_terrains.get_as_array():
			terrain_exited.emit(terrain)
	
	if new_terrains != null:
		var entered_terrains: DictSet = new_terrains.difference(old_terrains)
		
		for terrain: TerrainType in entered_terrains.get_as_array():
			terrain_entered.emit(terrain)

## The [method get_tile_data] method takes a [code]RID[/code] and
## a [code]TileMapLayer[/code], and retrieves the [TileData]
## of the tile with such [code]RID[/code].
## This is useful for accessing and manipulating individual tile data
## based on their unique [code]RID[/code].
func get_tile_data(tile_rid: RID, tile_map: TileMapLayer) -> TileData:
	var tile_coords: Vector2i = tile_map.get_coords_for_body_rid(tile_rid)
	var tile_data: TileData = tile_map.get_cell_tile_data(tile_coords)
	
	return tile_data

## The [method get_tile_terrains] method takes a [code]RID[/code] and
## a [code]TileMapLayer[/code], and returns an [Array] of the [TerrainType]s
## that the tile identified by that [code]RID[/code] has. [br]
## If the tile has no terrain data, it returns an empty [Array].
func get_tile_terrains(tile_rid: RID, tile_map: TileMapLayer) -> Array[TerrainType]:
	var tile_data: TileData = get_tile_data(tile_rid, tile_map)
	
	if tile_data == null:
		return []
	
	var terrains_id: int = tile_data.get_custom_data("Terrain")
	
	var terrains: Array[TerrainType] = Util.untype_array(Util.decompose_in_powers_of_2(terrains_id))
	
	return terrains

## The [method is_on_tile_with_terrain] method takes a [code]TerrainType[/code]
## and checks if any of the overlapping tiles have such terrain type. [br]
## A [code]bool[/code] is returned depending if this [TerrainDetector]
## is on the specified terrain or not.
func is_on_tile_with_terrain(terrain_id: TerrainType) -> bool:
	for tile: Dictionary in overlapping_tiles.get_as_array():
		if terrain_id in get_tile_terrains(tile.tile_rid, tile.tile_map):
			return true
	
	return false

## The [method is_on_terrain] method takes a [code]TerrainType[/code]
## and checks if the [member overlapping_terrains] property has such terrain.
## [br]
## A [code]bool[/code] is returned depending if the terrain was found or not.
func is_on_terrain(terrain_id: TerrainType) -> bool:
	for terrain: TerrainType in overlapping_terrains.get_as_array():
		if terrain == terrain_id:
			return true
	
	return false

## The [method on_tile_entered] method takes a [code]RID[/code] and
## a [code]TileMapLayer[/code] representing a tile
## and sets them to the [member overlapping_tiles] property.
## [br]
## This method also updates the [member overlapping_terrains] to reflect
## the new terrains being overlapped with the entrace of the new tile.
func on_tile_entered(tile_rid: RID, tile_map: TileMapLayer) -> void:
	overlapping_tiles.set_element({
		"tile_map": tile_map,
		"tile_rid": tile_rid
	})
	
	# Copying and setting a new object so that its setter is triggered.
	var new_overlapping_terrains: DictSet = overlapping_terrains.copy()
	new_overlapping_terrains.set_elements(get_tile_terrains(tile_rid, tile_map))
	
	overlapping_terrains = new_overlapping_terrains

## The [method on_tile_exited] method takes a [code]RID[/code] and
## a [code]TileMapLayer[/code] representing a tile
## and removes them from the [member overlapping_tiles] property.
## [br]
## This method also updates the [member overlapping_terrains] to reflect
## the new terrains being overlapped with the exit of the new tile.
func on_tile_exited(tile_rid: RID, tile_map: TileMapLayer) -> void:
	overlapping_tiles.remove_element({
		"tile_map": tile_map,
		"tile_rid": tile_rid
	})
	
	var tile_terrains: Array[TerrainType] = get_tile_terrains(tile_rid, tile_map)
	
	var new_overlapping_terrains: DictSet = overlapping_terrains.copy()
	
	for terrain: TerrainType in tile_terrains:
		# Only removes terrain if it isn't in another colliding tile.
		if not is_on_tile_with_terrain(terrain):
			# Copying and setting a new object so that its setter is triggered.
			new_overlapping_terrains.remove_element(terrain)
		
	overlapping_terrains = new_overlapping_terrains

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		on_tile_entered(body_rid, body as TileMapLayer)

func _on_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMapLayer:
		on_tile_exited(body_rid, body as TileMapLayer)
