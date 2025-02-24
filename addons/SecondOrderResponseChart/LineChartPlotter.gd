class_name LineChartPlotter extends Control

func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array

func auto_viewporter(list:Array,out_height,out_width,margin,right_offset):
	var extremums = get_array_extremums(list)
	var ratios = get_view_ratio(extremums,out_height,out_width,margin)
	var array = update_ratio(list,ratios)
	var offsets =( get_view_offset(get_array_extremums(array),
			out_height,out_width,margin,right_offset) )
	array = update_offset(array,offsets)
	return {"array":array,"ratios":ratios,"offsets":offsets,"extremums":extremums}

func adapt_viewporter(list:Array,ratios:Vector2,offsets:Vector2,limits:Array):
	var return_array = []
	var new_vect:Vector2
	var array = update_ratio(list,ratios)
	array = update_offset(array,offsets)
	for vector in array:
		new_vect.x = clamp(vector.x,limits[0].x,limits[1].x)
		new_vect.y = clamp(vector.y,limits[0].y,limits[1].y)
		return_array.append(new_vect)
	return return_array

func get_array_extremums(list:Array):
	var min_value = Vector2(INF,INF)
	var max_value = Vector2(-INF,-INF)
	for vector in list:
		min_value.x = min(min_value.x,vector.x)
		min_value.y = min(min_value.y,vector.y)
		max_value.x = max(max_value.x,vector.x)
		max_value.y = max(max_value.y,vector.y)
	return {"min":min_value,"max":max_value}

func get_view_ratio(extremums:Dictionary,out_height,out_width,margin):
	var width = extremums["min"].x - (extremums["max"].x)
	var height = extremums["min"].y - (extremums["max"].y)
	var h_ratio = abs(out_height/height*(1-margin))
	var w_ratio = abs(out_width/width)
	return Vector2(w_ratio,-h_ratio)

func get_view_offset(extremums:Dictionary,out_height,out_width,margin,right_offset):
	var min_value = Vector2(extremums["min"].x , extremums["max"].y)
	#we take the max for y cause y increase the further down not up
	var bottom_left = Vector2(right_offset,out_height*(1+margin/2)) 
	return bottom_left-min_value

func update_ratio(list:Array,ratios):
	var ratioed_list = []
	for vector in list:
		var new_vect = Vector2(vector.x*ratios.x,vector.y*ratios.y)
		ratioed_list.append(new_vect)
	return ratioed_list

func update_offset(list:Array,offsets):
	var offset_list = []
	for vector in list:
		var new_vect = vector + offsets
		offset_list.append(new_vect)
	return offset_list

func readapt_vertical_axis(list:Array,out_height):
	list[0] = Vector2(list[0][0],0)
	list[1] = Vector2(list[1][0],out_height)
	return list

func vect_step(step_amp,nbr_pts,step_at):
	var step = []
	for i in range(0,nbr_pts):
		if i <= step_at:
			step.append(Vector2(i,0))
		else: step.append(Vector2(i,step_amp))
	return step

func vect_command(amp,nbr_pts):
	var command  = []
	var tenth = nbr_pts / 10
	for i in range(0,tenth):
		command.append(Vector2(i,0))
	for i in range(tenth, 4*tenth):
		command.append(Vector2(i,amp*sin((i-tenth)/8.0)))
	var A = command[4*tenth-1][0]
	for i in range(4*tenth, 7*tenth):
		command.append(Vector2(i,(i-4*tenth)/8.0))
	for i in range(7*tenth,nbr_pts ):
		command.append(Vector2(i,0))
	return command
