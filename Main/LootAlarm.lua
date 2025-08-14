local AddonName, Addon = ...
local Core = Addon.Core
local Main = Addon.Main
local Functions = Addon.Functions
local Events1 = Addon.Events1
local Events2 = Addon.Events2
local Assets = Addon.Assets
local UI = Addon.UI
local ProfileManager = Addon.ProfileManager
local Items = Addon.Items
local Colors = Addon.Colors

--------------------------------------------
-- LOOT
--------------------------------------------

local TimeLastLootAlarm = time()

function Events1:LOOT_READY()
    if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then return end
    if (not ProfileManager:HasItemsInProfile()) then return end

    if (not LootAlarmLocalDB.Settings.FastLoot) then
        if (time() <= TimeLastLootAlarm + 0.5) then
            return
        else
            TimeLastLootAlarm = time()
        end
    end

    local UnitName = UnitName("Target")
    UnitName = Functions:Condition(UnitName, UnitName, "")

    local ProfileItems = ProfileManager:GeProfileItems()
    local LootAlarms = {}
    local HasHighValueItem = false

    for Slot = 1, GetNumLootItems() do
        if (GetLootSlotType(Slot) == Enum.LootSlotType.Item) then

            local ItemIcon, ItemName, _, _, ItemQuality = GetLootSlotInfo(Slot)
            local ItemLink = GetLootSlotLink(Slot)
            local ItemID = 0

            if (not ItemLink and ItemName) then
                _, ItemLink = C_Item.GetItemInfo(ItemName)
            end

            if (ItemLink) then
                ItemID = Items:GetItemID(ItemLink)
            end

            if ((not ItemID or ItemID == 0) and ItemName) then
                ItemID = Items:GetItemID(ItemName)
            end

            local HasItemName = ItemName and strlen(ItemName) > 0
            local HasItemID = ItemID and ItemID > 0
            local HasItemLink = ItemLink and strlen(ItemLink) > 0
            local HasItemQuality = ItemQuality and ItemQuality > 0

            if (HasItemName or HasItemLink or HasItemID) then

                for ProfileItemName, ProfileItem in next, ProfileItems, nil do

                    local IsLootAlarm = false

                    if (HasItemName) then
                        if (ProfileItem.IsWildcard) then

                            local Wildcard = string.lower(Functions:Trim(Functions:StringReplace(ProfileItemName, "*")))
                            if (Functions:StringContains(string.lower(ItemName), Wildcard)) then
                                IsLootAlarm = true
                            end
                            
                        elseif (string.lower(ItemName) == string.lower(ProfileItemName)) then
                            IsLootAlarm = true
                        end
                    end

                    if (not IsLootAlarm and HasItemID and ItemID == ProfileItem.ID) then
                        IsLootAlarm = true
                    end

                    if (IsLootAlarm) then
                        
                        if (not HasHighValueItem and HasItemQuality and ItemQuality) then
                            if (ItemQuality == Enum.ItemQuality.Rare or ItemQuality == Enum.ItemQuality.Epic) then
                                HasHighValueItem = true
                            end
                        end

                        local DisplayName = "Unknown item"

                        if (HasItemLink) then
                            DisplayName = ItemLink
                        elseif (HasItemName) then
                            DisplayName = ItemName
                        elseif (not tonumber(ProfileItemName)) then
                            DisplayName = ProfileItemName
                        end

                        if (HasItemID and DisplayName == "Unknown item") then
                            DisplayName = DisplayName.." ("..ItemID..")"
                        end

                        LootAlarms[Slot] = {}
                        LootAlarms[Slot].DisplayName = DisplayName
                        LootAlarms[Slot].Icon = Functions:Condition(ItemIcon and strlen(ItemIcon) > 0, ItemIcon, 134400)
                        LootAlarms[Slot].ID = Functions:Condition(ItemID and ItemID > 0, ItemID, 0)
                        LootAlarms[Slot].UnitName = UnitName

                        break

                    end
                end

            end
        end
    end

    if (Functions:CountTable(LootAlarms) == 0) then return end

    if (LootAlarmLocalDB.Settings.ShowChatMessage) then
        Main:DisplayLootInChat(LootAlarms)
    end

    if (LootAlarmLocalDB.Settings.ShowLootFrame) then
        Main:DisplayLootFrame(LootAlarms)
        if (LootAlarmLocalDB.Settings.AutoHideLootFrame) then
            Main:DisplayLootFrameProgressBar()
        end
    end

    if (LootAlarmLocalDB.Settings.JiggleLogo) then
		Main:JiggleLogo(0)
	end

    if (LootAlarmLocalDB.Settings.PlaySound) then
        PlaySoundFile(Assets.Sounds[Functions:Condition(HasHighValueItem, "Baam.ogg", "Bam.ogg")])
    end
end

--------------------------------------------
-- DISPLAY LOOT IN CHAT
--------------------------------------------

function Main:DisplayLootInChat(LootAlarms)
    print(Functions:PrintColor("—————————— "..Core.AddonName.." ——————————", "Whisper"))

    for LootSlot, Item in next, LootAlarms, nil do
        Functions:PrintAddon(table.concat{
            Functions:PrintIcon(Item.Icon),
            " "..Item.DisplayName,
            Functions:Condition(strlen(Item.UnitName) > 0, " from \""..Item.UnitName.."\"", "")..".",
        })
	end

    print(Functions:PrintColor("——————————————————————————", "Whisper"))
end

--------------------------------------------
-- DISPLAY LOOT FRAME
--------------------------------------------

function Main:DisplayLootFrame(LootAlarms)
	-- if (UI:IsVisible("LootFrame")) then UI:Hide("LootFrame") end

	for i = 1, 10 do
		UI:Hide("LFMultiAlarmIcon"..i)
		UI:Hide("LFMultiAlarmItemName"..i)
	end

	if (Functions:CountTable(LootAlarms) == 1) then

		UI:SetSize("LootFrame", { 450, 100 })
		UI:Show("LFSingleAlarmIcon", true)
		UI:Show("LFSingleAlarmItemName", true)

		for LootSlot, Item in next, LootAlarms, nil do

			UI:SetText("LFSingleAlarmItemName", Item.DisplayName)
			UI:SetText("LFSingleAlarmInfo", Item.UnitName)
			UI:SetNormalTexture("LFSingleAlarmIcon", Item.Icon)

			if (Item.ID > 0) then
				UI:SetItemTooltip("LFSingleAlarmIcon", Item.ID)
				UI:SetItemTooltip("LFSingleAlarmItemName", Item.ID)
			else
				local TooltipText = { "Couldn't receive any item info." }
            	UI:SetCustomTooltip("LFSingleAlarmIcon", TooltipText)
			end

		end

	else

		UI:Hide("LFSingleAlarmIcon")
		UI:Hide("LFSingleAlarmItemName")

		local LootFrameHeight = 45
		local i = 1

		for LootSlot, Item in next, LootAlarms, nil do
			
			UI:SetText("LFMultiAlarmItemName"..i, Item.DisplayName)
			UI:Show("LFMultiAlarmItemName"..i, true)

			UI:SetNormalTexture("LFMultiAlarmIcon"..i, Item.Icon)
			
			if (Item.ID > 0) then
				UI:SetItemTooltip("LFMultiAlarmIcon"..i, Item.ID)
				UI:SetItemTooltip("LFMultiAlarmItemName"..i, Item.ID)
			else
				local TooltipText = { "Couldn't receive any item info." }
            	UI:SetCustomTooltip("LFMultiAlarmIcon"..i, TooltipText)
			end

			UI:Show("LFMultiAlarmIcon"..i, true)

			LootFrameHeight = LootFrameHeight + 30
			i = i + 1
		end

		UI:SetSize("LootFrame", { 450, LootFrameHeight })

	end

	UI:Show("LootFrame", true)
end

Main.IsProgressBarLoading = false

function Main:DisplayLootFrameProgressBar()
    if (Main.IsProgressBarLoading) then return end
    Main.IsProgressBarLoading = true

    UI:Show("LFProgressBarBG", true)
    UI:SetWidth("LFProgressBar", 0)

    local LoadingTimeInSeconds = 15
    local MainFrameWidth = UI:GetWidth("LFProgressBarBG")
    local CurrentWidth = 0
    local TotalUpdates = LoadingTimeInSeconds * 60
    local GrowthRate = MainFrameWidth / TotalUpdates
    local UpdatesPassed = 0

    local function UpdateProgressBar()
        UpdatesPassed = UpdatesPassed + 1
        CurrentWidth = CurrentWidth + GrowthRate

        if CurrentWidth > MainFrameWidth then
            CurrentWidth = MainFrameWidth
        end

        UI:SetWidth("LFProgressBar", CurrentWidth)

        -- local TimePassed = UpdatesPassed / 100
        -- print(string.format("Time: %.2f LoadingTimeInSeconds, Width: %.2f pixel", TimePassed, CurrentWidth))

        if (UpdatesPassed < TotalUpdates and UI:IsVisible("LootFrame")) then
            C_Timer.After(0.01, UpdateProgressBar)
        else
            UI:Hide("LFProgressBarBG")
            UI:Hide("LootFrame")

            Main.IsProgressBarLoading = false
        end
    end

    UpdateProgressBar()
end

--------------------------------------------
-- JIGGLE LOGO
--------------------------------------------

Main.JiggleLogoReps = 16

function Main:JiggleLogo(Jiggle)
    local PositionX = Functions:Condition(Jiggle % 2 == 0, 1, -1)

    if (Jiggle == Main.JiggleLogoReps) then
		UI:SetPoint("LFLogo", { "CENTER", "LFTitle", "CENTER", 0, 32 })
        return
    else
		UI:SetPoint("LFLogo", { "CENTER", "LFTitle", "CENTER", PositionX, 32 })
    end

    C_Timer.After(0.06, function() Main:JiggleLogo((Jiggle + 1)) end)
end

--------------------------------------------
-- AUTO-EQUIP BOP & FAST LOOT
--------------------------------------------

Main.FastLootDelay = 0
Main.FastLootInterval = 0.3

function Events2:LOOT_READY()
    if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then return end

    -- Auto Confirm BoP 1/2

    if (LootAlarmLocalDB.Settings.AutoConfirmBoP) then
        for Slot = 1, GetNumLootItems() do
            if (GetLootSlotType(Slot) == Enum.LootSlotType.Item) then
                LootSlot(Slot)
                ConfirmLootSlot(Slot)
            end
        end
    end

    -- Fast Loot

    if (LootAlarmLocalDB.Settings.FastLoot) then
        if ((GetTime() - Main.FastLootDelay) < Main.FastLootInterval) then return end

        Main.FastLootDelay = GetTime()
        if (GetCVarBool("autoLootDefault") == IsModifiedClick("AUTOLOOTTOGGLE")) then return end

        for i = GetNumLootItems(), 1, -1 do
            LootSlot(i)
        end

        Main.FastLootDelay = GetTime()
    end
end

-- Auto Confirm BoP 2/2

function Events2:EQUIP_BIND_CONFIRM()
    if (not LootAlarmLocalDB.Settings.IsAddonEnabled) then return end
    if (not LootAlarmLocalDB.Settings.AutoConfirmBoP) then return end

    EquipPendingItem(0)
    StaticPopup_Hide("EQUIP_BIND")
end