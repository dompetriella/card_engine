extends Node2D
class_name CardManager

const VIEWPORT_HEIGHT = 648;
const VIEWPORT_WIDTH = 1152;

const CARD_NODE: PackedScene = preload("uid://biy8302fr2vdu");
const CARD_WIDTH: float = 80;
const HAND_Y_OFFSET_MARGIN: float = 128;
const DEFAULT_CARD_SCALE: Vector2 = Vector2(0.5, 0.5);
const DEFAULT_CARD_Z_INDEX: int = 1;
const CARD_SELECTED_Z_INDEX: int = 99;
const CARD_DRAGGING_Z_INDEX: int = 999;
const CARD_SELECTED_Y_OFFSET: float = -32;
# in seconds
const TIME_BEFORE_CARD_IS_DRAGGED: float = 0.5;

@export var first_hand_draw_amount: int = 5;

var is_hovering_over_card: bool = false;
var drag_timer: float = 0.0;

var card_clicked_in_memory: CardNode;
var selected_cards: Array[CardNode];
var player_hand: Array[CardNode] = [];
	
func _ready() -> void:
	draw_starting_hand();

func _process(delta: float) -> void:
	if (card_clicked_in_memory):
		drag_timer += delta;
		if (drag_timer > TIME_BEFORE_CARD_IS_DRAGGED):
			card_clicked_in_memory.z_index = CARD_DRAGGING_Z_INDEX;
			card_clicked_in_memory.modulate = Color.LIGHT_GOLDENROD;
			var mouse_position: Vector2 = get_global_mouse_position();
			card_clicked_in_memory.position = mouse_position;
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card: CardNode = raycast_check_for_top_card()
			if card:
				card_clicked_in_memory = card
				drag_timer = 0.0  # Reset the timer when a card is clicked

		#mouse button released
		else:
			
			#meaning that we clicked on a card
			if card_clicked_in_memory:
				if drag_timer < TIME_BEFORE_CARD_IS_DRAGGED:
					
					# Only select/deselect if it wasn't dragged
					if card_clicked_in_memory not in selected_cards:
						selected_cards.append(card_clicked_in_memory)
						set_card_as_selected(card_clicked_in_memory)
					else:
						selected_cards.erase(card_clicked_in_memory)
						set_card_as_not_selected(card_clicked_in_memory)
					card_clicked_in_memory = null
				
					drag_timer = 0.0
					update_player_hand_card_positions()
				else:
					# Reset drag variables after releasing
					card_clicked_in_memory.modulate = Color.WHITE;
					card_clicked_in_memory = null
					
					drag_timer = 0.0
					var cards_landed_on: Array[CardNode] = raycast_check_for_all_cards();
					if (cards_landed_on.size() == 2):
						swap_card_positions(cards_landed_on[1], cards_landed_on[0]);
					update_player_hand_card_positions();

					

func swap_card_positions(card_one: CardNode, card_two: CardNode) -> void:
	var index_one: int = player_hand.find(card_one)
	var index_two: int = player_hand.find(card_two)

	# Ensure both cards exist in the array
	if index_one == -1 or index_two == -1:
		print("Error: One or both cards not found in player_hand")
		return

	# Perform the swap manually
	var temp: CardNode = player_hand[index_one]
	player_hand[index_one] = player_hand[index_two]
	player_hand[index_two] = temp

func calculate_card_order_z_index():
	for i in range(player_hand.size()):
		if (player_hand[i] not in selected_cards):
			player_hand[i].z_index = 0;
	
	for i in range(player_hand.size()):
		if (player_hand[i] not in selected_cards):
			player_hand[i].z_index = i+1;

func raycast_check_for_top_card() -> CardNode:
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


 #need to check for all cards to swap dragged cards
func raycast_check_for_all_cards() -> Array[CardNode]:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new();
	parameters.position = get_global_mouse_position();
	parameters.collide_with_areas = true;
	parameters.collision_mask = 1;
	var result: Array[Dictionary] = space_state.intersect_point(parameters);
	var cards_clicked_on: Array[CardNode] = [];
	if (result.size() > 0):  # Start with the lowest possible value  

		for item in result:  
			var card_node_check = item.collider  
			if card_node_check != null and card_node_check.get_parent() is CardNode:   
				cards_clicked_on.append(card_node_check.get_parent());
			
	return cards_clicked_on;

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
		var viewport: Vector2 = Vector2(VIEWPORT_WIDTH, VIEWPORT_HEIGHT);
		var x_center: float = viewport.x / 2;
		var selected_y_offset: float = CARD_SELECTED_Y_OFFSET if player_hand[i] in selected_cards else 0;
		var y_position: float = viewport.y - HAND_Y_OFFSET_MARGIN + selected_y_offset;
		var card_x_offset: float = x_center + i * CARD_WIDTH - total_width / 2;
		var new_position =	Vector2(card_x_offset, y_position);
		player_hand[i].global_position = new_position;
		
		calculate_card_order_z_index();
	

func _on_card_is_focused(card: CardNode):
	if (!is_hovering_over_card):
		is_hovering_over_card = true;
		set_card_focus_properties(card);
	
	
func _on_card_is_unfocused(card: CardNode):
	set_card_unfocused_properties(card);
	var new_card_hovered: CardNode = raycast_check_for_top_card()
	if (new_card_hovered is CardNode):
		set_card_focus_properties(new_card_hovered)
	else:
		is_hovering_over_card = false;

# focus represents viewability of the card
# for a mouse, this is what would happen in a "hover state"
# for a controller, it'd be the current focus to click a button
func set_card_focus_properties(card: CardNode):
	print('focused')
	if (card not in selected_cards):
		card.z_index = CARD_SELECTED_Z_INDEX + 1;
		card.scale = DEFAULT_CARD_SCALE * 1.05;
	
func set_card_unfocused_properties(card: CardNode):
	card.scale = DEFAULT_CARD_SCALE;
	calculate_card_order_z_index();
	
func set_card_as_selected(card: CardNode):
	card.z_index = CARD_SELECTED_Z_INDEX;
	card.global_position.y = card.global_position.y + CARD_SELECTED_Y_OFFSET;
	card.modulate = Color.LIGHT_GREEN;
	print(selected_cards);
	
func set_card_as_not_selected(card: CardNode):
	card.global_position.y = card.global_position.y - CARD_SELECTED_Y_OFFSET;
	card.z_index = DEFAULT_CARD_Z_INDEX;
	card.modulate = Color.WHITE;
	print(selected_cards);
