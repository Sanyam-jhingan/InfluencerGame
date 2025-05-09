extends Node

# --- RebrandManager.gd ---
# Attach this to a global autoload singleton if possible

var rebrand_count := 0
var total_legacy_influence := 0

const REBRAND_THRESHOLD := 100000
const FOLLOWER_BONUS_PER_REBRAND := 0.10
const ENGAGEMENT_BONUS_PER_REBRAND := 0.05

func can_rebrand(current_followers: int) -> bool:
	return current_followers >= REBRAND_THRESHOLD

func perform_rebrand(current_followers: int):
	if not can_rebrand(current_followers):
		return

	rebrand_count += 1
	total_legacy_influence += calculate_legacy_points(current_followers)
	# Emit signal or call game reset here
	get_tree().call_group("game", "reset_game_state")

func calculate_legacy_points(followers: int) -> int:
	return int(followers / 10000)

func get_follower_bonus_multiplier() -> float:
	return 1.0 + (rebrand_count * FOLLOWER_BONUS_PER_REBRAND)

func get_engagement_bonus_multiplier() -> float:
	return 1.0 + (rebrand_count * ENGAGEMENT_BONUS_PER_REBRAND)
