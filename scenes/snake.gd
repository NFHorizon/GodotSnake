extends Area2D
class_name Snake

var random = RandomNumberGenerator.new()

var speed_map = {"slow": 2.0, "fast": 6.0}
var speed_step = 150

var body_max_length = 500
var init_width = 40
var snake_init_size = 0.45

var speed: float = 1
var speed_mode = "slow"
var snake_size = snake_init_size
var snake_body_length = 5
var angular_speed = PI

var color
var targetR
var body_space = 32
var body_arr:Array[Area2D] = []
var path_arr: Array[Vector2] = []

var kill
var bean_total_eaten = 0
var bean_in_hand = 0

var is_ai = false
var id 
var is_dead = false
var is_invincible = false

@export var joystick_left: VirtualJoystick
#@export var joystick_right : VirtualJoystick

@export var SnakeBody: PackedScene

var move_vector := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func init():
	speed = speed_map[speed_mode]
	targetR = rotation
	color = id
	init_width = $Head.texture.get_size().x	
	body_space = floor(init_width / 10 * 8)	
	
	for i in range(6, body_arr.size()):
		body_arr[i].queue_free()
		
	body_arr = body_arr.slice(0, 6)
	
	body_arr.push_back(self)
	
	var image = Image.load_from_file("res://arts/head%s.png" % [color])
	var texture = ImageTexture.create_from_image(image)
	$Head.texture = load("res://arts/head%s.png" % [color])
	for i in range(0, snake_body_length):
		add_body()
		
	position = Vector2(0, 0)
	is_invincible = true
	$ShieldTimer.start(3)	
	
func _ready():
	init()

func ai_move():
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsRayQueryParameters2D.create(Vector2(0, 0), Vector2(50, 100))
	#var result = space_state.intersect_ray(query)
	pass	

func _physics_process(delta): 
		
	if is_ai:
		move_vector = Vector2.from_angle(random.randf()*360)
		#var modes = speed_map.keys()
		speed_mode = "slow"
	else:
		move_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		speed_mode = "fast" if Input.is_action_pressed("speed_up") else "slow"
		
	speed = lerp(speed, speed_map[speed_mode], 1.0) 	
		
	for i in range(0, body_arr.size()):
		var body = body_arr[i]
		if i < body_arr.size() - 1:
			var next_body = body_arr[i+1]
			if next_body:
				next_body.targetR = body.rotation
				next_body.position = lerp(next_body.position, body.position, 0.06*speed_map[speed_mode])
				next_body.look_at(body.position)
			
		if i == 0:
			if not move_vector.is_zero_approx():
				targetR = move_vector.angle()
				rotation = lerp_angle(rotation, targetR, 0.1)
			position += Vector2.from_angle(rotation) * delta * speed * speed_step
			
	if bean_in_hand > 10:
		bean_in_hand -= 10
		add_body()
		bean_in_hand = 0 
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Movement using the joystick output:
#	if joystick_left and joystick_left.is_pressed:
#		position += joystick_left.output * speed * delta
	pass
	# Rotation:
	#if joystick_right and joystick_right.is_pressed:
		#rotation = joystick_right.output.angle()
		
		
func add_body():
	if body_arr.size() < body_max_length:
		var pre_body = body_arr.back()
		var pre_velocity: Vector2 = Vector2.from_angle(pre_body.rotation) 
		var pre_position: Vector2 = pre_body.position
		
		var body_position = pre_position - (pre_velocity * 45)
		
		var body := SnakeBody.instantiate()
		add_sibling.call_deferred(body)
		
		body.position = body_position
		body.rotation = pre_body.rotation
		body.is_ai = is_ai
		body.id = id
		body.set_color(id)
		body_arr.push_back(body)
				

func eat_bean():
	bean_in_hand += 1
	
func die():
	print("蛇蛇死了")

	for body in body_arr:
		body.is_dead = true
		body.queue_free()
		
	get_parent().get_parent().create_snake(id, is_ai)
	pass 

func _on_bean_area_entered(area):
	if not area is Bean:
		return 
	
	print("吃豆子")
	eat_bean()
	(area as Bean).eaten()	

func _on_snake_entered(area):
	print("撞到其他蛇",area)
	if is_invincible: 
		return 
		
	if area is Snake or area is SnakeBody:
		if area.is_dead:
			return 
			
		if area.id != id:
			die()

func _on_shield_timer_timeout():
	is_invincible = false
	pass # Replace with function body.
