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

outputfile = io.open(script..".lua","w")
outputfile:write("--[[ converted DDLC file ]]\n" .. script .. " = {}\n PWN = {}\n")

outputfile = io.open(script .. ".lua","a")

local output_table = file_to_table(script .. ".txt")
for linenumber, linecontent in ipairs(output_table) do
    linecontent = linecontent:match("^%s*(.*)")
    local first_word = linecontent:match("([^,]+)")
    if first_word then
        string.gsub(linecontent, first_word, '"' .. first_word .. '"')
        if not linecontent:find("#") then
            linecontent = string.gsub(linecontent, first_word, "")
            linecontent = string.gsub(linecontent, "[\n\r]", "")
            outputfile:write('\npoemwords["' .. first_word .. '"] = {"' .. first_word .. '"' .. linecontent .. '}')
        end
    end
end

local output_table = file_to_table(script .. ".txt")
for linenumber, linecontent in ipairs(output_table) do
    linecontent = linecontent:match("^%s*(.*)")
    local first_word = linecontent:match("([^,]+)")
    if first_word then
        string.gsub(linecontent, first_word, '"' .. first_word .. '"')
        if not linecontent:find("#") then
            linecontent = string.gsub(linecontent, first_word, "")
            linecontent = string.gsub(linecontent, "[\n\r]", "")
            outputfile:write('\nPWN[' .. linenumber .. '] = "' .. first_word .. '"')
        end
    end
end


outputfile:write("\n--[[end of script]]")

outputfile:close()

end

if arg[1] then
    RPY_TO_LUA(arg[1])
else
    print("No file selected!")
end