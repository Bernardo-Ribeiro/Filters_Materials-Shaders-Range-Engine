uniform sampler2D bgl_RenderedTexture;

const float distortion = 4.0;

vec2 barrelDistortion(vec2 p, vec2 amt)
{
    p = 2.0 * p - 1.0;

    float maxBarrelPower = sqrt(5.0);
    float radius = dot(p, p);
    float scale = pow(radius, maxBarrelPower * amt.x);
    p *= scale;

    return p * 0.5 + 0.5;
}

vec2 brownConradyDistortion(vec2 uv, float scalar)
{
    uv = (uv - 0.5) * 2.0;

    float barrelDistortion1 = -0.02 * scalar; // K1
    float barrelDistortion2 = 0.0 * scalar;   // K2

    float r2 = dot(uv, uv);
    uv *= (1.0 + barrelDistortion1 * r2 + barrelDistortion2 * r2 * r2);

    return (uv / 2.0) + 0.5;
}

void main()
{
    vec2 uv = gl_TexCoord[0].st;

    float maxDistort = 1.0 * distortion;
    float scalar = 1.0 * maxDistort;

    vec4 colourScalar = vec4(700.0, 560.0, 490.0, 1.0);
    colourScalar /= max(max(colourScalar.x, colourScalar.y), colourScalar.z);
    colourScalar *= 1.5;
    colourScalar *= scalar;

    vec4 colorAccum = vec4(0.0);
    vec4 colorSample;

    colorSample.r = texture2D(bgl_RenderedTexture, brownConradyDistortion(uv, colourScalar.r)).r;
    colorSample.g = texture2D(bgl_RenderedTexture, brownConradyDistortion(uv, colourScalar.g)).g;
    colorSample.b = texture2D(bgl_RenderedTexture, brownConradyDistortion(uv, colourScalar.b)).b;

    colorAccum += colorSample;
    colourScalar *= 0.99;

    gl_FragColor = colorAccum;
}