extends Node

@export var bean_scene: PackedScene
@export var Snake: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	add_beans()
	$BeanTimer.start()
	
	create_snake(1, false)

	for i in range(2, 7):
		create_snake(i, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func create_snake(id, is_ai):
	var snake = Snake.instantiate()
	snake.id = id
	snake.is_ai = is_ai	
	if not is_ai:
		snake.add_child(Camera2D.new())
	$TileMap2.add_child(snake)
	
func add_beans():
	var size = $TileMap2.texture.get_size()
	
	var beans_zone = $TileMap2/Beans as Node2D
	if beans_zone.get_child_count() < 5000:
		for i in range(1, 100):
			var bean = bean_scene.instantiate()
			
			bean.position = Vector2(randf_range(-size.x/2, size.x/2), randf_range(-size.y/2, size.y/2))
			$TileMap2/Beans.add_child(bean)
			pass
	
func _on_bean_timer_timeout():
	$BeanTimer.start()
	add_beans()
	pass # Replace with function body.

func _on_snake_entered(area):
	if not area is Snake:
		return 
	(area as Snake).die()


func _on_button_speed_up_pressed():
	print("按下加速按鈕")
	Input.action_press("speed_up")

func _on_button_speed_up_released():
	print("松开加速按鈕")
	Input.action_release("speed_up")
