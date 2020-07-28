extends Control




func _on_Unit_showTooltip(unitClass):
	self.visible = true
	$CenterContainer/VBoxContainer/UnitName.text = unitClass.name
	$CenterContainer/VBoxContainer/HP.text = "HP: "+ str(unitClass.stats.health)
	$CenterContainer/VBoxContainer/AP.text = "AP: "+ str(unitClass.stats.actionPoints)
	$CenterContainer/VBoxContainer/Speed.text = "Speed: "+ str(unitClass.stats.moveDistance)
	$CenterContainer/VBoxContainer/Stats.text = "MS: "+ str(unitClass.stats.meleeSkill) + " RS: " + str(unitClass.stats.meleeSkill) + "\n " + "S: " +  str(unitClass.stats.strength) + " T: " +  str(unitClass.stats.toughness)


func _on_Unit_hideTooltip():
	self.visible = false
