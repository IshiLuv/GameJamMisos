extends Node2D

@export var AMPLITUDE = 10.0
@export var FREQUENCY = 4.0

var item: String = "candy_corn"

func _ready() -> void:
	setItem(item)

var time_passed = 0.0
func _process(delta: float) -> void:
	time_passed += delta
	var y_offset = sin(time_passed * FREQUENCY) * AMPLITUDE
	$ItemIcon.position.y -= y_offset * delta

func setItem(item_id: String):
	item = item_id
	$ItemIcon.texture = load("res://Assets/Textures/Items/item_" + item_id + ".png")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_item(item)
		queue_free()
