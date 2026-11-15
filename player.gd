extends CharacterBody2D

var amountOfBrisket = 0
var startSpawns = 50
var press = 0
var charging = false
var angry = 0
var fed = 0
var end = false
var chase = 0

@onready var brisket = preload("res://brisket.tscn")
@onready var thrownBrisket = preload("res://thrownbrisket.tscn")
@onready var SheldonLeeCooperYouDawg = get_parent().get_node("SheldonLeeCooperYouDawg")
@onready var Sakupen = get_parent().get_node("Sakupen")
@onready var Escalator = get_parent().get_node("Escalator")
@onready var Victory = get_parent().get_node("Victory")
@export var death: CanvasLayer
@export var start: CanvasLayer
@export var george: CharacterBody2D
@export var WinByFeeding: CanvasLayer
@export var WinByChase: CanvasLayer

func _physics_process(delta):
	if end == true:
		return
		
	fed = fed + delta
	if fed >= 12:
		fed = 0
		george.playLate()
		makeGeorgeMad()
		
	if george.chasing == true:
		chase = chase + delta
		if chase >= 34:
			winByChase()
	
	if startSpawns >= 0:
		spawnBrisket()
		startSpawns = startSpawns - 1
	
	if $HeldBrisket.visible == true:
			if Input.is_action_pressed("ui_accept"):
					charging = true
					press = press + delta
					if press > 2.0:
						press = 2.0
			elif Input.is_action_just_released("ui_accept"):
				if charging == true:
					throwBrisket()
					
	var inputDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = inputDirection * 400
	move_and_slide()
	
	$CanvasLayer/Coordinates.text = "X: " + str(roundi(global_position.x)) + " Y: " + str(roundi(global_position.y))
	
func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("BrisketBoi") == true:
		if $HeldBrisket.visible == false:
			area.queue_free()
			$HeldBrisket.visible = true

func spawnBrisket():
	var newBrisket = brisket.instantiate()
	newBrisket.global_position = Vector2(randi_range(-4550, 4550), randi_range(-2600, 700))
	get_parent().add_child(newBrisket)
	print(str(newBrisket.global_position))
	
func throwBrisket():
	charging = false
	$Bazinga.play()
	$HeldBrisket.visible = false
	var mousePosition = get_global_mouse_position()
	var playerPosition = global_position
	var throwDirection = mousePosition - playerPosition
	throwDirection = throwDirection.normalized()
	var thrown = thrownBrisket.instantiate()
	var spawnPosition = global_position + (throwDirection * 30.0)
	thrown.global_position = spawnPosition
	get_parent().add_child(thrown)
	var throwSpeed = lerp(400.0, 1500.0, press / 2.0)
	press = 0.0
	thrown.linear_velocity = throwDirection * throwSpeed
	thrown.angular_velocity = randf_range(-10.0, 10.0)
	thrown.stoppedMoving.connect(spawnBrisket)
	thrown.scoredPoint.connect(func():
		amountOfBrisket = amountOfBrisket + 1
		$CanvasLayer/BrisketCount.text = "Brisket Value: " + str(amountOfBrisket)
	)

func _on_george_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		print("brisket touched george")
		fed = 0
		if body.foodState == "raw":
			print("ITS FOOKIN RAW")
			george.playRaw()
			makeGeorgeMad()
		elif body.foodState == "cooked":
			print("The best brisket in all of Texas")
			amountOfBrisket = amountOfBrisket + 1
			angry = max(0, angry - 1)
			george.playCooked()
			george.moreAnger(angry)
			$CanvasLayer/BrisketCount.text = "Brisket Value: " + str(amountOfBrisket)
			if amountOfBrisket >= 50:
				winByFeeding()
			print("How MAD George is: ", angry)
		elif body.foodState == "burnt":
			print("Connie you evil b-")
			george.playBurnt()
			makeGeorgeMad()
		body.queue_free()
		spawnBrisket()
		
func makeGeorgeMad():
	angry = angry + 1
	print("GEORGE ANGER: ", angry)
	george.moreAnger(angry)
	george.showAngry()
	if angry >= 10:
		george.startChasing()
		
func gameOver():
	if end == true:
		return
	end = true
	death.visible = true
	Sakupen.stop()
	SheldonLeeCooperYouDawg.play()
	print("George has turned you into brisket")


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_play_pressed() -> void:
	start.visible = false
	get_tree().paused = false
	
func _ready():
	get_tree().paused = true

func winByFeeding():
	if end == true:
		return
	end = true
	Sakupen.stop()
	Escalator.stop()
	await george.explode()
	WinByFeeding.visible = true
	Victory.play()

func winByChase():
	if end == true:
		return
	end = true
	Sakupen.stop()
	Escalator.stop()
	await george.explode()
	WinByChase.visible = true
	Victory.play()
