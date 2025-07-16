#include "/luascripts/script_ch0.lua"

function init()
	LoadedChapter = "0"
	line = 1
	currenttext = "NoTextLoaded"
	speakingcharacter = "Character"
	s_name = "Sayori"
  --[[if GetString("DDLC.MCNAME") ~= nil then
		mc_name = GetString("DDLC.MCNAME")s
	    else
		mc_name = "MC"
		SetString("DDLC.MCNAME", mc_name)
	end ]]
	SetString("DDLC.MCNAME", "MC")
	mc_name = GetString("DDLC.MCNAME")
	DebugPrint("Good Morning Chat!")
	DebugPrint("Doki Doki Literature Club v0.0.0-alpha")
	background_image = "bg/residential"
	character_on_screen = image_sayori_1
end

-- define game functions
function playmusic(music)
	local musicpath = "MOD/DDLC/audio.rpa/bgm/" .. music .. ".ogg"
	UiSound(musicpath)
end
-- The Holy Grail Of VISUAL Novels
function DrawImage(image, height)
  local w, h = UiGetImageSize(image)
  UiPush()
	UiScale(height / h)
  UiImage(image)
  UiPop()
end
function drawbackground(background_name)
	DrawImage("MOD/DDLC/images.rpa/images/" .. background_name .. ".png", UiHeight())
end
function renderCompositeImage(image, alignment)
	UiPush()
	UiResetNavigation()
	local ih, iw = UiGetImageSize("MOD/DDLC/images.rpa/images/" .. image[1])
	if alignment == "center" then
		UiTranslate(UiWidth()/2-iw/2)
	end
	local key = 1
	repeat
		DrawImage("MOD/DDLC/images.rpa/images/" .. image[key], UiHeight())
		key = key + 1
	until key == 4
	UiPop()
end

function tableContains(table, key)
  return table[key] ~= nil
end

-- image rendering commands over
-- script loading next

-- setup chapter table
  script_chfallback = {"FALLBACKSTRING"}
 
  chapters = {}

  chapters["fallback"] = "luascripts/script_chfallback.lua"
  chapters["debug"] = "luascripts/script_chdebug.lua"
  chapters["0"] = script_ch0
  chapters["1"] = "luascripts/script_ch1.lua"

-- setup character names
  names = {}
  names["s"] = "Sayori"
  names["mc"] = GetString("DDLC.MCNAME")
  names["monologue"] = "Internal Monologue"

--[[ function LoadChapter(chapterargument)
	if chapters[chapterargument] then
		DebugPrint("loading chapter " .. chapterargument)
		-- loadfile("" .. chapters[chapterargument])
		LoadedChapter = chapterargument
		line = 1
		currenttext = chapters[LoadedChapter][line]
	else
		DebugPrint("Chapter " .. chapterargument .. " not found.")
		LoadedChapter = "fallback"
	end
end ]]

-- text interpreting

function splitcommand(command)
	local words = {}
	for word in string.gmatch(command, "%S+") do
		table.insert(words, word)
	end
	return words
end

function interpretcommand()
	local command = splitcommand(currenttext)
  local key = 1
	local words = {}
	repeat until command[key] == nil
	if string.find(currenttext, "show") then
		DebugPrint("show")
		local words = splitcommand(currenttext)
		for i, word in ipairs(words) do
			if word ~= "show" then
				DebugPrint(word)

				break
			end
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
	DebugPrint(texttostrip)
	--  replace [player] with mc name
	--  texttostrip = string.sub(texttostrip, "[player]", mc_name)
	local first_quote = string.find(texttostrip, '"')
	local last_quote = string.find(texttostrip, '"', first_quote + 1)
	if first_quote and last_quote then
		return string.sub(texttostrip, first_quote + 1, last_quote - 1)
	end
	return texttostrip
end

--[[
function oldadvancetext(arg)
	if arg == "1" then
		line = line - 1
	else
		line = line + 1
	end
	if getspeaker() == "s" then
		displaytext = '"' .. striptext(currenttext) .. '"'
		speakingcharacter = s_name
	elseif getspeaker() == "mc" then
		displaytext = '"' .. striptext(currenttext) .. '"'
		speakingcharacter = GetString("DDLC.MCNAME")
	elseif getspeaker() == "monologue" then
		displaytext = striptext(currenttext)
		speakingcharacter = "internal monologue"
	else
		speakingcharacter = nil
		interpretcommand()
		DebugPrint(splitcommand(currenttext))
		advancetext()
	end
end ]]

function advancetext(arg)
  if arg == "1" then
    line = line - 1
  else
    line = line + 1
  end
  currenttext = script_ch0[line]--chapters["0"][line]
  if getspeaker() then
    speakingcharacter = names[getspeaker()]
  end
end

function tick()
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

	UiMakeInteractive()
	UiFont("MOD/fonts/riffic.ttf", 50)

--  DRAW THE CHARACTERS BEFORE THE TEXTBOX BUT AFTER THE BACKGROUND

--	renderCompositeImage(character_on_screen, "center")

--	Textbox
	local TextboxW, TextboxH = UiGetImageSize("MOD/DDLC/images.rpa/gui/textbox.png")
	UiTranslate(UiCenterW-(TextboxW*1.5)/2,--[[Align to bottom]] UiHeight()-TextboxH*1.5)
  DrawImage("MOD/DDLC/images.rpa/gui/textbox.png", TextboxH*1.5)

--  draw speaking character name
	UiPush()
	UiTranslate(10, -30)
  UiTextAlignment("middle")
  UiTextOutline(50, 0, 50, 1, 0.6)
	UiText(speakingcharacter)
	UiPop()

--	draw character speech
	UiTranslate(25, 60)
	UiFont("MOD/fonts/aller.ttf", 50)
  UiPush()
  UiWordWrap(TextboxW*1.5-30)
  UiTextOutline(0, 0, 0, 0.8, 0.4)
	UiText(currenttext)
  UiPop()

	UiFont("MOD/fonts/riffic.ttf", 50)
--	Next button
	UiTranslate(TextboxW*1.5-100, TextboxH*1.5-100)
	if UiTextButton("Next") then
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
--[[UiPush()
	UiTranslate(0, UiHeight()-50)
	if UiTextButton("Clear Console") then
		while i < 50 do
		DebugPrint("")
		i = i + 1
		end
	end
	UiPop() ]]
	UiPush()
	UiTranslate(50, 50)
	UiText("Load Chapter")
	UiTranslate(300, 0)
	if UiTextButton("D") then
		LoadChapter("debug")
	end
	UiTranslate(50, 0)
	if UiTextButton("f") then
		LoadChapter("fallback")
	end
	UiTranslate(50, 0)
	if UiTextButton("0") then
		LoadChapter("0")
	end
	UiTranslate(50, 0)
	if UiTextButton("1") then
		LoadChapter("1")
	end
	UiPop()
	UiTranslate(50, 100)
	local mousex, mousey = UiGetMousePos()
	UiText("Line " .. line .. " Chapter " .. LoadedChapter)-- .. " Speaker " .. getspeaker())
	UiTranslate(0, 50)
	UiText(currenttext)
	UiTranslate(0,50)
	if UiTextButton("play music") then
		playmusic("2")
	end
  UiTranslate(0,50)
	UiText(splitcommand(currenttext))
end

--[[  **           *****          **   **  **                          
     /**          /**//          //   /** //                           
     /**  *****  ******* *******  ** ********  ******  *******   ******
  ****** **///**///**/**//**///**/**///**//** **////**//**///** **//// 
 **///**/*******  /**/** /**  /**/**  /** /**/**   /** /**  /**//***** 
/**  /**/**////   /**/** /**  /**/**  /** /**/**   /** /**  /** /////**
//******//******  /**/** ***  /**/**  //**/**//******  ***  /** ****** 
 //////  //////   // // ///   // //    // //  //////  ///   // //////
]]

-- images sayori
image_sayori_1 = {"sayori/1l.png", "sayori/1r.png", "sayori/a.png"}


image_sayori_4p = {"sayori/2l.png", "sayori/2r.png", "sayori/p.png"}

image_sayori = {image_sayori_1}