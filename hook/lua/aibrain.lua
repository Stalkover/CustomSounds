OLDAIBrain = AIBrain

AIBrain = Class(OLDAIBrain) {
    -- System for playing VOs to the Player
    VOSounds = {
        -- {timeout delay, default cue, observers}
        NuclearLaunchDetected =        {timeout = 1, bank = nil, obs = true},
        OnTransportFull =              {timeout = 1, bank = nil},
        OnFailedUnitTransfer =         {timeout = 10, bank = 'Computer_Computer_CommandCap_01298'},
        OnPlayNoStagingPlatformsVO =   {timeout = 5, bank = 'XGG_Computer_CV01_04756'},
        OnPlayBusyStagingPlatformsVO = {timeout = 5, bank = 'XGG_Computer_CV01_04755'},
        OnPlayCommanderUnderAttackVO = {timeout = 15, bank = 'Test1234'}, --Computer_Computer_Commanders_01314'},
    },

    PlayVOSound = function(self, string, sound)
        if not self.VOTable then self.VOTable = {} end

        local VO = self.VOSounds[string]
        if not VO then
            WARN('PlayVOSound: ' .. string .. " not found")
            return
        end

        if not self.VOTable[string] and VO['obs'] and GetFocusArmy() == -1 and self:GetArmyIndex() == 1 then
            -- Don't stop sound IF not repeated AND sound is flagged as 'obs' AND i'm observer AND only from PlayerIndex = 1
        elseif self.VOTable[string] or GetFocusArmy() ~= self:GetArmyIndex() then
            return
        end

        local cue, bank
        if sound then
            cue, bank = GetCueBank(sound)
        else
            cue, bank = VO['bank'], 'XGG'
        end

        if not (bank and cue) then
            WARN('PlayVOSound: No valid bank/cue for ' .. string)
            return
        end

        self.VOTable[string] = true
        table.insert(Sync.Voice, {Cue = cue, Bank = bank})

        local timeout = VO['timeout']
        ForkThread(function()
            WaitSeconds(timeout)
            self.VOTable[string] = nil
        end)
    end,

}