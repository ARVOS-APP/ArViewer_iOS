/*
 * ArvosSquare.h - ArViewer_iOS
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface ArvosSquare : NSObject

@property(readonly)  BOOL     textureLoaded;
@property GLfloat*            vertices;

/**
 Load texture from image
 @param image a UIImage to load the texture from
 */
- (void)loadGlTexture:(UIImage*)image;
- (void)draw;

@end
