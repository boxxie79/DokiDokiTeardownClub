#include "/luascripts/script_ch0.lua"
#include "/luascripts/script_ch1.lua"
#include "/luascripts/script_chdebug.lua"
#include "/definitions/image_definitions.lua"

function init()
	LoadedChapter = 0
	line = 1
	currenttext = "NoTextLoaded"
	speakingcharacter = "Character"
	playing_music = "t1"
	s_name = "Sayori"
  --[[if GetString("DDLC.MCNAME") ~= nil then
		mc_name = GetString("DDLC.MCNAME")s
	    else
		mc_name = "MC"
		SetString("DDLC.MCNAME", mc_name)
	end ]]
	SetString("DDLC.MCNAME", "MC")
	mc_name = GetString("DDLC.MCNAME")
	DebugPrint("Doki Doki Literature Club v0.0.0-alpha")
	character_on_screen = nil
	advancetext()

	in_menu = false

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
	DrawImage("MOD/DDLC/images.rpa/images/" .. background_image .. ".png", UiHeight())
end

function renderCompositeImage(image, alignment)
	UiPush()
	UiResetNavigation()
	local ih, iw = UiGetImageSize("MOD/DDLC/images.rpa/images/" .. image[1])
	if alignment == "center" then
		UiTranslate(UiWidth()/2, 0)
		UiTranslate(-iw/2, 0)
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

--	set up background images
	backgrounds = {}
	backgrounds["residential_day"] = "bg/residential"
	backgrounds["class_day"] = "bg/class"
	backgrounds["corridor"] = "bg/corridor"
	backgrounds["club_day"] = "bg/club"

-- text interpreting

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
		character_on_screen = image_sayori[pose]
	elseif character == "monika" or character == "m" then
		character_on_screen = image_monika[pose]
	elseif character == "natsuki" or character == "n" then
		character_on_screen = image_natsuki[pose]
	elseif character == "yuri" or character == "y" then
		character_on_screen = image_yuri[pose]
	else
		DebugPrint("Unknown character: " .. character)
	end
end

function interpretcommand(input)
	local command = splitcommand(input)
	if command[1] == "show" then
		if command[3] == "zorder" then
			return -- zorder not implemented yet
		else
			DebugPrint(command[1] .. " " .. command[2] .. " " .. command[3])
			local character = command[2]
			showcharacter(command[2] .. " " .. command[3])
		end
		elseif command[1] == "play" then
		playing_music = music[command[3]]
	elseif command[1] == "scene" then
		character_on_screen = nil
		if command[2] == "bg" then
			background_image = backgrounds[command[3]]
		else
			DebugPrint("CG support not implemented")
		end
	elseif command[1] == "hide" then
		character_on_screen = nil
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

if in_menu == false then
	-- run the game

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

	--	play music
	PlayMusicLoop(playing_music)

	--  DRAW THE CHARACTERS BEFORE THE TEXTBOX BUT AFTER THE BACKGROUND

	UiPush()
	UiResetNavigation()
	if character_on_screen ~= nil then
		renderCompositeImage(character_on_screen, "center")
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
		UiTextOutline(73, 0, 60, 1, 0.6)
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
	if UiTextButton("Next") then
		UiSound("MOD/DDLC/audio.rpa/gui/sfx/select.ogg")
		advancetext()
	end
	--	previous (DEBUG) button
	UiTranslate(120, 0)
	if UiTextButton("Previous") then
		advancetext("1")
	end

	UiPop()
	--end

	UiResetNavigation()

	-- MORE DEBUG BUTTONS

	--	Debug HUD

	UiFont("MOD/fonts/riffic.ttf", 50)
	UiTextOutline(50, 0, 50, 1, 0.6)
	--[[UiPush()
	UiTranslate(0, UiHeight()-50)
	if UiTextButton("Clear Console") then
		while i < 50 do
		DebugPrint("")
		i = i + 1
		end
	end
	UiPop() ]]
	if InputDown("ctrl") then
		UiPush()
		UiTranslate(50, 50)
		UiText(background_image .. " " .. playing_music)
		UiPop()
		UiTranslate(50, 100)
		UiText("Line " .. line .. " Chapter " .. LoadedChapter .. " Speaker " .. getspeaker())
		UiTranslate(0, 50)
		UiPush()
		UiFont(fonts["name"], 25)
		UiWordWrap(1800)
		UiText(currenttext)
		UiPop()
		UiTranslate(0,50)
		UiText(splitcommand(currenttext))

		if InputDown("uparrow") then
			advancetext()
		elseif InputDown("downarrow") then
			advancetext("1")
		elseif InputDown("leftarrow") then
			line = 0
			advancetext()
		end
	end

-- END OF GAME UI
elseif in_menu == true then
	-- menu ui

	UiPush()
	UiTranslate(0, UiHeight()/2)
	UiFont("MOD/DDLC/fonts.rpa/gui/font/Aller_Rg.ttf", 50)
	UiText("Menu Placeholder")
	UiPop()

end

if InputPressed("F2") then
	-- toggle menu
	in_menu = not in_menu
end

-- end of draw function
end