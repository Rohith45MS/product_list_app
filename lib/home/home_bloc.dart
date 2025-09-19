import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_models.dart';
import '../core/services/banner_service.dart';
import '../core/services/products_service.dart';

class HomeEvent {}

class HomeStarted extends HomeEvent {}

class HomeState {
  const HomeState({
    required this.query,
    required this.banners,
    required this.sections,
    required this.isLoading,
  });

  final String query;
  final List<Banner> banners;
  final List<HomeSection> sections;
  final bool isLoading;

  HomeState copyWith({
    String? query,
    List<Banner>? banners,
    List<HomeSection>? sections,
    bool? isLoading,
  }) {
    return HomeState(
      query: query ?? this.query,
      banners: banners ?? this.banners,
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory HomeState.initial() =>
      const HomeState(query: '', banners: [], sections: [], isLoading: true);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final BannerService _bannerService = BannerService();
  final ProductsService _productsService = ProductsService();

  HomeBloc() : super(HomeState.initial()) {
    on<HomeStarted>(_onStarted);
  }

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    try {
      // Fetch banners from API
      final bannerModels = await _bannerService.getBanners();
      
      // Convert BannerModel to Banner
      final banners = bannerModels.map((bannerModel) => Banner(
        id: bannerModel.id,
        name: bannerModel.name,
        image: bannerModel.image,
        showingOrder: bannerModel.showingOrder,
        product: bannerModel.product != null ? Product(
          id: bannerModel.product!.id.toString(),
          name: bannerModel.product!.name,
          imageAsset: bannerModel.product!.featuredImage,
          price: bannerModel.product!.salePrice.toInt(),
          rating: bannerModel.product!.avgRating,
          strikePrice: bannerModel.product!.mrp.toInt(),
        ) : null,
        category: bannerModel.category != null ? Category(
          id: bannerModel.category!.id,
          name: bannerModel.category!.name,
          image: bannerModel.category!.image,
          isActive: bannerModel.category!.isActive,
          showingOrder: bannerModel.category!.showingOrder,
          slug: bannerModel.category!.slug,
          products: bannerModel.category!.products.map((p) => Product(
            id: p.id.toString(),
            name: p.name,
            imageAsset: p.featuredImage,
            price: p.salePrice.toInt(),
            rating: p.avgRating,
            strikePrice: p.mrp.toInt(),
          )).toList(),
        ) : null,
        hexcode1: bannerModel.hexcode1,
        hexcode2: bannerModel.hexcode2,
      )).toList();

      // Sort banners by showing order
      banners.sort((a, b) => a.showingOrder.compareTo(b.showingOrder));

      // Convert Product models to UI Product models
      final productModels = await _productsService.getProducts();
      final products = productModels.map((productModel) => Product(
        id: productModel.id.toString(),
        name: productModel.name,
        imageAsset: productModel.featuredImage,
        price: productModel.salePrice.toInt(),
        rating: productModel.avgRating,
        strikePrice: productModel.mrp.toInt(),
      )).toList();

      // Create sections with real product data
      final sections = [
        HomeSection(title: 'Popular Products', products: products.take(4).toList()),
        HomeSection(title: 'Latest Products', products: products.skip(2).take(4).toList()),
      ];

      emit(state.copyWith(
        banners: banners,
        sections: sections, 
        isLoading: false
      ));
    } catch (e) {
      print('Error fetching banners: $e');
      // Fallback to mock data if API fails
      final mockProducts = [
        Product(
          id: '1',
          name: 'Grain Peppers',
          imageAsset: 'assets/Logo.png',
          price: 599,
          rating: 4.5,
          strikePrice: 999,
        ),
        Product(
          id: '2',
          name: 'Organic Dry Turmeric',
          imageAsset: 'assets/Logo.png',
          price: 599,
          rating: 4.6,
          strikePrice: 999,
        ),
        Product(
          id: '3',
          name: 'jaggery powder',
          imageAsset: 'assets/Logo.png',
          price: 599,
          rating: 4.5,
          strikePrice: 999,
        ),
        Product(
          id: '4',
          name: 'Coriander Powder',
          imageAsset: 'assets/Logo.png',
          price: 599,
          rating: 4.5,
          strikePrice: 999,
        ),
      ];

      final sections = [
        HomeSection(title: 'Popular Product', products: mockProducts),
        HomeSection(title: 'Latest Products', products: mockProducts),
      ];

      emit(state.copyWith(sections: sections, isLoading: false));
    }
  }
}
