extends Node2D

@onready var player : Node = $Player
@onready var inv_ui : Node = $Inventory   #Inventario 

func _ready():
	inv_ui.set_inventory(player.inventory)
