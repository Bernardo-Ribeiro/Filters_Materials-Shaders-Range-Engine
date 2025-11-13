# Creating 2D Filters in Range Engine with Python

This guide explains how to create custom 2D post-processing filters for the Range Engine using Python and GLSL shaders.

## Overview

Range Engine (a Blender Game Engine fork) allows you to create custom visual effects using 2D filters. These filters are post-processing effects applied to the rendered image, allowing you to create various visual effects like blur, chromatic aberration, color grading, and more.

## Understanding the Template

The `Template_ShaderFilter` directory contains a complete example showing how to implement a 2D filter system with two render passes.

### File Structure

```
Template_ShaderFilter/
├── scripts/
│   └── shader.py          # Python component for filter management
└── shadersFilter.range    # Blender/Range scene file
```

## Python Script Breakdown

The Python script (`shader.py`) demonstrates a two-pass rendering system. Let's break down each component:

### 1. Import Required Modules

```python
from Range import types, logic, render
from collections import OrderedDict
```

- **Range.types**: Provides base classes for game components
- **Range.logic**: Game logic utilities
- **Range.render**: Rendering functions to access viewport dimensions
- **OrderedDict**: Maintains argument order for the component

### 2. GLSL Shader Code

The script defines two GLSL fragment shaders as string variables:

#### Buffer Shader (`buffe`)

```glsl
uniform sampler2D bgl_RenderedTexture;
uniform float bgl_RenderedTextureWidth;
uniform float bgl_RenderedTextureHeight;

void main() {
    vec2 texcoord = gl_TexCoord[0].st;
    vec2 pixelSize = vec2(1.0 / bgl_RenderedTextureWidth, 1.0 / bgl_RenderedTextureHeight);
    vec4 color = texture2D(bgl_RenderedTexture, texcoord);
    gl_FragColor = color;
}
```

**Purpose**: This is the first pass shader that:
- Receives the rendered scene as a texture (`bgl_RenderedTexture`)
- Calculates pixel dimensions for precise sampling
- Outputs the color to an offscreen buffer

This shader currently just passes through the color, but you can modify it to apply effects before storing to the buffer.

#### Image Shader (`image`)

```glsl
uniform sampler2D bgl_RenderedBuffe;
uniform sampler2D bgl_RenderedTexture;

vec2 texcoord = gl_TexCoord[0].st;

void main() {
    vec4 bufferTex = texture2D(bgl_RenderedBuffe, gl_TexCoord[0].st);
    vec4 renderedTex = texture2D(bgl_RenderedTexture, gl_TexCoord[0].st);
    
    gl_FragColor = renderedTex + bufferTex;
}
```

**Purpose**: This is the second pass shader that:
- Receives both the buffered texture from the first pass and the current rendered frame
- Combines both textures (in this case, by adding them together)
- Outputs the final result to the screen

### 3. The Python Component Class

```python
class filterShader(types.KX_PythonComponent):
    args = OrderedDict([
        ("Layer", 0)
    ])
```

**Component Definition**:
- Inherits from `KX_PythonComponent` to integrate with Range's component system
- Defines arguments that can be configured in the Range/Blender editor
- `Layer` parameter: Specifies which rendering layer to apply the filter to

### 4. Initialization Method

```python
def start(self, args):
    w = render.getWindowWidth()
    h = render.getWindowHeight()
    
    getFilter = self.object.scene.filterManager.addFilter
    getCustom = logic.RAS_2DFILTER_CUSTOMFILTER
    
    self.buffe = getFilter(self.args["Layer"], getCustom, buffe)
    self.image = getFilter(self.args["Layer"] + 1, getCustom, image)
    
    self.buffe.addOffScreen(1,
        width = int(w/2), height = int(h/2),
        hdr = 0, mipmap = False
    )
    
    self.image.setTexture(0, self.buffe.offScreen.colorBindCodes[0], "bgl_RenderedBuffe")
```

**Initialization Process**:

1. **Get viewport dimensions**: `render.getWindowWidth()` and `render.getWindowHeight()`

2. **Register filters**: 
   - Creates two filter passes using `addFilter(layer, type, shader_code)`
   - First filter on specified layer
   - Second filter on layer + 1

3. **Create offscreen buffer**:
   - `addOffScreen()` creates a render target for the first pass
   - Width/height set to half resolution (optimization technique)
   - `hdr=0`: Standard dynamic range
   - `mipmap=False`: No mipmap generation

4. **Link textures**:
   - Connects the offscreen buffer output to the second shader's input
   - The buffer becomes available as `bgl_RenderedBuffe` in the image shader

### 5. Update Method

```python
def update(self):
    pass
```

Currently empty but can be used for per-frame updates to shader uniforms.

## Creating Your Own 2D Filter

### Step 1: Define Your GLSL Shader

Create a fragment shader as a Python string. Example for a simple grayscale effect:

```python
grayscale_shader = """
uniform sampler2D bgl_RenderedTexture;

void main() {
    vec2 texcoord = gl_TexCoord[0].st;
    vec4 color = texture2D(bgl_RenderedTexture, texcoord);
    
    // Convert to grayscale using luminance formula
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    gl_FragColor = vec4(vec3(gray), color.a);
}
"""
```

### Step 2: Create the Python Component

```python
from Range import types, logic, render
from collections import OrderedDict

class MyCustomFilter(types.KX_PythonComponent):
    args = OrderedDict([
        ("Layer", 0),
        ("Intensity", 1.0)  # Custom parameter
    ])
    
    def start(self, args):
        getFilter = self.object.scene.filterManager.addFilter
        getCustom = logic.RAS_2DFILTER_CUSTOMFILTER
        
        self.filter = getFilter(self.args["Layer"], getCustom, grayscale_shader)
    
    def update(self):
        # You can update shader uniforms here if needed
        pass
```

### Step 3: Attach to Game Object

1. Open your Range/Blender scene
2. Select any game object (usually an Empty object)
3. Add your Python script as a component
4. Configure the Layer parameter to match your scene setup

## Advanced Techniques

### Multi-Pass Rendering

The template demonstrates a two-pass system:
1. **First Pass**: Renders to an offscreen buffer at lower resolution
2. **Second Pass**: Combines the buffer with the current frame

This is useful for:
- Bloom effects (blur bright areas)
- Motion blur (accumulate previous frames)
- Depth of field
- Temporal effects

### Accessing Uniforms

You can pass custom values to your shaders:

```python
def update(self):
    # Update uniform values each frame
    self.filter.setUniform("myCustomValue", some_value)
```

### Available Built-in Uniforms

Range provides several built-in uniforms automatically:
- `bgl_RenderedTexture`: The rendered scene
- `bgl_RenderedTextureWidth`: Viewport width
- `bgl_RenderedTextureHeight`: Viewport height

## Common Filter Examples

### Blur Effect

Sample multiple texture coordinates around the current pixel.

### Chromatic Aberration

Sample RGB channels at slightly offset positions.

### Edge Detection

Use Sobel or other edge detection kernels with pixel neighbors.

### Color Grading

Modify color channels using curves or lookup tables.

## Performance Tips

1. **Resolution scaling**: Use lower resolution buffers for expensive effects
2. **Minimize texture samples**: Each `texture2D()` call has a cost
3. **Avoid complex math**: Keep shader calculations simple when possible
4. **Use proper precision**: `lowp`, `mediump`, `highp` for mobile/performance

## Troubleshooting

- **Black screen**: Check that your shader has a valid `gl_FragColor` output
- **No effect visible**: Verify the Layer parameter matches your scene setup
- **Performance issues**: Reduce offscreen buffer resolution or simplify shader code

## Additional Resources

- **GLSL Tutorial**: Learn more about OpenGL Shading Language
- **Range Engine Documentation**: Official documentation for Range-specific features
- **Shader Examples**: Check the `Scripts` folder for more shader examples

## Example Filters Included

The repository includes several example filters:
- `AnalogTV.glsl`: CRT TV effect
- `ChromaticAberration.glsl`: RGB channel separation
- `SimpleToon.glsl`: Cel-shading effect
- `FractalTexturing.frag`: Procedural fractal textures

These can serve as templates for your own custom effects!
