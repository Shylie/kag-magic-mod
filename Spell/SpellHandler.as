#include "SpellCommon.as";
#include "SpellComponents.as";

// texture used to render custom spell graphics
const string textureName = "spell render texture";

// make sure the texture exists. if not, create it
void Setup()
{
    if (!Texture::exists(textureName))
    {
        if (!Texture::createBySize(textureName, 1, 1))
        {
            warn("Texture creation failed.");
        }
        else
        {
            ImageData@ edit = Texture::data(textureName);

            edit[0] = SColor(0xffffffff);

			if(!Texture::update(textureName, edit))
			{
				warn("Texture update failed");
			}
        }
    }
}

// render for all spells
void RenderFunction(int id)
{
    Render::SetAlphaBlend(true);

    CBlob@[] spellBlobs;
    getBlobsByTag("spell blob", @spellBlobs);
    for (int i = 0; i < spellBlobs.length; i++)
    {
        Spell@ spell;
        spellBlobs[i].get("spell object", @spell);
        if (spell is null)
        {
            continue;
        }
        Vertex[] verts;
        uint16[] indices;
        for (int i = 0; i < spell.spellComponents.length; i++)
        {
            spell.spellComponents[i].AddRenderInfo(spell, @verts, @indices);
        }
        if (verts.length > 0 && indices.length > 0)
        {
            Render::RawTrianglesIndexed(textureName, verts, indices);
        }
    }
}

// spell casting delay (in ticks)
const int spellDelay = 10;

// set up rules for use, including texture creation / load
void onInit(CRules@ this)
{
    Spell@[] spells;
    Spell@[] newSpells;
    this.set("spells", spells);
    this.set("new spells", newSpells);

    this.set_u32("gametime last fired", getGameTime());

    // update bag highlighting
    this.addCommandID("highlight bag");
    // move selected bag slot forward
    this.addCommandID("highlight bag forward");
    // move selected bag slot backward
    this.addCommandID("highlight bag backward");
    // set component name so people know what it is
    this.addCommandID("change comp name");
    // sync component to client
    this.addCommandID("add comp client");
    // cast a spell
    this.addCommandID("cast spell");
    // sync spell to client
    this.addCommandID("add spell client");

    Setup();
    // add render function
    int cbId = Render::addScript(Render::layer_postworld, "SpellHandler.as", "RenderFunction", 0.0f);
}

void onRestart(CRules@ this)
{
    // make sure texture exists on rules restart
    Setup();
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
    // update bag highlighting
    if (cmd == this.getCommandID("highlight bag"))
    {
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null)
        {
            return;
        }

        CInventory@ inv = blob.getInventory();
        if (inv is null)
        {
            return;
        }

        int selected = this.get_s32("selected slot");

        for (int i = 0; i < 8; i++)
        {
            CBlob@ item = inv.getItem(i);
            if (item is null)
            {
                continue;
            }

            if (item.getName() != "componentbag")
            {
                continue;
            }

            if (i == selected)
            {
                CSprite@ itemSprite = item.getSprite();
                if (itemSprite !is null)
                {
                    itemSprite.SetFrame(1);
                }
                item.inventoryIconFrame = 1;
            }
            else
            {
                CSprite@ itemSprite = item.getSprite();
                if (itemSprite !is null)
                {
                    itemSprite.SetFrame(0);
                }
                item.inventoryIconFrame = 0;
            }
        }
    }
    // move selected bag slot forward
    if (cmd == this.getCommandID("highlight bag forward"))
    {
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null)
        {
            return;
        }

        CInventory@ inv = blob.getInventory();
        if (inv is null)
        {
            return;
        }

        int selected = params.read_s32();
        int new_selected = selected + 1 > 8 ? 8 : selected + 1;

        CBlob@ prev = inv.getItem(selected);
        CBlob@ new = inv.getItem(new_selected);

        if (prev !is null)
        {
            if (prev.getName() == "componentbag")
            {
                CSprite@ sprite = prev.getSprite();
                if (sprite !is null)
                {
                    sprite.SetFrame(0);
                }
                prev.inventoryIconFrame = 0;
            }
        }
        if (new !is null)
        {
            if (new.getName() == "componentbag")
            {
                CSprite@ sprite = new.getSprite();
                if (sprite !is null)
                {
                    sprite.SetFrame(1);
                }
                new.inventoryIconFrame = 1;
            }
        }
    }
    // move selected bag slot backward
    if (cmd == this.getCommandID("highlight bag backward"))
    {
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null)
        {
            return;
        }

        CInventory@ inv = blob.getInventory();
        if (inv is null)
        {
            return;
        }

        int selected = params.read_s32();
        int new_selected = selected - 1 < 0 ? 0 : selected - 1;

        CBlob@ prev = inv.getItem(selected);
        CBlob@ new = inv.getItem(new_selected);

        if (prev !is null)
        {
            if (prev.getName() == "componentbag")
            {
                CSprite@ sprite = prev.getSprite();
                if (sprite !is null)
                {
                    sprite.SetFrame(0);
                }
                prev.inventoryIconFrame = 0;
            }
        }
        if (new !is null)
        {
            if (new.getName() == "componentbag")
            {
                CSprite@ sprite = new.getSprite();
                if (sprite !is null)
                {
                    sprite.SetFrame(1);
                }
                new.inventoryIconFrame = 1;
            }
        }
    }
    // set component name so people know what it is
    if (cmd == this.getCommandID("change comp name"))
    {
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null)
        {
            return;
        }
        blob.setInventoryName(params.read_string());
    }
    // sync component to client
    if (cmd == this.getCommandID("add comp client"))
    {
        if (!isClient())
        {
            return;
        }

        // localhost is a special snowflake
        if (isClient() && isServer())
        {
            return;
        }

        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null)
        {
            return;
        }

        string componentName = params.read_string();
        int grade = params.read_s32();

        SpellComponent@ componentObj = GetComponentFromString(componentName, grade);
        if (componentObj is null)
        {
            return;
        }

        blob.set("component obj", componentObj);
    }
    // cast a spell
    if (cmd == this.getCommandID("cast spell"))
    {
        // net check
        if (!isServer())
        {
            return;
        }

        // get caster blob
        CBlob@ blob = getBlobByNetworkID(params.read_netid());
        if (blob is null)
        {
            // this shouldn't happen, but here's a null check just in case.
            return;
        }

        // get caster blob's inventory
        CInventory@ inventory = blob.getInventory();
        if (inventory is null)
        {
            // this shouldn't happen either, but here's another null check anyway
            return;
        }

        // get aim position and calculate info based on aim pos and caster pos
        Vec2f aimPos = blob.getAimPos();
        Vec2f aimDif = aimPos - blob.getPosition();
        float angle = aimDif.getAngleDegrees();
        aimDif.Normalize();
        // spawn position -- offset by aimDif with a length of 10 so that it doesn't spawn in the caster blob.
        Vec2f spawnPos = blob.getPosition() + aimDif * 10.0f;

        int team = blob.getTeamNum();

        SpellComponent@[] cs;

        // get selected component bag
        CBlob@ item = inventory.getItem(params.read_s32());
        if (item !is null && item.getName() == "componentbag")
        {
            CInventory@ bagInventory = item.getInventory();

            // loop through all components in the bag
            for (int i = 0; i < bagInventory.getItemsCount(); i++)
            {
                // get the component blob
                CBlob@ cBlob = bagInventory.getItem(i);
                if (cBlob is null)
                {
                    continue;
                }
                
                // get the actual spell component
                SpellComponent@ c;
                cBlob.get("component object", @c);
                if (c is null)
                {
                    continue;
                }

                // add the component to the array
                cs.push_back(c.Copy());
            }
        }

        // actually create the spell. init code is done in the spell constructor.   
        Spell spell(spawnPos, angle, team, cs);
    }
    // sync spell to client
    if (cmd == this.getCommandID("add spell client"))
    {
        if (!isClient())
        {
            return;
        }

        // localhost is a special snowflake
        if (isClient() && isServer())
        {
            return;
        }

        CBlob@ spellBlob = getBlobByNetworkID(params.read_netid());
        if (spellBlob is null)
        {
            return;
        }

        int amt = params.read_s32();
        SpellComponent@[] cs;
        for (int i = 0; i < amt; i++)
        {
            string name = params.read_string();
            int grade = params.read_s32();
            SpellComponent@ c = GetComponentFromString(name, grade);
            if (c is null)
            {
                continue;
            }
            cs.push_back(c);
        }
        float angle = params.read_f32();
        Spell(cs, angle, spellBlob);
    }
}

void onTick(CRules@ this)
{
    Spell@[] spells;
    this.get("spells", spells);

    for (int i = spells.length - 1; i >= 0; i--)
    {
        // update spell
        if (spells[i].Update())
        {
            // spell died, needs removing
            spells[i].OnDeath();
            if (isServer())
            {
                // kill spell blob if on server
                spells[i].spellBlob.server_Die();
            }
            // finally remove
            spells.removeAt(i);
        }
    }

    this.set("spells", spells);

    Spell@[] newSpells;
    this.get("new spells", newSpells);

    for (int i = 0; i < newSpells.length; i++)
    {
        this.push("spells", @newSpells[i]);
    }

    this.clear("new spells");

    if (isClient())
    {
        CBlob@ blob = getLocalPlayerBlob();
        if (blob is null)
        {
            return;
        }
        CControls@ controls = blob.getControls();
        if (controls is null)
        {
            return;
        }

        if (controls.isKeyJustPressed(EKEY_CODE::KEY_KEY_B))
        {
            int selected = this.get_s32("selected slot");
            int new_selected = selected + 1 > 8 ? 8 : selected + 1;
            this.set_s32("selected slot", new_selected);

            CBitStream params;
            params.write_netid(blob.getNetworkID());
            params.write_s32(selected);

            this.SendCommand(this.getCommandID("highlight bag forward"), params);
        }

        if (controls.isKeyJustPressed(EKEY_CODE::KEY_KEY_N))
        {
            int selected = this.get_s32("selected slot");
            int new_selected = selected - 1 < 0 ? 0 : selected - 1;
            this.set_s32("selected slot", new_selected);

            CBitStream params;
            params.write_netid(blob.getNetworkID());
            params.write_s32(selected);

            this.SendCommand(this.getCommandID("highlight bag backward"), params);
        }

        uint time = getGameTime();
        if (time - this.get_u32("gametime last fired") < spellDelay)
        {
            return;
        }

        CBitStream stream;
        stream.write_netid(blob.getNetworkID());

        if (controls.isKeyPressed(EKEY_CODE::KEY_KEY_R))
        {
            stream.write_s32(this.get_s32("selected slot"));
        }
        else
        {
            return;
        }

        this.SendCommand(this.getCommandID("cast spell"), stream);

        this.set_u32("gametime last fired", time);
    }
}