extends KinematicBody2D
var direction = Vector2.ZERO
var velocity: Vector2
var max_speed: int = 800
var max_steering: float = 2.5
var max_avoide_distance = 300
var avoid_force_strength = 100

onready var raycasts: Node2D = get_node("RayCasts")

func _ready():
	pass
	
func _physics_process(_delta):
	var steering: Vector2 = Vector2.ZERO
	steering += seek_steering()
	steering += avoid_obstacles_steering()
	steering = steering.clamped(max_steering)
	
	velocity += steering
	velocity  = velocity.clamped(max_speed)
	velocity = move_and_slide(velocity)

func seek_steering():
	var desired_velocity: Vector2 = (Globals.player_pos - position).normalized() * max_speed
	return desired_velocity - velocity

func avoid_obstacles_steering():
#	raycasts.rotation = velocity.angle()
	var avoid_force = Vector2.ZERO 
	var closest_obestacle_distance = max_avoide_distance
	for raycast in raycasts.get_children():
		raycast.cast_to = velocity.normalized() * max_avoide_distance
		if raycast.is_colliding():
			var distance_to_obestacle = raycast.get_collision_point().distance_to(position)
			if distance_to_obestacle < closest_obestacle_distance:
				closest_obestacle_distance = distance_to_obestacle
				var collision_normal = raycast.get_collision_normal()
				var strength = lerp(avoid_force_strength,avoid_force_strength*2, 1 - (distance_to_obestacle / max_avoide_distance))
				avoid_force += collision_normal.rotated(rad2deg(90)) * avoid_force_strength
	
	if closest_obestacle_distance < max_avoide_distance / 2:
		velocity *= 0.8
	return avoid_force
