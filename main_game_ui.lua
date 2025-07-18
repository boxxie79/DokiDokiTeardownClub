#include "/luascripts/script_ch0.lua"
#include "/luascripts/script_ch1.lua"
#include "/luascripts/script_chdebug.lua"
#include "/definitions/image_definitions2.lua"

function init()
	LoadedChapter = 0
	line = 1

	SetInt("DDLC.chapter", LoadedChapter)
	SetInt("DDLC.line", line)

	currenttext = "fallback"
	speakingcharacter = "character"
	playing_music = "t1"
	s_name = "Sayori"

  --[[if GetString("DDLC.MCNAME") ~= nil then
		mc_name = GetString("DDLC.MCNAME")s
	    else
		mc_name = "MC"
		SetString("DDLC.MCNAME", mc_name)
	end ]]
	SetString("DDLC.MCNAME", "MC")
	-- mc_name = GetString("DDLC.MCNAME")

	sayori_score = 0
	natsuki_score = 0
	yuri_score = 0

	character_on_screen = nil

	-- on screen | pose | position 
	sayori_show = {false, "1", "center"}
	yuri_show = {false, "1", "center"}
	natsuki_show = {false, "1", "center"}
	monika_show = {false, "1", "center"}

	in_novel = true
	in_poem_game = false
	in_menu = false

	DebugPrint("startup complete")

	advancetext()

end

	-- only used for Teardown pause background
function tick()
	DrawSprite(LoadSprite("MOD/DDLC/images.rpa/gui/menu_bg.png"), Transform(Vec(0, 1, 0)), 5, 5)
end

-- define game functions
function PlayMusicLoop(input)
	local musicpath = "MOD/DDLC/audio.rpa/bgm/" .. input .. ".ogg"
	UiSoundLoop(musicpath)
end

-- The Holy Grail Of VISUAL Novels
function DrawImage(image, height)
  local w, h = UiGetImageSize(image)
  UiPush()
	UiScale(height / h)
  UiImage(image)
  UiPop()
end

function drawbackground(input)
	DrawImage("MOD/DDLC/images.rpa/images/" .. background_image, UiHeight())
end

function renderCompositeImage(image, alignment)
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

-- setup chapter table
	script_chfallback = {"FALLBACKSTRING"}
 
	chapters = {}

	chapters["fallback"] = script_chfallback
	chapters["debug"] = script_chdebug
	chapters[0] = script_ch0
	chapters[1] = script_ch1

-- setup character names
	names = {}
	names["mc"] = GetString("DDLC.MCNAME")
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

--	set up music
	music = {}
	music["t1"] = "1" -- Doki Doki Literature Club!
	music["t2"] = "2" -- Ohayou Sayori!
	music["t3"] = "3" -- Doki Doki Literature Club! (In Game Version)

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
	DebugPrint("showcharacter() " .. character .. " " .. pose)
	if character == "sayori" or character == "s" then
		sayori_show[1] = true
		sayori_show[2] = image_sayori[pose]
	elseif character == "monika" or character == "m" then
		monika_show[1] = true
		monika_show[2] = image_monika[pose]
	elseif character == "natsuki" or character == "n" then
		natsuki_show[1] = true
		natsuki_show[2] = image_natsuki[pose]
	elseif character == "yuri" or character == "y" then
		yuri_show[1] = true
		yuri_show[2] = image_yuri[pose]
	else
		DebugPrint("Unknown character: " .. character)
	end
end

function interpretcommand(input)
	local command = splitcommand(input)
	if command[1] == "show" then
		if command[3] == "zorder" then
			return -- zorder not implemented yet
		elseif command[3] == "behind" then
			return -- behind not implemented yet
		else
			DebugPrint("interpretcommand() " .. command[1] .. " " .. command[2] .. " " .. command[3])
			local character = command[2]
			showcharacter(command[2] .. " " .. command[3])
		end
		elseif command[1] == "play" then
		playing_music = music[command[3]]
	elseif command[1] == "scene" then
		character_on_screen = nil
		sayori_show[1] = false
		yuri_show[1] = false
		natsuki_show[1] = false
		monika_show[1] = false
		if command[2] == "bg" then
			background_image = image_bg[command[3]][1]
		else
			DebugPrint("CG support not implemented")
		end
	elseif command[1] == "hide" then
		if command[2] == "sayori" then
			sayori_show[1] = false
		elseif command[2] == "natsuki" then
			natsuki_show[1] = false
		elseif command[2] == "yuri" then
			yuri_show[1] = false
		elseif command[2] == "monika" then
			monika_show[1] = false
		else
			DebugPrint("hide command failed??")
		end
	elseif command[1] == "return" then
		LoadedChapter = LoadedChapter + 1
		line = 0
	else
		if command[1] then
		DebugPrint("Unknown command: " .. command[1])
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

function striptext(texttostrip)
	--  replace [player] with mc name
	--  texttostrip = string.sub(texttostrip, "[player]", mc_name)
	local first_quote = string.find(texttostrip, '"')
	local last_quote = string.find(texttostrip, '"', first_quote + 1)
	if first_quote and last_quote then
		return string.sub(texttostrip, first_quote + 1, last_quote - 1)
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
drawbackground(background_image)
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
		renderCompositeImage(sayori_show[2], 320)
	end
	if monika_show[1] then
		renderCompositeImage(monika_show[2], 1400)
	end
	if natsuki_show[1] then
		renderCompositeImage(natsuki_show[2], 960)
	end
	if yuri_show[1] then
		renderCompositeImage(yuri_show[2], 640)
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
	if --[[UiTextButton("Next")]]InputPressed("Space") then
		UiSound("MOD/DDLC/audio.rpa/gui/sfx/select.ogg")
		advancetext()
	end

	UiPop()
	--end

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

	background_image = backgrounds["notebook"]

	-- debug font
	UiFont("MOD/fonts/riffic.ttf", 50)
	UiTextOutline(0, 0.5, 1, 1, 0.6)
elseif in_menu == true then
	-- menu ui

	UiPush()
	UiTranslate(0, UiHeight()/2)
	UiFont("MOD/DDLC/fonts.rpa/gui/font/Aller_Rg.ttf", 50)
	UiText("Menu Placeholder")
	UiPop()

end

-- DEBUGGING UI

if not InputDown("ctrl") then
	UiResetNavigation()
	UiFont("MOD/fonts/riffic.ttf", 50)
	UiTranslate(50, 50)
	UiText("in_novel = " .. tostring(in_novel) .. " in_poem_game = " .. tostring(in_poem_game))
	UiTranslate(0, 50)
	UiText('bg = "' .. background_image .. '" music = "' .. playing_music .. '"')
	UiTranslate(0, 50)
	UiText("Line " .. line .. " Chapter " .. LoadedChapter .. " Speaker " .. getspeaker())
	UiTranslate(0, 25)
	UiPush()
	UiFont(fonts["name"], 25)
	UiWordWrap(1800)
	UiText(currenttext)
	UiPop()
	UiTranslate(0, 50)
	UiText("S = " .. sayori_score .. " N = " .. natsuki_score .. " Y = " .. yuri_score)
	if InputDown("uparrow") then
		advancetext()
	elseif InputPressed("downarrow") then
		advancetext("1")
	elseif InputDown("leftarrow") then
		line = 0
		advancetext()
	end

	-- print savedata
	UiResetNavigation()
	UiTranslate(UiWidth()-500, 50)
	UiText("Saved Data", true)
	UiText("line " .. GetInt("DDLC.line") .. " chapter " .. GetInt("DDLC.chapter"), true)
	UiText("S = " .. GetInt("DDLC.sayori_score") .. " N = " .. GetInt("DDLC.natsuki_score") .. " Y = " .. GetInt("DDLC.yuri_score"))
else
	DebugPrint("")
end

-- end of draw function
end

function tick()
	-- this really should be done in the tick function
	if InputPressed("F9") then
		-- switch to game
		in_poem_game = false
		in_novel = true
	elseif InputPressed("F10") then
		-- switch to poem game
		in_novel = false
		in_poem_game = true
	end
end