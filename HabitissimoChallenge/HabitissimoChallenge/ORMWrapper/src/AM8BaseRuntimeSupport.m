//
//  RuntimeSupport.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8BaseRuntimeSupport.h"


BOOL classDescendsFrom(Class classA, Class classB)
{
    //    DLog(@"%@ Descends from %@",NSStringFromClass(classA),NSStringFromClass(classB));
    while(1)
    {
        @autoreleasepool {
            //DLog(@"Parent is %@",NSStringFromClass(classA));
            if(classA == classB || [NSStringFromClass(classA) isEqualToString:NSStringFromClass(classB)])  return YES;
            Class superClass = [classA superclass] ;
            if(classA == superClass) return (superClass == classB);
            classA = superClass;
        }
    }
}


