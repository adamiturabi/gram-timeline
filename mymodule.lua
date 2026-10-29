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
  ["and"] = { x = 0.5, name_en = "Spain"       , name_ar = "الأندلس" }, -- Andalus
  ["afr"] = { x = 1.5, name_en = "North Africa", name_ar = "إفريقية" },-- North Africa
  ["msr"] = { x = 2.5, name_en = "Egypt"       , name_ar = "مصر" },    -- Egypt
  ["shm"] = { x = 3.5, name_en = "Syria"       , name_ar = "الشام" },  -- the Levant
  ["hjz"] = { x = 4.5, name_en = "Arabia"      , name_ar = "الحجاز" }, -- Arabia
  ["erq"] = { x = 5.5, name_en = "Iraq"        , name_ar = "العراق" }, -- Iraq/Baghdad
  ["frs"] = { x = 6.5, name_en = "Persia"      , name_ar = "الفارس" }, -- Persia
  ["bsr"] = { x = 5.75,name_en = "al-Baṣrah"   , name_ar = "البصرة" }, -- Basrah
  ["kwf"] = { x = 5.25,name_en = "al-Kūfah"    , name_ar = "الكوفة" }, -- Kufah
}
function ce2ah(ce)
  return (ce - 622 + 1) * 365.25 / (29.5 * 12)
end
function ah2ce(ah)
  return ah * (29.5 * 12) / 365.25 + 622 - 1
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
    if v.x > max_reg_val then
      max_reg_val = v.x
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
    --print(base_region, add_val)
    x = regions[base_region].x + add_val
    y = v.yod
    --print(v.region_code)
    tex.print(string.format("\\coordinate (pointnode)  at (%.2f,%.2f) {};", x, y))
    tex.print(string.format("\\node [fill, draw, circle, minimum width=2pt, inner sep=0] at (%.2f,%.2f) {};", x, y))
    tex.print(string.format("\\node (labelnode)  [inner sep=0, outer sep=0, %s of=pointnode, xshift=%.2f, yshift=%.2f,anchor=%s] {\\footnotesize %s};", v.align, v.xshift, v.yshift, v.anchor, get_name(v, use_lang)))
    tex.print(string.format("\\draw (pointnode)  -- (labelnode.%s);", v.anchor))
  end

end

function  M.plot_axes(use_lang)
  tex.print(string.format("\\draw [help lines, xstep=%s, ystep=%s] (%.2f, %.2f) grid (%.2f, %.2f + 1);",
    M.get_grid_step(),
    M.get_grid_step(),
    M.get_beg_reg_val(),
    M.get_beg_ah(),
    M.get_end_reg_val(),
    M.get_end_ah()
  ))

  -- Axis
  tex.print(string.format("\\draw [] (%.2f, 0) -- (%.2f, 0);",
    M.get_beg_reg_val(),
    M.get_end_reg_val()
  ))

  -- Axis ticks
  for y = y_grid_step_scale, M.get_end_ah(), y_grid_step_scale do
    tex.print(string.format("\\draw (0, %.2f) -- (-.2, %.2f) node [anchor=east] {\\footnotesize %d};",
      y, y, y))
  end
  -- 1AH
  tex.print(string.format("\\draw (0, 0) -- (-.2, 0) node [anchor=east] {\\footnotesize 1};"))
  tex.print(string.format("\\node  at (%.2f-0.5,50) {\\footnotesize \\textsc{ah}};", M.get_beg_reg_val()))
  tex.print(string.format("\\node  at (%.2f+0.5,30) {\\footnotesize \\textsc{ce}};", M.get_end_reg_val()))

  beg_ce = math.floor(ah2ce(M.get_beg_ah())/100) * 100
  end_ce = math.ceil(ah2ce(M.get_end_ah())/100) * 100
  for y = beg_ce, end_ce, y_grid_step_scale do
    tex.print(string.format("\\draw (7, %.2f) -- (7.2, %.2f) node [anchor=west] {\\footnotesize %d};",
    ce2ah(y), ce2ah(y), y))
  end
  for k,v in pairs(regions) do
    if v.x % 0.5 == 0 then
      tex.print(string.format("\\node[align=left, anchor=base] () at (%.2f, -8) {\\small %s};",
        v.x, get_name(v, use_lang)
      ))
    end
  end

  tex.print(string.format("\\node[rotate=90, align=left, anchor=west] () at (%.2f-0.05, -15) {\\scriptsize %s};",
    regions["kwf"].x, "←" .. get_name(regions["kwf"], use_lang)
  ))
  tex.print(string.format("\\node[rotate=90, align=left, anchor=west] () at (%.2f+0.05, -15) {\\scriptsize %s};",
    regions["bsr"].x, "←" .. get_name(regions["bsr"], use_lang)
  ))
  baghdad = {
    x = regions["erq"].x,
    name_en = "Bag͡hdād",
    name_ar = "بغداد"
  }
  tex.print(string.format("\\node[rotate=90, align=left, anchor=west] () at (%.2f, -15) {\\scriptsize %s};",
    baghdad.x, "←" .. get_name(baghdad, use_lang)
  ))
--\node[rotate=90,align=left,anchor=west] at (5.2, -15) {\scriptsize ←al-Kūfah};
--\node[rotate=90,align=left,anchor=west] at (5.5, -15) {\scriptsize ←Bag͡hdād};
--\node[rotate=90,align=left,anchor=west] at (5.8, -15) {\scriptsize ←al-Baṣrah};
--%\node[align=center,anchor=west] at (5.2, -85) {\small Iraq};

end

return M
