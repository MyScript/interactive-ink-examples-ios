## What is it about?

Interactive Ink SDK is the best way to integrate handwriting recognition capabilities into your iOS application. Interactive Ink extends digital ink to allow users to more intuitively create, interact with, and share content in digital form. Handwritten text, mathematical equations or even diagrams are interpreted in real-time to be editable via simple gestures, responsive and easy to convert to a neat output.

This repository contains a "get started" example, a complete example and a reference implementation of the iOS integration part that developers using Interactive Ink SDK can reuse inside their projects. We are in the process on moving the parts of this code that are in Objective C to Swift.

## Getting started

### Installation

1. Clone the examples repository `git clone https://github.com/MyScript/interactive-ink-examples-ios.git`

2. Claim a certificate to receive the free license to start develop your application by following the first steps of [Getting Started](https://developer.myscript.com/getting-started)

3. Copy this certificate to `Examples/GetStarted/GetStarted/MyScriptCertificate/MyCertificate.c` and `Examples/Demo/Demo/MyScriptCertificate/MyCertificate.c`

4. In Xcode, sign the applications in Settings Signing & Capabilities tab

## A word about the architecture

The `GetStarted` example is the easiest way for a first contact with iink SDK APIs, whereas the `Demo` example is a good way to play with some more advanced iink SDK features.
The `MainViewController` allows the user to do some basic Undo/Redo/Clear actions, and it encapsulates an `EditorViewController`.
The `EditorViewController` is responsible for all the display and it handles all the touch events made with a pen or a finger.
If you want to go further on the Edition and Rendering concepts, feel free to read the `UIReferenceImplementation` classes documentation.
These projects are based of the MVVM/Coordinator architecture, and the Data Binding between ViewModels and ViewControllers are based on Reactive Programming with Combine tool.
The main goal of this architecure is to clearly separate the roles of UI, Business and Routing, making everything more clear and testable.
The ViewController is responsible of displaying a model given by its ViewModel, and NOTHING more. It must ask the ViewModel or the Coordinator to do everything else.
The ViewModel is responsible of all the Business Logic, and it creates the Model to pass to the ViewController, via Data Binding.
Once a navigation action is needed, such as presenting a Modal ViewController for instance, the ViewController ask the Coordinator to do it.
The role of the Coordinator is to Instanciate the next ViewController and the way it is presented, and eventually pass it some data.

## Building your own integration

This repository provides you with a ready-to-use reference implementation of the iOS integration part, covering aspects like ink capture and rendering. It is located in `IInkUIReferenceImplementation` directory.

## Documentation

A complete guide is available on [MyScript Developer website](https://developer.myscript.com/docs/interactive-ink/latest/ios/).
The API Reference is available directly in Xcode once the dependencies are downloaded.

## Getting support, giving feedback

You can get some support or give feedback from the dedicated section on [MyScript Developer website](https://developer.myscript.com/support/).

## Something to show?

Made a cool app with Interactive Ink? Ready to cross join our marketing efforts? We would love to hear about you!
We’re planning to showcase apps powered by MyScript technology so let us know by sending a quick mail to [myapp@myscript.com](mailto://myapp@myscript.com).

## Contributing

We welcome your contributions:
If you would like to extend those examples for your needs, feel free to fork it!
Please sign our [Contributor License Agreement](CONTRIBUTING.md) before submitting your pull request.
