return {
    musicName = "mainmenu.ogg",
    elements = {
        ["background"] = {
            color = {r = 255, g = 255, b = 255},
            type = "sprite",
            spritePath = "assets/sprites/background.png",
            x = 400,
            y = 300,
            zindex = 100,
            scaleX = 1,
            scaleY = 1,
        },

        ["backButton"] = {
            color = {r = 255, g = 0, b = 0},
            type = "sprite",
            spritePath = "assets/sprites/button.png",
            x = 400,
            y = 550,
            zindex = 102,
            scaleX = .6,
            scaleY = .6,
        },
        ["backButtonLabel"] = {
            color = {r = 200, g = 200, b = 200},
            type = "text",
            text = "Back",
            x = 400,
            y = 550,
            zindex = 103,
            scaleX = .6,
            scaleY = .6,
        },
    }
}