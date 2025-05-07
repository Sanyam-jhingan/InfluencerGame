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

# Content-type labels for hints
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

func _ready():
	randomize_card_data()
	display_card()
	$ButtonContainer/AcceptButton.pressed.connect(_on_accept)
	$ButtonContainer/RejectButton.pressed.connect(_on_reject)

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

func _on_accept():
	swipe_accepted.emit(card_data)

func _on_reject():
	swipe_rejected.emit(card_data)
