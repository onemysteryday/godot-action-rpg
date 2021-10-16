extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum {
	IDLE,
	WALK,
}

onready var start_position = global_position
onready var target_position = start_position

onready var animationTree: AnimationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

var w_range = 72
var speed = 30
var state = IDLE
var velocity := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	animationTree.active = true
	update_animation_blend_positions(Vector2.DOWN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
		
func _physics_process(delta):
	if state == WALK:
		_start_walk(delta)
	velocity = move_and_slide(velocity)
			
func _start_walk(delta):
	var direction = global_position.direction_to(target_position)
	update_animation_blend_positions(direction)
	velocity = velocity.move_toward(direction * 12, speed * delta)
	
	if global_position.distance_to(target_position) <= speed * delta:
		state = IDLE
		$IdleTimer.start(rand_range(2, 5))
		animationState.travel("Idle")
		velocity = Vector2.ZERO

func update_animation_blend_positions(input_vector):
	animationTree.set("parameters/Idle/blend_position", input_vector)
	animationTree.set("parameters/Move/blend_position", input_vector)
	
func update_target_position():
	w_range = -w_range
	var target_vector = Vector2(0, w_range)
	target_position = global_position + target_vector

func _on_IdleTimer_timeout():
	state = WALK
	update_target_position()
	animationState.travel("Move")
