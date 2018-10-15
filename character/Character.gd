extends KinematicBody2D

# This demo shows how to build a kinematic controller.

# Member variables
const GRAVITY = 1000.0 # pixels/second/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_BACK_FORCE = 300
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 200
const WALK_BACK_MAX_SPEED = 100
const STOP_FORCE = 1300
const JUMP_SPEED = 600
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # one pixel/second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # one pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false
var on_floor = false
var on_wall = false

var prev_jump_pressed = false

onready var left_hand = get_node("Body/LeftArm/Fore/Hand/Position2D")
onready var right_hand = get_node("Body/RightArm/Fore/Hand/Position2D")
onready var head = get_node("Body/Neck/Head")
func equip_right(item):
	item.get_parent().remove_child(item)
	item.transform = Transform2D()
	right_hand.add_child(item) 
	
func equip_left(item):
	item.get_parent().remove_child(item)
	item.transform = Transform2D()
	left_hand.add_child(item) 
	
const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1
var facing_direction = DIRECTION_RIGHT
func update_facing_direction():
	var mpos = get_global_mouse_position()
	head.look_at(mpos)
	var dir = sign(mpos.x - global_position.x)
	if dir == 0:
		dir = facing_direction 
	apply_scale(Vector2(dir*facing_direction, 1)) # flip
	facing_direction = dir

func process_attack():
	var try_attack = Input.is_action_just_pressed("game_attack")
	if not try_attack:
		return
	
	var mpos = get_global_mouse_position()
	$Body/Torso/RemoteRightArm.look_at(mpos)
	print("attack vector", (mpos - global_position).normalized())
	

func _physics_process(delta):
	
	var walk_left = Input.is_action_pressed("game_left")
	var walk_right = Input.is_action_pressed("game_right")
	var try_jump = Input.is_action_pressed("game_jump")
	var crouch = Input.is_action_pressed("game_down")
	
	update_facing_direction()
	process_attack()
	
	var force = Vector2(0, GRAVITY)
	if $FloorDetect.is_colliding():
		force = $FloorDetect.get_collision_normal() * -GRAVITY
	
	
	var stop = true

	if walk_left:
		if velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED:
			force.x -= WALK_FORCE
			stop = false
	elif walk_right:
		if velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED:
			force.x += WALK_FORCE
			stop = false
	
	var vlen = abs(velocity.x)
	var move_direction = 0;
	if vlen > 1:
		move_direction = sign(velocity.x)
	
	if stop:
		vlen -= STOP_FORCE * delta
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * move_direction
	
	if vlen > 0.1:
		if move_direction != facing_direction:
			$AnimationPlayer.animate("backwards")
		else:
			$AnimationPlayer.animate("run")
			 
	elif crouch:
		$AnimationPlayer.animate("crouch")
	else:
		$AnimationPlayer.animate("idle")
		
	
	
	# Integrate forces to velocity
	velocity += force * delta	
	# Integrate velocity into motion and move
	velocity = move_and_slide(velocity, Vector2(0, -1))

	on_floor = is_on_floor()
	on_wall = is_on_wall()
	
	if on_floor:
		on_air_time = 0
		
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if on_air_time < JUMP_MAX_AIRBORNE_TIME and try_jump and not prev_jump_pressed and not jumping:
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		velocity.y = -JUMP_SPEED
		jumping = true
	
	on_air_time += delta
	prev_jump_pressed = try_jump
