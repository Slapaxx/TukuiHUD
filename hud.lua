------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------
local T, C, L = unpack(Tukui)
local addon, ns = ...
ns.oUF = oUFTukui
local oUF = ns.oUF
local db = TukuiHudCF
local normTex = [[Interface\AddOns\Tukui_Hud\media\Asphyxia]]
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}

local hud_height = T.Scale(TukuiHudCF.height)
local hud_width = T.Scale(TukuiHudCF.width)
local hud_power_width = T.Scale((hud_width/3)*2)

local function Hud(self, unit)
    -- Set Colors
    self.colors = T.UnitColor

    -- Update all elements on show
    self:HookScript("OnShow", TukuiHud.updateAllElements)
	self:EnableMouse(false) -- HUD should be click-through

    -- For Testing..
    --[[self:SetBackdrop(backdrop)
    self:SetBackdropColor(0, 0, 0)]]

    -- Border for non Player/Target frames
   
    ------------------------------------------------------------------------
    --	Player
    ------------------------------------------------------------------------
    if unit == "player" then
        -- Health Bar
        local health = CreateFrame('StatusBar', nil, self)
        health:SetWidth(hud_width)
        health:SetHeight(hud_height-4)
        health:SetPoint("LEFT", self, "LEFT")
        health:SetStatusBarTexture(normTex)
        health:SetOrientation("VERTICAL")
        health:SetFrameLevel(self:GetFrameLevel() + 5)
        self.health = health

        -- Health Frame Border
        local HealthFrame = CreateFrame("Frame", nil, self)
        HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", T.Scale(-2), T.Scale(2))
        HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
        HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

        HealthFrame:SetTemplate("Transparent")
        HealthFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
        HealthFrame:CreateShadow()

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.1)
		if db.showvalues then
			health.value = T.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
			health.value:SetPoint("TOPRIGHT", health, "TOPLEFT", T.Scale(-20), T.Scale(-15))
		end
        health.PostUpdate = TukuiHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
            health.Smooth = true
        end

        -- Setup Colors
        if db.unicolor ~= false then
            health.colorTapping = false
            health.colorClass = false
            health:SetStatusBarColor(unpack(C["unitframes"].healthcolor or { 0.05, 0.05, 0.05 }))
            health.colorDisconnected = false
        else
            health.colorTapping = true	
            health.colorClass = true
            health.colorReaction = true
            health.colorDisconnected = true		
        end

        if TukuiHudCF.powerhud then
            -- Power Frame Border
            local PowerFrame = CreateFrame("Frame", "TukuiHUD_Power", self)
            PowerFrame:SetHeight(hud_height)
            PowerFrame:SetWidth(hud_power_width)
            PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
            PowerFrame:SetPoint("LEFT", self.Health, "RIGHT", T.Scale(4), 0)

            PowerFrame:SetTemplate("Transparent")
            PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
            PowerFrame:CreateShadow()

            -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
            local power = CreateFrame('StatusBar', nil, self)
            power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", T.mult*2, -T.mult*2)
            power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -T.mult*2, T.mult*2)
            power:SetStatusBarTexture(normTex)
            power:SetOrientation("VERTICAL")
            power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

            -- Power Background
            local powerBG = power:CreateTexture(nil, 'BORDER')
            powerBG:SetAllPoints(power)
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if TukuiHudCF.showvalues then
				power.value = T.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
				power.value:SetPoint("TOPLEFT", power, "TOPRIGHT", T.Scale(10), T.Scale(-15))
			end
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

			power.colorTapping = true	
			power.colorPower = true
			power.colorReaction = true
			power.colorDisconnected = true		
			
            -- Smooth Animation
            if db.showsmooth == true then
                power.Smooth = true
            end
        end
		
		if TukuiHudCF.classspecificbars then
			if T.myclass == "DRUID" then
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)
				eclipseBar:SetSize(hud_width-8, hud_height-4)
				eclipseBar:SetFrameStrata("MEDIUM")
				eclipseBar:SetFrameLevel(8)
				eclipseBar:SetTemplate("Transparent")
				eclipseBar:SetBackdropBorderColor(0,0,0,0)
								
				local lunarBar = CreateFrame('StatusBar', self:GetName().."_LunarBar", eclipseBar)
				lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
				lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				lunarBar:SetStatusBarTexture(normTex)
				lunarBar:SetStatusBarColor(.30, .52, .90)
				lunarBar:SetOrientation('VERTICAL')
				eclipseBar.LunarBar = lunarBar

				local solarBar = CreateFrame('StatusBar', self:GetName().."_SolarBar", eclipseBar)
				solarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
				solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				solarBar:SetStatusBarTexture(normTex)
				solarBar:SetStatusBarColor(.80, .82,  .60)
				solarBar:SetOrientation('VERTICAL')
				eclipseBar.SolarBar = solarBar
				
				local eclipseBarText = eclipseBar:CreateFontString(nil, 'OVERLAY')
				eclipseBarText:SetPoint("LEFT", eclipseBar, "RIGHT", T.Scale(10), 0)
				eclipseBarText:SetFont(db.font, db.fontsize, "THINOUTLINE")
				
				eclipseBar.PostUpdatePower = TukuiHud.EclipseDirection
				self.EclipseBar = eclipseBar
				self.EclipseBar.Text = eclipseBarText
				
				eclipseBar.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_EclipseBar", eclipseBar)
				eclipseBar.FrameBackdrop:SetTemplate("Transparent")
				eclipseBar.FrameBackdrop:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", T.Scale(-2), T.Scale(2))
				eclipseBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", lunarBar, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				eclipseBar.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				eclipseBar.FrameBackdrop:SetFrameLevel(eclipseBar:GetFrameLevel() - 1)
				eclipseBar.FrameBackdrop:CreateShadow()

			end

			if T.myclass == "WARLOCK" then
				local bars = CreateFrame("Frame", nil, self)
				bars:SetHeight(hud_height-4)
				bars:SetWidth(hud_width-8)
				bars:SetFrameLevel(self:GetFrameLevel() + 5)
				bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)

				for i = 1, 4 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_WarlockSpecBars"..i, self)
					bars[i]:SetWidth(hud_width-8)			
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)
					bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					bars[i]:SetStatusBarColor(148/255, 130/255, 201/255)
					bars[i].bg:SetTexture(148/255, 130/255, 201/255)

					if i == 1 then
						bars[i]:SetPoint("BOTTOM", bars)
					else
						bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, T.Scale(1))
					end

					bars[i]:SetOrientation('VERTICAL')
					bars[i].bg:SetAllPoints(bars[i])
					bars[i]:SetHeight(((hud_height - 4) - 3)/4)

					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.15)
				end

				--bars.Override = T.UpdateWarlockSpecBars
				self.WarlockSpecBars = bars

				bars.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_WarlockSpecBar", bars)
				bars.FrameBackdrop:SetTemplate("Transparent")
				bars.FrameBackdrop:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
				bars.FrameBackdrop:CreateShadow()
			end
			if T.myclass == "PALADIN" then
				local bars = CreateFrame("Frame", nil, self)
				bars:SetHeight(hud_height-4)
				bars:SetWidth(hud_width-8)
				bars:SetFrameLevel(self:GetFrameLevel() + 5)
				bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)
				for i = 1, 5 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_HolyPower"..i, self)
					bars[i]:SetWidth(hud_width-8)			
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)
					bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)

					bars[i].bg = bars[i]:CreateTexture(nil, 'BORDER')
					bars[i]:SetStatusBarColor(228/255,225/255,16/255)
					bars[i].bg:SetTexture(228/255,225/255,16/255)
					
					if i == 1 then
						bars[i]:SetPoint("BOTTOM", bars)
					else
						bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, T.Scale(1))
					end
					bars[i]:SetOrientation('VERTICAL')
					bars[i].bg:SetAllPoints(bars[i])
					bars[i]:SetHeight((T.Scale(hud_height - 4) - 4)/5)
					if UnitLevel("player") <=84 then bars[i]:SetHeight(T.Scale(((hud_height - 4) - 2)/3)) end
					bars[i].bg:SetTexture(normTex)					
					bars[i].bg:SetAlpha(.15)
				end
				
				bars.Override = T.UpdateHoly
				self.HolyPower = bars

				bars.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_HolyPowerBar", bars)
				bars.FrameBackdrop:SetTemplate("Transparent")
				bars.FrameBackdrop:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
				bars.FrameBackdrop:CreateShadow()
			end
			if T.myclass == "MONK" then
				local hb = CreateFrame("Frame", nil, self)
				hb:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)
				hb:SetHeight(hud_height-4)
				hb:SetWidth(hud_width-8)
				hb:SetFrameLevel(self:GetFrameLevel() + 5)
				local _, talent = GetTalentRowSelectionInfo(3)
				
				for i = 1, 5 do
					hb[i] = CreateFrame("StatusBar", self:GetName().."_HarmonyBar"..i, self)
					hb[i]:SetHeight(((hud_height - 4) - 3)/4)
					if talent == 8 then hb[i]:SetHeight((T.Scale(hud_height - 4) - 4)/5) end
					hb[i]:SetWidth(hud_width-8)
					
					if i == 1 then
						hb[i]:SetPoint("BOTTOM", hb)
					else
						hb[i]:SetPoint("BOTTOM", hb[i-1], "TOP", 0, T.Scale(1))
					end
					hb[i]:SetStatusBarTexture(normTex)
					hb[i]:GetStatusBarTexture():SetHorizTile(false)
					hb[i]:SetOrientation('VERTICAL')
				end
				hb.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_HarmonyBar", hb)
				hb.FrameBackdrop:SetTemplate("Transparent")
				hb.FrameBackdrop:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				hb.FrameBackdrop:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				hb.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				hb.FrameBackdrop:SetFrameLevel(hb:GetFrameLevel() - 1)
				hb.FrameBackdrop:CreateShadow()
				self.HarmonyBar = hb
			end
			-- deathknight runes
			if T.myclass == "DEATHKNIGHT" then
				local Runes = CreateFrame("Frame", nil, self)
				Runes:SetHeight(hud_height-4)
				Runes:SetWidth(hud_width-8)
				Runes:SetFrameLevel(self:GetFrameLevel() + 5)
				Runes:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)
				Runes:SetTemplate("Transparent")
				Runes:SetBackdropBorderColor(0,0,0,0)

				for i = 1, 6 do
					Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
					Runes[i]:SetHeight(((hud_height - 4) - 5)/6)
					Runes[i]:SetWidth(hud_width-8)
					Runes[i]:SetFrameLevel(Runes:GetFrameLevel() + 1)

					if (i == 1) then
						Runes[i]:SetPoint("BOTTOM", Runes)
					else
						Runes[i]:SetPoint("BOTTOM", Runes[i-1], "TOP", 0, T.Scale(1))
					end
					Runes[i]:SetStatusBarTexture(normTex)
					Runes[i]:GetStatusBarTexture():SetHorizTile(false)
					Runes[i]:SetOrientation('VERTICAL')
				end
				
				Runes.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_RunesBar", Runes)
				Runes.FrameBackdrop:SetTemplate("Transparent")
				Runes.FrameBackdrop:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				Runes.FrameBackdrop:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				Runes.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				Runes.FrameBackdrop:SetFrameLevel(Runes:GetFrameLevel() - 1)
				Runes.FrameBackdrop:CreateShadow()
				self.Runes = Runes
			end
				
			-- shaman totem bar
			if T.myclass == "SHAMAN" then
				local TotemBar = CreateFrame("Frame", nil, self)
				TotemBar.Destroy = true
				TotemBar:SetHeight(hud_height-4)
				TotemBar:SetWidth(hud_width-8)
				TotemBar:SetFrameLevel(self:GetFrameLevel() + 5)
				TotemBar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)

				TotemBar:SetBackdrop(backdrop)
				TotemBar:SetBackdropColor(0, 0, 0)

				for i = 1, 4 do
					TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
					TotemBar[i]:SetHeight(((hud_height - 4) - 3)/4)
					TotemBar[i]:SetWidth(hud_width - 8)
					TotemBar[i]:SetFrameLevel(TotemBar:GetFrameLevel()+1)

					if (i == 1) then
						TotemBar[i]:SetPoint("BOTTOM",TotemBar)
					else
						TotemBar[i]:SetPoint("BOTTOM", TotemBar[i-1], "TOP", 0, T.Scale(1))
					end
					TotemBar[i]:SetStatusBarTexture(normTex)
					TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
					TotemBar[i]:SetOrientation('VERTICAL')
					TotemBar[i]:SetBackdrop(backdrop)
					TotemBar[i]:SetBackdropColor(0, 0, 0)
					TotemBar[i]:SetMinMaxValues(0, 1)

					
					TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
					TotemBar[i].bg:SetAllPoints(TotemBar[i])
					TotemBar[i].bg:SetTexture(normTex)
					TotemBar[i].bg.multiplier = 0.3
				end


				TotemBar.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_TotemsBar", TotemBar)
				TotemBar.FrameBackdrop:SetTemplate("Transparent")
				TotemBar.FrameBackdrop:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				TotemBar.FrameBackdrop:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				TotemBar.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				TotemBar.FrameBackdrop:SetFrameLevel(TotemBar:GetFrameLevel() - 1)
				TotemBar.FrameBackdrop:CreateShadow()
				self.TotemBar = TotemBar
			end
			if T.myclass == "ROGUE" then
				local bars = CreateFrame("Frame", nil, self)
				bars:SetHeight(hud_height-4)
				bars:SetWidth(hud_width-8)
				bars:SetFrameLevel(self:GetFrameLevel() + 5)
				bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_BanditsGuile"..i, self)
					bars[i]:SetWidth(hud_width-8)			
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)
					bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)
					
					if i == 1 then
						bars[i]:SetPoint("BOTTOM", bars)
					else
						bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, T.Scale(1))
					end
					bars[i]:SetOrientation('VERTICAL')
					bars[i]:SetHeight(T.Scale(((hud_height - 4) - 2)/3))
				end
				bars[1]:SetStatusBarColor(0.33, 0.59, 0.33)
				bars[2]:SetStatusBarColor(0.65, 0.63, 0.35)
				bars[3]:SetStatusBarColor(0.69, 0.31, 0.31)

				self.BanditsGuile = bars

				bars.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_BanditsGuileBar", bars[1])
				bars.FrameBackdrop:SetTemplate("Transparent")
				bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", T.Scale(-2), T.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
				bars.FrameBackdrop:CreateShadow()

				bars[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
				bars[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
				bars[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
				bars[1]:RegisterEvent("PLAYER_TARGET_CHANGED")
				bars[1]:RegisterUnitEvent("UNIT_AURA", "player")
				bars[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
				bars[1]:SetScript("OnEvent", function(self, event)
					local _, _, _, shallow = UnitBuff("player", GetSpellInfo(84745))
					local _, _, _, moderate = UnitBuff("player", GetSpellInfo(84746))
					local _, _, _, deep = UnitBuff("player", GetSpellInfo(84747))
					
					if GetSpecialization() == 2 and (shallow or moderate or deep) then
						if shallow then bars[1]:Show() end
						if moderate then bars[1]:Show() bars[2]:Show() end
						if deep then bars[1]:Show() bars[2]:Show() bars[3]:Show() end
					else
						for i = 1, 3 do bars[i]:Hide() end
					end
				end)
			end
			if T.myclass == "PRIEST" then
				local bars = CreateFrame("Frame", nil, self)
				bars:SetHeight(hud_height-4)
				bars:SetWidth(hud_width-8)
				bars:SetFrameLevel(self:GetFrameLevel() + 5)
				bars:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", T.Scale(-6), 0)
				for i = 1, 3 do					
					bars[i]=CreateFrame("StatusBar", self:GetName().."_ShadowOrb"..i, self)
					bars[i]:SetWidth(hud_width-8)			
					bars[i]:SetStatusBarTexture(normTex)
					bars[i]:GetStatusBarTexture():SetHorizTile(false)
					bars[i]:SetFrameLevel(bars:GetFrameLevel()+1)
					
					if i == 1 then
						bars[i]:SetPoint("BOTTOM", bars)
					else
						bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, T.Scale(1))
					end
					bars[i]:SetOrientation('VERTICAL')
					bars[i]:SetHeight(T.Scale(((hud_height - 4) - 2)/3))
					bars[i]:SetStatusBarColor(0.6, 0, 0.86)
				end

				self.ShadowOrb = bars

				bars.FrameBackdrop = CreateFrame("Frame", "TukuiHUD_ShadowOrbsBar", bars[1])
				bars.FrameBackdrop:SetTemplate("Transparent")
				bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", T.Scale(-2), T.Scale(2))
				bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))
				bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
				bars.FrameBackdrop:CreateShadow()

				bars[1]:RegisterEvent("PLAYER_ENTERING_WORLD")
				bars[1]:RegisterEvent("PLAYER_REGEN_DISABLED")
				bars[1]:RegisterEvent("PLAYER_REGEN_ENABLED")
				bars[1]:RegisterUnitEvent("UNIT_POWER", "player")
				bars[1]:RegisterUnitEvent("UNIT_MAXPOWER", "player")
				bars[1]:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
				bars[1]:SetScript("OnEvent", function(self, event)
					local value = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
					local maxValue = UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS)
					local count = maxValue
					
					for i = 1, count do bars[i]:Hide() end
					if bars[2]:IsShown() and not bars[1]:IsShown() then bars[1]:Show() end
					if value and value > 0 then
						for i = 1, value do bars[i]:Show() end
						for i = value+1, count do bars[i]:Hide() end
					else
						for i = 1, count do bars[i]:Hide() end
					end
				end)
			end
		end
    elseif unit == "target" then
        -- Health Bar
        local health = CreateFrame('StatusBar', nil, self)
        health:SetWidth(hud_width - 4)
        health:SetHeight(hud_height - 4)
        health:SetPoint("RIGHT", self, "RIGHT")
        health:SetStatusBarTexture(normTex)
        health:SetOrientation("VERTICAL")
        health:SetFrameLevel(self:GetFrameLevel() + 5)

        self.health = health

        -- Health Frame Border
        local HealthFrame = CreateFrame("Frame", nil, self)
        HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", T.Scale(-2), T.Scale(2))
        HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
        HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

        HealthFrame:SetTemplate("Transparent")
        HealthFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
        HealthFrame:CreateShadow()

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.2)
		if TukuiHudCF.showvalues then
			health.value = T.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
			health.value:SetPoint("LEFT", health, "RIGHT", T.Scale(20), 0)
		end
        health.PostUpdate = TukuiHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
            health.Smooth = true
        end

        -- Setup Colors
        if db.unicolor ~= false then
            health.colorTapping = false
            health.colorClass = false
            health:SetStatusBarColor(unpack(C["unitframes"].healthcolor or { 0.05, 0.05, 0.05 }))
            health.colorDisconnected = false
        else
            health.colorTapping = true	
            health.colorClass = true
            health.colorReaction = true
            health.colorDisconnected = true		
        end
		
		-- Setup combo points
		local bars = CreateFrame("Frame", nil, self)
		bars:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", T.Scale(6), 0)
		bars:SetWidth(hud_width-8)
		bars:SetHeight(hud_height-4)
		
		for i = 1, 5 do					
			bars[i] = CreateFrame("StatusBar", self:GetName().."_Combo"..i, self)
			bars[i]:SetHeight((T.Scale(hud_height - 4) - 4)/5)					
			bars[i]:SetStatusBarTexture(normTex)
			bars[i]:GetStatusBarTexture():SetHorizTile(false)
							
			if i == 1 then
				bars[i]:SetPoint("BOTTOM", bars)
			else
				bars[i]:SetPoint("BOTTOM", bars[i-1], "TOP", 0, T.Scale(1))
			end
			bars[i]:SetAlpha(0.15)
			bars[i]:SetWidth(hud_width-8)
			bars[i]:SetOrientation('VERTICAL')
		end
		
		bars[1]:SetStatusBarColor(0.70, 0.30, 0.30)		
		bars[2]:SetStatusBarColor(0.70, 0.40, 0.30)
		bars[3]:SetStatusBarColor(0.60, 0.60, 0.30)
		bars[4]:SetStatusBarColor(0.40, 0.70, 0.30)
		bars[5]:SetStatusBarColor(0.30, 0.70, 0.30)

		self.CPoints = bars
		self.CPoints.Override = TukuiHud.ComboDisplay
		
		bars.FrameBackdrop = CreateFrame("Frame", nil, bars[1])
		bars.FrameBackdrop:SetTemplate("Transparent")
		bars.FrameBackdrop:SetPoint("TOPLEFT", bars, "TOPLEFT", T.Scale(-2), T.Scale(2))
		bars.FrameBackdrop:SetPoint("BOTTOMRIGHT", bars, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
		bars.FrameBackdrop:SetFrameLevel(bars:GetFrameLevel() - 1)
		bars.FrameBackdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
		bars.FrameBackdrop:CreateShadow()
		self:RegisterEvent("UNIT_DISPLAYPOWER", TukuiHud.ComboDisplay)

        if TukuiHudCF.powerhud then
            -- Power Frame Border
            local PowerFrame = CreateFrame("Frame", nil, self)
            PowerFrame:SetHeight(hud_height)
            PowerFrame:SetWidth(hud_power_width)
            PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
            PowerFrame:SetPoint("RIGHT", self.Health, "LEFT", T.Scale(-4), 0)

            PowerFrame:SetTemplate("Transparent")
            PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
            PowerFrame:CreateShadow()

            -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
            local power = CreateFrame('StatusBar', nil, self)
            power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", T.mult*2, -T.mult*2)
            power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -T.mult*2, T.mult*2)
            power:SetStatusBarTexture(normTex)
            power:SetOrientation("VERTICAL")
            power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

            -- Power Background
            local powerBG = power:CreateTexture(nil, 'BORDER')
            powerBG:SetAllPoints(power)
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if TukuiHudCF.showvalues then
				power.value = T.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
				power.value:SetPoint("RIGHT", power, "LEFT", T.Scale(-4), 0)
			end
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

            -- Setup Colors
			power.colorTapping = true	
			power.colorPower = true
			power.colorReaction = true
			power.colorDisconnected = true		

            -- Smooth Animation
            if db.showsmooth == true then
                power.Smooth = true
            end
        end
    else
		-- Health Bar
        local health = CreateFrame('StatusBar', nil, self)
        health:SetWidth(hud_width - 4)
        health:SetHeight((hud_height * .75) - 4)
        health:SetPoint("LEFT", self, "LEFT")
        health:SetStatusBarTexture(normTex)
        health:SetOrientation("VERTICAL")
        health:SetFrameLevel(self:GetFrameLevel() + 5)
        self.health = health

        -- Health Frame Border
        local HealthFrame = CreateFrame("Frame", nil, self)
        HealthFrame:SetPoint("TOPLEFT", health, "TOPLEFT", T.Scale(-2), T.Scale(2))
        HealthFrame:SetPoint("BOTTOMRIGHT", health, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
        HealthFrame:SetFrameLevel(self:GetFrameLevel() + 4)

        HealthFrame:SetTemplate("Transparent")
        HealthFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
        HealthFrame:CreateShadow()

        -- Health Bar Background
        local healthBG = health:CreateTexture(nil, 'BORDER')
        healthBG:SetAllPoints()
        healthBG:SetTexture(.1, .1, .1)
        healthBG:SetAlpha(.1)
		if TukuiHudCF.showvalues then
			health.value = T.SetFontString(health, db.font, db.fontsize , "THINOUTLINE")
			health.value:SetPoint("RIGHT", health, "LEFT", T.Scale(-4), T.Scale(0))
		end
        health.PostUpdate = TukuiHud.PostUpdateHealthHud
        self.Health = health
        self.Health.bg = healthBG
        health.frequentUpdates = true

        -- Smooth Bar Animation
        if db.showsmooth == true then
            health.Smooth = true
        end

        -- Setup Colors
        if db.unicolor ~= false then
            health.colorTapping = false
            health.colorClass = false
            health:SetStatusBarColor(unpack(C["unitframes"].healthcolor or { 0.05, 0.05, 0.05 }))
            health.colorDisconnected = false
        else
            health.colorTapping = true	
            health.colorClass = true
            health.colorReaction = true
            health.colorDisconnected = true		
        end

        if TukuiHudCF.powerhud then
            -- Power Frame Border
            local PowerFrame = CreateFrame("Frame", nil, self)
            PowerFrame:SetHeight(hud_height * .75)
            PowerFrame:SetWidth(hud_power_width)
            PowerFrame:SetFrameLevel(self:GetFrameLevel() + 4)
            PowerFrame:SetPoint("LEFT", self.Health, "RIGHT", T.Scale(4), 0)

            PowerFrame:SetTemplate("Transparent")
            PowerFrame:SetBackdropBorderColor(unpack(C["media"].altbordercolor or C["media"].bordercolor))	
            PowerFrame:CreateShadow()

            -- Power Bar (Last because we change width of frame, and i don't want to fuck up everything else
            local power = CreateFrame('StatusBar', nil, self)
            power:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", T.mult*2, -T.mult*2)
            power:SetPoint("BOTTOMRIGHT", PowerFrame, "BOTTOMRIGHT", -T.mult*2, T.mult*2)
            power:SetStatusBarTexture(normTex)
            power:SetOrientation("VERTICAL")
            power:SetFrameLevel(PowerFrame:GetFrameLevel()+1)

            -- Power Background
            local powerBG = power:CreateTexture(nil, 'BORDER')
            powerBG:SetAllPoints(power)
            powerBG:SetTexture(normTex)
            powerBG.multiplier = 0.3
			if TukuiHudCF.showvalues then
				power.value = T.SetFontString(health, db.font, db.fontsize, "THINOUTLINE")
				power.value:SetPoint("LEFT", power, "RIGHT", T.Scale(4), 0)
			end
            power.PreUpdate = TukuiHud.PreUpdatePowerHud
            power.PostUpdate = TukuiHud.PostUpdatePowerHud

            self.Power = power
            self.Power.bg = powerBG

            -- Update the Power bar Frequently
            power.frequentUpdates = true

            -- Setup Colors
			power.colorTapping = true	
			power.colorPower = true
			power.colorReaction = true
			power.colorDisconnected = true		
			
            -- Smooth Animation
            if db.showsmooth == true then
                power.Smooth = true
            end
		end
		
		if unit == "pet" then
			self:RegisterEvent("UNIT_PET", TukuiHud.updateAllElements)
		end
	end
end

oUF:RegisterStyle('TukuiHUD',Hud)
oUF:SetActiveStyle('TukuiHUD')

if TukuiHudCF.warningText then
	TukuiHud.CreateWarningFrame()
end

	local width = hud_width
	if TukuiHudCF.powerhud then
		width = width + hud_power_width + 2
	end

	if TukuiHudCF.showthreat then
		width = width + hud_power_width + 2
	end

	local alpha = TukuiHudCF.alpha

	local player_hud = oUF:Spawn('player', "TukuiHUD_Player")
	player_hud:SetPoint("RIGHT", UIParent, "CENTER", T.Scale(-TukuiHudCF.offset), 0)
	player_hud:SetSize(width, hud_height)
	player_hud:SetAlpha(alpha)

	TukuiHud.HideOOC(player_hud)

	width = hud_width
	if TukuiHudCF.powerhud then
		width = width + hud_power_width + 2
	end

	local target_hud = oUF:Spawn('target', "TukuiHUD_Target")
	target_hud:SetPoint("LEFT", UIParent, "CENTER", T.Scale(TukuiHudCF.offset), 0)
	target_hud:SetSize(width, hud_height)
	target_hud:SetAlpha(alpha)

	TukuiHud.HideOOC(target_hud)

	if TukuiHudCF.pethud then
		width = hud_width
		if TukuiHudCF.powerhud then
			width = width + hud_power_width + 2
		end

		local pet_hud = oUF:Spawn('pet', "TukuiHUD_Pet")
		pet_hud:SetPoint("BOTTOMRIGHT", TukuiHUD_Player, "BOTTOMLEFT", -T.Scale(80), 0)
		pet_hud:SetSize(width, hud_height * .75)
		pet_hud:SetAlpha(alpha)
		
		TukuiHud.HideOOC(pet_hud)
	end
	
	if TukuiHudCF.tothud then
		width = hud_width
		if TukuiHudCF.powerhud then
			width = width + hud_power_width + 2
		end

		local tot_hud = oUF:Spawn('targettarget', "TukuiHUD_ToT")
		tot_hud:SetPoint("BOTTOMLEFT", TukuiHUD_Target, "BOTTOMRIGHT", T.Scale(80), 0)
		tot_hud:SetSize(width, hud_height * .75)
		tot_hud:SetAlpha(alpha)
		
		TukuiHud.HideOOC(tot_hud)
	end
	
	if TukuiHudCF.focushud then
		width = hud_width
		if TukuiHudCF.powerhud then
			width = width + hud_power_width + 2
		end
		
		local frame = oUF_Tukz_player_Hud
		if TukuiHudCF.pethud then
			frame = oUF_Tukz_pet_Hud
		end
		
		local focus_hud = oUF:Spawn('focus', "TukuiHUD_Focus")
		focus_hud:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -T.Scale(80), 0)
		focus_hud:SetSize(width, hud_height * .75)
		focus_hud:SetAlpha(alpha)
		
		TukuiHud.HideOOC(focus_hud)
	end

if TukuiHUD_HolyPowerBar then TukuiHUD_HolyPowerBar:HookScript("OnShow", function(self)
		if UnitAffectingCombat("player") or hideooc == false then
			if UnitLevel("player") <=84 then
				TukuiHUD_Player_HolyPower1:SetWidth(hud_width-8)
				TukuiHUD_Player_HolyPower2:SetWidth(hud_width-8)
				TukuiHUD_Player_HolyPower3:SetWidth(hud_width-8)
			end
		end
	end)
end
if TukuiHUD_HarmonyBar then TukuiHUD_HarmonyBar:HookScript("OnUpdate", function()
		if UnitAffectingCombat("player") or hideooc == false then
			local _, talent = GetTalentRowSelectionInfo(3)
			if talent == 8 then return end
			TukuiHUD_Player_HarmonyBar1:SetWidth(hud_width-8)
			TukuiHUD_Player_HarmonyBar2:SetWidth(hud_width-8)
			TukuiHUD_Player_HarmonyBar3:SetWidth(hud_width-8)
			TukuiHUD_Player_HarmonyBar4:SetWidth(hud_width-8)
		end
	end)
end
if TukuiHUD_WarlockSpecBar then TukuiHUD_WarlockSpecBar:HookScript("OnUpdate", function()
		if UnitAffectingCombat("player") or hideooc == false then
			local spec = GetSpecialization()
			TukuiHUD_Player_WarlockSpecBars1:SetHeight(((hud_height - 4) - 3)/4)
			TukuiHUD_Player_WarlockSpecBars2:SetHeight(((hud_height - 4) - 3)/4)
			TukuiHUD_Player_WarlockSpecBars3:SetHeight(((hud_height - 4) - 3)/4)
			TukuiHUD_Player_WarlockSpecBars4:SetHeight(((hud_height - 4) - 3)/4)
			TukuiHUD_Player_WarlockSpecBars1:SetWidth(hud_width-8)
			TukuiHUD_Player_WarlockSpecBars2:SetWidth(hud_width-8)
			TukuiHUD_Player_WarlockSpecBars3:SetWidth(hud_width-8)
			TukuiHUD_Player_WarlockSpecBars4:SetWidth(hud_width-8)
			if spec == SPEC_WARLOCK_AFFLICTION or spec == SPEC_WARLOCK_DESTRUCTION then 
				TukuiHUD_Player_WarlockSpecBars1:SetWidth(hud_width-8)
				TukuiHUD_Player_WarlockSpecBars2:SetWidth(hud_width-8)
				TukuiHUD_Player_WarlockSpecBars3:SetWidth(hud_width-8)
				TukuiHUD_Player_WarlockSpecBars4:SetWidth(hud_width-8)
				if not TukuiHUD_Player_WarlockSpecBars2:IsShown() then
					TukuiHUD_Player_WarlockSpecBars2:Show()
					TukuiHUD_Player_WarlockSpecBars3:Show()
					TukuiHUD_Player_WarlockSpecBars4:Show()
				end
			end
			if spec == SPEC_WARLOCK_DEMONOLOGY then 
				TukuiHUD_Player_WarlockSpecBars1:SetHeight(hud_height-4)
			end
		end
	end)
end