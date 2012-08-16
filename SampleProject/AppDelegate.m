#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface MapAnnotation : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString *title, *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end
@implementation MapAnnotation
@end

@interface NSObject (RecursiveDescription)
- (NSString *)recursiveDescription;
@end

@implementation AppDelegate {
    UIScrollView *scrollView;
    UIImageView *marsView;
    MKPinAnnotationView *topPin;
    SMCalloutView *calloutView;
    
    MKMapView *bottomMapView;
    MKPinAnnotationView *bottomPin;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
    self.window.backgroundColor = [UIColor whiteColor];
    
    CGRect half = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height/2);
    
    //
    // Fill top half with a custom view (image) inside a scroll view along with a custom pin view that triggers our custom MTCalloutView.
    //
    
    scrollView = [[UIScrollView alloc] initWithFrame:half];
    scrollView.backgroundColor = [UIColor grayColor];
    
    marsView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mars.jpg"]];
    marsView.userInteractionEnabled = YES;
    [marsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(marsTapped)]];
    
    [scrollView addSubview:marsView];
    scrollView.contentSize = marsView.frame.size;
    scrollView.contentOffset = CGPointMake(150, 50);
    
    topPin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
    topPin.center = CGPointMake(half.size.width/2 + 190, half.size.height/2 + 120);
    [topPin addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinTapped)]];
    [marsView addSubview:topPin];

    calloutView = [SMCalloutView new];
    calloutView.delegate = self;
    calloutView.title = @"Curiosity";
    calloutView.rightAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    calloutView.calloutOffset = topPin.calloutOffset;

    //
    // Fill top half with an MKMapView with a pin view that triggers our custom MTCalloutView.
    //

//    topPin = [[MKPinAnnotationView alloc] initWithAnnotation:capeCanaveral reuseIdentifier:@""];
//    topPin.canShowCallout = NO;
//    [topPin addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinTapped)]];
//
//    topMapView = [[MKMapView alloc] initWithFrame:half];
//    topMapView.delegate = self;
//    [topMapView addAnnotation:capeCanaveral];
//    [topMapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(marsTapped)]];
//
//    calloutView = [SMCalloutView new];
//    calloutView.delegate = self;
//    calloutView.title = capeCanaveral.title;
//    calloutView.subtitle = capeCanaveral.subtitle;
//    calloutView.rightAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    calloutView.calloutOffset = topPin.calloutOffset;

    //
    // Fill the bottom half of our window with a standard MKMapView with pin+callout for comparison
    //
    
    MapAnnotation *capeCanaveral = [MapAnnotation new];
    capeCanaveral.coordinate = (CLLocationCoordinate2D){28.388154, -80.604200};
    capeCanaveral.title = @"Cape Canaveral";

    bottomPin = [[MKPinAnnotationView alloc] initWithAnnotation:capeCanaveral reuseIdentifier:@""];
    bottomPin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    bottomPin.canShowCallout = YES;

    bottomMapView = [[MKMapView alloc] initWithFrame:CGRectOffset(half, 0, half.size.height)];
    bottomMapView.delegate = self;
    [bottomMapView addAnnotation:capeCanaveral];
    
    //
    // Put it all on the screen.
    //

    [self.window addSubview:scrollView];
    [self.window addSubview:bottomMapView];

    [self.window makeKeyAndVisible];
    
    //[self performSelector:@selector(popup) withObject:nil afterDelay:3];
    [self performSelector:@selector(printHierarchy) withObject:nil afterDelay:5];
    
    return YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    return mapView == topMapView ? topPin : bottomPin;
    return bottomPin;
}

- (void)pinTapped {
    [calloutView presentCalloutFromRect:topPin.bounds inView:topPin constrainedToView:scrollView permittedArrowDirections:SMCalloutArrowDirectionDown animated:YES];
}

- (void)marsTapped {
    [calloutView dismissCalloutAnimated:NO];
}

- (void)popup {
    [calloutView presentCalloutFromRect:topPin.bounds inView:topPin constrainedToView:scrollView permittedArrowDirections:SMCalloutArrowDirectionDown animated:YES];
    [bottomMapView selectAnnotation:bottomPin.annotation animated:YES];
    [self performSelector:@selector(tweakPopup) withObject:nil afterDelay:1];
}

- (NSTimeInterval)calloutView:(SMCalloutView *)theCalloutView delayForRepositionWithSize:(CGSize)offset {
    
    // We could cancel the popup here if we wanted to:
    // [calloutView dismissCalloutAnimated:NO];

    [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x-offset.width, scrollView.contentOffset.y-offset.height) animated:YES];
    
    return kSMCalloutViewRepositionDelayForUIScrollView;
}

- (void)tweakPopup {
}

- (UIView *)findSubviewOf:(UIView *)view havingClass:(NSString *)className {
    if ([NSStringFromClass(view.class) isEqualToString:className])
        return view;
    
    for (UIView *subview in view.subviews) {
        UIView *found = [self findSubviewOf:subview havingClass:className];
        if (found) return found;
    }
    
    return nil;
}

- (void)printHierarchy {
//    UIView *callout = [self findSubviewOf:bottomMapView havingClass:@"UICalloutView"];
//
//    for (int x=0;x<400;x+=10) {
//        NSLog(@"Size that fits %i,100: %@", x, NSStringFromCGSize([callout sizeThatFits:CGSizeMake(x, 100)]));
//        NSLog(@"OUR Size that fits %i,100: %@", x, NSStringFromCGSize([calloutView sizeThatFits:CGSizeMake(x, 100)]));
//    }
    
//    NSLog(@"%@", self.window.recursiveDescription);
    
//    CABasicAnimation *animation = (CABasicAnimation *)[callout.layer animationForKey:@"transform"];
//    NSLog(@"Callout: %@ duration:%f tx:%@", animation, animation.duration, NSStringFromCGAffineTransform(callout.transform));
//    if (animation)
//        [self performSelector:@selector(printHierarchy) withObject:nil afterDelay:0.01];
}

@end
