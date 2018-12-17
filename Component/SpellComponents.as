#include "SpellCommon.as";
#include "RenderCommon.as";
#include "Hitters.as";

string[] componentNames = 
{
    "SirenSong",
    "Brick",
    "Crystal",
    "Boomerang",
    "Seashell",
    "Quicksilver",
    "TruthPrism",
    "Gunpowder",
    "FairyDust",
    "SpiderSilk",
    "DarkMatter",
    "Shield",
    "CruelSun",
    "Catalyst",
    "PhaseFlower"
};

shared SpellComponent@ GetComponentFromString(string componentName, int grade)
{
    componentName = componentName.toUpper();

    if (SirenSongComponent(grade).ComponentID().toUpper() == componentName)
    {
        return SirenSongComponent(grade);
    }

    if (BrickComponent(grade).ComponentID().toUpper() == componentName)
    {
        return BrickComponent(grade);
    }

    if (CrystalComponent(grade).ComponentID().toUpper() == componentName)
    {
        return CrystalComponent(grade);
    }

    if (BoomerangComponent(grade).ComponentID().toUpper() == componentName)
    {
        return BoomerangComponent(grade);
    }

    if (SeashellComponent(grade).ComponentID().toUpper() == componentName)
    {
        return SeashellComponent(grade);
    }

    if (DummySeashellComponent(grade).ComponentID().toUpper() == componentName)
    {
        return DummySeashellComponent(grade);
    }

    if (QuicksilverComponent(grade).ComponentID().toUpper() == componentName)
    {
        return QuicksilverComponent(grade);
    }

    if (TruthPrismComponent(grade).ComponentID().toUpper() == componentName)
    {
        return TruthPrismComponent(grade);
    }

    if (GunpowderComponent(grade).ComponentID().toUpper() == componentName)
    {
        return GunpowderComponent(grade);
    }

    if (FairyDustComponent(grade).ComponentID().toUpper() == componentName)
    {
        return FairyDustComponent(grade);
    }

    if (SpiderSilkComponent(grade).ComponentID().toUpper() == componentName)
    {
        return SpiderSilkComponent(grade);
    }
    
    if (DummySpiderSilkComponent(grade).ComponentID().toUpper() == componentName)
    {
        return DummySpiderSilkComponent(grade);
    }

    if (DarkMatterComponent(grade).ComponentID().toUpper() == componentName)
    {
        return DarkMatterComponent(grade);
    }

    if (ShieldComponent(grade).ComponentID().toUpper() == componentName)
    {
        return ShieldComponent(grade);
    }

    if (CruelSunComponent(grade).ComponentID().toUpper() == componentName)
    {
        return CruelSunComponent(grade);
    }

    if (CatalystComponent(grade).ComponentID().toUpper() == componentName)
    {
        return CatalystComponent(grade);
    }

    if (PhaseFlowerComponent(grade).ComponentID().toUpper() == componentName)
    {
        return PhaseFlowerComponent(grade);
    }

    if (FlameTrailComponent(grade).ComponentID().toUpper() == componentName)
    {
        return FlameTrailComponent(grade);
    }

    if (TestComponent(grade).ComponentID().toUpper() == componentName)
    {
        return TestComponent(grade);
    }
    
    return null;
}

shared class SirenSongComponent : SpellComponent
{
    float xWiggleMod;
    float yWiggleMod;
    Vec2f oldWiggleVel;

    SirenSongComponent(int g)
    {
        super(g);
    }

    void OnCreate(Spell@ spell) override
    {
        oldWiggleVel = Vec2f(0.0f, 0.0f);

        float startAngle = spell.spellBlob.getAngleDegrees() * Maths::Pi / 180.0f;
        xWiggleMod = Maths::Sin(startAngle);
        yWiggleMod = Maths::Cos(startAngle);
    }

    bool Update(Spell@ spell) override
    {
        Vec2f vel = spell.spellBlob.getVelocity();
        float angle = spell.age * Maths::Pi / 12.0f;
        Vec2f wiggleVel(xWiggleMod * (1.5f * grade + 5) * Maths::Cos(angle), yWiggleMod * (1.5f * grade + 5) * Maths::Sin(angle));
        spell.spellBlob.setVelocity(vel + wiggleVel - oldWiggleVel);
        oldWiggleVel = wiggleVel;
        return false;
    }

    float Damage() override
    {
        return 0.25f * (grade + 1);
    }

    float DamageMult() override
    {
        return 1.0f + 0.025f * grade;
    }

    string ComponentID() override
    {
        return "SirenSong";
    }

    SpellComponent@ Copy() override
    {
        return SirenSongComponent(grade);
    }
}

shared class BrickComponent : SpellComponent
{

    BrickComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell)
    {
        spell.spellBlob.setVelocity(spell.spellBlob.getVelocity() + Vec2f(0.0f, (grade + 1) / 20.0f));
        return false;
    }

    float Damage() override
    {
        return 0.25f * (grade + 1);
    }

    float DamageMult() override
    {
        return 1.0f + 0.025f * grade;
    }

    string ComponentID() override
    {
        return "Brick";
    }

    SpellComponent@ Copy() override
    {
        return BrickComponent(grade);
    }
}

shared class CrystalComponent : SpellComponent
{
    Vec2f oldDif(0.0f, 0.0f);

    CrystalComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        int teamNum = spell.spellBlob.getTeamNum();
        Vec2f pos = spell.spellBlob.getPosition();
        CBlob@[] blobsToCheck;
        if (getMap().getBlobsInRadius(pos, 150.0f, @blobsToCheck))
        {
            CBlob@ target;
            float minDistance = 1000000.0f;
            for (int i = 0; i < blobsToCheck.length; i++)
            {
                float dist = (blobsToCheck[i].getPosition() - pos).getLength();
                if (dist < minDistance && blobsToCheck[i].getTeamNum() != teamNum && blobsToCheck[i].hasTag("player"))
                {
                    @target = @blobsToCheck[i];
                    minDistance = dist;
                }
            }
            if (target is null)
            {
                return false;
            }
            Vec2f dif = (target.getPosition() - pos);
            dif.Normalize();
            dif *= 2.0f + grade * 0.125f;
            spell.spellBlob.setVelocity(spell.spellBlob.getVelocity() + dif - oldDif);
            dif *= 0.75f;
            oldDif = dif;
        }
        return false;
    }

    string ComponentID() override
    {
        return "Crystal";
    }

    SpellComponent@ Copy() override
    {
        return CrystalComponent(grade);
    }
}

shared class BoomerangComponent : SpellComponent
{
    BoomerangComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        spell.spellBlob.setVelocity(spell.spellBlob.getVelocity().RotateBy(1.5f * (grade + 2)));
        return false;
    }

    string ComponentID() override
    {
        return "Boomerang";
    }

    SpellComponent@ Copy() override
    {
        return BoomerangComponent(grade);
    }

    float Damage() override
    {
        return 0.25f * (grade + 1);
    }

    float DamageMult() override
    {
        return 1.0f + 0.025f * grade;
    }
}

shared class SeashellComponent : SpellComponent
{
    SeashellComponent(int g)
    {
        super(g);
    }
    
    void OnDeath(Spell@ spell) override
    {
        if (!isServer())
        {
            return;
        }

        for (int i = 0; i < spell.spellComponents.length; i++)
        {
            if (spell.spellComponents[i].ComponentID() == "FairyDust")
            {
                return;
            }
        }

        int team = spell.spellBlob.getTeamNum();

        Vec2f pos = spell.spellBlob.getPosition();

        int amt = (3 + grade / 2 > 7 ? 7 : 3 + grade / 2);

        float angleChange = 360.0f / amt;
        float angle = spell.spellBlob.getAngleDegrees();

        string[] filter = { ComponentID() };
        SpellComponent@[] cs = CopyComponentsFiltered(spell.spellComponents, filter);
        cs.push_back(@DummySeashellComponent(grade));
        
        for (int i = 0; i < amt; i++)
        {
            Spell newSpell(pos, angle, team, CopyComponents(cs));
            angle += angleChange;
        }
    }

    string ComponentID() override
    {
        return "Seashell";
    }

    SpellComponent@ Copy() override
    {
        return SeashellComponent(grade);
    }
}

shared class DummySeashellComponent : SpellComponent
{
    DummySeashellComponent(int g)
    {
        super(g);
    }

    int MaxAge() override
    {
        return 5 * (grade + 1) - 30 > 0 ? 0 : 5 * (grade + 1) - 30;
    }

    string ComponentID() override
    {
        return "DummySeashell";
    }

    SpellComponent@ Copy() override
    {
        return DummySeashellComponent(grade);
    }
}

shared class QuicksilverComponent : SpellComponent
{
    QuicksilverComponent(int g)
    {
        super(g);
    }

    float StartVelocity() override
    {
        return 0.5f * (grade + 1);
    }

    string ComponentID() override
    {
        return "Quicksilver";
    }

    SpellComponent@ Copy() override
    {
        return QuicksilverComponent(grade);
    }
}

shared class TruthPrismComponent : SpellComponent
{
    TruthPrismComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices)
    {
        int teamNum = spell.spellBlob.getTeamNum();
        float radius = 5.0f * (grade + 2);
        
        CBlob@[] blobsToCheck;
        if (getMap().getBlobsInRadius(spell.spellBlob.getPosition(), radius, @blobsToCheck))
        {
            SColor col(0x77ffff00);
            for (int i = 0; i < blobsToCheck.length; i++)
            {
                CBlob@ blob = blobsToCheck[i];
                if (blob.getTeamNum() != teamNum && blob.hasTag("player"))
                {
                    AddCircle(@verts, @indices, blob.getInterpolatedPosition(), blob.getRadius() + 2.5f, 600.0f, col, 24);
                }
            }
        }
    }

    string ComponentID() override
    {
        return "TruthPrism";
    }

    SpellComponent@ Copy() override
    {
        return TruthPrismComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }

    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class GunpowderComponent : SpellComponent
{
    GunpowderComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {
    }

    void OnDeath(Spell@ spell) override
    {
        if (!isServer())
        {
            return;
        }

        int teamNum = spell.spellBlob.getTeamNum();
        float radius = 2.5f * (grade + 8);
        CBlob@[] blobsToCheck;
        if (getMap().getBlobsInRadius(spell.spellBlob.getPosition(), radius, @blobsToCheck))
        {
            for (int i = 0; i < blobsToCheck.length; i++)
            {
                CBlob@ blob = blobsToCheck[i];
                if (blobsToCheck[i].getTeamNum() != teamNum && blobsToCheck[i].hasTag("player"))
                {
                    spell.spellBlob.server_Hit(blob, blob.getPosition(), Vec2f(0.0f, 0.0f), spell.Damage(), Hitters::nothing);
                }
            }
        }
    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices)
    {
        if (spell.MaxAge() <= 0)
        {
            return;
        }

        Vec2f pos = spell.spellBlob.getInterpolatedPosition();
        float radius = 2.5f * (grade + 8);
        SColor col(245 * spell.age / spell.MaxAge(), 255, 0, 0);
        AddCircle(@verts, @indices, pos, radius, 600.0f, col, 24);
    }

    string ComponentID() override
    {
        return "Gunpowder";
    }

    SpellComponent@ Copy() override
    {
        return GunpowderComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }

    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class FairyDustComponent : SpellComponent
{
    FairyDustComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        // die on spawn
        return true;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {
        string[] filter = { ComponentID() };
        SpellComponent@[] cs = CopyComponentsFiltered(spell.spellComponents, filter);

        int amt = grade + 2 > 7 ? 7 : grade + 2;
        
        Vec2f pos = spell.spellBlob.getPosition();
        int teamNum = spell.spellBlob.getTeamNum();
        float angle = spell.spellBlob.getAngleDegrees() - 40.0f;
        float angleChange = 80.0f / (amt - 1);

        for (int i = 0; i < amt; i++)
        {
            Spell newSpell(pos, angle, teamNum, CopyComponents(cs));
            angle += angleChange;
        }
    }

    string ComponentID() override
    {
        return "FairyDust";
    }

    SpellComponent@ Copy() override
    {
        return FairyDustComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class SpiderSilkComponent : SpellComponent
{
    SpiderSilkComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        if (spell.age % 6 == 0)
        {
            Vec2f pos = spell.spellBlob.getPosition();
            float angle = spell.spellBlob.getAngleDegrees();
            int team = spell.spellBlob.getTeamNum();

            string[] filter = { ComponentID(), "Seashell" };
            SpellComponent@[] cs = CopyComponentsFiltered(spell.spellComponents, filter);
            cs.push_back(DummySpiderSilkComponent(grade));

            Spell newSpell(pos, angle, team, cs);
        }
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {

    }

    string ComponentID() override
    {
        return "SpiderSilk";
    }

    SpellComponent@ Copy() override
    {
        return SpiderSilkComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class DummySpiderSilkComponent : SpellComponent
{
    DummySpiderSilkComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {

    }

    string ComponentID() override
    {
        return "DummySpiderSilk";
    }

    SpellComponent@ Copy() override
    {
        return DummySpiderSilkComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return -3.5f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 5 * (grade + 1) - 30 > 0 ? 0 : 5 * (grade + 1) - 30;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class DarkMatterComponent : SpellComponent
{
    DarkMatterComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        Vec2f pos = spell.spellBlob.getPosition();
        int team = spell.spellBlob.getTeamNum();
        CBlob@[] blobsToCheck;
        if (getMap().getBlobsInRadius(pos, 3.5f * (grade + 7), @blobsToCheck))
        {
            for (int i = 0; i < blobsToCheck.length; i++)
            {
                if (blobsToCheck[i].getTeamNum() != team && blobsToCheck[i].hasTag("player"))
                {
                    Vec2f posDif = pos - blobsToCheck[i].getPosition();
                    posDif.Normalize();
                    blobsToCheck[i].setVelocity(blobsToCheck[i].getVelocity() + posDif);
                }
            }
        }
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {
        AddCircle(@verts, @indices, spell.spellBlob.getInterpolatedPosition(), 3.5f * (grade + 7), 600.0f, SColor(0x77000000), 24);
    }

    string ComponentID() override
    {
        return "DarkMatter";
    }

    SpellComponent@ Copy() override
    {
        return DarkMatterComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class ShieldComponent : SpellComponent
{
    ShieldComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        Vec2f pos = spell.spellBlob.getPosition();
        int team = spell.spellBlob.getTeamNum();
        CBlob@[] blobsToCheck;
        if (getMap().getBlobsInRadius(pos, 3.5f * (grade + 7), @blobsToCheck))
        {
            for (int i = 0; i < blobsToCheck.length; i++)
            {
                if (blobsToCheck[i].getTeamNum() != team && blobsToCheck[i].hasTag("player"))
                {
                    Vec2f posDif = blobsToCheck[i].getPosition() - pos;
                    posDif.Normalize();
                    blobsToCheck[i].setVelocity(blobsToCheck[i].getVelocity() + posDif);
                }
            }
        }
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {
        AddCircle(@verts, @indices, spell.spellBlob.getInterpolatedPosition(), 3.5f * (grade + 7), 600.0f, SColor(0x77ffffff), 24);
    }

    string ComponentID() override
    {
        return "Shield";
    }

    SpellComponent@ Copy() override
    {
        return ShieldComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class CruelSunComponent : SpellComponent
{
    CruelSunComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        if (!isServer())
        {
            return false;
        }

        Vec2f pos = spell.spellBlob.getPosition();
        int team = spell.spellBlob.getTeamNum();

        CBlob@[] blobsToCheck;
        if (getMap().getBlobsInRadius(pos, 5.0f * (grade + 6), @blobsToCheck))
        {
            for (int i = 0; i < blobsToCheck.length; i++)
            {
                if (blobsToCheck[i].getTeamNum() != team && blobsToCheck[i].hasTag("player"))
                {
                    spell.spellBlob.server_Hit(blobsToCheck[i], blobsToCheck[i].getPosition(), Vec2f(0.0f, 0.0f), spell.Damage() / 60.0f, Hitters::nothing);
                }
            }
        }
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {
        AddGradientCircle(@verts, @indices, spell.spellBlob.getInterpolatedPosition(), 5.0f * (grade + 6), 600.0f, SColor(0x77ff0000), SColor(0x77ffdd00), 24);
    }

    string ComponentID() override
    {
        return "CruelSun";
    }

    SpellComponent@ Copy() override
    {
        return CruelSunComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class CatalystComponent : SpellComponent
{
    CatalystComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {

    }

    string ComponentID() override
    {
        return "Catalyst";
    }

    SpellComponent@ Copy() override
    {
        return CatalystComponent(grade);
    }

    float Damage() override
    {
        return 0.1f * (grade + 1);
    }

    float DamageMult() override
    {
        return 1.0f + 0.035f * grade;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class PhaseFlowerComponent : SpellComponent
{
    PhaseFlowerComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {

    }

    string ComponentID() override
    {
        return "PhaseFlower";
    }

    SpellComponent@ Copy() override
    {
        return PhaseFlowerComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0 + 0.065f * (grade + 1);
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }

    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return false;
    }
}

shared class FlameTrailComponent : SpellComponent
{
    Vec2f[] positions;
    float[] angles;

    int trailLength = 61;

    FlameTrailComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {
        Vec2f pos = spell.spellBlob.getInterpolatedPosition();
        float angle = spell.spellBlob.getVelocity().getAngleDegrees();
        for (int i = 0; i < trailLength; i++)
        {
            positions.push_back(pos);
            angles.push_back(angle);
        }
    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {
        positions.push_back(spell.spellBlob.getInterpolatedPosition());
        angles.push_back(spell.spellBlob.getVelocity().getAngleDegrees());

        if (positions.length > trailLength)
        {
            positions.removeAt(0);
        }
        
        if (angles.length > trailLength)
        {
            angles.removeAt(0);
        }

        uint16 startIdx = verts.length;

        float z = 600.0f;
        Vec2f uv(0.0f, 0.0f);

        for (int i = positions.length - 1; i >= 0; i--)
        {
            Vec2f offset(5.0f, 0.0f);
            offset.RotateBy(-angles[i] - 90);
            SColor col(127, 255, 250 - i * 4, 0);
            verts.push_back(Vertex(positions[i] + offset, z, uv, col));
            verts.push_back(Vertex(positions[i] - offset, z, uv, col));
        }

        for (int i = positions.length - 1; i >= 0; i -= 2)
        {
            if (i < 0)
            {
                continue;
            }

            indices.push_back(startIdx + i);
            indices.push_back(startIdx + i + 1);
            indices.push_back(startIdx + i + 2);

            indices.push_back(startIdx + i + 1);
            indices.push_back(startIdx + i + 2);
            indices.push_back(startIdx + i + 3);
        }
    }

    string ComponentID() override
    {
        return "FlameTrail";
    }

    SpellComponent@ Copy() override
    {
        return FlameTrailComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }

    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}

shared class TestComponent : SpellComponent
{
    TestComponent(int g)
    {
        super(g);
    }

    bool Update(Spell@ spell) override
    {
        return false;
    }

    void OnCreate(Spell@ spell) override
    {

    }

    void OnDeath(Spell@ spell) override
    {

    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices) override
    {
        float perc = (100.0f * spell.age) / (100.0f * spell.MaxAge());
        float oRadius = 48.0f;
        float iRadius = oRadius * perc;
        AddGradientCircle(@verts, @indices, spell.spellBlob.getInterpolatedPosition(), iRadius, 600.0f, SColor(0x77ffffff), SColor(0x77000000), 24);
        AddGradientHollowCircle(@verts, @indices, spell.spellBlob.getInterpolatedPosition(), iRadius, oRadius, 600.0f, SColor(0x77000000), SColor(0x77ffffff), 24);
    }

    string ComponentID() override
    {
        return "Test";
    }

    SpellComponent@ Copy() override
    {
        return TestComponent(grade);
    }

    float Damage() override
    {
        return 0.0f;
    }

    float DamageMult() override
    {
        return 1.0f;
    }

    float StartVelocity() override
    {
        return 0.0f;
    }

    float StartVelocityMult() override
    {
        return 1.0f;
    }

    int MaxAge() override
    {
        return 0;
    }

    int MaxAgeMult() override
    {
        return 1;
    }
    
    bool Hits(Spell@ spell, CBlob@ blob) override
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }
}