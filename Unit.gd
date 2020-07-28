extends RigidBody


#mechanic params
export var playerId = 1
var isHighlighted = false
var canRotate = false
var canMove = false
var movementDone = false
export var speed = 0.1
var rot_x = 0
var rot_y = 0
var camera
var floorMesh
const ray_length = 1000
var originOnSelect
var distanceLeft 
var distanceTraveled = 0
var playerPos
var moveButtonPressed = false
var originalMovePos
var player
var isMine

#signals
signal showUI
signal hideUI
signal disableMovment
signal isMoving
signal moveClicked
signal showTooltip
signal hideTooltip
#unit info
var Mat
export var unitClass = {
	"name": "Gilgamesh",
	"avatar":"something.png",
	"faction": "heretics",
	"hasMelee": true,
	"hasRanged": true,
	"hasMagic":true,
	"powerLevel":150,
	"rarity":"legendary",
	"stats":{
		"moveDistance":6,
		"meleeSkill":50,
		"rangedSkill":100,
		"strength": 50,
		"toughness": 50,
		"health":30,
		"actionPoints":3,
	},
	"passives":[],
	"resistances":[],
	"immunities":[],
	"weaknesses":[],
	"abilities":[
		{
			"id":0,
			"name":"Fireball",
			"actionPoints": 2,
			"damage": 10,
			"damageType":"Fire"
		}
	],
	"weapons":[
		{
			"id":0,
			"name":"Unarmed Attack",
			"actionPoints": 2,
			"damage": 10,
			"damageType":"blunt"
		}
	]
}
var moveDistance = unitClass.stats.moveDistance

func _ready():
	camera = get_node("../Player/Camera")
	floorMesh = get_node("../Ground/UnitMovement")
	player = get_node("../Player")
	isMine = player.id == playerId
	if camera:
		print(camera.name)
	distanceLeft = moveDistance
	originalMovePos = playerPos



func _input(event):	
	if Input.is_action_pressed("rotate") and isMine:
		canRotate = true
	if Input.is_action_just_released("rotate") and isMine:
		canRotate = false
#	if Input.is_action_pressed("moveUnit"):
	if Input.is_action_just_pressed("moveUnit") and !movementDone and isMine:
		movePressed()
	if event is InputEventMouseMotion:
		var space_state = get_world().get_direct_space_state() 
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		var hit = space_state.intersect_ray(from, to)
		if hit and hit.collider_id == self.get_instance_id():
			print('hitting a unit')
			if Input.is_action_pressed("shift") and !isHighlighted:
				emit_signal("showTooltip", unitClass)
			elif !isHighlighted:
				emit_signal("hideTooltip")
	if Input.is_action_just_released("shift") and  !isHighlighted:
		emit_signal("hideTooltip")	
		
	if isHighlighted and canMove and !movementDone and isMine:
		handleMove(event)
		handleRaiseLower(event)
		handleRotation(event)
	
	

func movePressed():
	moveButtonPressed = true
	originalMovePos = global_transform.origin
	if(!canMove):
		canMove = true
		emit_signal("isMoving")
		playerPos = global_transform.origin
		drawMovementArea()
	else:
		canMove = false
		playerPos = global_transform.origin
		stopMove()
		hideMovmenetArea()
	
func _on_Unit_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_mask & 1 and player.id == playerId:
		if event.is_pressed():
			handleSelect()	
			

func unSelect():
	handleUnHighlight()
	emit_signal("hideUI")
		
func handleSelect():
	playerPos = global_transform.origin
	if isHighlighted and canMove == false:
		unSelect()
		player.selectedUnit = null
		emit_signal("hideTooltip")
	elif(!isHighlighted):
		handleHighlight(null)
		player.selectedUnit = self
		emit_signal("showUI")
		emit_signal("showTooltip", unitClass)
		
func handleUnHighlight():
	var children = $Mesh.get_children()
	for child in children:
		if child.name == "outline":
			$Mesh.remove_child(child)
			isHighlighted = false
			if isMine:
				hideMovmenetArea()

func handleHighlight(isEnemy):
	originOnSelect = global_transform.origin
	var mesh_outline = $Mesh.mesh.create_outline(0.05)
	var Outline = MeshInstance.new()
	Outline.name = "outline"
	if len($Mesh.get_children()) == 0:
		$Mesh.add_child(Outline)
		Outline.set_mesh(mesh_outline)
		var highlightMaterial
		if(!isEnemy):
			highlightMaterial = load("res://materials/highlight.tres")
		else:
			highlightMaterial = load("res://materials/enemyHighlight.tres")
		Outline.set_surface_material(0, highlightMaterial)
		isHighlighted = true
		
		print('Highlited Unit')
	
func handleRotation(event):
	if isHighlighted and canRotate:
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
	if !movementDone and isMine:
			if event is InputEventMouseMotion and event.button_mask & 1:
				var space_state = get_world().get_direct_space_state() 
				var from = camera.project_ray_origin(event.position)
				var to = from + camera.project_ray_normal(event.position) * ray_length
				var hit = space_state.intersect_ray(from, to)
				
				if hit.size() != 0:
					var resultPos = Vector3(hit.position.x, global_transform.origin.y, hit.position.z)
					var distance = originOnSelect.distance_to(resultPos)
					distanceTraveled = distance
					var distanceRay = space_state.intersect_ray(originOnSelect, resultPos)	
					if distance <= distanceLeft:
						global_transform.origin = resultPos
						emit_signal("moveClicked", self)
#					DrawLine3d.DrawLine(originOnSelect, resultPos, Color(1,0,0), 2)
					print("Distance: %s" % [distance])
					

func stopMove():
	print('stopping movment ')
	distanceLeft -= distanceTraveled
	distanceTraveled = 0
	movementDone = true
	emit_signal("disableMovment", false)
	

func drawMovementArea():
	print('trying to draw movment area. ')
	Mat = floorMesh.get_surface_material(0)
	Mat.set_shader_param("unitPos", playerPos)
	Mat.set_shader_param("R", distanceLeft)
	Mat.set_shader_param("alpha", 1.0)
	
func hideMovmenetArea():
	Mat = floorMesh.get_surface_material(0)
	Mat.set_shader_param("alpha", 0)


func _on_UI_movePressed():
	if(!moveButtonPressed):
		moveButtonPressed = true
		drawMovementArea()
		movePressed()
	else:
		movePressed()
		hideMovmenetArea()
		stopMove()
		moveButtonPressed = false


func _on_UI_cancelPressed():
	if(canMove):
		canMove = false
		global_transform.origin = originalMovePos
		playerPos = global_transform.origin
		hideMovmenetArea()
		emit_signal("disableMovment", !canMove)
		
	else:
		unSelect()


func _on_Unit_moveClicked(unit):
	if unit.playerId != playerId:
		print("Signal received from other unit")
		var isInMeleeRange = unit.global_transform.origin.distance_to(global_transform.origin) <= 1
		if isInMeleeRange:
			handleHighlight(true)
		else:
			if isHighlighted:
				handleUnHighlight()


func _on_Unit_mouse_entered():
	if Input.is_action_just_pressed("shift") and !isHighlighted:
		emit_signal("showTooltip", unitClass)
	if Input.is_action_just_released("shift") and !isHighlighted:
		emit_signal("hideTooltip")	
