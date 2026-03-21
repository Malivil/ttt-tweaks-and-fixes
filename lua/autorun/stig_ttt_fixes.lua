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

hook.Add("TTTPrepareRound", "StigTTTFixes", function()
    FixVisibleSpectators()
    timer.Simple(0.1, FixVisibleSpectators)

    timer.Create("StigTTTFixesVisibleSpectators", 1, 4, function()
        FixVisibleSpectators()
    end)
end)

-- Fixes an error with the prone mod, when using a playermodel without a head bone
if CLIENT then
    hook.Add("InitPostEntity", "StigTTTFixes", function()
        local oldCalcView = hook.GetTable()["CalcView"]["prone.ViewTransitions"]

        if oldCalcView then
            hook.Add("CalcView", "prone.ViewTransitions", function(ply, ...)
                if not ply:LookupBone("ValveBiped.Bip01_Head1") then return end

                return oldCalcView(ply, ...)
            end)
        end
    end)
end