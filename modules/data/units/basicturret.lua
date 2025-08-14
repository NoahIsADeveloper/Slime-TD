return {
    displayName = "Basic Turret",
    description = "A basic turret designed to fight slimes.",

    upgrades = {
        [1] = {
            upgradeName = "Standard",
            spritePath = "assets/sprites/unit_basicturret_1.png",
            cooldown = .9,
            range = 200,
            damage = 60,
            cost = 200,
            hiddenDetection = false,
        },
        [2] = {
            upgradeName = "Extended Range",
            spritePath = "assets/sprites/unit_basicturret_2.png",
            cooldown = .9,
            range = 300,
            damage = 60,
            cost = 500,
            hiddenDetection = true,
        },
        [3] = {
            upgradeName = "High Impact",
            spritePath = "assets/sprites/unit_basicturret_3.png",
            cooldown = .9,
            range = 300,
            damage = 85,
            cost = 800,
            hiddenDetection = true,
        },
        [4] = {
            upgradeName = "Rapid Fire",
            spritePath = "assets/sprites/unit_basicturret_4.png",
            cooldown = .55,
            range = 300,
            damage = 85,
            cost = 1450,
            hiddenDetection = true,
        },
        [5] = {
            upgradeName = "Hypercharge",
            spritePath = "assets/sprites/unit_basicturret_5.png",
            cooldown = .45,
            range = 400,
            damage = 100,
            cost = 2600,
            hiddenDetection = true,
        }
    }
}