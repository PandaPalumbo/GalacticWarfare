extends RigidBody


#params
var isHighlighted = false
var canRotate = false
var canMove = false
var speed = 0.1
var rot_x = 0
var rot_y = 0
var camera
const ray_length = 1000
var originOnSelect
var moveDistance = 10


func _ready():
	camera = get_node("../Player/Camera")
	if camera:
		print(camera.name)

func _process(delta):
	if isHighlighted:
		if Input.is_action_pressed("rotate"):
			canRotate = true
		if Input.is_action_just_released("rotate"):
			canRotate = false
		if Input.is_action_pressed("moveUnit"):
			canMove = true
		if Input.is_action_just_released("moveUnit"):
			canMove = false

func _input(event):
	if canRotate:
		handleRotation(event)
	if isHighlighted:
		handleRaiseLower(event)
		handleMove(event)

func _on_Unit_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_mask & 1:
		if event.is_pressed():
			handleHighlight()
			print('poop')

func handleHighlight():
	if isHighlighted and !canMove:
		var children = $Unit.get_children()
		for child in children:
			if child.name == 'outline':
				$Unit.remove_child(child)
				isHighlighted = false
	else:
		originOnSelect = global_transform.origin
		var mesh_outline = $Unit.mesh.create_outline(0.02)
		var Outline = MeshInstance.new()
		Outline.name = 'outline'
		$Unit.add_child(Outline)
		Outline.set_mesh(mesh_outline)
		var highlightMaterial = load("res://materials/highlight.tres")
		Outline.set_surface_material(0, highlightMaterial)
		isHighlighted = true

func handleRotation(event):
	if isHighlighted:
		if event is InputEventMouseMotion:
			var rotation_speed = speed* 0.1
			
			# modify accumulated mouse rotation
			rot_x -= event.relative.x * rotation_speed
			rot_y -= event.relative.y * rotation_speed
			transform.basis = Basis() # reset rotation
			rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			rotate_object_local(Vector3(0, 1, 0), rot_y) # first rotate in Y

func handleRaiseLower(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if canMove:
				if event.button_index == BUTTON_WHEEL_UP:
					translate_object_local(Vector3(0,1,0)*speed)
				if event.button_index == BUTTON_WHEEL_DOWN:
					translate_object_local(Vector3(0,-1,0)*speed)

func handleMove(event):
	if isHighlighted:
		if canMove:
			if event is InputEventMouseMotion and event.button_mask & 1:
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * ray_length
				var space_state = get_world().get_direct_space_state()
				var hit = space_state.intersect_ray(from, to)
				if hit.size() != 0:
					var resultPos = Vector3(hit.position.x, global_transform.origin.y, hit.position.z)
					global_transform.origin = resultPos
					var distance = originOnSelect.distance_to(resultPos)
					print("Distance: %s" % [distance])
