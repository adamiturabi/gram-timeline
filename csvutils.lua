
local M = {}

-- Helper function to split a string by a delimiter
function M.split(str, sep)
    local t = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(match)
        table.insert(t, match:match("^%s*(.-)%s*$")) -- trim whitespace
    end)
    return t
end


-- Function to parse CSV with a comment header line
function M.parseCommentHeaderCSV(filepath)
    local file = io.open(filepath, "r")
    if not file then
        error("Could not open file: " .. filepath)
    end

    local fields = nil
    local dict = {}

    for line in file:lines() do
        -- Skip empty lines
        if line:match("%S") then
            if not fields then
                -- Remove leading comment characters like '--', '#', or '//' and whitespace
                local cleanHeader = line:gsub("^%s*[%-%#%/]+%s*", "")
                fields = M.split(cleanHeader, ",")
                table.remove(fields,1) -- first column is key
            else
                local values = M.split(line, ",")
                local key = values[1]
                table.remove(values,1)
                local row = {}
                --for field, value in pairs(fields, values) do
                for i = 1, #values do
                    row[fields[i]] = values[i]
                    --print(field, value)
                end
                dict[key] = row
                --table.insert(rows, row)
            end
        end
    end

    file:close()
    return dict
end

return M
-- Example Usage:
-- Assuming 'data.csv' has:
-- --id,name,score
-- 1,Alice,95
-- 2,Bob,88

--local data = parseCommentHeaderCSV("grammarians.csv")
--for key, row in pairs(data) do
--    print(key, row.name_en, row.name_ar)
--end

