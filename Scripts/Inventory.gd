class_name Inventory
extends Node

#Funciones del Inventario
var items : Dictionary = {}

func add_item(item_name: String, amount: int = 1) -> void:
	if items.has(item_name):
		items[item_name] += amount
	else:
		items[item_name] = amount

func remove_item(item_name: String, amount: int = 1) -> void:
	if items.has(item_name):
		items[item_name] -= amount
		if items[item_name] <= 0:
			items.erase(item_name)

func get_item_amount(item_name: String) -> int:
	return items.get(item_name, 0)
