# GameState.gd
extends Node

var player_alive: bool = true
var max_lives = 5
var lives = max_lives
var hud 

func lose_life():
	lives -= 1
	if hud:
		hud.load_hearts()
	
	# Check if game over
	if lives <= 0:
		# Handle game over logic here
		print("Game Over!")
		# You can add scene change or other game over logic here
