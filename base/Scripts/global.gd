extends Node

var main: Node2D
var main_menu: Node2D

#settings:
var resolution: int = 0
var based_screen: Vector2i =  DisplayServer.screen_get_size()
var skipIntro: bool = false 
