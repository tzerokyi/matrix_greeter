#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 viewport;
    float clockSeconds;
    float density;
    float intensity;
    float quality;
    float motion;
};
layout(binding = 1) uniform sampler2D glyphAtlas;

float hash1(float n) {
    n = fract(n * 0.1031);
    n *= n + 33.33;
    n *= n + n;
    return fract(n);
}
float hash2(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float glyphAt(float code, vec2 local) {
    vec2 grid = vec2(mod(code, 16.0), floor(code / 16.0));
    vec2 uv = (grid + clamp(local, 0.035, 0.965)) / 16.0;
    return texture(glyphAtlas, uv).a;
}

vec3 stream(vec2 p, vec2 pitch, float layer, float gain) {
    vec2 grid = floor(p / pitch);
    vec2 local = fract(p / pitch);
    float col = grid.x;
    float row = grid.y;
    float salt = layer * 101.17;
    float id = col + salt;
    float seed = hash1(id * 9.17 + 3.73);
    float velocity = mix(6.5, 17.5, hash1(id * 3.71 + 52.0));
    if (layer > 0.5) velocity *= 0.58;
    float lengthRows = mix(29.0, 56.0, hash1(id * 5.31 + 9.0));
    if (layer > 0.5) lengthRows *= 0.63;
    float screenRows = ceil(viewport.y / pitch.y) + 1.0;
    float track = screenRows + lengthRows + 4.0;
    float travel = clockSeconds * velocity * motion;
    float head = mod(travel + seed * track, track) - lengthRows;
    float age = head - row;
    if (age < 0.0 || age >= lengthRows) return vec3(0.0);
    float tail = clamp(1.0 - age / lengthRows, 0.0, 1.0);

    float gap = hash2(vec2(col * 0.73 + salt, row * 3.11));
    float alive = step(0.092, gap);
    float flickerStep = floor(clockSeconds * (0.8 + seed * 2.1) * motion);
    float mutate = step(0.78, hash2(vec2(row * 3.71, col * 1.13 + flickerStep)));
    float code = floor(256.0 * hash2(vec2(col * 13.17 + mutate * flickerStep,
                                              row * 17.91 - mutate * flickerStep)));
    float character = glyphAt(code, local);

    float headGlow = exp(-age * age * 1.35);
    float nearHead = exp(-age * 0.115);
    float luminance = alive * (0.14 + 0.83 * pow(tail, 1.28)) * (0.68 + 0.32 * gap);
    luminance += headGlow * 0.76 + nearHead * 0.15;

    vec3 darkGreen = vec3(0.018, 0.34, 0.115);
    vec3 clearGreen = vec3(0.19, 0.98, 0.45);
    vec3 brightWhite = vec3(0.78, 1.0, 0.83);
    vec3 color = mix(darkGreen, clearGreen, pow(tail, 2.2));
    color = mix(color, brightWhite, headGlow * 0.85);
    color *= luminance * character * gain;

    float centerX = 1.0 - abs(local.x - 0.5) * 2.0;
    float aura = pow(max(centerX, 0.0), 3.0) * headGlow * 0.055;
    color += vec3(0.04, 0.53, 0.19) * aura * gain;
    return color;
}

void main() {
    vec2 p = qt_TexCoord0 * viewport;
    float pitch = mix(18.4, 12.7, clamp(density, 0.0, 1.0));
    vec3 color = vec3(0.0022, 0.0100, 0.0050);

    if (quality >= 1.5) {
        color += stream(p * 0.93 + vec2(7.0, 19.0), vec2(pitch * 1.69, 24.0), 1.0, 0.25);
    }
    color += stream(p, vec2(pitch, 18.5), 0.0, 1.06);

    vec2 c = (qt_TexCoord0 - vec2(0.5, 0.51)) / vec2(0.31, 0.37);
    float centerVeil = 1.0 - smoothstep(0.38, 1.31, length(c));
    color *= 1.0 - centerVeil * 0.91;

    vec2 v = (qt_TexCoord0 - 0.5) * vec2(1.1, 1.12);
    float edge = 1.0 - smoothstep(0.33, 0.88, length(v));
    float scan = 0.955 + 0.045 * cos(p.y * 3.14159265);
    color *= scan * (0.61 + 0.39 * edge) * intensity;
    color += vec3(0.002, 0.008, 0.004) * edge * (1.0 - centerVeil * 0.3);
    fragColor = vec4(min(color, vec3(1.0)), 1.0) * qt_Opacity;
}
