uniform sampler2D bgl_RenderedTexture;
uniform float bgl_RenderedTextureWidth;
uniform float bgl_RenderedTextureHeight;
uniform float TIME;

float rand(vec2 co) { 
    return fract(sin(dot(co.xy , vec2(12.9898, 78.233))) * 43758.5453);
} 

void main() {     
    vec2 fragCoord = gl_FragCoord.xy;
    vec2 resolution = vec2(bgl_RenderedTextureWidth, bgl_RenderedTextureHeight);
    vec2 uv = (fragCoord - resolution * 0.5) / resolution.y;      

    uv *= 0.32;
    uv.x *= 0.56;
    
    // Fish eye
    float fovTheta = 7.55;    
    float z = sqrt(max(0.2 - uv.x * uv.x - uv.y * uv.y, 0.0));
    float a = 1.0 / (z * tan(fovTheta * 0.5));	
    uv = uv * a;

    vec3 col = texture2D(bgl_RenderedTexture, uv + 0.5).rgb;

    vec2 ruv = uv;
    ruv.x += 0.02;
    col.r += texture2D(bgl_RenderedTexture, ruv + 0.5).r * 0.2;

    // Color noise    
    col += rand(fract(floor((ruv + TIME) * resolution.y) * 0.7)) * 0.2;    

    col *= clamp(fract(uv.y * 100.0 + TIME * 8.0), 0.8, 1.0);       

    float bf = fract(uv.y * 3.0 + TIME * 26.0);
    float ff = min(bf, 1.0 - bf) + 0.35;
    col *= clamp(ff, 0.5, 0.75) + 0.75;       

    col *= (sin(TIME * 120.0) * 0.5 + 0.5) * 0.1 + 0.9;

    col *= smoothstep(-0.51, -0.50,  uv.x) * smoothstep(0.51, 0.50, uv.x);
    col *= smoothstep(-0.51, -0.50,  uv.y) * smoothstep(0.51, 0.50, uv.y);       

    gl_FragColor = vec4(col, 1.0);
}
