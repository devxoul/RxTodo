RxTodo
======

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![Build Status](https://travis-ci.org/devxoul/RxTodo.svg?branch=master)](https://travis-ci.org/devxoul/RxTodo)

RxTodo is an iOS application developed using [The Reactive Architecture](https://github.com/devxoul/TheReactiveArchitecture). This project is for whom having trouble with learning how to build a RxSwift application due to lack of references. (as I did 😛)


Features
--------

* [The Reactive Architecture](https://github.com/devxoul/ReactiveArchitecture)
* Using [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)
* Observing model create/update/delete across the view controllers
* Navigating between view controllers
* Immutable models
* Testing with [RxExpect](https://github.com/devxoul/RxExpect)


Philosophy
----------

* View doesn't have control flow. View cannot modify the data. View only knows how to map the data.

    **Bad**

    ```swift
    viewReactor.titleLabelText
      .map { $0 + "!" } // Bad: View should not modify the data
      .bindTo(self.titleLabel)
    ```

    **Good**
    
    ```swift
    viewReactor.titleLabelText
      .bindTo(self.titleLabel.rx.text)
    ```

* View doesn't know what ViewReactor does. View can only communicate to ViewReactor about what View did.

    **Bad**

    ```swift
    viewReactor.login() // Bad: View should not know what ViewReactor does (login)
    ```

    **Good**
    
    ```swift
    self.loginButton.rx.tap
      .bindTo(viewReactor.loginButtonDidTap) // "Hey I clicked the login button"

    self.usernameInput.rx.controlEvent(.editingDidEndOnExit)
      .bindTo(viewReactor.usernameInputDidReturn) // "Hey I tapped the return on username input"
    ```

* Model is hidden by ViewReactor. ViewReactor only exposes the minimum data so that View can render.

    **Bad**
    
    ```swift
    struct ProductViewReactor {
      let product: Driver<Product> // Bad: ViewReactor should hide Model
    }
    ```

    **Good**
    
    ```swift
    struct ProductViewReactor {
      let productName: Driver<String>
      let formattedPrice: Driver<String>
      let formattedOriginalPrice: Driver<String>
      let isOriginalPriceHidden: Driver<Bool>
    }
    ```


Requirements
------------

* iOS 8+
* Swift 3
* CocoaPods


Screenshots
-----------

![rxtodo](https://cloud.githubusercontent.com/assets/931655/21965942/1611927a-dbad-11e6-99ee-3509d06dc242.png)


Contribution
------------

Discussion and pull requests are welcomed 💖


License
-------

RxTodo is under MIT license. See the [LICENSE](LICENSE) for more info.
