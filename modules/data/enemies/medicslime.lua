return {
    displayName = "Medic Slime",
    type = "support",
    spritePath = "assets/sprites/enemy_medicslime.png",
    killReward = 100,
    maxHealth = 300,
    moveSpeed = 50,
    damageReduction = 0,

    hasAura = true,
    auraRange = 175,
    auraEffects = {
        healAmount = 2,
        healCooldown = .1,
    },
    auraColor = {r = 100, g = 200, b = 80},
    lastHealTime = 0
}