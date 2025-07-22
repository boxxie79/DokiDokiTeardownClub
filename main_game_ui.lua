#include "/luascripts/script_ch0.lua"
#include "/luascripts/script_ch1.lua"
#include "/luascripts/script_ch2.lua"

#include "/luascripts/script-exclusives-sayori.lua"
#include "/luascripts/script-exclusives-natsuki.lua"
#include "/luascripts/script-exclusives-yuri.lua"

#include "/luascripts/script_contentwarning.lua"

#include "/definitions/image_definitions.lua"
#include "/definitions/cgs.lua"

#include "/definitions/poemwords.lua"

function init()

	DebugUI = true

	if GetBool("savegame.mod.seendisclaimer") == false then
		LoadedChapter = "contentwarning"
	else
	LoadedChapter = 0
	end
	line = 0

	currenttext = "fallback"
	speakingcharacter = "character"
	playing_music = "t1"
	s_name = "Sayori"
	currentlabel = nil

  --[[if GetString("savegame.mod.MCNAME") ~= nil then
		mc_name = GetString("savegame.mod.MCNAME")s
	    else
		mc_name = "MC"
		SetString("savegame.mod.MCNAME", mc_name)
	end ]]
	SetString("savegame.mod.mcname", "MC")
	-- mc_name = GetString("savegame.mod.MCNAME")


	-- poem game
	sayori_point_total = 0
	natsuki_point_total = 0
	yuri_point_total = 0

	sayori_points = 0
	natsuki_points = 0
	yuri_points = 0

	s_poemappeal = {}
	n_poemappeal = {}
	y_poemappeal = {}

	poem_dislike_threshold = 29
	poem_like_threshold = 45

	-- not poem game
	background_image = "../gui/menu_bg.png"
	
	characters_on_screen = {}
	displaywords = {}

	choice_text = {}
	choice_command = {}

	cg_on_screen = {}

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
	paused = false

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
	chapters[2] = script_ch2

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
	music["t7"] = "7" -- Poem Panic!
	music["t8"] = "8" -- Daijoubu!

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
	expressions["poemwinner"] = nil
	expressions["ch1_choice"] = nil

	poemwinner = {}

function PoemGameControl(control)
	returncount = 0
	if control == "start" then
		in_novel = false
		in_poem_game = true
		wordspicked = 0
		displaywords = PickPoemWords()
	elseif control == "end" then
		in_poem_game = false
		in_novel = true
		LoadedChapter = LoadedChapter + 1
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
		paused = not paused
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
	-- affection point_totals
	SetInt("savegame.mod.sayori.point_total", sayori_point_total)
	SetInt("savegame.mod.yuri.point_total", yuri_point_total)
	SetInt("savegame.mod.natsuki.point_total", natsuki_point_total)
	if poemwinner[0] then
		SetString("savegame.mod.poemwinner0", poemwinner[0])
	end

	SetString("savegame.mod.expressions.ch1_choice", expressions["ch1_choice"])

	-- visuals
	SetString("savegame.mod.visuals.scene", background_image)

	DebugPrint("game saved")
end

function LoadGame()
    -- basics
	in_poem_game = false
	in_novel = true
	making_choice = false

	LoadedChapter = GetInt("savegame.mod.chapter")
	line = 0
	-- affection point_totals
	sayori_point_total = GetInt("savegame.mod.sayori.point_total")
	yuri_point_total = GetInt("savegame.mod.yuri.point_total")
	natsuki_point_total = GetInt("savegame.mod.natsuki.point_total")

	if GetString("savegame.mod.poemwinner0") then
		poemwinner[0] = GetString("savegame.mod.poemwinner0")
	end

	expressions["ch1_choice"] = GetString("savegame.mod.expressions.ch1_choice")

	-- visual
	background_image = GetString("savegame.mod.visuals.scene")
	-- trigger textbox update
	repeat
		advancetext()
	until line == GetInt("savegame.mod.line")
end

-- define game functions
function PlayMusicLoop(input)
	if input then
		local musicpath = "MOD/DDLC/audio.rpa/bgm/" .. input .. ".ogg"
		UiSoundLoop(musicpath)
	end
end

function ClickPoemWord(input)
	DebugPrint(input.." click!")
	sayori_point_total = sayori_point_total + poemwords[input][2]
	natsuki_point_total = natsuki_point_total + poemwords[input][3]
	yuri_point_total = yuri_point_total + poemwords[input][4]
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
		if math.max(sayori_point_total, natsuki_point_total, yuri_point_total) == sayori_point_total then
			poemwinner[LoadedChapter] = "sayori"
		elseif math.max(sayori_point_total, natsuki_point_total, yuri_point_total) == natsuki_point_total then
			poemwinner[LoadedChapter] = "natsuki"
		else
			poemwinner[LoadedChapter] = "yuri"
		end
		if sayori_point_total < poem_dislike_threshold then s_poemappeal[LoadedChapter] = -1 end
		if sayori_point_total > poem_like_threshold then s_poemappeal[LoadedChapter] = 1 end
		if natsuki_point_total < poem_dislike_threshold then n_poemappeal[LoadedChapter] = -1 end
		if natsuki_point_total > poem_like_threshold then n_poemappeal[LoadedChapter] = 1 end
		if yuri_point_total < poem_dislike_threshold then y_poemappeal[LoadedChapter] = -1 end
		if yuri_point_total > poem_like_threshold then y_poemappeal[LoadedChapter] = 1 end
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
function tableFind(find, table)
	for i, v in table do
		if v == find then
			return I
		else
			return nil
		end
	end
end

-- text interpreting

function offsettext(offset)
	if offset then
		return chapters[LoadedChapter][line+offset]
	else
		return currenttext
	end
end

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
	elseif string.find(character, "cg") then
		if string.find(character, "exp") then 
			cg_on_screen["exp"] = character
		end
		if string.find(character, "base") then
			cg_on_screen["base"] = character
		end
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
		elseif string.find(command[2], "cg") then
			if string.find(command[2], "exp") then 
				cg_on_screen["exp"] = command[2]
			end
			if string.find(command[2], "base") then
				cg_on_screen["base"] = command[2]
			end
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
			in_cg = false
			background_image = image_bg[command[3]][1]
		else
			in_cg = true
			cg_on_screen["bg"] = command[2]
			background_image = image_cg[cg_on_screen["bg"]]
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
		elseif string.find(command[2], "cg") then
			if command[2] == cg_on_screen["exp"] then
				cg_on_screen["exp"] = nil
			elseif command[2] == cg_on_screen["base"] then
				cg_on_screen["base"] = nil
			else
				DebugPrint("WHAT???")
			end
		else
				DebugPrint("hide command failed??")
		end
	elseif command[1] == "return" then
		scriptreturn()
	elseif command[1] == "label" then
		current_label = string.gsub(command[2], ":", "")
	elseif command[1] == "call" then
		if command[2] == "expression" then
			DebugPrint("Calling from expression "..command[3])
			DebugPrint(expressions["nextscene"])
			for i, v in pairs(chapters["exclusives_"..poemwinner[0]]) do
				if v == "label " .. expressions["nextscene"] .. ":" then
					DebugPrint("calling " .. expressions["nextscene"])
					PreviousChapter = LoadedChapter
					PreviousLine = line
					PreviousLabel = current_label
					current_label = expressions["nextscene"]
					LoadedChapter = "exclusives_"..poemwinner[0]
					line = i
				end
			end
		end
		for i, v in pairs(chapters[LoadedChapter]) do
			if v == "label " .. command[2] .. ":" then
				DebugPrint("calling "..v)
				current_label = command[2]
				line = i
				advancetext()
			end
		end
	elseif command[1] == "stop" and command[2] == "music" then
		playing_music = nil
	elseif command[1] == "menu:" then

		making_choice = true
		choice_text[0] = offsettext(1)

		choice_text[1] = offsettext(2)
		choice_command[1] = offsettext(3)
		if offsettext(4) ~= "" then
		choice_text[2] = offsettext(4)
		choice_command[2] = offsettext(5)
		end
		if offsettext(6) ~= "" then
			choice_text[3] = offsettext(6)
			choice_command[3] = offsettext(7)
		end
		if offsettext(8) ~= "" then
			choice_text[4] = offsettext(8)
			choice_command[4] = offsettext(9)
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
		DebugPrint("editing variable "..command[2])
		if string.find(command[4], "poemwinner") then
			DebugPrint("Hardcoding is bad for you.")
			DebugPrint("Hardcoding chapter 1 next scene anyway...")
			expressions["nextscene"] = poemwinner[LoadedChapter-1] .. "_exclusive_" .. LoadedChapter
		else
			expressions[command[2]] = command[4]
			DebugPrint(command[2].." = "..expressions[command[2]])
		end
	end
end

function scriptreturn()
	if LoadedChapter == 0 then
		PoemGameControl("start")
	elseif type(LoadedChapter) == "string" and string.find(LoadedChapter, "exclusives") then
		LoadedChapter = PreviousChapter
		current_label = PreviousLabel
		line = PreviousLine
	elseif LoadedChapter == 1 then
		if returncount == 0 then
			sharePoems()
		elseif returncount == 1 then
			interpretcommand("call ch1_end")
		elseif returncount == 2 then
			PoemGameControl("start")
		end
	elseif LoadedChapter == "contentwarning" then
		LoadedChapter = 0
		line = 0
		SetBool("savegame.mod.seendisclaimer", true)
		advancetext()
	else
	--  previousposition = {chapter, line}
	DebugPrint("Return is an interesting command.")
	end
	returncount = returncount + 1
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
	if not making_choice then
		advancetext()
	end
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

	if in_cg then
		if cg_on_screen["base"] then
			drawFullscreen(image_cg[cg_on_screen["base"]])
		end
		if cg_on_screen["exp"] then
			drawFullscreen(image_cg[cg_on_screen["exp"]])
		end
	end

	UiPop()

	if making_choice then
		UiPush()
		UiFont(fonts["name"], 50)
		UiTextOutline(0.73, 0.33, 0.60, 1, 0.6)
		UiTranslate(500,500)
		for loop = 1,4 do
			if choice_text[loop] then
				if UiTextButton(striptext(choice_text[loop])) then
					making_choice = false
					interpretcommand(choice_command[loop])
					choice_text = {}
					choice_command = {}
				end
			end
			UiTranslate(0,50)
		end
		UiPop()
	end

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
	if making_choice then
		UiText(striptext(choice_text[0]))
	else
		UiText(displaytext)
	end
	UiPop()

	UiFont(fonts["name"], 50)
	--	Next button
	UiTranslate(TextboxW*1.5-100, TextboxH*1.5-100)
	
	if InputReleased("space") and not paused and not making_choice then
		advancetext()
	end

	UiPop()
	UiPush()
	-- menu buttons
	UiTranslate(550,1040)
	UiFont(fonts["speech"], 30)
	if paused == false and GetBool("savegame.mod.seendisclaimer") then
		if UiTextButton("Settings") then
			paused = true
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

	if paused then
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
	UiText("in_novel=" .. tostring(in_novel) .. " in_poem_game=" .. tostring(in_poem_game), true)
	if in_cg then
		UiText("IN CG "..tostring(background_image).." base="..tostring(cg_on_screen["base"]).." exp="..tostring(cg_on_screen["exp"]), true)
	end
	if making_choice then
		UiText("Making Choice", true)
	end
	UiText('bg = "' .. tostring(background_image) .. '" music = "' .. tostring(playing_music) .. '"', true)
	UiText("line=" .. line .. " chapter=" .. LoadedChapter .. " label=" .. tostring(current_label), true)
	UiText("S = " .. sayori_point_total .. " N = " .. natsuki_point_total .. " Y = " .. yuri_point_total, true)
	if type(LoadedChapter) == "number" and poemwinner[LoadedChapter-1] then
		UiText("poemwinner[" .. LoadedChapter-1 .."] = " .. poemwinner[LoadedChapter-1], true)
	end
	UiFont(fonts["name"], 25)
	UiWordWrap(1800)

	UiText(offsettext(-4), true)
	UiText(offsettext(-3), true)
	UiText(offsettext(-2), true)
	UiText(offsettext(-1), true)

	UiText(currenttext, true)
	UiTranslate(0,25)
	UiFont(fonts["name"], 50)

	if expressions["nextscene"] and not expressions["nextscene"] == " " then
		UiText("nextscene="..expressions["nextscene"], true)
	end

	if InputDown("uparrow") and in_novel and not making_choice then
		advancetext()
	elseif InputPressed("downarrow") and in_novel and not making_choice then
		advancetext("1")
	elseif InputDown("leftarrow") and in_novel and not making_choice then
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
	UiText("S = " .. GetInt("savegame.mod.sayori.point_total") .. " N = " .. GetInt("savegame.mod.natsuki.point_total") .. " Y = " .. GetInt("savegame.mod.yuri.point_total"), true)
	UiText("ch1_choice="..GetString("savegame.mod.expressions.ch1_choice"), true)
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