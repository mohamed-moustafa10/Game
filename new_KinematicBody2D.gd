extends KinematicBody2D

var _velocity = Vector2.ZERO
onready var hunter = $NavigationAgent2D
var speed = 200
var path = []
var map


func _ready():
	call_deferred("setup_navserver")

#func _input(event):
#	if not event.is_action_pressed("primary action"):
#		return
#	_update_navigation_path(position,get_global_mouse_position())

func setup_navserver():
	map = Navigation2DServer.map_create()
	Navigation2DServer.map_set_active(map,true)

	var region = Navigation2DServer.region_create()
	Navigation2DServer.region_set_transform(region,Transform2D())
	Navigation2DServer.region_set_map(region,map)

	var navigation_poly = NavigationMesh.new()
	navigation_poly = $"../../NavigationPolygonInstance".navpoly
	Navigation2DServer.region_set_navpoly(region,navigation_poly)

func _update_navigation_path(start_pos,end_pos):
	path = Navigation2DServer.map_get_path(map,start_pos,end_pos,true)
	path.remove(0)
	set_process(true)

func _process(delta):
	var walk_distance = 500 * delta
	move_along_path(walk_distance)

func move_along_path(distance):
	var last_position = position
	while path.size():
		var distance_between_points = last_position.distance_to(path[0])
		if distance <= distance_between_points:
			position = last_position.linear_interpolate(path[0],distance/ distance_between_points)
			return

		distance -= distance_between_points
		last_position = path[0]
		path.remove(0)

	position = last_position
	set_process(false)
	
#func _physics_process(delta):
#
#	if hunter.is_navigation_finished():
#		return
#
#	var next_path = hunter.get_next_location()
#	var direction = global_position.direction_to(get_global_mouse_position())
#	var move_to_path = direction * hunter.max_speed
#	var steering = (move_to_path - _velocity) * delta * 4.0
#	_velocity += steering
#	hunter.set_velocity(_velocity)
#
#func move(velocity):
#	_velocity = move_and_slide(velocity)
	
#func _physics_process(delta):
#	if hunter.is_target_reachable():
#		if int(hunter.distance_to_target()) > 5:
#			var next_path = hunter.get_next_location()
#			var new_direction = global_position.direction_to(next_path).normalized()
#			global_position += new_direction * delta * speed
#
#	if Input.is_action_just_pressed("primary action"):
#		hunter.target_location = get_global_mouse_position()
#
#	if hunter.is_navigation_finished():
#		return


func _on_Timer_timeout():
	#hunter.target_location = Globals.player_pos
	_update_navigation_path(position,Globals.player_pos)
