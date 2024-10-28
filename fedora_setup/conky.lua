require 'cairo'

local cpu_history = {}
local freq_history = {}
local temp_history = {}
local voltage_history = {}
local power_history = {}
local max_samples = 100
local last_update_time = 0
local update_interval = 0.001  -- 1 ms

function conky_main()
    if conky_window == nil then return end
    local current_time = os.clock()
    if current_time - last_update_time < update_interval then return end
    last_update_time = current_time

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
    update_freq_history()
    update_temp_history()
    -- update_voltage_history()
    -- update_power_history()

    draw_cpu_graph(cr, x, y, width, height)
    draw_freq_graph(cr, x, y, width, height)
    draw_temp_graph(cr, x, y, width, height)
    -- draw_voltage_graph(cr, x, y, width, height)
    -- draw_power_graph(cr, x, y, width, height)

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

function update_freq_history()
    local freq = tonumber(conky_parse("${freq_g}"))  -- Giả sử biến này tồn tại
    table.insert(freq_history, 1, freq)
    if #freq_history > max_samples then
        table.remove(freq_history)
    end
end

function update_temp_history()
    -- Sử dụng lệnh shell để lấy nhiệt độ và loại bỏ ký tự không phải số
    local temp_data = tonumber(conky_parse("${exec cat /sys/class/thermal/thermal_zone10/temp}"))
    table.insert(temp_history, 1, temp_data)
    if #temp_history > max_samples then
        table.remove(temp_history)
    end
end

function update_voltage_history()
    local voltage = tonumber(conky_parse("${hwmon volt 1}"))
    table.insert(voltage_history, 1, voltage)
    if #voltage_history > max_samples then
        table.remove(voltage_history)
    end
end

function update_power_history()
    local power = tonumber(conky_parse("${hwmon power 1}"))
    table.insert(power_history, 1, power)
    if #power_history > max_samples then
        table.remove(power_history)
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

function draw_freq_graph(cr, x, y, width, height)
    local step = width / max_samples
    local last_x, last_y = x + width, y + height

    for i, freq in ipairs(freq_history) do
        local this_x = x + width - (i * step)
        local this_y = y + height - (freq / 5.7 * height)  -- Giả sử tần số tối đa là 1000
        cairo_set_line_width(cr, 2)
        cairo_set_source_rgba(cr, 1, 0, 0, 0.8)  -- Màu đỏ
        cairo_move_to(cr, last_x, last_y)
        cairo_line_to(cr, this_x, this_y)
        cairo_stroke(cr)
        last_x, last_y = this_x, this_y
    end
end

function draw_temp_graph(cr, x, y, width, height)
    local step = width / max_samples
    local last_x, last_y = x + width, y + height
    for i, temp in ipairs(temp_history) do
        local this_x = x + width - (i * step)
        local this_y = y + height - (temp / 105000.0 * height)  -- Giả sử nhiệt độ tối đa là 100
        cairo_set_line_width(cr, 2)
        cairo_set_source_rgba(cr, 1, 0.5, 0, 0.8)  -- Màu cam
        cairo_move_to(cr, last_x, last_y)
        cairo_line_to(cr, this_x, this_y)
        cairo_stroke(cr)
        last_x, last_y = this_x, this_y
    end
end

-- function draw_voltage_graph(cr, x, y, width, height)
--     local step = width / max_samples
--     local last_x, last_y = x + width, y + height
--     for i, volt in ipairs(voltage_history) do
--         local this_x = x + width - (i * step)
--         local this_y = y + height - (volt / 1.5 * height)  -- Giả sử điện áp tối đa là 1.5V
--         cairo_set_line_width(cr, 2)
--         cairo_set_source_rgba(cr, 0, 0, 1, 0.8)  -- Màu xanh dương
--         cairo_move_to(cr, last_x, last_y)
--         cairo_line_to(cr, this_x, this_y)
--         cairo_stroke(cr)
--         last_x, last_y = this_x, this_y
--     end
-- end

-- function draw_power_graph(cr, x, y, width, height)
--     local step = width / max_samples
--     local last_x, last_y = x + width, y + height
--     for i, power in ipairs(power_history) do
--         local this_x = x + width - (i * step)
--         local this_y = y + height - (power / 100 * height)  -- Giả sử công suất tối đa là 100W
--         cairo_set_line_width(cr, 2)
--         cairo_set_source_rgba(cr, 0.5, 0, 0.5, 0.8)  -- Màu tím
--         cairo_move_to(cr, last_x, last_y)
--         cairo_line_to(cr, this_x, this_y)
--         cairo_stroke(cr)
--         last_x, last_y = this_x, this_y
--     end
-- end