extends Sprite2D

@export var duration: float = 1.0

@export var color: Color = Color.BLACK

func _ready() -> void:
	modulate = color
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	
	tween.tween_property(
		self,
		"modulate",
		Color(modulate, 0),
		duration
	)
	
	tween.finished.connect(func(): queue_free())
