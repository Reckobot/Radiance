#define AMBIENT 0.25 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.05 1.1 1.15 1.2 1.25 1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65 1.7 1.75 1.8 1.85 1.9 1.95 2.0]
#define SUNBRIGHTNESS 3.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0]
#define SUNROTATION 45 //[-90 -85 -80 -75 -70 -65 -60 -55 -50 -45 -40 -35 -30 -25 -20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90]
#define HQSHADOWS
#define SHADOWSOFTNESS 1.0 //[0.0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1.0]
#define DISTANTFOG
#define FANCYFOG
#define MATERIAL 3 //[1 2 3]

//fancy fog stuff
#define FOGOPACITY 1.0 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0 3.25 3.5 3.75 4.0 4.25 4.5 4.75 5.0]
#define FOGSIZE 2500 //[10 100 500 1000 2500 5000 10000 20000 30000 40000 50000 60000 70000 80000 90000 100000]
#define FOGHEIGHT 50 //[0 25 50 75 100 125 150 175 200 225 250 275 300]
#define FOGTHICKNESS 25 //[0 5 10 12.5 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100]
#define FOGSTEPS 200 //[10 50 100 200 300 400 500 600 700 800 900 1000]
#define FOGDIST 1 //[1 2 3 4 5 6 7 8]
#define FOGLAYERS 2 //[1 2 3 4 5 6 7 8]

//#define SSR
//#define SSGI

#define FOGRES 1.0 //[0.25 0.5 0.75 1.0]

#define SSR_STEPS 64 //[2 4 8 16 32 64 128 192 256 512 1024]
#define SSR_DIST 0.25 //[0.01 0.02 0.03 0.04 0.05 0.06 0.075 0.08 0.09 0.1 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2.0 3.0 4.0 5.0]
#define SSR_RES 1.0 //[0.25 0.5 0.75 1.0]

#define SSGI_STEPS 6 //[2 4 8 12 16 32 64 128 256 512 1024]
#define SSGI_SAMPLES 64 //[2 4 8 16 32 64 84 96 128 256 512 1024]
#define SSGI_RES 1.0 //[0.25 0.5 0.75 1.0]
#define SSGI_DIST 1.0 //[0.1 0.2 0.25 0.5 0.75 1.0]


const vec3 blocklightColor = vec3(1,1,1);
const vec3 skylightColor = vec3(1,1,1);
const vec3 sunlightColor = vec3(2,1.5,1);
const vec3 ambientColor = vec3(1,1.5,2);
uniform vec3 fogColor;

uniform int logicalHeightLimit;