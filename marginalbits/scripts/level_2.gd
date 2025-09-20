extends Node2D

func _ready():
	var player = $Player
	var spawn = $SpawnPoint
	player.global_position = spawn.global_position
