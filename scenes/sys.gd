extends Node

@onready var camera = $Cam;
@onready var map = $Map;

const CAMERA_MAX_SPEED := 6.0;
const CAMERA_DEACCELERATION := 4.0;
const CAMERA_ACCELERATION := 500.0;

var HEIGHT := DisplayServer.window_get_size().y;
@onready var TOP: int = -1 * ( map.NUMBER_OF_FLOORS - 2 ) * map.SPACE_BETWEEN;
var camera_velocity = Vector2( 0, 0 );

func _ready() -> void:
	camera.offset.y = HEIGHT * 0.75;


func _process( delta: float ) -> void:
	var moving := false;
	if Input.is_action_pressed( "Up" ) and camera_velocity.y > -CAMERA_MAX_SPEED:
		camera_velocity.y -= CAMERA_ACCELERATION * delta;
		moving = true;
	elif Input.is_action_just_released( "Up" ) and camera_velocity.y > -CAMERA_MAX_SPEED:
		camera_velocity.y -= CAMERA_ACCELERATION * delta;
		moving = true;
	elif Input.is_action_pressed( "Down" ) and camera_velocity.y < CAMERA_MAX_SPEED:
		camera_velocity.y += CAMERA_ACCELERATION * delta;
		moving = true;
	elif Input.is_action_just_released( "Down" ) and camera_velocity.y < CAMERA_MAX_SPEED:
		camera_velocity.y += CAMERA_ACCELERATION * delta;
		moving = true;

		
	if not moving:
		camera_velocity.y = lerp( camera_velocity.y, 0.0, CAMERA_DEACCELERATION * delta );
	
	camera.offset.y += camera_velocity.y;
	camera.offset.y = clamp( camera.offset.y, TOP, HEIGHT );
