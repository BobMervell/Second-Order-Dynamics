extends Node
class_name SecondOrderSystem

## A plugin designed for Godot 4.3 that allows users to work with complex second-order systems.
## It integrates a line chart directly into the inspector to visualize the system's response over time.
## This tool simplifies the analysis and tuning of second-order dynamics, providing a clear graphical representation
##  of the system's behavior, such as oscillations, damping, and natural frequency, all within the editor.


## Gain, (the output is multiplied by k )
var k:float 
## Pulsation (response/oscillation speed)
var wo:float 
## ksi >= 1 == no oscillation, ksi<1 = overshoot + oscillations
var xi:float 
## z<0 = reversal start , z>0 strong start + overshoot
var z:float 
## Delta represents the err threshold (any error stronger (input-previous_output)
## will lead to a reset off the slow start)
var delta_err:float 
## Slow the start of the response during T seconds (linear increase between 0 and 100% during T_offset)
var T_offset:float 

## (Discrete) If y¨​ is at one point higher than delta_err/delta_time then it resets the envelop (1−exp(−t/T_offset))
## y¨​(t)+2ξω0​y˙​(t)+ω02​y(t) = kω02​(u(t) * (1−exp(−t/T_offset)) +zu˙(t))
## H(s)= K(1−exp(−t/T_offset) + z*s) / ( s²wo² + 2ξs/wo ​+ 1 )​​


var float_envelop:float = 0
var float_old_input:float = 0
var float_output_dot:float  = 0

var vec2_envelop:float = 0
var vec2_old_input:Vector2 = Vector2.ZERO
var vec2_output_dot:Vector2  = Vector2.ZERO

var vec3_envelop:float = 0
var vec3_old_input:Vector3 = Vector3.ZERO
var vec3_output_dot:Vector3  = Vector3.ZERO

## When using SecondOrderSystem; You need to create your a SecondOrderSystem instance the following manner:
## [br][code] @export var body_second_order_config:Dictionary
## [br] @export var body_second_order:SecondOrderSystem[/code]
## [br] This ensure that the plugin can detect correctly each instance.
## [br] You also need to initiate each instance in ready
## [br][code] body_second_order = SecondOrderSystem.new(body_second_order_config)[/code]
##[br][b]Note:[/b]
## Use float_output_variables, vec2_output_variables or vec3_output_variables depending on your vectors type
func _init(weights:Dictionary) -> void:
	if weights.size() != 6:
		push_warning("Second order system weights incorrect, default: ",
				str({"k":1,"wo":40,"xi":1,"z":0,"delta_err":.9,"T_offset":0}),"  will be used instead of: ", str(weights) )

		weights = {"k":1,"wo":40,"xi":1,"z":0,"delta_err":.9,"T_offset":0}
	
	k = weights["k"]
	wo = weights["wo"]
	xi = weights["xi"]
	z = weights["z"]
	delta_err = weights["delta_err"]
	T_offset = weights["T_offset"]

## This function computes the second-order response of a system for float,
##[br] returns a dictionnary containing the output and it's derivatives.
func float_second_order_response(delta:float,input:float,
		previous_output:float,input_dot:Variant=null) -> Dictionary:
		
	if input_dot == null:
		input_dot = (input - float_old_input)/delta
		float_old_input = input

	
	var err:float = log(1+(input-previous_output)**2)
	if err > delta_err:
		float_envelop = 0
	float_envelop += delta / T_offset # if T_offset =0 min(1,value) restore proper value
	float_envelop = min(1,float_envelop)
	
	var output_dotdot:float = ( k * wo**2 * ( input + input_dot * z)
				 -  2 * xi * wo * float_output_dot
				-  wo**2 * previous_output )
	float_output_dot = float_envelop * float_output_dot + output_dotdot * delta / (1 + 2 * xi * wo * delta)
	previous_output += float_output_dot * delta

	return {"output":previous_output,"output_dot":float_output_dot,"output_dotdot":output_dotdot}

## This function computes the second-order response of a system for vector2,
##[br] returns a dictionnary containing the output and it's derivatives.
func vec2_second_order_response(delta:float,input:Vector2,
		previous_output:Vector2,input_dot:Variant=null) -> Dictionary:
	
	# Estimate input_dot
	if input_dot == null:
		input_dot = (input - vec2_old_input)/delta
		vec2_old_input = input


	
	var err:float = log(1+(input-previous_output).length_squared())
	if err > delta_err:
		vec2_envelop = 0
	vec2_envelop += delta / T_offset # if T_offset =0 min(1,value) restore proper value
	vec2_envelop = min(1,vec2_envelop)

	# process second order
	var output_dotdot:Vector2 = ( k * wo**2 * ( input + input_dot * z)
				 - 2 * xi * wo * vec2_output_dot
				- wo**2 * previous_output )
	vec2_output_dot = vec2_envelop * vec2_output_dot + output_dotdot * delta / (1 + 2 * xi * wo * delta)
	previous_output += vec2_output_dot * delta

	return {"output":previous_output,"output_dot":vec2_output_dot,"output_dotdot":output_dotdot}

## This function computes the second-order response of a system for vector2,
##[br] returns a dictionnary containing the output and it's derivatives.
func vec3_second_order_response(delta:float,input:Vector3,
		previous_output:Vector3,input_dot:Variant=null) -> Dictionary:
	
	#if input_dot == "test":
		#Logger.log_warn("test",
		#{
			#"input":input,
			#"old_input":vec3_old_input,
			#"previous_output":previous_output,
			#"input_dot":input_dot,
			#"previous_output_dot":vec3_output_dot,
			#"envelop":vec3_envelop
			#
		#})
	#input_dot = null
	# Estimate input_dot
	if input_dot == null:
		input_dot = (input - vec3_old_input)/delta
		vec3_old_input = input

	
	var err:float = log(1+(input-previous_output).length_squared())
	if err > delta_err :
		vec3_envelop = 0
	vec3_envelop += delta / T_offset # if T_offset =0 min(1,value) restore proper value
	vec3_envelop = min(1,vec3_envelop)
	# process second order
	var output_dotdot:Vector3 = ( k * wo**2 * ( input + input_dot * z)
				 -  2 * xi * wo * vec3_output_dot
				- wo**2 * previous_output )
	vec3_output_dot = vec3_envelop * vec3_output_dot + output_dotdot * delta / (1 + 2 * xi * wo * delta)
	previous_output += vec3_output_dot * delta
	return {"output":previous_output,"output_dot":vec3_output_dot,"output_dotdot":output_dotdot}

## This function resets every runtime variable to 0, usefull when discontiued use 
func reset_runtime_variables():
	vec3_old_input = Vector3.ZERO
	vec3_output_dot  = Vector3.ZERO
	vec3_envelop = 0
	
	vec2_old_input = Vector2.ZERO
	vec2_output_dot  = Vector2.ZERO
	vec2_envelop = 0
	
	float_old_input = 0
	float_output_dot = 0
	float_envelop = 0
