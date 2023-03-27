extends Node

const Groups = {
	BUILD_AREA_GROUP = "build_area"
}

const SettingsSection = {
	HUD = "hud"
}

const SettingsKey = {
	SELECTED_TOWER = "selected tower"
}

const SETTINGS_PATH: String = "user://settings.cfg"

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	UNIQUE,
}

const TILE_HEIGHT: float = 128.0
