#include "SpellCommon.as";

void onInit(CBlob@ this)
{
    this.Tag("sawed"); // sawproofing
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
    if (!isServer())
    {
        return;
    }

    if (blob is null)
    {
        return;
    }

    if (blob.getName() != "component")
    {
        this.server_PutOutInventory(blob);
        return;
    }

    SpellComponent@ component;

    blob.get("component object", @component);
    if (component is null)
    {
        this.server_PutOutInventory(blob);
        return;
    }
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
    this.inventoryIconFrame = 0;
    CSprite@ sprite = this.getSprite();
    if (sprite is null)
    {
        return;
    }
    sprite.SetFrame(0);
}