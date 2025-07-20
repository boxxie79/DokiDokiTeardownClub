-- thanks copilot you a real one

local function file_to_table(filename)
    local lines = {}
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file: " .. filename)
    end
    for line in file:lines() do
        line = line:gsub("'", "\\'")
        table.insert(lines, line)
    end
    file:close()
    return lines
end
-- Example usage:
-- local my_table = file_to_table("yourfile.txt")
-- for i, v in ipairs(my_table) do print(i, v) end

function RPY_TO_LUA(script)

outputfile = io.open(script .. ".lua","w")
outputfile:write("--[[ converted DDLC script ]]\n" .. script .. " = {\n")

outputfile = io.open(script .. ".lua","a")

local output_table = file_to_table(script .. ".rpy")
for linenumber, linecontent in ipairs(output_table) do
    linecontent = linecontent:match("^%s*(.*)")
    outputfile:write("  ",--[[linenumber,]] "'", linecontent, "',\n")
end

outputfile:write("}\n--[[end of script]]")

outputfile:close()

end

if arg[1] then
    RPY_TO_LUA(arg[1])
end