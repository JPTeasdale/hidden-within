extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Swords.connect("body_entered", self, "sword_body_eneterd")
	$CameraPath.set_player($Character)

func sword_body_eneterd(body):
	print("BODY", body.name)
	$Swords.disconnect("body_entered", self, "sword_body_eneterd")
	$Character.equip_left($LSword)
	$Character.equip_right($RSword)
	