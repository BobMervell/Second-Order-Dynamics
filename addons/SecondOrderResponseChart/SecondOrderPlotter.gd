@tool
extends EditorProperty


const CHART_CONTROL = preload("res://addons/SecondOrderResponseChart/SecondOrderControl.tscn")
var linechart

@export var margin =.4
@export var graph_size = 4
@onready var viewport_height = get_viewport().size[1] / graph_size
@onready var viewport_width = get_viewport().size[0] / graph_size
@onready var corners:Array = [Vector2(0, 0),
			Vector2(viewport_width, 0),
			Vector2(viewport_width,viewport_height),
			Vector2(0,viewport_height),
			Vector2(0, 0)]
@onready var viewport_limits: Array = [Vector2(0, 0),
		Vector2(viewport_width,viewport_height)]
var object #the node who opened the inspector
var prop_name #the secondOrder property dealt by this chart

var K = 1 #Gain
var wo = 1 #Pulsation 
var xi = 1 # damp
var z = 1 # start strength

var control_text:Label
var option_btn:OptionButton

var global_delta = .016
var command_array:Array = []
var response_array:Array = []
var set_complex_command:bool
var set_step_command:bool

var chart_plotter

func _init():
	chart_plotter = LineChartPlotter.new()
	linechart = CHART_CONTROL.instantiate()
	add_child(linechart)
	add_focusable(linechart)
	control_text = linechart.find_child("Label")
	option_btn = linechart.find_child("OptionButton")
	connect_inspector_changes()

func _ready():
	linechart.custom_minimum_size = Vector2(viewport_width,viewport_height*1.2)

func _physics_process(delta):
	global_delta = delta

func _draw():
	draw_colored_polygon(corners,Color.LIGHT_GRAY)
	var viewported = chart_plotter.auto_viewporter(command_array,
			viewport_height*(1-margin),viewport_width,margin)
	var response = chart_plotter.adapt_viewporter(response_array,
			viewported["ratios"],viewported["offsets"],viewport_limits)
	draw_polyline(viewported["array"],Color.RED,5.0)
	draw_polyline(response,Color.DARK_GREEN,3.0)
	draw_polyline(corners,Color.BLACK,5.0)

func update_weights(properties_dict):
	for prop in properties_dict:
		if prop.contains("k"):
			K = properties_dict[prop]
		elif prop.contains("wo"):
			wo = properties_dict[prop]
		elif prop.contains("xi"):
			xi = properties_dict[prop]
		elif prop.contains("z"):
			z = properties_dict[prop]

func set_command_step():
	command_array = chart_plotter.vect_step(5,100,10)

func set_command_detailled():
	command_array = chart_plotter.vect_command(5,500)

func plot_array_response():
	control_text.text = "Response time approximation : " + str(get_temps_95()) + " s"
	var second_order = SecondOrderSystem.new(K,wo,xi,z)
	response_array = [Vector2.ZERO]
	for i in range(1,command_array.size()):
		var output = second_order.vec2_output_variables(global_delta,command_array[i],null,response_array[i-1])
		response_array.append(output[0])
		
	##needed fot ploting because second order modified y 
	for i in range(0,response_array.size()):
		response_array[i][0]=i
	queue_redraw()

func connect_inspector_changes():
	if not EditorInterface.get_inspector().is_connected(
			"property_edited",on_inspector_edited_object_changed):
		EditorInterface.get_inspector().property_edited.connect(
					on_inspector_edited_object_changed)
	if not option_btn.is_connected("item_selected",update_chart):
		option_btn.item_selected.connect(update_chart)

func update_chart(chart_type_ID:int):
	if chart_type_ID == 0: set_command_step()
	elif chart_type_ID == 1: set_command_detailled()
	plot_array_response()

func on_inspector_edited_object_changed(prop):
	if prop.get_slice('_',0) == prop_name.get_slice('_',0):
		object = EditorInterface.get_inspector().get_edited_object()
		var related_properties = get_related_properties(prop,object)
		var properties_dict = get_properties_value(related_properties,object)
		update_weights(properties_dict) 
		update_chart(option_btn.get_selected_id())

func get_related_properties(prop_name,object):
	var property_first_name = prop_name.get_slice('_',0)
	var properties = object.get_property_list()
	var list = []
	for prop in properties:
		if prop["name"].get_slice('_',0) == property_first_name:
			list.append(prop["name"])
	return list

func get_properties_value(related_properties,object):
	var dict = {}
	for prop in related_properties:
		dict[prop] = object[prop]
	return dict

func get_temps_95():
	if xi > 1:return (3/wo)
	else: return (3/(wo*xi))
