# AKA Beacon

AKA Beacon is a binding framework for iOS. It is similar in scope to XAML and Knockout.

> We prepared [a short survey](https://mutechaka.typeform.com/to/caKeuX). Please help us and give us some feedback. Thank you for taking the time (it's really short)

## Installation & Integration

Beacon is available on Cocoapods, at the time of writing "0.1.0-pre.*". This version is not fit for production. Please wait until the "-pre" goes away and use the head revision for up-to-date versions (again better not for production yet).

```
pod 'AKABeacon', :head
```

## Documentation

* [Take a look at the Wiki](https://github.com/mutech/aka-ios-beacon/wiki)–work in progress.
* [Cocoapods AKA Beacon Appledoc's](http://cocoadocs.org/docsets/AKABeacon/0.1.0-pre.2/). The API documentation is very incomplete and still needs a lot of work, but you might find some useful information. Quality documentation will be coming with v1.0.

## How Beacon works

The typical usage scenario is that (blue is Beacon's, green your job):

* Your view controller **inherits** from a form view controller (**AKAFormViewController** or **AKAFormTableViewController**) provided by Beacon.
* Your view controller **provides** properties or a reference to your **model data**
* You design a view in Interface Builder and **assign binding expressions** to views which should be bound to your data.

![Binding Schematics](Documentation/BindingSchematics.png)

What happens behind the scenes (Beacon's job):

* **viewDidLoad:** The form view controller will **inspect your view hierarchy** to find views defining binding expressions and **create bindings** for them.
* **viewWillAppear:** The bindings will **initialize views** with content from your data model and **observe changes** on boths ends.
* **viewWillDisappear:** Bindings will **stop observing changes** and restore the original state of bound views.

Many of these tasks are actually carried out by **controls** which are in charge of managing bindings, providing data contexts and controlling the behavior of view hierarchies. In most cases you can ignore controls, since they do their job transparently without bothering you. If you need to interact with them however, they provide fine granular delegate methods, which you can use to inspect and control the behavior of controls and bindings. If you inherit from a form view controller, all you have to do is to implement one of the optional delegate methods (traditional iOS style).

Please note that most modules in Beacon are designed to be independent. You can for example use bindings without controls, and you don't have to use form view controllers to manage controls and bindings.

We spend a lot of effort to ensure that you can use the parts of the framework that actually help you without requiring you to put your architecture upside down just to integrate data binding functionality.

We also tried hard to take over all the work to support standard use cases such that you don't have to write code, just to make sure that your text fields are visible when you're typing, that it still works when you rotate the device. This is going much further than scrolling. In later versions you will get automatic support for theming, automatic font resizing, highlighting of search terms, form transaction support (model values are updated at the end of a form editing session and only if valid) and much more.

## Examples

### Text Field Binding Example

The corresponding view controller source is:

* [TextFieldBindingViewController.h](AKABeacon/AKABeaconDemo/TextFieldBindingViewController.h) and
* [TextFieldBindingViewController.h](AKABeacon/AKABeaconDemo/TextFieldBindingViewController.m)


<img align="left" src="Documentation/NumberEditing.gif" style="padding:0 50px 0 0" />

The binding expressions used for the three text fields are:

```
stringValue {
	textForUndefinedValue: "(Please enter some text)",
	treatEmptyTextAsUndefined: $true
}
```

```
stringValue { liveModelUpdates: $false }
```

```
numberValue {
	numberFormatter: {
		numberStyle: $enum.CurrencyStyle
	},
	editingNumberFormatter: {
		maximumFractionDigits: 5
	}
}
```

<div style="clear: both"></div>

### Picker Keyboards

The corresponding view controller source is:

* [PickerKeyboardViewController.h](AKABeacon/AKABeaconDemo/PickerKeyboardViewController.h) and
* [PickerKeyboardViewController.m](AKABeacon/AKABeaconDemo/PickerKeyboardViewController.m)

Please note that in this example, each edit control consists of a label displaying the selected value and a wrapper view, which activates the keyboard when tapped and also performs the highlight and the animation.

You can combine the picker functionality with any view (and reasonably with any view that is able to somehow render the selected value). This also has the advantage that you can use different formatting options for the picker choices and the selection display.

<img align="left" src="Documentation/PickerKeyboards.gif" style="padding:0 50px 0 0" />

The binding expressions used here are:

First picker label: (connects the label to key path `stringValue` and configures the binding to display "(tap to choose)" if the value is undefined).

```
stringValue {
	textForUndefinedValue: "(tap to choose)"
}
```

Picker: (the picker keyboard takes its choices from `stringArrayValue`. Since no title is specified, array items will be used as values for respective choices).

```
stringValue {
	choices: stringArrayValue,
	titleForUndefinedValue: "(please choose)"
}
```

Second picker labels: (This picker contains multiple labels bound to different properties of the data context, which is an object in this case).

```
objectValue.title
```

```
objectValue.value
```

Picker: (Here, the array items are complex objects, so the title attribute is defined as key path relative to the respective array item; picker keyboards also support the setting liveModelUpdates).

```
objectValue {
	title: title,
	choices: objectArrayValue,
	liveModelUpdates: $false
}
```

Date picker label: (See the section on label formatting).

```
dateValue { dateFormatter: { dateStyle: $enum.LongStyle, timeStyle: $enum.MediumStyle } } 
```

Picker: (The date picker only needs the key path for the selected value).

```
dateValue
```

<div style="clear: both"></div>

### Label Binding Demo

The corresponding view controller source is:

* [LabelDemoTableViewController.h](AKABeacon/AKABeaconDemo/LabelDemoTableViewController.h) and
* [LabelDemoTableViewController.m](AKABeacon/AKABeaconDemo/LabelDemoTableViewController.m)

<img src="Documentation/LabelFormatting.png" width="300"/>

#### Numbers:
The **numberFormatter** attribute supports most configuration properties of NSNumberFormatter. Enumeration values can be specified as `$enum.Value` (if the enumeration is known to Beacon) or `$enum.Type.Value` (you can provide mappings for your own enumerations).

```
floatValue {
	numberFormatter: {
		numberStyle: $enum.CurrencyStyle
	}
}
```

#### Boolean values:

**textForYes** and **textForNo** allow you to map number values to title.

```
boolValue {
	textForYes: "Yes",
	textForNo: "No"
}
```

#### Text values:

If you don't need any formatting, just specifying the key path to the value is enough.

```
textValue
```

#### Complex values and custom formatters:

You can use your own formatters by specifying the class name in angle brackets. You are however restricted by the data types that can be represented as binding expressions for the configuration of your custom formatter. As mentioned above, enumerations values can be registered:

```
objectValue {
	formatter: <CustomFormatter> {
		format: "Hello, %@"
	}
}
```

We're planning to support templating libraries such as mustache or handlebars. Once implemented a similar example would look like:

```
objectValue {
	formatter: <MustacheFormatter> {
		template: "Hello, {{givenName}} {{familyName}}"
	}
}
```

#### Date values:

Similar to number values, date values can be formatter using the NSDateFormatter.

```
dateValue {
	dateFormatter: {
		dateStyle: $enum.NSDateFormatterStyle.LongStyle,
		timeStyle: $enum.LongStyle
	}
}
```

## Demo Video

[I put up a demo video here](https://www.youtube.com/watch?v=88DkI8ZfEkg). It's already a bit outdated but it shows how working with Beacon feels like.

## Status

Beacon is approaching a state where it's really useful and sufficiently stable to be used without too many worries. It's not yet feature complete and also not yet well tested, so we still need some time. Our goal is to get a feature complete version out at the end of 2015 (that would be v0.1.0) and a well documented and tested release (v1.0) a couple of months later.

However, the interface is not yet stable, there are a couple of important features missing, we need to refactor some parts and there will certainly be some ugly bugs that we didn't find yet or that we don't want to admit. If you look for a high quality solution, wait a bit, we'll get there.

On the other hand, we desperately seek for feedback, both to make sure that the interface is sufficiently stable so that we won't break all of your code when we release 1.1 or 2.0 and also because it was a lot of work and it would be nice to hear some praise ;-)

## License

Beacon will be dual-licensed. The open source license is GPL-v3.

The details for commercials licensing are not yet set in stone. We plan to offer free licenses for individual developers on a per app and per beacon version basis. Please contact us if you want to use Beacon in a closed source application.