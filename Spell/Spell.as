#include "SpellCommon.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
    this.getSprite().ScaleBy(Vec2f(0.5f, 0.5f));
    this.Tag("spell blob");
    this.Tag("sawed"); // sawproofing
    this.getShape().getConsts().rotates = false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
    if (blob is null)
    {
        return;
    }

    Spell@ spell;
    this.get("spell object", @spell);

    if (spell is null || spell.shouldDie)
    {
        return;
    }

    if (blob.getTeamNum() != this.getTeamNum() && blob.getName() == this.getName())
    {
        Spell@ otherSpell;
        blob.get("spell object", @otherSpell);

        if (otherSpell is null || otherSpell.shouldDie)
        {
            return;
        }

        spell.shouldDie = true;
        otherSpell.shouldDie = true;
    }

    if (spell.Hits(blob))
    {
        this.server_Hit(blob, this.getPosition(), Vec2f(0.0f, 0.0f), spell.Damage(), Hitters::nothing);
        spell.shouldDie = true;
        return;
    }
}