return {
    displayName = "Giant Split Slime",
    type = "Splitter",
    spritePath = "assets/sprites/enemy_giantsplitslime.png",
    killReward = 300,
    maxHealth = 1200,
    moveSpeed = 55,
    damageReduction = 0,

    splitsInto = {
        {type = "splitslime", amount = 2, hidden = false},
    },
    splitSound = "splitslime.wav"
}