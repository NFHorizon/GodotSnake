extends Node

@export var bean_scene: PackedScene
@export var Snake: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	add_beans()
	$BeanTimer.start()
	
	var snake = create_snake(1, false)
	
	for i in range(2, 7):
		create_snake(i, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func create_snake(id, is_ai):
	var size = $TileMap2.texture.get_size()
	var snake = Snake.instantiate()
	snake.id = id
	snake.is_ai = is_ai	
	snake.position = Vector2(randf_range(-size.x/2 + 100, size.x/2 - 100), randf_range(-size.y/2 + 100, size.y/2) - 100)
	
	if not is_ai:
		snake.add_child(Camera2D.new())
		snake.statistics_updated.connect(_on_update_my_statistics)
		
	$TileMap2.add_child(snake)
	snake.died.connect(_on_snake_died)
	return snake

func _on_update_my_statistics(length, kill):
	print("更新统计数据:", length, kill)
	$CanvasLayer/LabelSnakeLength.text = "长度: %s" % length
	$CanvasLayer/LabelKill.text = "击杀: %s" % kill
	
func _on_snake_died(die_snake, killer_snake):
	for body in die_snake.body_arr:
		explode_to_beans(body)
	
	if killer_snake is SnakeNode:
		killer_snake.head.kill += 1
	create_snake(die_snake.id, die_snake.is_ai)	

func add_beans():
	var size = $TileMap2.texture.get_size()
	
	var beans_zone = $TileMap2/Beans as Node2D
	if beans_zone.get_child_count() < 3000:
		for i in range(1, 50):
			var bean = bean_scene.instantiate()
			
			bean.position = Vector2(randf_range(-size.x/2, size.x/2), randf_range(-size.y/2, size.y/2))
			$TileMap2/Beans.add_child(bean)
	
func _on_bean_timer_timeout():
	$BeanTimer.start()
	add_beans()
	pass # Replace with function body.
		
func explode_to_beans(body):
	for i in range(1, 10):
		#首先生成角度theta [0,2*pi]
		var random_theta = randf() * PI * 2
		#生成距离圆心的长度
		var random_r = sqrt(randf()) * 21
		var position = body.position + Vector2(cos(random_theta) * random_r, sin(random_theta) * random_r)
		
		var bean = bean_scene.instantiate()
		bean.position = position
		
		$TileMap2/Beans.call_deferred("add_child", bean)
	
func _on_button_speed_up_pressed():
	print("按下加速按鈕")
	Input.action_press("speed_up")

func _on_button_speed_up_released():
	print("松开加速按鈕")
	Input.action_release("speed_up")
