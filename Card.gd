extends Control

signal swipe_accepted(card_data)
signal swipe_rejected(card_data)

var card_data = {
	"title": "",
	"description": "",
	"reach": 0,
	"risk": 0.0,
	"content_type": null,
	"quality_score": 0.0
}

var titles_by_type = {
	"BRAND": ["Sponsored Unboxing", "Ad Deal: Energy Drink", "Brand Q&A"],
	"TREND": ["Dance Challenge!", "Meme Remix", "Trend Alert 🚨"],
	"VLOG": ["Morning Routine", "Day in Life", "Vlog: Behind Scenes"],
	"CHALLENGE": ["24h Challenge", "Extreme Reaction", "Collab Chaos"]
}

var desc_by_type = {
	"BRAND": ["Promote a product for a brand.", "Paid ad with target audience.", "Branded content opportunity."],
	"TREND": ["Viral content circulating online.", "Jump on the latest social meme.", "Might pop off—might flop."],
	"VLOG": ["Authentic day-to-day content.", "Fans love seeing the real you.", "Longer format video."],
	"CHALLENGE": ["Trending challenge with big risks.", "High payoff, high controversy.", "Can you pull it off?"]
}

var drag_start = Vector2.ZERO
var dragging = false
var threshold = 150
var initial_position = Vector2.ZERO

# References to screen-edge glow overlays
@onready var accept_glow = get_node("/root/Main/AcceptGlow")
@onready var reject_glow = get_node("/root/Main/RejectGlow")

func _ready():
	initial_position = position
	randomize_card_data()
	display_card()

	if $ButtonContainer:
		$ButtonContainer.visible = false

	set_process_input(true)
	reset_glow()

func randomize_card_data():
	var types = ["BRAND", "TREND", "VLOG", "CHALLENGE"]
	var picked_type = types[randi() % types.size()]

	card_data.content_type = picked_type
	card_data.title = titles_by_type[picked_type][randi() % titles_by_type[picked_type].size()]
	card_data.description = desc_by_type[picked_type][randi() % desc_by_type[picked_type].size()]
	card_data.reach = randi_range(50, 300)
	card_data.risk = randf_range(0.0, 0.6)
	card_data.quality_score = randf_range(0.0, 1.0)

func display_card():
	$TitleLabel.text = card_data.title
	$DescLabel.text = card_data.description

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		drag_start = event.position
		dragging = true
		scale_card(true)

	elif event is InputEventMouseMotion and dragging:
		var offset = event.position - drag_start
		position.x += offset.x * 0.3
		rotation_degrees = position.x / 20.0
		update_glow()

	elif event is InputEventMouseButton and not event.pressed:
		dragging = false
		handle_swipe()
		scale_card(false)
		reset_glow()

func handle_swipe():
	if position.x > threshold:
		accept()
	elif position.x < -threshold:
		reject()
	else:
		reset_card_position()

func accept():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(500, 0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_emit_accept"))

func reject():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(-500, 0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_emit_reject"))

func _emit_accept():
	swipe_accepted.emit(card_data)
	queue_free()

func _emit_reject():
	swipe_rejected.emit(card_data)
	queue_free()

func reset_card_position():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", initial_position, 0.35)
	tween.parallel().tween_property(self, "rotation_degrees", 0.0, 0.35)

func scale_card(expand: bool):
	var tween = get_tree().create_tween()
	var target_scale = Vector2(1.05, 1.05) if expand else Vector2(1.0, 1.0)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, 0.2)

# ===== Glows =====

func update_glow():
	var swipe_offset = position.x - initial_position.x
	var alpha = clamp(abs(swipe_offset) / 250.0, 0.0, 1.0)

	if swipe_offset > 0:
		accept_glow.modulate.a = alpha
		reject_glow.modulate.a = 0.0
	elif swipe_offset < 0:
		reject_glow.modulate.a = alpha
		accept_glow.modulate.a = 0.0
	else:
		reset_glow()

func reset_glow():
	accept_glow.modulate.a = 0.0
	reject_glow.modulate.a = 0.0
