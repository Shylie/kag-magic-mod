shared void AddCircle(Vertex[]@ verts, uint16[]@ indices, Vec2f pos, float radius, float z, SColor col, int samples)
{
    float angle = 0.0f;
    float angleChange = 360.0f / samples;
    Vec2f uv(0.0f, 0.0f);
    int startIndex = verts.length;

    verts.push_back(Vertex(pos, z, uv, col));
    for (int i = 0; i < samples; i++)
    {
        Vec2f bPos(pos.x + radius * Maths::Cos(angle * Maths::Pi / 180.0f), pos.y + radius * Maths::Sin(angle * Maths::Pi / 180.0f));
        verts.push_back(Vertex(bPos, z, uv, col));

        indices.push_back(startIndex);
        indices.push_back(startIndex + (i + 1 > samples ? i + 1 - samples : i + 1));
        indices.push_back(startIndex + (i + 2 > samples ? i + 2 - samples : i + 2));

        angle += angleChange;
    }
}

shared void AddGradientCircle(Vertex[]@ verts, uint16[]@ indices, Vec2f pos, float radius, float z, SColor colInner, SColor colOuter, int samples)
{
    float angle = 0.0f;
    float angleChange = 360.0f / samples;
    Vec2f uv(0.0f, 0.0f);
    int startIndex = verts.length;
    
    verts.push_back(Vertex(pos, z, uv, colInner));
    for (int i = 0; i < samples; i++)
    {
        Vec2f bPos(pos.x + radius * Maths::Cos(angle * Maths::Pi / 180.0f), pos.y + radius * Maths::Sin(angle * Maths::Pi / 180.0f));
        verts.push_back(Vertex(bPos, z, uv, colOuter));

        indices.push_back(startIndex);
        indices.push_back(startIndex + (i + 1 > samples ? i + 1 - samples : i + 1));
        indices.push_back(startIndex + (i + 2 > samples ? i + 2 - samples : i + 2));

        angle += angleChange;
    }
}

shared void AddHollowCircle(Vertex[]@ verts, uint16[]@ indices, Vec2f pos, float innerRadius, float outerRadius, float z, SColor col, int samples)
{
    float angle = 0.0f;
    float angleChange = 360.0f / samples;
    Vec2f uv(0.0f, 0.0f);
    int startIndex = verts.length;

    for (int i = 0; i < samples; i++)
    {
        Vec2f iPos(pos.x + innerRadius * Maths::Cos(angle * Maths::Pi / 180.0f), pos.y + innerRadius * Maths::Sin(angle * Maths::Pi / 180.0f));
        Vec2f oPos(pos.x + outerRadius * Maths::Cos(angle * Maths::Pi / 180.0f), pos.y + outerRadius * Maths::Sin(angle * Maths::Pi / 180.0f));
        verts.push_back(Vertex(iPos, z, uv, col));
        verts.push_back(Vertex(oPos, z, uv, col));

        indices.push_back(startIndex + (2 * i >= samples * 2 ? 2 * (i - samples) : 2 * i));
        indices.push_back(startIndex + (2 * i + 1 >= samples * 2 ? 2 * (i - samples) + 1 : 2 * i + 1));
        indices.push_back(startIndex + (2 * i + 3 >= samples * 2 ? 2 * (i - samples) + 3 : 2 * i + 3));
        
        indices.push_back(startIndex + (2 * i >= samples * 2 ? 2 * (i - samples) : 2 * i));
        indices.push_back(startIndex + (2 * i + 2 >= samples * 2 ? 2 * (i - samples) + 2 : 2 * i + 2));
        indices.push_back(startIndex + (2 * i + 3 >= samples * 2 ? 2 * (i - samples) + 3 : 2 * i + 3));

        angle += angleChange;
    }
}

shared void AddGradientHollowCircle(Vertex[]@ verts, uint16[]@ indices, Vec2f pos, float innerRadius, float outerRadius, float z, SColor colInner, SColor colOuter, int samples)
{
    float angle = 0.0f;
    float angleChange = 360.0f / samples;
    Vec2f uv(0.0f, 0.0f);
    int startIndex = verts.length;

    for (int i = 0; i < samples; i++)
    {
        Vec2f iPos(pos.x + innerRadius * Maths::Cos(angle * Maths::Pi / 180.0f), pos.y + innerRadius * Maths::Sin(angle * Maths::Pi / 180.0f));
        Vec2f oPos(pos.x + outerRadius * Maths::Cos(angle * Maths::Pi / 180.0f), pos.y + outerRadius * Maths::Sin(angle * Maths::Pi / 180.0f));
        verts.push_back(Vertex(iPos, z, uv, colInner));
        verts.push_back(Vertex(oPos, z, uv, colOuter));

        indices.push_back(startIndex + (2 * i >= samples * 2 ? 2 * (i - samples) : 2 * i));
        indices.push_back(startIndex + (2 * i + 1 >= samples * 2 ? 2 * (i - samples) + 1 : 2 * i + 1));
        indices.push_back(startIndex + (2 * i + 3 >= samples * 2 ? 2 * (i - samples) + 3 : 2 * i + 3));
        
        indices.push_back(startIndex + (2 * i >= samples * 2 ? 2 * (i - samples) : 2 * i));
        indices.push_back(startIndex + (2 * i + 2 >= samples * 2 ? 2 * (i - samples) + 2 : 2 * i + 2));
        indices.push_back(startIndex + (2 * i + 3 >= samples * 2 ? 2 * (i - samples) + 3 : 2 * i + 3));

        angle += angleChange;
    }
}