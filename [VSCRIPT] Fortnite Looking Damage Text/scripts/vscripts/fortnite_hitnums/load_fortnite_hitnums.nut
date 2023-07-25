//================================================================================================================================
// TF2 VSCRIPT - Fortnite Looking Damage Text (v1.0)
// Made by ShakSheep, Inspired by butare's CSGO Server Plugin version
// DEMO VIDEO: https://www.youtube.com/watch?v=Qqdx3fcDhQM
//================================================================================================================================

// ======== Put this command in console to load in any map ======== //
// script_execute fortnite_hitnums/load_fortnite_hitnums
// ======== Put this command in console to debug. NOTE: only do this if you know what you are doing!!! ======== //
// script_execute fortnite_hitnums/load_fortnite_hitnums;script GetListenServerHost().ShowFortniteDamage(GetListenServerHost(), 9999, true);

PrecacheModel("materials/particles/fortnite/hitnums/nums_bw.vmt");
::CTFPlayer.ShowFortniteDamage <- function(attacker, damage, crit, radius, debugMode) {

	// BUG: first number 4 digit damage amounts doesn't line up properly.
	// TODO: damage number adding overtime.
	
	local victim = this;
	if (!victim.IsInvulnerable() && attacker != victim)
	{
		local x = RandomInt(-10, 10);
		local y = RandomInt(-10, 10);
		local z = RandomInt(80, 90);
		
		local amtSize = damage.tostring().len();
		local entInRadius = GetEntitiesInRadius(attacker, victim, 700.0);
		
		if (debugMode)
			DebugDrawCircle(attacker.GetOrigin(), Vector(255,255,0), 255, radius, false, 1.0);
		
		for (local i = (amtSize - 1); i >= 0; i--)
		{
			local eyeAng = attacker.EyeAngles();
			local attackerPos = attacker.EyePosition() + eyeAng.Forward() * 600 + Vector(0, 0, -60);

			local testNum = ("fortnite_" + (crit ? "crit" : "def") + "_num" + (damage.tostring().slice(i, (i + 1))) + "_f" + (i > (amtSize / 2 - 1) ? "l" : "r"));
			local fnDmg = SpawnParticle(testNum, ((entInRadius ? victim.GetOrigin() : attackerPos) + (eyeAng.Left() * ((i > (amtSize / 2 - 1)) ? (5.5 * i) : 0.0)) + Vector(x, y, z)), "", "head", true); // local fnDmg = 
			fnDmg.SetOwner(attacker);
			// printl(i);
		}
	}
}
// ::CTFBot.ShowFortniteDamage <- CTFPlayer.ShowFortniteDamage;


::SpawnParticle <- function(strName, intOrigin, strParentName = "", strParentAttachment = "", keepEntity = true) {

	local effect = SpawnEntityFromTable("info_particle_system",
	{
		effect_name	 	= strName,
		start_active 	= true,
		origin 			= intOrigin,
	});
	
	EntFireByHandle(effect, "SetParent", strParentName, 0, null, null);
	EntFireByHandle(effect, "SetParentAttachment", strParentAttachment, 0, null, null);
	
	if (!keepEntity && effect.IsValid())
		effect.Kill();
	
	return effect;
}
::GetEntitiesInRadius <- function(client, target, dist) {

	local clientPos = client.GetOrigin();
    local entity = null;
    while (null != (entity = Entities.FindInSphere(entity, clientPos, dist)))
    {
        if (entity == target)
			return true;
	}
	return false;
}


function OnPlayerHurt(event) {

	local victim = GetPlayerFromUserID(event["userid"]);
	local attacker = GetPlayerFromUserID(event["attacker"]);
	
	if (!victim || !attacker)
		return;
	
	// BUG: Damage Text still appear despite not looking at someone from a far distance.
	victim.ShowFortniteDamage(attacker, event["damageamount"], (event["crit"] || event["minicrit"]), 700, false);
}
::OnGameEvent_player_hurt <- OnPlayerHurt.bindenv(this);
__CollectGameEventCallbacks(this);
