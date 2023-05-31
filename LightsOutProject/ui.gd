extends Control
var goal

# Called when the node enters the scene tree for the first time.
func _ready():
	goal = get_node("../../Goal")
	goal.victory.connect(win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func win():
	$Winner.visible = true
	Global.next_level()
