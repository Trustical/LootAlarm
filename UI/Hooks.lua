local _, Addon = ...
local Core = Addon.Core
local UI = Addon.UI
local Functions = Addon.Functions
local Items = Addon.Items
local Colors = Addon.Colors

--------------------------------------------
-- ITEM ID
--------------------------------------------

local function HookItemID(Tooltip)
    if (not LootAlarmLocalDB.Settings.ShowItemIDs) then return end
	if (not Tooltip or not Tooltip.GetItem) then return end
	
	local _, ItemLink = Tooltip:GetItem()
	if (not ItemLink) then return end
	
	local ItemName = Items:GetItemNameByLink(ItemLink)
    if (strlen(ItemName) == 0) then return end

	local ItemID = Items:GetItemIDByLink(ItemLink)
    if (ItemID == 0) then return end

    Tooltip:AddLine("\nID: "..Functions:PrintColor(ItemID, Colors.blue))
end

if (TooltipDataProcessor) then
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, HookItemID)
else
	GameTooltip:HookScript("OnTooltipSetItem", HookItemID)
end