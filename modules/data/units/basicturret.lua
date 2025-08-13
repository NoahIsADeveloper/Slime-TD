return {
    displayName = "Basic Turret",
    description = "A basic turret designed to fight slimes.",

    upgrades = {
        [1] = {
            upgradeName = "Standard",
            spritePath = "assets/sprites/unit_basicturret_1.png",
            cooldown = .9,
            range = 300,
            damage = 50,
            cost = 200,
        },
        [2] = {
            upgradeName = "Extended Range",
            spritePath = "assets/sprites/unit_basicturret_2.png",
            cooldown = .85,
            range = 350,
            damage = 55,
            cost = 350,
        },
        [3] = {
            upgradeName = "High Impact",
            spritePath = "assets/sprites/unit_basicturret_3.png",
            cooldown = .85,
            range = 350,
            damage = 70,
            cost = 650,
        },
        [4] = {
            upgradeName = "Rapid Fire",
            spritePath = "assets/sprites/unit_basicturret_4.png",
            cooldown = .75,
            range = 375,
            damage = 70,
            cost = 1200,
        },
        [5] = {
            upgradeName = "Overclocked",
            spritePath = "assets/sprites/unit_basicturret_5.png",
            cooldown = .6,
            range = 375,
            damage = 80,
            cost = 3000,
        }
    }
}