extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	ElementDB.populate_db()
	FormulaDB.populate_db()
