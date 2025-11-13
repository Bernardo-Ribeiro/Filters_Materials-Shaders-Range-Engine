from Range import types, logic, render
from collections import OrderedDict

buffe = """
uniform sampler2D bgl_RenderedTexture;

uniform float bgl_RenderedTextureWidth;
uniform float bgl_RenderedTextureHeight;

void main() {
    vec2 texcoord = gl_TexCoord[0].st;
    vec2 pixelSize = vec2(1.0 / bgl_RenderedTextureWidth, 1.0 / bgl_RenderedTextureHeight);
    vec4 color = texture2D(bgl_RenderedTexture, texcoord);
    gl_FragColor = color;
}

"""

image = """
uniform sampler2D bgl_RenderedBuffe;
uniform sampler2D bgl_RenderedTexture;

vec2 texcoord = gl_TexCoord[0].st;

void main() {
    vec4 bufferTex = texture2D(bgl_RenderedBuffe, gl_TexCoord[0].st);
    vec4 renderedTex = texture2D(bgl_RenderedTexture, gl_TexCoord[0].st);

    gl_FragColor = renderedTex + bufferTex;
}

"""

class filterShader(types.KX_PythonComponent):
    args = OrderedDict([
        ("Layer", 0)
    ])

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

    def update(self):
        pass
