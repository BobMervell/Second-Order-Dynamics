extends CharacterBody3D

const SPEED:float = 10.0

@export var second_order_activated:bool = true

@export_group("Motion second order") #not mandatory
@export var move_second_order_config:Dictionary
@export var move_second_order:SecondOrderSystem

var input_velocity:Vector3 = Vector3.ZERO
var output_velocity:Vector3 = Vector3.ZERO

func _ready() -> void:
	move_second_order = SecondOrderSystem.new(move_second_order_config)

func _physics_process(delta: float) -> void:

	# basic movement script
	var input_dir:Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction:Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		input_velocity.x = direction.x * SPEED
		input_velocity.z = direction.z * SPEED
	else:
		input_velocity.x = move_toward(velocity.x, 0, SPEED)
		input_velocity.z = move_toward(velocity.z, 0, SPEED)
	
	output_velocity = move_second_order.get_second_order_response(delta,input_velocity,output_velocity)[0]

	if second_order_activated: 
		velocity = output_velocity
	else:
		velocity = input_velocity
	
	move_and_slide()
