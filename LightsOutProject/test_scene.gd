extends Node2D

var marker = preload("res://marker.tscn")
var ground_verts = []
var draw_verts = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# find all the walls in level and get vertices
	for ground in find_children("Ground*"):
		var gpos = ground.position
		var gscale = ground.scale
		var rect = ground.get_node("CollisionShape2D").shape.get_rect()
		
		# get vectors from center of obj to rectangle corners
		var corners = []
		corners.append(Vector2((rect.size[0] * gscale[0])/2, (rect.size[1] * gscale[1])/2))
		corners.append(Vector2(-(rect.size[0] * gscale[0])/2, (rect.size[1] * gscale[1])/2))
		corners.append(Vector2(-(rect.size[0] * gscale[0])/2, -(rect.size[1] * gscale[1])/2))
		corners.append(Vector2((rect.size[0] * gscale[0])/2, -(rect.size[1] * gscale[1])/2))
		
		# set markers on the corners to show it is the right spot
		#for i in range(4):
		#	var mark = marker.instantiate()
		#	mark.set_position(Vector2(corners[i-1][0] + gpos[0], corners[i-1][1] + gpos[1]))
		#	add_child(mark)
		
		# add to global var to access during updates
		ground_verts.append([ground, corners])
	print(ground_verts)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _physics_process(delta):
	# clear draw
	draw_verts = []
	
	# select which light rays are actually important
	for object in ground_verts:
		
		var space_state = get_world_2d().direct_space_state
		# make corner to vectors to corners
		var gpos = object[0].position
		for corner in object[1]:
			var vect = Vector2(corner[0] + gpos[0], corner[1] + gpos[1])
			var query = PhysicsRayQueryParameters2D.create($Player.position, vect)
			query.exclude = [$Player]
			var result = space_state.intersect_ray(query)
			if result == {}:
				draw_verts.append(vect)
			elif result != null:
				if (result.position - vect).length() <= 1:
					draw_verts.append(vect)

# draw relevant light rays
func _draw():
	for vertex in draw_verts:	
		draw_line($Player.position, vertex, Color(1,1,1))
			
			
			
# shape of desired database:
# object: vertices related to center, vectors that form edges
