extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GrassEffect: PackedScene = preload("res://Effects/GrassEffect.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_HurtBox_area_entered(area):
	execute_destory_effect()
	queue_free()
	
func execute_destory_effect():
	var effect = GrassEffect.instance()
	effect.global_position = global_position
	owner.add_child(effect)
