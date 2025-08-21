return {
    displayName = "Snipe Turret",
    description = "A long-range turret that excels at eliminating high-priority targets.",

    upgrades = {
        [1] = {
            upgradeName = "Standard",
            spritePath = "assets/sprites/unit_sniperturret_1.png",
            soundName = "snipershoot.wav",
            cooldown = 5,
            range = 999,
            damage = 2000,
            cost = 900,
            turnSpeed = 0.5,
            attackThreshold = 0.05,
            hiddenDetection = true,
        },
        [2] = {
            upgradeName = "Lubricated Gears",
            spritePath = "assets/sprites/unit_sniperturret_2.png",
            soundName = "snipershoot.wav",
            cooldown = 3.5,
            range = 999,
            damage = 2000,
            cost = 2250,
            turnSpeed = 1.2,
            attackThreshold = 0.05,
            hiddenDetection = true,
        },
        [3] = {
            upgradeName = "Hi-Explosive Rounds",
            spritePath = "assets/sprites/unit_sniperturret_3.png",
            soundName = "heavysnipershoot.wav",
            cooldown = 3.5,
            range = 999,
            damage = 3000,
            cost = 4500,
            turnSpeed = 1.2,
            attackThreshold = 0.05,
            hiddenDetection = true,

            hasSplashDamage = true,
            splashRadius = 100,
            splashDamageRatio = 0.3
        },
        [4] = {
            upgradeName = "Antimatter Rifle",
            spritePath = "assets/sprites/unit_sniperturret_4.png",
            soundName = "lasersnipershoot.wav",
            cooldown = 2.5,
            range = 999,
            damage = 6000,
            cost = 6000,
            turnSpeed = 1.5,
            attackThreshold = 0.05,
            hiddenDetection = true,

            hasSplashDamage = true,
            splashRadius = 150,
            splashDamageRatio = 0.2
        },
    }
}