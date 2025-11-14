# Template_ShaderFilter

Content
- `scripts/shader.py` — example Python component implementing a 2D filter in two passes (buffer + image).
- `shadersFilter.range` — `.range` scene with the example configured for testing.

Purpose
This directory is the recommended starting point to create new filters/shaders. The Python script demonstrates:
- How to register filters with the `filterManager`.
- How to create an offscreen buffer using `addOffScreen`.
- How to bind the buffer to the second pass with `setTexture`.
- Where to update per-frame uniforms in `update()`.

How to use (step-by-step)
1. Open `shadersFilter.range` in your Range/Blender build to see the example running.
2. Open `scripts/shader.py` and locate the two GLSL strings: `buffe` (first pass) and `image` (second pass).
3. To test an effect, edit only the GLSL code (you usually don't need to change the Python if you only modify shader logic).
4. Run the scene. If nothing appears, check:
  - The shader defines `gl_FragColor`.
  - The Layer set in the component matches the scene setup.

Quick shader example (grayscale)
```glsl
uniform sampler2D bgl_RenderedTexture;
void main() {
  vec2 texcoord = gl_TexCoord[0].st;
  vec4 color = texture2D(bgl_RenderedTexture, texcoord);
  float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
  gl_FragColor = vec4(vec3(gray), color.a);
}
```

How to pass custom uniforms via Python
- In the component `start()` or `update()`:
  - `self.image.setUniform("uIntensity", 0.8)`
- In GLSL:
  - `uniform float uIntensity;`

Important notes about the template pipeline
- Pass 1 (`buffe`): receives `bgl_RenderedTexture` and writes to an offscreen buffer.
- Pass 2 (`image`): receives `bgl_RenderedBuffe` (bound via `setTexture`) and `bgl_RenderedTexture` and composes the final result.
- Offscreen buffers are commonly used at reduced resolution for performance (e.g., `width=int(w/2)`).

Best practices
- Use lower offscreen resolution for heavy effects (bloom, blur).
- Minimize `texture2D` calls.
- Update uniforms in `update()` only when necessary.

Quick debugging
- Black screen → shader did not set `gl_FragColor` or failed to compile.
- No visible effect → wrong Layer, shader not applied, or buffer texture not set.
- Poor performance → reduce offscreen resolution or simplify the shader.

References
- See the `Scripts` folder (ready shaders) and `Filters and Shaders Materials` (scenes with applied shaders).