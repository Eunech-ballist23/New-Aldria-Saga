extends Node

# Preload your coin sound file here
var coin_sfx = preload("res://assets/musicSoundsAndEffects_mandatory/sounds/coin_sound.wav")

func play_coin_sound():
	# Create a new audio player in memory
	var asp = AudioStreamPlayer.new()
	asp.stream = coin_sfx
	
	# Give it a random pitch so it sounds more "natural"
	asp.pitch_scale = randf_range(0.9, 1.2)
	
	# Add it to the AudioManager (the Global node)
	add_child(asp)
	asp.play()
	
	# Very Important: Delete the player node once the sound stops
	asp.finished.connect(asp.queue_free)
