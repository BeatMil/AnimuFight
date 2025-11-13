extends Node


var skill_dict = {
	"tatsu": false,
	"jin1+2": true,
	"burst": false,
}


var skill_point: int = 0


func enable_skill(skill_name: String) -> bool:
	if skill_dict.has(skill_name):
		# check skill exists
		if skill_dict[skill_name]:
			print("%s is already on"%skill_name)
		else:
			skill_dict[skill_name] = true

		return true

	else:
		# Skill not found
		print("%s not found"%skill_name)

		return false


func check_skill(skill_name: String) -> bool:
	if skill_dict.has(skill_name):
		if skill_dict[skill_name]:
			return true
		else:
			return false
	else:
		# Skill not found
		print("%s not found"%skill_name)

		return false

