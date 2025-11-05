extends Node


var Skills = {
	"tatsu": false,
	"burst": false,
}


var skill_point: int = 0


func enable_skill(skill_name: String) -> bool:
	if Skills.has(skill_name):
		# check skill exists
		if Skills[skill_name]:
			print("%s is already on"%skill_name)
		else:
			Skills[skill_name] = true

		return true

	else:
		# Skill not found
		print("%s not found"%skill_name)

		return false


func check_skill(skill_name: String) -> bool:
	if Skills.has(skill_name):
		if Skills[skill_name]:
			return true
		else:
			return false
	else:
		# Skill not found
		print("%s not found"%skill_name)

		return false

