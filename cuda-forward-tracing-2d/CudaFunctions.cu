#include "CudaFunctions.cuh"




#undef max
#undef min





__host__ Transform createTransform(glm::vec2 t, float r, glm::vec2 s){
	glm::mat3 mat = glm::mat3(1.0f);
	mat = glm::translate(mat, t);
	mat = glm::rotate(mat, r);
	mat = glm::scale(mat, s);
	glm::mat3 invMat = inverse(mat);
	return Transform{ invMat, mat };
}

__device__ float rand1f(curandState_t* state){
	return curand_uniform(state);
}

__device__ float toWaveIntensity(glm::vec3 rgb, float wavelength){
	float number = (wavelength - 380.0f) / (730.0f - 380.0f);
	number = glm::max(glm::min(1.0f, number), 0.0f);
	int bin = glm::floor(number * 35.0f);
	int next = glm::max(glm::min(35, bin + 1), 0);
	return glm::dot(glm::mix(glm::vec3(rho_R[bin], rho_G[bin], rho_B[bin]), glm::vec3(rho_R[next], rho_G[next], rho_B[next]), glm::fract(number*35.0f)), rgb);
}
__device__ float xFit_1931(float wave){
	float t1 = (wave - 442.0)*((wave < 442.0) ? 0.0624 : 0.0374);
	float t2 = (wave - 599.8)*((wave < 599.8) ? 0.0264 : 0.0323);
	float t3 = (wave - 501.1)*((wave < 501.1) ? 0.0490 : 0.0382);
	return 0.362*glm::exp(-0.5*t1*t1) + 1.056*glm::exp(-0.5*t2*t2)
		- 0.065*glm::exp(-0.5*t3*t3);
}
__device__ float yFit_1931(float wave){
	float t1 = (wave - 568.8)*((wave < 568.8) ? 0.0213 : 0.0247);
	float t2 = (wave - 530.9)*((wave < 530.9) ? 0.0613 : 0.0322);
	return 0.821*glm::exp(-0.5*t1*t1) + 0.286*glm::exp(-0.5*t2*t2);
}
__device__ float zFit_1931(float wave){
	float t1 = (wave - 437.0)*((wave < 437.0) ? 0.0845 : 0.0278);
	float t2 = (wave - 459.0)*((wave < 459.0) ? 0.0385 : 0.0725);
	return 1.217*glm::exp(-0.5*t1*t1) + 0.681*glm::exp(-0.5*t2*t2);
}
__host__ __device__ glm::vec3 XYZToRGB(glm::vec3 xyz){
	const glm::mat3 XYZ_to_RGB(2.3706743f, -0.9000405f, -0.4706338f,
		-0.5138850f, 1.4253036f, 0.0885814f,
		0.0052982f, -0.0146949f, 1.0093968f);
	return xyz*XYZ_to_RGB;
}
//circle at 0,0 with radius 1
__device__ float circle(const Ray2D& ray, glm::vec2& normal){
	float a = glm::dot(ray.rd, ray.rd);
	float b = glm::dot(ray.rd, ray.ro);
	float c = glm::dot(ray.ro, ray.ro) - 1.0f;
	float d = b * b - c * a;
	if (d >= 0.0){
		d = sqrt(d);
		float t = (-b - d) / a;
		if (t < 0.0){
			t = (-b + d) / a;
		}
		normal = glm::normalize(ray.ro + ray.rd*t);
		return t;
	}
	return -1.0f;
}
//line with points 0,0 and 1,0
__device__ float line(const Ray2D& ray, glm::vec2& normal){
	float t = (-ray.ro.y) / ray.rd.y;
	if (t >= 0){
		glm::vec2 point = ray.ro + ray.rd*t;
		if (glm::abs(point.x - 0.5f) <= 0.5f){
			normal.x = 0.0f;
			normal.y = 1.0f;
			return t;
		}
	}
	return -1.0f;
}
__device__ float intersectShape(int shapeType, const Ray2D& ray, glm::vec2& normal){
	switch (shapeType){
		case 0:
			return line(ray, normal);
		case 1:
			return circle(ray, normal);
	}
	return -1.0f;
}
__device__ float intersectObject(const Ray2D& ray, const Object& object, glm::vec2& normal){
	Ray2D tRay;
	tRay = worldToLocal(object.t, ray);
	float t = intersectShape(object.objectType, tRay, normal);
	normal = glm::normalize(localToWorldN(object.t, normal));
	return t;
}
__device__ float intersectLight(const Ray2D& ray, Light& light){
	switch (light.lightType){
	case _POINT:
		break;
	case POINTDIRECTIONAL:
		break;
	case POINTANGULAR:
		break;
	case CIRCLE:{
				   float a = glm::dot(ray.rd, ray.rd);
				   float b = glm::dot(ray.rd, ray.ro);
				   float c = glm::dot(ray.ro, ray.ro) - 1.0f;
				   float d = b * b - c * a;
				   if (d >= 0.0){
					   d = sqrt(d);
					   float t = (-b - d) / a;
					   if (t < 0.0){
						   t = (-b + d) / a;
					   }
					   return t;
				   }
				   break;
	}
	case CIRCLEANGULAR:{
						  float a = glm::dot(ray.rd, ray.rd);
						  float b = glm::dot(ray.rd, ray.ro);
						  float c = glm::dot(ray.ro, ray.ro) - 1.0f;
						  float d = b * b - c * a;
						  if (d >= 0.0){
							  float ax = -glm::cos(light.angle);
							  d = sqrt(d);
							  float t = (-b - d) / a;
							  if (t < 0.0){
								  t = (-b + d) / a;
							  }
							  else{
								  glm::vec2 p = ray.ro + ray.rd*t;
								  if (p.x < ax){
									  t = (-b + d) / a;
									  p = ray.ro + ray.rd*t;
									  if (p.x < ax)
										  return -1.0f;
								  }
							  }
							  return t;
						  }
						  break;
	}
	case LINE:
	case LINEDIRECTIONAL:{
							float t = (-ray.ro.x) / ray.rd.x;
							if (t >= 0){
								glm::vec2 point = ray.ro + ray.rd*t;
								if (glm::abs(point.y) <= 0.5f){
									return t;
								}
							}
	}
	}
	return -1.0f;
}
__device__ bool findIntersection(const Ray2D&ray, Object* objects, int objCount, Light* lights, int lightCount, HitInfo& info){
	float t0 = 10e8;
	int id = -1;
	for (int i = 0; i < objCount; i++){
		glm::vec2 normal;
		float t = intersectObject(ray, objects[i], normal);
		if (t <= t0 && t >= 0.0){
			t0 = t;
			info.normal = normal;
			info.material = objects[i].materialType;
			id = i;
		}
	}
	bool lightInter = false;
	for (int i = 0; i < lightCount; i++){
		Ray2D tRay;
		tRay = worldToLocal(lights[i].t, ray);
		float t = intersectLight(tRay, lights[i]);
		if (t <= t0 && t >= 0.0){
			lightInter = true;
			info.material = -1;
			t0 = t;
		}
	}
	info.point = ray.ro + ray.rd*t0;
	if (lightInter)
		return true;
	if (id == -1)
		return false;
	switch (objects[id].normalType){
		case NormalType::B:
			info.normal = -info.normal;
			break;
		case NormalType::BOTH:
			info.normal = info.normal * glm::sign(-glm::dot(info.normal, ray.rd));
			break;
	}
	return true;
}

__device__ Ray2D localToWorld(const Transform& t, const Ray2D&ray){
	Ray2D result;
	result.ro = glm::vec2(t.inv*glm::vec3(ray.ro, 1.0f));
	result.rd = glm::vec2(t.inv*glm::vec3(ray.rd, 0.0f));
	return result;
}
__device__ Ray2D worldToLocal(const Transform& t, const Ray2D&ray){
	Ray2D result;
	result.ro = glm::vec2(t.t*glm::vec3(ray.ro, 1.0f));
	result.rd = glm::vec2(t.t*glm::vec3(ray.rd, 0.0f));
	return result;
}
__device__ glm::vec2 localToWorldN(const Transform& t, glm::vec2& normal){
	return glm::vec2(glm::vec3(normal, 0.0f)*t.t);
}
__device__ glm::vec2 getUniformCircle(curandState_t* state){
	float angle = rand1f(state)*glm::two_pi<float>();
	return glm::vec2(glm::cos(angle), glm::sin(angle));
}
__device__ glm::vec2 getUniformHemiCircle(glm::vec2 dir, curandState_t* state){
	float angle = rand1f(state)*glm::pi<float>();
	glm::vec2 tang(-dir.y, dir.x);
	return glm::cos(angle)*tang + glm::sin(angle)*dir;
}
__device__ glm::vec2 getCosDistribution(glm::vec2 dir, curandState_t* state){
	glm::vec2 normal(-dir.y, dir.x);
	float x = rand1f(state)*2.0f - 1.0f;
	return normal * x + dir * glm::sqrt(1.0f - x * x);
}
__device__ Ray2D sampleRay(const Light* light, float* pdf, curandState_t* state){
	Ray2D ray;
	switch (light->lightType){
	case _POINT:{
				   ray.ro = glm::vec2(0.0f, 0.0f);
				   ray.rd = getUniformCircle(state);
				   *pdf = glm::one_over_two_pi<float>();
				   break;
	}
	case POINTDIRECTIONAL:{
							 ray.ro = glm::vec2(0.0f, 0.0f);
							 ray.rd = glm::vec2(1.0f, 0.0f);
							 *pdf = 1.0f;
							 //return one possible ray
							 break;
	}
	case POINTANGULAR:{
						 ray.ro = glm::vec2(0.0f, 0.0f);
						 float angle = (rand1f(state) - 0.5f)*light->angle;
						 ray.rd = glm::vec2(glm::cos(angle), glm::sin(angle));
						 ray.ro += ray.rd*0.001f;
						 *pdf = 1.0f / light->angle;
						 break;
	}
	case CIRCLE:{
				   ray.ro = getUniformCircle(state);
				   ray.rd = getUniformCircle(state);
				   *pdf = glm::one_over_two_pi<float>()*glm::one_over_two_pi<float>();
				   break;
	}
	case CIRCLEANGULAR:{
						  float angle = (rand1f(state) - 0.5f)*light->angle;
						  ray.ro = glm::vec2(glm::cos(angle), glm::sin(angle));
						  ray.rd = getUniformCircle(state);
						  *pdf = glm::one_over_two_pi<float>() / light->angle;
						  break;
	}
	case LINE:{
				 ray.ro = glm::vec2(0.0, rand1f(state) - 0.5f);
				 ray.rd = getUniformCircle(state);
				 *pdf = glm::one_over_two_pi<float>();//unit length line
				 break;
	}
	case LINEDIRECTIONAL:{
							ray.ro = glm::vec2(0.0, rand1f(state) - 0.5f);
							ray.rd = glm::vec2(1.0f, 0.0f);
							*pdf = 1.0f;//unit length line
							break;
	}
	}
	ray = localToWorld(light->t, ray);
	ray.rd = glm::normalize(ray.rd);
	return ray;
}
__device__ void swap(float& a, float& b){
	float t = a;
	a = b;
	b = t;
}
__device__ float frDielectric(float cosThetaI, float etaI, float etaT){
	cosThetaI = glm::clamp(cosThetaI, -1.0f, 1.0f);
	bool outside = cosThetaI > 0.0f;
	if (!outside){
		swap(etaI, etaT);
		cosThetaI = glm::abs(cosThetaI);
	}
	float sinThetaI = glm::sqrt(glm::max(0.0f, 1.0f - cosThetaI * cosThetaI));
	float sinThetaT = etaI / etaT * sinThetaI;
	float cosThetaT = glm::sqrt(glm::max(0.0f, 1.0f - sinThetaT * sinThetaT));
	float rparl = (etaT*cosThetaI - etaI * cosThetaT) /
		(etaT*cosThetaI + etaI * cosThetaT);
	float rperp = ((etaI * cosThetaI) - (etaT * cosThetaT)) /
		((etaI * cosThetaI) + (etaT * cosThetaT));
	return (rparl*rparl + rperp * rperp)*0.5f;
}
__device__ float getRefractionIndex(float wave, glm::vec3 b, glm::vec3 c){
	float waveSqr = wave * wave;
	glm::vec3 num = b * waveSqr;
	glm::vec3 denum = waveSqr - c;
	num = num / denum;
	return sqrt(1.0 + glm::dot(num, glm::vec3(1.0)));
}
__device__ glm::vec2 traceRect(const Ray2D& ray, glm::vec2 min, glm::vec2 max){
	float tmin, tmax, tymin, tymax;
	glm::vec2 invDir = 1.0f / ray.rd;
	tmin = ((ray.rd.x >= 0.0 ? min.x : max.x) - ray.ro.x) * invDir.x;
	tmax = ((ray.rd.x >= 0.0 ? max.x : min.x) - ray.ro.x) * invDir.x;
	tymin = ((ray.rd.y >= 0.0 ? min.y : max.y) - ray.ro.y) * invDir.y;
	tymax = ((ray.rd.y >= 0.0 ? max.y : min.y) - ray.ro.y) * invDir.y;
	if ((tmin > tymax) || (tymin > tmax))
		return glm::vec2(-1.0f, -1.0f);
	if (tymin > tmin)
		tmin = tymin;
	if (tymax < tmax)
		tmax = tymax;
	return glm::vec2(tmin, tmax);
}

__device__ Ray2D genRay(Light* lights, int lightCount, RayInfo &rayInfo, float& currentTime, curandState_t* state){
	int lightIndex = floor(rand1f(state)*lightCount);
	Light* light = lights+lightIndex;
	float pdf = 1.0f;
	Ray2D ray = sampleRay(light, &pdf, state);
	pdf /= lightCount;
	ray.ro += ray.rd*0.001f;

	rayInfo.ro = ray.ro;
	rayInfo.rd = ray.rd;
	rayInfo.time = 0;
	rayInfo.speed = 1.0f;
	currentTime = 0;
	float wavelength = glm::mix(spectrumLow, spectrumHigh, rand1f(state));
	float intensity = toWaveIntensity(light->color, wavelength)*pdf;
	rayInfo.wavelength = wavelength;
	rayInfo.color = intensity*glm::max(XYZToRGB(glm::vec3(xFit_1931(wavelength), yFit_1931(wavelength), zFit_1931(wavelength))), 0.0f);//color of one ray = power*pdf
	return ray;
}

__device__ void shade(Ray2D& ray, const HitInfo& hitInfo, Material * materials,RayInfo& rayInfo,curandState_t* state){
	glm::vec2 nr;
	Material* material = materials+hitInfo.material;
	glm::vec3 lr;
	float dotn = glm::dot(ray.rd, hitInfo.normal);
	rayInfo.depth++;
	glm::vec3 f(1.0f);
	float pdf = 1.0f;
	switch (material->type){
		case DIFFUSEREFL:{
			if (dotn >= 0.0f){
				rayInfo.depth = 0;
				break;
			}
			nr = getCosDistribution(hitInfo.normal, state);
			float dt = glm::dot(nr, hitInfo.normal);
			f = material->r*0.5f;
			pdf = abs(dt)*0.5f;
			break;
		}
		//sample random direction in hemicircle
		case DIFFUSETRANSM:{
			nr = getCosDistribution(hitInfo.normal*glm::sign(dotn), state);
			float dt = glm::dot(nr, hitInfo.normal);
			f = material->t*0.5f;
			pdf = abs(dt)*0.5f;
			break;
		}
		//sample random direction in opposite hemicircle
		case SPECULARGLASS:{
			float rIndex = getRefractionIndex(rayInfo.wavelength / 1000.0f, material->b, material->c);
			float etaA = 1.0f;
			float etaB = rIndex;
			float F = frDielectric(-dotn, etaA, etaB);
			float c = rand1f(state);
			if (c < F){
				nr = glm::reflect(ray.rd, hitInfo.normal);
				float dt = glm::dot(nr, hitInfo.normal);
				pdf = F;
				f = F * material->r / glm::abs(dt);
				//f *= 0.0f;
			}
			else{
				bool entering = dotn < 0;
				float etaI = entering ? etaA : etaB;
				float etaT = entering ? etaB : etaA;
				nr = glm::refract(ray.rd, -hitInfo.normal*glm::sign(dotn), etaI / etaT);
				float dt = glm::dot(nr, hitInfo.normal);
				glm::vec3 ft = material->t * (1.0f - F);
				pdf = 1.0f - F;
				if ((nr.x*nr.x + nr.y*nr.y) < 0.01f)
					f = glm::vec3(0.0f);
				else
					f = ft / glm::abs(dt);
				rayInfo.speed = rayInfo.speed*(etaT / etaI);
			}
			break;
		}
		case SPECULARREFL:{
			float rIndex = getRefractionIndex(rayInfo.wavelength / 1000.0f, material->b, material->c);
			if (dotn >= 0.0f){
				rayInfo.depth = 0;
				break;
			}
			nr = glm::reflect(ray.rd, hitInfo.normal);
			float dt = glm::dot(nr, hitInfo.normal);
			f = material->r*frDielectric(-dotn, 1.0, rIndex) / abs(dt);
			pdf = 1.0;
			break;
		}
	}
	lr = rayInfo.color * f * glm::abs(glm::dot(nr, hitInfo.normal)) / pdf;
	rayInfo.ro = hitInfo.point + hitInfo.normal*glm::sign(glm::dot(nr, hitInfo.normal))*0.0005f;//new position
	rayInfo.rd = nr;
	rayInfo.color = lr;
}

__global__ void kernelLinePulse(RayInfo* infoArray, VBOInfo *vbo, const CudaScene scene, curandState_t*states, int* rayCount, int size, float time, float dt){
	unsigned int index = blockIdx.x*blockDim.x + threadIdx.x;
	if (index >= size){
		return;
	}
	curandState_t * state = &states[index];
	/*atomicAdd(rayCount, 1);
	vbo[index * 2] = VBOInfo{ glm::vec2(index),glm::vec2(0.0f), glm::vec3(1.0f), 0.1 };
	vbo[index * 2 + 1] = VBOInfo{ glm::vec2(index), glm::vec2(0.0f), glm::vec3(0.5f, 1.0f, 0.1f), 0.4 };
	infoArray[index].objectIndex = index;
	return;*/
	RayInfo rayInfo = infoArray[index];
	Ray2D ray;
	float currentTime = rayInfo.time;
	if (rayInfo.depth == 0){
		atomicAdd(rayCount, 1);//compute total number of rays for color normalization
		ray = genRay(scene.lights, scene.lightCount, rayInfo, currentTime, state);
	}
	else{
		ray.ro = rayInfo.ro;
		ray.rd = rayInfo.rd;
	}
	float angle = glm::atan(ray.rd.y, ray.rd.x);
	glm::vec3 currentColor = rayInfo.color;
	HitInfo hitInfo;
	if (findIntersection(ray, scene.objects, scene.objCount, scene.lights, scene.lightCount, hitInfo)){
		rayInfo.time = currentTime + glm::distance(ray.ro, hitInfo.point) / rayInfo.speed;
		if (hitInfo.material == -1){
			rayInfo.depth = 0;
			rayInfo.ro = hitInfo.point;
		}
		else{
			shade(ray, hitInfo, scene.materials, rayInfo, state);
		}
	}
	else{
		glm::vec2 t2 = traceRect(ray, glm::vec2(-1.0f), glm::vec2(1.0f));
		float t = glm::max(t2.y, 0.0f);
		//intersect ray with camera bounds
		//set t value

		rayInfo.ro = ray.ro + ray.rd*t;
		rayInfo.depth = 0;
		rayInfo.time = currentTime + t / rayInfo.speed;
	}
	if (rayInfo.depth>scene.maxDepth)
		rayInfo.depth = 0;
	//russian rullete path termination
	else if (rayInfo.depth > scene.minDepth){
		float q = glm::max((float)0.05f, 1.0f - glm::max(rayInfo.color.x, glm::max(rayInfo.color.y, rayInfo.color.z)));
		if (rand1f(state) < q)
			rayInfo.depth = 0;
		else
			rayInfo.color /= 1 - q;
	}
	float t2 = time + dt;
	if (t2 <= rayInfo.time)
		rayInfo.depth = 0;
	if (time >= rayInfo.time){
		vbo[index * 2] = VBOInfo{ rayInfo.ro, glm::vec2(0.0f), glm::vec3(0.0f), angle };
		vbo[index * 2 + 1] = VBOInfo{ rayInfo.ro, glm::vec2(0.0f), glm::vec3(0.0f), angle };
	}
	else if (t2 <= currentTime){
		vbo[index * 2] = VBOInfo{ rayInfo.ro, glm::vec2(0.0f), glm::vec3(0.0f), angle };
		vbo[index * 2 + 1] = VBOInfo{ rayInfo.ro, glm::vec2(0.0f), glm::vec3(0.0f), angle };
	}
	else{
		float t1 = glm::max(time, currentTime); 
		t2 = glm::min(t2, rayInfo.time);
		vbo[index * 2] = VBOInfo{ glm::mix(ray.ro, rayInfo.ro, (t1 - currentTime) / (rayInfo.time - currentTime)), glm::vec2(0.0f), currentColor, angle };
		vbo[index * 2 + 1] = VBOInfo{ glm::mix(ray.ro, rayInfo.ro, (t2 - currentTime) / (rayInfo.time - currentTime)), glm::vec2(0.0f), currentColor, angle };
	}
	//put vboinfo with old ray info
	infoArray[index] = rayInfo;
}

__global__ void kernelLine(RayInfo* infoArray, VBOInfo *vbo, const CudaScene scene, curandState_t*states, int* rayCount, int size, float time){
	unsigned int index = blockIdx.x*blockDim.x + threadIdx.x;
	if (index >= size){
		return;
	}
	curandState_t * state = &states[index];
	RayInfo rayInfo = infoArray[index];
	Ray2D ray;
	float currentTime = rayInfo.time;
	if (rayInfo.depth == 0){
		atomicAdd(rayCount, 1);//compute total number of rays for color normalization
		ray=genRay(scene.lights,scene.lightCount,rayInfo,currentTime,state);
	}
	else{
		ray.ro = rayInfo.ro;
		ray.rd = rayInfo.rd;
	}
	float angle = glm::atan(ray.rd.y, ray.rd.x);
	glm::vec3 currentColor = rayInfo.color;
	HitInfo hitInfo;
	if (findIntersection(ray, scene.objects, scene.objCount, scene.lights, scene.lightCount, hitInfo)){
		rayInfo.time = currentTime + glm::distance(ray.ro, hitInfo.point) / rayInfo.speed;
		if (hitInfo.material == -1){
			rayInfo.depth = 0;//gen new ray next time
			rayInfo.ro = hitInfo.point;
		}
		else{
			shade(ray,hitInfo,scene.materials,rayInfo,state);
		}
	}
	else{
		glm::vec2 t2 = traceRect(ray, glm::vec2(-1.0f), glm::vec2(1.0f));
		float t = glm::max(t2.y, 0.0f);
		//intersect ray with camera bounds
		//set t value
		rayInfo.ro = ray.ro + ray.rd*t;
		rayInfo.depth = 0;
		rayInfo.time = currentTime + t / rayInfo.speed;
	}
	if (rayInfo.depth>scene.maxDepth)
		rayInfo.depth = 0;
	//russian rullete path termination
	else if (rayInfo.depth > scene.minDepth){
		float q = glm::max((float)0.05f, 1.0f - glm::max(rayInfo.color.x, glm::max(rayInfo.color.y, rayInfo.color.z)));
		if (rand1f(state) < q)
			rayInfo.depth = 0;
		else
			rayInfo.color /= 1 - q;
	}

	if (rayInfo.time >= time&& currentTime <= time){
		vbo[index * 2] = VBOInfo{ ray.ro, glm::vec2(0.0f), currentColor, angle };
		vbo[index * 2 + 1] = VBOInfo{ glm::mix(ray.ro, rayInfo.ro, (time - currentTime) / (rayInfo.time - currentTime)), glm::vec2(0.0f), currentColor, angle };
		rayInfo.depth = 0;
	}
	else{
		vbo[index * 2] = VBOInfo{ ray.ro, glm::vec2(0.0f), currentColor, angle };
		vbo[index * 2 + 1] = VBOInfo{ rayInfo.ro, glm::vec2(0.0f), currentColor, angle };
	}
	//put vboinfo with old ray info
	infoArray[index] = rayInfo;
}

__global__ void curandInitKernel(curandState_t*states, int seed, int size){
	unsigned int index = blockIdx.x*blockDim.x + threadIdx.x;
	if (index >= size){
		return;
	}
	curandState_t * state = &states[index];
	curand_init(seed, index, 0, state);
}