extends Node3D

@export var body_second_order_config:Dictionary
@export var body_second_order := SecondOrderSystem.new(body_second_order_config)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	pass
