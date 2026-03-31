extends Node

@export var tersia_ability_scene: PackedScene

var base_damage = 10
var additional_damage_percent = 1


func _ready() -> void:
	$Timer.timeout.connect(on_timer_timeout)
	GameEvent.ability_upgrades_added.connect(on_ability_upgrades_added)
	

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	var tersia_instance = tersia_ability_scene.instantiate() as Node2D
	foreground.add_child(tersia_instance)
	tersia_instance.global_position = player.global_position
	tersia_instance.hitbox_component.damage = base_damage * additional_damage_percent


func on_ability_upgrades_added(upgrade:AbilityUpgrade,current_upgrades:Dictionary):
	if upgrade.id == "tersia_damage":
		additional_damage_percent = 1 + (current_upgrades["tersia_damage"]["quantity"]) * 0.1
