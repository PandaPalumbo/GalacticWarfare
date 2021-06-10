extends StaticBody

var camera
const ray_length = 1000
var clickedCellPos

var DrawLine

var shader

func _ready():
	camera = get_node("../Player/Camera")
	var shader = get_node("../Ground/Grid").get_surface_material(0)

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
#			print(hit.position)
			print(hit)


