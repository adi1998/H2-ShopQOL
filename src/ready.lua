modutil.mod.Path.Wrap("UpdateMarketScreenInteractionText", function (base, screen, button)
    base(screen, button)
    local components = screen.Components
	local category = screen.ItemCategories[screen.ActiveCategoryIndex]
    if button and button.Data and button.Data.Priority then
        if not category.FlipSides then
            game.SetAlpha({ Id = components.SellAllButton.Id, Fraction = 1.0, Duration = 0.2 })
            game.ModifyTextBox({ Id = components.SellAllButton.Id, Text = mod.BuyAllText })
        end
    end
    if category.FlipSides then
        game.SetAlpha({ Id = components[_PLUGIN.guid .. "SellEverythingButton"].Id, Fraction = 1.0, Duration = 0.2 })
        if screen.ActiveCategoryIndex == 4 then
            game.ModifyTextBox({ Id = components[_PLUGIN.guid .. "SellEverythingButton"].Id, Text = components[_PLUGIN.guid .. "SellEverythingButton"].AltTexts[1] })
        else
            game.ModifyTextBox({ Id = components[_PLUGIN.guid .. "SellEverythingButton"].Id, Text = components[_PLUGIN.guid .. "SellEverythingButton"].Text })
        end
    else
        game.SetAlpha({ Id = components[_PLUGIN.guid .. "SellEverythingButton"].Id, Fraction = 0.0, Duration = 0.2 })
    end
end)

modutil.mod.Path.Wrap("MarketScreenShowSellAllPrompt", function (base, screen)
    if screen.SelectedItem == nil then
		return
	end
	local button = screen.SelectedItem
	if button.Data.SoldOut then
		return
	end
    if not screen.ItemCategories[screen.ActiveCategoryIndex].FlipSides then
        if button.Data.Priority then
            mod.OpenBuyAllMarketPromptScreen( screen, button )
            if screen.DoSellAll then
                mod.MarketScreenBuyAll( screen, button )
            end
            screen.DoSellAll = nil
        end
	end
    return base(screen)
end)