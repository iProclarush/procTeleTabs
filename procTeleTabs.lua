print("################################")
print("# Starting Script ProcTeleTabs #")
print("################################")

local API = require("api")
local Utils = require("Utils")

local startTime = os.time()
local startXp = API.GetSkillXP("MAGIC")
local fetching = false
local firstLaunch = true
local starting = 0

local function WriteLog(inputLog)
    local time = os.date('%Y-%m-%d %H:%M:%S')
    print(time .. ": " .. inputLog)
end

local function RoundNumber(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

local function FormatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

-- Format script elapsed time to [hh:mm:ss]
local function FormatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function ProgressBarPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then return 100 end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end


local function InitGUI()
    os.execute("cls")

    guiBackPlate = API.CreateIG_answer();
    guiBackPlate.box_name = "back";
    guiBackPlate.box_start = FFPOINT.new(0, 0, 0)
    guiBackPlate.box_size = FFPOINT.new(530, 45, 0)
    guiBackPlate.colour = ImColor.new(15, 13, 18, 255)
    guiBackPlate.string_value = ""

    guiListBox = API.CreateIG_answer()
    guiListBox.box_name = "|  "
    guiListBox.box_start = FFPOINT.new(1,4,0)
    guiListBox.stringsArr = {"Varrock","Lumbridge","Falador" , "Camelot", "Ardougne", "Watchtower", "House"}
     
    progressBar = API.CreateIG_answer()
    progressBar.box_start = FFPOINT.new(120, 4, 0)
    progressBar.box_name = "ProgressBar"
    progressBar.colour = ImColor.new(4, 17, 196);
    progressBar.string_value = "Magic XP"

    starting = API.InvStackSize(1762)
    API.Write_ScripCuRunning0("procTeleTabs")
end

local function TeleTabInterfaceSelection()

    if(guiListBox.string_value == "Varrock") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,25,API.OFF_ACT_GeneralInterface_route)
    end

    if(guiListBox.string_value == "Lumbridge") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,29,API.OFF_ACT_GeneralInterface_route)
    end

    if(guiListBox.string_value == "Camelot") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,37,API.OFF_ACT_GeneralInterface_route)
    end

    if(guiListBox.string_value == "Ardougne") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,41,API.OFF_ACT_GeneralInterface_route)
    end

    if(guiListBox.string_value == "Watchtower") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,45,API.OFF_ACT_GeneralInterface_route)
    end

    if(guiListBox.string_value == "Falador") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,33,API.OFF_ACT_GeneralInterface_route)
    end

    if(guiListBox.string_value == "House") then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,49,API.OFF_ACT_GeneralInterface_route)
    end

end

local function DrawGUI()

    API.DrawSquareFilled(guiBackPlate)
    API.DrawComboBox(guiListBox, false)
    
    local tabs = starting - API.InvStackSize(1762)
    local skill = "MAGIC"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. string.lower(skill):gsub("^%l", string.upper) .. ": " .. currentLevel .. " | XP/H: " .. FormatNumber(xpPH) .. " | Crafted: " .. tabs
    API.DrawProgressBar(progressBar)

    if (guiListBox.return_click) then
        guiListBox.return_click = false
    end

end

InitGUI()

local function ProcTeleTabs()

    local isWorking = API.isProcessing()

    if(API.InvItemcount_1(1761) == 0 and API.InvStackSize(563) > 0 and isWorking == false and fetching == false) then
        WriteLog("Un-certing more soft clay")
        DrawGUI()
        API.DoAction_Inventory1(1762, 0, 2, 4432)
        API.RandomSleep2(1500, 2000, 3500)
        API.DoAction_NPC(0x24,1408,{ 4243 },50)
        API.RandomSleep2(500, 800, 1500)

        if(API.Select_Option("Un-cert another")) then
            fetching = true
            WriteLog("Waiting for butler to return")
            API.RandomSleep2(1500, 2000, 3500)
        end

        if(API.Select_Option("Un-cert")) then
            API.RandomSleep2(500, 500, 500)
            API.KeyPress_("2")
            API.RandomSleep2(200, 500, 600)
            API.KeyPress_("0")
            API.RandomSleep2(200, 500, 600)
            API.KeyPress_("\13")
            API.RandomSleep2(200, 500, 600)
            fetching = true
            WriteLog("Waiting for butler to return")
            API.RandomSleep2(1500, 2000, 3500)
        end
    end

    if(API.InvItemcount_1(1761) > 0 and API.InvStackSize(563) > 0 and isWorking == false) then
        WriteLog("Crafting tele tabs")
        DrawGUI()
        API.RandomSleep2(800, 1200, 3500)
        API.DoAction_Object1(0x3f,0,{ 13647 },50)
        API.RandomSleep2(1500, 2000, 3500)
        TeleTabInterfaceSelection()
        API.RandomSleep2(500, 700, 1500)
        API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,4512)
        fetching = false
        API.RandomSleep2(500, 500, 500)
    end
end


API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    if (API.GetGameState() == 2) then
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end

    if(API.GetGameState() == 3) then
        API.DoRandomEvents()
        DrawGUI()

        if(firstLaunch) then
            API.RandomSleep2(5000, 6000, 7000)
            firstLaunch = false
        end

        ProcTeleTabs()
    end

API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
