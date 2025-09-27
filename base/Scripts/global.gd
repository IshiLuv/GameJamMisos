extends Node

var main: Node2D
var main_menu: Node2D

#settings:
var resolution: int = 0
var based_screen: Vector2i =  DisplayServer.screen_get_size()
var skipIntro: bool = false 

func _ready() -> void:
	TranslationServer.set_locale("en")

func spawn_bullet(sender, bullet_scn, pos, dir):
	var bullet = bullet_scn.instantiate()
	bullet.global_position = pos
	bullet.direction = dir
	bullet.sender = sender
	G.main.add_child(bullet)
