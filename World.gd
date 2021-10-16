extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var nav2d: Navigation2D = $Navigation2D
onready var line2d: Line2D = $Line2D
onready var player: KinematicBody2D = $YSort/Player
onready var camera2d: Camera2D = $Camera2D
onready var baseMap: TileMap = $GrassTileMap
onready var btn_attack: BaseButton = $CanvasLayer/Attack

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Background.queue_free()
	
	var map_rect = baseMap.get_used_rect()
	var cell_size = baseMap.cell_size
#
#	camera2d.limit_left = map_rect.position.x * cell_size.x
#	camera2d.limit_right = map_rect.end.x * cell_size.x
#
#	camera2d.limit_top = map_rect.position.y * cell_size.y
#	camera2d.limit_bottom = map_rect.end.y * cell_size.y
	
	var window_size = OS.get_window_size()
	var world_width = map_rect.end.x * cell_size.x
	var world_height = map_rect.end.y * cell_size.y
	var display_width = ProjectSettings.get("display/window/size/width")
	
	camera2d.get_viewport().set_size_override(true, Vector2(display_width, display_width * (window_size.y / window_size.x)))
	camera2d.get_viewport().size_override_stretch = true
	
	#camera2d.min_zoom = world_width / window_width
	camera2d.max_zoom = world_width / display_width

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if not (event is InputEventMouseButton or event is InputEventScreenTouch):
		return
		
	if event.button_index != BUTTON_LEFT or event.pressed:
		return
		
	if player == null or camera2d.dragging:
		return
		
	var new_path := nav2d.get_simple_path(player.global_position, get_local_mouse_position())
	line2d.points = new_path
	player.path = new_path

func _on_Player_end_path():
	line2d.clear_points()

func _on_Attack_button_up():
	btn_attack.release_focus()
	btn_attack.material.set("shader_param/active", false)


func _on_Attack_button_down():
	Input.action_press("attack")
	btn_attack.material.set("shader_param/active", true)
