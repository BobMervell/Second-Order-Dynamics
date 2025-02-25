class_name LineChartPlotter extends Control

func auto_viewporter(values:Array,out_height:float,out_width:float,margin:float) -> Dictionary:
	var extremums:Dictionary = get_array_extremums(values)
	var ratios:Vector2 = get_view_ratio(extremums,out_height,out_width,margin)
	var viewported_values:Array = update_ratio(values,ratios)
	var offsets:Vector2 =( get_view_offset(get_array_extremums(viewported_values),
			out_height,margin) )
	viewported_values = update_offset(viewported_values,offsets)
	return {"viewported_values":viewported_values,"ratios":ratios,"offsets":offsets,"extremums":extremums}

func adapt_viewporter(values:Array,ratios:Vector2,offsets:Vector2,limits:Array) -> Array[Vector2]:
	var return_array:Array[Vector2]
	var new_vect:Vector2
	var array:Array[Vector2] = update_ratio(values,ratios)
	array = update_offset(array,offsets)
	for vector:Vector2 in array:
		new_vect.x = clamp(vector.x,limits[0].x,limits[1].x)
		new_vect.y = clamp(vector.y,limits[0].y,limits[1].y)
		return_array.append(new_vect)
	return return_array

func get_array_extremums(values:Array) -> Dictionary:
	var min_value:Vector2 = Vector2(INF,INF)
	var max_value:Vector2 = Vector2(-INF,-INF)
	for vector:Vector2 in values:
		min_value.x = min(min_value.x,vector.x)
		min_value.y = min(min_value.y,vector.y)
		max_value.x = max(max_value.x,vector.x)
		max_value.y = max(max_value.y,vector.y)
	return {"min":min_value,"max":max_value}

func get_view_ratio(extremums:Dictionary,out_height:float,out_width:float,margin:float) -> Vector2:
	var width:float = extremums["min"].x - (extremums["max"].x)
	var height:float = extremums["min"].y - (extremums["max"].y)
	var h_ratio:float = abs(out_height/height*(1-margin))
	var w_ratio:float = abs(out_width/width)
	return Vector2(w_ratio,-h_ratio)

func get_view_offset(extremums:Dictionary,out_height:float,margin:float) -> Vector2:
	@warning_ignore("unsafe_call_argument")
	var min_value:Vector2 = Vector2(extremums["min"].x , extremums["max"].y)
	#we take the max for y cause y increase the further down not up
	var bottom_left:Vector2 = Vector2(0,out_height*(1+margin/2)) 
	return bottom_left-min_value

func update_ratio(list:Array,ratios:Vector2) -> Array[Vector2]:
	var ratioed_list:Array[Vector2]
	for vector:Vector2 in list:
		var new_vect:Vector2 = Vector2(vector.x*ratios.x,vector.y*ratios.y)
		ratioed_list.append(new_vect)
	return ratioed_list

func update_offset(list:Array[Vector2],offsets:Vector2) -> Array[Vector2]:
	var offset_list:Array[Vector2]
	for vector:Vector2 in list:
		var new_vect:Vector2 = vector + offsets
		offset_list.append(new_vect)
	return offset_list

func readapt_vertical_axis(list:Array[Vector2],out_height:float) -> Array:
	list[0] = Vector2(list[0][0],0)
	list[1] = Vector2(list[1][0],out_height)
	return list

func vect_step(step_amp:float,nbr_pts:int,step_at:int) -> Array[Vector2]:
	var step:Array[Vector2]
	for i:int in range(0,nbr_pts):
		if i <= step_at:
			step.append(Vector2(i,0))
		else: step.append(Vector2(i,step_amp))
	return step

func vect_command(amp:float,nbr_pts:int) -> Array[Vector2]:
	var command:Array[Vector2]
	@warning_ignore("integer_division")
	var tenth:int = nbr_pts / 10
	for i:int in range(0,tenth):
		command.append(Vector2(i,0))
	for i:int in range(tenth, 4*tenth):
		command.append(Vector2(i,amp*sin((i-tenth)/8.0)))
	for i:int in range(4*tenth, 7*tenth):
		command.append(Vector2(i,(i-4*tenth)/8.0))
	for i:int in range(7*tenth,nbr_pts ):
		command.append(Vector2(i,0))
	return command
