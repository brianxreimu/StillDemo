##class ini merupakan turunan dari CharacterBody2D
extends CharacterBody2D

## Basic buat semua entity 2d. isinya stat karakter and meta data.
## [br]
## juga buat ngatur logika inti, seperti:[br]
## - [i]Gravity[/i][br]
## - [i]Face Direction (and a fixed Container for RayCasts)[/i][br]
## - [i]Hitpoint[/i][br]
## - [i]Movement karakter[/i][br]
## - [i]Kontrol animasi[/i][br]
## - [i]Basic Audio[/i][br]
class_name Entity

#region Stat Karakter
## tipe karakter sebuah entity
enum character_type {
	## karakter hero
	Hero,
	## temen karakter hero
	Ally,
	## karakter netral
	Civillian,
	## musuh
	Enemy,
	## Boss
	Boss
}

## Tipe serangan utama karakter
enum attack_type {
	## gabisa nyerang
	None,
	## karakter secara default pakai melee
	Melee,
	## pakai serangan proyektil secara default
	Projectile
}

## Gambar karakter[br]
## ini buat nanti bikin karakter yang di HUD ama selector karakter
@export var avatar : Texture2D
## tampilan nama karakternya[br]
## sama sih kek yang di atas
@export var title : String
## Type entity karakternya[br]
## intinya itu buat bikin karakter!
@export var type : character_type
## Tipe serangan utama karakter[br]
## ini buat bikin karakter juga
@export var attack : attack_type
@export_group("Stats")
## HP max yang bakal dimiliki karakter[br]
@export var Hit_Points : float
## Kecepatan jalan karakternya[br]
@export var Walk_Speed : float
## Kecepatan lari karakter[br]
@export var Run_Speed : float
## The upwards velocity at which the character jumps[br]
@export var Jump_Velocity : float
## jangkauan serangan karakter[br][br]
## yaaa buat bikin karakter
@export var Attack_Range : float
## laju karakter
@export var Acceleration : float = 1000
#endregion

#region Meta
## dipakai kalau karakter spawn
signal spawned(Entity: Entity)
## dipakai kalau karakternya gerak, jalan / lari
signal moved(dir: float, run : bool)
## dipakai kalau karakter lompat
signal jumped
## dipakai kalau karakter kena damage
signal hurt(amount: float)
## dipakai kalau karakter mati
signal died

@export_category("Meta")
## boolean buat disable gravity karakter
@export var gravity : bool = true
## boolean buat disable AI bawaan karakter
@export var puppet : bool = false
## referensi buat [CollisionShape2D] karakternya
@export var collider : CollisionShape2D
@export_group("Animation Names", "ANM_N")
## Nama animasi buat jalan[br]
@export var ANM_N_Walk : String
## Nama animasi buat lari[br]
@export var ANM_N_Run : String
## Nama animasi buat lompat[br]
@export var ANM_N_Jump : String
## Nama animasi kalau kena damage[br]
@export var ANM_N_Hurt : String
## Nama Animasi buat sekarat[br]
@export var ANM_N_Die : String
## list nama semua animasi yang bakal otomatis pause gerakan karakternya[br]
@export var ANM_N_auto_pause_movement : Array
@export_group("Animation Player", "ANM_P")
## referensi [AnimatedSprite2D] buat karakter
@export var ANM_P_Animated_Sprite : AnimatedSprite2D
## referensi [AnimationPlayer] buat karakter
@export var ANM_P_Animation_Player : AnimationPlayer
## referensi [AnimationTree] buat karakter
@export var ANM_P_Animation_Tree : AnimationTree
@export_group("Sound Effects", "SFX")
## Referensi buat [AudioStreamPlayer2D] kalau karakternya spawn
@export var SFX_Spawn : AudioStreamPlayer2D
## Referensi buat [AudioStreamPlayer2D] kalau karakternya jalan biasa
@export var SFX_Walk : AudioStreamPlayer2D
## Referensi buat [AudioStreamPlayer2D] to kalau karakternya lari
@export var SFX_Run : AudioStreamPlayer2D
## Referensi ke [AudioStreamPlayer2D] buat jalan kalau karakternya lompat
@export var SFX_Jump : AudioStreamPlayer2D
## Referensi ke [AudioStreamPlayer2D] buat jalan kalau karakter kena damage
@export var SFX_Hurt : AudioStreamPlayer2D
## Referensi ke [AudioStreamPlayer2D] buat jalan kalau karakter mati
@export var SFX_Die : AudioStreamPlayer2D

## buat enable/disable warning node yang ilang
@export var show_warnings : bool = true

## buat cek kalau ada node atau path yang ilang atau programnya eror ya!
func check_nodes():
	if not show_warnings: return
	var t = "%s (%s)" % [title if title != "" else "Untitled Entity", name]
	if not collider: push_warning("%s Collider MISSING" % t)
	if not ANM_P_Animated_Sprite: push_warning("%s ANM_P_Animated_Sprite nya gaada / MISSING!" % t)
	else:
		if not ANM_P_Animated_Sprite.sprite_frames: push_warning("%s gaada sprite frames" % t)
		else:
			if not anim_exists(ANM_N_Walk): push_warning("%s ga punya '%s' %s animasi" % [t, ANM_N_Walk, "(Walk)"])
			if not anim_exists(ANM_N_Run):  push_warning("%s ga punya '%s' %s animasi" % [t, ANM_N_Run,  "(Run)"])
			if not anim_exists(ANM_N_Jump): push_warning("%s ga punya '%s' %s animasi" % [t, ANM_N_Jump, "(Jump)"])
			if not anim_exists(ANM_N_Hurt): push_warning("%s ga punya '%s' %s animasi" % [t, ANM_N_Hurt, "(Hurt)"])
			if not anim_exists(ANM_N_Die):  push_warning("%s ga punya '%s' %s animasi" % [t, ANM_N_Die,  "(Die)"])
	if not ANM_P_Animation_Player: push_warning("%s ANM_P_Animation_Player nya MISSING!" % t)
	if not ANM_P_Animation_Tree: push_warning("%s ANM_P_Animation_Tree nya MISSING" % t)
	if not SFX_Spawn: push_warning("%s SFX_Spawn MISSING" % t)
	if not SFX_Walk: push_warning("%s SFX_Walk MISSING" % t)
	if not SFX_Run: push_warning("%s SFX_Run MISSING" % t)
	if not SFX_Jump: push_warning("%s SFX_Jump MISSING" % t)
	if not SFX_Hurt: push_warning("%s SFX_Hurt MISSING" % t)
	if not SFX_Die: push_warning("%s SFX_Die MISSING" % t)
#endregion

#region Core / inti (ini masih dibenerin!)
## kondisi hp karakter disaat itu juga
var hp : float
## node2d ini harusnya buat rpg platformer, aku salah ambil referensi harusnya top down[br]
## kurang tau juga fungsinya apaan, yang ini aku ambil mentah
var RayBox : Node2D
## yaa hal tentang platformer intinya
var facing : int = 1

func _ready() -> void:
	check_nodes()
	hp = Hit_Points
	RayBox = Node2D.new()
	add_child.call_deferred(RayBox)
	if SFX_Spawn: SFX_Spawn.play()
	spawned.emit(self)

func _physics_process(delta: float) -> void:
	if not is_on_floor() and gravity: velocity += get_gravity() * delta
	velocity.x = move_toward(velocity.x, move_x, delta*Acceleration)
	move_and_slide()

## buat ganti arah
func flip() -> void:
	facing *= -1
	scale.x *= -1
	RayBox.scale.x = facing
#endregion

#region gerakan / movement (ini belum jadi ya!)
## Boolean yang paksa buat pause gerakan karakter
var force_pause : bool = false
## 
var move_x : float = 0

## harusnya buat pause karakter juga !
func pause_movement() -> bool:
	var is_paused := false
	if force_pause: is_paused = true
	for anim in ANM_N_auto_pause_movement: if check_anim(anim): is_paused = true
	if is_paused: velocity.x = 0
	return is_paused

## buat berhentiin gerakan karakter untuk sementara
func quick_pause(duration : float = 0.3) -> void:
	force_pause = true
	await get_tree().create_timer(duration).timeout
	force_pause = false

## buat gerakin karakter (jalan atau lari entahlah)
#func move(x_dir : float, run : bool = false) -> void:
	#if x_dir * facing < 0 : flip()
	#if pause_movement(): return
	#var delta = get_physics_process_delta_time()
	#if x_dir != 0:
		#if run:
			#move_x = x_dir * Run_Speed * delta * 60
			#if is_on_floor():
			#	start_anim(ANM_N_Run)
			#	moved.emit(x_dir, true)
			#	if SFX_Run: SFX_Run.play()
			#	if SFX_Walk: SFX_Walk.stop()
		#else:
			#move_x = x_dir * Walk_Speed * delta * 50
		#	if is_on_floor():
			#	start_anim(ANM_N_Walk)
			#	moved.emit(x_dir, false)
			#	if SFX_Run: SFX_Run.stop()
			#	if SFX_Walk: SFX_Walk.play()
	#else:
		#move_x = 0
		#if SFX_Run: SFX_Run.stop()
		#if SFX_Walk: SFX_Walk.stop()

## buat bikin karakternya lompat
func jump(force := Jump_Velocity) -> void:
	if pause_movement() or not is_on_floor() or check_anim(ANM_N_Jump): return
	velocity.y -= force
	start_anim(ANM_N_Jump, true)
	if SFX_Jump: SFX_Jump.play()
	jumped.emit()
#endregion

#region HP
## Instant kill
func kill() -> void:
	damage(hp)

## buat nge-damage ke karakternya yaa
func damage(amount: float) -> void:
	if hp <= 0: return
	hp -= amount
	velocity.x = 0
	if hp <= 0: _die()
	else:
		start_anim(ANM_N_Hurt, true)
		if SFX_Hurt: SFX_Hurt.play()
		hurt.emit(amount)

## Ini kalau karakternya tewas
func _die():
	set_process(false)
	set_physics_process(false)
	velocity.x = 0
	name = str(title + "-dead_" + str(randi()))
	collider.set_deferred("disabled", true)
	if SFX_Die:
		SFX_Die.play()
		force_anim(ANM_N_Die)
		await get_tree().create_timer(max(SFX_Die.stream.get_length(), ANM_P_Animation_Player.get_animation("die").length), false).timeout
	else: await force_anim(ANM_N_Die)
	died.emit()
	queue_free()
#endregion

#region Animasi
## ini program yang cek kalau animasi nya ada atau ngga
func anim_exists(animation : String) -> bool:
	return ANM_P_Animated_Sprite and ANM_P_Animated_Sprite.sprite_frames.has_animation(animation)

## buat cek kalau ada animasi yang jalan
func check_anim(animation : String) -> bool:
	return ANM_P_Animated_Sprite and ANM_P_Animated_Sprite.animation == animation

## Cek kalau ada frame yang lagi jalan
func check_frame(animation : String, frame : int) -> bool:
	return ANM_P_Animated_Sprite and ANM_P_Animated_Sprite.animation == animation and ANM_P_Animated_Sprite.frame == frame

## Cek kalau animasi ada di frame terakhir saat itu
func check_anim_end(animation : String) -> bool:
	return ANM_P_Animated_Sprite and ANM_P_Animated_Sprite.animation == animation and ANM_P_Animated_Sprite.frame == ANM_P_Animated_Sprite.sprite_frames.get_frame_count(animation) - 1

## tunggu sampai yakin ada frame yang jalan
func await_frame(animation: String, frame : int) -> void:
	while ANM_P_Animated_Sprite and !check_frame(animation, frame):
		if not get_tree(): break
		await get_tree().process_frame
	return

## tunggu sampai yakin animasi selesai
func await_anim_end(animation: String) -> void:
	while ANM_P_Animated_Sprite and !check_anim_end(animation):
		if not get_tree(): break
		await get_tree().process_frame
	return

## buat memicu pindah animasi
func start_anim(animation : String, force : bool = false) -> void:
	if ANM_P_Animation_Tree:
		if force: ANM_P_Animation_Tree.get("parameters/playback").start(animation)
		else: ANM_P_Animation_Tree.get("parameters/playback").travel(animation)
	elif ANM_P_Animated_Sprite: ANM_P_Animated_Sprite.play(animation)

## paksa animasinya mulai dan tunggu sampai selesai
func force_anim(animation : String) -> void:
	while ANM_P_Animated_Sprite and !check_anim_end(animation):
		if not check_anim(animation): start_anim(animation, true)
		if not get_tree(): break
		await get_tree().process_frame
	return
#endregion
