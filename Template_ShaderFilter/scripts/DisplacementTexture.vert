uniform sampler2D samp0;

const float displacementScale = 0.1;

void vertex(){
    float height = texture(samp0, UV).r;

    vec3 normal = normalize(NORMAL);
    VERTEX += normal * height * displacementScale;

    vec2 e = vec2(0.01, 0.0);
    
    float h1 = texture(samp0, UV - e).r;
    float h2 = texture(samp0, UV + e).r;
    float h3 = texture(samp0, UV - e.yx).r;
    float h4 = texture(samp0, UV + e.yx).r;

    vec3 normalCalculated = normalize(vec3( h1 - h2, h3 - h4, 1.0));

    NORMAL = normalCalculated;
}