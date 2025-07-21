#include "/luascripts/script_ch0.lua"
#include "/luascripts/script_ch1.lua"

#include "/luascripts/script-exclusives-sayori.lua"
#include "/luascripts/script-exclusives-natsuki.lua"
#include "/luascripts/script-exclusives-yuri.lua"

#include "/luascripts/script_contentwarning.lua"

#include "/definitions/image_definitions.lua"
#include "/definitions/poemwords.lua"

function init()

	DebugUI = true

	if GetBool("savegame.mod.seendisclaimer") == false then
		LoadedChapter = "contentwarning"
		SetBool("savegame.mod.seendisclaimer", true)
	else
	LoadedChapter = 0
	end
	line = 1

	currenttext = "fallback"
	speakingcharacter = "character"
	playing_music = "t1"
	s_name = "Sayori"

  --[[if GetString("savegame.mod.MCNAME") ~= nil then
		mc_name = GetString("savegame.mod.MCNAME")s
	    else
		mc_name = "MC"
		SetString("savegame.mod.MCNAME", mc_name)
	end ]]
	SetString("savegame.mod.mcname", "MC")
	-- mc_name = GetString("savegame.mod.MCNAME")

	sayori_score = 0
	natsuki_score = 0
	yuri_score = 0

	background_image = "../gui/menu_bg.png"
	
	characters_on_screen = {}
	displaywords = {}

	-- pose | position
	-- if pose is nil, don't show 
	sayori_show = {nil, "center"}
	yuri_show = {nil, "center"}
	natsuki_show = {nil, "center"}
	monika_show = {nil, "center"}

	in_novel = true
	in_poem_game = false
	in_menu = false

	making_choice = false
	in_pause = false

	DebugPrint("startup complete")

	advancetext()
end

-- set up tables

-- chapters
	script_chfallback = {"FALLBACKSTRING"}
 
	chapters = {}

	chapters["contentwarning"] = script_contentwarning

	chapters[0] = script_ch0
	chapters[1] = script_ch1
	chapters["exclusives_natsuki"] = script_exclusives_natsuki
	chapters["exclusives_sayori"] = script_exclusives_sayori
	chapters["exclusives_yuri"] = script_exclusives_yuri

-- setup character names
	names = {}
	names["mc"] = GetString("savegame.mod.MCNAME")
 	names["monologue"] = "monologue"
	names["s"] = "Sayori"
 	names["m"] = "Monika"
	names["n"] = "Natsuki"
 	names["y"] = "Yuri"
	names["ny"] = "Nat & Yuri"

--  set up fonts
	fonts = {}
	fonts["speech"] = "MOD/DDLC/fonts.rpa/gui/font/Aller_Rg.ttf"
	fonts["name"] = "MOD/DDLC/fonts.rpa/gui/font/RifficFree-Bold.ttf"
	fonts["mc_handwriting"] = "MOD/DDLC/fonts.rpa/gui/font/Halogen.ttf"

--	set up music
	music = {}
	music["t1"] = "1" -- Doki Doki Literature Club!
	music["t2"] = "2" -- Ohayou Sayori!
	music["t3"] = "3" -- Doki Doki Literature Club! (In Game Version)
	music["t4"] = "4" -- Dreams Of Love And Literature
	music["t5"] = "5"
	music["t6"] = "6"

	-- heavy shitcode
	chr_positions = {}
	chr_positions["sayori"] = 0
	chr_positions["monika"] = 0
	chr_positions["natsuki"] = 0
	chr_positions["yuri"] = 0

	-- expressions used in game
	expressions = {}
	expressions["s_name"] = "Sayori"
	expressions["n_name"] = "Peak"
	expressions["y_name"] = "Y???"
	expressions["m_name"] = "XXXXXX"
	expressions["nextscene"] = ""
	expressions["poemwinner"] = ""

	poemwinner = {}

function PoemGameControl(control)
	if control == "start" then
		in_novel = false
		in_poem_game = true
		wordspicked = 0
		displaywords = PickPoemWords()
	elseif control == "end" then
		in_poem_game = false
		in_novel = true
		line = 0
		advancetext()
	end
end

function tick()
	DrawSprite(LoadSprite("MOD/DDLC/images.rpa/gui/menu_bg.png"), Transform(Vec(0, 1, 0)), 5, 5)
	if InputPressed("F9") then
		PoemGameControl("end")
	elseif InputPressed("F10") then
		PoemGameControl("start")
	elseif InputPressed("F11") then
		-- switch to menu (soon to be default state ok?)
		in_novel = false
		in_poem_game = false
		in_menu = true
	end
	if InputPressed("F8") then
		in_pause = not in_pause
	end
	if InputDown("esc") then
		SetPaused(false)
	end
	if InputPressed("ctrl") then
		DebugUI = not DebugUI
	end
end

function SaveGame()
	-- basics
	SetInt("savegame.mod.chapter", LoadedChapter)
	SetInt("savegame.mod.line", line)
	-- affection scores
	SetInt("savegame.mod.sayori.score", sayori_score)
	SetInt("savegame.mod.yuri.score", yuri_score)
	SetInt("savegame.mod.natsuki.score", natsuki_score)
	if poemwinner[0] then
		SetString("savegame.mod.poemwinner0", poemwinner[0])
	end
	-- visuals
	SetString("savegame.mod.visuals.scene", background_image)

	DebugPrint("game saved")
end

function LoadGame()
    -- basics
	in_poem_game = false
	in_novel = true
	LoadedChapter = GetInt("savegame.mod.chapter")
	line = 0
	-- affection scores
	sayori_score = GetInt("savegame.mod.sayori.score")
	yuri_score = GetInt("savegame.mod.yuri.score")
	natsuki_score = GetInt("savegame.mod.natsuki.score")

	if GetString("savegame.mod.poemwinner0") then
		poemwinner[0] = GetString("savegame.mod.poemwinner0")
	end
	-- visual
	background_image = GetString("savegame.mod.visuals.scene")
	-- trigger textbox update
	repeat
		advancetext()
	until line == GetInt("savegame.mod.line")
end

-- define game functions
function PlayMusicLoop(input)
	local musicpath = "MOD/DDLC/audio.rpa/bgm/" .. input .. ".ogg"
	UiSoundLoop(musicpath)
end

function ClickPoemWord(input)
	DebugPrint(input.." click!")
	sayori_score = sayori_score + poemwords[input][2]
	natsuki_score = natsuki_score + poemwords[input][3]
	yuri_score = yuri_score + poemwords[input][4]
	wordspicked = wordspicked + 1
	if math.max(poemwords[input][2], poemwords[input][3], poemwords[input][4]) == poemwords[input][2] then
		lastwordwinner = "sayori"
	elseif math.max(poemwords[input][2], poemwords[input][3], poemwords[input][4]) == poemwords[input][3] then
		lastwordwinner = "natsuki"
	else
		lastwordwinner = "yuri"
	end
	displaywords = PickPoemWords()
	if wordspicked == 10 then
		if math.max(sayori_score, natsuki_score, yuri_score) == sayori_score then
			poemwinner[LoadedChapter-1] = "sayori"
		elseif math.max(sayori_score, natsuki_score, yuri_score) == natsuki_score then
			poemwinner[LoadedChapter-1] = "natsuki"
		else
			poemwinner[LoadedChapter-1] = "yuri"
		end
		PoemGameControl("end")
	end
end

function PickPoemWords()
	local table = {}
	for loop = 1,10 do
		local word = 0
		repeat
			word = math.floor(math.random(4, 235))
		until PWN[word]
		DebugPrint(word)
		table[loop] = PWN[word]
	end
	return table
end

-- The Holy Grail Of VISUAL Novels
function DrawImage(image, height)
  local w, h = UiGetImageSize(image)
  UiPush()
	UiScale(height / h)
  UiImage(image)
  UiPop()
end

function drawFullscreen(input)
	if input then
		DrawImage("MOD/DDLC/images.rpa/images/" .. input, UiHeight())
	end
end

function RenderCompositeImage(image, alignment)
	UiPush()
	UiResetNavigation()
	local ih, iw = UiGetImageSize("MOD/DDLC/images.rpa/images/" .. image[1])
	if alignment == "center" then
		UiTranslate(UiWidth()/2, 0)
		UiTranslate(-iw/2, 0)
	else
		UiTranslate(-480, 0)
		UiTranslate(alignment, 0)
	end
	local key = 1
	repeat
		DrawImage("MOD/DDLC/images.rpa/images/" .. image[key], UiHeight())
		key = key + 1
	until image[key] == nil
	UiPop()
end

function tableContains(table, key)
  return table[key] ~= nil
end

-- find in table
function findintable(find, table)
	for i, v in table do
		if v == find then
			return I
		else
			return nil
		end
	end
end

-- text interpreting

-- copilot wrote this one
function splitcommand(command)
	local words = {}
	for word in string.gmatch(command, "%S+") do
		table.insert(words, word)
	end
	return words
end

function showcharacter(input)
	local character = splitcommand(input)[1]
	local pose = splitcommand(input)[2]
	DebugPrint(character .. " " .. pose)
	if character == "sayori" or character == "s" then
		sayori_show[1] = image_sayori[pose]
		local character = "sayori"
	elseif character == "monika" or character == "m" then
		monika_show[1] = image_monika[pose]
		local character = "monika"
	elseif character == "natsuki" or character == "n" then
		natsuki_show[1] = image_natsuki[pose]
		local character = "natsuki"
	elseif character == "yuri" or character == "y" then
		yuri_show[1] = image_yuri[pose]
		local character = "yuri"
	elseif character == "bg" then
		DebugPrint("WHAT")
		background_image = image_bg[pose][1]
	else
		DebugPrint("Unknown character: " .. character)
		local character = nil
	end
	if character then
		table.insert(characters_on_screen, character)
	end
end

--[[
$$$$$$\            $$\                                                        $$\      $$$$$$\                                                                  $$\   $$$\ $$$\   
\_$$  _|           $$ |                                                       $$ |    $$  __$$\                                                                 $$ | $$  _| \$$\  
  $$ |  $$$$$$$\ $$$$$$\    $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\   $$$$$$\ $$$$$$\   $$ /  \__| $$$$$$\  $$$$$$\$$$$\  $$$$$$\$$$$\   $$$$$$\  $$$$$$$\   $$$$$$$ |$$  /    \$$\ 
  $$ |  $$  __$$\\_$$  _|  $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\\_$$  _|  $$ |      $$  __$$\ $$  _$$  _$$\ $$  _$$  _$$\  \____$$\ $$  __$$\ $$  __$$ |$$ |      $$ |
  $$ |  $$ |  $$ | $$ |    $$$$$$$$ |$$ |  \__|$$ /  $$ |$$ |  \__|$$$$$$$$ | $$ |    $$ |      $$ /  $$ |$$ / $$ / $$ |$$ / $$ / $$ | $$$$$$$ |$$ |  $$ |$$ /  $$ |$$ |      $$ |
  $$ |  $$ |  $$ | $$ |$$\ $$   ____|$$ |      $$ |  $$ |$$ |      $$   ____| $$ |$$\ $$ |  $$\ $$ |  $$ |$$ | $$ | $$ |$$ | $$ | $$ |$$  __$$ |$$ |  $$ |$$ |  $$ |\$$\     $$  |
$$$$$$\ $$ |  $$ | \$$$$  |\$$$$$$$\ $$ |      $$$$$$$  |$$ |      \$$$$$$$\  \$$$$  |\$$$$$$  |\$$$$$$  |$$ | $$ | $$ |$$ | $$ | $$ |\$$$$$$$ |$$ |  $$ |\$$$$$$$ | \$$$\ $$$  / 
\______|\__|  \__|  \____/  \_______|\__|      $$  ____/ \__|       \_______|  \____/  \______/  \______/ \__| \__| \__|\__| \__| \__| \_______|\__|  \__| \_______|  \___|\___/  
                                               $$ |                                                                                                                               
                                               $$ |                                                                                                                               
                                               \_]]

function interpretcommand(input)
	local command = splitcommand(input)
	if command[1] == "show" then
		if command[3] == "zorder" then
			return -- zorder not implemented yet
		elseif command[3] == "behind" then
			return -- behind not implemented yet
		else
			DebugPrint(command[2] .. " " .. command[3])
			showcharacter(command[2] .. " " .. command[3])
		end
		elseif command[1] == "play" then
		playing_music = music[command[3]]
	elseif command[1] == "scene" then
		characters_on_screen = {}
		sayori_show[1] = nil
		yuri_show[1] = nil
		natsuki_show[1] = nil
		monika_show[1] = nil
		if command[2] == "bg" then
			background_image = image_bg[command[3]][1]
		else
			DebugPrint("CG support not implemented")
		end
	elseif command[1] == "hide" then
		if command[2] == "sayori" then
			sayori_show[1] = nil
			--characters_on_screen[findintable("sayori", characters_on_screen)] = nil
		elseif command[2] == "natsuki" then
			natsuki_show[1] = nil
			--characters_on_screen[findintable("natsuki", characters_on_screen)] = nil
		elseif command[2] == "yuri" then
			yuri_show[1] = nil
			--characters_on_screen[findintable("yuri", characters_on_screen)] = nil
		elseif command[2] == "monika" then
			monika_show[1] = nil
			--characters_on_screen[findintable("monika", characters_on_screen)] = nil
		else
			DebugPrint("hide command failed??")
		end
	elseif command[1] == "return" then
		-- end chapter 0
		if LoadedChapter == 0 then
		LoadedChapter = LoadedChapter + 1
		line = 0
		PoemGameControl("start")
		-- go back to main script from side path
		elseif type(LoadedChapter) == "string" and string.find(LoadedChapter, "exclusives") then
			LoadedChapter = PreviousChapter
			line = PreviousLine
		elseif LoadedChapter == 1 then
			sharePoems()
		elseif LoadedChapter == "contentwarning" then
			LoadedChapter = 0
			line = 0
			advancetext()
		else
		--  previousposition = {chapter, line}
		DebugPrint("Return is an interesting command.")
		return
		end
	elseif command[1] == "call" then
		if command[2] == "expression" then
			DebugPrint("Calling from expression "..command[3])
			DebugPrint(expressions["nextscene"])
			for i, v in pairs(chapters["exclusives_"..poemwinner[0]]) do
				if v == "label " .. expressions["nextscene"] .. ":" then
					DebugPrint("calling " .. expressions["nextscene"])
					PreviousChapter = LoadedChapter
					PreviousLine = line
					LoadedChapter = "exclusives_"..poemwinner[0]
					line = i
				end
			end
		end
		for i, v in pairs(chapters[LoadedChapter]) do
			if v == "label " .. command[2] then
				DebugPrint("calling "..v)
				line = i
				advancetext()
			end
		end
	elseif command[1] == "$" then
		DebugPrint("special command $")
		specialcommand(command)
	else
		if command[1] then
		DebugPrint("Unknown command: " .. command[1])
		end
	end
end

function specialcommand(command)
	if command[2] == "renpy.quit()" then
		menu()
	elseif command[3] == "=" then 
		DebugPrint("Ren'Py wants to change a variable.")
		DebugPrint("variable is "..command[2])
		if string.find(command[4], "poemwinner") then
			DebugPrint("Hardcoding is bad for you.")
			DebugPrint("Hardcoding chapter 1 next scene anyway...")
			expressions["nextscene"] = poemwinner[0] .. "_exclusive_1"
		end
	end
end

-- Copilot wrote basically all this one so :)
function getspeaker()
	if currenttext then
		if string.sub(currenttext, 1, 1) == '"' then
			return 'monologue'
		end
		local first_space = string.find(currenttext, " ")
		if first_space then
			return string.sub(currenttext, 1, first_space - 1)
		else
			return currenttext
		end
	end
end


-- Strip text for displaying to textbox
function striptext(texttostrip)
	--  replace [player] with mc name
	--  texttostrip = string.sub(texttostrip, "[player]", mc_name)
	local first_quote = string.find(texttostrip, '"')
	local last_quote = string.find(texttostrip, '"', first_quote + 1)
	if first_quote and last_quote then
		local workingtext = string.sub(texttostrip, first_quote + 1, last_quote - 1)
		if string.find(workingtext, "[player]", 1, true) then
			workingtext = string.gsub(workingtext, "%[player%]", GetString("savegame.mod.mcname"))
		end
--[[	if string.find(workingtext, "{i}") and string.find(workingtext, "{/i}") then
			local italicstart = string.find(workingtext, "{i}")
			local italicend = string.find(workingtext, "{/i}")
			workingtext = string.sub(workingtext, italicstart+3, italicend-4)
		end]]
		return workingtext
	end
	return texttostrip
end

function advancetext(argument)
  if argument == "1" then
    line = line - 1
  else
    line = line + 1
  end
  currenttext = chapters[LoadedChapter][line]--chapters["0"][line]
  local splittext = splitcommand(currenttext)
  if names[getspeaker()] ~= nil then
    speakingcharacter = names[getspeaker()]
	if not string.find(splittext[1], '"') and not string.find (splittext[2], '"') then
		showcharacter(splittext[1] .. " " .. splittext[2])
		displaytext = '"' .. striptext(currenttext) .. '"'
	elseif names[getspeaker()] == "monologue" then
		displaytext = striptext(currenttext)
	else
		displaytext = '"' .. striptext(currenttext) .. '"'
	end
  else 
	interpretcommand(currenttext)
	advancetext()
  end
end

--[[    ** **       *******                         **                **                 
/**    /**/**      /**////**                       /**               //            ***** 
/**    /**/**      /**   /**   *****  *******      /**  *****  ****** ** *******  **///**
/**    /**/**      /*******   **///**//**///**  ****** **///**//**//*/**//**///**/**  /**
/**    /**/**      /**///**  /******* /**  /** **///**/******* /** / /** /**  /**//******
/**    /**/**      /**  //** /**////  /**  /**/**  /**/**////  /**   /** /**  /** /////**
//******* /**      /**   //**//****** ***  /**//******//******/***   /** ***  /**  ***** 
 ///////  //       //     //  ////// ///   //  //////  ////// ///    // ///   //  ///]]

function draw()

--mark top corner
UiPush()
--	define center
UiCenterH = UiHeight()/2
UiCenterW = UiWidth()/2
--	draw background
drawFullscreen(background_image)
if not InputDown("shift") then
UiMakeInteractive()
end


if in_novel == true then
	-- run the game
	--	play music
	PlayMusicLoop(playing_music)

	--  DRAW THE CHARACTERS BEFORE THE TEXTBOX BUT AFTER THE BACKGROUND

	UiPush()
	UiResetNavigation()

	if sayori_show[1] then
		RenderCompositeImage(sayori_show[1], 100)
	end
	if natsuki_show[1] then
		RenderCompositeImage(natsuki_show[1], 600)
	end
	if yuri_show[1] then
		RenderCompositeImage(yuri_show[1], 1100)
	end
	if monika_show[1] then
		RenderCompositeImage(monika_show[1], 1600)
	end

	UiPop()

	--	Textbox
	local TextboxW, TextboxH = UiGetImageSize("MOD/DDLC/images.rpa/gui/textbox.png")
	local nameboxW, nameboxH = UiGetImageSize("MOD/DDLC/images.rpa/gui/namebox.png")
	UiTranslate(UiCenterW-(TextboxW*1.5)/2,--[[Align to bottom]] UiHeight()-TextboxH*1.5-20)
	DrawImage("MOD/DDLC/images.rpa/gui/textbox.png", TextboxH*1.5)

	if speakingcharacter == "monologue" or speakingcharacter == nil then
		-- don't do anything
	else
		UiPush()
		UiTranslate(50, -nameboxH*1.5)
		DrawImage("MOD/DDLC/images.rpa/gui/namebox.png", nameboxH*1.5)
		UiPop()
		-- draw character name
		UiFont(fonts["name"], 40)
		UiPush()
		UiTranslate(168, -20)
		local textW, textH = UiText(speakingcharacter, false, 0)
		UiTranslate(-textW/2, 0)
		UiTextAlignment("middle center")
		UiTextOutline(0.73, 0.33, 0.60, 1, 0.6)
		UiText(speakingcharacter)
		UiPop()
	end



	--	draw character speech
	UiPush()
  	UiTranslate(50, 80)
	UiFont(fonts["speech"], 40)
	UiWordWrap(TextboxW*1.5-100)
	UiTextOutline(0, 0, 0, 0.8, 0.4)
	UiText(displaytext)
	UiPop()

	UiFont(fonts["name"], 50)
	--	Next button
	UiTranslate(TextboxW*1.5-100, TextboxH*1.5-100)
	
	if InputReleased("space") and not in_pause and not making_choice then
		advancetext()
	end

	UiPop()
	UiPush()
	-- menu buttons
	UiTranslate(550,1040)
	UiFont(fonts["speech"], 30)
	if in_pause == false then
		if UiTextButton("Settings") then
			in_pause = true
		end
		UiTranslate(150)
		if UiTextButton("Save") then
			SaveGame()
		end
		UiTranslate(100)
		if UiTextButton("Load") then
			LoadGame()
		end
	end
	UiPop()
	--end

	if in_pause then
		UiPush()
		drawFullscreen("../gui/overlay/game_menu.png")
		UiResetNavigation()
		UiFont(fonts["name"], 50)
		UiTextOutline(0.73, 0.33, 0.60, 1, 0.6)
		UiTranslate(50, 100)
		UiText("Paused")
		UiPop()
	end

	UiResetNavigation()

	-- MORE DEBUG BUTTONS

	--	Debug HUD

	UiFont("MOD/fonts/riffic.ttf", 50)
	UiTextOutline(0.73, 0.33, 0.60, 1, 0.6)
	--[[UiPush()
	UiTranslate(0, UiHeight()-50)
	if UiTextButton("Clear Console") then
		while i < 50 do
		DebugPrint("")
		i = i + 1
		end
	end
	UiPop() ]]-- END OF GAME UI
elseif in_poem_game == true then
	-- poem game ui
	UiPush()

	PlayMusicLoop(music["t4"]) -- dreams of love and literature

	background_image = "bg/notebook.png"
	UiFont(fonts["mc_handwriting"], 50)
	UiTextOutline(0,0,0,1,0.5)

	UiPush()
	UiTranslate(1200,128)
	if UiTextButton(wordspicked .. "/10") then
		DebugPrint("Rerolling")
		displaywords = PickPoemWords()
	end
	UiPop()

	UiTranslate(720, 269)
	-- poemgame menu
	for loop = 1,5 do
		if UiTextButton(displaywords[loop]) then
			ClickPoemWord(displaywords[loop])
		end
		UiTranslate(265, 0)
		if UiTextButton(displaywords[loop+5]) then
			ClickPoemWord(displaywords[loop+5])
		end
		UiTranslate(-265,137)
	end
	UiPop()

	-- draw stickers
	UiPush()
	
	UiTranslate(60,760)
	if lastwordwinner == "sayori" then
	DrawImage("MOD/DDLC/images.rpa/gui/poemgame/s_sticker_2.png", 200)
	else 
	DrawImage("MOD/DDLC/images.rpa/gui/poemgame/s_sticker_1.png", 200)
	end
	UiTranslate(175, 0)
	if lastwordwinner == "natsuki" then
	DrawImage("MOD/DDLC/images.rpa/gui/poemgame/n_sticker_2.png", 200)
	else 
	DrawImage("MOD/DDLC/images.rpa/gui/poemgame/n_sticker_1.png", 200)
	end
	UiTranslate(175, 0)
	if lastwordwinner == "yuri" then
	DrawImage("MOD/DDLC/images.rpa/gui/poemgame/y_sticker_2.png", 200)
	else 
	DrawImage("MOD/DDLC/images.rpa/gui/poemgame/y_sticker_1.png", 200)
	end
	
	UiPop()
	-- debug font
	--UiFont("MOD/fonts/riffic.ttf", 50)
	UiTextOutline(0, 0.5, 1, 1, 0.6)
elseif in_menu == true then
	--[[menu ui
	
	--background_image = "../gui/menu_bg.png"
	UiFont("MOD/fonts/riffic.ttf", 50)
	UiTextOutline(1, 0, 0.5, 1, 0.6)
	UiPush()
	UiTranslate(0, UiHeight()/2)
	UiText("Menu Placeholder", true)
	if UiTextButton("New Game") then
		in_menu = false
		in_novel = true
		advancetext()
	end
	UiPop()]]
end
-- DEBUGGING UI

if DebugUI then
	UiResetNavigation()
	UiFont(fonts["name"], 50)
	UiPush()
	UiTranslate(50, 50)
	UiText("in_novel=" .. tostring(in_novel) .. " in_poem_game=" .. tostring(in_poem_game) .. " in_menu=" .. tostring(in_menu), true)
	UiText('bg = "' .. background_image .. '" music = "' .. playing_music .. '"', true)
	if getspeaker() then
	UiText("Line " .. line .. " Chapter " .. LoadedChapter .. " Speaker " .. getspeaker(), true)
	else
	UiText("Line " .. line .. " Chapter " .. LoadedChapter, true)
	end
	UiText("S = " .. sayori_score .. " N = " .. natsuki_score .. " Y = " .. yuri_score, true)
	if type(LoadedChapter) == "number" and poemwinner[LoadedChapter-1] then
		UiText("poemwinner[" .. LoadedChapter-1 .."] = " .. poemwinner[LoadedChapter-1], true)
	end
	UiFont(fonts["name"], 25)
	UiWordWrap(1800)

	UiText(chapters[LoadedChapter][line-4], true)
	UiText(chapters[LoadedChapter][line-3], true)
	UiText(chapters[LoadedChapter][line-2], true)
	UiText(chapters[LoadedChapter][line-1], true)

	UiText(currenttext, true)
	UiTranslate(0,25)
	UiFont(fonts["name"], 50)

	if expressions["nextscene"] and not expressions["nextscene"] == " " then
		UiText("nextscene="..expressions["nextscene"], true)
	end

	if InputDown("uparrow") and in_novel then
		advancetext()
	elseif InputPressed("downarrow") and in_novel then
		advancetext("1")
	elseif InputDown("leftarrow") and in_novel then
		line = 0
		advancetext()
	end
	UiPop()
	-- print savedata
	UiPush()
	UiResetNavigation()
	UiTranslate(UiWidth()-500, 50)
	UiText("Save Slot 1", true)
	UiText("line " .. GetInt("savegame.mod.line") .. " chapter " .. GetInt("savegame.mod.chapter"), true)
	UiText("S = " .. GetInt("savegame.mod.sayori.score") .. " N = " .. GetInt("savegame.mod.natsuki.score") .. " Y = " .. GetInt("savegame.mod.yuri.score"), true)
	if GetString("savegame.mod.poemwinner0") then
		UiText(GetString("savegame.mod.poemwinner0"), true)
	end
	if UiTextButton("Save") then
		SaveGame()
	end
	UiTranslate(100, 0)
	if UiTextButton("Load") then
		LoadGame()
	end
	UiTranslate(0, 40)
	if UiTextButton("First run") then
		SetBool("savegame.mod.seendisclaimer", false)
		LoadedChapter = "contentwarning"
		line = 0 
		init()
	end
	UiPop()
	local displaymousex, displaymousey = 0
	mousex, mousey = UiGetMousePos()
	if mousey > 650 and mousex > 300 and mousex < 1630 and in_novel then
		displaymousey = mousey - ( mousey - 650 )
	elseif mousey > 870 then
		displaymousey = mousey - ( mousey - 870 )
	else
		displaymousey = mousey
	end
	if mousex > 1800 then
		displaymousex = mousex - ( mousex - 1800 )
	elseif mousex < 100 then
		displaymousex = mousex + 100-mousex
	else
		displaymousex = mousex
	end
	UiTranslate(displaymousex-50, displaymousey+100)
	UiText("X"..math.floor(mousex).. "\nY" .. math.floor(mousey))
else
	DebugPrint("")
end

-- end of draw function
end