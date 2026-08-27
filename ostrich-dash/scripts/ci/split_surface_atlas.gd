extends SceneTree

const SOURCE := "res://assets/generated/gameplay/surface_atlas.png"
const OUTPUTS := [
	"classic_rubber.png",
	"beach_sand.png",
	"night_track.png",
	"desert_clay.png",
	"snow_pack.png",
	"jungle_earth.png"
]

func _initialize() -> void:
	var image := Image.load_from_file(SOURCE)
	var cell_width := image.get_width() / 3
	var cell_height := image.get_height() / 2
	var directory := ProjectSettings.globalize_path("res://assets/generated/gameplay/surfaces")
	DirAccess.make_dir_recursive_absolute(directory)
	for index in range(OUTPUTS.size()):
		var region := Rect2i((index % 3) * cell_width, floori(float(index) / 3.0) * cell_height, cell_width, cell_height)
		var tile := image.get_region(region)
		var path := "%s/%s" % [directory, OUTPUTS[index]]
		var error := tile.save_png(path)
		if error != OK:
			push_error("Could not save %s" % path)
			quit(1)
			return
		print("SURFACE_TILE %s" % path)
	quit()
