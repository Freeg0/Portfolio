uniform sampler2D uChannel0;
uniform sampler2D uChannel1;
uniform vec3 uResolution;

varying vec2 vUv;

void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = vUv; // fragCoord/iResolution.xy;

    vec4 data = texture(uChannel0, uv);
    
    // Brightness = water height
    // gl_FragColor.xyz = vec3(data.x + 1.0) / 2.0;
    
    // Color = texture
    gl_FragColor = texture(uChannel1, uv + 0.2 * data.zw);
    
    // Sunlight glint
    vec3 normal = normalize(vec3(-data.z, 0.2, -data.w));
    gl_FragColor += vec4(1) * pow(max(0.0, dot(normal, normalize(vec3(-3, 10, 3)))), 60.0);
}
