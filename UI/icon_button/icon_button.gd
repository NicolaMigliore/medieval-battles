@tool
extends Button
class_name IconButton

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		if icon_rect:
			icon_rect.texture = value

@export var icon_size: Vector2i = Vector2i(32, 32):
	set(value):
		icon_size = value
		if icon_rect:
			icon_rect.custom_minimum_size = value
		_update_size()

@export var label_text: String = "":
	set(value):
		label_text = value
		if label:
			label.text = value
		_update_size()

@export var min_size: Vector2 = Vector2.ZERO:
	set(value):
		min_size = value
		_update_size()


@onready var icon_rect: TextureRect = $MarginContainer/HBoxContainer/TextureRect
@onready var label: Label = $MarginContainer/HBoxContainer/MarginContainer/Label

func _ready() -> void:
	icon_rect.texture = icon_texture
	icon_rect.custom_minimum_size = icon_size

	label.text =label_text

	# resize button
	custom_minimum_size = $MarginContainer.get_combined_minimum_size()


func _process(_delta: float) -> void:
	_update_label_color()


func _update_label_color() -> void:
	if not label:
		return
	var color: Color
	if has_focus() and has_theme_color("font_focus_color", "Button"):
		color = get_theme_color("font_focus_color", "Button")
	else:
		match get_draw_mode():
			DRAW_PRESSED, DRAW_HOVER_PRESSED:
				color = get_theme_color("font_pressed_color", "Button")
			DRAW_HOVER:
				color = get_theme_color("font_hover_color", "Button")
			DRAW_DISABLED:
				color = get_theme_color("font_disabled_color", "Button")
			_:
				color = get_theme_color("font_color", "Button")
	label.add_theme_color_override("font_color", color)



func _update_size() -> void:
	if not is_inside_tree():
		return
	var content_size: Vector2 = $MarginContainer.get_combined_minimum_size()
	custom_minimum_size = Vector2(
		max(content_size.x, min_size.x),
		max(content_size.y, min_size.y)
	)
