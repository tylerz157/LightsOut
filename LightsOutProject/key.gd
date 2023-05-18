extends RigidBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var grabbed = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		apply_impulse(Vector2(0, -500))
	
	if grabbed != null:
		self.position = grabbed.position
	
func grab(object):
	grabbed = object
	
