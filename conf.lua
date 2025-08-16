function love.conf(config)
    config.identity = "SLIME-TD"

    config.window.width = 800
    config.window.height = 600

    config.window.minwidth = 400
    config.window.minheight = 300

    config.window.icon = "assets/sprites/enemy_slime.png"
    config.window.title = "Slime Tower Defense"

    config.window.fullscreentype = "desktop"

    config.window.resizable = true
    config.console = false

    config.window.vsync = 0
end