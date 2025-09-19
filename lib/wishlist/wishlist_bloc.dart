import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../home/home_models.dart';

// Events
abstract class WishlistEvent {}

class WishlistStarted extends WishlistEvent {}
class WishlistItemToggled extends WishlistEvent {
  final Product product;
  WishlistItemToggled(this.product);
}

// State
class WishlistState {
  final bool isLoading;
  final List<Product> products;
  final String? error;

  WishlistState({
    this.isLoading = false,
    this.products = const [],
    this.error,
  });
}

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final _dio = Dio();

  WishlistBloc() : super(WishlistState()) {
    on<WishlistStarted>(_onStarted);
    on<WishlistItemToggled>(_onItemToggled);
  }

  Future<void> _onStarted(WishlistStarted event, Emitter<WishlistState> emit) async {
    emit(WishlistState(isLoading: true));
    try {
      final response = await _dio.get(
        'https://skilltestflutter.zybotechlab.com/api/wishlist',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Check if data contains products directly
        final List<dynamic> productList = data['products'] as List? ?? [];
        final List<Product> products = [];
        
        for (var item in productList) {
          if (item is Map<String, dynamic>) {
            try {
              final product = Product.fromJson(item);
              products.add(product as Product);
            } catch (e) {
              print('Error parsing product: $e');
            }
          }
        }
        
        emit(WishlistState(products: products));
      } else if (response.statusCode == 401) {
        emit(WishlistState(error: 'Please login to view your wishlist'));
      } else {
        emit(WishlistState(error: 'Failed to load wishlist'));
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          emit(WishlistState(error: 'Please login to view your wishlist'));
        } else {
          emit(WishlistState(error: e.response?.data['message'] ?? 'Failed to load wishlist'));
        }
      } else {
        emit(WishlistState(error: e.toString()));
      }
    }
  }

  Future<void> _onItemToggled(WishlistItemToggled event, Emitter<WishlistState> emit) async {
    try {
      final formData = FormData.fromMap({
        'product_id': event.product.id.toString(),
      });
      
      final response = await _dio.post(
        'https://skilltestflutter.zybotechlab.com/api/wishlist',
        data: formData,
      );

      if (response.statusCode == 200) {
        add(WishlistStarted());
      }
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }
}
