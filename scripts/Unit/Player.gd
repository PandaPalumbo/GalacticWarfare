extends KinematicBody
var speed = 0.1
var rot_x = 0
var rot_y = 0
export var id = 1
var isUnitSelected = false
var selectedUnit = null
			
func _process(delta):
	movement()
		

func _input(event):
	
		if event is InputEventMouseMotion and event.button_mask & 2:
			var rotation_speed = speed* 0.1
			
			# modify accumulated mouse rotation
			rot_x -= event.relative.x * rotation_speed
			rot_y += event.relative.y * rotation_speed
			transform.basis = Basis() # reset rotation
			rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
			rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

func movement():
	#movement
	if Input.is_action_pressed("move_forward"):
		translate_object_local(Vector3(0,0,1)*speed)
		
	if Input.is_action_pressed("move_backward"):
		translate_object_local(Vector3(0,0,-1)*speed)
		
	if Input.is_action_pressed("move_left"):
		translate_object_local(Vector3(1,0,0)*speed)
		
	if Input.is_action_pressed("move_right"):
		translate_object_local(Vector3(-1,0,0)*speed)
		
	if Input.is_action_pressed("move_up"):
		translate_object_local(Vector3(0,1,0)*speed)
	
	if Input.is_action_pressed("move_down"):
		translate_object_local(Vector3(0,-1,0)*speed)


func _on_Unit_showUI():
	isUnitSelected = true


func _on_Unit_hideUI():
	isUnitSelected = false
