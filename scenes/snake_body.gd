extends SnakeNode

class_name SnakeBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_color(color):
	var image = Image.load_from_file("res://arts/body%s.png" % [color])
	var texture = ImageTexture.create_from_image(image)
	$Sprite.texture = load("res://arts/body%s.png" % [color])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
