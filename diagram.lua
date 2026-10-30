
local csvutils = require("csvutils")

local grid_step_val = 1.5
local grid_step_unit = 'cm'
local y_grid_step_scale = 100.0


function get_grid_step()
  return tostring(grid_step_val) .. grid_step_unit
end
function get_pic_x()
  return get_grid_step()
  end
function get_pic_y()
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
function get_beg_ah()
  return 0
end
function get_end_ah()
  return 1000
end
function get_beg_reg_val()
  return 0
end
function get_end_reg_val()
  max_reg_val = get_beg_reg_val()
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
 
function plot_grammarians(use_lang)
  local grammarians, gram_order = csvutils.parseCommentHeaderCSV("grammarians.csv")
 
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
function get_font_size(size_str, use_lang)
  dict = {
    [-4]  = "\\tiny",
    [-3]  = "\\scriptsize",
    [-2]  = "\\footnotesize",
    [-1]  = "\\small",
    [0]   = "\\normalsize",
    [1]   = "\\large",
    [2]   = "\\Large",
    [3]   = "\\LARGE",
    [4]   = "\\huge",
    [5]   = "\\Huge"
  }
  if size_str == nil or size_str == "" then
    size_str = 0
  end
  local size_int = tonumber(size_str)
  -- bump up Arabic font size
  if use_lang == 'ar' then
    size_int = size_int + 1
  end
  return dict[size_int]
end
--Colors
--E9E2D0 D7C7B8 C7D7D4 B9C7D6
--FFF9F0 F2E6D5 D9CBB8 CFE0D2 B8CBBE
--E6EBF1 D7DEE8 C7D0DB
--C7DADD E6E2F7 F2E9E4
--FBE7B8 E7D3A2 D6E7F7 E5F0E8
--E7E2D7 D6CFC2 C9D2D6 B8C3C9
--FFD6C9 FBEAF3
function get_rgb(hex_color)
  if hex_color == '0' then
    return 255,255,255,0
  end
  red_hex   = string.sub(hex_color, 1, 2)
  green_hex = string.sub(hex_color, 3, 4)
  blue_hex  = string.sub(hex_color, 5, 6)
  return tonumber(red_hex, 16), tonumber(green_hex, 16), tonumber(blue_hex, 16), 0.75
end
function plot_dynasties(use_lang, color)
  local dynasties, dyn_order = csvutils.parseCommentHeaderCSV("dynasties.csv")
 
  for index, k in ipairs(dyn_order) do
    v = dynasties[k]
    local reg_beg, add_val = get_region_parts(v.reg_beg)
    reg_beg = regions[reg_beg].x + add_val
    local reg_end, add_val = get_region_parts(v.reg_end)
    reg_end = regions[reg_end].x + add_val
    x_label = reg_beg + (reg_end - reg_beg)/2
    y_label = ce2ah(v.ce_beg + (v.ce_end - v.ce_beg)/2)
    shifts = ""
    if v.shifts ~= nil then
      shifts = v.shifts:gsub("%|", ",")
    end
    name = get_font_size(v.name_size, use_lang) .. " " .. get_name(v, use_lang)
    tex.print("\\begin{pgfonlayer}{background}")
    if color == true then
      tex.print(string.format("\\fill [fill={rgb,255:red,%d;green,%d;blue,%d}, fill opacity=%.2f]", get_rgb(v.color)))
    else
      tex.print(string.format("\\fill [pattern=%s,pattern color=black!10!white]", v.pattern))
    end
    tex.print(string.format("(%.2f,%.2f) rectangle (%.2f,%.2f);", reg_beg, ce2ah(v.ce_beg), reg_end, ce2ah(v.ce_end)))
    tex.print(string.format("\\node [black!45, %s, font=\\bfseries\\sffamily] at (%.2f, %.2f) {%s};",
      shifts, x_label, y_label, name))
    tex.print("\\end{pgfonlayer}")
  end
end


function  plot_axes(use_lang)
  tex.print(string.format("\\draw [help lines, xstep=%s, ystep=%s] (%.2f, %.2f) grid (%.2f, %.2f + 1);",
    get_grid_step(),
    get_grid_step(),
    get_beg_reg_val(),
    get_beg_ah(),
    get_end_reg_val(),
    get_end_ah()
  ))

  -- Axis
  tex.print(string.format("\\draw [] (%.2f, 0) -- (%.2f, 0);",
    get_beg_reg_val(),
    get_end_reg_val()
  ))

  -- Axis ticks
  for y = y_grid_step_scale, get_end_ah(), y_grid_step_scale do
    tex.print(string.format("\\draw (0, %.2f) -- (-.2, %.2f) node [anchor=east] {\\footnotesize %d};",
      y, y, y))
  end
  -- 1AH
  tex.print(string.format("\\draw (0, 0) -- (-.2, 0) node [anchor=east] {\\footnotesize 1};"))
  tex.print(string.format("\\node  at (%.2f-0.5,50) {\\footnotesize \\textsc{ah}};", get_beg_reg_val()))
  tex.print(string.format("\\node  at (%.2f+0.5,30) {\\footnotesize \\textsc{ce}};", get_end_reg_val()))

  beg_ce = math.floor(ah2ce(get_beg_ah())/100) * 100
  end_ce = math.ceil(ah2ce(get_end_ah())/100) * 100
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

end
function plot_phase(desc_en, desc_ar, beg_y, end_y, use_lang)
  desc = desc_en
  if use_lang == 'ar' then
    desc = "\\foreignlanguage{arabic}{" .. desc_ar .. "}"
  end
  tex.print(string.format("\\draw [thin] (-0.8,%.2f+2) -- (-1,%.2f+2) -- (-1, %.2f-2) node [midway, above, rotate=90,align=center, font=\\sffamily] {\\footnotesize %s} -- (-0.8,%.2f-2);", beg_y, beg_y, end_y, desc, end_y))
end
function plot_phases(use_lang)
    plot_phase("Precursors", "النشأة",
      ce2ah(660), ce2ah(770), use_lang)
    plot_phase("Early grammar", "الوضع",
      ce2ah(770), ce2ah(920), use_lang)
    plot_phase("Codification and\\\\\\footnotesize systematization", "التوسيع والترتيب",
      ce2ah(920), ce2ah(1100), use_lang)
    plot_phase("Elaboration of forms of presentation", "التبيين والتحقيق",
      ce2ah(1100),ce2ah(1520), use_lang)
end

local M = {}

function M.draw(use_lang, color)
  if color == 'true' then
    color = true
  else
    color = false
  end
  tex.print(string.format("\\begin{tikzpicture}[x=%s, y=%s, yscale=-1]",
    get_pic_x(),
    get_pic_y()
  ))
  plot_dynasties(use_lang, color)
  plot_axes(use_lang)
  plot_grammarians(use_lang)
  plot_phases(use_lang)

  tex.print("\\end{tikzpicture}")
end

return M

