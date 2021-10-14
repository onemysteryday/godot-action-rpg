extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


const EnemyDeathEffect: PackedScene = preload("res://Effects/EnemyDeathEffect.tscn")
const HitEffect: PackedScene = preload("res://Effects/HitEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

export var speed = 250

var knockback_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var state = IDLE


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("fly")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, speed * delta)
	knockback_velocity = move_and_slide(knockback_velocity)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, speed * delta)
			
			if $WanderController.get_time_left() == 0:
				reset_wander_state()
		WANDER:
			if $WanderController.get_time_left() == 0:
				reset_wander_state()
			
			update_velocity($WanderController.target_position, delta)
			
			if global_position.distance_to($WanderController.target_position) <= speed * delta:
				reset_wander_state()
			
		CHASE:
			var player = $PlayerDetectionZone.player
			if player != null:
				#global_position = lerp(global_position, player.global_position, delta)
				update_velocity(player.global_position, delta)
		
	velocity += $SoftCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func _on_HurtBox_area_entered(area):
	$Stats.health -= area.damage
	var effect = HitEffect.instance()
	owner.add_child(effect)
	effect.global_position = global_position
	knockback_velocity = area.knockback_vector * 120


func _on_Stats_no_health():
	var effect = EnemyDeathEffect.instance()
	effect.global_position = global_position
	owner.add_child(effect)
	queue_free()


func _on_PlayerDetectionZone_player_detected():
	state = CHASE

func _on_PlayerDetectionZone_player_escaped():
	state = WANDER
	
func update_velocity(position, delta):
	var direction = global_position.direction_to(position) * 50
	velocity = velocity.move_toward(direction, speed * delta)
	$AnimatedSprite.flip_h = direction.x < 0
	
func reset_wander_state():
	state = get_random_state()
	$WanderController.start_wander_timer()
	
func get_random_state():
	return randi() % 2
