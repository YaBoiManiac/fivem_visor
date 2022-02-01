--[[

    This script is setup to handle native helmets, if you wish to add custom clothing helmets the numbers are below.

    Please note:
        This script is standalone and might not work properly with skin frameworks.

]]

Config = {}
-- Slash command
Config.CommandName = "visor"
-- Enables whether nightvision gets enabled on the nightvision helmets
Config.EnableNightVision = true

Config.Visors = {

    --[[
        Format:
            [Down] = Up

            Just uses the number of the helmets
    ]]

    Male = {
        -- bike
        [82] = 67,
        [50] = 68,
        [51] = 69,
        [52] = 70,
        [53] = 71,
        [62] = 72,
        [73] = 74,
        [78] = 79,
        [80] = 81,
        [91] = 92,
        [128] = 127,
        -- night vision
        [116] = 117,
        [118] = 119,
        -- tac
        [123] = 124,
        [125] = 126
    },

    Female = {
        -- bike
        [49] = 67,
        [50] = 68,
        [51] = 69,
        [52] = 70,
        [62] = 71,
        [72] = 73,
        [77] = 78,
        [79] = 80,
        [81] = 66,
        [90] = 91,
        [127] = 126,

        -- night vision
        [115] = 116,
        [117] = 118,
        -- tac
        [122] = 123,
        [124] = 125
    }

}