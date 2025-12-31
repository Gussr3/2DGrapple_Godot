extends CharacterBody2D

@onready var grapple_cast: RayCast2D = $GrappleCast

var grappling = false
var grapple_point : Vector2
var get_grapple_point : bool = false

const SPEED = 150.0
const JUMP_VELOCITY = -200.0
var gravity = Vector2(0, 980)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _process(delta: float) -> void:
	grapple_cast.look_at(get_global_mouse_position())
	grapple()
	
func grapple():
	if Input.is_action_just_pressed("Grapple"):
		if grapple_cast.is_colliding():
			if !grappling:
				grappling = true
	if grappling == true:
		gravity = Vector2.ZERO
		if get_grapple_point == false:
			grapple_point = grapple_cast.get_collision_point()
			get_grapple_point = true
			
		if grapple_point.distance_to(self.position) > 12:
			if get_grapple_point == true:
				self.position = lerp(self.position, grapple_point, 0.2)
		else:
			gravity = Vector2(0, 980)
			get_grapple_point = false
			grappling = false
			
	print(grapple_point.distance_to(self.position))
			
			
