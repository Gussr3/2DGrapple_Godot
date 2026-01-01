extends CharacterBody2D

@onready var grapple_cast: RayCast2D = $GrappleCast
@onready var jump_particle = preload("res://Scenes/jump_particle.tscn")

var states = ["WALKING", "JUMPING", "IDLE", "WALLSLIDING"]
var State = states[0]

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
		
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			State = states[0] #set state to walking
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		State = states[2] #set state to IDLE--------------------
		

	move_and_slide()
	
	if velocity.x < 0:
		$CharacterSprite.flip_h = true
	elif velocity.x > 0:
		$CharacterSprite.flip_h = false
	
	
func _process(delta: float) -> void:
	grapple_cast.look_at(get_global_mouse_position())
	grapple()
	jumpEffect(self.global_position)
	wall_slide()
	
	
	
func grapple():
	if Input.is_action_just_pressed("Grapple"):
		if grapple_cast.is_colliding():
			if is_on_floor():
				if !grappling:
					grappling = true
	if grappling == true:
		gravity = Vector2.ZERO
		if get_grapple_point == false:
			grapple_point = grapple_cast.get_collision_point()
			get_grapple_point = true
			
		if grapple_point.distance_to(self.position) > 12:
			if get_grapple_point == true:
				$PlayerAnimations.play("grapple")
				await get_tree().create_timer(0.3).timeout
				self.position = lerp(self.position, grapple_point, 0.2)
				
		else:
			gravity = Vector2(0, 980)
			get_grapple_point = false
			grappling = false
			
		move_and_slide()
		
		
#-------state behaviour-----------------------
	if State == states[0]:
		$PlayerAnimations.play("walk_anim")
	elif State == states[1]:
		$PlayerAnimations.play("jumping")
	if !is_on_floor():
		State = states[1]
	if State == states[2]:
		gravity = Vector2(0, 980)
		$PlayerAnimations.play("idle")
		
func jumpEffect(pos : Vector2):
	var jumpPos
	if Input.is_action_just_pressed("Jump") and $JumpCast.is_colliding():
		jumpPos = get_parent().global_position
		var jump_particle_instance = jump_particle.instantiate()
		jump_particle_instance.global_position = pos - Vector2(0, -5)
		jump_particle_instance.emitting = true
		get_parent().add_child(jump_particle_instance)
		
func wall_slide():
	if $LeftRay.is_colliding():
		State = states[3]
		
	elif !$LeftRay.is_colliding():
		State = states[2]
		gravity = Vector2(0, 980)
	if $RightRay.is_colliding():
		State = states[3]
		
	elif !$RightRay.is_colliding():
		State = states[2]
		gravity = Vector2(0, 980)
	
	if State == states[3] and !is_on_floor():
		gravity = Vector2(0, 5)
		grappling = false
	
