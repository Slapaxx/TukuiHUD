local T, C, L = unpack(Tukui)
TukuiHudCF = {
	enabled = true,
	powerhud = true, -- show the power bar in the hud
	pethud = true, -- show the pet hud
	tothud = false, -- show the target of target hud
	focushud = false, -- show the focus hud
	showthreat = true, -- show a threat bar next to the players hud
	classspecificbars = true, -- show class specific bars (rune bar, totem bar, eclipse bar, etc.)
	showvalues = true, -- show text values
	unicolor = false, -- use a unicolor them
	flash = true, -- flash a warning
	warningText = true, -- show warning text when a bar is flashing
	lowThreshold = 35, -- flash health and mana bars below this %
	showsmooth = true, -- show smooth bars
	hideooc = true, -- hide the hud out of combat
	height = 150, -- height of the HUD
	width = 15, -- width of the HUD
	offset = 150, -- offset from the center in pixels
	font = C["media"].font,
	fontsize = 12,
	alpha = 1, -- alpha value of the HUD when fully visible
	oocalpha = 0, -- alpha value of the HUD when hidden out of combat if hideooc is true
}

