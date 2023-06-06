extends CharacterBody2D

enum State {FREE, HOLDING}
var held_obj = null
const SPEED = 300.0
const JUMP_VELOCITY = -300.0
var push_force = 75
var is_jump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("jump")
		is_jump = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if(is_jump == true):
		pass
	elif(velocity == Vector2(0,0)):
		$AnimatedSprite2D.play("idle")
	elif(velocity.x > 0):
		$AnimatedSprite2D.play("move_right")
		$AnimatedSprite2D.flip_h = false
	elif(velocity.x < 0):
		$AnimatedSprite2D.play("move_right")
		$AnimatedSprite2D.flip_h = true
#
	if(is_on_floor()):
		is_jump = false
	
	# grab object
	if Input.is_action_just_pressed("grab"):
		# if already holding something, let go
		if held_obj != null:
			held_obj.get_parent().drop(direction)
			held_obj = null
		# grab something
		else:
			# find collision
			var collisions = $Area2D.get_overlapping_areas()
			var grab_obj = null
			for i in range(len(collisions)):
				if(collisions[i-1].get_collision_layer() == 8):
					grab_obj = collisions[i-1]
			if grab_obj != null:
				grab_obj.get_parent().grab(self)
				held_obj = grab_obj
	
	# push other objects around
	# source: https://ask.godotengine.org/147759/how-to-push-a-rigidbody2d-with-a-characterbody2d
	if self.move_and_slide(): # true if collided
		for i in self.get_slide_collision_count():
			var col = self.get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().set_linear_velocity(col.get_normal() * -push_force)
				#col.get_collider().add_constant_force(col.get_normal() * -push_force)

func drop():
	var obj = held_obj
	if held_obj != null:
		held_obj.get_parent().drop(0)
		held_obj = null
	if(obj != null):
		return obj.get_parent()
			
			
			
