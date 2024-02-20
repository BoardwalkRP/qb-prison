Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true' -- Use qb-target interactions (don't change this, go to your server.cfg and add `setr UseTarget true` to use this and just that from true to false or the other way around)

local isServer = IsDuplicityVersion()
if not isServer then
    --- This function will be triggered once the hack is done
    --- @param success boolean
    --- @param currentGate number
    --- @param gateData table
    --- @return nil
    function Config.OnHackDone(success, currentGate, gateData)
        if success then
            TriggerServerEvent("prison:server:SetGateHit", currentGate)
            TriggerServerEvent('qb-doorlock:server:updateState', gateData.gatekey, false, false, false, true)
        else
            TriggerServerEvent("prison:server:SecurityLockdown")
        end
        TriggerEvent('mhacking:hide')
    end
end

Config.Jobs = {
    ["electrician"] = "Electrician"
}

Config.JobTimeReduction = {
    min = 2,
    max = 5,
    chance = 75,
}

Config.Uniforms = {
    ['male'] = {
        outfitData = {
            ['t-shirt'] = { item = 15, texture = 0 },
            ['torso2'] = { item = 5, texture = 0 },
            ['arms'] = { item = 5, texture = 0 },
            ['pants'] = { item = 3, texture = 7 },
            ['shoes'] = { item = 1, texture = 0 },
        }
    },
    ['female'] = {
        outfitData = {
            ['t-shirt'] = { item = 14, texture = 0 },
            ['torso2'] = { item = 370, texture = 0 },
            ['arms'] = { item = 0, texture = 0 },
            ['pants'] = { item = 0, texture = 12 },
            ['shoes'] = { item = 1, texture = 0 },
        }
    },
}

Config.PrisonZone = {
    vector2(1863.470336914, 2686.099609375),
    vector2(1863.7830810546, 2525.7021484375),
    vector2(1858.029296875, 2503.5102539062),
    vector2(1847.5952148438, 2478.9792480468),
    vector2(1825.8067626954, 2447.96875),
    vector2(1806.7784423828, 2426.2973632812),
    vector2(1766.1140136718, 2396.2536621094),
    vector2(1663.7055664062, 2380.4045410156),
    vector2(1640.2489013672, 2385.6040039062),
    vector2(1537.3293457032, 2447.7482910156),
    vector2(1526.1490478516, 2465.0068359375),
    vector2(1519.4575195312, 2580.0446777344),
    vector2(1521.2282714844, 2591.0397949218),
    vector2(1549.9978027344, 2673.9096679688),
    vector2(1558.3237304688, 2687.8942871094),
    vector2(1628.6137695312, 2760.5920410156),
    vector2(1647.0845947266, 2769.4714355468),
    vector2(1767.314819336, 2776.7717285156),
    vector2(1781.9735107422, 2773.1669921875),
    vector2(1794.2966308594, 2767.68359375),
    vector2(1849.4309082032, 2722.6767578125),
    vector2(1860.5283203125, 2708.0200195312)
}

Config.Locations = {
    jobs = {
        ["electrician"] = {
            [1] = {
                coords = vector4(1761.46, 2540.41, 45.56, 272.249),
            },
            [2] = {
                coords = vector4(1718.54, 2527.802, 45.56, 272.249),
            },
            [3] = {
                coords = vector4(1700.199, 2474.811, 45.56, 272.249),
            },
            [4] = {
                coords = vector4(1664.827, 2501.58, 45.56, 272.249),
            },
            [5] = {
                coords = vector4(1621.622, 2509.302, 45.56, 272.249),
            },
            [6] = {
                coords = vector4(1627.936, 2538.393, 45.56, 272.249),
            },
            [7] = {
                coords = vector4(1625.1, 2575.988, 45.56, 272.249),
            }
        }
    },
    ["freedom"] = {
        coords = vector4(1783.91, 2589.88, 44.8, 178.91)
    },
    ["outside"] = {
        coords = vector4(1848.13, 2586.05, 44.67, 269.5)
    },
    ["yard"] = {
        coords = vector4(1765.67, 2565.91, 44.56, 1.5)
    },
    ["middle"] = {
        coords = vector4(1693.33, 2569.51, 44.55, 123.5)
    },
    ["shop"] = {
        coords = vector4(1779.4, 2591.33, 44.8, 179.09)
    },
    visitation = {
        enter = {
            ped = vector4(1836.72, 2591.2, 44.95, 256.23),
            coords = vector4(1838.33, 2586.14, 44.95, 261.25),
        },
        exit = {
            ped = vector4(1781.18, 2612.91, 44.97, 19.64),
            coords = vector4(1781.36, 2614.38, 44.97, 79.97),
        },
    },
    spawns = {
        [1] = {
            coords = vector4(1661.046, 2524.681, 45.564, 260.545)
        },
        [2] = {
            coords = vector4(1650.812, 2540.582, 45.564, 230.436)
        },
        [3] = {
            coords = vector4(1654.959, 2545.535, 45.564, 230.436)
        },
        [4] = {
            coords = vector4(1697.106, 2525.558, 45.564, 187.208)
        },
        [5] = {
            coords = vector4(1673.084, 2519.823, 45.564, 229.542)
        },
        [6] = {
            coords = vector4(1666.029, 2511.367, 45.564, 233.888)
        },
        [7] = {
            coords = vector4(1691.229, 2509.635, 45.564, 52.432)
        },
        [8] = {
            coords = vector4(1770.59, 2536.064, 45.564, 258.113)
        },
        [9] = {
            coords = vector4(1792.45, 2584.37, 45.56, 276.24)
        },
        [10] = {
            coords = vector4(1768.33, 2566.08, 45.56, 176.83)
        },
        [11] = {
            coords = vector4(1696.09, 2469.4, 45.56, 1.4)
        }
    },
    solitary = {
        [1] = {
            coords = vector4(1766.16, 2597.55, 49.54, 103.54),
        },
        [2] = {
            coords = vector4(1766.17, 2594.42, 49.54, 81.83),
        },
        [3] = {
            coords = vector4(1765.96, 2591.33, 50.55, 86.29),
        },
        [4] = {
            coords = vector4(1766.12, 2588.31, 50.54, 80.52),
        },
        [5] = {
            coords = vector4(1761.86, 2588.05, 50.55, 269.04),
        },
        [6] = {
            coords = vector4(1761.85, 2590.97, 50.55, 272.05),
        },
        [7] = {
            coords = vector4(1761.82, 2593.88, 50.55, 246.17),
        },
        [8] = {
            coords = vector4(1761.9, 2596.84, 50.55, 276.68),
        },
    }
}

Config.CanteenItems = {
    [1] = {
        name = "sandwich",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 1
    },
    [2] = {
        name = "water_bottle",
        price = 4,
        amount = 50,
        info = {},
        type = "item",
        slot = 2
    }
}
