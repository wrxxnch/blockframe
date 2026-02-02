--------------------------------------------------
-- INIT.LUA - BLOCKFRAME with Minecraft-style display
--------------------------------------------------

blockframe = {}
blockframe.active = {}
blockframe.memory = {}

--------------------------------------------------
-- Minecraft → Minetest translations
--------------------------------------------------
local mc_to_mt = {
    ["minecraft:dirt"]="mcl_core:dirt",
    ["minecraft:stone"]="mcl_core:stone",
    ["minecraft:flower_pot"]="mcl_core:flower_pot",
    ["minecraft:dandelion"]="mcl_core:dandelion",
    ["minecraft:wildflowers"]="mcl_core:wildflowers",
    ["minecraft:pink_petals"]="mcl_core:pink_petals",
    ["minecraft:cornflower"]="mcl_core:cornflower",
    ["minecraft:orange_tulip"]="mcl_core:orange_tulip",
    ["minecraft:oxeye_daisy"]="mcl_core:oxeye_daisy",
    ["minecraft:azure_bluet"]="mcl_core:azure_bluet",
}

--------------------------------------------------
-- HELP
--------------------------------------------------
function blockframe.help_text()
	return [[
📦 BlockFrame — Help

Commands:
/blockframe <args>
/blockframe_set
/blockframe_cancel
/blockframe_undo
/blockframe_del
/blockframe_help
/blockframe_display <JSON>   # Accepts Minecraft-style Passengers JSON

ARGS:
 size=x,y,z        block size
 rotate=x,y,z      rotation XYZ
 mirror=x|y|z      mirror
 pos=x,y,z         absolute or relative offset (~)
 step=value        snap

/blockframe_display example JSON:
{
  "Passengers":[
    {"id":"block_display","block_state":{"Name":"minecraft:flower_pot"},"transformation":[1.5,0,0,-0.25,0,1,0,0,0,0,1.5,-0.25,0,0,0,1]},
    {"id":"block_display","block_state":{"Name":"minecraft:dandelion"},"transformation":[0.48,0.18,0,0.37,-0.12,0.65,0.12,0.26,0.03,-0.17,0.48,0.12,0,0,0,1]}
  ]
}
]]
end

--------------------------------------------------
-- UTIL
--------------------------------------------------
local function parse_vec(str,def)
	if not str then return def end
	local vals={}
	for n in str:gmatch("([^,]+)") do table.insert(vals,n) end
	if #vals==1 then return {x=tonumber(vals[1]) or 0,y=tonumber(vals[1]) or 0,z=tonumber(vals[1]) or 0} end
	if #vals==2 then return {x=tonumber(vals[1]) or 0,y=tonumber(vals[2]) or 0,z=tonumber(vals[2]) or 0} end
	if #vals>=3 then return {x=tonumber(vals[1]) or 0,y=tonumber(vals[2]) or 0,z=tonumber(vals[3]) or 0} end
	return def
end

local function snap(v, step)
	if not step or step<=0 then return v end
	return {x=math.floor(v.x/step+0.5)*step,
	        y=math.floor(v.y/step+0.5)*step,
	        z=math.floor(v.z/step+0.5)*step}
end

local function parse_relative(val,base)
	-- supports "~", "~n" or absolute number
	if type(val)=="string" then
		if val:sub(1,1)=="~" then
			local n=tonumber(val:sub(2)) or 0
			return base+n
		else
			return tonumber(val) or base
		end
	end
	return val or base
end

local function parse_pos(str,base)
	base = base or {x=0,y=0,z=0}
	if not str then return base end
	local vals={}
	for n in str:gmatch("([^,]+)") do table.insert(vals,n) end
	return {
		x=parse_relative(vals[1],base.x),
		y=parse_relative(vals[2],base.y),
		z=parse_relative(vals[3],base.z)
	}
end

local function get_wielded_item(player)
	local stack = player:get_wielded_item()
	if stack:is_empty() then return end
	return stack:get_name()
end

--------------------------------------------------
-- ENTITIES
--------------------------------------------------
-- PREVIEW
minetest.register_entity("blockframe:preview",{
	initial_properties={
		visual="wielditem", physical=false, pointable=false, glow=5,
		visual_size={x=0.5,y=0.5}, collisionbox={0,0,0,0,0,0}, static_save=true
	},
	on_activate=function(self, staticdata)
		local data = minetest.deserialize(staticdata) or {}
		self.node=data.node or "default:stone"
		self.args={}
		self.step=0
		self.player=nil
		self.last_pos=nil
		self.offset={x=0,y=0,z=0}
		self.object:set_properties({wield_item=self.node,opacity=120})
	end,
	set_node=function(self,node)
		self.node=node
		self.object:set_properties({wield_item=node})
	end,
	apply_args=function(self,args)
		if args.size then self.args.size=parse_vec(args.size,{x=0.5,y=0.5,z=0.5}) end
		if args.mirror=="x" or args.mirror=="y" or args.mirror=="z" then self.args.mirror=args.mirror end
		if args.step then self.step=tonumber(args.step) or 0 end
		if args.pos then self.offset=args.pos; self.args.pos=self.offset end
		if args.rotate then
			local rx,ry,rz=args.rotate:match("([^,]+),([^,]+),([^,]+)")
			if rx and ry and rz then self.args.rotate={x=tonumber(rx) or 0,y=tonumber(ry) or 0,z=tonumber(rz) or 0}
			else local r=tonumber(args.rotate); self.args.rotate={x=0,y=r or 0,z=0} end
		end
		local base=self.args.size or {x=0.5,y=0.5,z=0.5}
		local v=table.copy(base)
		if self.args.mirror=="x" then v.x=-v.x end
		if self.args.mirror=="y" then v.y=-v.y end
		if self.args.mirror=="z" then v.z=-v.z end
		self.object:set_properties({visual_size=v})
		if self.args.rotate then
			self.object:set_rotation({x=math.rad(self.args.rotate.x or 0),
			                         y=math.rad(self.args.rotate.y or 0),
			                         z=math.rad(self.args.rotate.z or 0)})
		end
	end,
	on_step=function(self)
		if not self.player or not self.player:is_player() then return end
		local eye=vector.add(self.player:get_pos(),
			self.player:get_properties().eye_height and {x=0,y=self.player:get_properties().eye_height,z=0} or {x=0,y=1.6,z=0})
		local dir=self.player:get_look_dir()
		local start=vector.add(eye,vector.multiply(dir,0.2))
		local finish=vector.add(start,vector.multiply(dir,6))
		local ray=minetest.raycast(start,finish,true,true)
		for hit in ray do
			if hit.type=="object" and hit.ref==self.player then goto continue end
			local p=hit.intersection_point or hit.above
			if p then
				p=snap(p,self.step)
				p=vector.add(p,self.offset)
				self.object:set_pos(p)
				self.last_pos=p
				return
			end
			::continue::
		end
	end
})

-- PLACED
minetest.register_entity("blockframe:placed",{
	initial_properties={visual="wielditem",physical=false,pointable=true,static_save=true,
		visual_size={x=0.5,y=0.5},collisionbox={0,0,0,0,0,0}},
	on_activate=function(self,staticdata)
		local data=minetest.deserialize(staticdata) or {}
		self.node=data.node or "default:stone"
		self.args=data.args or {}
		self.object:set_properties({wield_item=self.node})
		local base=self.args.size or {x=0.5,y=0.5,z=0.5}
		local v=table.copy(base)
		if self.args.mirror=="x" then v.x=-v.x end
		if self.args.mirror=="y" then v.y=-v.y end
		if self.args.mirror=="z" then v.z=-v.z end
		self.object:set_properties({visual_size=v})
		if type(self.args.rotate)=="table" then
			self.object:set_rotation({x=math.rad(self.args.rotate.x or 0),
			                          y=math.rad(self.args.rotate.y or 0),
			                          z=math.rad(self.args.rotate.z or 0)})
		end
		if self.args.pos then self.object:set_pos(self.args.pos) end
	end,
	get_staticdata=function(self)
		return minetest.serialize({node=self.node,args=self.args})
	end
})

--------------------------------------------------
-- /blockframe_display
--------------------------------------------------
minetest.register_chatcommand("blockframe_display",{
	func=function(name,param)
		local player=minetest.get_player_by_name(name)
		if not player then return false,"Player not found" end
		if param=="" then return false,"You must provide JSON" end

		local ok,data=pcall(minetest.parse_json,param)
		if not ok then return false,"Invalid JSON" end
		if not data.Passengers or type(data.Passengers)~="table" then return false,"No Passengers found" end

		-- cleanup previous previews
		if blockframe.active[name] then
			for _,ent in pairs(blockframe.active[name].entities or {}) do
				if ent.object then ent.object:remove() end
			end
		end
		blockframe.active[name]={entities={}}

		local base_pos=player:get_pos()
		for _,passenger in ipairs(data.Passengers) do
			local node=passenger.block_state and passenger.block_state.Name or "default:stone"
			if mc_to_mt[node] then node=mc_to_mt[node] end
			local t=passenger.transformation or {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
			local size={x=t[1],y=t[11],z=t[12]}
			local pos=parse_pos(
				string.format("%s,%s,%s",t[13] or 0,t[14] or 0,t[15] or 0),
				base_pos
			)
			local rot={x=0,y=(t[4] or 0)*180/math.pi,z=0}

			local obj=minetest.add_entity(pos,"blockframe:preview",minetest.serialize({node=node}))
			if obj and obj:get_luaentity() then
				local ent=obj:get_luaentity()
				ent.player=player
				ent.args={size=size,rotate=rot,pos=pos}
				ent:apply_args(ent.args)
				table.insert(blockframe.active[name].entities,ent)
			end
		end

		return true,"Display preview spawned"
	end
})

--------------------------------------------------
-- /blockframe_set
--------------------------------------------------
minetest.register_chatcommand("blockframe_set",{
	func=function(name)
		local data=blockframe.active[name]
		if not data or not data.entities then return false,"No active preview" end
		for _,ent in ipairs(data.entities) do
			if ent and ent.object then
				local pos=ent.object:get_pos()
				minetest.add_entity(pos,"blockframe:placed",minetest.serialize({node=ent.node,args=ent.args}))
				ent.object:remove()
			end
		end
		blockframe.active[name]=nil
		return true,"BlockFrame placed"
	end
})

--------------------------------------------------
-- /blockframe_cancel
--------------------------------------------------
minetest.register_chatcommand("blockframe_cancel",{
	func=function(name)
		local data=blockframe.active[name]
		if not data or not data.entities then return false,"No active preview" end
		for _,ent in ipairs(data.entities) do
			if ent.object then ent.object:remove() end
		end
		blockframe.active[name]=nil
		return true,"Preview cancelled"
	end
})

--------------------------------------------------
-- /blockframe_help
--------------------------------------------------
minetest.register_chatcommand("blockframe_help",{
	func=function() return true,blockframe.help_text() end
})
