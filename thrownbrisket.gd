extends RigidBody2D

var bounceAmount = 0
var foodState = "raw"
var hasBounced: bool = false
var timeAlive: float = 0.0
signal scoredPoint
signal stoppedMoving
var count = 0
@export var raw: Texture2D
@export var cooked: Texture2D
@export var burnt: Texture2D
@onready var brisket = $Sprite2D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	brisket.texture = raw

func _physics_process(thing: float) -> void:
	timeAlive = timeAlive + thing
	if timeAlive > 0.2:
		var velocty = linear_velocity.length()
		if velocty < 25.0:
			stoppedMoving.emit()
			queue_free()

func _on_body_entered(body: Node) -> void:
	var georgeCooper = false
	if body.name.to_lower().contains("george"):
		georgeCooper = true
	if body.is_in_group("george"):
		georgeCooper = true
		
	if georgeCooper == false:
		hasBounced = true
		count = count + 1
		print("BOUNCES: ", count)
		
		if count > 1:
			foodState = "burnt"
			brisket.texture = burnt
		else:
			foodState = "cooked"
			brisket.texture = cooked
	
	# zach was here
	
func _on_area_entered(area: Area2D) -> void:
	print("touched an area", area.name)
	if area.name == "Mouth":
		print("george has been fed")
		if hasBounced == true:
			scoredPoint.emit()
		queue_free()
