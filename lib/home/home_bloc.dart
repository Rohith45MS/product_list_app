import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_models.dart';
import '../core/models/register_request.dart';
import '../core/api/banner_api.dart';
import '../core/api/product_api.dart';
import '../core/api/wishlist_api.dart';

class HomeEvent {}

class HomeStarted extends HomeEvent {}

class ToggleWishlist extends HomeEvent {
  final String productId;
  ToggleWishlist(this.productId);
}

class SearchProducts extends HomeEvent {
  final String query;
  SearchProducts(this.query);
}

class HomeState {
  const HomeState({
    required this.query,
    required this.banners,
    required this.sections,
    required this.isLoading,
    this.searchResults, // Add this
  });

  final String query;
  final List<Banner> banners;
  final List<HomeSection> sections;
  final bool isLoading;
  final List<Product>? searchResults; // Add this

  HomeState copyWith({
    String? query,
    List<Banner>? banners,
    List<HomeSection>? sections,
    bool? isLoading,
    List<Product>? searchResults, // Add this
  }) {
    return HomeState(
      query: query ?? this.query,
      banners: banners ?? this.banners,
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults, // Add this
    );
  }

  factory HomeState.initial() => const HomeState(
        query: '',
        banners: [],
        sections: [],
        isLoading: true,
        searchResults: null, // Add this
      );
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    on<HomeStarted>(_onStarted);
    on<ToggleWishlist>(_onToggleWishlist);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, query: event.query));
      
      if (event.query.isEmpty) {
        final products = await ProductApi.fetchProducts();
        final sections = [
          HomeSection(title: 'Popular Product', products: products),
          HomeSection(title: 'Latest Products', products: products),
        ];
        emit(state.copyWith(
          sections: sections,
          isLoading: false,
          searchResults: null,
        ));
      } else {
        final searchResults = await ProductApi.searchProducts(event.query);
        emit(state.copyWith(
          searchResults: searchResults,
          isLoading: false,
        ));
      }
    } catch (e) {
      print('Error searching products: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    try {
      emit(state.copyWith(isLoading: true));
      final banners = await BannerApi.fetchBanners();
  
      // Fetch products from API
      final products = await ProductApi.fetchProducts();
  
      final sections = [
        HomeSection(title: 'Popular Product', products: products),
        HomeSection(title: 'Latest Products', products: products),
      ];
  
      emit(
        state.copyWith(banners: banners, sections: sections, isLoading: false),
      );
    } catch (e) {
      print('Error initializing home: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onToggleWishlist(
    ToggleWishlist event,
    Emitter<HomeState> emit,
  ) async {
    await WishlistApi.toggleWishlist(event.productId);
  }
}
