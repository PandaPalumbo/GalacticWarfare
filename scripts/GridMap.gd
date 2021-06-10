extends GridMap
var camera
const ray_length = 1000
var grid_size = Vector2(50,50)
var grid = []

var clickedCellPos

func _ready():
	camera =  get_viewport().get_camera()
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
			
	var positions = []
	

func _input(event):	
	if Input.is_action_pressed("click"):
		var space_state = get_world().get_direct_space_state()
		##cameras pov
		var from = camera.project_ray_origin(event.position)
		# to where clicked
		var to = from + camera.project_ray_normal(event.position) * ray_length
		## where they hit
		var hit = space_state.intersect_ray(from, to)
		if hit and hit.collider_id:
			print(self.world_to_map(hit.position))
