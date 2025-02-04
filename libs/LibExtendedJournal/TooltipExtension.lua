LibExtendedJournal.TOOLTIP_VERSION = 4


--------------------------------------------------------------------------------
-- ExtendedJournalTooltipExtension
--------------------------------------------------------------------------------

ExtendedJournalTooltipExtension = ZO_Object:Subclass()
local ExtendedJournalTooltipExtension = ExtendedJournalTooltipExtension

function ExtendedJournalTooltipExtension:New( name )
	local obj = ZO_Object.New(self)

	obj.name = "ExtendedJournalTooltipExtension_" .. name
	obj.control = WINDOW_MANAGER:CreateControlFromVirtual(obj.name, GuiRoot, "ExtendedJournalTooltipExtension")
	obj.sections = { obj.control:GetNamedChild("Section") }
	obj.index = 1

	return obj
end

function ExtendedJournalTooltipExtension:GetSection( )
	local sections = self.sections
	local index = self.index
	self.index = index + 1

	-- Create new sections lazily, only as needed
	while (index > #sections) do
		local section = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Section" .. tostring(#sections + 1), self.control, "ExtendedJournalTooltipSection")
		section:SetAnchor(TOPLEFT, sections[#sections], BOTTOMLEFT, 0, 12)
		section:SetAnchor(RIGHT, nil, nil, nil, nil, ANCHOR_CONSTRAINS_X)
		table.insert(sections, section)
	end
	return sections[index]
end

function ExtendedJournalTooltipExtension:Initialize( showDivider, textLeft, textRight )
	local control = self.control
	control:GetNamedChild("Divider"):SetHidden(not showDivider)
	control:GetNamedChild("Left"):SetText(textLeft or "")
	control:GetNamedChild("Right"):SetText(textRight or "")
	self.index = 1
	return self
end

function ExtendedJournalTooltipExtension:AddSection( textHeader, textBody, alignBody )
	local control = self:GetSection()
	control:GetNamedChild("Header"):SetText(textHeader or "")
	control:GetNamedChild("Body"):SetText(textBody or "")
	control:GetNamedChild("Body"):SetHorizontalAlignment(alignBody or TEXT_ALIGN_CENTER)
	control:SetHidden(false)
end

function ExtendedJournalTooltipExtension:Finalize( tooltipControl, showEmpty )
	local control = self.control
	local sections = self.sections
	local index = self.index

	-- Only show if sections were added, unless showEmpty is specified
	if (index > 1 or showEmpty) then
		-- Hide remaining unused sections
		for i = index, #sections do
			sections[i]:SetHidden(true)
		end
		tooltipControl:AddControl(control)
		control:SetAnchor(TOP)
	end
end
