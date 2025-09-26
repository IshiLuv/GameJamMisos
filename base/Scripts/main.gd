extends Node2D
class_name Main

@onready var player = $Character

func _ready() -> void:
	G.main = self
	Animations.appear(self)
