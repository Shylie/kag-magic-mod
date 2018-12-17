#include "SpellCommon.as";
#include "SpellComponents.as";

void onInit(CBlob@ this)
{
    this.Tag("component blob");
    this.Tag("blacklist random exit vel componentbag");
    this.Tag("sawed"); // sawproofing

    this.addCommandID("select type");
    this.addCommandID("combine");
    this.addCommandID("do nothing");

    AddIconToken("$combine_icon$", "CombineIcon.png", Vec2f(16, 16), 0);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (caller is null)
    {
        return;
    }

    CBlob@ carried = caller.getCarriedBlob();
    if (carried is null || carried.getName() != this.getName())
    {
        return;
    }

    if (this is carried)
    {
        if (this.getInventoryName() != "Spell component")
        {
            return;
        }
        if (!caller.isMyPlayer())
        {
            return;
        }
        CGridMenu@ gridMenu = CreateGridMenu(this.getScreenPos(), this, Vec2f(8, 4), "Select a rune type.");
        gridMenu.deleteAfterClick = false;
        if (gridMenu !is null)
        {
            {
                CBitStream params;
                gridMenu.SetDefaultCommand(this.getCommandID("do nothing"), params);
                gridMenu.AddKeyCommand(KEY_ESCAPE, this.getCommandID("do nothing"), params);
            }
            for (int i = 0; i < componentNames.length; i++)
            {
                CBitStream params;
                params.write_string(componentNames[i]);
                CGridButton@ button = gridMenu.AddTextButton(componentNames[i], this.getCommandID("select type"), Vec2f(2, 1), params);
            }
        }
    }
    else
    {
        CBitStream params;
        params.write_netid(carried.getNetworkID());

        CButton@ button = caller.CreateGenericButton("$combine_icon$", Vec2f_zero, this, this.getCommandID("combine"), "Combine", params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("do nothing"))
    {
        // literally do nothing
        return;
    }
    if (cmd == this.getCommandID("select type"))
    {

        if (!isServer())
        {
            return;
        }

        SpellComponent@ component;
        this.get("component object", @component);
        if (component !is null)
        {
            CBitStream nameParams;
            nameParams.write_netid(this.getNetworkID());
            nameParams.write_string("Grade " + component.grade + " " + component.ComponentID() + " rune");
            getRules().SendCommand(getRules().getCommandID("change comp name"), nameParams);
            return; // already selected
        }
        @component = GetComponentFromString(params.read_string(), 0);
        if (component is null)
        {
            return;
        }
        this.set("component object", @component);

        CRules@ rules = getRules();

        CBitStream nameParams;
        nameParams.write_netid(this.getNetworkID());
        nameParams.write_string("Grade " + component.grade + " " + component.ComponentID() + " rune");

        rules.SendCommand(rules.getCommandID("change comp name"), nameParams);

        CBitStream componentParams;
        componentParams.write_netid(this.getNetworkID());
        componentParams.write_string(component.ComponentID());
        componentParams.write_s32(component.grade);

        rules.SendCommand(rules.getCommandID("add comp client"), componentParams);
    }
    if (cmd == this.getCommandID("combine"))
    {
        if (!isServer()) 
        {
            return;
        }

        CBlob@ carried = getBlobByNetworkID(params.read_netid());
        if (carried is null)
        {
            return;
        }

        SpellComponent@ cThis;
        SpellComponent@ cOther;
        this.get("component object", @cThis);
        carried.get("component object", @cOther);
        if (cThis is null || cOther is null)
        {
            return;
        }

        if (cThis.grade != cOther.grade || cThis.ComponentID() != cOther.ComponentID())
        {
            return;
        }

        Vec2f pos = this.getPosition();

        this.server_Die();
        carried.server_Die();

        cThis.grade += 1;
        CBlob@ new = server_CreateBlob("component", -1, pos);
        new.set("component object", @cThis);

        CBitStream nameParams;
        nameParams.write_netid(new.getNetworkID());
        nameParams.write_string("Grade " + cThis.grade + " " + cThis.ComponentID() + " rune");
        
        CRules@ rules = getRules();

        rules.SendCommand(rules.getCommandID("change comp name"), nameParams);
    }
}