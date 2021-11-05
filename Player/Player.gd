extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal end_path

enum {
	MOVE,
	ROLL,
	ATTACK,
	FOLLOW
}

const HitEffect: PackedScene = preload("res://Effects/HitEffect.tscn")

export var speed = 80
export var steer_force = 0.1
export var look_ahead = 16
export var num_rays = 8

var ray_directions = []
var interest = []
var danger = []

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var state = MOVE
var path := PoolVector2Array() setget set_path
var next_point = null

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerStats.connect("no_health", self, "queue_free")
	animationTree.active = true
	update_animation_blend_positions(Vector2.DOWN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	track_input()

func _physics_process(delta):
	match state:
		MOVE:
			velocity = move_and_slide(velocity)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
		FOLLOW:
			move_next_point(next_point, delta)
	
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
	#display_hurt_effect()
	$HurtTimer.start()
	$BlinkAnimationPlayer.play("start")


func _on_HurtTimer_timeout():
	#display_hurt_effect()
	$HurtTimer.start()


func _on_HurtBox_area_exited(area):
	$HurtTimer.stop()
	$BlinkAnimationPlayer.play("stop")
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE
	velocity = Vector2.ZERO
	
func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	if next_point != null:
		emit_signal("end_path")
	
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
	
func move_next_point(point: Vector2, delta: float):
	var start_point := position
	var distance := start_point.distance_to(point)
	
	if point != null and distance >= 1:
		var direction = start_point.direction_to(point)
		set_interest(direction)
		set_danger()

		var move_vector = choose_direction()
		#var move_vector = start_point.direction_to(point)
		roll_vector = move_vector
		update_animation_blend_positions(move_vector)
		animationState.travel("Move")
		velocity = move_vector * speed
		#velocity = move_and_slide(velocity)
		move_and_collide(velocity * delta)
		
#		if direction.distance_to(move_vector) >= 0.5 and path.size() > 0:
#			next_point = path[0]
#			path.remove(0)
#			print("skip")
	elif path.size() > 0:
		position = next_point
		next_point = path[0]
		path.remove(0)
	else:
		position = next_point
		state = MOVE
		animationState.travel("Idle")
		velocity = Vector2.ZERO
		next_point = null
		ray_directions.clear()
		interest.clear()
		danger.clear()
		emit_signal("end_path")
		
func set_interest(point: Vector2):
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(point)
		interest[i] = max(0, d)
	#print(interest)
	#print(ray_directions)
	
func set_danger():
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var result = space_state.intersect_ray(position, position + ray_directions[i].rotated(rotation) * look_ahead, [self])
		danger[i] = 1.0 if result else 0.0
	
func choose_direction() -> Vector2: 
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	
	var chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	
	#print(chosen_dir.normalized())
	return chosen_dir.normalized()
	
func move_along_path(distance: float):
	var start_point := global_position
	for i in range(path.size()):
		var distance_to_next := start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			var move_vector = start_point.direction_to(path[0])
			update_animation_blend_positions(move_vector)
			animationState.travel("Move")
			velocity = move_vector * speed
			velocity = move_and_slide(velocity)
			break
		if distance <= 0.0:
			position = path[0]
			state = MOVE
			animationState.travel("Idle")
			velocity = Vector2.ZERO
			break
		
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		
	
func set_path(value: PoolVector2Array):
	path = value
	if value.size() == 0:
		return
		
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	
	var temp_interest = []
	temp_interest.resize(num_rays)
	var temp_dir = Vector2.ZERO
	
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		temp_interest[i] = max(0, ray_directions[i].rotated(rotation).dot(Vector2(0, -1)));
		
		if i == 5 or i == 6 or i == 7:
			temp_interest[i] = 0
		
		temp_dir += ray_directions[i] * temp_interest[i]
	
	print(ray_directions)
	print(temp_interest)
	print(temp_dir.normalized())
	
	#print(ray_directions)
	#print((Vector2(0, 1) * 1))
	state = FOLLOW
	next_point = path[0]
	path.remove(0)
	
