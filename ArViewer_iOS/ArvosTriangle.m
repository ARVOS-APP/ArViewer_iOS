/*
 * Copyright (C) 2012 Gregory Beauchamp
 *
 * ArvosTriangle.m - ArViewer_iOS
 *
 *  Created by Peter Graf on 24.03.13.
 *
 * Derived from
 * http://android-raypick.blogspot.com/2012/04/first-i-want-to-state-this-is-my-first.html
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ArvosTriangle.h"
#import "ArvosRay.h"

#include "vectorUtil.h"
#include "math.h"

#define SMALL_NUM  0.00000001

@interface   ArvosTriangle () {
    GLfloat vec0[3];
    GLfloat vec1[3];
    GLfloat vec2[3];
}

@end

@implementation ArvosTriangle

-(id)init {
    if ((self = [super init])) {
        
        self.v0 = vec0;
        self.v1 = vec1;
        self.v2 = vec2;
    }
    return self;
}

// intersectRayAndTriangle(): intersect a ray with a 3D triangle
// Input: a ray R, and a triangle T
// Output: *I = intersection point (when it exists)
// Return: -1 = triangle is degenerate (a segment or point)
// 0 = disjoint (no intersect)
// 1 = intersect in unique point I1
// 2 = are in the same plane

-(int)intersectWithRay:(ArvosRay*)ray
           resultPoint:(GLfloat*)resultpoint {
    
    float u[3], v[3], n[3]; // triangle vectors
    float dir[3], w0[3], w[3]; // ray vectors
    float r, a, b; // params to calc ray-plane intersect
    
    // get triangle edge vectors and plane normal
    vec3Subtract(u, self.v1, self.v0);
    vec3Subtract(v ,self.v2, self.v0);
    
    vec3CrossProduct(n ,u, v); // cross product
    
    if( n[0] == 0. && n[1] == 0. && n[2] == 0. )
    { // triangle is degenerate
        return -1; // do not deal with this case
    }
    vec3Subtract(dir, ray.p1, ray.p0); // ray direction vector
    vec3Subtract(w0 , ray.p0, self.v0);
    a = -vec3DotProduct(n, w0);
    b = vec3DotProduct(n, dir);
    if (abs(b) < SMALL_NUM)
    { // ray is parallel to triangle plane
        if (a == 0)
        { // ray lies in triangle plane
            return 2;
        }
        else
        {
            return 0; // ray disjoint from plane
        }
    }
    
    // get intersect point of ray with triangle plane
    r = a / b;
    if (r < 0.0f)
    { // ray goes away from triangle
        return 0; // => no intersect
    }
    // for a segment, also test if (r > 1.0) => no intersect
    
    float product[3];
    product[0] = dir[0] * r;
    product[1] = dir[1] * r;
    product[2] = dir[2] * r;
    
    vec3Add(resultpoint, ray.p0, product); // intersect point of ray and a plane
    
    // is I inside T?
    float uu, uv, vv, wu, wv, D;
    uu = vec3DotProduct(u, u);
    uv = vec3DotProduct(u, v);
    vv = vec3DotProduct(v, v);
    vec3Subtract(w, resultpoint, self.v0);
    wu = vec3DotProduct(w, u);
    wv = vec3DotProduct(w, v);
    D = (uv * uv) - (uu * vv);
    
    // get and test parametric coords
    float s, t;
    s = ((uv * wv) - (vv * wu)) / D;
    if (s < 0.0f || s > 1.0f) // I is outside T
        return 0;
    t = (uv * wu - uu * wv) / D;
    if (t < 0.0f || (s + t) > 1.0f) // I is outside T
        return 0;
    
    return 1; // I is in T
}
@end
