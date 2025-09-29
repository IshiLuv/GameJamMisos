extends Node

var main: Node2D

var spawned_enemies: int = 0

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
var lang: int

var resolution: int = 0
var based_screen: Vector2i =  DisplayServer.screen_get_size()
var watchedIntro: bool = false 
var watchedCutscene: bool = false
var frame_music: int=3
var frame_svx: int=3
func _ready() -> void:
	TranslationServer.set_locale("ru")

func spawn_bullet(sender, bullet_scn, pos, dir, dmg = 1, is_burning: bool = false):
	var bullet = bullet_scn.instantiate()
	bullet.global_position = pos
	bullet.direction = dir
	bullet.sender = sender
	bullet.damage = dmg
	bullet.is_burning = is_burning
	G.main.add_child(bullet)
