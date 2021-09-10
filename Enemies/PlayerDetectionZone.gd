extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal player_detected
signal player_escaped

var player = null


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func can_see_player() -> bool:
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	player = body
	emit_signal("player_detected")


func _on_PlayerDetectionZone_body_exited(body):
	player = null
	emit_signal("player_escaped")
