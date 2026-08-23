extends SceneTree

func _init() -> void:
	if OS.get_cmdline_user_args().is_empty():
		push_error("Pass an image path after --")
		quit(2)
		return
	var path := OS.get_cmdline_user_args()[0]
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		push_error("Could not load %s" % path)
		quit(2)
		return
	var min_alpha := 1.0
	var max_alpha := 0.0
	var transparent_pixels := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			min_alpha = minf(min_alpha, alpha)
			max_alpha = maxf(max_alpha, alpha)
			if alpha < 0.99:
				transparent_pixels += 1
	print("ALPHA path=%s size=%dx%d min=%.3f max=%.3f transparent=%d/%d" % [
		path,
		image.get_width(),
		image.get_height(),
		min_alpha,
		max_alpha,
		transparent_pixels,
		image.get_width() * image.get_height(),
	])
	quit(0)
