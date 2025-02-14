local XC    = XelosesContacts
local CONST = XC.CONST
local L     = XC.getString
local T     = type

-- --------------------
--  @SECTION Update SV
-- --------------------

function XC:UpdateConfig()
    if (self.config.v >= self.version) then return end

    if (not self.config.v or self.config.v < 10103) then
        -- @since 1.0.3
        -- Update contact groups table structure
        for category_id, _ in ipairs(CONST.CONTACTS_CATEGORIES) do
            for i, group in ipairs(self.config.groups[category_id]) do
                if (T(group) == "string") then
                    local group_name = not group:isEmpty() and group or L(("GROUP_%d%d"):format(category_id, i)) or L("GROUP_NEW")
                    self.config.groups[category_id][i] = {
                        id = i,
                        name = group_name,
                        icon = self.defaults.groups[category_id][i].icon,
                    }
                end
            end
            -- remove old indexes
            self.config.groups[category_id] = table:new(self.config.groups[category_id]):values()
        end
    end

    -- Update version
    self.config.v = self.version
end
