-- All non-weapon fixes for various mods on the workshop
-- Weapon fixes reside in stig_ttt_weapon_fixes.lua
if engine.ActiveGamemode() ~= "terrortown" then return end

-- Fixes spectators being visible at the start of the round
local function FixVisibleSpectators()
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsSpec() then
            ply:SetNoDraw(true)
            ply:SetRenderMode(RENDERMODE_TRANSALPHA)
            ply:SetMaterial("models/effects/vol_light001")

            if SERVER then
                ply:Fire("alpha", 0, 0)
            end
        else
            ply:SetNoDraw(false)
            ply:DrawShadow(true)
            ply:SetMaterial("")
            ply:SetRenderMode(RENDERMODE_NORMAL)

            if SERVER then
                ply:Fire("alpha", 255, 0)
            end
        end
    end
end

-- Fix the weapon quick swap mod erroring when trying to swap a weapon without a SWEP.Primary.ClipMax set
local function FixWeaponQuickSwap()
    if not hook.GetTable()["InitPostEntity"]["WQS.QuickSwapInit"] then return end
    SWEP = weapons.GetStored("weapon_base")
    SWEP.OldUseOverride = SWEP.UseOverride

    function SWEP:UseOverride(...)
        if not self.Primary.ClipMax then
            self.Primary.ClipMax = -1
        end

        return self:OldUseOverride(...)
    end
end

local firstRound = true

hook.Add("TTTPrepareRound", "StigTTTFixes", function()
    FixVisibleSpectators()
    timer.Simple(0.1, FixVisibleSpectators)

    timer.Create("StigTTTFixesVisibleSpectators", 1, 4, function()
        FixVisibleSpectators()
    end)

    if firstRound then
        FixWeaponQuickSwap()
        firstRound = false
    end
end)

-- Fixes an error with the prone mod, when using a playermodel without a head bone
if CLIENT then
    hook.Add("InitPostEntity", "StigTTTFixes", function()
        local calcViewHooks = hook.GetTable()["CalcView"]
        if not calcViewHooks then return end
        oldCalcView = calcViewHooks["prone.ViewTransitions"]
        if not oldCalcView then return end

        hook.Add("CalcView", "prone.ViewTransitions", function(ply, ...)
            if not ply:LookupBone("ValveBiped.Bip01_Head1") then return end

            return oldCalcView(ply, ...)
        end)
    end)
end