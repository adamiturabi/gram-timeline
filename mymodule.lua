local M = {}

function get_name(v, use_lang)
  if use_lang == 'ar' then
    return '\\foreignlanguage{arabic}{' .. v.name_ar .. '}'
  else
    assert(use_lang == 'en')
    return v.name_en
  end
end

function M.plot_grammarians(use_lang)

  local csvutils = require("csvutils")
  local grammarians = csvutils.parseCommentHeaderCSV("grammarians.csv")
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
  
  for k, v in pairs(grammarians) do
    local region_parts = csvutils.split(v.region_code, "%+")
    local add_val = 0
    local base_region = v.region_code
    if #region_parts > 1 then
      base_region = region_parts[1]
      add_val = tonumber(region_parts[2])
    else
      region_parts = csvutils.split(v.region_code, "%-")
      if #region_parts > 1 then
        base_region = region_parts[1]
        add_val = - tonumber(region_parts[2])
      end
    end
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
