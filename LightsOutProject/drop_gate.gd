extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_entered(area):
	print(area.get_parent().name)
	if area.get_parent().name == "Player":
		var dropped_obj = area.get_parent().drop()
	if(area.get_collision_layer() == 8):
		if area.get_parent().grabbed_by != null:
			area.get_parent().grabbed_by.drop()
		area.get_parent().set_linear_velocity(Vector2(area.get_parent().position.x - self.position.x,0)*5 + Vector2.UP*200)
