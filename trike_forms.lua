dofile(minetest.get_modpath("trike") .. DIR_DELIM .. "trike_global_definitions.lua")

--------------
-- Manual --
--------------

function trike.getPlaneFromPlayer(player)
    local seat = player:get_attach()
    if seat then
        local plane = seat:get_attach()
        return plane
    end
    return nil
end

function trike.pilot_formspec(name)
    local player = minetest.get_player_by_name(name)
    local plane_obj = trike.getPlaneFromPlayer(player)
    local plane = plane_obj:get_luaentity()
    local pitch_button = "Toggle pitch up mechanism. Current: "
    if plane._pitch_up_dir == "up" then
        pitch_button = pitch_button .. "Forward"
    else
        pitch_button = pitch_button .. "Back"
    end

    local buttons = {
        {n="go_out", t="Go Offboard"},
        {n="hud", t="Show/Hide Gauges"},
        {n="toggle_up", t=pitch_button},
    }

    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6," .. (#buttons * 1.5 + 1.5) .. "]",
	}, "")

    for index, button in ipairs(buttons)
    do
        local y = 1 + (index - 1) * 1.5
        basic_form = basic_form ..
            "button[1," .. y .. ";4,1;" ..
            button.n .. ";" ..
            button.t .. "]"
    end

    minetest.show_formspec(name, "trike:pilot_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "trike:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = trike.getPlaneFromPlayer(player)
        if plane_obj == nil then
            minetest.close_formspec(name, "trike:pilot_main")
            return
        end
        local ent = plane_obj:get_luaentity()
        if fields.hud then
            if ent._show_hud == true then
                ent._show_hud = false
            else
                ent._show_hud = true
            end
        end
		if fields.go_out then
            -- eject passenger if the plane is on ground
            local touching_ground, liquid_below = trike.check_node_below(plane_obj)
            if ent.isinliquid or touching_ground or liquid_below then --isn't flying?
                if ent._passenger then
                    local passenger = minetest.get_player_by_name(ent._passenger)
                    if passenger then trike.dettach_pax(ent, passenger) end
                end
            end
            trike.dettachPlayer(ent, player)
		end
        if fields.toggle_up then
            if ent._pitch_up_dir == "up" then
                ent._pitch_up_dir = "down"
            else
                ent._pitch_up_dir = "up"
            end
        end
        minetest.close_formspec(name, "trike:pilot_main")
    end
end)
