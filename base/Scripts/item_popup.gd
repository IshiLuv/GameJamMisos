extends Button

var item: String

func _ready() -> void:
	$Name.text = "item_" + item + "_name"
	$Sprite2D.texture = load("res://Assets/Textures/Items/item_" + item + ".png")
