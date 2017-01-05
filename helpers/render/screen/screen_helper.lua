local M = {}
M.__index = M

function M.new()
	local self = setmetatable({},M)
	self.pred = render.predicate({"screen"})
	self.projection=vmath.matrix4_orthographic(0,0.02,0,0.02,-1,1)
	return self
end

function M:draw_in(render_target,x,y,width,height)
	render.set_viewport(x,y,width,height)
	M.draw(self,render_target)
	render.set_viewport(0,0,render.get_window_width(),render.get_window_height())
end

function M:draw(render_target,constants,clear_color)
	render.set_projection(self.projection)
	render.enable_texture(0, render_target, render.BUFFER_COLOR_BIT)
	if(clear_color~=nil) then
		render.clear({[render.BUFFER_COLOR_BIT] = clear_color, [render.BUFFER_DEPTH_BIT] = 1, [render.BUFFER_STENCIL_BIT] = 0})
	end
	render.draw(self.pred,constants)
	render.disable_texture(0,render_target)
end

return M