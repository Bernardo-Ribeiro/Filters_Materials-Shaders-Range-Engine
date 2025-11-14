# Scripts

Content
This folder contains GLSL shader files and helper scripts (effect examples). Examples referenced in the main README:
- `AnalogTV.glsl`
- `ChromaticAberration.glsl`
- `SimpleToon.glsl`
- `FractalTexturing.frag`
(Open the folder to see the actual contents and filenames.)

Purpose
Store ready-to-use shader examples — copy/paste the GLSL code into the template (`Template_ShaderFilter/scripts/shader.py`) or load it into new Python components.

How to integrate a shader from this folder into the template
1. Open the desired GLSL file and copy the fragment shader code.
2. Paste the GLSL string into either `buffe` or `image` in `Template_ShaderFilter/scripts/shader.py`.
   - Use `buffe` to manipulate/generate an offscreen buffer.
   - Use `image` to compose the final output using `bgl_RenderedBuffe` and `bgl_RenderedTexture`.
3. Adjust `addOffScreen(width, height)` if the shader requires a specific resolution.
4. If the shader uses custom uniforms, add `setUniform` calls in Python:
   - `self.image.setUniform("name", value)`

Editing tips
- Keep comments in the GLSL to document expected uniforms.
- Test incrementally: start with a simple pass-through shader then add complexity.
- If the shader comes from ShaderToy, adapt helper functions (iTime, iResolution) to the template uniforms (`bgl_RenderedTextureWidth/Height`, time via Python, etc.).

Suggested organization
- Name files with `.glsl` or `.frag` suffixes clearly: `effectName.frag` or `effectName.glsl`.
- Include a top comment listing requirements (e.g., uses `bgl_RenderedBuffe`, needs offscreen at half resolution).

Example of dynamic uniform integration
- In Python:
```python
self.image.setUniform("uTime", current_time)
self.image.setUniform("uIntensity", 0.5)
```
- In GLSL:
```glsl
uniform float uTime;
uniform float uIntensity;
```
