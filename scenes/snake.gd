extends Sprite2D

var speed_map = {"slow": 2, "fast": 4, "rotation": 10}
var body_max_length = 500
var init_width = 40
var snake_init_size = 0.45

var speed: float = 1
var speed_mode = "slow"
var snake_size = snake_init_size
var snake_length

var color
var targetR
var body_space
var rotation_temp
var body_arr
var path_arr

var kill
var bean_eaten
	
@export var joystick_left: VirtualJoystick
#@export var joystick_right : VirtualJoystick

var move_vector := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = speed_map[speed_mode]
	targetR = get_rotation_degrees()
	color = 1
	init_width = texture.get_size().x
	body_space = floor(texture.get_size().x / 10 * 8)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Movement using the joystick output:
#	if joystick_left and joystick_left.is_pressed:
#		position += joystick_left.output * speed * delta
	move_head()
	move_body()
	change_speed_smoothly()
	change_rotation_smoothly()
	# Rotation:
	#if joystick_right and joystick_right.is_pressed:
		#rotation = joystick_right.output.angle()

func move_out():
	pass

func move_head():
	## Movement using Input functions:
	move_vector = Vector2.ZERO
	move_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var x = speed * cos(self.rotation_degrees * PI / 180)
	var y = speed * sin(self.rotation_degrees * PI / 180)
	self.rotation_degrees = rotation_temp

	var pos = self.position
	var posBefore = self.position

	pos += Vector2(x, y)

	for index in range(1, speed+1):
		path_arr.push_front(Vector2(
			index * cos(atan2(pos.y - posBefore.y, pos.x - posBefore.x)) + posBefore.x,
			index * sin(atan2(pos.y - posBefore.y, pos.x - posBefore.x)) + posBefore.y
		))
	
	#position += move_vector * speed * delta	

func move_body():
	pass
	
func change_speed_smoothly():
	if speed_mode == "slow":
		speed = speed - 1 if speed > speed_map[speed_mode] else speed_map[speed_mode]
	else:
		speed = speed + 1 if speed > speed_map[speed_mode] else speed_map[speed_mode]
		
func change_rotation_smoothly():
	var rotation_diff = abs(targetR - rotation_temp) if abs(targetR - rotation_temp) < speed_map['rotation'] else speed_map['rotation']

	if (targetR < - 0 and rotation_temp > 0 and abs(targetR) + rotation_temp > 180):
		rotation_diff = (180 - rotation_temp) + (180 + targetR) if (180 - rotation_temp) + (180 + targetR) < speed_map['rotation'] else speed_map['rotation']
		rotation_temp += rotation_diff
	else:
		rotation_temp += rotation_diff if (targetR > rotation_temp and abs(targetR - rotation_temp) <= 180) else - rotation_diff
	
	rotation_temp = (rotation_temp - 360 if rotation_temp > 0 else rotation_temp + 360) if abs(rotation_temp) > 180 else rotation_temp
	
func add_body():
	pass
