extends Node
## Template controller untuk input karakter.
## Tugasnya cuma baca input lalu ngirim perintah gerak ke Entity.
class_name CharacterController

#region Konstanta
## Device default = keyboard / input utama
const DEFAULT_DEVICE := -1

## Batas kecil supaya analog stick tidak terlalu sensitif
const JOYPAD_DEADZONE := 0.2
#endregion

#region Referensi
## Karakter yang dikontrol.
## Node ini harus jadi parent dari controller.
@onready var Character : Entity = get_parent() as Entity
#endregion

#region Config Input
## Controller yang dipakai.
## Kalau DEFAULT_DEVICE, maka pakai keyboard.
@export var my_controller : int = DEFAULT_DEVICE
#endregion

#region Core
func _ready() -> void:
	## Cek apakah parent benar-benar Entity
	if Character == null:
		push_error("%s harus jadi child dari Entity." % name)
		set_process(false)
		set_process_unhandled_input(false)
		return

## Input, dipakai buat gerak kiri-kanan-atas-bawah, dan kalau tambahin tombol baru
func _process(_delta: float) -> void:
	if Character == null:
		return
	if my_controller == DEFAULT_DEVICE:
		_poll_default_input()
#lompat
		if Input.is_action_just_pressed("jump"):
			Character.jump()
	else:
		_poll_gamepad_input()
#endregion

#region Continuous Inputs
## Gerakan dari gamepad
func _poll_gamepad_input() -> void:
	var x_dir : float = Input.get_joy_axis(my_controller, JOY_AXIS_LEFT_X)
	var y_dir : float = Input.get_joy_axis(my_controller, JOY_AXIS_LEFT_Y)

	## Buang input kecil supaya stick tidak goyang sendiri
	if abs(x_dir) < JOYPAD_DEADZONE:
		x_dir = 0.0
	if abs(y_dir) < JOYPAD_DEADZONE:
		y_dir = 0.0

	## Run saat trigger kanan ditekan
	var run : bool = Input.get_joy_axis(my_controller, JOY_AXIS_TRIGGER_RIGHT) > 0.5

	## Kirim gerak topdown ke Entity
	Character.set_movement(Vector2(x_dir, y_dir), run)

## Gerakan dari keyboard
func _poll_default_input() -> void:
	var x_dir : float = 0.0
	var y_dir : float = 0.0

	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		x_dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		x_dir += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		y_dir -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		y_dir += 1.0
		
	## Run saat Left Shift ditekan
	var run : bool = Input.is_action_pressed("run")

	## Kirim gerak topdown ke Entity
	Character.set_movement(Vector2(x_dir, y_dir), run)

	## Kirim gerak topdown ke Entity
	Character.set_movement(Vector2(x_dir, y_dir), run)
#endregion
