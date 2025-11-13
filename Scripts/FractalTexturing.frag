vec4 fractal_texture_mip(sampler2D tex, vec2 uv, float depth)
{
    float LOD = log(depth + 1e-3);
    float LOD_floor = floor(LOD);
    float LOD_fract = LOD - LOD_floor;

    vec2 uv1 = uv / exp(LOD_floor - 1.0);
    vec2 uv2 = uv / exp(LOD_floor + 0.0);
    vec2 uv3 = uv / exp(LOD_floor + 1.0);

    vec2 dx = dFdx(uv) / depth * exp(1.0);
    vec2 dy = dFdy(uv) / depth * exp(1.0);

    vec4 tex0 = textureGrad(tex, uv1, dx, dy);
    vec4 tex1 = textureGrad(tex, uv2, dx, dy);
    vec4 tex2 = textureGrad(tex, uv3, dx, dy);

    return (tex1 + mix(tex0, tex2, LOD_fract)) * 0.5;
}

void fragment()
{
    vec2 uv = UV - 0.5;

    float scale = 200.0;

    vec2 coords = uv * scale;

    float depth = distance(CAMERA_POS, OBJECT_POS) * 0.01 * scale;

    vec4 col = fractal_texture_mip(samp0, coords, depth);

    ALBEDO = col.rgb;
}
