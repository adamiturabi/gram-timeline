local M = {}

local csvutils = require("csvutils")

local grid_step_val = 1.5
local grid_step_unit = 'cm'
local y_grid_step_scale = 100.0
function M.get_grid_step()
  return tostring(grid_step_val) .. grid_step_unit
end
function M.get_pic_x()
  return M.get_grid_step()
  end
function M.get_pic_y()
  return tostring(grid_step_val / y_grid_step_scale) .. grid_step_unit
end


local regions = {
  ["and"] = 0.5, -- Andalus
  ["afr"] = 1.5, -- North Africa
  ["msr"] = 2.5, -- Egypt
  ["shm"] = 3.5, -- the Levant
  ["hjz"] = 4.5, -- Arabia
  ["erq"] = 5.5, -- Iraq/Baghdad
  ["frs"] = 6.5, -- Persia
  ["bsr"] = 5.25,-- Basrah
  ["kwf"] = 5.25,-- Kufah
}

function ce2ah(ce)
  return (ce - 622 + 1) * 365.25 / (29.5 * 12)
end
function M.get_beg_ah()
  return 0
end
function M.get_end_ah()
  return 1000
end
function M.get_beg_reg_val()
  return 0
end
function M.get_end_reg_val()
  max_reg_val = M.get_beg_reg_val()
  for k, v in pairs(regions) do
    if v > max_reg_val then
      max_reg_val = v
    end
  end
  return math.ceil(max_reg_val)
end

function get_name(v, use_lang)
  if use_lang == 'ar' then
    return '\\foreignlanguage{arabic}{' .. v.name_ar .. '}'
  else
    assert(use_lang == 'en')
    return v.name_en
  end
end

function get_region_parts(region_code)
  local region_parts = csvutils.split(region_code, "%+")
  local add_val = 0
  local base_region = region_code
  if #region_parts > 1 then
    base_region = region_parts[1]
    add_val = tonumber(region_parts[2])
  else
    region_parts = csvutils.split(region_code, "%-")
    if #region_parts > 1 then
      base_region = region_parts[1]
      add_val = - tonumber(region_parts[2])
    end
  end
  return base_region, add_val
end
 
function M.plot_grammarians(use_lang)

  local grammarians = csvutils.parseCommentHeaderCSV("grammarians.csv")
 
  for k, v in pairs(grammarians) do
    local base_region, add_val = get_region_parts(v.region_code)
    print(base_region, add_val)
    x = regions[base_region] + add_val
    y = v.yod
    --print(v.region_code)
    tex.print(string.format("\\coordinate (pointnode)  at (%.2f,%.2f) {};", x, y))
    tex.print(string.format("\\node [fill, draw, circle, minimum width=2pt, inner sep=0] at (%.2f,%.2f) {};", x, y))
    tex.print(string.format("\\node (labelnode)  [inner sep=0, outer sep=0, %s of=pointnode, xshift=%.2f, yshift=%.2f,anchor=%s] {\\footnotesize %s};", v.align, v.xshift, v.yshift, v.anchor, get_name(v, use_lang)))
    tex.print(string.format("\\draw (pointnode)  -- (labelnode.%s);", v.anchor))
  end

end

return M
