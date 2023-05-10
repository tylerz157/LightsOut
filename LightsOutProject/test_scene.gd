extends Node2D

var marker = preload("res://marker.tscn")
var ground_verts = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# find all the walls in level and get vertices
	for ground in find_children("Ground*"):
		var gpos = ground.position
		var gscale = ground.scale
		var rect = ground.get_node("CollisionShape2D").shape.get_rect()
		
		# get vectors from center of obj to rectangle corners
		var corners = []
		corners.append(Vector2((rect.size[0] * gscale[0])/2 + gpos[0], (rect.size[1] * gscale[1])/2 + gpos[1]))
		corners.append(Vector2(-(rect.size[0] * gscale[0])/2 + gpos[0], (rect.size[1] * gscale[1])/2 + gpos[1]))
		corners.append(Vector2(-(rect.size[0] * gscale[0])/2 + gpos[0], -(rect.size[1] * gscale[1])/2 + gpos[1]))
		corners.append(Vector2((rect.size[0] * gscale[0])/2 + gpos[0], -(rect.size[1] * gscale[1])/2 + gpos[1]))
		
		for i in range(4):
			var mark = marker.instantiate()
			mark.set_position(Vector2(corners[i-1][0], corners[i-1][1]))
			add_child(mark)
		
		ground_verts.append(corners)
	print(ground_verts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	
func _draw():
	for corners in ground_verts:
		for corner in corners:	
			draw_line($Player.position, corner, Color(1,1,1))
