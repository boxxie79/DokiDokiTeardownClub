outputfile = io.open("sayori_image_definitions.lua", "w")

outputfile:write('image_sayori = {}\n')
outputfile:write('\nimage_sayori["1"] = {"sayori/1l.png", "sayori/1r.png", "sayori/a.png"}\n')

letter = "a"
repeat
    outputfile:write('image_sayori["1' .. letter .. '"] = {"sayori/1l.png", "sayori/1r.png", "sayori/' .. letter .. '.png"}\n')
    letter = string.char(string.byte(letter) + 1)
until string.byte(letter) == 123

letter = "a"
outputfile:write('\nimage_sayori["2"] = {"sayori/1l.png", "sayori/2r.png", "sayori/a.png"}\n')
repeat
    outputfile:write('image_sayori["2' .. letter .. '"] = {"sayori/1l.png", "sayori/2r.png", "sayori/' .. letter .. '.png"}\n')
    letter = string.char(string.byte(letter) + 1)
until string.byte(letter) == 123

letter = "a"
outputfile:write('\nimage_sayori["3"] = {"sayori/2l.png", "sayori/1r.png", "sayori/a.png"}\n')
repeat
    outputfile:write('image_sayori["3' .. letter .. '"] = {"sayori/2l.png", "sayori/1r.png", "sayori/' .. letter .. '.png"}\n')
    letter = string.char(string.byte(letter) + 1)
until string.byte(letter) == 123

letter = "a"
outputfile:write('\nimage_sayori["4"] = {"sayori/2l.png", "sayori/2r.png", "sayori/a.png"}\n')
repeat
    outputfile:write('image_sayori["4' .. letter .. '"] = {"sayori/2l.png", "sayori/2r.png", "sayori/' .. letter .. '.png"}\n')
    letter = string.char(string.byte(letter) + 1)
until string.byte(letter) == 123