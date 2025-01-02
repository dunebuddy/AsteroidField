extends Node3D

signal ship_speed_change(speed)

const E = 2.718281828459045

var drop_scene = preload("res://scenes/drop/drop.tscn")

@onready var fps_label: Label = $UI/FPSLabel
@onready var menu: PanelContainer = $UI/Menu
@onready var menu_animator: AnimationPlayer = $UI/Menu/MenuAnimator
@onready var asteroids_label: Label = $UI/Menu/MenuMargin/MenuVBox/OptionsVBox/AsteroidsPanel/AsteroidsMargin/AsteroidsVBox/AsteroidsLabel
var is_menu_visible = false

var speed_min = 10
var speed_max = 60
var scale_min = 0.05
var scale_max = 0.15
var z_scale_min = 0.5
var z_scale_max = 0.75

var ship_speed_max = 400
var ship_speed = 0
var drops_count = 4000
var drops: Array[Drop] = []

func reseed_drop(drop: Drop):
	if drops.size() <= drops_count:
		var scale_xy = randf_range(scale_min, scale_max)
		var scale_z = randf_range(z_scale_min, z_scale_max)
		
		drop.transform.origin = Vector3(randf_range(-200, 200), randf_range(-100, 100), randf_range(-200, -90))
		drop.set_drop_scale(Vector3(scale_xy, scale_xy, scale_z))
		drop.speed = randf_range(scale_min, speed_max)
	else:
		drops.erase(drop)
		drop.queue_free()


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
	for i in range(drops_count):
		_add_drop()


func _add_drop():
	var drop: Drop = drop_scene.instantiate()
	
	#drop.frustum = frustum_planes
	reseed_drop(drop)

	drops.append(drop)
	add_child(drop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if drops.size() < drops_count:
		for i in range(drops_count - drops.size()):
			_add_drop()
	
	fps_label.text = "%d FPS" % Engine.get_frames_per_second()
	
	var acceleration_value = 0
	if Input.is_key_pressed(KEY_SPACE):
		acceleration_value = (17*(1-(1/(1+pow(E, -0.015*(ship_speed-250))))))
	
	var drag_value = 3 * (1 - pow(E, -0.05 * ship_speed))
	
	var acceleration = acceleration_value - drag_value
	ship_speed = clamp(ship_speed + acceleration, 0, ship_speed_max)
	
	_update_drops(delta)

func _update_drops(delta):
	for drop: Drop in drops:
		if drop.transform.origin.z > 0:
			reseed_drop(drop)
		else:
			drop.transform.origin.z += (drop.speed + ship_speed) * delta
			
			if ship_speed > 0.1:
				drop.scale.z = drop.original_scale.z + ship_speed * 0.03
				drop.material.set_shader_parameter("emission_intensity", clamp(ship_speed + drop.speed, 0, 160))


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


func _on_asteroids_count_slider_value_changed(value):
	drops_count = value
	
	asteroids_label.text = "Asteroides .: " + str(value) + " :."
