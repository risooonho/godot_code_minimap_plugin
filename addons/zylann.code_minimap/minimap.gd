tool
extends ColorRect


var _text_edit = null
var _dragging = false
var _char_height = 2
var _line_spacing = 1


func _ready():
	color = Color(0, 0, 0, 0.15)
	var sb = get_scrollbar()
	sb.connect("value_changed", self, "_on_scrollbar_value_changed")


func set_text_edit(text_edit):
	_text_edit = text_edit
	_text_edit.connect("cursor_changed", self, "_on_text_edit_cursor_changed")


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			
			if event.button_index == BUTTON_LEFT:
				_scroll(event.position.y)
			
			if not _dragging:
				_dragging = true
		else:
			_dragging = false
	
	elif event is InputEventMouseMotion:
		if _dragging:
			_scroll(event.position.y)


func _scroll(mouse_y):
	var rh = _get_region_height()
	var line = _pixel_to_line(mouse_y - rh / 2)
	var scrollbar = get_scrollbar()
	scrollbar.value = line


func _pixel_to_line(y):
	y *= _get_pan_multiplier()
	return float(y) / float(_get_line_height())


func _get_pan_multiplier():
	var mvl = _get_max_visible_lines()
	var lc = get_scrollbar().max_value - get_scrollbar().min_value
	if lc > mvl:
		return (lc / mvl)
	return 1.0


func _get_max_visible_lines():
	return rect_size.y / _get_line_height()


func _get_line_height():
	return _char_height + _line_spacing


func _on_scrollbar_value_changed(v):
	# v is the line number at the top of TextEdit
	update()


func _on_text_edit_cursor_changed():
	update()


func get_scrollbar():
	return get_parent()


func _get_region_height():
	# TODO I need the amount of lines the textedit can show...
	var ratio = _text_edit.rect_size.x / _text_edit.rect_size.y
	return rect_size.x / ratio


func _draw():
	if _text_edit == null:
		print("No textedit!")
		return
	
	var sb = get_scrollbar()
	
	var offset = sb.ratio * rect_size.y * (_get_pan_multiplier() - 1.0)
	
	var rh = _get_region_height()
	draw_rect(Rect2(0, sb.value * 3.0 - offset, rect_size.x, rh), Color(1,1,1,0.1))
	
	if _text_edit != null:
		draw_map(self, _text_edit, _char_height, _line_spacing, offset)


static func draw_map(control, text_edit, char_h, spacing, offset):
	var char_w = 1
	
	var width = control.rect_size.x
	var height = control.rect_size.y
	
	var visible_line_count = int(height) / (char_h + spacing)
	
	# TODO Optimize out drawing region
	
	var line_height = char_h + spacing
	control.draw_rect(Rect2(0, text_edit.cursor_get_line() * line_height - offset, width, line_height), Color(0.7,0.7,0.7,1.0))
	
	var y = -offset
	for i in text_edit.get_line_count():
		
		if text_edit.is_folded(i):
			continue
		
		var line = text_edit.get_line(i)
		line = line.to_utf8()
		var x = 0
		
		for j in len(line):
			
			if x >= width:
				break
			
			var c = line[j]
			
			if c == 32:
				x += char_w
				continue
				
			if c == 9:
				x += 4 * char_w
				continue
			
			control.draw_rect(Rect2(x, y, char_w, char_h), Color(1,1,1,0.5))
			x += 1
						
		y += line_height

