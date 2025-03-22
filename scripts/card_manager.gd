extends Node2D
class_name CardManager

const CARD_NODE: PackedScene = preload("uid://biy8302fr2vdu");
const CARD_WIDTH: float = 80;
const HAND_Y_OFFSET_MARGIN: float = 128;
const DEFAULT_CARD_SCALE: Vector2 = Vector2(0.5, 0.5);\
const DEFAULT_CARD_Z_INDEX: int = 1;
const CARD_SELECTED_Z_INDEX: int = 99;
const CARD_SELECTED_Y_OFFSET: float = -48;

@export var first_hand_draw_amount: int = 5;

var is_hovering_over_card: bool = false;
var click_timer: Timer;

var card_being_dragged: CardNode;
var selected_cards: Array[CardNode];
var player_hand: Array[CardNode] = [];


func _ready() -> void:
	draw_starting_hand()
	
func _process(delta: float) -> void:
	if (card_being_dragged):
		var mouse_position: Vector2 = get_global_mouse_position();
		card_being_dragged.position = mouse_position;
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.pressed:
			var card: CardNode = raycast_check_for_card()
			if card:
				if card not in selected_cards:
					selected_cards.append(card);
					set_card_as_selected(card);
				else:
					selected_cards.erase(card);
					set_card_as_not_selected(card);
					update_player_hand_card_positions();
		#else:
			#if card_being_dragged:
				#card_being_dragged = null 
				#update_player_hand_card_positions();

func raycast_check_for_card() -> CardNode:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new();
	parameters.position = get_global_mouse_position();
	parameters.collide_with_areas = true;
	parameters.collision_mask = 1;
	var result: Array[Dictionary] = space_state.intersect_point(parameters);
	if (result.size() > 0):  
		var highest_z_node = null  
		var highest_z_index = -INF  # Start with the lowest possible value  

		for item in result:  
			var card_node_check = item.collider  
			if card_node_check != null and card_node_check.get_parent() is CardNode:  
				var parent_node = card_node_check.get_parent()  
				if parent_node.z_index > highest_z_index:  
					highest_z_index = parent_node.z_index  
					highest_z_node = parent_node  

		return highest_z_node
			
	return null;

func draw_starting_hand() -> void:
	for i in first_hand_draw_amount:
		draw_card(i);
		
func draw_card(id: int) -> void:
	var card_node: CardNode = CARD_NODE.instantiate();
	
	card_node.scale = DEFAULT_CARD_SCALE;
	card_node.id = id;
	player_hand.append(card_node);
	
	# bind focus events
	card_node.card_focused.connect(_on_card_is_focused.bind());
	card_node.card_unfocused.connect(_on_card_is_unfocused.bind());
	
	self.add_child(card_node);
	update_player_hand_card_positions();

# this is the constant function that calculates where a card should be
# on the screen after something like a card played, drawn, discarded, etc
func update_player_hand_card_positions() -> void:
	for i in player_hand.size():
		var total_width: float = (player_hand.size() - 1) * CARD_WIDTH;
		var viewport: Vector2 = get_viewport().size;
		var x_center: float = viewport.x / 2;
		var y_position: float = viewport.y - HAND_Y_OFFSET_MARGIN;
		var card_x_offset: float = x_center + i * CARD_WIDTH - total_width / 2;
		var new_position =	Vector2(card_x_offset, y_position);
		player_hand[i].global_position = new_position;

func _on_card_is_focused(card: CardNode):
	if (!is_hovering_over_card):
		is_hovering_over_card = true;
		set_card_focus_properties(card);
	
	
func _on_card_is_unfocused(card: CardNode):
	set_card_unfocused_properties(card);
	var new_card_hovered: CardNode = raycast_check_for_card()
	if (new_card_hovered is CardNode):
		set_card_focus_properties(new_card_hovered)
	else:
		is_hovering_over_card = false;

# focus represents viewability of the card
# for a mouse, this is what would happen in a "hover state"
# for a controller, it'd be the current focus to click a button
func set_card_focus_properties(card: CardNode):
	card.z_index = CARD_SELECTED_Z_INDEX + 1;
	card.scale = DEFAULT_CARD_SCALE * 1.05;
	
func set_card_unfocused_properties(card: CardNode):
	if (card not in selected_cards):
		card.z_index = DEFAULT_CARD_Z_INDEX;
		card.scale = DEFAULT_CARD_SCALE;
	
func set_card_as_selected(card: CardNode):
	card.z_index = CARD_SELECTED_Z_INDEX;
	card.global_position.y = card.global_position.y + CARD_SELECTED_Y_OFFSET;
	print(selected_cards);
	
func set_card_as_not_selected(card: CardNode):
	card.global_position.y = card.global_position.y - CARD_SELECTED_Y_OFFSET;
	card.z_index = DEFAULT_CARD_Z_INDEX;
	print(selected_cards);
