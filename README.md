RxTodo
======

RxTodo is an iOS application developed using [RxSwift](https://github.com/ReactiveX/RxSwift) and MVVM design pattern. This project is for whom having trouble with learning RxSwift and MVVM due to lack of references. (as I did 😁)


Features
--------

* MVVM design pattern
* Using [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)
* Observing model create/update/delete across the view controllers
* Navigating between view controllers
* Immutable models and view models


Philisophy
----------

* View doesn't have control flow. View cannot modify the data. View only knows how to map the data.

    **Bad**

    ```swift
    viewModel.title
        .map { $0 + "!" } // Bad: View should not modify the data
        .bindTo(self.titleLabel)
    ```

    **Good**
    
    ```swift
    viewModel.title
        .bindTo(self.titleLabel)
    ```

* View doesn't know what ViewModel does. View can only communicate to ViewModel about what View did.

    **Bad**

    ```swift
    viewModel.login() // Bad: View should not know what ViewModel does (login)
    ```

    **Good**
    
    ```swift
    self.loginButton.rx_tap
        .bindTo(viewModel.loginButtonDidTap) // "Hey I clicked the login button"

    self.usernameInput.rx_controlEvent(.EditingDidEndOnExit)
        .bindTo(viewModel.usernameInputDidReturn) // "Hey I tapped the return on username input"
    ```

* Model is hidden by ViewModel. ViewModel only exposes the minimum data so that View can render.

    **Bad**
    
    ```swift
    struct ProductViewModel {
        let product: Driver<Product> // Bad: ViewModel should hide Model
    }
    ```

    **Good**
    
    ```swift
    struct ProductViewModel {
        let productName: Driver<String>
        let formattedPrice: Driver<String>
        let formattedOriginalPrice: Driver<String>
        let originalPriceHidden: Driver<Bool>
    }
    ```


Requirements
------------

* iOS 8+
* Swift 2.2
* CocoaPods (I used 1.0.0)


Screenshots
-----------

![rxtodo](https://cloud.githubusercontent.com/assets/931655/16531082/eae3ead2-4005-11e6-8537-a6856d704d74.png)


Contribution
------------

Discussion and pull requests are welcomed 💖 Correcting English grammar is welcomed, too.


License
-------

RxTodo is under MIT license. See the [LICENSE](LICENSE) for more info.
