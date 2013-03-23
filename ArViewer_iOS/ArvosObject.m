/*
 * ArvosObject.m - ArViewer_iOS
 *
 * Copyright (C) 2013, Peter Graf, Ulrich Zurucker
 *
 * This file is part of Arvos - AR Viewer Open Source for iOS.
 * Arvos is free software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * For more information on the AR Viewer Open Source
 * please see: http://www.arvos-app.com/.
 */

#import "ArvosObject.h"
#import "Arvos.h"

@interface ArvosObject () {
    Arvos*  mInstance;
    GLfloat mPosition[3];
	GLfloat mScale[3];
	GLfloat mRotation[4];
}
@end

@implementation ArvosObject

- (id)init {
    NSAssert(NO, @"ArvosObject must not be initialzed without id");
    return nil;
}

-(id)initWithId:(int)idParameter {
    self = [super init];
	if (self) {
        self.id = idParameter;
        mInstance = [Arvos sharedInstance];
	}
	return self;
}

- (GLfloat*)getPosition{ return mPosition; }
- (GLfloat*)getScale{ return mScale; }
- (GLfloat*)getRotation{ return mRotation; }

/**
 * True billboarding. With the spherical version the object will always face
 * the camera. It requires more computational effort than the cylindrical
 * billboard though. The parameters camX,camY, and camZ, are the target,
 * i.e. a 3D point to which the object will point.
 *
 * @param gl
 * @param camX
 * @param camY
 * @param camZ
 * @param posX
 * @param posY
 * @param posZ
 */
void l3dBillboardSphericalBegin(GLfloat camX, GLfloat camY, GLfloat camZ, GLfloat posX, GLfloat posY, GLfloat posZ)
{
    GLfloat lookAt[] = { 0., 0., 1.};
    GLfloat objToCamProj[3];
    GLfloat objToCam [3];
    GLfloat upAux [3];
    GLfloat angleCosine;
    
    // objToCamProj is the vector in world coordinates from the local origin
    // to the camera
    // projected in the XZ plane
    objToCamProj[0] = camX - posX;
    objToCamProj[1] = 0;
    objToCamProj[2] = camZ - posZ;
    
    // normalize both vectors to get the cosine directly afterwards
    vec3Normalize(objToCamProj, objToCamProj);
    
    // easy fix to determine whether the angle is negative or positive
    // for positive angles upAux will be a vector pointing in the
    // positive y direction, otherwise upAux will point downwards
    // effectively reversing the rotation.
    
    vec3CrossProduct(upAux, lookAt, objToCamProj);
    
    // compute the angle
    angleCosine = vec3DotProduct(lookAt, objToCamProj);
    
    // perform the rotation. The if statement is used for stability reasons
    // if the lookAt and v vectors are too close together then |aux| could
    // be bigger than 1 due to lack of precision
    if ((angleCosine < 0.99990) && (angleCosine > -0.9999))
    {
        GLfloat f = 180 / M_1_PI * ((GLfloat) (acosf(angleCosine)));
        vec3Normalize(upAux, upAux);
        glRotatef(f, upAux[0], upAux[1], upAux[2]);
    }
    
    // objToCam is the vector in world coordinates from the local origin to
    // the camera
    objToCam[0] = camX - posX;
    objToCam[1] = camY - posY;
    objToCam[2] = camZ - posZ;
    
    // Normalize to get the cosine afterwards
    vec3Normalize(objToCam, objToCam);
    
    // Compute the angle between v and v2, i.e. compute the
    // required angle for the lookup vector
    angleCosine = vec3DotProduct(objToCamProj, objToCam);
    
    // Tilt the object. The test is done to prevent instability when
    // objToCam and objToCamProj have a very small
    // angle between them
    if ((angleCosine < 0.99990) && (angleCosine > -0.9999))
    {
        if (objToCam[1] < 0)
        {
            GLfloat f = 180 / M_1_PI * ((GLfloat) (acosf(angleCosine)));
            glRotatef(f, 1, 0, 0);
        }
        else
        {
            GLfloat f = 180 / M_1_PI * ((GLfloat) (acosf(angleCosine)));
            glRotatef(f, -1, 0, 0);
        }
    }
}

/**
 * The objects motion is restricted to a rotation on a predefined axis The
 * function bellow does cylindrical billboarding on the Y axis, i.e. the
 * object will be able to rotate on the Y axis only.
 *
 * @param camX
 * @param camY
 * @param camZ
 * @param posX
 * @param posY
 * @param posZ
 * @param pUpAux
 * @return
 */
float l3dBillboardCylindricalDegrees(GLfloat camX, GLfloat camY, GLfloat camZ, GLfloat posX, GLfloat posY, GLfloat posZ, GLfloat* pUpAux)
{
    GLfloat lookAt [] = { 0, 0, 1 };
    GLfloat objToCamProj [3];
    GLfloat tmp [3];
    GLfloat* upAux = pUpAux;
    if (upAux == NULL)
    {
        upAux = tmp;
    }
    GLfloat angleCosine;
    
    // objToCamProj is the vector in world coordinates from the local origin
    // to the camera
    // projected in the XZ plane
    objToCamProj[0] = camX - posX;
    objToCamProj[1] = 0;
    objToCamProj[2] = camZ - posZ;
    
    // normalize both vectors to get the cosine directly afterwards
    vec3Normalize(objToCamProj, objToCamProj);
    
    // easy fix to determine whether the angle is negative or positive
    // for positive angles upAux will be a vector pointing in the
    // positive y direction, otherwise upAux will point downwards
    // effectively reversing the rotation.
    
    vec3CrossProduct(upAux, lookAt, objToCamProj);
    
    // compute the angle
    angleCosine = vec3DotProduct(lookAt, objToCamProj);
    
    // perform the rotation. The if statement is used for stability reasons
    // if the lookAt and v vectors are too close together then |aux| could
    // be bigger than 1 due to lack of precision
    if ((angleCosine < 0.99990) && (angleCosine > -0.9999))
    {
        return 180 / M_1_PI * ((GLfloat) (acosf(angleCosine)));
    }
    return 0.;
}

/**
 * Cylindrical billboarding.
 *
 * @param gl
 * @param camX
 * @param camY
 * @param camZ
 * @param posX
 * @param posY
 * @param posZ
 */
void l3dBillboardCylindricalBegin(GLfloat camX, GLfloat camY, GLfloat camZ, GLfloat posX, GLfloat posY, GLfloat posZ)
{
    GLfloat upAux [3];
    GLfloat f = l3dBillboardCylindricalDegrees(camX, camY, camZ, posX, posY, posZ, upAux);
    if (f != 0.)
    {
        glRotatef(f, upAux[0], upAux[1], upAux[2]);
    }
}

- (void)draw {
    if (!self.textureLoaded) {
        [self loadGlTexture:self.image];
    }

    //glTranslatef(0.0, 0, -5.0);
    // Take the device orientation into account
    //
    //gl.glRotatef(mInstance.getRotationDegrees(), 0f, 0f, 1f);
    
    // The device coordinates are flat on the table with X east, Y north and
    // Z up.
    // The world coordinates are X east, Y up and Z north
    //
    glRotatef(90, 1., 0., 0.);
    
    // Apply azimut, pitch and roll of the device
    //
    glRotatef(mInstance.roll, 0., 0., -1.);
    glRotatef(mInstance.pitch, 1., 0., 0.);
    glRotatef(mInstance.azimuth, 0., 1., 0.);
    
    // Move the object
    //
    glTranslatef(mPosition[0], mPosition[1], mPosition[2]);
    
    // Make it face the camera
    //
    if ([ArvosBillboardHandlingCylinder isEqualToString:self.billboardHandling])
    {
        l3dBillboardCylindricalBegin(0., 0., 0., mPosition[0], mPosition[1], mPosition[2]);
    }
    else if ([ArvosBillboardHandlingSphere isEqualToString:self.billboardHandling])
    {
        l3dBillboardSphericalBegin(0., 0., 0., mPosition[0], mPosition[1], mPosition[2]);
    }

    glRotatef(mRotation[3], mRotation[0], mRotation[1], mRotation[2]);
    glScalef(mScale[0], mScale[1], mScale[2]);
    
    [super draw];
}

@end
