frame = 0

function init()
	DebugPrint("Hello World")
end

function tick()
	frame = frame + 1
	DebugPrint(frame)
end
