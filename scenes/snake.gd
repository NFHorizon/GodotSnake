extends SnakeNode
class_name Snake

var random = RandomNumberGenerator.new()

var speed_map = {"slow": 3, "fast": 10}
var speed_step = 150

var body_max_length = 500
var init_width = 40
var snake_init_size = 0.45

var speed: int = 1
var speed_mode = "slow"
var snake_size = snake_init_size
var snake_body_length = 5
var angular_speed = PI

var color
var targetR
var body_space = 24

var body_arr:Array[Area2D] = []
var path_arr: Array[Vector2] = []
			
var bean_total_eaten = 0
var bean_in_hand = 0

var is_invincible = false

@export var joystick_left: VirtualJoystick
#@export var joystick_right : VirtualJoystick

@export var SnakeBody: PackedScene

var move_vector := Vector2.ZERO

signal died(die_snake, killer_snake)
signal statistics_updated(length, kill)

var kill : int :
	set(value):
		kill = value
		statistics_updated.emit(snake_body_length, kill)
			
# Called when the node enters the scene tree for the first time.
func init():
	speed = speed_map[speed_mode]
	targetR = rotation
	color = id
	init_width = $Sprite.texture.get_size().x	
	#body_space = floor(init_width / 10 * 8)	
	($Sprite as Sprite2D).z_index = 500
	#for i in range(6, body_arr.size()):
		#body_arr[i].queue_free()
	#body_arr = body_arr.slice(0, 6)
	head = self
	body_arr.push_back(self)
	
	var image = Image.load_from_file("res://arts/head%s.png" % [color])
	var texture = ImageTexture.create_from_image(image)
	$Sprite.texture = load("res://arts/head%s.png" % [color])
	for i in range(0, snake_body_length):
		add_body()
		
	#position = Vector2(0, 0)
	is_invincible = true
	$ShieldTimer.start(3)	
	snake_body_length = 5
	kill = 0
	
	
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
		speed_mode = "slow"
	else:
		move_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		speed_mode = "fast" if Input.is_action_pressed("speed_up") else "slow"
		
	speed = lerp(speed, speed_map[speed_mode], 1) 
	if not move_vector.is_zero_approx():
		targetR = move_vector.angle()
		rotation = lerp_angle(rotation, targetR, 0.5)
		#print("rotation", rotation)
		
	var pos_before = position
	position += Vector2.from_angle(rotation) * speed  #* speed_step * delta 
	for i in range(1, speed+1):
		path_arr.push_front(Vector2(
			i * cos(atan2(position.y-pos_before.y, position.x -pos_before.x )) + pos_before.x,
			i * sin(atan2(position.y-pos_before.y, position.x -pos_before.x )) + pos_before.y,
		))
	
	for i in range(0, body_arr.size()):
		if i > 0 and i < body_arr.size():
			if i*body_space <= path_arr.size()-1:
				var path = path_arr[(i)*body_space]
				var body = body_arr[i]			
				body.rotation = atan2(
					path.y - body.position.y
					, path.x - body.position.x
				)
				body.position = path
				if path_arr.size() > body_arr.size() * (1+body_space):
					path_arr.pop_back()
			
	if bean_in_hand > 10:
		bean_in_hand -= 10
		add_body()
		
		snake_body_length += 1
		statistics_updated.emit(snake_body_length, kill)
		
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
	#if body_arr.size() < body_max_length:
	var pre_body = body_arr.back()
	var pre_velocity: Vector2 = Vector2.from_angle(pre_body.rotation) 
	var pre_position: Vector2 = pre_body.position
	
	var body_position = pre_position - (pre_velocity * body_space)
	var body := SnakeBody.instantiate()
	add_sibling.call_deferred(body)
	
	body.position = body_position
	body.rotation = pre_body.rotation
	body.is_ai = is_ai
	body.id = id
	body.get_node("Sprite").z_index = pre_body.get_node("Sprite").z_index - 1
	body.set_color(id)
	body.head = self
	
	body_arr.push_back(body)
	for i in range(0, body_space * 1):
		path_arr.push_back(
			position - i * Vector2.from_angle(body.rotation)
		)
			

func eat_bean():
	bean_in_hand += 1
	
func die():
	print("蛇蛇死了")
	is_dead = true
	for body in body_arr:
		body.queue_free()
		body = null

func _on_bean_area_entered(area):
	if not area is Bean:
		return 
	
	#print("吃豆子")
	eat_bean()
	(area as Bean).eaten()	

func _on_snake_entered(area):
	print("进入其他蛇的区域", area)
#碰撞双方有一个无敌就不判定碰撞
	if area is Wall:
		print("撞墙了")
		die()
		died.emit(self, area)		
	elif area is Snake or area is SnakeBody:
		if is_invincible or area.head.is_invincible or is_dead or area.head.is_dead: 
			return 
	
		print("发生碰撞", area.id)
		if area.id != id:
			die()
			died.emit(self, area)

func _on_shield_timer_timeout():
	is_invincible = false
	pass # Replace with function body.
