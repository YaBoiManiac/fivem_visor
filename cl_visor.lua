local visor_TOGGLES = {
    ["DOWN"] = {[0] = {},[1] = {}},
    ["UP"] = {[0] = {},[1] = {}}
}

local visor_getVisorDict = function(override)
    local ped = PlayerPedId()
    if ( not IsPedInAnyVehicle(ped, false) or override ) then
        return "anim@mp_helmets@on_foot"
    end

    local vehicle = GetVehiclePedIsUsing( ped )
    local model = GetEntityModel( vehicle )

    if ( IsThisModelABike( model ) ) then
        local layout = GetVehicleLayoutHash(vehicle)

        if ( layout == GetHashKey("LAYOUT_BIKE_FREEWAY") ) then
            return "anim@mp_helmets@on_bike@chopper"
        end

        if ( layout == GetHashKey("LAYOUT_BIKE_DIRT") ) then
            return "anim@mp_helmets@on_bike@dirt"
        end

        -- if ( layout == GetHashKey("LAYOUT_BIKE_POLICEB") ) then
        --     print("policeb")
        -- end

        if ( layout == GetHashKey("LAYOUT_BIKE_SCOOTER") ) then
            return "anim@mp_helmets@on_bike@scooter"
        end

        if ( layout == GetHashKey("LAYOUT_BIKE_SPORT") ) then
            return "anim@mp_helmets@on_bike@sports"
        end

        -- default
        return "anim@mp_helmets@on_bike@sports"
    end

    if ( IsThisModelAQuadbike( model ) ) then
        return "anim@mp_helmets@on_bike@quad"
    end

    return "anim@mp_helmets@on_foot"
end

local visor_playAnimation = function(ped, dict, anim)
    if ( not DoesAnimDictExist(dict) ) then
        return
    end

    if ( not HasAnimDictLoaded(dict) ) then
        local timeout = GetGameTimer() + 2000
        RequestAnimDict(dict)
        while ( not HasAnimDictLoaded(dict) and GetGameTimer() < timeout ) do
            Wait(0)
        end
    end

    if ( HasAnimDictLoaded(dict) ) then
        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 48, 0.0, false, false, false)
        RemoveAnimDict(dict)
    end
end

local visor_canVisorBeToggled = function(gender, comp)
    if ( visor_TOGGLES["DOWN"][gender][comp] ~= nil ) then
        return true
    end
    if ( visor_TOGGLES["UP"][gender][comp] ~= nil ) then
        return true
    end
    return false
end

local visor_isVisorDown = function(gender, comp)
    return visor_TOGGLES["DOWN"][gender][comp] ~= nil
end

local visor_setDown = function(gender, comp)
    local anim = ( ( comp <= 119 and comp >= 115 ) and "goggles_down" or "visor_down" )
    local dict = visor_getVisorDict( anim == "goggles_down" )

    if ( dict == "anim@mp_helmets@on_foot" and not IsFollowPedCamActive() ) then
        anim = "pov_visor_down"
    end

    local ped = PlayerPedId()
    visor_playAnimation(ped, dict, anim)
    while ( GetEntityAnimCurrentTime(ped, dict, anim) < 0.4 ) do Wait(100)
        if (GetEntityAnimCurrentTime(ped, dict, anim) == 0.0) then
            return
        end
    end

    local texture = GetPedPropTextureIndex(PlayerPedId(), 0)
    SetPedPropIndex(ped, 0, visor_TOGGLES["UP"][gender][comp], texture, 2)
end

local visor_setUp = function(gender, comp)
    local anim = ( ( comp <= 119 and comp >= 115 ) and "goggles_up" or "visor_up" )
    local dict = visor_getVisorDict( anim == "goggles_up" )

    if ( dict == "anim@mp_helmets@on_foot" and not IsFollowPedCamActive() ) then
        anim = "pov_visor_up"
    end

    local ped = PlayerPedId()
    visor_playAnimation(ped, dict, anim)
    while ( GetEntityAnimCurrentTime(ped, dict, anim) < 0.4 ) do Wait(100)
        if (GetEntityAnimCurrentTime(ped, dict, anim) == 0.0) then
            return
        end
    end

    local texture = GetPedPropTextureIndex(PlayerPedId(), 0)
    SetPedPropIndex(ped, 0, visor_TOGGLES["DOWN"][gender][comp], texture, 2)
end

local visor_toggle = function()
    local gender = (GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") and 0 or 1)
    local comp = GetPedPropIndex(PlayerPedId(), 0)
    if ( visor_canVisorBeToggled( gender, comp ) ) then
        if ( visor_isVisorDown( gender, comp ) ) then
            visor_setUp( gender, comp )
        else
            visor_setDown( gender, comp )
        end
    end
end

Citizen.CreateThread(function()

    for k,v in pairs(Config.Visors.Male) do
        visor_TOGGLES["DOWN"][0][k] = v
        visor_TOGGLES["UP"][0][v] = k
    end

    for k,v in pairs(Config.Visors.Female) do
        visor_TOGGLES["DOWN"][1][k] = v
        visor_TOGGLES["UP"][1][v] = k
    end

    RegisterCommand(Config.CommandName, visor_toggle)

    if ( Config.KeyCommandEnabled or Config.EnableNightVision ) then
        while true do Wait(0)
            if ( Config.KeyCommandEnabled ) then
                if ( IsControlJustPressed(0, Config.KeyCommand) ) then
                    visor_toggle()
                end
            end

            if ( Config.EnableNightVision ) then
                if ( GetRenderingCam() == -1 ) then
                    local gender = (GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") and 0 or 1)
                    local comp = GetPedPropIndex(PlayerPedId(), 0)
                    if ( comp <= 119 and comp >= 115 ) then
                        if ( visor_TOGGLES["DOWN"][gender][comp] ) then
                            if ( not GetUsingnightvision() ) then
                                SetNightvision(true)
                                PlaySoundFrontend(-1, "On", "GTAO_Vision_Modes_SoundSet", false)
                            end
                        else
                            if ( GetUsingnightvision() ) then
                                SetNightvision(false)
                                PlaySoundFrontend(-1, "Off", "GTAO_Vision_Modes_SoundSet", false)
                            end
                        end
                    elseif ( GetUsingnightvision() ) then
                        SetNightvision(false)
                    end
                end
            end

        end

    end

end)