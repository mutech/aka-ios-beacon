# AKA Beacon

## Quick Summary

AKA Beacon is a binding framework for iOS. It is similar in scope to XAML and Knockout.

The typical way to use Beacon is to define binding expressions on UIViews in Interface Builder and to subclass AKAFormViewController or AKAFormTableViewController (more to come) in your view controllers.

For example, given this view controller:

```Objective-C
@import AKABeacon;
@interface MyViewController: AKAFormViewController
@property(nonatomic) double money;
@property(nonatomic) NSDate* date;
@end
```

```Objective-C
@implementation MyViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  self.money = 1234.567;
  self.date = [NSDate new];
}
@end
```

and a UILabel in the view controller's view that defines a label with the *textBinding_aka* property

```
money { numberFormatter: { numberStyle: $enum.CurrencyStyle, locale: "de_DE" } }
```

and another UILabel with

```
date { dateFormatter: { dateFormat: "'Today is:' mm/dd/YYYY" } }
```

Will do all the work of connecting the property values to the labels. The views are updated whenever the properties change.

This currently works with UILabel, UITextField, UITextView, UISwitch, UISlider, and at the time Beacon is released (soon now) with the rest of the gang.

There is a whole lot more to Beacon than just binding values. Go and check it out, you'll be surprised ;-)

## Installation & Integration

Beacon is available on Cocoapods, at the time of writing 0.1.0-pre.2. This version is not fit for production. Please wait until the "pre" goes away.

```
pod 'AKABeacon', '~> 0.1.0-pre.2'
```

## Demo

[I put up a demo video here](https://www.youtube.com/watch?v=88DkI8ZfEkg). I hope you forgive me the miserable audio quality and my poor presentation skills, please ignore both and focus on the features if you can ;-)

## Status

Beacon is approaching a state where it's really useful and sufficiently stable to be used without too many worries. It's not yet feature complete and also not yet well tested, so we still need some time. Our goal is to get a feature complete version out at the end of 2015 (that would be v0.1.0) and a well documented and tested release (v1.0) a couple of months later.

However, the interface is not yet stable, there are a couple of important features missing, we need to refactor some parts and there will certainly be some ugly bugs that we didn't find yet or that we don't want to admit. If you look for a high quality solution, wait a bit, we'll get there.

On the other hand, we desperately seek for feedback, both to make sure that the interface is sufficiently stable so that we won't break all of your code when we release 1.1 or 2.0 and also because it was a lot of work and it would be nice to hear some praise ;-)

## License

Beacon will be dual-licensed. The open source license is GPL-v3.

The details for commercials licensing are not yet set in stone. We plan to offer free licenses for individual developers on a per app and per beacon version basis. Please contact us if you want to use Beacon in a closed source application.