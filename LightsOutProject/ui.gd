extends Control
var timer = 0
var intro

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for object in get_node("../..").get_children():
		if object.name.contains("Lava"):
			object.death.connect(die)
		if object.name.contains("Goal"):
			object.victory.connect(win)
	
	intro = get_node("../intro")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer < 2:
		timer += delta
	else:
		intro.visible = false
	
	
	if Input.is_action_just_pressed("restart"):
		Global.reset_level()
	
func win():
	Global.next_level()
	
func die():
	Global.reset_level()
	
