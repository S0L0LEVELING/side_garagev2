
# Side Garage V2

## Dependencies
- es_extended (1.8 Above)
- ox_lib
- oxmysql

## Documentations

- radial menu export
```lua
    -- check if inside garage
    exports.side_garagev2:InsideGarage()

    -- check if inside impound
    exports.side_garagev2:InsideImpound()

    -- Trigger On Client To Open Vehicle List
    TriggerEvent('side_garagev2:client:requestVehicle')

    -- Trigger On Client To Store Vehicle
    TriggerEvent('side_garagev2:client:storeVehicle')

    -- Trigger On Client To Open Impound
    TriggerEvent('side_garagev2:client:requestImpoundVehicle')

```

- Whitelist Access to Whitelist Impound
```lua
sdpGarage.WhitelistAccess = {
    'police',
    'mechanic',
    'ambulance',
    'burgershot',
}

```

- Impound / Garage

    using ox_lib box zone to add garage,
    blip can be set to false or true, if true blip will show
    #
    job can be null, if null

```lua
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
        {
        type = 'car', -- car, boat or aircraft
        blipCoords = vector4(265.7472, 2598.3469, 43.8344, 15.7470),
        label = 'Whitelist Impound',
        whitelist = true, -- can be null or false
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
        job = 'police',
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
}

```

## Preview
![image](https://github.com/sleepyexe/side_garagev2/assets/67649181/fb8dccd8-7e02-4502-8b68-aed56ae7c525)
![image](https://github.com/sleepyexe/side_garagev2/assets/67649181/f4547228-8d36-4618-9731-0de0dbf4fa52)
