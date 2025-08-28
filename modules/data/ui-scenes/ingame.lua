return {
    elements = {
        ["currentWave"] = {
            color = {r = 255, g = 255, b = 255},
            type = "text",
            x = 400,
            y = 110,
            zindex = 101,
            scaleX = .5,
            scaleY = .5,
        },
        ["information"] = {
            color = {r = 255, g = 255, b = 255},
            type = "text",
            x = 400,
            y = 85,
            zindex = 101,
            scaleX = .5,
            scaleY = .5,
        },
        ["baseHealth"] = {
            color = {r = 255, g = 255, b = 255},
            type = "text",
            x = 400,
            y = 40,
            zindex = 101,
            scaleX = 1.25,
            scaleY = 1.25,
        },
        ["cashCounter"] = {
            color = {r = 255, g = 200, b = 0},
            type = "text",
            x = 140,
            y = 550,
            zindex = 101,
            scaleX = .6,
            scaleY = .6
        },

        ["timeScale"] = {
            color = {r = 255, g = 255, b = 255},
            type = "text",
            text = "Time Scale: 1",
            x = 700,
            y = 550,
            zindex = 101,
            scaleX = .6,
            scaleY = .6
        },
        ["enemyNameDisplay"] = {
            color = {r=255, g=255, b=255},
            type = "text",
            x = 0,
            y = 0,
            zindex = 101,
            scaleX = .6,
            scaleY = .6
        },
        ["enemyHealthCounter"] = {
            color = {r=107, g=255, b=107},
            type = "text",
            x = 0,
            y = 0,
            zindex = 101,
            scaleX = .6,
            scaleY = .6
        },

        ["upgradeUnitButtonLabel"] = {
            color = {r = 73, g = 94, b = 73},
            text = "Upgrade -($)",
            type = "text",
            scaleX = 0.5,
            scaleY = 0.5,
            zindex = 103
        },
        ["upgradeUnitButton"] = {
            color = {r=255, g=255, b=255},
            spritePath = "assets/sprites/button.png",
            scaleX = 0.5,
            scaleY = 0.5,
            type = "sprite",
            zindex = 102
        },

        ["sellUnitButtonLabel"] = {
            color = {r = 200, g = 200, b = 200},
            text = "Sell +($)",
            type = "text",
            scaleX = 0.4,
            scaleY = 0.4,
            zindex = 103
        },
        ["sellUnitButton"] = {
            color = {r=255, g=0, b=0},
            spritePath = "assets/sprites/button.png",
            scaleX = 0.4,
            scaleY = 0.4,
            type = "sprite",
            zindex = 102
        },

       ["unitPlacementErrorMessage"] = {
            color = {r=200, g=0, b=00},
            scaleX = .8,
            scaleY = .8,
            type = "text",
            text = "",
            zindex = 102,
            x = 400,
            y = 500
        },

        ["loadoutBackground"] = {
            color = {r=42,g=42,b=42},
            alpha = 0.9,
            type = "sprite",
            spritePath = "assets/sprites/button.png",
            rot = math.rad(90),
            scaleX = 0.8,
            scaleY = 0.9,
            x = 60,
            y = 425,
            zindex = 103,
        }
    }
}