extends CSGMesh

#params
var isHighlighted = false
var canRotate = false
var speed = 0.1
var rot_x = 0
var rot_y = 0

func _ready():
	pass


func _process(delta):
	if isHighlighted:
		if Input.is_action_pressed("rotate"):
			canRotate = true
		else:
			canRotate = false

func _on_Area_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_mask & 1:
		if event.is_pressed():
			handleHighlight()
	
func _input(event):
	if canRotate:
		handleRotation(event)
	if isHighlighted:
		handleRaiseLower(event)

func handleHighlight():
	if isHighlighted:
		var children = get_children()
		for child in children:
			if child.name == 'outline':
				remove_child(child)
				isHighlighted = false
	else:
		var mesh_outline = mesh.create_outline(0.02)
		var Outline = MeshInstance.new()
		Outline.name = 'outline'
		add_child(Outline)
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
			transform.basis = Basis() # reset rotation
			rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y


func handleRaiseLower(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				translate_object_local(Vector3(0,1,0)*speed)
			if event.button_index == BUTTON_WHEEL_DOWN:
				translate_object_local(Vector3(0,-1,0)*speed)
