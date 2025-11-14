uniform sampler2D bgl_RenderedTexture;
uniform vec3 pos[count];
uniform float timer;
uniform vec2 radarPosition;
uniform vec2 radarSize;
uniform float MAX_RANGE;

vec2 texcoord = gl_TexCoord[0].st;

#define PI 3.1415926535897932384626433832795

float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rotate(vec2 p, float angle) {
    float s = sin(angle), c = cos(angle);
    return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

void main() {
    vec3 image = texture(bgl_RenderedTexture, texcoord).rgb;

    vec2 size = textureSize(bgl_RenderedTexture, 0);
    vec2 aspect = vec2(size.x / size.y, 1.0);
    vec2 uv = (texcoord - radarPosition) * 2.0 / radarSize - 1.0;
    uv *= aspect;

    float radius = 1.0;
    float dist = length(uv);

    float mask = smoothstep(radius, radius - 0.02, dist);

    float green = 0.0;
    float red = 0.0;

    float border = abs(dist - radius);
    if (border < 0.02) {
        green = 1.0 - border / 0.02;
    }

    vec2 rotatedUV = rotate(uv, -timer);
    float anglePix = atan(rotatedUV.x, rotatedUV.y);
    if (anglePix < 0.0) anglePix += 2.0 * PI;
    float sectorGradient = anglePix / (2.0 * PI);
    sectorGradient = pow(sectorGradient, 3.0);

    float noiseFactor = noise(rotatedUV * 20.0 + timer * 5.0);
    noiseFactor = (noiseFactor - 0.5) * 0.2;
    sectorGradient += noiseFactor;
    sectorGradient = clamp(sectorGradient, 0.0, 1.0);

    green = max(green, sectorGradient * mask);

    for (int i = 0; i < count; i++) {
        vec2 blip = pos[i].xy;
        float d = distance(uv * 3.0, blip);
        if (d < 0.4) {
            red = max(red, (0.4 - d) / 0.4);
        }
    }

    vec3 radarColor = mix(image, vec3(0.0, green, 0.0), mask);

    float blipMask = smoothstep(radius, radius - 0.1, dist);
    vec3 finalColor = mix(radarColor, vec3((2.0 * red) * green, 0.0, 0.0), red * blipMask);

    gl_FragColor = vec4(finalColor, 1.0);
}
