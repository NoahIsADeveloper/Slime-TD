return {
    displayName = "Basic Turret",
    description = "A basic turret designed to fight slimes.",

    upgrades = {
        [1] = {
            upgradeName = "Standard",
            spritePath = "assets/sprites/unit_basicturret_1.png",
            soundName = "turretshoot.wav",
            cooldown = .9,
            range = 200,
            damage = 50,
            cost = 200,
            hiddenDetection = false,
        },
        [2] = {
            upgradeName = "Longer Barrel",
            spritePath = "assets/sprites/unit_basicturret_2.png",
            soundName = "turretshoot.wav",
            cooldown = .75,
            range = 350,
            damage = 55,
            cost = 400,
            hiddenDetection = true,
        },
        [3] = {
            upgradeName = "Hi-Power Ammo",
            spritePath = "assets/sprites/unit_basicturret_3.png",
            soundName = "turretshoot.wav",
            cooldown = .75,
            range = 350,
            damage = 70,
            cost = 1250,
            hiddenDetection = true,
        },
        [4] = {
            upgradeName = "Double Barrel",
            spritePath = "assets/sprites/unit_basicturret_4.png",
            soundName = "turretshoot.wav",
            cooldown = .5,
            range = 350,
            damage = 70,
            cost = 2500,
            hiddenDetection = true,
        },
        [5] = {
            upgradeName = "Hypercharged",
            spritePath = "assets/sprites/unit_basicturret_5.png",
            soundName = "hyperturretshoot.wav",
            cooldown = .5,
            range = 375,
            damage = 85,
            cost = 3200,
            hiddenDetection = true,
        }
    }
}