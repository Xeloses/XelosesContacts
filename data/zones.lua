local CONST = XelosesContacts.CONST

-- ---------------------
--  @SECTION GAME ZONES
-- ---------------------

CONST.ZONES = {

    -- ---------------------------
    --  @SECTION Infinite Archive
    -- ---------------------------

    IA = table:new(
        1436 -- Infinite Archive
    ),

    -- -----------------
    --  @SECTION Arenas
    -- -----------------

    ARENA = {
        SOLO = table:new(
            677, -- Maelstrom Arena
            1227 -- Vateshran Hollows
        ),
        GROUP = table:new(
            635, -- Dragonstar Arena
            1082 -- Blackrose Prison
        ),
    },

    -- -------------------------
    --  @SECTION Group dungeons
    -- -------------------------

    DUNGEON = table:new(
        11,   -- Vaults of Madness
        22,   -- Volenfell
        31,   -- Selene's Web
        38,   -- Blackheart Haven
        63,   -- Darkshade Caverns I
        64,   -- Blessed Crucible
        126,  -- Elden Hollow I
        130,  -- Crypt of Hearts I
        131,  -- Tempest Island
        144,  -- Spindleclutch I
        146,  -- Wayrest Sewers I
        148,  -- Arx Corinium
        176,  -- City of Ash I
        283,  -- Fungal Grotto I
        380,  -- The Banished Cells I
        449,  -- Direfrost Keep
        678,  -- Imperial City Prison
        681,  -- City of Ash II
        688,  -- White-Gold Tower
        843,  -- Ruins of Mazzatun
        848,  -- Cradle of Shadows
        930,  -- Darkshade Caverns II
        931,  -- Elden Hollow II
        932,  -- Crypt of Hearts II
        933,  -- Wayrest Sewers II
        934,  -- Fungal Grotto II
        935,  -- The Banished Cells II
        936,  -- Spindleclutch II
        973,  -- Bloodroot Forge
        974,  -- Falkreath Hold
        1009, -- Fang Lair
        1010, -- Scalecaller Peak
        1052, -- Moon Hunter Keep
        1055, -- March of Sacrifices
        1080, -- Frostvault
        1081, -- Depths of Malatar
        1122, -- Moongrave Fane
        1123, -- Lair of Maarselok
        1152, -- Icereach
        1153, -- Unhallowed Grave
        1197, -- Stone Garden
        1201, -- Castle Thorn
        1228, -- Black Drake Villa
        1229, -- The Cauldron
        1267, -- Red Petal Bastion
        1268, -- The Dread Cellar
        1301, -- Coral Aerie
        1302, -- Shipwright's Regret
        1360, -- Earthen Root Enclave
        1361, -- Graven Deep
        1389, -- Bal Sunnar
        1390, -- Scrivener's Hall
        1470, -- Oathsworn Pit
        1471, -- Bedlam Veil
        1496, -- ? (new dungeon)
        1497  -- ? (new dungeon)
    ),

    -- -----------------
    --  @SECTION Trials
    -- -----------------

    TRIAL = table:new(
        636,  -- HCR (Hel Ra Citadel)
        638,  -- AA  (Aetherian Archive)
        639,  -- SO  (Sanctum Ophidia)
        725,  -- MoL (Maw of Lorkhaj)
        975,  -- HoF (Halls of Fabrication)
        1000, -- AS  (Asylum Sanctorium)
        1051, -- CR  (Cloudrest)
        1121, -- SS  (Sunspire)
        1196, -- KA  (Kyne's Aegis)
        1263, -- RG  (Rockgrove)
        1344, -- DSR (Dreadsail Reef)
        1427, -- SE  (Sanity's Edge)
        1478, -- LC  (Lucent Citadel)
        1548  -- OC  (Ossein Cage)
    ),

    -- --------------------
    --  @SECTION PvP zones
    -- --------------------

    PVP = table:new(
        181,                                        -- Cyrodiil
        551, 584, 643,                              -- Imperial city and Imperial underground + sewers
        508, 509, 510, 511, 512, 513, 514, 517, 518 -- Battlegrounds
    ),

}
