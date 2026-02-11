-- translate.lua

blockframe = blockframe or {}

blockframe.mc_translate = {

    ["minecraft:dirt"] = "mcl_core:dirt",
    ["minecraft:grass_block"] = "mcl_core:dirt_with_grass",
    ["minecraft:stone"] = "mcl_core:stone",

    ["minecraft:oak_slab"] = "mcl_stairs:slab_wood",
    ["minecraft:spruce_slab"] = "mcl_stairs:slab_spruce",

    ["minecraft:light_gray_carpet"] = "mcl_wool:carpet_light_grey",
    ["minecraft:oak_fence"] = "mcl_fences:fence",
    ["minecraft:iron_chain"] = "mcl_core:chain",
}

function blockframe.translate_node(mc_name)

    if blockframe.mc_translate[mc_name] then
        return blockframe.mc_translate[mc_name]
    end

    local fallback = mc_name:gsub("minecraft:", "mcl_core:")

    if minetest.registered_nodes[fallback] then
        return fallback
    end

    return mc_name
end
