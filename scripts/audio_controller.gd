extends Node2D

@export var mute: bool = false


func slash1():
	if not mute:
		$slash.play()
		
func waterSkill():
	if not mute:
		$waterSkillSF.play()
func fireballSkill():
	if not mute:
		$firebalSkilllSF.play()
		
func windSkill():
	if not mute:
		$windSkillSF.play()

func stepRun():
	if not mute:
		$run.play()

func deadSF():
	if not mute:
		$deadSF.play()
		
func playerDeadSF():
	if not mute:
		$playerDeadSF.play()
		
func mobDeadSF():
	if not mute:
		$playerDeadSF.play()

func mobTakeDamage():
	if not mute:
		$take_damage.play()
		
func portalSF():
	if not mute:
		$portalSF.play()		
