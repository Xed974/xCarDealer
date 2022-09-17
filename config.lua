xCarDealer = xCarDealer or {}

xCarDealer = {
    MarkerType = 23, -- https://docs.fivem.net/docs/game-references/markers/
    MarkerColorR = 0, -- https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
    MarkerColorG = 255, -- https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
    MarkerColorB = 255, -- https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
    MarkerOpacite = 180, 
    MarkerSizeLargeur = 0.3,
    MarkerSizeEpaisseur = 0.3,
    MarkerSizeHauteur = 0.3,
    MarkerSaute = false, 
    MarkerTourne = false,

    TimeForTest = 1, -- Temps pour test les véhicules (en minutes)
    WebHookDiscord = "",

    Position = {
        --
        SpwanCarForTest = vector3(-75.23, -819.11, 326.17),
        HeadingForTest = 200.0,
        --
        SpawnCarWhenBy = vector3(-2154.00, 220.97, 184.60),
        HeadingWhenBy = 200.0,
        --
        Menu = {vector3(-2151.13, 221.84, 184.60)},
        Exposition = vector3(-2150.46, 226.10, 184.60)
    },
    Stockage = { -- Poids du coffre des véhicules par catégories
        {name = "compacts", weight = 10},
        {name = "coupes", weight = 10},
        {name = "motorcycles", weight = 0},
        {name = "muscle", weight = 10},
        {name = "offroad", weight = 100},
        {name = "sedans", weight = 10},
        {name = "sports", weight = 10},
        {name = "sportsclassics", weight = 10},
        {name = "super", weight = 5},
        {name = "suvs", weight = 100},
        {name = "vans", weight = 200},
    },
    Blips = {
        Model = 227,
        Couleur = 0,
        Taille = 0.7,
        Title = "Concessionnaire"
    }
}

--- Xed#1188 | https://discord.gg/HvfAsbgVpM