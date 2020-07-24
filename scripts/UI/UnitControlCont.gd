extends Control

signal movePressed
signal cancelPressed

func _on_Unit_showUI():
	$UnitControlCont.visible = true



func _on_Unit_hideUI():
	$UnitControlCont.visible = false


func _on_Unit_disableMovment(isMoveCancel):
	if(!isMoveCancel):
		$UnitControlCont/RightCont/Move.disabled = true
	$UnitControlCont/LeftCont.visible = true
	$TurnControlCont.visible = true
	$UnitControlCont/RightCont/Move.text = "Move (M)"

func _on_Unit_isMoving():
	$UnitControlCont/RightCont/Move.text = "End Movement (M)"
	$UnitControlCont/LeftCont.visible = false
	$TurnControlCont.visible = false


func _on_Move_pressed():
	emit_signal("movePressed")


func _on_Cancel_pressed():
	emit_signal("cancelPressed")
