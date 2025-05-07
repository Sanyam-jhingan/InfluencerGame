extends Control

# UI Nodes
@onready var follower_label = $FollowerPanel/FollowerLabel
@onready var engagement_label = $FollowerPanel/EngagementLabel
@onready var card_container = $CardContainer
@onready var result_label = $ResultLabel

# Game Variables
var followers = 100
var engagement = 10.0
var current_card = null

func _ready():
	update_stats()
	generate_new_card()

func update_stats():
	follower_label.text = "Followers: %d" % followers
	engagement_label.text = "Engagement: %.1f%%" % engagement

func generate_new_card():
	if current_card:
		current_card.queue_free()

	var card = preload("res://Card.tscn").instantiate()
	card_container.add_child(card)
	card.swipe_accepted.connect(_on_card_accepted)
	card.swipe_rejected.connect(_on_card_rejected)
	current_card = card

func _on_card_accepted(card_data):
	followers += card_data.reach
	engagement += randf_range(0.1, 1.0)
	result_label.text = "👍 Great choice!"
	update_stats()
	generate_new_card()

func _on_card_rejected(card_data):
	followers -= int(card_data.risk * 5)
	engagement -= randf_range(0.2, 0.5)
	result_label.text = "👎 Missed opportunity."
	update_stats()
	generate_new_card()
