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
		var collider_polygon = []
		
		# find the bad vertex (obtuse bisector)
		for i in range(len(vertices)):
			var edge1 = vertices[(i+1)%len(vertices)] - vertices[i]
			var edge2 = vertices[(i-1)%len(vertices)] - vertices[i]
			var light_ray = vertices[i] - lantern.position
			
			var solid = false
			var betweenv1 = (edge1.normalized() - light_ray.normalized()).normalized()
			var betweenv2 = (edge2.normalized() - light_ray.normalized()).normalized()
			var angle = acos(betweenv1.dot(betweenv2))

			
			# account for floating point error
			if(angle - 0.001 >= PI/4):
				solid = true
				test_red.append([vertices[i], betweenv1*20])
				test_red.append([vertices[i], betweenv2*20])
			else:
				test_draw.append([vertices[i], betweenv1*20])
				test_draw.append([vertices[i], betweenv2*20])
				
		# find raycast end positions of other vertices 
			if(solid == false):
				collider_points.append(vertices[i])
				test_points.append(vertices[i])
				var query = PhysicsRayQueryParameters2D.create(vertices[i] + light_ray.normalized()*1, vertices[i] + light_ray.normalized()*2000)
				query.exclude = excluded_obj
				var result = space_state.intersect_ray(query)
				if result != null:
					if result.size() != 0:
						test_points.append(result.position)
						collider_points.append(result.position)
						
		# move collider to verticies and end position locations
		collider_polygon = collider_points
		collider.get_node("CollisionPolygon2D").set_polygon(collider_polygon)
#
#		# make corner to vectors to corners
#		var gpos = ground.position
#		for i in range(len(corners)):
#			var vect = Vector2(corners[i-1][0] + gpos[0], corners[i-1][1] + gpos[1])
#			var edge1 = corners[i%len(corners)] - corners[i-1]
#			var edge2 = corners[(i-2)%len(corners)] - corners[i-1]
#
#			var light_ray = vect - lantern.position
#			var query = PhysicsRayQueryParameters2D.create(lantern.position, vect)
#			query.exclude = ray_exclude
#			var result = space_state.intersect_ray(query)
#
#			# check if it intersects with anything in front
#			var blocked = true
#			if result == {}:
#				blocked = false
#			elif result != null:
#				if (result.position - vect).length() <= 1:
#					blocked = false
#
#			# check if the light is colliding or keeps going afterwards
#			var solid = false
#			var betweenv1 = (edge1.normalized() - light_ray.normalized()).normalized()
#			var betweenv2 = (edge2.normalized() - light_ray.normalized()).normalized()
#			var angle = acos(betweenv1.dot(betweenv2))
#
#			# account for floating point error
#			if(angle - 0.001 >= PI/4):
#				solid = true
#				test_red.append([corners[i-1]+gpos, betweenv1*20])
#				test_red.append([corners[i-1]+gpos, betweenv2*20])
#			else:
#				test_draw.append([corners[i-1]+gpos, betweenv1*20])
#				test_draw.append([corners[i-1]+gpos, betweenv2*20])
#
#			# check if relevant
#			if blocked == false and solid == false:
#				# if yes, move or make collider
#				draw_verts.append(vect)
#
#				# physics collision to find end point
#				var query2 = PhysicsRayQueryParameters2D.create(vect + light_ray.normalized()*1, vect + light_ray.normalized()*2000)
#				query2.exclude = ray_exclude
#				var result2 = space_state.intersect_ray(query2)
#
#				# if it collides...
#				if result2 != null:
#					if result2.size() != 0:
#						var segment = SegmentShape2D.new()
#						segment.a = vect
#						segment.b = result2.position
#
#						# check if vectex has a light wall yet
#						if(collider[i-1] == null):
#							# make collider
#							collider[i-1] = light_wall.instantiate()
#							add_child(collider[i-1])
#						# move position
#						collider[i-1].get_node("CollisionShape2D").shape = segment
#
#			# if no, delete collider if there is one
#			else:
#				if(collider[i-1] != null):
#					collider[i-1].queue_free()
#					collider[i-1] = null
	
	
	
	# make and move collisions
	
	# setup:
	# loop through every object and determine if it casts light rays.
	# if ground, add to list, if border, dont, neither, add to raycast ignore list
	# if lantern, assign it to the light source
	# set up database and colliders (interact with just player rn)
	
	# loop:
	# loop through each light object
	# find the bad vertex (obtuse bisector)
	# find raycast end positions of other vertices 
	# move collider to verticies and end position locations

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
	
			
			
			
# shape of desired database:
# [object, [corner, corner...], [active, active,...], [collider, collider,...]],
# [object, [corner, corner...], [active, active,...], [collider, collider,...]],
# [object, [corner, corner...], [active, active,...], [collider, collider,...]],
# [object, [corner, corner...], [active, active,...], [collider, collider,...]]

