extends Label
class_name ActionLabel

func _ready() -> void:
	var card_manager: CardManager = get_tree().get_first_node_in_group(GlobalGroupNames.CARD_MANAGER);
	
	card_manager.update_action.connect(_on_update_label.bind());

func _on_update_label(new_label: String) -> void:
	if new_label.is_empty():
		self.text = new_label
		return

	# Get the current font size (fallback to a default if not set)
	var base_font_size: int = self.get_theme_font_size("font_size")
	var enlarged_font_size: int = int(base_font_size * 3)  # Increase by 20%

	# Create a tween for font size animation
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "theme_override_font_sizes/font_size", enlarged_font_size, 0.2)  

	self.text = new_label;

	tween.tween_property(self, "theme_override_font_sizes/font_size", base_font_size, 0.2) 
