extends Node

class_name OverlayOutput

const MAX_LOG_LINES = 7

var lines: Array[String] = []

@onready var output_label = $VBoxContainer/outputLabel

func log(line: String) -> void:
	lines.push_back(line)
	if lines.size() > MAX_LOG_LINES: lines.pop_front()
	output_label.text = "\n".join(lines)
