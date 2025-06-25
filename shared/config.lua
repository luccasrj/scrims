Config = {}

Config.roundTime = 120
Config.freezeTime = 5

Config.mapPool = {
    ["predio"] = {
        spawnTeam1 = {
            coords = vec3(82.78,-864.58,133.76),
        },
        spawnTeam2 = {
            coords = vec3(121.13,-878.78,133.76),
        }
    },
    ["fazenda"] = {
        spawnTeam1 = {
            coords = vec3(1454.76,1184.62,113.14),
        },
        spawnTeam2 = {
            coords = vec3(1458.61,1128.06,113.33),
        }
    }
}

Config.scrimWeapons = {
    ["WEAPON_PISTOL_MK2"] = { 
        ["attachments"] = {
			"COMPONENT_AT_PI_FLSH_02",
			"COMPONENT_AT_PI_COMP",
			"COMPONENT_AT_PI_RAIL"
        }
    },
    ["WEAPON_KNIFE"] = { 
        ["attachments"] = {}
    },
}