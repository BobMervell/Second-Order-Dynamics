@tool
extends EditorProperty
class_name SecondOrderPlotter

var margin =.4
var graph_size = .9
var right2left_offset_ratio = .7
var viewport_height:float
var viewport_width:float
var corners:Array
var viewport_limits:Array
var right_offset:float
var left_offset:float
var top_offset:float

var command_color:=Color.RED
var output_color:=Color.DARK_GREEN

var object #the node who opened the inspector
var prop_name #the secondOrder property dealt by this chart

var weights:Dictionary
var global_delta:float = .016
var command_array:Array = []
var response_array:Array = []
var set_complex_command:bool
var set_step_command:bool

var chart_plotter:LineChartPlotter
var chart_container:Control
var response_time_label:Label
var chart_size_slider:Control

func add_graph_response_time() -> HBoxContainer:
	var parent :=HBoxContainer.new()
	var text := Label.new()
	response_time_label = Label.new()
	var end_text := Label.new()
	parent.add_child(text)
	parent.add_child(response_time_label)
	parent.add_child(end_text)
	
	text.text = "Response time approximation: "
	response_time_label.text = "0"
	end_text.text = "s"
	return parent

func add_graph_container() -> Control:
	var container = Control.new()
	container.set_anchors_preset(chart_container.PRESET_FULL_RECT)
	return container

func add_graph_size_slider() -> VSlider: 
	var test = VSlider.new()
	return test

func _init():
	var parent :=VBoxContainer.new()
	chart_plotter = LineChartPlotter.new()
	chart_container = add_graph_container()
	chart_size_slider = add_graph_size_slider()
	var hbox := HBoxContainer.new()
	hbox.add_child(chart_container)
	#hbox.add_child(chart_size_slider)
	parent.add_child(hbox)
	parent.add_child(add_graph_response_time())
	add_child(parent)
	set_command_step()

func _ready():
	update_graph_size()
	var insp:EditorInspector = EditorInterface.get_inspector()
	insp.resized.connect(update_graph_size)

func update_graph_size():
	var inspector_size:Vector2 = EditorInterface.get_inspector().size

	right_offset = inspector_size[0] * (1-graph_size)
	left_offset = right2left_offset_ratio * right_offset
	top_offset = left_offset *.2
	
	viewport_width = inspector_size[0] * graph_size
	viewport_height = viewport_width / 1.6
	viewport_limits = [Vector2(right_offset, 0),
		Vector2(viewport_width+left_offset,viewport_height)]
	corners = [Vector2(right_offset, top_offset),
			Vector2(viewport_width+left_offset, top_offset),
			Vector2(viewport_width+left_offset,viewport_height),
			Vector2(right_offset,viewport_height),
			Vector2(right_offset, top_offset)]
	
	chart_container.custom_minimum_size = Vector2(viewport_width,viewport_height)

func _physics_process(delta):
	global_delta = delta

func _draw():
	var editor_settings:EditorSettings = EditorInterface.get_editor_settings()
	var bg_color:Color = editor_settings.get_setting("text_editor/theme/highlighting/background_color")
	var border_color:Color = editor_settings.get_setting("text_editor/theme/highlighting/text_color")
	draw_colored_polygon(corners,bg_color)
	var viewported = chart_plotter.auto_viewporter(command_array,
			viewport_height*(1-margin)-top_offset,viewport_width-right_offset+left_offset,margin,right_offset)
	var response = chart_plotter.adapt_viewporter(response_array,
			viewported["ratios"],viewported["offsets"],viewport_limits)
	draw_polyline(viewported["array"],command_color,4)
	draw_polyline(response,output_color,3)
	draw_polyline(corners,border_color,2)

func set_command_step():
	command_array = chart_plotter.vect_step(5,100,10)

func set_command_detailled():
	command_array = chart_plotter.vect_command(5,500)

func plot_array_response():
	var second_order = SecondOrderSystem.new(weights)
	response_array = [Vector2.ZERO]
	for i in range(1,command_array.size()):
		var output = second_order.vec2_output_variables(global_delta,command_array[i],null,response_array[i-1])
		response_array.append(output[0])
		
	# needed fot plotting because second order modified y 
	for i in range(0,response_array.size()):
		response_array[i][0]=i
	response_time_label.text = str(round(get_temps_95()*1000)/1000)
	queue_redraw()

func update_chart_weights(new_weights:Dictionary):
	weights = new_weights
	plot_array_response()

func update_chart_type(chart_type_ID:int):
	if chart_type_ID == 0: set_command_step()
	elif chart_type_ID == 1: set_command_detailled()
	plot_array_response()

func get_temps_95():
	if weights["xi"] > 1:return (3/weights["wo"])
	else: return (3/(weights["wo"]*weights["xi"]))
