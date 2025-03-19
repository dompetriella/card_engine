extends Node2D
class_name CardManager

const CARD_NODE: PackedScene = preload("uid://biy8302fr2vdu");
const CARD_WIDTH: float = 64;
const HAND_Y_OFFSET_MARGIN: float = 128;

@export var draw_amount: int = 5;

var player_hand: Array[CardNode] = []
var card_being_dragged: CardNode;

func _ready() -> void:
	draw_starting_hand()
	
func _process(delta: float) -> void:
	if (card_being_dragged):
		var mouse_position: Vector2 = get_global_mouse_position();
		card_being_dragged.position = mouse_position;
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# When the mouse button is pressed, check for a card
			var card: CardNode = raycast_check_for_card()
			if card:
				card_being_dragged = card
		else:
			# When the mouse button is released
			if card_being_dragged:
				card_being_dragged = null 
				update_player_hand_card_positions(); # Reset the dragged card

func raycast_check_for_card() -> CardNode:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new();
	parameters.position = get_global_mouse_position();
	parameters.collide_with_areas = true;
	parameters.collision_mask = 1;
	var result: Array[Dictionary] = space_state.intersect_point(parameters);
	if (result.size() > 0):
		var card_node_check = result[0].collider
		if (card_node_check != null && card_node_check.get_parent() is CardNode):
			return card_node_check.get_parent();
			
	return null;

func draw_starting_hand() -> void:
	for i in draw_amount:
		draw_card();
		
func draw_card() -> void:
	var card_node: CardNode = CARD_NODE.instantiate();
	card_node.scale = Vector2(0.5, 0.5);
	card_node.id = randi();
	player_hand.append(card_node);
	
	# bind focus events
	card_node.card_focused.connect(_on_card_is_focused.bind());
	card_node.card_unfocused.connect(_on_card_is_unfocused.bind());
	
	self.add_child(card_node);
	update_player_hand_card_positions();

func update_player_hand_card_positions() -> void:
	for i in player_hand.size():
		var new_position = calculate_card_position(i);
		player_hand[i].global_position = new_position;
		
func calculate_card_position(index: int) -> Vector2:
	var total_width: float = (player_hand.size() - 1) * CARD_WIDTH;
	var viewport: Vector2 = get_viewport().size;
	var x_center: float = viewport.x / 2;
	var y_position: float = viewport.y - HAND_Y_OFFSET_MARGIN;
	var card_x_offset: float = x_center + index * CARD_WIDTH - total_width / 2;
	return Vector2(card_x_offset, y_position);

func _on_card_is_focused(card: CardNode):
	print(str(card.id) + " focused");
	
func _on_card_is_unfocused(card: CardNode):
	print(str(card.id) + " unfocused");
	
