function FHH_MinimapDrag_OnUpdate(arg1)
	local db = _G['HuntersHelperDB']
	local xPos, yPos = GetCursorPosition();
	local xMin, yMin = Minimap:GetLeft(), Minimap:GetBottom();

	xPos = xMin - xPos / UIParent:GetScale() + 70;
	yPos = yPos / UIParent:GetScale() - yMin - 70;

	db.MinimapButtonPosition = math.deg(math.atan2(yPos, xPos));
	FHH_MoveMinimapButton();
end

function FHH_MoveMinimapButton()
	local db = _G['HuntersHelperDB']
	local xPos = 52 - (80 * math.cos(math.rad(db.MinimapButtonPosition or 260 + 90)));
	local yPos = (80 * math.sin(math.rad(db.MinimapButtonPosition or 260 + 90))) - 52;
	FHH_MinimapFrame:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", xPos, yPos);
end

function FHH_MinimapShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = FHH_MinimapShineFadeOut;
	UIFrameFade(FHH_MinimapShine, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function FHH_MinimapShineFadeOut()
	UIFrameFadeOut(FHH_MinimapShine, 0.5);
end
