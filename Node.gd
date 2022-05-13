extends Node

onready var input_number = $Label

func _ready():
	input_number.text = String(int(input_number.text) + 5)
