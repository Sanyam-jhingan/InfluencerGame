extends Control

signal swipe_accepted(card_data)
signal swipe_rejected(card_data)

var card_data = {
	"title": "Dance Challenge!",
	"description": "Join the latest viral TikTok dance challenge.",
	"reach": randi_range(10, 100),
	"risk": randf_range(0.1, 0.5)
}

func _ready():
	$TitleLabel.text = card_data.title
	$DescLabel.text = card_data.description
	$ButtonContainer/AcceptButton.pressed.connect(_on_accept)
	$ButtonContainer/RejectButton.pressed.connect(_on_reject)

func _on_accept():
	swipe_accepted.emit(card_data)

func _on_reject():
	swipe_rejected.emit(card_data)
