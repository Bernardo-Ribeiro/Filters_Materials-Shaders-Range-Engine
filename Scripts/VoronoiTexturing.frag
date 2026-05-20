vec4 hash4(vec2 p)
{
    return fract(sin(vec4(
        1.0 + dot(p, vec2(37.0,17.0)),
        2.0 + dot(p, vec2(11.0,47.0)),
        3.0 + dot(p, vec2(41.0,29.0)),
        4.0 + dot(p, vec2(23.0,31.0))
    )) * 103.0);
}

vec4 textureNoTile(sampler2D samp, vec2 uv, float variation)
{
    vec2 p = floor(uv);
    vec2 f = fract(uv);

    vec2 ddx = dFdx(uv);
    vec2 ddy = dFdy(uv);

    vec4 acc = vec4(0.0);
    float wsum = 0.0;
    float wsum2 = 0.0;

    for(int j = -1; j <= 1; j++)
    for(int i = -1; i <= 1; i++)
    {
        vec2 g = vec2(float(i), float(j));

        vec4 o = hash4(p + g);

        vec2 r = g - f + o.xy;

        float d = dot(r, r);

        float w = exp(-5.0 * d);

        vec2 offset = variation * o.zw;

        vec4 col = textureGrad(samp, uv + offset, ddx, ddy);

        acc += w * col;
        wsum += w;
        wsum2 += w * w;
    }

    vec4 base = acc / wsum;

    float mean = 0.4;
    vec4 res = mean + (acc - wsum * mean) / sqrt(wsum2);

    return mix(base, res, variation);
}

void fragment()
{
    vec2 uv = UV - 0.5;

    float scale = 100.0;
    vec2 coords = uv * scale;

    float variation = 0.7;

    vec4 col = textureNoTile(samp0, coords, variation);

    ALBEDO = col.rgb;
}