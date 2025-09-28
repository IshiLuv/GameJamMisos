extends Node

var main: Node2D

var item_pool: Array = [
	"candy_corn",
	"shovel",
	"nest",
	"candles",
	"match",
	"bird_protein",
	"clock",
	"pogo",
	"wings",
	"witch_hat",
	"chef_hat",
]

#settings:
var resolution: int = 0
var based_screen: Vector2i =  DisplayServer.screen_get_size()
var watchedIntro: bool = false 

func _ready() -> void:
	TranslationServer.set_locale("en")

func spawn_bullet(sender, bullet_scn, pos, dir, dmg = 1, is_burning: bool = false):
	var bullet = bullet_scn.instantiate()
	bullet.global_position = pos
	bullet.direction = dir
	bullet.sender = sender
	bullet.damage = dmg
	bullet.is_burning = is_burning
	G.main.add_child(bullet)
