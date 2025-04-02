extends Label

var card_manager: CardManager;

func _ready() -> void:
	card_manager = get_tree().get_first_node_in_group(GlobalGroupNames.CARD_MANAGER);

func _process(delta: float) -> void:
	self.text = "Discard\n" + str(card_manager.discard_pile.size());
