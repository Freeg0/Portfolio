varying vec2 vUv;
uniform float uTime;
uniform sampler2D uChannel0;
uniform sampler2D uChannel1;
uniform sampler2D uChannel2;


float avg(vec4 color) {
    return (color.r + color.g + color.b) / 5.0;
}

void main()
{
    // Flow Speed, increase to make the water flow faster.
    float speed = 1.0;
    
    // Water Scale, scales the water, not the background.
    float scale = 0.8;
    
    // Water opacity, higher opacity means the water reflects more light.
    float opacity = 0.5;

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = -1.0 + 2.0 * vUv;
    vec2 scaledUv = uv * scale;

    // Water layers, layered on top of eachother to produce the reflective effect
    // Add 0.1 to both uv vectors to avoid the layers stacking perfectly and creating a huge unnatural highlight
    vec4 water1 = texture(uChannel0, scaledUv + uTime * 0.02 * speed - 0.1);
    vec4 water2 = texture(uChannel0, scaledUv.xy + uTime * speed * vec2(-0.02, -0.02) + 0.1);
    
    // Water highlights
    vec4 highlights1 = texture(uChannel2, scaledUv.xy + uTime * speed / vec2(-10, 100));
    vec4 highlights2 = texture(uChannel2, scaledUv.xy + uTime * speed / vec2(10, 100));
    
    // Background image
    vec4 background = texture(uChannel1, vec2(uv) + avg(water1) * 0.05);
    
    // Average the colors of the water layers (convert from 1 channel to 4 channel
    water1.rgb = vec3(avg(water1));
    water2.rgb = vec3(avg(water2));
    
    // Average and smooth the colors of the highlight layers
    highlights1.rgb = vec3(avg(highlights1) / 1.5);
    highlights2.rgb = vec3(avg(highlights2) / 1.5);
    
    float alpha = opacity;
    
    if(avg(water1 + water2) > 0.3) {
        alpha = 0.0;
    }
    
    if(avg(water1 + water2 + highlights1 + highlights2) > 0.75) {
        alpha = 5.0 * opacity;
    }

    // Output to screen
    gl_FragColor = (water1 + water2) * alpha + background;
}


