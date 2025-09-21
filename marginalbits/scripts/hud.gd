extends CanvasLayer

@export var heart_texture: Texture2D
@export var max_health := 4

@onready var hearts := $HeartsContainer

func _ready() -> void:
	update_hearts(max_health)

func clear_hearts() -> void:
	for child in hearts.get_children():
		child.queue_free()

func update_hearts(current_health: int) -> void:
	print("Updating hearts: ", current_health)
	#clear_hearts()
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.modulate = Color(1, 1, 1, 1) if i < current_health else Color(0.2, 0.2, 0.2, 0.5)
		hearts.add_child(heart)
