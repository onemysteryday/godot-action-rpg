extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal no_health
signal health_changed

export(int) var max_health = 1
onready var health = max_health setget set_health


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
