#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>

using namespace metal;

/// Cheap pseudo-random value from a 2D position. Range [0, 1].
static float hash(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

/// Per-pixel noise modulation for the LCD glow layer.
///
/// Applied as a colorEffect to a pre-blurred glow shape behind the panel.
/// Shifts brightness using two octaves of animated hash noise so the glow
/// edge looks organic and alive rather than a uniform blur.
///
/// - time:  seconds (from TimelineView), drives the noise animation
[[stitchable]]
half4 lcdGlowNoise(
    float2 position,
    half4  color,
    float  time
) {
    // Two octaves at different spatial scales and drift speeds
    float n1 = hash(position * 0.06 + float2(time * 0.08, 0.0));
    float n2 = hash(position * 0.13 + float2(0.0, time * 0.10));
    float noise = n1 * 0.6 + n2 * 0.4;   // [0, 1]

    // Map to a brightness multiplier: [0.55 … 1.0]
    // Floor at 0.55 so glow never fully vanishes
    float mod = 0.55 + noise * 0.45;

    color.rgb *= half(mod);
    return color;
}
