extends StaticBody2D
var border_expansion = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var inlevel_size = Vector2(32*$texture.scale.x*self.scale.x, 32*$texture.scale.x*self.scale.y)
	var border_size = Vector2(inlevel_size.x + border_expansion, inlevel_size.y + border_expansion)
	var border_rescale = Vector2(border_size.x/self.scale.x/32, border_size.y/self.scale.y/32)
	
	$outline.scale = border_rescale
	
	# correct code, but i think it runs the light manager first, which causes this to adjust after and shift everything over
	# $CollisionShape2D.scale = border_rescale/4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
