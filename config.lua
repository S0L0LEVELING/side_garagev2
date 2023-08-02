sdpGarage = {}

sdpGarage.TeleportToVehicles = true

sdpGarage.DefaultGarage = 'Legion Garage'

sdpGarage.BlipColors = {
	Car = 3,
    Boat = 51,
    Aircraft = 81
}

sdpGarage.keyInfo = "F1"

sdpGarage.radial = true -- Use ox_lib radial if true

sdpGarage.clientNotif = function(message, type, length)
    lib.notify({
        title = 'Garage',
        description = message,
        type = type,
        duration = length
    })
end

sdpGarage.serverNotif = function(source, message, type, length)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Garage',
        description = message,
        type = type,
        duration = length
    })
end

sdpGarage.ChangeNamePrice = 25000 -- Price for change name

sdpGarage.PayInCash = true -- jika false maka bayar menggunakan bank / if false  then pay with bank

sdpGarage.WhitelistAccess = {
	'police',
    'mechanic',
    'ambulance',
    'burgershot',
}

sdpGarage.ImpoundPrices = {
	-- These are vehicle classes
	[0] = 1000,  -- Compacts
	[1] = 500,   -- Sedans
	[2] = 500,   -- SUVs
	[3] = 800,   -- Coupes
	[4] = 1200,  -- Muscle
	[5] = 800,   -- Sports Classics
	[6] = 1500,  -- Sports
	[7] = 10000,  -- Super
	[8] = 300,   -- Motorcycles
	[9] = 500,   -- Off-road
	[10] = 1000, -- Industrial
	[11] = 500,  -- Utility
	[12] = 600,  -- Vans
	[13] = 100,  -- Cylces
	[14] = 2800, -- Boats
	[15] = 3500, -- Helicopters
	[16] = 3800, -- Planes
	[17] = 500,  -- Service
	[18] = 0,    -- Emergency
	[19] = 100,  -- Military
	[20] = 1500, -- Commercial
	[21] = 0     -- Trains (lol)
}

sdpGarage.Impounds = {
	{
        type = 'car', -- car, boat or aircraft
        blipCoords = vector4(265.7472, 2598.3469, 43.8344, 15.7470),
        label = 'Public Impound',
        zone = {
            coords = vec3(258.0, 2600.0, 45.0),
            size = vec3(10.0, 7.0, 4.0),
            rotation = 10.0,
        },
        spawns = {
            vector4(255.7090, 2599.8191, 44.8031, 273.5988),
            vector4(254.3019, 2605.1760, 44.9612, 6.6118),
            vector4(246.1634, 2603.6299, 45.1275, 122.6817),
        }
    },
    {
        type = 'car', -- car, boat or aircraft
        blipCoords = vector4(265.7472, 2598.3469, 43.8344, 15.7470),
        label = 'Whitelist Impound',
        whitelist = true,
        zone = {
            coords = vec3(418.52, -1638.38, 29.0),
            size = vec3(11.0, 14.0, 4.0),
            rotation = 0.0,
        },
        spawns = {
            vector4(420.7229, -1641.9304, 28.8790, 90.5952),
            vector4(254.3019, 2605.1760, 44.9612, 6.6118),
            vector4(246.1634, 2603.6299, 45.1275, 122.6817),
        }
    },
}


sdpGarage.Garages = {
    {
        label = 'Legion Garage',
        blip = true,
        type = 'car',
        zone = {
            coords = vec3(-318.29, -932.78, 31.85),
            size = vec3(8.0, 15.0, 3.65),
            rotation = 339.75,
        },
        spawns = {
            vec4(-316.8089, -928.5145, 30.6687, 249.8371),
            vec4(-317.8161, -931.9794, 30.6686, 250.4529),
        }
    },

    {
        label = 'Police Garage',
        blip = true,
        job = 'police',
        type = 'car',
        zone = {
            coords = vec3(446.32, -1023.18, 29.0),
            size = vec3(11.0, 15.75, 4.0),
            rotation = 271.0,
        },
        spawns = {
            vec4(440.3240, -1026.1168, 28.3373, 2.6144),
            vec4(443.6043, -1025.7875, 28.2736, 3.4878),
        }
    },

    {
        label = 'Police Helicopters Garage',
        blip = true,
        job = 'police',
        type = 'aircraft',
        zone = {
            coords = vec3(448.49, -980.81, 44.0),
            size = vec3(15.0, 12.0, 4.0),
            rotation = 0.5,
        },
        spawns = {
            vec4(449.1612, -981.1318, 43.2794, 91.1547),
        }
    },

    {
        label = 'Pillbox Public',
        blip = false,
        type = 'car',
        zone = {
            coords = vec3(295.44, -607.76, 43.0),
            size = vec3(10.0, 14.0, 4.0),
            rotation = 340.0,
        },
        spawns = {
            vec4(295.5757, -610.7896, 42.9474, 69.4731),
            vec4(296.4612, -607.7762, 42.9310, 69.3626),
        }
    },

    {
        label = 'Sandy Shore Garage',
        blip = true,
        type = 'car',
        zone = {
            coords = vec3(1959.23, 3764.36, 32.0),
            size = vec3(12.0, 7.0, 4.0),
            rotation = 31.0,
        },
        spawns = {
            vec4(1953.2390, 3760.8667, 31.7912, 29.3780),
            vec4(1959.6553, 3764.4568, 31.7867, 29.9853),
        }
    },

    {
        label = 'Pillbox A',
        blip = true,
        type = 'car',
        job = 'ambulance',
        zone = {
            coords = vec3(368.49, -562.41, 29.0),
            size = vec3(26.0, 9.0, 4.0),
            rotation = 340.0,
        },
        spawns = {
            vec4(367.7774, -562.5544, 28.4356, 158.8421),
        }
    },
    {
        label = 'Pillbox Helicopters',
        blip = true,
        type = 'aircraft',
        job = 'ambulance',
        zone = {
            coords = vec3(351.0, -587.0, 74.0),
            size = vec3(28.0, 30.0, 9.0),
            rotation = 340.0,
        },
        spawns = {
            vec4(351.4203, -587.9789, 74.1656, 245.2842),
        }
    },
    {
        label = 'Burgershot Garage',
        blip = false,
        type = 'car',
        zone = {
            coords = vec3(-1171.92, -878.43, 14.0),
            size = vec3(8.0, 16.0, 4.0),
            rotation = 31.5,
        },
        spawns = {
            vec4(-1172.7887, -876.6992, 13.7087, 121.2434),
            vec4(-1170.8132, -880.0280, 13.7077, 120.9189),
        }
    },
}