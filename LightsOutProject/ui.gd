extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for object in get_node("../..").get_children():
		if object.name.contains("Lava"):
			object.death.connect(die)
		if object.name.contains("Goal"):
			object.victory.connect(win)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("restart"):
		Global.reset_level()
	
func win():
	$Winner.visible = true
	Global.next_level()
	
func die():
	Global.reset_level()
	
