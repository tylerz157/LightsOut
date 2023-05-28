extends RigidBody2D
@export
var light_only : bool
var grabbed_by = null


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("idle")
	if light_only == true:
		set_collision_mask(35)
	else:
		set_collision_mask(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	if grabbed_by != null:
		self.position = grabbed_by.position
		self.freeze = true
	
	
func grab(grabber):
	grabbed_by = grabber
	
func drop(direction):
	set_linear_velocity(grabbed_by.velocity)
	apply_central_impulse(direction)
	grabbed_by = null
	self.freeze = false
