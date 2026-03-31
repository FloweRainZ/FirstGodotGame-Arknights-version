extends Node

@export var experience_manager : Node
@export var upgrade_screen_scene : PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var upgrade_tersia = preload("res://resources/upgrades/tersia.tres")
var upgrade_tersia_damage = preload("res://resources/upgrades/tersia_damage.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_tear = preload("res://resources/upgrades/tear.tres")
var upgrade_tear_count = preload("res://resources/upgrades/tear_count.tres")


func _ready() -> void:
	upgrade_pool.add_item(upgrade_tersia, 10)
	upgrade_pool.add_item(upgrade_tear, 10)
	upgrade_pool.add_item(upgrade_sword_rate, 10)
	upgrade_pool.add_item(upgrade_sword_damage, 10)
	upgrade_pool.add_item(upgrade_player_speed, 5)
	experience_manager.level_up.connect(on_level_up)


func apply_upgrade(upgrade:AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	#首次获取 → 初始化记录
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource" : upgrade,
			"quantity" : 1
		}
	#重复获取 → 增加数量
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	update_upgrade_pool(upgrade)
	GameEvent.emit_ability_upgrades_added(upgrade,current_upgrades)


func update_upgrade_pool(chosen_upgrade:AbilityUpgrade):
	if chosen_upgrade.id == upgrade_tersia.id:
		upgrade_pool.add_item(upgrade_tersia_damage,10)
	elif chosen_upgrade.id == upgrade_tear.id:
		upgrade_pool.add_item(upgrade_tear_count, 5)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	for i in 2:
		if upgrade_pool.items.size()==chosen_upgrades.size():
			break
		var chosen_upgrade = upgrade_pool.pick_item()
		chosen_upgrades.append(chosen_upgrade)
		#filtered_upgrades = filtered_upgrades.filter(func (upgrade): return upgrade.id != chosen_upgrade.id)
		
	return chosen_upgrades


func on_upgrade_selected(upgrade:AbilityUpgrade):
	apply_upgrade(upgrade)


func on_level_up(current_level:int):
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
	
