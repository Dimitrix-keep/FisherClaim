extends CanvasLayer
#Interfaz de inventario
var inventory : Inventory

func set_inventory(inv: Inventory) -> void:
	inventory = inv

func _process(_delta: float) -> void:
	if inventory:
		$VBoxContainer/ItemLabel.text = "Fish"
		$VBoxContainer/AmountLabel.text = str(inventory.get_item_amount("Fish"))
