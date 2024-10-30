require 'cairo'

local cpu_history = {}
local max_samples = 100

function conky_main()
    if conky_window == nil then return end
    
    local cs = cairo_xlib_surface_create(conky_window.display,
        conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    local width, height = 160, 50
    local x, y = conky_window.width - width - 2, 2

    -- Vẽ khung chung cho đồ thị
    cairo_set_source_rgba(cr, 0.1, 0.1, 0.1, 0.5)
    cairo_rectangle(cr, x, y, width, height)
    cairo_fill(cr)

    update_cpu_history()
    
    draw_cpu_graph(cr, x, y, width, height)
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

function update_cpu_history()
    local cpu_usage = tonumber(conky_parse("${cpu cpu0}"))
    table.insert(cpu_history, 1, cpu_usage)
    if #cpu_history > max_samples then
        table.remove(cpu_history)
    end
end

function draw_cpu_graph(cr, x, y, width, height)
    local step = width / max_samples
    local last_x, last_y = x + width, y + height

    for i, usage in ipairs(cpu_history) do
        local this_x = x + width - (i * step)
        local this_y = y + height - (usage / 100.0 * height)
        cairo_set_line_width(cr, 2)
        cairo_set_source_rgba(cr, 0, 1, 0, 0.8)  -- Màu xanh lá
        cairo_move_to(cr, last_x, last_y)
        cairo_line_to(cr, this_x, this_y)
        cairo_stroke(cr)
        last_x, last_y = this_x, this_y
    end
end

