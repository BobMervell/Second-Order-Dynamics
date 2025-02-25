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

var vec3_old_input:Vector3 = Vector3.ZERO
var vec3_output_dot:Vector3  = Vector3.ZERO


var vec2_old_input:Vector2 = Vector2.ZERO
var vec2_output_dot:Vector2  = Vector2.ZERO

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
		push_warning("Second order system weights incorrect, default: ",
				str({"k":1,"wo":40,"xi":1,"z":0}),"  will be used instead" )
	
	k = weights["k"]
	wo = weights["wo"]
	xi = weights["xi"]
	z = weights["z"]

## This function computes the second-order response of a system for vector2,
##[br] returns a dictionnary containing the output and it's derivatives.
func vec2_second_order_response(delta:float,input:Vector2,
		previous_output:Vector2,input_dot:Variant=null) -> Dictionary:
	
	# Estimate input_dot
	if input_dot == null:
		input_dot = (input - vec2_old_input)/delta
		vec2_old_input = input
	
	# process second order
	var output_dotdot:Vector2 = ( k * wo**2 * (input + input_dot * z)
				 - 2 * xi * wo * vec2_output_dot
				- wo**2 * previous_output )
	vec2_output_dot = vec2_output_dot + output_dotdot * delta / (1 + 2 * xi * wo * delta)
	previous_output += vec2_output_dot * delta

	return {"output":previous_output,"output_dot":vec2_output_dot,"output_dotdot":output_dotdot}

## This function computes the second-order response of a system for vector2,
##[br] returns a dictionnary containing the output and it's derivatives.
func vec3_second_order_response(delta:float,input:Vector3,
		previous_output:Vector3,input_dot:Variant=null) -> Dictionary:
	
	# Estimate input_dot
	if input_dot == null:
		input_dot = (input - vec3_old_input)/delta
		vec3_old_input = input
	
	# process second order
	var output_dotdot:Vector3 = ( k * wo**2 * (input + input_dot * z)
				 - 2 * xi * wo * vec2_output_dot
				- wo**2 * previous_output )
	vec3_output_dot = vec3_output_dot + output_dotdot * delta / (1 + 2 * xi * wo * delta)
	previous_output += vec3_output_dot * delta
	return {"output":previous_output,"output_dot":vec3_output_dot,"output_dotdot":output_dotdot}
	
## DEPRECATED
func update_weights(weights:Dictionary) -> void:
	if weights.size() < 4:
		weights = {"k":1,"wo":40,"xi":1,"z":0}
		push_warning("Second order system weights incorrect, default: ",
				str({"k":1,"wo":40,"xi":1,"z":0}),"  will be used instead" )
	
	k = weights["k"]
	wo = weights["wo"]
	xi = weights["xi"]
	z = weights["z"]
