extends Node3D

signal ship_speed_change(speed)

const E = 2.718281828459045

var drop_scene = preload("res://scenes/drop/drop.tscn")

@onready var fps_label: Label = $UI/FPSLabel
@onready var menu: PanelContainer = $UI/Menu
@onready var menu_animator: AnimationPlayer = $UI/Menu/MenuAnimator

@onready var frustum_planes: Array[Plane] = $Camera3D.get_frustum()

var is_menu_visible = false

var speed_min = 10
var speed_max = 60
var scale_min = 0.05
var scale_max = 0.15
var z_scale_min = 0.05
var z_scale_max = 0.75

var ship_speed_max = 400
var ship_speed = 0
var acceleration = Vector3(0, 0, 0)
var drops = []

func reseed_drop(drop):
	var scale_xy = randf_range(scale_min, scale_max)
	var scale_z = randf_range(z_scale_min, z_scale_max)
	
	drop.transform.origin = Vector3(randf_range(-200, 200), randf_range(-100, 100), randf_range(-200, -90))
	drop.set_drop_scale(Vector3(scale_xy, scale_xy, scale_z))
	drop.set_drop_speed(randf_range(scale_min, speed_max))
	drop.validate()


func toggle_menu():
	if menu_animator.is_playing():
		return

	if is_menu_visible:
		menu_animator.play("slide_out")
	else:
		menu_animator.play("slide_in")

	is_menu_visible = !is_menu_visible


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(4000):
		var drop: Drop = drop_scene.instantiate()
		
		drop.frustum = frustum_planes
		drop.connect("reseed", _on_drop_reseed)
		drop.invalidate()

		drops.append(drop)
		add_child(drop)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	
	var acceleration_value = 0
	if Input.is_key_pressed(KEY_SPACE):
		acceleration_value = (17*(1-(1/(1+pow(E, -0.015*(ship_speed-250))))))
	
	var drag_value = 3 * (1 - pow(E, -0.05 * ship_speed))
	
	var acceleration = acceleration_value - drag_value
	ship_speed = clamp(ship_speed + acceleration, 0, ship_speed_max)
	
	#print_debug("acceleration_value=", acceleration_value)
	#print_debug("drag_value=", drag_value)
	_emit_acceleration_change()


func _input(event):
	if event is InputEventKey:
		match event.keycode:
			KEY_ENTER:
				if event.is_pressed() and event.alt_pressed:
					var current_mode = DisplayServer.window_get_mode()
					if current_mode == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
						DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
					else:
						DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			
			KEY_ESCAPE:
				if event.is_pressed():
					if event.alt_pressed:
						get_tree().quit()
					else:
						toggle_menu()


func _emit_acceleration_change():
	ship_speed_change.emit(ship_speed)
	#print_debug("ship_speed=",ship_speed)


func _on_drop_reseed(drop):
	reseed_drop(drop)


func _on_show_fps_button_toggled(toggled_on):
	fps_label.visible = toggled_on


func _on_min_z_scale_slider_value_changed(value):
	z_scale_min = value


func _on_max_z_scale_slider_value_changed(value):
	z_scale_max = value


func _on_min_scale_slider_value_changed(value):
	scale_min = value


func _on_max_scale_slider_value_changed(value):
	scale_max = value


func _on_min_speed_slider_value_changed(value):
	speed_min = value


func _on_max_speed_slider_value_changed(value):
	speed_max = value
