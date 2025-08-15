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
            x = 120,
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

        ["upgradeUnitButton"] = {
            color = {r = 73, g = 94, b = 73},
            text = "Upgrade -($)",
            type = "text",
            scaleX = 0.5,
            scaleY = 0.5,
            zindex = 103
        },
        ["upgradeUnitButtonBackground"] = {
            color = {r=255, g=255, b=255},
            spritePath = "assets/sprites/button.png",
            scaleX = 0.5,
            scaleY = 0.5,
            type = "sprite",
            zindex = 102
        },

        ["sellUnitButton"] = {
            color = {r = 200, g = 200, b = 200},
            text = "Sell +($)",
            type = "text",
            scaleX = 0.4,
            scaleY = 0.4,
            zindex = 103
        },
        ["sellUnitButtonBackground"] = {
            color = {r=255, g=0, b=0},
            spritePath = "assets/sprites/button.png",
            scaleX = 0.4,
            scaleY = 0.4,
            type = "sprite",
            zindex = 102
        }
    }
}