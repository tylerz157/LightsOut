extends Node2D

var marker = preload("res://marker.tscn")
var ground_verts = []
var draw_verts = []

var test_draw = []
var test_red = []

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
	test_draw = []
	test_red = []
	
	# select which light rays are actually important
	for object in ground_verts:
		
		var space_state = get_world_2d().direct_space_state
		# make corner to vectors to corners
		var gpos = object[0].position
		for i in range(len(object[1])):
			var corners = object[1]
			var vect = Vector2(corners[i-1][0] + gpos[0], corners[i-1][1] + gpos[1])
			var edge1 = corners[i%len(object[1])] - corners[i-1]
			var edge2 = corners[(i-2)%len(object[1])] - corners[i-1]
			
			var light_ray = vect - $Player.position
			var query = PhysicsRayQueryParameters2D.create($Player.position, vect)
			query.exclude = [$Player]
			var result = space_state.intersect_ray(query)
			
			# check if it intersects with anything in front
			var blocked = true
			if result == {}:
				blocked = false
			elif result != null:
				if (result.position - vect).length() <= 1:
					blocked = false
			
			# check if the light is colliding or keeps going afterwards
			var solid = false
			var betweenv1 = (edge1.normalized() - light_ray.normalized()).normalized()
			var betweenv2 = (edge2.normalized() - light_ray.normalized()).normalized()
			var angle = acos(betweenv1.dot(betweenv2))
			
			
			
			# account for floating point error
			if(angle - 0.001 >= PI/4):
				solid = true
				test_red.append([corners[i-1]+gpos, betweenv1*20])
				test_red.append([corners[i-1]+gpos, betweenv2*20])
			else:
				test_draw.append([corners[i-1]+gpos, betweenv1*20])
				test_draw.append([corners[i-1]+gpos, betweenv2*20])
							
			# draw it if its good
			if blocked == false and solid == false:
				draw_verts.append(vect)

# draw relevant light rays
func _draw():
	for vertex in draw_verts:	
		draw_line($Player.position, vertex, Color(1,1,1), 1)
	for pair in test_draw:
		draw_line(pair[0], pair[1] + pair[0], Color.LIGHT_GREEN, 1)
		draw_circle(pair[1] + pair[0], 1, Color.LIGHT_GREEN)
	for pair in test_red:
		draw_line(pair[0], pair[1] + pair[0], Color.RED, 1)
		draw_circle(pair[1] + pair[0], 1, Color.RED)
	
			
			
			
# shape of desired database:
# object: vertices related to center, vectors that form edges
