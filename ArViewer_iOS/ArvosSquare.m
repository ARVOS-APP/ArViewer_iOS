/*
 * ArvosSquare.m - ArViewer_iOS
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

#import "ArvosSquare.h"

@interface ArvosSquare () {
    
    GLuint mTextures[1];
}
@end

@implementation ArvosSquare

-(id)init {
    self = [super init];
	if (self) {
        mTextures[0] = 0;
	}
	return self;
}

- (void)loadGlTexture:(UIImage*)image {
    if (nil == image) {
        _textureLoaded = NO;
        return;
    }
       
    // generate one texture pointer and bind it to the array of the arvos square
    glGenTextures(1, mTextures);
    glBindTexture(GL_TEXTURE_2D, mTextures[0]);
    
    // copy UIImage to local buffer
    CGImageRef cgimage = image.CGImage;
    
    float width = CGImageGetWidth(cgimage);
    float height = CGImageGetHeight(cgimage);
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    
    void *imageBuffer = malloc(width * height * 4);
    CGContextRef imgContext = CGBitmapContextCreate(imageBuffer,
                                                    width, height,
                                                    8, 4 * width, colourSpace,
                                                    kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colourSpace);
    CGContextClearRect(imgContext, bounds);
    CGContextTranslateCTM (imgContext, 0, height);
    CGContextScaleCTM (imgContext, 1.0, -1.0);
    
    CGAffineTransform flip = CGAffineTransformMake(1, 0, 0, -1, 0, height);
    CGContextConcatCTM(imgContext, flip);
    
    CGContextDrawImage(imgContext, bounds, cgimage);
    
    // create nearest filtered texture
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    // create a two-dimensional texture image
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageBuffer);
    
    GLenum err = glGetError();
    CGContextRelease(imgContext);
    free(imageBuffer);
    if (err != GL_NO_ERROR) {
        NSLog(@"Error. glError: 0x%04X\n", err);
        _textureLoaded = NO;
    }
    _textureLoaded = YES;
}

- (void)draw {
       
    static const float textureVertices[] = {
        -0.5f, -0.5f,
        -0.5f,  0.5f,
        0.5f, -0.5f,
        0.5f,  0.5f,
    };
    
    static const float textureCoords[] = {
        -1.0f, 0.0f,
        -1.0f, -1.0f,
        0.0f, 0.0f,
        0.0f, -1.0f,
    };
    
    glBindTexture(GL_TEXTURE_2D, mTextures[0]);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glFrontFace(GL_CW);
    
    glVertexPointer(2, GL_FLOAT, 0, textureVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

@end
