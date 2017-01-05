local Screen_helper = require "helpers.render.screen.screen_helper"

local add_light_hash=hash("add_light")


local M = {}
M.__index = M


local function init_render_targets(self,size)
	local color_params = {
		format = render.FORMAT_RGBA,
		width = render.get_width(),
		height = render.get_height(),
		min_filter = render.FILTER_LINEAR,
		mag_filter = render.FILTER_LINEAR,
		u_wrap = render.WRAP_CLAMP_TO_EDGE,
		v_wrap = render.WRAP_CLAMP_TO_EDGE }

	self.occlusion_map_target=render.render_target("occlusion_map_target", {[render.BUFFER_COLOR_BIT] = color_params})
	self.light_map_target=render.render_target("light_map_target", {[render.BUFFER_COLOR_BIT] = color_params})

	local shadow_color_params = {
    format = render.FORMAT_RGBA,
  	width = size,
  	height = 1,
  	min_filter = render.FILTER_LINEAR,
  	mag_filter = render.FILTER_LINEAR,
  	u_wrap = render.WRAP_REPEAT,
  	v_wrap = render.WRAP_REPEAT }
	self.shadow_map_target=render.render_target("shadow_map_target", {[render.BUFFER_COLOR_BIT] = shadow_color_params})
end

--soft shadows is number from 0 to 1
--light_size is number of rays per light source
function M.new(light_size, additive, soft_shadows)
	local self = setmetatable({},M)
	self.screen_helper=Screen_helper:new()
	self.light_size=light_size
	self.lights={}
	self.additive=additive
	self.soft_shadows=soft_shadows
	self.block_light_pred = render.predicate({"block_light"})
	self.pred = render.predicate({"screen"})
	init_render_targets(self,light_size)
	self.clear_color=vmath.vector4(0,0,0,0)
	return self
end


local function enable_blend(self)
	render.enable_state(render.STATE_BLEND)
	if(self.additive) then
    	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE)
    else
    	render.set_blend_func(render.BLEND_SRC_ALPHA, render.BLEND_ONE_MINUS_SRC_ALPHA)
	end
end

--maybe use one big occlusion_target
local function draw_occlusion(self,light)
	--render.set_viewport(0, 0, self.light_size, self.light_size)
	--render.set_projection(vmath.matrix4_orthographic(-self.light_size/2+light.position.x, self.light_size/2+light.position.x, -self.light_size/2+light.position.y, self.light_size/2+light.position.y, -1, 1))
	render.enable_render_target(self.occlusion_map_target)
	render.clear({[render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0})
	render.draw(self.block_light_pred)
	render.disable_render_target(self.occlusion_map_target)
	--self.screen_helper:draw_in(self.occlusion_map_target,600,0,256,256)
end

--THE BOTTLENECK HERE
local function draw_shadow_map(self,light)
	render.set_viewport(0, 0, self.light_size, self.light_size)
	self.projection=vmath.matrix4_orthographic(0,0.02,0,0.02,-1,1)
	render.set_projection(self.projection)
	render.enable_render_target(self.shadow_map_target)
	--render.clear({[render.BUFFER_COLOR_BIT] = self.clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0})
	render.enable_material("2d_light_shadow")
	render.enable_texture(0,self.occlusion_map_target, render.BUFFER_COLOR_BIT)
	render.draw(self.pred,light.const)
	render.disable_texture(0,self.occlusion_map_target)
	render.disable_material("2d_light_shadow")
	render.disable_render_target(self.shadow_map_target)
	--self.screen_helper:draw_in(self.shadow_map_target,600,0,256,256)
end

local function draw_light_map(self,light)
	enable_blend(self)

	local width=render.get_width()
	local height=render.get_height()
	local width_scale = width/self.light_size/light.scale
	local height_scale = height/self.light_size/light.scale
	render.set_viewport(0, 0, render.get_window_width(), render.get_height())
	local x=0.01 * width_scale-light.position.x/width*0.02*width_scale + 0.01
	local y=0.01 * height_scale-light.position.y/height*0.02*height_scale + 0.01

	local projection=vmath.matrix4_orthographic(x-0.01*width_scale,x+0.01*width_scale,y-0.01*height_scale,y+0.01*height_scale,-1,1)
	render.set_projection(projection)

	--print(light.color)
	render.enable_material("light_map")
	render.enable_texture(0, self.shadow_map_target, render.BUFFER_COLOR_BIT)

	render.draw(self.pred,light.const)
	render.disable_texture(0,self.shadow_map_target)
	render.disable_material("light_map")
end




local function draw_light(self,light)
	draw_shadow_map(self,light)
	draw_light_map(self,light)
	render.set_viewport(0, 0, render.get_window_width(), render.get_height())
end

function M:draw()
	draw_occlusion(self)
	for key,light in pairs(self.lights) do
		draw_light(self,light)
	end
end

function M:handle_message(message_id,message)
	if(message_id==add_light_hash)then
		local light_constants = render.constant_buffer()
    	light_constants.resolution = vmath.vector4(self.light_size, self.light_size, 0, 0)
  		light_constants.up_scale=vmath.vector4(message.scale,0,0,0)
   		light_constants.vColor = message.color
   		light_constants.pos=vmath.vector4(message.position.x,message.position.y,render.get_width(),render.get_height())
		local light={position=message.position,size=message.size,color=message.color,const=light_constants,scale=message.scale}
		self.lights[message.light_id]=light
	end
end



return M
