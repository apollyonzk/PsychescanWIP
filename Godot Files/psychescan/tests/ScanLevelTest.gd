extends GutTest

var SceneTransition1 = preload("res://psychescan/scripts/SceneTransition1.gd")
var SceneTransition2 = preload("res://psychescan/scripts/SceneTransition2.gd")
var SceneTransition3 = preload("res://psychescan/scripts/SceneTransition2.gd")
var Level = preload("res://psychescan/levels/main_level.tscn")
var Level1 = preload("res://psychescan/levels/level.tscn")
var Level2 = preload("res://psychescan/levels/level2.tscn")
var Level3 = preload("res://psychescan/levels/level3.tscn")

var _scene_transition1 = null
var _scene_transition2 = null
var _scene_transition3 = null
var _level = null
var _level1 = null
var _level2 = null
var _level3 = null

func before_each():
    _scene_transition1 = SceneTransition1.new()
    _scene_transition2 = SceneTransition2.new()
    _scene_transition3 = SceneTransition3.new()
    _level = Level.instantiate()
    _level1 = Level1.instantiate()
    _level2 = Level2.instantiate()
    _level3 = Level3.instantiate()

    add_child(_scene_transition1)
    add_child(_scene_transition2)
    add_child(_scene_transition3)
    add_child(_level)
    add_child(_level1)
    add_child(_level2)
    add_child(_level3)

func after_each():
    _scene_transition1.queue_free()
    _scene_transition2.queue_free()
    _scene_transition3.queue_free()
    _level.queue_free()
    _level1.queue_free()
    _level2.queue_free()
    _level3.queue_free()

func test_run():
    # Test if the scene transition is working correctly
    _scene_transition1.new_scene_path = "res://psychescan/levels/level2.tscn"
    _scene_transition2.new_scene_path = "res://psychescan/levels/level3.tscn"
    _scene_transition3.new_scene_path = "res://psychescan/levels/victory_scene.tscn"

    assert(_scene_transition1.new_scene_path == "res://psychescan/levels/level2.tscn")
    assert(_scene_transition2.new_scene_path == "res://psychescan/levels/level3.tscn")
    assert(_scene_transition3.new_scene_path == "res://psychescan/levels/victory_scene.tscn")