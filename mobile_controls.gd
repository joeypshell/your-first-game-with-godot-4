extends Control

@export var show_on_desktop := false

const ACTION_LEFT := "move_left"
const ACTION_RIGHT := "move_right"
const ACTION_UP := "move_up"
const ACTION_DOWN := "move_down"
const DEADZONE := 0.18
const STICK_RADIUS := 88.0
const ACTIVATION_RADIUS := 180.0
const EDGE_MARGIN := 150.0

var _touch_index := -1
var _direction := Vector2.ZERO
var _action_strengths := {
	ACTION_LEFT: 0.0,
	ACTION_RIGHT: 0.0,
	ACTION_UP: 0.0,
	ACTION_DOWN: 0.0,
}


func _ready() -> void:
	visible = show_on_desktop or _is_touch_device()
	if not visible:
		mouse_filter = Control.MOUSE_FILTER_IGNORE


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and _is_in_stick_zone(event.position):
			_touch_index = event.index
			_update_direction(event.position)
			accept_event()
		elif not event.pressed and event.index == _touch_index:
			_reset_stick()
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_direction(event.position)
		accept_event()
	elif show_on_desktop and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _is_in_stick_zone(event.position):
			_touch_index = 0
			_update_direction(event.position)
			accept_event()
		elif not event.pressed and _touch_index == 0:
			_reset_stick()
			accept_event()
	elif show_on_desktop and event is InputEventMouseMotion and _touch_index == 0:
		_update_direction(event.position)
		accept_event()


func _draw() -> void:
	if not visible:
		return

	var center := _stick_center()
	draw_circle(center, STICK_RADIUS, Color(0.08, 0.1, 0.12, 0.32))
	draw_arc(center, STICK_RADIUS, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.38), 4.0)

	var knob_position := center + (_direction * STICK_RADIUS)
	draw_circle(knob_position, 34.0, Color(1.0, 1.0, 1.0, 0.45))
	draw_arc(knob_position, 34.0, 0.0, TAU, 32, Color(0.08, 0.1, 0.12, 0.55), 3.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_EXIT_TREE:
		_release_all_actions()


func _is_touch_device() -> bool:
	return DisplayServer.is_touchscreen_available() \
		or OS.has_feature("android") \
		or OS.has_feature("ios") \
		or OS.has_feature("web_android") \
		or OS.has_feature("web_ios")


func _is_in_stick_zone(position: Vector2) -> bool:
	return position.distance_to(_stick_center()) <= ACTIVATION_RADIUS


func _stick_center() -> Vector2:
	var viewport_size := get_viewport_rect().size
	return Vector2(EDGE_MARGIN, viewport_size.y - EDGE_MARGIN)


func _update_direction(position: Vector2) -> void:
	var offset := position - _stick_center()
	_direction = offset.limit_length(STICK_RADIUS) / STICK_RADIUS
	if _direction.length() < DEADZONE:
		_direction = Vector2.ZERO
	_apply_direction()
	queue_redraw()


func _reset_stick() -> void:
	_touch_index = -1
	_direction = Vector2.ZERO
	_release_all_actions()
	queue_redraw()


func _apply_direction() -> void:
	_set_action_strength(ACTION_LEFT, maxf(-_direction.x, 0.0))
	_set_action_strength(ACTION_RIGHT, maxf(_direction.x, 0.0))
	_set_action_strength(ACTION_UP, maxf(-_direction.y, 0.0))
	_set_action_strength(ACTION_DOWN, maxf(_direction.y, 0.0))


func _set_action_strength(action: String, strength: float) -> void:
	var applied_strength := 0.0 if strength < DEADZONE else strength
	if is_equal_approx(_action_strengths[action], applied_strength):
		return

	_action_strengths[action] = applied_strength
	if applied_strength > 0.0:
		Input.action_press(action, applied_strength)
	else:
		Input.action_release(action)


func _release_all_actions() -> void:
	for action in _action_strengths:
		_action_strengths[action] = 0.0
		Input.action_release(action)
