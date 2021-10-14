extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Lower cap for the `_zoom_level`.
export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
export var max_zoom := 2.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2

export var zoom_sensitivity = 10

export var zoom_speed = 0.05

# The camera's target zoom level.
var _zoom_level := 1.0 setget _set_zoom_level
var events = {}
var last_drag_distance = 0
var dragging := false

# We store a reference to the scene's tween node.
onready var tween: Tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	#_zoom_level = zoom.x
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	zoom = lerp(zoom, Vector2.ONE * _zoom_level, zoom_speed * delta)

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		# Inside a given class, we need to either write `self._zoom_level = ...` or explicitly
		# call the setter function to use it.
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)
		
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			dragging = false
			last_drag_distance = 0
			events.erase(event.index)
				
	if event is InputEventScreenDrag:
		events[event.index] = event
		if events.size() == 2:
			dragging = true
			var drag_distance = events[0].position.distance_to(events[1].position)
			if last_drag_distance == 0:
				last_drag_distance = drag_distance

			var level = (last_drag_distance / drag_distance) * zoom.x
			
			zoom = Vector2.ONE * clamp(level, min_zoom, max_zoom)

			last_drag_distance = drag_distance
			
#			if abs(drag_distance - last_drag_distance) > zoom_sensitivity:
#				var new_zoom = (1 + zoom_speed) if drag_distance < last_drag_distance else (1 - zoom_speed)
#				_zoom_level = clamp(zoom.x * new_zoom, min_zoom, max_zoom)
#				#zoom = Vector2.ONE * _zoom_level
#				zoom = zoom.move_toward(Vector2.ONE * _zoom_level, zoom_speed)
#				last_drag_distance = drag_distance

func _set_zoom_level(value: float):
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(_zoom_level, _zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	tween.start()
