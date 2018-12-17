shared SpellComponent@[] CopyComponents(SpellComponent@[] toCopy)
{
    SpellComponent@[] copied;
    for (int i = 0; i < toCopy.length; i++)
    {
        copied.push_back(toCopy[i].Copy());
    }
    return copied;
}

shared SpellComponent@[] CopyComponentsFiltered(SpellComponent@[] toCopy, string[] toRemove)
{
    SpellComponent@[] copied;
    for (int i = 0; i < toCopy.length; i++)
    {
        if (toRemove.find(toCopy[i].ComponentID()) < 0)
        {
            copied.push_back(toCopy[i].Copy());
        }
    }
    return copied;
}

shared class SpellComponent
{
    int grade;

    SpellComponent(int g)
    {
        if (g < 0)
        {
            warn("Spell components cannot have a negative grade. Defaulting grade to 0.");
            g = 0;
        }
        grade = g;
    }

    // return true to kill spell
    bool Update(Spell@ spell)
    {
        // do nothing, this is for inherited classes
        return false;
    }

    void OnCreate(Spell@ spell)
    {
        // do nothing, this is for inherited classes
    }

    void OnDeath(Spell@ spell)
    {
        // do nothing, this is for inherited classes
    }

    void AddRenderInfo(Spell@ spell, Vertex[]@ verts, uint16[]@ indices)
    {
        // do nothing, this is for inherited classes
    }

    string ComponentID()
    {
        warn(ComponentID() + " didn't override the ComponentID method.");
        return "default component";
    }

    SpellComponent@ Copy()
    {
        warn(ComponentID() + " didn't override the Copy method.");
        return SpellComponent(grade);
    }

    float Damage()
    {
        return 0.0f;
    }

    float DamageMult()
    {
        return 1.0f;
    }

    float StartVelocity()
    {
        return 0.0f;
    }

    float StartVelocityMult()
    {
        return 1.0f;
    }

    int MaxAge()
    {
        return 0;
    }

    int MaxAgeMult()
    {
        return 1;
    }

    bool Hits(Spell@ spell, CBlob@ blob)
    {
        return !spell.shouldDie && spell.spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
    }

    bool opEquals(SpellComponent&in other)
    {
        return this is other;
    }
}

shared class Spell
{
    // blob that represents the spell
    CBlob@ spellBlob;

    // age of the spell
    private int _age = 0;

    int age
    {
        get
        {
            return _age;
        }
    }

    // TODO: add custom max collision amt

    // should die next update
    bool shouldDie = false;

    // spell modifying components
    SpellComponent@[] spellComponents;

    // clientside init
    Spell(SpellComponent@[] c, float angle, CBlob@ spellBlob)
    {
        // net check
        if (!isClient())
        {
            return;
        }

        // gravity
        spellBlob.getShape().SetGravityScale(0.0f);

        @this.spellBlob = @spellBlob;

        // spell components
        spellComponents = c;

        // starting velocity
        Vec2f vel(StartVelocity(), 0.0f);
        vel = vel.RotateBy(-angle);
        spellBlob.setVelocity(vel);

        // set the blob's angle
        spellBlob.setAngleDegrees(angle);

        // add a reference to this in the blob
        spellBlob.set("spell object", @this);

        // call oncreate for each component
        for (int i = 0; i < c.length; i++)
        {
            spellComponents[i].OnCreate(@this);
        }

        // add to array of all spells
        getRules().push("new spells", @this);
    }

    // serverside init
    Spell(Vec2f pos, float angle, int team, SpellComponent@[] c)
    {
        // net check
        if (!isServer())
        {
            return;
        }

        // make object handle
        @spellBlob = @server_CreateBlob("spell", team, pos);

        // gravity
        spellBlob.getShape().SetGravityScale(0.0f);

        // spell components
        spellComponents = c;

        // starting velocity
        Vec2f vel(StartVelocity(), 0.0f);
        vel = vel.RotateBy(-angle);
        spellBlob.setVelocity(vel);

        // set the blob's angle
        spellBlob.setAngleDegrees(angle);

        // add a reference to this in the blob
        spellBlob.set("spell object", @this);

        // call oncreate for each component
        for (int i = 0; i < c.length; i++)
        {
            spellComponents[i].OnCreate(@this);
        }

        // add to array of all spells
        getRules().push("new spells", @this);

        // declare bitstream
        CBitStream params;

        // write some blob net id so we can get the blob on client
        params.write_netid(spellBlob.getNetworkID());

        // write the amount of spell components for proper reading on client
        params.write_s32(spellComponents.length);
        
        // actually write the components
        for (int i = 0; i < spellComponents.length; i++)
        {
            params.write_string(spellComponents[i].ComponentID());
            params.write_s32(spellComponents[i].grade);
        }

        // angle of the spell. dunno why this is last tbh.
        params.write_f32(angle);
        
        // send the command
        getRules().SendCommand(getRules().getCommandID("add spell client"), params);
    }

    // return true if the spell is dead
    bool Update()
    {
        // don't run component update methods if spell should be dead
        if (age > MaxAge())
        {
            return true;
        }

        bool dead = false;
        if (spellComponents.length > 0)
        {
            for (int i = 0; i < spellComponents.length; i++)
            {
                if (spellComponents[i].Update(this))
                {
                    dead = true;
                }
            }
        }
        return _age++ > MaxAge() || dead || shouldDie;
    }

    // this is called when the spell dies
    void OnDeath()
    {
        if (spellComponents.length > 0)
        {
            for (int i = 0; i < spellComponents.length; i++)
            {
                spellComponents[i].OnDeath(this);
            }
        }
    }

    // return damage amount
    float Damage()
    {
        if (spellComponents.length == 0)
        {
            return 1.0f;
        }

        float base = 1.0f;
        float mult = 1.0f;
        for (int i = 0; i < spellComponents.length; i++)
        {
            base += spellComponents[i].Damage();
            mult *= spellComponents[i].DamageMult();
        }
        return base * mult;
    }

    // return start velocity
    float StartVelocity()
    {
        if (spellComponents.length == 0)
        {
            return 3.5f;
        }

        float base = 3.5f;
        float mult = 1.0f;
        for (int i = 0; i < spellComponents.length; i++)
        {
            base += spellComponents[i].StartVelocity();
            mult *= spellComponents[i].StartVelocityMult();
        }
        return base * mult;
    }

    // return max age in ticks
    int MaxAge()
    {
        if (spellComponents.length == 0)
        {
            return 60; // 2 seconds
        }

        int base = 60;
        int mult = 1;
        for (int i = 0; i < spellComponents.length; i++)
        {
            base += spellComponents[i].MaxAge();
            mult *= spellComponents[i].MaxAgeMult();
        }
        return base * mult > 0 ? base * mult : 0;
    }

    // should hit
    bool Hits(CBlob@ blob)
    {
        if (spellComponents.length == 0)
        {
            return !shouldDie && spellBlob.getTeamNum() != blob.getTeamNum() && blob.hasTag("player");
        }

        for (int i = 0; i < spellComponents.length; i++)
        {
            if (!spellComponents[i].Hits(this, blob))
            {
                return false;
            }
        }
        return true;
    }

    bool opEquals(Spell&in other)
    {
        return this is other;
    }
}