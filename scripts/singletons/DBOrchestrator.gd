extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	ElementDB.populate_db()
	FormulaDB.populate_db()
