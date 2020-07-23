extends RigidBody


#params
var isHighlighted = false
var canRotate = false
var canMove = false
var movementDone = false
var speed = 0.1
var rot_x = 0
var rot_y = 0
var camera
var floorMesh
const ray_length = 1000
var originOnSelect
var moveDistance = 6.0
var distanceLeft 
var distanceTraveled = 0
var playerPos
var Mat

func _ready():
	camera = get_node("../Player/Camera")
	floorMesh = get_node("../Ground/UnitMovement")
	if camera:
		print(camera.name)
	distanceLeft = moveDistance
	

func _process(delta):
	if isHighlighted:
		if Input.is_action_pressed("rotate"):
			canRotate = true
		if Input.is_action_just_released("rotate"):
			canRotate = false


func _input(event):
	if canRotate:
		handleRotation(event)
	if isHighlighted:
		handleRaiseLower(event)
#		if Input.is_action_pressed("moveUnit"):
#			canMove = true
#			handleMove(event)
#		else:
#			canMove = false
#			playerPos = global_transform.origin
#			distanceLeft = distanceLeft - distanceTraveled
#			if distanceLeft <= 0:
#				movementDone = true

func _on_Unit_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_mask & 1:
		if event.is_pressed():
			handleHighlight()		
			if isHighlighted:
				drawMovementArea()

func handleHighlight():
	playerPos = global_transform.origin
	if isHighlighted and canMove == false:
		var children = $Unit.get_children()
		for child in children:
			if child.name == 'outline':
				$Unit.remove_child(child)
				isHighlighted = false
		stopMove()
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
		print('poop')
		
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
		if canMove and !movementDone:
			if event is InputEventMouseMotion and event.button_mask & 1:
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * ray_length
				var space_state = get_world().get_direct_space_state()
				var hit = space_state.intersect_ray(from, to)
				if hit.size() != 0:
					var resultPos = Vector3(hit.position.x, global_transform.origin.y, hit.position.z)
					var distance = originOnSelect.distance_to(resultPos)
					distanceTraveled = distance
					var distanceRay = space_state.intersect_ray(originOnSelect, resultPos)
					if distance <= distanceLeft:
						global_transform.origin = resultPos
#					DrawLine3d.DrawLine(originOnSelect, resultPos, Color(1,0,0), 2)
					print("Distance: %s" % [distance])

func stopMove():
	print('stopping movment ')
	Mat = floorMesh.get_surface_material(0)
	Mat.set_shader_param("alpha", 0)
	if distanceLeft <= 0:
		movementDone = true

func drawMovementArea():
	print('trying to draw movment area. ')
	Mat = floorMesh.get_surface_material(0)
	Mat.set_shader_param("unitPos", playerPos)
	Mat.set_shader_param("R", distanceLeft)
	Mat.set_shader_param("alpha", 1.0)
