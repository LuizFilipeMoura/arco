# HealthManagement.gd
# Gerencia vida, cura e morte de qualquer personagem.
# Recebe via export a área (hurtbox) que dispara o dano.
class_name HealthManagement
extends Node2D

@export var max_health: int = 100
@export var hurtbox: NodePath  # Caminho para o Area2D que representa a hurtbox

signal damaged(amount: int)
signal healed(amount: int)
signal died()

var current_health: int

func _ready() -> void:
	current_health = max_health
	$HealthBar.init_bar(max_health)
	if hurtbox:
		var hb_node = get_node(hurtbox)
		if hb_node is Area2D:
			hb_node.connect("body_entered", Callable(self, "_on_hurtbox_body_entered"))
		else:
			push_warning("Assigned hurtbox is not an Area2D")
	else:
		push_warning("No hurtbox assigned to HealthManagement")

func damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	var prev_health = current_health
	current_health = max(current_health - amount, 0)
	emit_signal("damaged", amount)
	$HealthBar.update_bar(current_health)
	if current_health <= 0 and prev_health > 0:
		die()

func heal(amount: int) -> void:
	if amount <= 0 or current_health >= max_health:
		return
	var actual_heal = min(amount, max_health - current_health)
	current_health += actual_heal
	$HealthBar.update_bar(current_health)
	emit_signal("healed", actual_heal)

func die() -> void:
	emit_signal("died")
	# Desativa processamento e colisões após a morte
	set_process(false)
	if hurtbox:
		var hb_node = get_node(hurtbox)
		if hb_node is Area2D:
			hb_node.monitoring = false

func _on_hurtbox_body_entered(body: Node) -> void:
	# Supondo que o corpo que causa dano tenha uma propriedade `damage_amount`
	if body.has_meta("damage_amount"):
		damage(body.get_meta("damage_amount"))
	elif body.has_method("get_damage_amount"):
		damage(body.get_damage_amount())
