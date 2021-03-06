/*
 * iSGL3D: http://isgl3d.com
 *
 * Copyright (c) 2010-2012 Stuart Caunt
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ViewportTestView.h"
#import "Isgl3dDemoCameraController.h"


@interface ViewportTestView ()
@end


#pragma mark -
@implementation ViewportTestView

- (id)init {
	
	if (self = [super init]) {

		// Create the primitive
		Isgl3dTextureMaterial * material = [Isgl3dTextureMaterial materialWithTextureFile:@"red_checker.png" shininess:0.9 precision:Isgl3dTexturePrecisionMedium repeatX:NO repeatY:NO];
	
		Isgl3dTorus * torusMesh = [Isgl3dTorus meshWithGeometry:2 tubeRadius:1 ns:32 nt:32];
		_torus = [self.scene createNodeWithMesh:torusMesh andMaterial:material];
		[_torus addEvent3DListener:self method:@selector(objectTouched:) forEventType:TOUCH_EVENT];
		[_torus addEvent3DListener:self method:@selector(objectMoved:) forEventType:MOVE_EVENT];
		[_torus addEvent3DListener:self method:@selector(objectReleased:) forEventType:RELEASE_EVENT];
		_torus.interactive = YES;
	
		// Add light
		Isgl3dLight * light  = [Isgl3dLight lightWithHexColor:@"FFFFFF" diffuseColor:@"FFFFFF" specularColor:@"FFFFFF" attenuation:0.005];
		light.position = Isgl3dVector3Make(5, 15, 15);
		[self.scene addChild:light];

		// Create camera controller
        Isgl3dNodeCamera *camera = (Isgl3dNodeCamera *)self.defaultCamera;
        
		_cameraController = [[Isgl3dDemoCameraController alloc] initWithNodeCamera:camera andView:self];
		_cameraController.orbit = 14;
		_cameraController.theta = 30;
		_cameraController.phi = 30;
		
		[self schedule:@selector(tick:)];
	}
	return self;
}

- (void)dealloc {
	[_cameraController release];
    _cameraController = nil;

	[super dealloc];
}

- (void)onActivated {
	// Add camera controller to touch-screen manager - responds only to touches in viewport
	[[Isgl3dTouchScreen sharedInstance] addResponder:_cameraController withView:self];
}

- (void)onDeactivated {
	// Remove camera controller from touch-screen manager
	[[Isgl3dTouchScreen sharedInstance] removeResponder:_cameraController];
}

- (void)tick:(float)dt {
	_torus.rotationY += 0.5;
	
	[_cameraController update];
}

- (void)objectTouched:(Isgl3dEvent3D *)event {
	UITouch * touch = [[event.touches allObjects] objectAtIndex:0];
	CGPoint uiPoint = [touch locationInView:touch.view];
	CGPoint viewPoint = [self convertUIPointToView:uiPoint];
	
	NSLog(@"object touched %i %@ %@", [event.touches count], NSStringFromCGPoint(uiPoint), NSStringFromCGPoint(viewPoint));
}

- (void)objectMoved:(Isgl3dEvent3D *)event {
	NSLog(@"object moved %i", [event.touches count]);
}

- (void)objectReleased:(Isgl3dEvent3D *)event {
	NSLog(@"object released %i", [event.touches count]);
}

@end

#pragma mark AppDelegate

/*
 * Implement principal class: creates the view(s) and adds them to the director
 */
@implementation AppDelegate

- (void) createViews {
	// Add Isgl3dView 1
	Isgl3dView *view1 = [ViewportTestView view];
	view1.viewport = CGRectMake(2, 241, 316, 237);
	view1.backgroundColorString = @"000022ff";
	view1.isOpaque = YES;
    view1.displayFPS = YES;
	[[Isgl3dDirector sharedInstance] addView:view1];
	
	// Add Isgl3dView 2
	Isgl3dView * view2 = [ViewportTestView view];
	view2.viewport = CGRectMake(2, 2, 316, 237);
	view2.backgroundColorString = @"002200ff";
	view2.isOpaque = YES;
	[[Isgl3dDirector sharedInstance] addView:view2];
}

@end

