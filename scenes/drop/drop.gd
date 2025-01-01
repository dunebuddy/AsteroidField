class_name Drop
extends MeshInstance3D

signal reseed(drop: MeshInstance3D)

var shader = preload("res://scenes/drop/shader.gdshader")
var drop_mesh = preload("res://scenes/drop/drop.obj")

var material: ShaderMaterial = ShaderMaterial.new()

var frustum: Array[Plane] = []
var valid: bool = false

var drop_speed = 0
var ship_speed = 0
var original_scale = Vector3.ZERO

func set_drop_speed(speed):
	drop_speed = speed
	_set_emission_intensity()


func set_ship_speed(speed):
	ship_speed = speed
	_set_emission_intensity()


func set_drop_scale(scale: Vector3):
	original_scale = scale
	
	self.scale = scale


func _set_emission_intensity():
	#print_debug(ship_speed + drop_speed)
	material.set_shader_parameter("emission_intensity", clamp(ship_speed + drop_speed, 0, 160))
	

func invalidate():
	valid = false


func validate():
	valid = true


func _is_in_frustum() -> bool:
	var object_position = global_position

	# Verificar se o objeto está dentro dos planos
	for plane in frustum:
		if plane.distance_to(object_position) > 0:
			return false  # O objeto está fora do frustum
	return true  # O objeto está dentro do frustum


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("ship_speed_change", _on_ship_speed_change)

	material.shader = shader  # Atribui o shader ao material
	material.set_shader_parameter("max_color", Color.CORNFLOWER_BLUE)
	
	# Defina a malha para o MeshInstance3D e aplique o material
	mesh = drop_mesh  # Atribui a malha carregada ao MeshInstance3D
	self.material_override = material  # Atribui o material ao MeshInstance3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.scale.z = original_scale.z + (ship_speed * 0.03)
	self.transform.origin.z += (drop_speed + ship_speed) * delta
	
	if !_is_in_frustum() or !valid:
		reseed.emit(self)


func _on_ship_speed_change(speed):
	set_ship_speed(speed)
