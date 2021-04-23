//
//  BaseRuntimeSupport.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objc/runtime.h"

/**
 *  Detect inheritance of class checking all levels.
 *
 *  @param classA class to evaluate
 *  @param classB ¿classA inherits from classB?
 *
 *  @return TRUE if classA inherits from classB
 */
BOOL classDescendsFrom(Class classA, Class classB);

