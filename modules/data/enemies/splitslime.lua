return {
    displayName = "Split Slime",
    type = "Splitter",
    spritePath = "assets/sprites/enemy_splitslime.png",
    killReward = 60,
    maxHealth = 400,
    moveSpeed = 110,
    damageReduction = 0,

    splitsInto = {
        {type = "minislime", amount = 3, hidden = false}
    },
    splitSound = "splitslime.wav"
}