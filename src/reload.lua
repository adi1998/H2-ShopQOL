--#region Buy All button
mod.BuyAllText = "{IP} PURCHASE ALL"

function mod.OpenBuyAllMarketPromptScreen( parentScreen, button )
	local screen = game.DeepCopyTable( game.ScreenData.MarketSellAllLayout )
	local components = screen.Components
	screen.ParentScreen = parentScreen
	screen.ButtonId = button.Id
	game.OnScreenOpened( screen )
	game.CreateScreenFromData( screen, screen.ComponentData )

	local sellKey = game.GetFirstKey(button.Data.Cost)
    local sellCost = game.GetFirstValue(button.Data.Cost)
	local sellAmount = game.GameState.Resources[sellKey] - game.GameState.Resources[sellKey] % sellCost
	local buyKey = button.Data.BuyName
	local buyAmount = button.Data.BuyAmount * math.floor(sellAmount / sellCost)
	local textData =
	{
		SellAmount = sellAmount,
		SellResourceIcon = game.ResourceData[sellKey].TextIconPath,
		BuyAmount = buyAmount,
		BuyResourceIcon = game.ResourceData[buyKey].TextIconPath,
	}
	game.ModifyTextBox({ Id = components.DescriptionText.Id, LuaKey = "TempTextData", LuaValue = textData })

	game.TeleportCursor({ DestinationId = components.CloseButton.Id, ForceUseCheck = true })
	game.SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	game.SetColor({ Id = components.BackgroundTint.Id, Color = game.Color.Black })
	game.SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	game.SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	game.wait(0.3)

	screen.KeepOpen = true
	game.HandleScreenInput( screen )
end

function mod.MarketScreenBuyAll( screen, button )
    local sellKey = game.GetFirstKey(button.Data.Cost)
    local sellCost = game.GetFirstValue(button.Data.Cost)
	local sellAmount = game.GameState.Resources[sellKey] - game.GameState.Resources[sellKey] % sellCost
	local buyKey = button.Data.BuyName
	local buyAmount = button.Data.BuyAmount * math.floor(sellAmount / sellCost)

    local item = button.Data

    local newCost = game.ShallowCopyTable( item.Cost )
    newCost[sellKey] = sellAmount

    local resourceArgs = { Silent = true }
    game.SpendResources( newCost, "ResourceShop", resourceArgs )
    game.AddResource( buyKey, buyAmount, "ResourceShop", resourceArgs )

    game.MarketScreenUpdateResourceStatus( screen )
	game.UpdateMarketScreenInteractionText( screen )
	game.UpdateAffordabilityStatus()
end
--#endregion

--#region Sell Everything button

local actionBar = game.ScreenData.MarketScreen.ComponentData.ActionBar

if not game.Contains(actionBar.ChildrenOrder, _PLUGIN.guid .. "SellEverythingButton") then
    table.insert(actionBar.ChildrenOrder, _PLUGIN.guid .. "SellEverythingButton")
end

actionBar.Children[_PLUGIN.guid .. "SellEverythingButton"] =
{
    Graphic = "ContextualActionButton",
    GroupName = "Combat_Menu_Overlay",
    Alpha = 0.0,
    Data =
    {
        -- Hotkey only
        OnPressedFunctionName = _PLUGIN.guid .. "." .. "MarketSellEverythingPrompt",
        ControlHotkeys = { "Reroll", },
    },
    Text = "{RR} SELL EVERYTHING",
    AltTexts = { "{RR} RECYCLE EVERYTHING" },
    TextArgs = game.UIData.ContextualButtonFormatRight,
}

function mod.OpenSellEverythingPromptScreen(parentScreen, buttonList)

    local screen = game.DeepCopyTable( game.ScreenData.MarketSellAllLayout )
	local components = screen.Components
	screen.ParentScreen = parentScreen
	game.OnScreenOpened( screen )
	game.CreateScreenFromData( screen, screen.ComponentData )

    local sellIcon = "GUI\\Screens\\Inventory\\Icon-Fish"
    local sellAmount = 0
    local buyKey = "MetaCurrency"
    local buyAmount = 0

    if parentScreen.ActiveCategoryIndex == 4 then
        buyKey = "CosmeticsPoints"
        sellIcon = "GUI\\Screens\\Inventory\\Icon-Reagents"
    end

    for index, button in ipairs(buttonList) do
        local item = button.Data
        if item then
            local itemSellKey = game.GetFirstKey(item.Cost)
            sellAmount = sellAmount + game.GameState.Resources[itemSellKey]
            buyAmount = buyAmount + item.BuyAmount * game.GameState.Resources[itemSellKey]
        end
    end

    local textData =
	{
		SellAmount = sellAmount,
		SellResourceIcon = sellIcon,
		BuyAmount = buyAmount,
		BuyResourceIcon = game.ResourceData[buyKey].TextIconPath,
	}

    game.ModifyTextBox({ Id = components.DescriptionText.Id, LuaKey = "TempTextData", LuaValue = textData })

    game.TeleportCursor({ DestinationId = components.CloseButton.Id, ForceUseCheck = true })
	game.SetConfigOption({ Name = "ExclusiveInteractGroup", Value = "Combat_Menu_TraitTray" })
	game.SetColor({ Id = components.BackgroundTint.Id, Color = game.Color.Black })
	game.SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.0, Duration = 0 })
	game.SetAlpha({ Id = components.BackgroundTint.Id, Fraction = 0.9, Duration = 0.3 })
	game.wait(0.3)

	screen.KeepOpen = true
	game.HandleScreenInput( screen )
end

function mod.MarketSellEverythingPrompt(screen)
    local category = screen.ItemCategories[screen.ActiveCategoryIndex]

    if not category.FlipSides then
        return
    end

    local buttonList = {}
    for itemIndex = 1, screen.NumItems do
        local button = screen.Components["PurchaseButton"..itemIndex]
        if button ~= nil then
			local item = button.Data
            if item and not item.HasUnmetRequirements then
                table.insert(buttonList, button)
            end
        end
    end
    if not game.IsEmpty(buttonList) then
        mod.OpenSellEverythingPromptScreen(screen, buttonList)
        if screen.DoSellAll then
            for key, button in ipairs(buttonList) do
                game.MarketScreenSellAll(screen, button)
                game.wait(0.05)
            end
            game.wait(0.1)
            game.WeaponShopScreenHideItems( screen )
            game.wait( 0.1 )
            screen.ScrollOffset = 0
            game.MarketScreenDisplayCategory( screen, screen.ActiveCategoryIndex )
            game.WeaponShopUpdateVisibility( screen )
            game.wait( 0.02 )
            game.ScreenResetCursorToStartLocation( screen )
        end
        screen.DoSellAll = nil
    end
end