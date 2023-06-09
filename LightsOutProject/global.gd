extends Node

var current_scene = null
var current_scene_num = -1
var max_scene = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func next_level():
	current_scene_num += 1
	if current_scene_num == max_scene:
		current_scene_num = -1
		call_deferred("_deferred_goto_scene", "res://win_screen.tscn")
	else:
		call_deferred("_deferred_goto_scene", "res://level_" + str(current_scene_num) + ".tscn")
	
func reset_level():
	call_deferred("_deferred_goto_scene", "res://level_" + str(current_scene_num) + ".tscn")
	
func go_main_menu():
	call_deferred("_deferred_goto_scene", "res://main_menu.tscn")


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
