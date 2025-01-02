class_name Drop
extends MeshInstance3D

#signal reseed(drop: MeshInstance3D)

var shader = preload("res://scenes/drop/shader.gdshader")
var drop_mesh = preload("res://scenes/drop/drop.obj")

var material: ShaderMaterial = ShaderMaterial.new()

var frustum: Array[Plane] = []
var valid: bool = false

var speed = 0
var ship_speed = 0
var original_scale = Vector3.ZERO


func set_drop_scale(new_scale: Vector3):
	original_scale = new_scale
	scale = new_scale


func invalidate():
	valid = false


func validate():
	valid = true


func _ready():
	material.shader = shader  # Atribui o shader ao material
	material.set_shader_parameter("max_color", Color.CORNFLOWER_BLUE)
	
	# Defina a malha para o MeshInstance3D e aplique o material
	mesh = drop_mesh  # Atribui a malha carregada ao MeshInstance3D
	self.material_override = material  # Atribui o material ao MeshInstance3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
