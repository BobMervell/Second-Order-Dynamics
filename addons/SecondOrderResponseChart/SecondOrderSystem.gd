extends Node
class_name SecondOrderSystem

## A plugin designed for Godot 4.3 that allows users to work with complex second-order systems.
## It integrates a line chart directly into the inspector to visualize the system's response over time.
## This tool simplifies the analysis and tuning of second-order dynamics, providing a clear graphical representation
##  of the system's behavior, such as oscillations, damping, and natural frequency, all within the editor.



var k:float #Gain, (the output is multiplied by k )
var wo:float #Pulsation (response/oscillation speed)
var xi:float #ksi >= 1 == no oscillation, ksi<1 = overshoot + oscillations
var z:float # z<0 = reversal start , z>0 strong start + overshoot

var old_input_pos:Vector2 = Vector2.ZERO
var output_speed:Vector2 = Vector2.ZERO

var vec2_old_input_pos:Vector2 = Vector2.ZERO
var vec2_output_speed:Vector2 = Vector2.ZERO

var vec3_old_input_pos:Vector3 = Vector3.ZERO
var vec3_output_speed:Vector3 = Vector3.ZERO

## When using SecondOrderSystem; You need to create your a SecondOrderSystem instance the following manner:
## [br][code] @export var body_second_order_config:Dictionary
## [br] @export var body_second_order:SecondOrderSystem[/code]
## [br] This ensure that the plugin can detect correctly each instance.
## [br] You also need to initiateeach instance in ready
## [br][code] body_second_order = SecondOrderSystem.new(body_second_order_config)[/code]
##[br][b]Note:[/b]
## Use vec2_output_variables or vec3_output_variables depending on your vectors type
func _init(weights:Dictionary) -> void:
	if weights.size() < 4:
		weights = {"k":1,"wo":40,"xi":1,"z":0}
	
	k = weights["k"]
	wo = weights["wo"]
	xi = weights["xi"]
	z = weights["z"]


func vec2_output_variables(delta:float,input_pos:Vector2,
		input_speed:Variant,previous_output:Vector2) -> Array:
	if input_speed == null:
		input_speed = (input_pos - vec2_old_input_pos)/delta
		vec2_old_input_pos = input_pos
	
	var output_acc:Variant = ( k * wo**2 * (input_pos + input_speed * z)
				 - 2 * xi * wo * vec2_output_speed
				- wo**2 * previous_output )
	
	vec2_output_speed = vec2_output_speed + output_acc * delta / (1 + 2 * xi * wo * delta)
	previous_output += vec2_output_speed * delta
	return [previous_output,vec2_output_speed] #no longer previous output

func vec3_output_variables(delta:float,input_pos:Vector3,
		input_speed:Variant,previous_output:Vector3) -> Array:
	if input_speed == null:
		input_speed = (input_pos - vec3_old_input_pos)/delta
		vec3_old_input_pos = input_pos
	
	var output_acc:Variant = ( k * wo**2 * (input_pos + input_speed * z)
				 - 2 * xi * wo * vec3_output_speed
				- wo**2 * previous_output )
	
	vec3_output_speed = vec3_output_speed + output_acc * delta / (1 + 2 * xi * wo * delta)
	
	previous_output += vec3_output_speed * delta
	return [previous_output,vec3_output_speed] #no longer previous output
