extends Node2D

var marker = preload("res://marker.tscn")
var light_wall = preload("res://light_wall.tscn")
var lantern
var ground_verts = []
var draw_verts = []

var test_draw = []
var test_red = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	lantern = $lantern
	
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
		
		# add to global var to access during updates
		var collider = [null, null, null, null]
		ground_verts.append([ground, corners, collider])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _physics_process(delta):
	# clear draw
	draw_verts = []
	test_draw = []
	test_red = []
	
	var mouse = get_viewport().get_mouse_position()
	lantern.position = mouse
	
	# select which light rays are actually important and make colliders
	for object in ground_verts:
		
		var space_state = get_world_2d().direct_space_state
		var ground = object[0]
		var corners = object[1]
		var collider = object[2]
		
		# make corner to vectors to corners
		var gpos = ground.position
		for i in range(len(corners)):
			var vect = Vector2(corners[i-1][0] + gpos[0], corners[i-1][1] + gpos[1])
			var edge1 = corners[i%len(corners)] - corners[i-1]
			var edge2 = corners[(i-2)%len(corners)] - corners[i-1]
			
			var light_ray = vect - lantern.position
			var query = PhysicsRayQueryParameters2D.create(lantern.position, vect)
			query.exclude = [$Player, lantern]
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
							
			# check if relevant
			if blocked == false and solid == false:
				# if yes, move or make collider
				draw_verts.append(vect)
				
				# physics collision to find end point
				var query2 = PhysicsRayQueryParameters2D.create(vect + light_ray.normalized()*1, vect + light_ray.normalized()*2000)
				query2.exclude = [$Player, lantern]
				var result2 = space_state.intersect_ray(query2)
				
				# if it collides...
				if result2 != null:
					var segment = SegmentShape2D.new()
					segment.a = vect
					segment.b = result2.position
					
					# check if vectex has a light wall yet
					if(collider[i-1] == null):
						# make collider
						collider[i-1] = light_wall.instantiate()
						add_child(collider[i-1])
					# move position
					collider[i-1].get_node("CollisionShape2D").shape = segment
					
			# if no, delete collider if there is one
			else:
				if(collider[i-1] != null):
					collider[i-1].queue_free()
					collider[i-1] = null
	
	
	
	# make and move collisions
	
	# loop through all rays
	# check if the ray is relevant
	# if it is, draw a raycast from the vertex and extend it past in the same direction as the ray
	# once end point is found...
	# check if vertex has a collider
	# if not, make one and set it to vertex and end point
	# if already has, then move the end point to new end point
	# if ray is not relevant, delete collider
	
# draw relevant light rays
func _draw():
	for vertex in draw_verts:	
		draw_line(lantern.position, vertex, Color(1,1,1), 1)
	for pair in test_draw:
		draw_line(pair[0], pair[1] + pair[0], Color.LIGHT_GREEN, 1)
		draw_circle(pair[1] + pair[0], 1, Color.LIGHT_GREEN)
	for pair in test_red:
		draw_line(pair[0], pair[1] + pair[0], Color.RED, 1)
		draw_circle(pair[1] + pair[0], 1, Color.RED)
	
			
			
			
# shape of desired database:
# [object, [corner, corner...], [active, active,...], [collider, collider,...]],
# [object, [corner, corner...], [active, active,...], [collider, collider,...]],
# [object, [corner, corner...], [active, active,...], [collider, collider,...]],
# [object, [corner, corner...], [active, active,...], [collider, collider,...]]

