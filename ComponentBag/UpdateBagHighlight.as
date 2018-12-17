void onAddToInventory(CBlob@ this, CBlob@ blob)
{
    UpdateBag(this);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
    UpdateBag(this);
}

void UpdateBag(CBlob@ blob)
{
    CRules@ rules = getRules();
    if (rules !is null)
    {
        CBitStream stream;
        stream.write_netid(blob.getNetworkID());

        rules.SendCommand(rules.getCommandID("highlight bag"), stream);
    }
}