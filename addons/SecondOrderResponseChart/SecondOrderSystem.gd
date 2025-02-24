extends Node
class_name SecondOrderSystem
##When using SecondOrderSystem; You need to name your variables the following
## manner for the chart plugin to work:

# a_name_k
# a_name_wo 
# a_name_xi
# a_name_z
# a_name_second_order = SecondOrderSystem.new(a_name_k,a_name_wo,
#		a_name_xi,a_name_z)

var k:float #Gain, (offset factor t = +INF )
var wo:float #Pulsation (response/oscillation speed)
var xi:float #ksi >= 1 == no oscillation, ksi<1 = overshoot + oscillations
var z:float # z<0 = reversal start , z>0 strong start + overshoot

var old_input_pos:Vector2 = Vector2.ZERO
var output_speed:Vector2 = Vector2.ZERO

var vec2_old_input_pos:Vector2 = Vector2.ZERO
var vec2_output_speed:Vector2 = Vector2.ZERO

var vec3_old_input_pos:Vector3 = Vector3.ZERO
var vec3_output_speed:Vector3 = Vector3.ZERO

func _init(weights:Dictionary) -> void:
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
