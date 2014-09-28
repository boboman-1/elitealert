-----------------------------------------------------------------------------------------------
-- Client Lua Script for EliteAlert
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- EliteAlert Module Definition
-----------------------------------------------------------------------------------------------
local EliteAlert = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function EliteAlert:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function EliteAlert:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- EliteAlert OnLoad
-----------------------------------------------------------------------------------------------
function EliteAlert:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("EliteAlert.xml")
	self.skullSprite = Apollo.LoadSprites("AlertSprite.xml", "AlertSprite_Skull");
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- EliteAlert OnDocLoaded
-----------------------------------------------------------------------------------------------
function EliteAlert:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "EliteAlertForm", nil, self)
		self.alertWindow = Apollo.LoadForm(self.xmlDoc, "AlertForm", nil, self)
		if self.wndMain == nil then
			Print("Error loading EliteAlert")
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
		self.alertWindow:Show(false,true)
		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("ea", "OnEliteAlertOn", self)
		-- self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)
		
		Apollo.RegisterEventHandler("TargetUnitChanged", "OnTargetUnitChanged", self)

		-- Do additional Addon initialization here
	end
end

function EliteAlert:OnTargetUnitChanged(s)
	Print("Target Changed")
	Print(self:getRankDisplayString())
end	

function EliteAlert:getRankDisplayString()
	local target = GameLib.GetPlayerUnit():GetTarget()
	
	if (target ~= nil 
		and target:GetDispositionTo(GameLib.GetPlayerUnit()) ~= Unit.CodeEnumDisposition.Friendly) then
		
		--Rank
		local rank = target:GetRank()
		local rankStr

		-- Not sure what to do with this yet.  
		--Originally for debugging the unit types/strengths/ranks/difficulty whatever the hell they are called...
		if rank == Unit.CodeEnumRank.Elite then
			rankStr = "Elite"
		elseif rank == Unit.CodeEnumRank.Superior then
			rankStr = "Superior"
		elseif rank == Unit.CodeEnumRank.Champion then
			rankStr = "Champion"
		elseif rank == Unit.CodeEnumRank.Standard then
			rankStr = "Standard"
		elseif rank == Unit.CodeEnumRank.Minion then
			rankStr = "Minion"
		elseif rank == Unit.CodeEnumRank.Fodder then
			rankStr = "Fodder"
		else
			-- do something?
		end
		
		--Difficulty
		local difficulty = target:GetDifficulty()
		local difficultyStr
		
		if difficulty == 3 or difficulty == 7 then
			self.alertWindow:Show(true,true)
			Sound.Play(Sound.LootItemSound)
		else
			self.alertWindow:Show(false,true)
		end

		return ("target={Difficulty: " .. (difficulty or "null") .. ",  Rank: " .. (rank  or "null") .."}");
	else
		self.alertWindow:Show(false,true)
	end
end
-----------------------------------------------------------------------------------------------
-- EliteAlert Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/ea"
function EliteAlert:OnEliteAlertOn()
--cal drPlayer = GameLib.GetPlayerUnit()
	--local strName = drPlayer and drPlayer:GetName() or "dude"
		
	--self.wndMain:FindChild("Text"):SetText("Damn," .. strName ..", Lookin good!  Also... Hello, World!")
	--	self.wndMain:Show(true)
	--self.wndMain:Invoke() -- show the window
end

-- on timer
function EliteAlert:OnTimer()

end


-----------------------------------------------------------------------------------------------
-- EliteAlertForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function EliteAlert:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function EliteAlert:OnCancel()
	self.wndMain:Close() -- hide the window
end


-----------------------------------------------------------------------------------------------
-- EliteAlert Instance
-----------------------------------------------------------------------------------------------
local EliteAlertInst = EliteAlert:new()
EliteAlertInst:Init()
