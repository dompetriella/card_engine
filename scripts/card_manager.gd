extends Node2D
class_name CardManager

signal update_action(label: String)

#update this to window size
#this is used for all global position math
@export var viewport_height: float = 648;
@export var viewport_width: float = 1152;

#this is tied to the card node via UID
#card node can be moved anywhere in the project this way
const CARD_NODE: PackedScene = preload("uid://biy8302fr2vdu");

const DEFAULT_CARD_Z_INDEX: int = 1;
const CARD_SELECTED_Z_INDEX: int = 99;
const CARD_DRAGGING_Z_INDEX: int = 999;

#testing coords for where cards will first generate
@onready var draw_coordinates: Marker2D = %DrawCoordinates
#testing coords for where cards will move to on discard
@onready var discard_coordinates: Marker2D = %DiscardCoordinates

@export_category("Hand Constants")

## The amount of cards dealt at start
@export var starting_deck_number: int = 20;

## The max amount of cards held in hand at one time
@export var max_hand_size: int = 9;

@export_category("Hand Position")
## Offset in pixels of the hand 
## from the bottom of the screen
@export var hand_y_offset_margin: int = 128;

@export var hand_horizontal_percentage = 0.50;

@export_category("Card Properties")
## Adjusts the starting scale of the card without any
## modifications to its size (ie, hover, select, drag, etc)
@export var default_card_scale: float = 0.5;

@export_category("Deck Manipulation")

@export_subgroup("Animation")
## Duration (in seconds) for cards to move to and fro from the deck, ie
## if a card is moved, discarded, dragged etc
@export var manipulation_duration: float = 0.2;
@export var manipulation_transition: Tween.TransitionType = Tween.TRANS_QUAD;
@export var manipulation_easing: Tween.EaseType = Tween.EASE_IN_OUT;

@export_category("Card Selection")

## Adjusts how far a card moves on the y-axis
## when selected.
@export var selected_y_offset: int = -32 

@export_subgroup("Animation")
## Duration (in seconds) of tween for selection animation (when clicking a card)
@export var selection_duration: float = 0.2
@export var selection_transition: Tween.TransitionType = Tween.TRANS_QUAD;
@export var selection_easing: Tween.EaseType = Tween.EASE_IN_OUT;


@export_category("Click and Drag")

## How long (in seconds) the user needs to hold down the select button
## until the cards starts following the mouse (dragging)
@export var time_until_dragged: float = 0.5;

## Scale of card being dragged
@export var scale_while_dragging: float = 0.8;
#not an export variable, but used per frame
# to calculate time
var drag_timer: float = 0.0;

@export_subgroup("Animation")
## Duration (in seconds) of tween for drag animation
@export var drag_duration: float = 0.2;
@export var drag_transition: Tween.TransitionType = Tween.TRANS_QUAD;
@export var drag_easing: Tween.EaseType = Tween.EASE_IN_OUT;

@export_category("Play Card")

## Amount of distance the card moves on the y-axis when played
@export var play_y_offset: float = -20;

## How long (in seconds) the card waits before moving on to the next card
@export var play_pause: float = 0.5;

@export_subgroup("Animation")

## Increase in size of card when played
@export var play_scale: float = 1.2

## Duration (in seconds) for the card to play its animations
@export var play_duration: float = 0.2;

@export_category("Card Focus")

## Scale of card while focused
@export var focus_scale: float = 1.2;

@export_subgroup("Animation")
## Duration (in seconds) of tween for focus animation (when hovering over a card)
@export var focus_duration: float = 0.2;
@export var focus_transition: Tween.TransitionType = Tween.TRANS_QUAD;
@export var focus_easing: Tween.EaseType = Tween.EASE_IN_OUT;


@export_category("Card Draw")
## Scale of card as it comes from the deck
@export var initial_draw_scale: float = 0.2;

@export_subgroup("Animation")
## Duration (in seconds) of animation as the card enters the deck. 
## Note: this is just animation of the card.  Card animation movement
## is controlled by the deck manipulation speed variable
@export var draw_animation_duration: float = 0.2;
@export var draw_transition: Tween.TransitionType = Tween.TRANS_QUAD;
@export var draw_easing: Tween.EaseType = Tween.EASE_IN_OUT;

@export_category("Testing")
## Highlights a selected card in this color.  White shows no color
@export var selection_color: Color = Color.WHITE;
## Highlights a dragged card in this color.  White shows no color
@export var drag_color: Color = Color.WHITE;

var card_to_land_on: CardNode;

var is_hovering_over_card: bool = false;


var card_clicked_in_memory: CardNode;
var selected_cards: Array[CardNode] = [];
var player_hand: Array[CardNode] = [];
var discard_pile: Array[CardNode] = [];
var draw_pile: Array[CardNode] = []

var card_width: float;

func _ready() -> void:
	create_draw_pile(starting_deck_number);

func _process(delta: float) -> void:
	if (card_clicked_in_memory):
		drag_timer += delta;
		if (drag_timer > time_until_dragged):
			set_card_drag_properties(card_clicked_in_memory);
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
				if drag_timer < time_until_dragged:
					
					# Only select/deselect if it wasn't dragged
					if card_clicked_in_memory not in selected_cards:
						select_card(card_clicked_in_memory)
						set_card_as_selected(card_clicked_in_memory)
						card_clicked_in_memory = null
						return;
					else:
						deselect_card(card_clicked_in_memory);
						set_card_as_not_selected(card_clicked_in_memory);
						card_clicked_in_memory = null
						return;
						
						
					card_clicked_in_memory = null
					
					drag_timer = 0.0
					update_player_hand_card_positions()
				else:
					set_card_not_dragged_properties(card_clicked_in_memory);
					card_clicked_in_memory = null
					
					drag_timer = 0.0
					var cards_landed_on: Array[CardNode] = raycast_check_for_all_cards();
					if (cards_landed_on.size() == 2):
						swap_card_positions(cards_landed_on[1], cards_landed_on[0]);
					update_player_hand_card_positions();

func select_card(card: CardNode) -> void:
	if card not in selected_cards:
		var selected_cards_copy: Array[CardNode] = selected_cards.duplicate()
		selected_cards_copy.append(card)
		selected_cards = selected_cards_copy;

func deselect_card(card: CardNode) -> void:
	if card in selected_cards:
		var selected_cards_copy: Array[CardNode] = selected_cards.duplicate()
		selected_cards_copy.erase(card)
		selected_cards = selected_cards_copy;

#raycasts
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


# hand manipulation
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

func create_draw_pile(number_of_cards: int):
	for i in range(number_of_cards):
		var card_node: CardNode = CARD_NODE.instantiate();
		var random_value: int = randi_range(100,999);
		card_node.value = random_value;
		draw_pile.append(card_node);
		card_node.scale = Vector2(0, 0);
		self.add_child(card_node);

func add_card_to_draw_pile(card: CardNode):
	var draw_pile_copy: Array[CardNode] = draw_pile.duplicate();
	draw_pile_copy.append(card);
	draw_pile = draw_pile_copy;

func shuffle_discard_pile_into_draw_pile():
	var draw_pile_copy: Array[CardNode] = draw_pile.duplicate();
	var discard_pile_copy: Array[CardNode] = discard_pile.duplicate();
	
	for card: CardNode in discard_pile_copy:
		draw_pile_copy.append(card);
	discard_pile_copy = [];
	
	draw_pile_copy.shuffle();
	
	draw_pile = draw_pile_copy;
	discard_pile = discard_pile_copy;

func draw_card() -> void:
	if (player_hand.size() <= max_hand_size):
		var player_hand_copy: Array[CardNode] = player_hand.duplicate();
		var draw_pile_copy: Array[CardNode] = draw_pile.duplicate();
		
		if (draw_pile_copy.size() > 0):
			var drawn_card: CardNode = draw_pile_copy[-1];
			player_hand_copy.append(drawn_card);
			draw_pile_copy.erase(drawn_card)
			
			draw_pile = draw_pile_copy;
			player_hand = player_hand_copy;
		
			drawn_card.card_focused.connect(_on_card_is_focused.bind());
			drawn_card.card_unfocused.connect(_on_card_is_unfocused.bind());
			
			# get size of card collision shape
			var card_dimensions: Vector2 =  drawn_card.get_card_size();
			card_width = card_dimensions.x * default_card_scale
			
			if (draw_coordinates != null):
				drawn_card.global_position = draw_coordinates.global_position;
			drawn_card.scale = Vector2(default_card_scale, default_card_scale) * initial_draw_scale;
			var tween = get_tree().create_tween();
			tween.tween_property(drawn_card, "scale", Vector2(default_card_scale, default_card_scale), draw_animation_duration).set_trans(draw_transition).set_ease(draw_easing);
			update_player_hand_card_positions();

func play_selected_cards():
	for card: CardNode in player_hand:
		if (card in selected_cards):
			await play_card(card);
	
	await discard_selected_cards();
	update_action.emit("");


func play_card(card: CardNode) -> void:
	var forward_tween: Tween = get_tree().create_tween()
	
	card.z_index = CARD_DRAGGING_Z_INDEX;
	# Move up, scale up, and change color
	forward_tween.parallel().tween_property(card, "modulate", Color.ORANGE, play_duration)
	forward_tween.parallel().tween_property(card, "global_position", card.global_position + Vector2(0, play_y_offset), play_duration)
	forward_tween.parallel().tween_property(card, "scale", Vector2(default_card_scale * play_scale, default_card_scale * play_scale), play_duration)

	await forward_tween.finished;
	
	update_action.emit(str(card.value));

	await get_tree().create_timer(play_pause).timeout;

	var backward_tween: Tween = get_tree().create_tween();
	
	card.z_index = CARD_SELECTED_Z_INDEX;
	backward_tween.parallel().tween_property(card, "global_position", card.global_position + Vector2(0, -play_y_offset), play_duration);
	backward_tween.parallel().tween_property(card, "scale", Vector2(default_card_scale, default_card_scale), play_duration);
	backward_tween.parallel().tween_property(card, "modulate", selection_color, play_duration);

	await backward_tween.finished;

func discard_selected_cards():
	for card: CardNode in selected_cards:
		await discard_card(card);
		await get_tree().create_timer(0.05).timeout

func discard_card(card: CardNode) -> void:
	var player_hand_copy: Array[CardNode] = player_hand.duplicate()
	var selected_cards_copy: Array[CardNode] = selected_cards.duplicate()

	player_hand_copy.erase(card)
	discard_pile.append(card)

	if card in selected_cards_copy:
		selected_cards_copy.erase(card)
		
	card.card_focused.disconnect(_on_card_is_focused);
	card.card_unfocused.disconnect(_on_card_is_unfocused);
	card.modulate = Color.WHITE;

	player_hand = player_hand_copy
	selected_cards = selected_cards_copy

	var discard_location: Vector2 = discard_coordinates.global_position
	var tween: Tween = get_tree().create_tween()
	tween.parallel().tween_property(card, "scale", Vector2(0,0), draw_animation_duration).set_trans(draw_transition).set_ease(draw_easing)
	tween.parallel().tween_property(card, "global_position", discard_location, draw_animation_duration).set_trans(draw_transition).set_ease(draw_easing)

	update_player_hand_card_positions()


#visual manipulation

# this is the constant function that calculates where a card should be
# on the screen after something like a card played, drawn, discarded, etc
func update_player_hand_card_positions() -> void:
	var hand_width = viewport_width * hand_horizontal_percentage
	var card_spacing: float = card_width + (8 * default_card_scale); # Default spacing
	
	# Calculate total width of the cards at normal spacing
	var total_width: float = (player_hand.size() - 1) * card_width
	
	# If the total width exceeds the available hand width, adjust spacing
	if total_width > hand_width and player_hand.size() > 1:
		card_spacing = hand_width / (player_hand.size() - 1);  # Evenly distribute

	for i in player_hand.size():
		var viewport: Vector2 = Vector2(viewport_width, viewport_height);
		var x_center: float = viewport.x / 2;
		var selected_y_offset: float = selected_y_offset if player_hand[i] in selected_cards else 0;
		var y_position: float = viewport.y - hand_y_offset_margin + selected_y_offset;
		
		# Use the new adjusted spacing instead of fixed card_width
		var total_adjusted_width = (player_hand.size() - 1) * card_spacing;
		var card_x_offset: float = x_center + i * card_spacing - total_adjusted_width / 2;
		var new_position = Vector2(card_x_offset, y_position);
		
		# Tween the movement
		var tween: Tween = get_tree().create_tween();
		var card: CardNode = player_hand[i]
		tween.tween_property(card, "global_position", new_position, manipulation_duration).set_trans(manipulation_transition).set_ease(manipulation_easing);
	
		calculate_card_order_z_index();
	
func calculate_card_order_z_index():
	for i in range(player_hand.size()):
		if (player_hand[i] not in selected_cards):
			player_hand[i].z_index = 0;
	
	for i in range(player_hand.size()):
		if (player_hand[i] not in selected_cards):
			player_hand[i].z_index = i+1;

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
	if (card not in selected_cards):
		var tween = get_tree().create_tween()
		tween.tween_property(card, "scale", Vector2(default_card_scale, default_card_scale) * focus_scale, focus_duration).set_trans(focus_transition).set_ease(focus_easing)
		card.z_index = CARD_SELECTED_Z_INDEX + 1;
	
func set_card_unfocused_properties(card: CardNode):
	var tween = get_tree().create_tween();
	tween.tween_property(card, "scale", Vector2(default_card_scale, default_card_scale), focus_duration).set_trans(focus_transition).set_ease(focus_easing)
	calculate_card_order_z_index();
	
func set_card_as_selected(card: CardNode):
	card.z_index = CARD_SELECTED_Z_INDEX;
	var tween = get_tree().create_tween();
	var new_y_position: float = card.global_position.y + selected_y_offset;
	tween.tween_property(card, "global_position:y", new_y_position, selection_duration).set_trans(selection_transition).set_ease(selection_easing);
	card.modulate = selection_color;
	
func set_card_as_not_selected(card: CardNode):
	var new_y_position: float = card.global_position.y - selected_y_offset;
	var tween = get_tree().create_tween();
	tween.tween_property(card, "global_position:y", new_y_position, selection_duration).set_trans(selection_transition).set_ease(selection_easing);
	card.z_index = DEFAULT_CARD_Z_INDEX;
	card.modulate = Color.WHITE;
	
func set_card_drag_properties(card: CardNode):
	card.z_index = CARD_DRAGGING_Z_INDEX;
	card.modulate = drag_color;
	var tween: Tween = get_tree().create_tween();
	tween.tween_property(card, "scale", Vector2(default_card_scale, default_card_scale) * scale_while_dragging, drag_duration).set_trans(drag_transition).set_ease(drag_easing);
	
func set_card_not_dragged_properties(card: CardNode):
	card.modulate = Color.WHITE;
	var tween: Tween = get_tree().create_tween();
	tween.tween_property(card, "scale", Vector2(default_card_scale, default_card_scale) * scale_while_dragging, drag_duration).set_trans(drag_transition).set_ease(drag_easing);
