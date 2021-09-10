extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var max_hearts = 4 setget set_max_hearts
var hearts = 4 setget set_hearts


var heart_vector = Vector2(0, 11)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_max_hearts(PlayerStats.max_health)
	set_hearts(PlayerStats.health)
#	$HeartEmpty.rect_size.x = max_hearts * 15
#	$HeartFull.rect_size.x = hearts * 15
	PlayerStats.connect("health_changed", self, "set_hearts")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HeartFull.rect_size = $HeartFull.rect_size.move_toward(heart_vector, 70 * delta)
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	$HeartEmpty.rect_size.x = max_hearts * 15
	
func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	heart_vector.x = hearts * 15
#	$HeartFull.rect_size.x = hearts * 15
