extends Control

const VIEW := Vector2(540, 960)
const NAVY := Color("#0E1F2E")
const GLACIER := Color("#1B4B6B")
const CYAN := Color("#6FD8E8")
const ORANGE := Color("#F4692A")
const CREAM := Color("#F7F2E7")
const GOLD := Color("#E8B23D")

const POSTER_FONT: Font = preload("res://assets/UbuntuSansCondensed.ttf")
const MENU_ART: Texture2D = preload("res://assets/art/alpine_background.png")
const CREST_ART: Texture2D = preload("res://assets/art/title_crest.png")
const PENGUIN_ART: Texture2D = preload("res://assets/art/penguin_headfirst.png")
const FISH_ART: Texture2D = preload("res://assets/art/golden_fish.png")

var game_state := 0
var distance := 0.0
var best_distance := 0
var fish_count := 0
var new_best := false
var game_over_age := 0.0
var pulse_time := 0.0


func _ready() -> void:
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	pulse_time += delta
	queue_redraw()


func set_game_view(state_value: int, distance_value: float, best_value: int, fish_value: int, new_best_value: bool, over_age: float) -> void:
	game_state = state_value
	distance = distance_value
	best_distance = best_value
	fish_count = fish_value
	new_best = new_best_value
	game_over_age = over_age
	queue_redraw()


func _draw() -> void:
	match game_state:
		0:
			_draw_menu()
		1:
			_draw_hud()
		2:
			_draw_hud()
			_draw_game_over()


func _draw_menu() -> void:
	draw_texture_rect(MENU_ART, Rect2(Vector2.ZERO, VIEW), false)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(NAVY, 0.10))
	draw_texture_rect(CREST_ART, Rect2(25, 60, 490, 327), false)
	_center_text("PENGUIN", Rect2(42, 132, 456, 84), CREAM, 69)
	_center_text("DASH 3D", Rect2(42, 198, 456, 92), GOLD, 78)
	_center_text("A REAL MOUNTAIN.  ONE TINY TUMMY.", Rect2(60, 352, 420, 34), NAVY, 18)

	var bob := sin(pulse_time * 2.2) * 5.0
	draw_texture_rect(PENGUIN_ART, Rect2(205, 408 + bob, 130, 195), false)
	_draw_heart(Vector2(181, 480 + bob), 9.0, ORANGE)
	_draw_heart(Vector2(365, 522 + bob), 7.0, GOLD)

	var shadow := PackedVector2Array([Vector2(133, 659), Vector2(407, 659), Vector2(387, 720), Vector2(270, 741), Vector2(153, 720)])
	draw_colored_polygon(shadow, NAVY)
	var button := PackedVector2Array([Vector2(142, 650), Vector2(398, 650), Vector2(379, 710), Vector2(270, 730), Vector2(161, 710)])
	draw_colored_polygon(button, ORANGE)
	_center_text("LET'S SLIDE!", Rect2(150, 665, 240, 43), CREAM, 34)
	_center_text("TAP ANYWHERE", Rect2(150, 760, 240, 30), NAVY, 18)
	if best_distance > 0:
		_center_text("3D BEST  %05d M" % best_distance, Rect2(95, 813, 350, 36), GOLD, 22)
	_center_text("HEAD FIRST  •  HOLD ON TIGHT", Rect2(50, 884, 440, 32), GLACIER, 17)


func _draw_hud() -> void:
	var ribbon := PackedVector2Array([Vector2(22, 22), Vector2(518, 22), Vector2(506, 48), Vector2(518, 76), Vector2(22, 76), Vector2(34, 48)])
	draw_colored_polygon(ribbon, NAVY)
	var inner := PackedVector2Array([Vector2(29, 28), Vector2(511, 28), Vector2(499, 48), Vector2(511, 70), Vector2(29, 70), Vector2(41, 48)])
	draw_colored_polygon(inner, CREAM)
	draw_rect(Rect2(50, 34, 172, 31), GOLD)
	draw_rect(Rect2(56, 38, 160, 23), NAVY)
	_center_text("%05d M" % int(distance), Rect2(56, 36, 160, 29), CREAM, 23)
	draw_texture_rect(FISH_ART, Rect2(348, 34, 42, 28), false)
	_text("%02d" % fish_count, Vector2(394, 63), NAVY, 27)
	_text("BEST %05d" % best_distance, Vector2(233, 59), GLACIER, 16)


func _draw_game_over() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(NAVY, 0.62))
	var panel := PackedVector2Array([Vector2(57, 203), Vector2(483, 203), Vector2(499, 249), Vector2(476, 723), Vector2(64, 723), Vector2(41, 249)])
	draw_colored_polygon(panel, NAVY)
	var inner := PackedVector2Array([Vector2(68, 215), Vector2(472, 215), Vector2(486, 255), Vector2(465, 710), Vector2(75, 710), Vector2(54, 255)])
	draw_colored_polygon(inner, CREAM)
	_center_text("MOUNTAIN MEDAL", Rect2(85, 246, 370, 52), GLACIER, 34)
	draw_circle(Vector2(270, 412), 103, NAVY)
	draw_circle(Vector2(270, 402), 94, GOLD if int(distance) >= 700 else CYAN)
	draw_circle(Vector2(270, 402), 73, CREAM)
	_center_text("%05d" % int(distance), Rect2(185, 364, 170, 62), NAVY, 49)
	_center_text("METERS", Rect2(205, 426, 130, 28), GLACIER, 19)
	if new_best:
		_center_text("OH MY GOSH — NEW 3D BEST!", Rect2(82, 544, 376, 40), GOLD, 24)
	else:
		_center_text("BEST  %05d M" % best_distance, Rect2(135, 548, 270, 34), GLACIER, 22)
	var retry_shadow := PackedVector2Array([Vector2(130, 619), Vector2(410, 619), Vector2(391, 678), Vector2(270, 700), Vector2(149, 678)])
	draw_colored_polygon(retry_shadow, NAVY)
	var retry := PackedVector2Array([Vector2(139, 625), Vector2(401, 625), Vector2(383, 670), Vector2(270, 690), Vector2(157, 670)])
	draw_colored_polygon(retry, ORANGE)
	_center_text("AGAIN! AGAIN!", Rect2(150, 634, 240, 42), CREAM, 30)
	if game_over_age > 0.45:
		_center_text("TAP ANYWHERE — BACK ON THE MOUNTAIN", Rect2(60, 785, 420, 32), CREAM, 18)


func _text(value: String, position: Vector2, color: Color, font_size: int) -> void:
	draw_string(POSTER_FONT, position, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _center_text(value: String, rect: Rect2, color: Color, font_size: int) -> void:
	var text_size := POSTER_FONT.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var position := Vector2(rect.position.x + (rect.size.x - text_size.x) * 0.5, rect.position.y + (rect.size.y + text_size.y) * 0.5 - 3.0)
	draw_string(POSTER_FONT, position, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_heart(center: Vector2, heart_size: float, color: Color) -> void:
	var radius := heart_size * 0.36
	draw_circle(center + Vector2(-radius, -radius * 0.25), radius, color)
	draw_circle(center + Vector2(radius, -radius * 0.25), radius, color)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-heart_size * 0.69, -heart_size * 0.12),
		center + Vector2(heart_size * 0.69, -heart_size * 0.12),
		center + Vector2(0, heart_size * 0.82)
	]), color)
