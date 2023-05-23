extends Node2D

var light_wall = preload("res://light_wall.tscn")
var excluded_obj = []
var lantern
var shadowcast_obj = []

var draw_verts = []
var test_draw = []
var test_red = []
var test_points = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# setup:
	print(get_parent().get_children())
	# loop through every object and determine if it casts light rays.
	for object in get_parent().get_children():
		# if ground, add to list, if border, dont, neither, add to raycast ignore list
		print(object.get_name())
		if(object.get_name().contains("Ground")):
			print('found ground')
			var opos = object.position
			var oscale = object.scale
			var rect = object.get_node("CollisionShape2D").shape.get_rect()
			
			# get vectors for vertex positions
			var vertices = []
			vertices.append(Vector2(opos.x + (rect.size[0] * oscale[0])/2, opos.y + (rect.size[1] * oscale[1])/2))
			vertices.append(Vector2(opos.x - (rect.size[0] * oscale[0])/2, opos.y + (rect.size[1] * oscale[1])/2))
			vertices.append(Vector2(opos.x - (rect.size[0] * oscale[0])/2, opos.y - (rect.size[1] * oscale[1])/2))
			vertices.append(Vector2(opos.x + (rect.size[0] * oscale[0])/2, opos.y - (rect.size[1] * oscale[1])/2))
			
			# set up database
			var collider = light_wall.instantiate()
			add_child(collider)
			collider.collision_layer = 32
			collider.collision_mask = 4
			shadowcast_obj.append([object, vertices, collider])
			
		# if border, do nothing
		elif(object.get_name().contains("wall")):
			pass
		
		# any other object, add to excluded	
		else:
			# if lantern, assign it to the light source
			if(object.get_name().contains("Lantern")):
				lantern = object
			excluded_obj.append(object)
			
	print(excluded_obj)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _physics_process(delta):
	# clear draw
	draw_verts = []
	test_draw = []
	test_red = []
	test_points = []
	
	# loop:
	
	# loop through each light object
	for object in shadowcast_obj:
		var space_state = get_parent().get_world_2d().direct_space_state
		var obj_node = object[0]
		var vertices = object[1]
		var collider = object[2]
		# vertex order: ray vertex, ray end, next end.., ray end2, ray vertex2, vertex going back
		var collider_points = []
		
		# find important vertices (edges with light rays)
		for i in range(len(vertices)):
			var edge1 = vertices[(i+1)%len(vertices)] - vertices[i]
			var edge2 = vertices[(i-1)%len(vertices)] - vertices[i]
			var light_ray = vertices[i] - lantern.position
			
			# find if ray creates an obtuse angle (vertex is in the light)
			var in_light = false
			var betweenv1 = (edge1.normalized() - light_ray.normalized()).normalized()
			var betweenv2 = (edge2.normalized() - light_ray.normalized()).normalized()
			var angle = acos(betweenv1.dot(betweenv2))
			
			# find if ray creates an acute angle (vertex is in the shadow)
			var in_shadow = false
			var bisector = (edge1.normalized() + edge2.normalized()).normalized()
			var angle2 = acos(bisector.dot((-light_ray).normalized()))
			
			# identify good light rays
			if(angle + 0.001 >= 3*PI/4):
				in_light = true
				test_red.append([vertices[i], betweenv1*20])
				test_red.append([vertices[i], betweenv2*20])
			elif(angle2 - 0.001 <= PI/4):
				in_shadow = true
				test_red.append([vertices[i], bisector*20])
			else:
				test_draw.append([vertices[i], betweenv1*20])
				test_draw.append([vertices[i], betweenv2*20])
				
			# find raycast end positions of vertices 
			if(in_light == false):
				var end_query = PhysicsRayQueryParameters2D.create(vertices[i] + light_ray.normalized()*1, vertices[i] + light_ray.normalized()*2000)
				end_query.exclude = excluded_obj
				var end_result = space_state.intersect_ray(end_query)
				if end_result != null:
					if end_result.size() != 0:
						test_points.append(end_result.position)
						collider_points.append(end_result.position)
			
			# only add vertex if it is a good light ray
			if(in_light == false and in_shadow == false):
				collider_points.append(vertices[i])
				test_points.append(vertices[i])
						
		# move collider to verticies and end position locations
		# find centroid
		if(len(collider_points) > 0):
			var cent_x = 0
			var cent_y = 0
			var centroid = Vector2.ZERO
			for point in collider_points:
				cent_x += point.x
				cent_y += point.y
			centroid = Vector2(cent_x/len(collider_points), cent_y/len(collider_points))
			test_points.append(centroid)
			
			# order vertices by going clockwise/counterclockwise around centroid
			# turn into heap later 
			var collider_polygon = []
			for i in range(len(collider_points)):
				var smallest_angle = collider_points[0]
				for point in collider_points:
					if Vector2.UP.angle_to(point - centroid) < Vector2.UP.angle_to(smallest_angle - centroid):
						smallest_angle = point
				collider_polygon.append(smallest_angle)
				collider_points.erase(smallest_angle)
			
			collider.get_node("CollisionPolygon2D").set_polygon(collider_polygon)
		
		
		
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
	for point in test_points:
		draw_circle(point, 5, Color.BLANCHED_ALMOND)
