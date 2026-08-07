class_name HPBar
extends Control

@onready var bar:ProgressBar = $ProgressBar
@onready var label:Label = $Label 

var fill_style: StyleBoxFlat
var colors = [
	{ "min": -1, "max": 0.25, "color": "#ba4a4a"},
	{ "min": 0.25, "max": 0.50, "color": "#ba864a"},
	{ "min": 0.50, "max": 0.75, "color": "#4aba56"},
	{ "min": 0.75, "max": 1, "color": "#4ba8bb"}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_style = bar.get_theme_stylebox("fill").duplicate()
	bar.add_theme_stylebox_override("fill", fill_style)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible:
		var perc = bar.value / bar.max_value
		for c in colors:
			if perc > c.min and perc <= c.max:
				fill_style.bg_color = Color(c.color)
				return
			
func set_label(text: String) -> void:
	label.text = text


func tween_bar(new_value:float, duration:float=2.0) -> void:
	# value = 0
	var tween: Tween = create_tween()
	tween.tween_property(bar, "value", new_value, duration)