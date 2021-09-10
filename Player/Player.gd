extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum {
	MOVE,
	ROLL,
	ATTACK
}

const HitEffect: PackedScene = preload("res://Effects/HitEffect.tscn")

export var speed = 80

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var state = MOVE

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	PlayerStats.connect("no_health", self, "queue_free")
	animationTree.active = true
	update_animation_blend_positions(Vector2.DOWN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	track_input()

func _physics_process(_delta):
	match state:
		MOVE:
			velocity = move_and_slide(velocity)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	
#func _input(event):
#	input_vector.y = event.get_action_strength("ui_down") - event.get_action_strength("ui_up")
#	input_vector.x = event.get_action_strength("ui_right") - event.get_action_strength("ui_left")
#	input_vector = input_vector.normalized()
#
#	if input_vector != Vector2.ZERO:
#		animationTree.set("parameters/Idle/blend_position", input_vector)
#		animationTree.set("parameters/Move/blend_position", input_vector)
#		animationTree.set("parameters/Attack/blend_position", input_vector)
#		animationState.travel("Move")
#		velocity = input_vector * speed
#	else:
#		animationState.travel("Idle")
#		velocity = Vector2.ZERO
#
#	if Input.is_action_just_pressed("attack"):
#		state = ATTACK
#		velocity = Vector2.ZERO

func _on_HurtBox_area_entered(area):
	display_hurt_effect()
	$HurtTimer.start()


func _on_HurtTimer_timeout():
	display_hurt_effect()
	$HurtTimer.start()


func _on_HurtBox_area_exited(area):
	$HurtTimer.stop()
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE
	velocity = Vector2.ZERO
	
func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state():
	velocity = roll_vector * speed * 1.5
	animationState.travel("Roll")
	velocity = move_and_slide(velocity)
	
func track_input():
	var input_vector = Vector2.ZERO
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		update_animation_blend_positions(input_vector)
		animationState.travel("Move")
		velocity = input_vector * speed
	else:
		animationState.travel("Idle")
		velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		

func update_animation_blend_positions(input_vector):
	$PivotSword/SwordHitBox.knockback_vector = roll_vector
	animationTree.set("parameters/Idle/blend_position", input_vector)
	animationTree.set("parameters/Move/blend_position", input_vector)
	animationTree.set("parameters/Attack/blend_position", input_vector)
	animationTree.set("parameters/Roll/blend_position", input_vector)
	
func display_hurt_effect():
	PlayerStats.health -= 1
	var effect = HitEffect.instance()
	owner.add_child(effect)
	effect.global_position = global_position
