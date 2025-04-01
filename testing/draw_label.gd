extends Label

var card_manager: CardManager;

func _ready() -> void:
	card_manager = get_tree().get_nodes_in_group(GlobalGroupNames.CARD_MANAGER)[0];

func _process(delta: float) -> void:
	self.text = "Draw\n" + str(card_manager.draw_pile.size());
