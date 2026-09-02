extends Node2D

@onready var _mouse_down_sound: AudioStreamPlayer2D = %MouseDownSound
@onready var _mouse_up_sound: AudioStreamPlayer2D = %MouseUpSound
@onready var _button : Button = %TheButton
@onready var _canvas : CanvasLayer = %CanvasLayer
@onready var _cpuParticles : CPUParticles2D = %CPUParticles2D

var squash_and_stretch : bool = false
var camera_shake : bool = false
var particles : bool = false
var sound : bool = false
var shader : bool = false
var offset : bool = false
var tween : Tween

func _ready() -> void:
	# Set the buttons pivot to the bottom middle instead of default top left so it squashes downward
	_button.pivot_offset = Vector2(_button.size.x / 2.0, _button.size.y)
	
func _on_squash_toggled(toggled_on: bool) -> void:
	squash_and_stretch = toggled_on

func _on_shake_toggled(toggled_on: bool) -> void:
	camera_shake = toggled_on

func _on_particles_toggled(toggled_on: bool) -> void:
	particles = toggled_on

func _on_sound_toggled(toggled_on: bool) -> void:
	sound = toggled_on

func _on_shader_toggled(toggled_on: bool) -> void:
	shader = toggled_on
	
	if shader:
		var material : ShaderMaterial = ShaderMaterial.new()
		material.shader = load("res://Demo.gdshader")
		_button.material = material
	else:
		_button.material = null

func _on_offset_toggled(toggled_on: bool) -> void:
	offset = toggled_on

func _on_the_button_button_down() -> void:
	if shader:
		_button.material.set_shader_parameter("speed", 0.0)
	
	if sound:
		_mouse_down_sound.play()


func _on_the_button_button_up() -> void:
	if shader:
		_button.material.set_shader_parameter("speed", 2.0)
	if sound:
		_mouse_up_sound.play()

func _on_the_button_pressed() -> void:
	if squash_and_stretch:
		apply_squash_and_stretch()
	
	if camera_shake:
		add_trauma(2.0)
	
	if particles:
		_cpuParticles.emitting = true
	
func apply_squash_and_stretch() -> void:
	if tween: tween.kill() # Interrupt previous animation
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	# 1. Snap to squash pose
	tween.tween_property(_button, "scale", Vector2(1.2,0.4), 0.1)
	
	# 2. Return to normal
	tween.tween_property(_button, "scale", Vector2.ONE, 0.25)

#region Screenshake
# When not dealing with UI items, apply this script to the camera instead of the CanvasLayer
@export var decay = 0.99
@export var max_offset = Vector2(50, 40)
@export var max_roll = 0.3
var trauma = 0.0

func add_trauma(amount):
	trauma = min(trauma + amount, 0.6)
	
func _process(delta):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()
		
func shake():
	var amount = pow(trauma, 2)
	_canvas.offset.x = max_offset.x * amount * randf_range(-1, 1)
	_canvas.offset.y = max_offset.y * amount * randf_range(-1, 1)
	rotation = max_roll * amount * randf_range(-1, 1)
#endregion


func _on_the_button_mouse_entered() -> void:
	if offset:
		_button.offset_transform_enabled = true


func _on_the_button_mouse_exited() -> void:
	if offset:
		_button.offset_transform_enabled = false


func _on_theme_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_button.theme = load("res://kenney_button.tres")
	else:
		_button.theme = load("res://default_button.tres")
