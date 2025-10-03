extends Button

var item: String

func _ready() -> void:
	$Panel.visible = false
	$Panel/VBoxContainer/Name.text = "item_" + item + "_name"
	$Panel/VBoxContainer/Description.text = "item_" + item + "_desc"
	$Sprite2D.texture = load("res://Assets/Textures/Items/item_" + item + ".png")
	
func _on_mouse_entered() -> void:
	$Panel.visible = true

func _on_mouse_exited() -> void:
	$Panel.visible = false
