@tool
extends Button
class_name IconButton

#region Icon
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
#endregion

#region Label
@export var label_text: String = "":
	set(value):
		label_text = value
		if label:
			label.text = value
			label.visible = not value.is_empty()
		_update_size()
#endregion

#region Btn Layout
@export var min_size: Vector2 = Vector2.ZERO:
	set(value):
		min_size = value
		_update_size()

@export var vertical_layout: bool = false:
	set(value):
		vertical_layout = value
		if box_container:
			box_container.vertical = value

			if box_container.vertical:
				box_container.alignment = BoxContainer.ALIGNMENT_CENTER
		_update_size()
#endregion


@onready var box_container: BoxContainer = get_node_or_null("MarginContainer/BoxContainer") as BoxContainer
@onready var icon_rect: TextureRect = get_node_or_null("MarginContainer/BoxContainer/TextureRect") as TextureRect
@onready var label: Label = get_node_or_null("MarginContainer/BoxContainer/MarginContainer/Label") as Label

func _ready() -> void:
	if box_container:
		box_container.vertical = vertical_layout

	if icon_rect:
		icon_rect.texture = icon_texture
		icon_rect.custom_minimum_size = icon_size
		icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	if label:
		label.text =label_text
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	_update_size()

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
	
	var margin_container:= get_node_or_null("MarginContainer") as MarginContainer
	if not margin_container:
		return

	# avoid spacing if not all elements are present
	if box_container:
		var has_icon := icon_rect and icon_rect.texture != null
		var has_label := label and label.visible and not label.text.is_empty()
		if has_icon and has_label:
			box_container.remove_theme_constant_override("separation")
		else:
			box_container.add_theme_constant_override("separation",0)

	var content_size: Vector2 = margin_container.get_combined_minimum_size()
	custom_minimum_size = Vector2(
		max(content_size.x, min_size.x),
		max(content_size.y, min_size.y)
	)

	# Override BoxContainer separation if only text or icon
	

