/*
 * Copyright (C) 2012 Gregory Beauchamp
 *
 * ArvosRay.m - ArViewer_iOS
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

#import "ArvosRay.h"
#import "vectorUtil.h"

#import <Accelerate/Accelerate.h>

/* implementation de gluProject et gluUnproject */
/* M. Buffat 17/2/95 */

/*
 * Transform a point (column vector) by a 4x4 matrix.  I.e.  out = m * in
 * Input:  m - the 4x4 matrix
 *         in - the 4x1 vector
 * Output:  out - the resulting 4x1 vector.
 */
static void
transform_point(GLfloat outVector[4], const GLfloat m[16], const GLfloat a[4])
{
    vDSP_mmul((float*) m, 1, (float*) a, 1, outVector, 1, 4, 1, 4);
}

/*
 * Perform a 4x4 matrix multiplication  (product = a x b).
 * Input:  a, b - matrices to multiply
 * Output:  product - product of a and b
 */
static void
matmul(GLfloat * product, const GLfloat * a, const GLfloat * b)
{
    vDSP_mmul((float*) a, 1, (float*) b, 1, product, 1, 4, 4, 4);
}

/*
 * Compute inverse of 4x4 transformation matrix.
 * Code contributed by Jacques Leroy jle@star.be
 * Return GL_TRUE for success, GL_FALSE for failure (singular matrix)
 */
static GLboolean
invert_matrix(const GLfloat * m, GLfloat * out)
{
	/* NB. OpenGL Matrices are COLUMN major. */
    __CLPK_integer N = 4;
    __CLPK_integer error=0;
    __CLPK_integer *pivot = valloc(N*N*sizeof(__CLPK_integer));
 
    sgetrf_(&N, &N, (float*) m, &N, pivot, &error);
    if (error) {
        free(pivot);
        return GL_FALSE;
    }
    
    float *workspace = valloc(N*sizeof(float));
    sgetri_(&N, (float*) m, &N, pivot, workspace, &N, &error);
    
    free(pivot);
    free(workspace);
    
    return error == 0 ? GL_TRUE : GL_FALSE;
}



/* projection du point (objx,objy,obz) sur l'ecran (winx,winy,winz) */
//GLint GLAPIENTRY;
static GLboolean gluProject(GLfloat objx, GLfloat objy, GLfloat objz,
                            const GLfloat model[16], const GLfloat proj[16],
                            const GLint viewport[4],
                            GLfloat * winx, GLfloat * winy, GLfloat * winz)
{
	/* matrice de transformation */
	GLfloat in[4], out[4];
	
	/* initilise la matrice et le vecteur a transformer */
	in[0] = objx;
	in[1] = objy;
	in[2] = objz;
	in[3] = 1.0f;
	transform_point(out, model, in);
	transform_point(in, proj, out);
	
	/* d'ou le resultat normalise entre -1 et 1 */
	if (in[3] == 0.0f)
		return GL_FALSE;
	
	in[0] /= in[3];
	in[1] /= in[3];
	in[2] /= in[3];
	
	/* en coordonnees ecran */
	*winx = viewport[0] + (1.0f + in[0]) * viewport[2] / 2.0f;
	*winy = viewport[1] + (1.0f + in[1]) * viewport[3] / 2.0f;
	/* entre 0 et 1 suivant z */
	*winz = (1.0f + in[2]) / 2.0f;
	return GL_TRUE;
}


static GLboolean gluUnProject(GLfloat winx, GLfloat winy, GLfloat winz,
                              const GLfloat model[16], const GLfloat proj[16],
                              const GLint viewport[4],
                              GLfloat * obj)
{
	GLfloat m[16], A[16];
	GLfloat in[4];
	
	matmul(A, proj, model);
	invert_matrix(A, m);
	
	in[0] = (winx - viewport[0]) * 2.0f / viewport[2] - 1.0f;
	in[1] = (winy - viewport[1]) * 2.0f / viewport[3] - 1.0f;
	in[2] = 2.0f * winz - 1.0f; 
	in[3] = 1.0f;

    vec4MultMatrix(obj, m, in);
    
	return GL_TRUE;
}

@interface   ArvosRay () {
    GLfloat nearCoOrds[3];
    GLfloat farCoOrds[3];
}

@end

@implementation ArvosRay

- (id)initWithModelView:(GLfloat*)modelView
             projection:(GLfloat*)projection
                  width:(int)width
                 height:(int)height
                 xTouch:(GLfloat)xTouch
                 yTouch:(GLfloat)yTouch {
    
    if ((self = [super init])) {
        
        int viewport[] = { 0, 0, width, height };
        GLfloat temp[4];
        GLfloat temp2[4];
        
		// get the near and far cords for the click
        
		float winx = xTouch, winy = (float) viewport[3] - yTouch;
               
        temp[3] = 0;
		int result = gluUnProject(winx, winy, 1., modelView, projection, viewport, temp);
        vec4MultMatrix(temp2, modelView, temp);
        
        if( result == GL_TRUE)
        {
            nearCoOrds[0] = temp2[0] / temp2[3];
            nearCoOrds[1] = temp2[1] / temp2[3];
            nearCoOrds[2] = temp2[2] / temp2[3];
        }
        
        temp[3] = 0;
		result = gluUnProject(winx, winy, 0., modelView, projection, viewport, temp);
        vec4MultMatrix(temp2, modelView, temp);

        if( result == GL_TRUE)
        {
            farCoOrds[0] = temp2[0] / temp2[3];
            farCoOrds[1] = temp2[1] / temp2[3];
            farCoOrds[2] = temp2[2] / temp2[3];
        }
        
		self.p0 = farCoOrds;
		self.p1 = nearCoOrds;
    }

    return self;
}

@end
