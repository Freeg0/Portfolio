uniform sampler2D uChannel0;
uniform vec3 uResolution;
uniform vec4 uMousePosition;
uniform float uFrame;

varying vec2 vUv;

// Make this a smaller number for a smaller timestep.
// Don't make it bigger than 1.4 or the universe will explode.
const float delta = 1.0;

void main()
{
    if (uFrame == 0.0) {gl_FragColor = vec4(0); return;}
    
    float pressure = texelFetch(uChannel0, ivec2(gl_FragCoord), 0).x;
    float pVel = texelFetch(uChannel0, ivec2(gl_FragCoord), 0).y;

    float p_right = texelFetch(uChannel0, ivec2(gl_FragCoord) + ivec2(1, 0), 0).x;
    float p_left = texelFetch(uChannel0, ivec2(gl_FragCoord) + ivec2(-1, 0), 0).x;
    float p_up = texelFetch(uChannel0, ivec2(gl_FragCoord) + ivec2(0, 1), 0).x;
    float p_down = texelFetch(uChannel0, ivec2(gl_FragCoord) + ivec2(0, -1), 0).x;
    
    // Change values so the screen boundaries aren't fixed.
    if (gl_FragCoord.x == 0.5) p_left = p_right;
    if (gl_FragCoord.x == uResolution.x - 0.5) p_right = p_left;
	  if (gl_FragCoord.y == 0.5) p_down = p_up;
    if (gl_FragCoord.y == uResolution.y - 0.5) p_up = p_down;

    // Apply horizontal wave function
    pVel += delta * (-2.0 * pressure + p_right + p_left) / 4.0;
    // Apply vertical wave function (these could just as easily have been one line)
    pVel += delta * (-2.0 * pressure + p_up + p_down) / 4.0;
    
    // Change pressure by pressure velocity
    pressure += delta * pVel;
    
    // "Spring" motion. This makes the waves look more like water waves and less like sound waves.
    pVel -= 0.005 * delta * pressure;
    
    // Velocity damping so things eventually calm down
    pVel *= 1.0 - 0.002 * delta;
    
    // Pressure damping to prevent it from building up forever.
    pressure *= 0.999;
    
    //x = pressure. y = pressure velocity. Z and W = X and Y gradient
    gl_FragColor.xyzw = vec4(pressure, pVel, (p_right - p_left) / 2.0, (p_up - p_down) / 2.0);
    
    // if (uMousePosition.x > 1.0) {
        float dist = distance(gl_FragCoord.xy, uMousePosition.xy);
        if (dist <= 20.0) {
            gl_FragColor.x += 1.0 - dist / 20.0;
        }
    // }
}