@tool
extends EditorProperty
class_name SecondOrderPlotter

var margin:float =.4 # in chart vertical margin
var left_offset:int = 25 #offset of chart on the left
var viewport_height:float
var viewport_width:float
var corners:Array 
var viewport_limits:Array

var command_color:Color = Color.RED
var output_color:Color = Color.DARK_GREEN

var weights:Dictionary = {"k":1,"wo":40,"xi":1,"z":0} #default
var global_delta:float = .016
var chart_type_ID:int = 0
var simulation_time:float = 2.1
var step_at:float = .21
var precision:float = 1

var command_array:Array[Vector2] = []
var response_array:Array[Vector2] = []

var chart_plotter:LineChartPlotter
var chart_container:Control
var response_time_label:Label

##used to get process time
var start_time:float
var end_time:float


func add_graph_response_time() -> HBoxContainer:
	var parent:HBoxContainer = HBoxContainer.new()
	var text:Label = Label.new()
	response_time_label = Label.new()
	var end_text:Label = Label.new()
	parent.add_child(text)
	parent.add_child(response_time_label)
	parent.add_child(end_text)
	
	text.text = "Response time approximation: "
	response_time_label.text = "0"
	end_text.text = "s"
	return parent

func _init() -> void:
	var parent:VBoxContainer = VBoxContainer.new()
	chart_plotter = LineChartPlotter.new()
	chart_container = Control.new()
	parent.add_child(chart_container)
	parent.add_child(add_graph_response_time())
	add_child(parent)
	set_command_step()

func _ready() -> void:
	update_graph_size()
	EditorInterface.get_inspector().resized.connect(update_graph_size)

func update_graph_size() -> void:
	var inspector_size:Vector2 = EditorInterface.get_inspector().size
	
	# not custom_minimum_size.x because can't reduce size and crash if too big
	chart_container.custom_minimum_size.y = inspector_size.x / 1.6 - left_offset
	chart_container.size.y = chart_container.custom_minimum_size.y
	
	viewport_width = chart_container.size.y * 1.6 
	viewport_height = chart_container.size.y
	
	viewport_limits = [Vector2(0, 0),
		Vector2(viewport_width,viewport_height)]
	corners = [Vector2(0, 0),
			Vector2(viewport_width, 0),
			Vector2(viewport_width,viewport_height),
			Vector2(0,viewport_height),
			Vector2(0, 0)]

func _physics_process(delta:float) -> void:
	global_delta = delta

func _draw() -> void:
	var editor_settings:EditorSettings = EditorInterface.get_editor_settings()
	var bg_color:Color = editor_settings.get_setting("text_editor/theme/highlighting/background_color")
	var border_color:Color = editor_settings.get_setting("text_editor/theme/highlighting/text_color")
	
	var graph_height:float = viewport_height*(1-margin)
	var graph_width:float = viewport_width

	
	var viewported:Dictionary = chart_plotter.auto_viewporter(command_array,
			graph_height,graph_width,margin)
	@warning_ignore("unsafe_call_argument")
	var response:Array = chart_plotter.adapt_viewporter(response_array,
			viewported["ratios"],viewported["offsets"],viewport_limits)
	
	draw_colored_polygon(corners,bg_color)
	@warning_ignore("unsafe_call_argument")
	draw_polyline(viewported["viewported_values"],command_color,4)
	draw_polyline(response,output_color,3)
	draw_polyline(corners,border_color,2)
	end_time = Time.get_ticks_usec()
	#print((end_time-start_time)/1000)

func plot_array_response() -> void:
	start_time = Time.get_ticks_usec()
	var second_order:SecondOrderSystem = SecondOrderSystem.new(weights)
	response_array = [Vector2.ZERO]
	for i:int in range(1,command_array.size()):
		var output:Dictionary = second_order.float_second_order_response(global_delta*precision,command_array[i].y,response_array[i-1].y)
		@warning_ignore("unsafe_call_argument")
		var response:Vector2 = Vector2(command_array[i].x,output["output"])
		response_array.append(response)
	@warning_ignore("unsafe_method_access")
	if response_time_label.get_parent().is_visible():
		response_time_label.text =  "%.3f" % get_temps_95_bis()
	queue_redraw()

func update_chart_weights(new_weights:Dictionary) -> void:
	for key:String in new_weights:
		weights[key] = new_weights[key]
	plot_array_response()

func update_chart_type(new_chart_type_ID:int) -> void:
	chart_type_ID = new_chart_type_ID
	if new_chart_type_ID == 0: set_command_step()
	elif new_chart_type_ID == 1: set_command_detailled()
	plot_array_response()

func update_simuation_precision(new_precision:float) -> void:
	precision = new_precision
	update_chart_type(chart_type_ID)

func update_simuation_duration(new_duration:float) -> void:
	simulation_time = new_duration
	step_at = simulation_time/10
	update_chart_type(chart_type_ID)

func set_command_step() -> void:
	if precision ==0: precision = 1
	command_array = chart_plotter.precise_step(simulation_time,global_delta,step_at,precision)
	@warning_ignore("unsafe_method_access")
	response_time_label.get_parent().set_visible(true)

func set_command_detailled() -> void:
	command_array = chart_plotter.complex_command(simulation_time,global_delta,precision)
	@warning_ignore("unsafe_method_access")
	response_time_label.get_parent().set_visible(false)

func get_temps_95_bis()-> float:
	for i:int in range(command_array.size()-1,0,-1):
		var out_range:bool = response_array[i].y < 0.95 * command_array[-1].y
		out_range = out_range or response_array[i].y > 1.05 * command_array[-1].y
		if out_range:
			if i > .95 * command_array.size()-1:
				return +INF
			return i * global_delta * precision - step_at
	return 1


func get_temps_95() -> float:
	if weights["xi"] > 1:return (5*weights["xi"]/weights["wo"])
	else: return (3/(weights["wo"]*weights["xi"]))
