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
#include "vectorUtil.h"

/* implementation de gluProject et gluUnproject */
/* M. Buffat 17/2/95 */

/*
 * Transform a point (column vector) by a 4x4 matrix.  I.e.  out = m * in
 * Input:  m - the 4x4 matrix
 *         in - the 4x1 vector
 * Output:  out - the resulting 4x1 vector.
 */
static void
transform_point(GLfloat out[4], const GLfloat m[16], const GLfloat in[4])
{
#define M(row,col)  m[col*4+row]
	out[0] = M(0, 0) * in[0] + M(0, 1) * in[1] + M(0, 2) * in[2] + M(0, 3) * in[3];
	out[1] = M(1, 0) * in[0] + M(1, 1) * in[1] + M(1, 2) * in[2] + M(1, 3) * in[3];
	out[2] = M(2, 0) * in[0] + M(2, 1) * in[1] + M(2, 2) * in[2] + M(2, 3) * in[3];
	out[3] = M(3, 0) * in[0] + M(3, 1) * in[1] + M(3, 2) * in[2] + M(3, 3) * in[3];
#undef M
}




/*
 * Perform a 4x4 matrix multiplication  (product = a x b).
 * Input:  a, b - matrices to multiply
 * Output:  product - product of a and b
 */
static void
matmul(GLfloat * product, const GLfloat * a, const GLfloat * b)
{
	/* This matmul was contributed by Thomas Malik */
	GLfloat temp[16];
	GLint i;
	
#define A(row,col)  a[(col<<2)+row]
#define B(row,col)  b[(col<<2)+row]
#define T(row,col)  temp[(col<<2)+row]
	
	/* i-te Zeile */
	for (i = 0; i < 4; i++) {
		T(i, 0) = A(i, 0) * B(0, 0) + A(i, 1) * B(1, 0) + A(i, 2) * B(2, 0) + A(i, 3) * B(3, 0);
		T(i, 1) = A(i, 0) * B(0, 1) + A(i, 1) * B(1, 1) + A(i, 2) * B(2, 1) + A(i, 3) * B(3, 1);
		T(i, 2) = A(i, 0) * B(0, 2) + A(i, 1) * B(1, 2) + A(i, 2) * B(2, 2) + A(i, 3) * B(3, 2);
		T(i, 3) = A(i, 0) * B(0, 3) + A(i, 1) * B(1, 3) + A(i, 2) * B(2, 3) + A(i, 3) * B(3, 3);
	}
	
#undef A
#undef B
#undef T
	memcpy(product, temp, 16 * sizeof(GLfloat));
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
#define SWAP_ROWS(a, b) { GLfloat *_tmp = a; (a)=(b); (b)=_tmp; }
#define MAT(m,r,c) (m)[(c)*4+(r)]
	
	GLfloat wtmp[4][8];
	GLfloat m0, m1, m2, m3, s;
	GLfloat *r0, *r1, *r2, *r3;
	
	r0 = wtmp[0], r1 = wtmp[1], r2 = wtmp[2], r3 = wtmp[3];
	
	r0[0] = MAT(m, 0, 0), r0[1] = MAT(m, 0, 1),
	r0[2] = MAT(m, 0, 2), r0[3] = MAT(m, 0, 3),
	r0[4] = 1.0f, r0[5] = r0[6] = r0[7] = 0.0f,
	r1[0] = MAT(m, 1, 0), r1[1] = MAT(m, 1, 1),
	r1[2] = MAT(m, 1, 2), r1[3] = MAT(m, 1, 3),
	r1[5] = 1.0f, r1[4] = r1[6] = r1[7] = 0.0f,
	r2[0] = MAT(m, 2, 0), r2[1] = MAT(m, 2, 1),
	r2[2] = MAT(m, 2, 2), r2[3] = MAT(m, 2, 3),
	r2[6] = 1.0f, r2[4] = r2[5] = r2[7] = 0.0f,
	r3[0] = MAT(m, 3, 0), r3[1] = MAT(m, 3, 1),
	r3[2] = MAT(m, 3, 2), r3[3] = MAT(m, 3, 3),
	r3[7] = 1.0f, r3[4] = r3[5] = r3[6] = 0.0f;
	
	/* choose pivot - or die */
	if (fabsf(r3[0]) > fabsf(r2[0]))
		SWAP_ROWS(r3, r2);
	if (fabsf(r2[0]) > fabsf(r1[0]))
		SWAP_ROWS(r2, r1);
	if (fabsf(r1[0]) > fabsf(r0[0]))
		SWAP_ROWS(r1, r0);
	if (0.0f == r0[0])
		return GL_FALSE;
	
	/* eliminate first variable     */
	m1 = r1[0] / r0[0];
	m2 = r2[0] / r0[0];
	m3 = r3[0] / r0[0];
	s = r0[1];
	r1[1] -= m1 * s;
	r2[1] -= m2 * s;
	r3[1] -= m3 * s;
	s = r0[2];
	r1[2] -= m1 * s;
	r2[2] -= m2 * s;
	r3[2] -= m3 * s;
	s = r0[3];
	r1[3] -= m1 * s;
	r2[3] -= m2 * s;
	r3[3] -= m3 * s;
	s = r0[4];
	if (s != 0.0f) {
		r1[4] -= m1 * s;
		r2[4] -= m2 * s;
		r3[4] -= m3 * s;
	}
	s = r0[5];
	if (s != 0.0f) {
		r1[5] -= m1 * s;
		r2[5] -= m2 * s;
		r3[5] -= m3 * s;
	}
	s = r0[6];
	if (s != 0.0f) {
		r1[6] -= m1 * s;
		r2[6] -= m2 * s;
		r3[6] -= m3 * s;
	}
	s = r0[7];
	if (s != 0.0f) {
		r1[7] -= m1 * s;
		r2[7] -= m2 * s;
		r3[7] -= m3 * s;
	}
	
	/* choose pivot - or die */
	if (fabsf(r3[1]) > fabsf(r2[1]))
		SWAP_ROWS(r3, r2);
	if (fabsf(r2[1]) > fabsf(r1[1]))
		SWAP_ROWS(r2, r1);
	if (0.0f == r1[1])
		return GL_FALSE;
	
	/* eliminate second variable */
	m2 = r2[1] / r1[1];
	m3 = r3[1] / r1[1];
	r2[2] -= m2 * r1[2];
	r3[2] -= m3 * r1[2];
	r2[3] -= m2 * r1[3];
	r3[3] -= m3 * r1[3];
	s = r1[4];
	if (0.0f != s) {
		r2[4] -= m2 * s;
		r3[4] -= m3 * s;
	}
	s = r1[5];
	if (0.0f != s) {
		r2[5] -= m2 * s;
		r3[5] -= m3 * s;
	}
	s = r1[6];
	if (0.0f != s) {
		r2[6] -= m2 * s;
		r3[6] -= m3 * s;
	}
	s = r1[7];
	if (0.0f != s) {
		r2[7] -= m2 * s;
		r3[7] -= m3 * s;
	}
	
	/* choose pivot - or die */
	if (fabsf(r3[2]) > fabsf(r2[2]))
		SWAP_ROWS(r3, r2);
	if (0.0f == r2[2])
		return GL_FALSE;
	
	/* eliminate third variable */
	m3 = r3[2] / r2[2];
	r3[3] -= m3 * r2[3], r3[4] -= m3 * r2[4],
	r3[5] -= m3 * r2[5], r3[6] -= m3 * r2[6], r3[7] -= m3 * r2[7];
	
	/* last check */
	if (0.0f == r3[3])
		return GL_FALSE;
	
	s = 1.0f / r3[3];		/* now back substitute row 3 */
	r3[4] *= s;
	r3[5] *= s;
	r3[6] *= s;
	r3[7] *= s;
	
	m2 = r2[3];			/* now back substitute row 2 */
	s = 1.0f / r2[2];
	r2[4] = s * (r2[4] - r3[4] * m2), r2[5] = s * (r2[5] - r3[5] * m2),
	r2[6] = s * (r2[6] - r3[6] * m2), r2[7] = s * (r2[7] - r3[7] * m2);
	m1 = r1[3];
	r1[4] -= r3[4] * m1, r1[5] -= r3[5] * m1,
	r1[6] -= r3[6] * m1, r1[7] -= r3[7] * m1;
	m0 = r0[3];
	r0[4] -= r3[4] * m0, r0[5] -= r3[5] * m0,
	r0[6] -= r3[6] * m0, r0[7] -= r3[7] * m0;
	
	m1 = r1[2];			/* now back substitute row 1 */
	s = 1.0f / r1[1];
	r1[4] = s * (r1[4] - r2[4] * m1), r1[5] = s * (r1[5] - r2[5] * m1),
	r1[6] = s * (r1[6] - r2[6] * m1), r1[7] = s * (r1[7] - r2[7] * m1);
	m0 = r0[2];
	r0[4] -= r2[4] * m0, r0[5] -= r2[5] * m0,
	r0[6] -= r2[6] * m0, r0[7] -= r2[7] * m0;
	
	m0 = r0[1];			/* now back substitute row 0 */
	s = 1.0f / r0[0];
	r0[4] = s * (r0[4] - r1[4] * m0), r0[5] = s * (r0[5] - r1[5] * m0),
	r0[6] = s * (r0[6] - r1[6] * m0), r0[7] = s * (r0[7] - r1[7] * m0);
	
	MAT(out, 0, 0) = r0[4];
	MAT(out, 0, 1) = r0[5], MAT(out, 0, 2) = r0[6];
	MAT(out, 0, 3) = r0[7], MAT(out, 1, 0) = r1[4];
	MAT(out, 1, 1) = r1[5], MAT(out, 1, 2) = r1[6];
	MAT(out, 1, 3) = r1[7], MAT(out, 2, 0) = r2[4];
	MAT(out, 2, 1) = r2[5], MAT(out, 2, 2) = r2[6];
	MAT(out, 2, 3) = r2[7], MAT(out, 3, 0) = r3[4];
	MAT(out, 3, 1) = r3[5], MAT(out, 3, 2) = r3[6];
	MAT(out, 3, 3) = r3[7];
	
	return GL_TRUE;
	
#undef MAT
#undef SWAP_ROWS
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
