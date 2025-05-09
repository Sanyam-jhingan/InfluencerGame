extends Control

# UI Nodes
@onready var follower_label = $FollowerPanel/FollowerLabel
@onready var engagement_label = $FollowerPanel/EngagementLabel
@onready var card_container = $CardContainer
@onready var result_label = $ResultLabel
@onready var rebrand_button = $RebrandButton

# Game Variables
var followers = 100
var engagement = 10.0
var current_card = null

# Prestige System: Rebranding
var rebrand_tokens = 0
var rebrand_available = false
var rebrand_engagement_streak = 0
const REBRAND_FOLLOWER_REQUIREMENT = 10000
const REQUIRED_ENGAGEMENT_STREAK = 10
const REQUIRED_ENGAGEMENT_THRESHOLD = 20.0
var brand_deal_completed = false

# Algorithm Update System
enum FavoredContent { TREND, BRAND, VLOG, CHALLENGE }
var current_favored = FavoredContent.TREND
var algorithm_timer := Timer.new()

# Brand Deal System
var brand_deals = []
var active_deal = null

func _ready():
	update_stats()
	generate_new_card()

	# Setup algorithm timer
	add_child(algorithm_timer)
	algorithm_timer.wait_time = 30
	algorithm_timer.autostart = true
	algorithm_timer.timeout.connect(_on_algorithm_shift)

	offer_brand_deal()
	rebrand_button.disabled = false
	rebrand_button.pressed.connect(_on_rebrand_pressed)

func update_stats():
	follower_label.text = "Followers: %d" % followers
	engagement_label.text = "Engagement: %.1f%%" % engagement
	rebrand_button.disabled = not check_rebrand_conditions()

func generate_new_card():
	if current_card and is_instance_valid(current_card):
		current_card.queue_free()
		await get_tree().process_frame

	var card = preload("res://Card.tscn").instantiate()
	var content_types = FavoredContent.values()
	var content_type = content_types[randi() % content_types.size()]
	card.card_data = {
		"reach": randi_range(50, 300),
		"risk": randf_range(0.0, 0.6),
		"content_type": content_type,
		"quality_score": randf_range(0.0, 1.0)
	}
	card_container.add_child(card)
	card.swipe_accepted.connect(_on_card_accepted)
	card.swipe_rejected.connect(_on_card_rejected)
	current_card = card

func flash_glow(is_accept: bool):
	var glow = $AcceptGlow if is_accept else $RejectGlow
	var tween = get_tree().create_tween()
	glow.modulate.a = 0.0
	tween.tween_property(glow, "modulate:a", 1.0, 0.1)
	tween.tween_interval(0.1)
	tween.tween_property(glow, "modulate:a", 0.0, 0.2)

func _on_card_accepted(card_data):
	flash_glow(true)
	var score = evaluate_card(card_data)
	var quality = card_data.quality_score

	if quality > 0.4:
		followers += int(score * quality)
		engagement += randf_range(0.1, 1.0) * quality
		result_label.text = "👍 Great choice!"
		if engagement >= REQUIRED_ENGAGEMENT_THRESHOLD:
			rebrand_engagement_streak += 1
			if rebrand_engagement_streak >= REQUIRED_ENGAGEMENT_STREAK:
				rebrand_tokens += 1
				rebrand_engagement_streak = 0
				result_label.text += " ✨ Earned a Rebrand Token!"
	else:
		followers -= int((1.0 - quality) * 50)
		engagement -= randf_range(0.3, 1.0) * (1.0 - quality)
		rebrand_engagement_streak = 0
		result_label.text = "⚠️ Low-quality post! You lost followers."

	if active_deal and FavoredContent.has(card_data.content_type) and FavoredContent[card_data.content_type] == active_deal.requirement:
		complete_brand_deal()

	update_stats()
	generate_new_card()

func _on_card_rejected(card_data):
	flash_glow(false)
	var score = evaluate_card(card_data)
	if score < 50:
		result_label.text = "🚫 Good call. That post would’ve flopped!"
	else:
		result_label.text = "👎 Missed opportunity."
		followers -= int(card_data.risk * 5)
		engagement -= randf_range(0.2, 0.5)
		rebrand_engagement_streak = 0

	update_stats()
	generate_new_card()

func _on_algorithm_shift():
	var options = FavoredContent.values()
	current_favored = options[randi() % options.size()]
	print("📣 Algorithm update! Favored content is now:", current_favored)

func evaluate_card(card_data):
	var base_score = card_data.reach * (1.0 - card_data.risk)
	if card_data.content_type == FavoredContent.keys()[current_favored]:
		base_score *= 1.5
	return base_score

# ----- Brand Deal System -----

func offer_brand_deal():
	var deal = {
		"brand": "Zappa Cola",
		"requirement": FavoredContent.BRAND,
		"reward": 1000,
		"risk": 0.3
	}
	brand_deals.append(deal)
	show_brand_offer(deal)

func accept_brand_deal(deal):
	active_deal = deal
	brand_deals.erase(deal)
	print("✅ Accepted brand deal with ", deal.brand)

func complete_brand_deal():
	if active_deal:
		followers += active_deal.reward
		result_label.text = "💰 Brand deal completed!"
		print("🎉 Brand deal complete! Followers gained.")
		brand_deal_completed = true
		active_deal = null

func show_brand_offer(deal):
	print("💼 New Brand Deal Offer: %s wants %s content" % [deal.brand, deal.requirement])
	accept_brand_deal(deal)

# ----- Rebrand System -----

func check_rebrand_conditions() -> bool:
	return followers >= REBRAND_FOLLOWER_REQUIREMENT and brand_deal_completed and rebrand_tokens > 0

func show_rebrand_hint():
	var reasons = []

	if followers < REBRAND_FOLLOWER_REQUIREMENT:
		reasons.append("- Reach at least %d followers (you have %d)" % [REBRAND_FOLLOWER_REQUIREMENT, followers])

	if active_deal != null:
		reasons.append("- Complete your current brand deal with %s" % active_deal.brand)

	if rebrand_tokens < 1:
		reasons.append("- Earn at least 1 Rebrand Token by keeping high engagement on multiple good posts")

	var hint_text = "You can't Rebrand yet:\n\n" + "\n".join(reasons)
	$RebrandHintPopup/RebrandHintLabel.text = hint_text
	$RebrandHintPopup.popup_centered()

func _on_rebrand_pressed():
	print("Rebrand button pressed")
	if not check_rebrand_conditions():
		show_rebrand_hint()
		return

	followers = 100
	engagement = 10.0
	rebrand_tokens -= 1
	brand_deal_completed = false
	rebrand_engagement_streak = 0
	result_label.text = "🔄 You rebranded! Growth bonuses applied."

	# Apply prestige bonuses (placeholder - customize later)
	# Example: +10% permanent follower gain multiplier (not yet implemented)
	update_stats()
	generate_new_card()
