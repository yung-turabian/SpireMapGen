class_name Map extends Node

var room_texture = preload( "res://icon.svg" );
var shader = preload( "res://tint.gdshader" );
@onready var rooms_conatiner = $Rooms;
@onready var visual_gen_timer = $GenVisual;
var rng: RandomNumberGenerator;
var unique_trailheads := 0;

const NUMBER_OF_FLOORS := 15;
const NUMBER_OF_ROOMS_PER_FLOOR := 7;
var SPACE_BETWEEN := DisplayServer.window_get_size().x / ( NUMBER_OF_ROOMS_PER_FLOOR + 1 );
var current_state := 0;

class Room extends Node:
	var x: int;
	var y: int;
	var visual: Sprite2D;
	var visited := false;
	var acutal_position: Vector2;
	func _init( _x: int, _y: int, texture: Texture2D, scale ) -> void:
		x = _x;
		y = _y;
		acutal_position = Vector2( (x + 1) * scale, DisplayServer.window_get_size().y - (y * scale) );
		visual = Sprite2D.new();
		visual.texture = texture;
		visual.scale = Vector2( 0.25, 0.25 );
		visual.position = acutal_position;

func GetRoom( x: int, y: int ) -> Room:
	if x < 0 or x >= NUMBER_OF_ROOMS_PER_FLOOR or y < 0 or y >= NUMBER_OF_FLOORS:
		return null;
	return rooms[y * NUMBER_OF_ROOMS_PER_FLOOR + x];

# Vertices
var rooms: Array[Room] = [];


# Map Template

func _ready() -> void:
	# Setup
	rng = RandomNumberGenerator.new();
	
	for i in range( 0, NUMBER_OF_FLOORS * NUMBER_OF_ROOMS_PER_FLOOR ):
		var x := i % NUMBER_OF_ROOMS_PER_FLOOR;
		var y := i / NUMBER_OF_ROOMS_PER_FLOOR;
		var new_room = Room.new( x, y, room_texture, SPACE_BETWEEN );
		rooms.append( new_room );
		rooms_conatiner.add_child( new_room.visual )
	
	visual_gen_timer.start( 1.0 );


# TODO Could benefit from more DFS-related logic.
func GeneratePath( color: Color ):
	var path: Array[Room] = [];

	# Only perform this operation for 1st floor, twice.
	var last_room: Room;
	
	if unique_trailheads < 2:
		var available_rooms: Array[int] = [];
		for i in range( 0, NUMBER_OF_ROOMS_PER_FLOOR ):
			if !rooms[i].visited:
				available_rooms.append( i );
		last_room = rooms[available_rooms[rng.randi_range( 0, available_rooms.size() - 1 )]];
		unique_trailheads += 1;
		print( "Created a unique trailhead." );
	else:
		last_room = rooms[rng.randi_range( 0, NUMBER_OF_ROOMS_PER_FLOOR - 1 )];
	last_room.visual.modulate = color;
	last_room.visited = true;
	path.append( last_room );
	
	
	for floor in range( 1, NUMBER_OF_FLOORS ):
		var idx := last_room.x + ( (floor - 1) * NUMBER_OF_ROOMS_PER_FLOOR );
		var nidx := last_room.x + ( floor * NUMBER_OF_ROOMS_PER_FLOOR );
		var l: int;
		var r: int;
		
		if last_room.x == 0:
			# Prevent paths from crossing one another
			if rooms[idx + 1].visited and rooms[nidx].visited:
				l = 0; r = 0;
			else:
				l = 0; r = 1;
				
		elif last_room.x == ( NUMBER_OF_ROOMS_PER_FLOOR - 1 ):
			if rooms[idx - 1].visited and rooms[nidx].visited:
				l = 0; r = 0;
			else:
				l = -1; r = 0;
				
		else:
			if (rooms[idx - 1].visited or rooms[idx + 1].visited) \
			   and rooms[nidx].visited:
				l = 0; r = 0;
			else:
				l = -1; r = 1;

				
		#if rooms[last_room.x + 1].visited and (rooms[starting].visited or rooms[starting].visited):
		#	l = 0; r = 0;
		var next_room := rooms[rng.randi_range( nidx + l, 
												nidx + r )];
		next_room.visited = true;
		next_room.visual.modulate = color;

		path.append( next_room );
		
		last_room = next_room;
		
		var path_visual := Path2D.new();
		var curve := Curve2D.new();
		var line := Line2D.new();

		for node in path:
			curve.add_point( node.acutal_position );
		
		path_visual.set_curve( curve );
		line.default_color = color;
		line.points = curve.get_baked_points();
	
		add_child( line );



func _on_gen_visual_timeout() -> void:
	match current_state:
		0:
			var colors := [Color.RED, Color.GREEN, Color.YELLOW, Color.BLUE, Color.PURPLE];
			for i in range( 0, 5, 1 ):
				GeneratePath( Color( colors[i], 0.65 ) );
			current_state += 1;
			visual_gen_timer.start( 1.0 );
		1:
			var used_rooms: Array[Room] = [];
			for i in range( rooms.size() -1, -1, -1 ):
				var room = rooms[i];
				if not room.visited:
					if is_instance_valid( room.visual ):
						room.visual.get_parent().remove_child( room.visual )
						room.visual.queue_free();
					rooms.remove_at(i);
				else:
					used_rooms.append( room );

			rooms = used_rooms;
			rooms.reverse();
			visual_gen_timer.stop();
