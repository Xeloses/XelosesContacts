local L = XelosesContacts.getString
local T = type

-- --------------------
--  @SECTION Update SV
-- --------------------

function XelosesContacts:UpdateConfig(default_settings)
    if (self.config.v and self.config.v >= self.version) then return end

    if (not self.config.v or self.config.v < 10200) then
        -- @since 1.2.0
        -- ============
        -- Update contact groups table structure
        for category_id, _ in ipairs(self.CONST.CONTACTS_CATEGORIES) do
            for i, group in ipairs(self.config.groups[category_id]) do
                if (T(group) == "string") then
                    local group_name =
                        (not group:isEmpty() and group) or
                        (default_settings.groups[category_id][i] and default_settings.groups[category_id][i].name) or
                        L("GROUP_NEW")

                    self.config.groups[category_id][i] = {
                        id   = i,
                        name = group_name,
                        icon = default_settings.groups[category_id][i].icon,
                    }
                end

                if (category_id == self.CONST.CONTACTS_VILLAINS_ID and self.config.chat and self.config.chat.block_groups) then
                    local block_chat = (self.config.chat.block_groups[i] == true)
                    self.config.groups[category_id][i].mute = block_chat
                end
            end

            -- remove old indexes
            self.config.groups[category_id] = table:new(self.config.groups[category_id]):values()
        end

        -- remove old chat blocking settings for contact groups
        self.config.chat.block_groups = nil
    elseif (self.config.v < 10204) then
        -- @since 1.2.4
        -- ============
        -- Reticle marker: added "Display mode" option; removed "Show icon" option.
        if (self.config.reticle) then
            if (self.config.reticle.icon and self.config.reticle.icon.enabled ~= nil) then
                self.config.reticle.mode = self.config.reticle.icon.enabled and XelosesReticleMarker.DISPLAY_MODE.FULL or XelosesReticleMarker.DISPLAY_MODE.TEXT
                self.config.reticle.icon.enabled = nil
            else
                self.config.reticle.mode = XelosesReticleMarker.DISPLAY_MODE.FULL
            end
        end
    end

    -- Update version
    self.config.v = self.version
end
