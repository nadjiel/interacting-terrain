extends Node2D

@onready var terrain_detector: TerrainDetector = $TerrainDetector

func _ready() -> void:
	terrain_detector.terrain_entered.connect(
		func(terrain): print("entered " + str(terrain))
	)
	terrain_detector.terrain_exited.connect(
		func(terrain): print("exited " + str(terrain))
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		terrain_detector.global_position = event.global_position
	
	if event.is_action_pressed("esc"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
