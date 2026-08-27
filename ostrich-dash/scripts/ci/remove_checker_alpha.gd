extends SceneTree

# Removes a generator-rendered near-white checkerboard by flood-filling only
# neutral, bright pixels connected to the canvas edge. Warm cream artwork and
# colored glows are retained because they break the neutral-color threshold.

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Usage: -- <png path>")
		quit(2)
		return
	var path: String = args[-1]
	var image := Image.load_from_file(path)
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var queue := PackedInt32Array()
	for x in range(width):
		_try_enqueue(image, x, 0, width, visited, queue)
		_try_enqueue(image, x, height - 1, width, visited, queue)
	for y in range(height):
		_try_enqueue(image, 0, y, width, visited, queue)
		_try_enqueue(image, width - 1, y, width, visited, queue)
	var cursor := 0
	while cursor < queue.size():
		var packed: int = queue[cursor]
		cursor += 1
		var x := packed % width
		var y := packed / width
		_try_enqueue(image, x - 1, y, width, visited, queue)
		_try_enqueue(image, x + 1, y, width, visited, queue)
		_try_enqueue(image, x, y - 1, width, visited, queue)
		_try_enqueue(image, x, y + 1, width, visited, queue)
	for packed in queue:
		var x := packed % width
		var y := packed / width
		var color := image.get_pixel(x, y)
		color.a = 0.0
		image.set_pixel(x, y, color)
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s: %s" % [path, error_string(error)])
		quit(3)
		return
	print("REMOVED_CHECKER path=%s transparent=%d/%d" % [path, queue.size(), width * height])
	quit()

func _try_enqueue(image: Image, x: int, y: int, width: int, visited: PackedByteArray, queue: PackedInt32Array) -> void:
	if x < 0 or y < 0 or x >= width or y >= image.get_height():
		return
	var packed := y * width + x
	if visited[packed] != 0:
		return
	visited[packed] = 1
	var color := image.get_pixel(x, y)
	var high := maxf(color.r, maxf(color.g, color.b))
	var low := minf(color.r, minf(color.g, color.b))
	if low >= 0.87 and high - low <= 0.045:
		queue.append(packed)
