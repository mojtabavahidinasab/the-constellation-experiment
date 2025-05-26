extends CPUParticles2D


func _ready() -> void:
	emitting = true


func پایان():
	queue_free()
