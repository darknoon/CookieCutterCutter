//
//  GLKitImport.c
//  CookieCutterCutter
//
//  Created by Elizabeth Salazar on 8/23/14.
//
//

#include "GLKitImport.h"
#import <GLKit/GLKit.h>

SCNMatrix4 createMatrixFromQuaternion(SCNQuaternion quat) {

    GLKQuaternion glkQuat = GLKQuaternionMake(quat.x, quat.y, quat.z, quat.w);
    
    GLKMatrix4 glkMatrix = GLKMatrix4MakeWithQuaternion(glkQuat);
    
    return *((SCNMatrix4 *)&glkMatrix);
}
