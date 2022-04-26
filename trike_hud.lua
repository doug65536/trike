trike.hud_list = {}

function trike.animate_gauge(player, ids, prefix, x, y, angle)
    local angle_in_rad = math.rad(angle + 180)
    local dim
    local pos_x
    local pos_y
    
    for pt = 1,7
    do
        dim = pt * 10
        pos_x = math.sin(angle_in_rad) * dim
        pos_y = math.cos(angle_in_rad) * dim
        player:hud_change(ids[prefix .. pt], "offset", {x = pos_x + x, y = pos_y + y})
    end
end

function trike.update_hud(player, climb, speed, power, fuel)
    local player_name = player:get_player_name()

    local screen_pos_y = -150
    local screen_pos_x = 10

    local clb_gauge_x = screen_pos_x + 75
    local clb_gauge_y = screen_pos_y + 1
    local sp_gauge_x = screen_pos_x + 170
    local sp_gauge_y = clb_gauge_y

    local pwr_gauge_x = screen_pos_x + 330
    local pwr_gauge_y = clb_gauge_y

    local fu_gauge_x = screen_pos_x + 340
    local fu_gauge_y = clb_gauge_y

    local ids = trike.hud_list[player_name]
    if ids then
        trike.animate_gauge(player, ids, "clb_pt_", clb_gauge_x, clb_gauge_y, climb)
        trike.animate_gauge(player, ids, "sp_pt_", sp_gauge_x, sp_gauge_y, speed)
        trike.animate_gauge(player, ids, "pwr_pt_", pwr_gauge_x, pwr_gauge_y, power)
        trike.animate_gauge(player, ids, "fu_pt_", fu_gauge_x, fu_gauge_y, fuel)
    else
        ids = {}

        ids["title"] = player:hud_add({
            hud_elem_type = "text",
            position  = {x = 0, y = 1},
            offset    = {x = screen_pos_x +140, y = screen_pos_y -100},
            text      = "Flight Information",
            alignment = 0,
            scale     = { x = 100, y = 30},
            number    = 0xFFFFFF,
        })

        ids["bg"] = player:hud_add({
            hud_elem_type = "image",
            position  = {x = 0, y = 1},
            offset    = {x = screen_pos_x, y = screen_pos_y},
            text      = "trike_hud_panel.png",
            scale     = { x = 0.5, y = 0.5},
            alignment = { x = 1, y = 0 },
        })

        local pts = {
            {prefix = "clb_pt_", offset = {x = clb_gauge_x, y = clb_gauge_y}},
            {prefix = "sp_pt_", offset = {x = sp_gauge_x, y = sp_gauge_y}},
            {prefix = "pwr_pt_", offset = {x = pwr_gauge_x, y = pwr_gauge_y}},
            {prefix = "fu_pt_", offset = {x = fu_gauge_x, y = fu_gauge_y}}
        }
        local scale = { x = 6, y = 6}
        local alignment = { x = 1, y = 0 }
        local position = { x = 0, y = 1 }

        for _, ptinfo in pairs(pts)
        do
            for pt = 1,7
            do
                local offset = ptinfo["offset"]
                ids[ptinfo["prefix"] .. pt] = player:hud_add({
                    hud_elem_type = "image",
                    position  = position,
                    offset    = {x = offset["x"], y = offset["y"]},
                    text      = "trike_ind_box.png",
                    scale     = scale,
                    alignment = alignment,
                })
            end
        end

        trike.hud_list[player_name] = ids
    end
end


function trike.remove_hud(player)
    if player then
        local player_name = player:get_player_name()
        --minetest.chat_send_all(player_name)
        local ids = trike.hud_list[player_name]
        if ids then
            --player:hud_remove(ids["altitude"])
            --player:hud_remove(ids["time"])
            player:hud_remove(ids["title"])
            player:hud_remove(ids["bg"])
            for pt = 1,7
            do
                player:hud_remove(ids["clb_pt_" .. pt])
                player:hud_remove(ids["sp_pt_" .. pt])
                player:hud_remove(ids["pwr_pt_" .. pt])
                player:hud_remove(ids["fu_pt_" .. pt])
            end
        end
        trike.hud_list[player_name] = nil
    end

end
