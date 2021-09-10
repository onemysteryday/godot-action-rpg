extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(int) var w_range = 32

onready var start_position = global_position
onready var target_position = start_position


# Called when the node enters the scene tree for the first time.
func _ready():
	update_target_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	update_target_position()

func update_target_position():
	var target_vector = Vector2(rand_range(-w_range, w_range), rand_range(-w_range, w_range))
	target_position = start_position + target_vector
	
func start_wander_timer():
	$Timer.start(rand_range(1, 3))
	
func get_time_left():
	return $Timer.time_left
