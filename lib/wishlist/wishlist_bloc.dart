import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/api/wishlist_api.dart';
import '../home/home_models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


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

  WishlistState({this.isLoading = false, this.products = const [], this.error});
}

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc() : super(WishlistState()) {
    on<WishlistStarted>(_onStarted);
    on<WishlistItemToggled>(_onItemToggled);
  }

  Future<void> _onStarted(
    WishlistStarted event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistState(isLoading: true));
    try {
      // Fetch wishlist from API
      final products = await WishlistApi.fetchWishlist();
      emit(WishlistState(products: products));
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }

  Future<void> _onItemToggled(
    WishlistItemToggled event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      // Remove the product from wishlist
      final updatedProducts = state.products
          .where((product) => product.id != event.product.id)
          .toList();
      
      final success = await WishlistApi.toggleWishlist(event.product.id.toString());
      if (success) {
        emit(WishlistState(products: updatedProducts));
      }
    } catch (e) {
      emit(WishlistState(error: e.toString()));
    }
  }
}
