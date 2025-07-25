import 'dart:io';
import 'dart:convert';

class Product {
  String name;
  String description;
  double price;

  Product(this.name, this.description, this.price);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      json['name'] as String,
      json['description'] as String,
      json['price'] as double,
    );
  }

  @override
  String toString() {
    return 'Name: $name, Description: $description, Price: \$${price.toStringAsFixed(2)}';
  }
}

class ProductManager {
  final List<Product> _products = [];
  final String _filePath;

  ProductManager(this._filePath) {
    _loadProductsFromFile(); // Load products when manager is initialized
  }

  void _saveProductsToFile() {
    try {
      final jsonList = _products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      File(_filePath).writeAsStringSync(jsonString);
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  void _loadProductsFromFile() {
    try {
      final file = File(_filePath);
      if (file.existsSync()) {
        final jsonString = file.readAsStringSync();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _products.clear(); // Clear existing products before loading
        _products.addAll(jsonList.map((json) => Product.fromJson(json as Map<String, dynamic>)));
        print('Products loaded from $_filePath');
      } else {
        print('Product data file not found. Starting with an empty list.');
      }
    } catch (e) {
      print('Error loading products: $e');
      _products.clear();
    }
  }

  void addProduct(String name, String description, double price) {
    final product = Product(name, description, price);
    _products.add(product);
    _saveProductsToFile(); // Save after adding
    print('Product "$name" added successfully.');
  }

  void viewAllProducts() {
    if (_products.isEmpty) {
      print('No products available.');
      return;
    }
    print('\n--- All Products ---');
    for (int i = 0; i < _products.length; i++) {
      print('${i + 1}. ${_products[i]}');
    }
    print('--------------------');
  }

  void viewProduct(int index) {
    if (index < 1 || index > _products.length) {
      print('Invalid product number.');
      return;
    }
    print('\n--- Product Details ---');
    print(_products[index - 1]);
    print('-----------------------');
  }

  void editProduct(int index, String newName, String newDescription, double newPrice) {
    if (index < 1 || index > _products.length) {
      print('Invalid product number.');
      return;
    }
    final product = _products[index - 1];
    product.name = newName;
    product.description = newDescription;
    product.price = newPrice;
    _saveProductsToFile(); // Save after editing
    print('Product "${product.name}" updated successfully.');
  }

  void deleteProduct(int index) {
    if (index < 1 || index > _products.length) {
      print('Invalid product number.');
      return;
    }
    final removedProduct = _products.removeAt(index - 1);
    _saveProductsToFile(); // Save after deleting
    print('Product "${removedProduct.name}" deleted successfully.');
  }

  int get productCount => _products.length;
}

void main() {
  const String dataFileName = 'products.json';
  final manager = ProductManager(dataFileName);
  bool running = true;

  while (running) {
    print('\n--- eCommerce Application Menu ---');
    print('1. Add Product');
    print('2. View All Products');
    print('3. View Single Product');
    print('4. Edit Product');
    print('5. Delete Product');
    print('6. Exit');
    stdout.write('Enter your choice: ');

    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write('Enter product name: ');
        final name = stdin.readLineSync() ?? '';
        stdout.write('Enter product description: ');
        final description = stdin.readLineSync() ?? '';
        stdout.write('Enter product price: ');
        final priceStr = stdin.readLineSync() ?? '0';
        final price = double.tryParse(priceStr);

        if (name.isEmpty || description.isEmpty || price == null || price <= 0) {
          print('Invalid input. Please provide valid name, description, and a positive price.');
        } else {
          manager.addProduct(name, description, price);
        }
        break;
      case '2':
        manager.viewAllProducts();
        break;
      case '3':
        if (manager.productCount == 0) {
          print('No products to view.');
          break;
        }
        stdout.write('Enter product number to view: ');
        final indexStr = stdin.readLineSync() ?? '0';
        final index = int.tryParse(indexStr);
        if (index == null) {
          print('Invalid input. Please enter a number.');
        } else {
          manager.viewProduct(index);
        }
        break;
      case '4':
        if (manager.productCount == 0) {
          print('No products to edit.');
          break;
        }
        stdout.write('Enter product number to edit: ');
        final indexStr = stdin.readLineSync() ?? '0';
        final index = int.tryParse(indexStr);

        if (index == null || index < 1 || index > manager.productCount) {
          print('Invalid product number.');
          break;
        }

        final currentProduct = manager._products[index - 1]; // Access directly for current values

        stdout.write('Enter new name (current: "${currentProduct.name}", leave blank to keep): ');
        final newName = stdin.readLineSync();
        stdout.write('Enter new description (current: "${currentProduct.description}", leave blank to keep): ');
        final newDescription = stdin.readLineSync();
        stdout.write('Enter new price (current: \$${currentProduct.price.toStringAsFixed(2)}, leave blank to keep): ');
        final newPriceStr = stdin.readLineSync();
        final newPrice = double.tryParse(newPriceStr ?? '');

        manager.editProduct(
          index,
          newName!.isEmpty ? currentProduct.name : newName,
          newDescription!.isEmpty ? currentProduct.description : newDescription,
          newPrice == null ? currentProduct.price : newPrice,
        );
        break;
      case '5':
        if (manager.productCount == 0) {
          print('No products to delete.');
          break;
        }
        stdout.write('Enter product number to delete: ');
        final indexStr = stdin.readLineSync() ?? '0';
        final index = int.tryParse(indexStr);
        if (index == null) {
          print('Invalid input. Please enter a number.');
        } else {
          manager.deleteProduct(index);
        }
        break;
      case '6':
        running = false;
        print('Exiting application. Goodbye!');
        break;
      default:
        print('Invalid choice. Please try again.');
    }
  }
}