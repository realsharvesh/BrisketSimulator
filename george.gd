extends CharacterBody2D

@export var chaseSpeed = 200
@export var player: CharacterBody2D
var chasing = false
@onready var normalFace = $Sprite2D.texture
@onready var angryFace = preload("res://GeorgeAngry.png")
@onready var backgroundMusic = get_parent().get_node("Escalator")
@onready var chaseMusic = get_parent().get_node("Sakupen")

func startChasing():
	if chasing == true:
		return
	chasing = true
	$Sprite2D.texture = angryFace
	backgroundMusic.stop()
	chaseMusic.play()
	print("george is mad and chasing you")
	
func _physics_process(delta):
	if chasing == false:
		return
	if player == null:
		return
	var distance = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * chaseSpeed
	move_and_slide()
	for i in get_slide_collision_count():
		if get_slide_collision(i).get_collider() == player:
			player.gameOver()
			return

				
func moreAnger(angerAmount):
	$Angry.value = angerAmount
	
func showAngry():
	print("called showAngry")
	$Sprite2D.texture = angryFace
	await get_tree().create_timer(1.0).timeout
	if chasing == false:
		$Sprite2D.texture = normalFace

func playRaw():
	$Raw.play()
	
func playBurnt():
	$Burnt.play()
	
func playLate():
	$Late.play()
	
func playCooked():
	$Cooked.play()
	
func explode():
	chasing = false
	$Sprite2D.visible = false
	$Angry.visible = false
	$Bigboom.visible = true
	$Oppenheimer.play()
	await get_tree().create_timer(1.5).timeout
