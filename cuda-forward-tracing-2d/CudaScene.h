#pragma once

#ifndef __CUDACC__
#define __CUDACC__
#endif // !__CUDACC_
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <curand.h>
#include <curand_kernel.h>
#include <device_functions.h>

#define GLM_FORCE_CUDA
#define GLM_FORCE_RADIANS
#include <glm/glm.hpp>
#include <glm\gtc\constants.hpp>
#include <algorithm>
#include <glm\common.hpp>
#include <glm\gtc\quaternion.hpp>
#include <glm\gtx\quaternion.hpp>
#include <glm\gtc\matrix_transform.hpp>
#include <glm\gtx\matrix_transform_2d.hpp>
#include <glm/gtc/type_ptr.hpp>


#include <vector>





enum LightType{
	_POINT = 1,
	POINTDIRECTIONAL = 2,
	POINTANGULAR = 3,
	CIRCLE = 4,
	CIRCLEANGULAR = 5,
	LINE = 6,
	LINEDIRECTIONAL = 7,
};
enum NormalType{
	F = 0,
	B = 1,
	BOTH = 2
};
enum MaterialType{
	DIFFUSEREFL = 1,
	SPECULARREFL = 2,
	SPECULARGLASS = 3,
	DIFFUSETRANSM = 4
};
struct Transform{
	glm::mat3x3 t;
	glm::mat3x3 inv;
};
struct Material{
	glm::vec3 r;
	int type;
	glm::vec3 t;
	glm::vec3 b;
	glm::vec3 c;
};
struct Object{
	glm::uint8_t objectType;
	glm::uint8_t materialType;
	int normalType;
	Transform t;
};
struct Light{
	glm::vec3 color;
	float angle;
	glm::uint8_t lightType;
	Transform t;
};
struct Ray2D{
	glm::vec2 ro;
	glm::vec2 rd;
};
struct HitInfo{
	glm::vec2 normal;
	glm::vec2 point;
	int material;
};
struct RayInfo{
	glm::vec2 ro;
	glm::vec2 rd;
	glm::vec3 color;//xyz color
	float wavelength;
	int depth;
	float time;
	float speed;
	unsigned int padding[1];
};
struct VBOInfo{
	glm::vec2 pos;
	glm::vec2 padding;
	glm::vec3 color;
	float angle;
};
struct CudaScene{
	Object * objects;
	Light * lights;
	Material * materials;
	int objCount;
	int lightCount;
	int matCount;
	int maxDepth;
	int minDepth;
}; 

struct SceneDescription{
	std::vector<Object> objects;
	std::vector<Material> materials;
	std::vector<Light> lights;
};