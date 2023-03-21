class_name Projectile
extends CharacterBody2D


# Projectile moves towards the target and disappears when it
# reaches the target.


signal target_hit(projectile, target)
signal interpolation_finished(projectile)

var _caster: Unit = null
var _target: Unit = null
var _last_known_position: Vector2 = Vector2.ZERO
var _speed: float = 100
const CONTACT_DISTANCE: int = 30
var _explosion_scene: PackedScene = preload("res://Scenes/Explosion.tscn")
var _game_scene: Node = null

var user_int: int = 0
var user_int2: int = 0
var user_int3: int = 0
var user_real: float = 0.0
var user_real2: float = 0.0
var user_real3: float = 0.0


# TODO: targeted - If true, projectile has "homing" behavior
# and follows unit as it moves. If false, projectile flies
# to position the unit had when create() was called.
#
# TODO: ignore_target_z - ignore target height value,
# projectile flies straight without changing it's height to
# match target height. Probably relevant to air units?
# 
# TODO: expire_when_reached - if true, overrides the
# "lifetime" property and expires when reaching target, no
# matter if lifetime is shorter or longer than the time it
# takes to reach the target
static func create_from_unit_to_unit(type: ProjectileType, caster: Unit, _damage_ratio: float, _crit_ratio: float, from: Unit, target: Unit, _targeted: bool, _ignore_target_z: bool, _expire_when_reached: bool) -> Projectile:
	var _projectile_scene: PackedScene = preload("res://Scenes/Projectile.tscn")
	var projectile: Projectile = _projectile_scene.instantiate()

	projectile._speed = type._speed

	if !type._hit_handler.is_null():
		projectile.set_event_on_target_hit(type._hit_handler)

	projectile._caster = caster
	projectile._target = target
	projectile.position = from.get_visual_position()
	projectile._game_scene = caster.get_tree().get_root().get_node("GameScene")

	projectile._game_scene.call_deferred("add_child", projectile)
	projectile._target.death.connect(projectile._on_target_death)

	return projectile


# TODO: implement actual interpolation, for now calling
# normal create()
static func create_linear_interpolation_from_unit_to_unit(type: ProjectileType, caster: Unit, damage_ratio: float, crit_ratio: float, from: Unit, target: Unit, _z_arc: float, targeted: bool) -> Projectile:
	return create_from_unit_to_unit(type, caster, damage_ratio, crit_ratio, from, target, targeted, false, true)


func _process(delta):
#	Move towards target
	var target_pos = _get_target_position()
	var pos_diff = target_pos - position
	var move_vector = _speed * pos_diff.normalized() * delta
	position += move_vector

	var distance: float = Utils.vector_isometric_length(pos_diff)
	var reached_target = distance < CONTACT_DISTANCE

	if reached_target:
		if _target != null:
			target_hit.emit(self, _target)

#			TODO: emit interpolation_finished() signal when
#			interpolation finishes.
			interpolation_finished.emit(self)

		var explosion = _explosion_scene.instantiate()
		explosion.position = global_position
		_game_scene.call_deferred("add_child", explosion)

		queue_free()


func get_target() -> Unit:
	return _target


func get_caster() -> Unit:
	return _caster


# NOTE: unlike buff and unit events, there's no weird stuff
# like trigger chances, so projectile events can be
# implemented as simple signals. These set_event() f-ns are
# still needed to match original API.

func set_event_on_target_hit(handler: Callable):
	target_hit.connect(handler)


func set_event_on_interpolation_finished(handler: Callable):
	interpolation_finished.connect(handler)


# TODO: original scale is not (1, 1), fix it
func setScale(scale_arg: float):
	scale = Vector2(scale_arg, scale_arg)


func _get_target_position() -> Vector2:
	if _target != null:
		var target_pos: Vector2 = _target.get_visual_position()

		return target_pos
	else:
		return _last_known_position


func _on_target_death(_event: Event):
	_last_known_position = _get_target_position()
	_target = null
