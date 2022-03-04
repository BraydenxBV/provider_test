import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represenst a Cart Item. Has <int>`id`, <String>`name`, <int>`quantity`
class CartItem {
  int id;
  String name;
  int quantity;
  CartItem(this.id, this.name, this.quantity);
}
/// Manages a cart. Implements ChangeNotifier
class CartState with ChangeNotifier {
  List<CartItem> _products = [];
  CartState();
  /// The number of individual items in the cart. That is, all cart items' quantities.
  int get totalCartItems => _products.fold(0, (totalQuantity, product) => totalQuantity + product.quantity);
  /// The list of CartItems in the cart
  List<CartItem> get products => _products;
  /// Clears the cart. Notifies any consumers.
  void clearCart() {
    _products = [];
    notifyListeners();
  }
  /// Adds a new CartItem to the cart. Notifies any consumers.
  void addToCart({required CartItem item}) {
    _products.add(item);
    notifyListeners();
  }
  /// Updates the quantity of the Cart item with this id. Notifies any consumers
  void updateQuantity({required int id, required int newQty}) {
    _products.forEach((product) {product.id == id ? product.quantity = newQty: "" ;});
    notifyListeners();
  }
  void removeProduct({required int index}) {
    _products.removeAt(index);
    notifyListeners();
  }
  returnShoutOut({required int numberOfCats}) {
    List catComments = ["you should pick out some cats","only 1 cat, you can do better!!", "2 is always better than 1", "3 is a party!", " wow! looks like you're taking all the cat!"];
    if (numberOfCats == 0) {
      return(catComments[0]);
    } else if(numberOfCats < 4) {
      return(catComments[numberOfCats]);
    } else return catComments[4];
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartState(),
      child: MyCartApp(),
    ),
  );
}

class MyCartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              ListOfCartItems(),
              CartSummary(),
              CartComments(),
              CartControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class CartControls extends StatelessWidget {
  /// Handler for Add Item pressed
  void _addItemPressed(BuildContext context) {
    /// mostly unique cartItemId.
    /// don't change this; not important for this test
    int nextCartItemId = Random().nextInt(10000);
    String nextCartItemName = 'A cart item';
    int nextCartItemQuantity = 1;
    CartItem item = new CartItem(nextCartItemId, nextCartItemName, nextCartItemQuantity); // Actually use the CartItem constructor to assign id, name and quantity
    Provider.of<CartState>(context,listen: false).addToCart(item: item);
  }
  /// Handle clear cart pressed. Should clear the cart
  void _clearCartPressed(BuildContext context) {
    Provider.of<CartState>(context,listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final Widget addCartItemWidget = TextButton(
      child: Text('Add Item'),
      onPressed: () {
        _addItemPressed(context);
      },
    );
    final Widget clearCartWidget = TextButton(
      child: Text('Clear Cart'),
      onPressed: () {
        _clearCartPressed(context);
      },
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        addCartItemWidget,
        clearCartWidget,
      ],
    );
  }
}

class ListOfCartItems extends StatelessWidget {
  /// Handles adding 1 to the current cart item quantity.
  void _incrementQuantity(context, int id, int delta) {
    int activeProductindex = Provider.of<CartState>(context, listen: false).products.indexWhere((product) => product.id == id);
    CartItem activeProduct = Provider.of<CartState>(context, listen: false).products[activeProductindex];
    Provider.of<CartState>(context, listen: false).updateQuantity(id: id, newQty: activeProduct.quantity + delta);
  }
  /// Handles removing 1 to the current cart item quantity.
  void _decrementQuantity(context, int id, int delta) {
    int activeProductindex = Provider.of<CartState>(context, listen: false).products.indexWhere((product) => product.id == id);
    CartItem activeProduct = Provider.of<CartState>(context, listen: false).products[activeProductindex];
    if(activeProduct.quantity - delta > 0) {
      Provider.of<CartState>(context, listen: false).updateQuantity(id: id, newQty: activeProduct.quantity - delta);
    } else {Provider.of<CartState>(context, listen: false).removeProduct(index: activeProductindex);
    };
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
        builder: (BuildContext context, CartState cart, Widget? child) {
          final ButtonStyle style =
          ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 10));
          if (cart.totalCartItems == 0) {
            return Text("there are no items in the cart");
          }
          return Column(children: [
            ...cart.products.map(
                  (c) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("${c.name} x ${c.quantity}"),
                    Image.network('https://cataas.com/cat',
                      height: 50, width: 50,
                    ),
                    //  Current quantity should update whenever a change occurs.
                    ElevatedButton(onPressed: () =>_incrementQuantity(context, c.id, 1), child: Text("+"), style: style),
                    ElevatedButton(onPressed: () =>_decrementQuantity(context, c.id, 1), child: Text("-"), style: style),
                  ],
                ),
              ),
            ),
          ]);
        });
  }
}

class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (BuildContext context, CartState cart, Widget? child) {
        return Text("Total items: ${cart.totalCartItems}");

      },
    );
  }
}

class CartComments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (BuildContext context, CartState cart, Widget? child) {
        return Text("${Provider.of<CartState>(context, listen: false).returnShoutOut(numberOfCats: cart.totalCartItems)}");
      },
    );
  }
}
