# sokol-template.zig
Zig bindings for the sokol headers are here: https://github.com/floooh/sokol-zig

## Build and Run

The main branch is supposed to work with the Mach nominated zig version (but may
fall behind from time to time). Download it from [Here](https://machengine.org/about/nominated-zig/)    
Don't forget to add Zig's executable folder to your operating systems evironment `PATH`.

Check the git branches for use with older Zig versions.

To build and run the native version from root directory:

```bash
zig build run
```

...or for the web version run (NOTE: this will install a local Emscripten SDK into the Zig cache, so the first
run will take a little while):

```bash
zig build -Dtarget=wasm32-emscripten run
```

...or to build a release versions:

```bash
zig build -Doptimize=ReleaseSafe run
zig build -Doptimize=ReleaseSmall -Dtarget=wasm32-emscripten run
```

On Windows, rendering is done via D3D11, on Linux via OpenGL, on macOS via Metal
and the web version uses WebGL2.

On Linux, you need to install the usual dev-packages for GL-, X11- and ALSA-development.
