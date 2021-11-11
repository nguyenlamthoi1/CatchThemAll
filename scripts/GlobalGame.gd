extends Node

const COLUMNS: int = 4
const ROWS: int = 4
const RULE_GAME_SIZE: int = 4
const MAX_HAND_CARD: int = 4
const PLAYER_TURN_TIME: float = 10.0
const NUM_EFF_AREA = 4

const P1 = "0"
const P2 = "1"

enum {LEFT, TOP, RIGHT, BOTTOM}

const GAME_MODE = {
	PVP = 0,
	AI_RANDOM = 1,
	AI_MIN_MAX = 2
}

# Card constants
# stats = [left, top, right, bottom]
enum {LEVEL_0, LEVEL_1, LEVEL_2}
const LV_DECK_NUM = {
	"LEVEL_0": 8,
	"LEVEL_1": 8,
	"LEVEL_2": 4,
}
const DECK_NUM = 20
const USE_RANDOM_STATS = true

const CARD_DICT = {
	"LEVEL_0": [
		{id = 0, name = "pikachu", type = LEVEL_0, stats = [1, 1, 1, 1],},
		{id = 1, name = "clefable", type = LEVEL_0, stats = [0, 2, 0, 2], },
		{id = 2, name = "pinsir", type = LEVEL_0, stats = [2, 0, 2, 0], },
		{id = 3, name = "primeape", type = LEVEL_0, stats = [4, 0, 0, 0], },
		{id = 4, name = "rapidash", type = LEVEL_0, stats = [0, 0, 3, 1], },
		{id = 5, name = "exeggutor", type = LEVEL_0, stats = [3, 0, 0, 1], },
		{id = 6, name = "golduck", type = LEVEL_0, stats = [2, 0, 2, 0], },
		{id = 7, name = "vileplume", type = LEVEL_0, stats = [0, 1, 1, 2], },
		],
	"LEVEL_1": [
		{id = 8, name = "arcanine", type = LEVEL_1, stats = [4, 1, 0, 3], },
		{id = 9, name = "kangaskhan", type = LEVEL_1, stats = [4, 4, 0, 0], },
		{id = 10, name = "lapras", type = LEVEL_1, stats = [1, 1, 2, 4], },
		{id = 11, name = "machamp", type = LEVEL_1, stats = [0, 0, 7, 1], },
		{id = 12, name = "ninetales", type = LEVEL_1, stats = [3, 1, 3, 1], },
		{id = 13, name = "onix", type = LEVEL_1, stats = [3, 1, 3, 1], },
		{id = 14, name = "persian", type = LEVEL_1, stats = [2, 0, 2, 0], },
		{id = 15, name = "victreebel", type = LEVEL_1, stats = [5, 0, 0, 3], },
		{id = 16, name = "alakazam", type = LEVEL_1, stats = [1, 4, 2, 1], },
		{id = 17, name = "gengar", type = LEVEL_1, stats = [0, 2, 2, 4], },
		{id = 18, name = "kingler", type = LEVEL_1, stats = [1, 1, 1, 5], },
		],
	"LEVEL_2": [
		{id = 19, name = "blastoise", type = LEVEL_2, stats = [3, 3, 3, 3], },
		{id = 20, name = "charizard", type = LEVEL_2, stats = [5, 2, 5, 2], },
		{id = 21, name = "venusaur", type = LEVEL_2, stats = [6, 0, 6, 0], },
		{id = 22, name = "snorlax", type = LEVEL_2, stats = [0, 0, 8, 4], },
		{id = 23, name = "mewtwo", type = LEVEL_2, stats = [1, 3, 6, 2], },
		]
}

var GameScene = preload("res://scenes/play_scene.tscn")
var WelcomeScene = preload("res://welcome_scene.tscn")

var _game_mode = GAME_MODE.PVP

var rng = RandomNumberGenerator.new()

func set_game_mode(mode):
	_game_mode = mode

func _ready():
	rng.randomize()
	_load_my_res()
	
func _load_my_res():
	var res_path = "res://assets/pokemons/"
	for card_type in CARD_DICT:
		for i in range(CARD_DICT[card_type].size()):
			# Get card data
			var card_data = CARD_DICT[card_type][i]
			# Do load
			var load_path = res_path + card_data.name + ".png"
			#print("[Resource Loading]: " + load_path)
			card_data.img = load(load_path)
			# Do random stats if needed
			if USE_RANDOM_STATS:
				var rand_stat_arr = _get_rand_stats_array(card_data.type)
				card_data.random_stats = rand_stat_arr
				
			card_data.use_random = USE_RANDOM_STATS
			# Test
			#print(CARD_DICT[card_type][i].name + " Stat_arr: " + str(CARD_DICT[card_type][i].random_stats) )

func _get_rand_stats_array(level):
		var total_stats = (level + 1) * 4
		var const_total_stats = total_stats
		var stats_array = [0, 0, 0, 0]
		var STAT_NUM = 4
		for i in range(STAT_NUM):
			if i == STAT_NUM - 1:
				stats_array[i] = const_total_stats - stats_array[i - 1] - stats_array[i - 2] -  stats_array[i - 3]
			else:
				stats_array[i] = rng.randi_range(0, total_stats)
			total_stats -= stats_array[i]
			if total_stats == 0:
				break
		return stats_array
		

	
