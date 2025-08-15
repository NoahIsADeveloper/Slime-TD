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
            cooldown = .85,
            range = 320,
            damage = 50,
            cost = 450,
            hiddenDetection = true,
        },
        [3] = {
            upgradeName = "Hi-Power Ammo",
            spritePath = "assets/sprites/unit_basicturret_3.png",
            soundName = "turretshoot.wav",
            cooldown = .85,
            range = 320,
            damage = 80,
            cost = 1250,
            hiddenDetection = true,
        },
        [4] = {
            upgradeName = "Double Barrel",
            spritePath = "assets/sprites/unit_basicturret_4.png",
            soundName = "turretshoot.wav",
            cooldown = .425,
            range = 350,
            damage = 80,
            cost = 2500,
            hiddenDetection = true,
        },
        [5] = {
            upgradeName = "Hypercharged",
            spritePath = "assets/sprites/unit_basicturret_5.png",
            soundName = "hyperturretshoot.wav",
            cooldown = .425,
            range = 400,
            damage = 99,
            cost = 3200,
            hiddenDetection = true,
        }
    }
}