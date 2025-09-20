extends ParallaxBackground

class_name Background

@export var can_process: bool
@export var layer_speed: Array[int]

func _ready() -> void:
	if !can_process:
			set_physics_process(false)
#
#func _physics_process(delta: float) -> void:
		#for index in get_child_count():
			#var crr_child = get_child(index)
			#if crr_child is ParallaxLayer:
				#crr_child.motion_offset.x -= (delta * 5) * layer_speed[index]
