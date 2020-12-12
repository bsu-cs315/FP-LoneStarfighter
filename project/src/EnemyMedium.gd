extends KinematicBody2D

signal destroyed
signal in_stage

var rng := RandomNumberGenerator.new()
var is_on_path := false
var is_in_area := false
var can_fire := false
var can_move := true
var velocity := Vector2.ZERO
var path_points := []


onready var start_pos := position
onready var enemy_move := EnemyMovement.new(start_pos)

func _ready()->void:
	if get_parent() is Path2D:
		var parent :Path2D= get_parent()
		path_points = parent.curve.get_baked_points()
		is_on_path = true


func _process(delta:float)->void:
	if is_on_path:
		if can_move:
			velocity = enemy_move.on_path(path_points,position)
			var _collison := move_and_collide((velocity*100)*delta)
	elif is_in_area:
		position = enemy_move.oscillate(position)
	else:
		position = enemy_move.error_oscillation(position)
	if can_fire and can_move:
		enemy_move.fire(get_parent().get_parent(), $Muzzle.global_position)
		can_fire = false


func hit()-> void:
	can_move = false
	velocity = Vector2.ZERO
	set_collision_layer_bit(0,false)
	set_collision_layer_bit(1,false)
	set_collision_mask_bit(0,false)
	set_collision_mask_bit(1,false)
	emit_signal("destroyed")


func _on_Appearance_animation_finished()->void:
	self.queue_free()


func _on_EnemyArea_body_entered(body)->void:
	if body == self:
		is_in_area = true
		is_on_path = false
		emit_signal("in_stage")


func _on_HoverTimer_timeout()-> void:
	is_in_area = false
	is_on_path = true


func _on_FireTimer_timeout()->void:
	can_fire = true
	$FireTimer.wait_time = rng.randf_range(1,5)
	$FireTimer.start()
