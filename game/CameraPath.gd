extends Path2D

var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	
func set_player(p):
	player = p
	set_process(true)

func _process(delta):
	var viewHalf= get_viewport_rect().end.x/2
	var playerX = (player.global_transform * get_canvas_transform()).get_origin().x
	
	if playerX > viewHalf:
		$Follow.unit_offset = min($Follow.unit_offset + delta * 0.1, 1)
		if $Follow.unit_offset == 1:
			set_process(false)
			