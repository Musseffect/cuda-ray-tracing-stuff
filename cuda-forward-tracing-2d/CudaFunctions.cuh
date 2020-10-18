#pragma once

#include "CudaScene.h"

#ifdef __INTELLISENSE__
#define __device__
#define __constant__
#define __host__
#define __global__
#endif


__host__ Transform createTransform(glm::vec2 t, float r, glm::vec2 s);

__constant__ float spectrumHigh = 700.0f;
__constant__ float spectrumLow = 400.0f;

__constant__ const float rho_R[] = { 0.021592459f, 0.020293111f, 0.021807906f, 0.023803297f, 0.025208132f, 0.025414957f, 0.024621282f, 0.020973705f, 0.015752802f, 0.01116804f, 0.008578277f, 0.006581877f, 0.005171723f, 0.004545205f, 0.00414512f, 0.004343112f, 0.005238155f, 0.007251939f, 0.012543656f, 0.028067132f, 0.091342277f, 0.484081092f, 0.870378324f, 0.939513128f, 0.960926994f, 0.968623763f, 0.971263883f, 0.972285819f, 0.971898742f, 0.972691859f, 0.971734812f, 0.97234454f, 0.97150339f, 0.970857997f, 0.970553866f, 0.969671404f };
__constant__ const float rho_G[] = { 0.010542406f, 0.010878976f, 0.011063512f, 0.010736566f, 0.011681813f, 0.012434719f, 0.014986907f, 0.020100392f, 0.030356263f, 0.063388962f, 0.173423837f, 0.568321142f, 0.827791998f, 0.916560468f, 0.952002841f, 0.964096452f, 0.970590861f, 0.972502542f, 0.969148203f, 0.955344651f, 0.892637233f, 0.5003641f, 0.116236717f, 0.047951391f, 0.027873526f, 0.020057963f, 0.017382174f, 0.015429109f, 0.01543808f, 0.014546826f, 0.015197773f, 0.014285896f, 0.015069123f, 0.015506263f, 0.015545797f, 0.016302839f };
__constant__ const float rho_B[] = { 0.967865135f, 0.968827912f, 0.967128582f, 0.965460137f, 0.963110055f, 0.962150324f, 0.960391811f, 0.958925903f, 0.953890935f, 0.925442998f, 0.817997886f, 0.42509696f, 0.167036273f, 0.078894327f, 0.043852038f, 0.031560435f, 0.024170984f, 0.020245519f, 0.01830814f, 0.016588218f, 0.01602049f, 0.015554808f, 0.013384959f, 0.012535491f, 0.011199484f, 0.011318274f, 0.011353953f, 0.012285073f, 0.012663188f, 0.012761325f, 0.013067426f, 0.013369566f, 0.013427487f, 0.01363574f, 0.013893597f, 0.014025757f };


__device__ float rand1f(curandState_t* state);

__device__ float toWaveIntensity(glm::vec3 rgb, float wavelength);
__device__ float xFit_1931(float wave);
__device__ float yFit_1931(float wave);
__device__ float zFit_1931(float wave);
__host__ __device__ glm::vec3 XYZToRGB(glm::vec3 xyz);


__device__ float circle(const Ray2D& ray, glm::vec2& normal);
__device__ float line(const Ray2D& ray, glm::vec2& normal);

__device__ float intersectShape(int shapeType, const Ray2D& ray, glm::vec2& normal);
__device__ float intersectObject(const Ray2D& ray, const Object& object, glm::vec2& normal);
__device__ float intersectLight(const Ray2D& ray, Light& light);
__device__ bool findIntersection(const Ray2D&ray, Object* objects, int objCount, Light* lights, int lightCount, HitInfo& info);

__device__ Ray2D localToWorld(const Transform& t, const Ray2D&ray);
__device__ Ray2D worldToLocal(const Transform& t, const Ray2D&ray);
__device__ glm::vec2 localToWorldN(const Transform& t, glm::vec2& normal);
__device__ glm::vec2 getUniformCircle(curandState_t* state);
__device__ glm::vec2 getUniformHemiCircle(glm::vec2 dir, curandState_t* state);
__device__ glm::vec2 getCosDistribution(glm::vec2 dir, curandState_t* state);
__device__ Ray2D sampleRay(const Light* light, float* pdf, curandState_t* state);
__device__ void swap(float& a, float& b);
__device__ float frDielectric(float cosThetaI, float etaI, float etaT);
__device__ float getRefractionIndex(float wave, glm::vec3 b, glm::vec3 c);
__device__ glm::vec2 traceRect(const Ray2D& ray, glm::vec2 min, glm::vec2 max);

__global__ void kernelLinePulse(RayInfo* infoArray, VBOInfo *vbo, const CudaScene scene, curandState_t*states, int* rayCount, int size, float time, float dt);

__global__ void kernelLine(RayInfo* infoArray, VBOInfo *vbo, const CudaScene scene, curandState_t*states, int* rayCount, int size, float time);

__global__ void curandInitKernel(curandState_t*states, int seed, int size);
