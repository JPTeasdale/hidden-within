extends AnimationPlayer

func animate(name):
	if name == get_assigned_animation():
		return
	play(name)