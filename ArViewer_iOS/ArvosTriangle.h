/*
 * Copyright (C) 2012 Gregory Beauchamp
 *
 * ArvosTriangle.h - ArViewer_iOS
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

#import <Foundation/Foundation.h>

@class ArvosRay;

@interface ArvosTriangle : NSObject

@property GLfloat* v0;
@property GLfloat* v1;
@property GLfloat* v2;

-(int)intersectWithRay:(ArvosRay*)ray
           resultPoint:(GLfloat*)resultpoint;

@end
