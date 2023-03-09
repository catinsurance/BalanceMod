local DSSModName = "Dead Sea Scrolls (BalanceMod)"
local DSSCoreVersion = 7
local MenuProvider = {}

-- Below are some constant elements that we can reuse throughout the menu
local BREAK_LINE = {str = '', fsize = 1, nosel = true}
local ITEM_CHANGES = {
    {
        Name = "plan c",
        Index = "PlanC",
        Id = Isaac.GetItemIdByName("Plan C"),
        Tooltip = "plan c will kill you after you leave the room instead of after 3 seconds"
    },
    {
        Name = "d10",
        Index = "D10",
        Id = Isaac.GetItemIdByName("D10"),
        Tooltip = "d10 will devolve champions"
    },
    {
        Name = "breath of life",
        Index = "BreathOfLife",
        Id = Isaac.GetItemIdByName("Breath of Life"),
        Tooltip = "breath of life takes less time to use"
    },
    {
        Name = "dataminer",
        Index = "Dataminer",
        Id = Isaac.GetItemIdByName("Dataminer"),
        Tooltip = "gives temporary tears and damage instead of shuffling stats"
    },
    {
        Name = "mom's pad",
        Index = "MomsPad",
        Id = Isaac.GetItemIdByName("Mom's Pad"),
        Tooltip = "marks enemies instead of fearing them"
    },
    {
        Name = "milk!",
        Index = "Milk",
        Id = Isaac.GetItemIdByName("Milk!"),
        Tooltip = "massive tears up while standing in the milk creep"
    },
    {
        Name = "abel",
        Index = "Abel",
        Id = Isaac.GetItemIdByName("Abel"),
        Tooltip = "collects pickups for you and auto aims towards enemies"
    },
    {
        Name = "razor blade",
        Index = "RazorBlade",
        Id = Isaac.GetItemIdByName("Razor Blade"),
        Tooltip = "better damage on use"
    },
    {
        Name = "the jar",
        Index = "TheJar",
        Id = Isaac.GetItemIdByName("The Jar"),
        Tooltip = "blocks a single hit when filled, empties afterward"
    },
    {
        Name = "mom's bottle of pills",
        Index = "BottleOfPills",
        Id = Isaac.GetItemIdByName("Mom's Bottle of Pills"),
        Tooltip = "shorter cooldown"
    },
    {
        Name = "clicker",
        Index = "Clicker",
        Id = Isaac.GetItemIdByName("Clicker"),
        Tooltip = "clicker changes your character, but follows a lot of new rules to make it fair and less glitchy"
    },
    {
        Name = "yuck heart",
        Index = "YuckHeart",
        Id = Isaac.GetItemIdByName("Yuck Heart"),
        Tooltip = "clicker changes your character with a lot of new rules to make it fair"
    },
    {
        Name = "obsessed fan",
        Index = "ObsessedFan",
        Tooltip = "obsessed fan will blocks projectiles, as long as it isn't standing inside the player"
    },
    {
        Name = "little baggy",
        Index = "LittleBaggyTweak",
        Tooltip = "little baggy identifies all pills on pickup"
    },
    {
        Name = "cursed eye",
        Index = "CursedEyeTweak",
        Tooltip = "having cursed eye lowers your knockback significantly"
    },
    {
        Name = "r key",
        Index = "RKeyTweak",
        Tooltip = "using r key makes you take full hearts of damage instead of half"
    },
    {
        Name = "thunder thighs",
        Index = "ThunderThighs",
        Tooltip = "thunder thighs gives -0.3 speed instead of -0.4"
    }
}

local TWEAKS = {
    {
        Name = "item quality",
        Tooltip = "changes certain item qualities (you must start a new run for this to take effect)",
        Change = "QualityTweaks",
    },
    {
        Name = "c.h.a.d. item drop",
        Tooltip = "changes c.h.a.d. to have a 50% chance to drop a normal boss room item",
        Change = "ChadTweak"
    },
    {
        Name = "gish item drop",
        Tooltip = "changes gish to have a 50% chance to drop a normal boss room item",
        Change = "GishTweak"
    }
}

local ENEMY_CHANGES = {
    {
        Name = "grilled clotty",
        Tooltip = "lowers the max health of the grilled clotty to 16",
        Change = "Health-" .. tostring(EntityType.ENTITY_CLOTTY)
    },
    {
        Name = "big spider",
        Tooltip = "lowers the max health of a big spider to 15",
        Change = "Health-" .. tostring(EntityType.ENTITY_BIGSPIDER)
    },
    {
        Name = "keeper head",
        Tooltip = "lowers the max health of a keeper head to 33",
        Change = "Health-" .. tostring(EntityType.ENTITY_KEEPER)
    },
    {
        Name = "poofer",
        Tooltip = "lowers the max health of the poofer to 16",
        Change = "Health-" .. tostring(EntityType.ENTITY_POOFER)
    },
    {
        Name = "the clutch",
        Tooltip = "lowers the max health of the clutch to 468",
        Change = "Health-" .. tostring(EntityType.ENTITY_CLUTCH)
    }
}

local TRINKET_CHANGES = {
    {
        Name = "perfection",
        Index = "Perfection",
        Id = Isaac.GetTrinketIdByName("Perfection"),
        Tooltip = "perfection will drop in \"tier\" and will disappear after tier 3"
    },
    {
        Name = "fish head",
        Index = "FishHead",
        Id = Isaac.GetTrinketIdByName("Fish Head"),
        Tooltip = "fish head has a chance to give a poison locust on hit"
    }
}

-- Helper functions


-- auto split tooltips into multiple lines optimally
local function GenerateTooltip(str)
    local endTable = {}
    local currentString = ""
    for w in str:gmatch("%S+") do
        local newString = currentString .. w .. " "
        if newString:len() >= 15 then
            table.insert(endTable, currentString)
            currentString = ""
        end

        currentString = currentString .. w .. " "
    end

    table.insert(endTable, currentString)
    return {strset = endTable}
end

-- The below functions are all required 
function MenuProvider.SaveSaveData()
    BalanceMod.SaveModData()
end

function MenuProvider.GetPaletteSetting()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    if not REPENTANCE then
        return dssData.HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    if not REPENTANCE then
        dssData.HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenuControllerToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenuControllerToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    local dssData = BalanceMod.GetDssSave() or {}
    return dssData.MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    local dssData = BalanceMod.GetDssSave() or {}
    dssData.MenusPoppedUp = var
end

local DSSInitializerFunction = include("BalanceMod.API.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local dssDirectory = {
    main = {
        title = "balance mod",
        tooltip = dssmod.menuOpenToolTip,
        buttons = {
            {str = 'resume game', action = "resume"},
            {str = "options", dest = "options"},
            dssmod.changelogsButton,
            {str = "credits", dest = "credits"},
        }
    },
    options = {
        title = "options",
        buttons = {
            {str = "item changes", dest = "items", tooltip = GenerateTooltip("toggle changes to items")},
            {str = "trinket changes", dest = "trinkets", tooltip = GenerateTooltip("toggle changes to trinkets")},
            {str = "enemy changes", dest = "enemies", tooltip = GenerateTooltip("toggle changes to enemies")},
            {str = "misc changes", dest = "misc", tooltip = GenerateTooltip("toggle miscellaneous tweaks")},
        }
    },
    items = {
        title = "item changes",
        buttons = {},
        generate = function (master)
            master.buttons = {}
            for _, item in ipairs(ITEM_CHANGES) do
                local button = {
                    str = item.Name,
                    tooltip = GenerateTooltip(item.Tooltip),
                    choices = {"enabled", "disabled"},
                    variable = item.Name .. "-toggle",

                    load = function ()
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        local key = tostring(item.Index)
                        if saveData[key] == nil then
                            saveData[key] = true
                        end
                           
                        return saveData[key] == true and 1 or 2
                    end,

                    store = function (var)
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        local key = tostring(item.Index)
                        saveData[key] = var == 1
                    end
                }

                button.setting = button.load()
                table.insert(master.buttons, button)
            end
        end
    },
    trinkets = {
        title = "trinket changes",
        buttons = {},
        generate = function (master)
            master.buttons = {}
            for _, item in ipairs(TRINKET_CHANGES) do
                local button = {
                    str = item.Name,
                    tooltip = GenerateTooltip(item.Tooltip),
                    choices = {"enabled", "disabled"},
                    variable = item.Name .. "-toggle",

                    load = function ()
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        local key = tostring(item.Index)
                        if saveData[key] == nil then
                            saveData[key] = true
                        end
                           
                        return saveData[key] == true and 1 or 2
                    end,

                    store = function (var)
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        local key = tostring(item.Index)
                        saveData[key] = var == 1
                    end
                }

                button.setting = button.load()
                table.insert(master.buttons, button)
            end
        end
    },
    enemies = {
        title = "enemy changes",
        buttons = {},
        generate = function (master)
            master.buttons = {}
            for _, item in ipairs(ENEMY_CHANGES) do
                local button = {
                    str = item.Name,
                    tooltip = GenerateTooltip(item.Tooltip),
                    choices = {"enabled", "disabled"},
                    variable = item.Name .. "-toggle",

                    load = function ()
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        if saveData[item.Change] == nil then
                            saveData[item.Change] = true
                        end
                           
                        return saveData[item.Change] == true and 1 or 2
                    end,

                    store = function (var)
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        saveData[item.Change] = var == 1
                    end
                }

                button.setting = button.load()
                table.insert(master.buttons, button)
            end
        end
    },
    misc = {
        title = "misc. tweaks",
        buttons = {
        },
        generate = function (master)
            master.buttons = {}
            for _, item in ipairs(TWEAKS) do
                local button = {
                    str = item.Name,
                    tooltip = GenerateTooltip(item.Tooltip),
                    choices = {"enabled", "disabled"},
                    variable = item.Name .. "-toggle",

                    load = function ()
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        local key = tostring(item.Change)
                        if saveData[key] == nil then
                            saveData[key] = true
                        end
                           
                        if saveData[key] then
                            return 1
                        else
                            return 2
                        end
                    end,

                    store = function (var)
                        local saveData = BalanceMod.GetSettingsSave() or {}
                        saveData[item.Change] = var == 1
                    end
                }

                button.setting = button.load()
                table.insert(master.buttons, button)
            end
        end
    },
    credits = {
        title = "credits",
        tooltip = GenerateTooltip("thank you to everyone who helped make this mod possible!"),
        buttons = {
            {
                str = "creator",
                nosel = true,
                fsize = 3,
            },
            {str = "slugcat", fsize = 2},
            BREAK_LINE,
            {
                str = "artists",
                nosel = true,
                fsize = 3,
            },
            {str = "ferpe", fsize = 2},
            {str = "player_null_name", fsize = 2},
            BREAK_LINE,
            {
                str = "concepts",
                nosel = true,
                fsize = 3,
            },
            {str = "slugcat", fsize = 2},
            {str = "theturtlemelon", fsize = 2},
            {str = "kattack", fsize = 2},
            {str = "the1337gh0st", fsize = 2},
            BREAK_LINE,
            BREAK_LINE,
            BREAK_LINE,
            {str = "thank u as well <3", fsize = 1, nosel = true}
        },
    }
}

local dirKey = {
    Item = dssDirectory.main,
    Main = 'main',
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("BalanceMod", {
    Run = dssmod.runMenu,
    Open = dssmod.openMenu,
    Close = dssmod.closeMenu,
    UseSubMenu = false,
    Directory = dssDirectory,
    DirectoryKey = dirKey
})

BalanceMod.SETTING_INFO = {
    ITEM_CHANGES = ITEM_CHANGES,
    TRINKET_CHANGES = TRINKET_CHANGES,
    ENEMY_CHANGES = ENEMY_CHANGES,
    TWEAKS = TWEAKS,
}