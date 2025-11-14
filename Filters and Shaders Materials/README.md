# Filters and Shaders Materials

## Content
This directory contains scene files (`.range`) and materials where each shader is already applied and configured. Use these scenes as practical usage examples.

## Purpose
Provide practical examples with shaders already integrated into the scene — useful to:
- Check which parameters and layers (`Layer`) are in use.
- Test the shader in context (lighting, objects, cameras).
- Learn how the Python component is connected to the object/Empty in the scene.

## How to use
1. Open the corresponding `.range` scene in Range/Blender.
2. Find the object that has the Python component attached (usually an Empty).
3. Inspect the component (args/Layer) and open the linked script.
4. Run the scene to see the effect in action.

### What to check when opening an example scene
- Which Layer the filter is using (render layers).
- If the offscreen buffer was created (check `addOffScreen` parameters).
- If the image shader was bound to the buffer using `setTexture`.
- Which custom uniforms are updated in `update()`.

### Best practices when studying the scenes
- Compare the shader in the `Scripts/` folder with the one applied in the scene.
- Reproduce the scene/filterManager configuration in your own project by copying the component.
- Note any optimizations used (offscreen resolution, use of mipmaps/HDR).

### Common issues when opening examples
- Shader compilation error on load → check the console for compile messages.
- Incorrect Layer → adjust the `Layer` parameter on the component.
- Buffer texture not appearing → verify `setTexture` and `offScreen.colorBindCodes`.
