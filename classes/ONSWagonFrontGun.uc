//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSWagonFrontGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<ShockBeamEffect> BeamEffectClass;
var ONSSkyMine ComboTarget;
var float MinAim;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'XEffectMat.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flash');
    L.AddPrecacheMaterial(Material'XEffectMat.purple_line');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_a');
    L.AddPrecacheMaterial(Material'XWeapons_rc.ShockBeamTex');
    L.AddPrecacheMaterial(Material'XEffects.SaDScorcht');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core_low');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.EclipseCircle');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flash');
    Level.AddPrecacheMaterial(Material'XEffectMat.purple_line');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_a');
    Level.AddPrecacheMaterial(Material'XWeapons_rc.ShockBeamTex');
    Level.AddPrecacheMaterial(Material'XEffects.SaDScorcht');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core_low');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.EclipseCircle');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	if (ComboTarget != None && Vehicle(Instigator).bWeaponIsAltFiring)
		return 1;
	else
		return 0;
}

function rotator AdjustAim(bool bAltFire)
{
	if (bAltFire && ComboTarget != None)
		return rotator(ComboTarget.Location - WeaponFireLocation);

	return Super.AdjustAim(bAltFire);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None; // prevents client side repositioning of beam start
    Beam.AimAt(HitLocation, HitNormal);
}

function SetComboTarget(ONSSkyMine S)
{
	if (Bot(Instigator.Controller) == None || Instigator.Controller.Enemy == None)
		return;

	ComboTarget = S;
	ComboTarget.Monitor(Bot(Instigator.Controller).Enemy);
}

function DoCombo()
{
	if (Vehicle(Instigator) != None && Instigator.Controller != None)
	{
		Instigator.StopWeaponFiring();
		Vehicle(Instigator).bWeaponIsAltFiring = true;
	}
}

state InstantFireMode
{
    simulated function ClientSpawnHitEffects()
    {
    }

    function SpawnHitEffects(Actor HitActor, vector HitLocation, vector HitNormal)
    {
    }

    function AltFire(Controller C)
    {
        local float CurAim, BestAim;
        local int x;
        local Projectile BestMine;

        ShakeView();
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(AltFireSoundClass, SLOT_None, AltFireSoundVolume/255.0,, AltFireSoundRadius,, False);

	//aiming help for hitting skymines
	BestAim = MinAim;
	for (x = 0; x < Projectiles.length; x++)
	{
		if (Projectiles[x] == None)
		{
			Projectiles.Remove(x, 1);
			x--;
		}
		else
		{
			CurAim = Normal(Projectiles[x].Location - WeaponFireLocation) dot vector(WeaponFireRotation);
			if (CurAim > BestAim)
			{
				BestMine = Projectiles[x];
				BestAim = CurAim;
			}
		}
	}
	if (BestMine != None)
		TraceFire(WeaponFireLocation, rotator(BestMine.Location - WeaponFireLocation));
	else
	        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function Fire(Controller C)
    {
    	local ONSSkyMine S;

    	S = ONSSkyMine(SpawnProjectile(ProjectileClass, False));
    	if (S != None && Bot(Instigator.Controller) != None && (ComboTarget == None || FRand() < 0.4))
        	SetComboTarget(S);
    }
}

defaultproperties
{
     BeamEffectClass=XWeapons.ShockBeamEffect
     MinAim=0.925000
     YawBone="GunRotation"
     PitchBone="GunRotation"
     PitchUpLimit=8000
     PitchDownLimit=62500
     WeaponFireAttachmentBone="GunFire"
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     FireInterval=0.220000
     AltFireInterval=0.220000
     FlashEmitterClass=Onslaught.ONSRVChainGunFireEffect
     FireSoundClass=ONSVehicleSounds-S.Tank.TankMachineGun01
     AltFireSoundClass=ONSVehicleSounds-S.PRV.PRVFire02
     FireForce="MINI GUN"
     AltFireForce="MINI GUN"
     DamageType=Onslaught.DamTypeONSChainGun
     DamageMin=15
     DamageMax=15
     ProjectileClass=Onslaught.ONSSkyMine
     ShakeRotMag=(X=60.000000,Y=20.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000)
     ShakeRotTime=2.000000
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.200000,RefireRate=1.000000)
     AIInfo(1)=(bInstantHit=True,RefireRate=0.000000)
     CullDistance=6000.000000
     Mesh=SkeletalMesh'ONSHellwagon.MiniGun'
     DrawScale=0.800000
}
