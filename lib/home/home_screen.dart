import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_list_app/home/search_results_screen.dart';
import '../theme/app_colors.dart';
import '../shared/bottom_navigation.dart';
import '../wishlist/wishlist_bloc.dart';
import 'home_bloc.dart';
import 'home_models.dart' as home_models;
import '../core/api/wishlist_api.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(HomeStarted())),
        BlocProvider(create: (_) => WishlistBloc()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _currentIndex = 0;
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (!mounted) return;

      // Get the current banner count from the state
      final currentState = context.read<HomeBloc>().state;
      final bannerCount =
          currentState.banners.isNotEmpty
              ? currentState.banners.length
              : 3; // Fallback to 3 if no banners

      if (bannerCount > 0) {
        final next = (_bannerIndex + 1) % bannerCount;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.black87)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) {
            Navigator.pushReplacementNamed(context, '/wishlist');
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Update banner timer when banners are loaded
            if (state.banners.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startBannerTimer(); // Restart timer with new banner count
              });
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _SearchBar()),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: Container(
                    height: 138,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: PageView.builder(
                      controller: _bannerController,
                      itemCount:
                          state.banners.isNotEmpty ? state.banners.length : 3,
                      onPageChanged: (i) => setState(() => _bannerIndex = i),
                      itemBuilder: (context, index) {
                        return state.banners.isNotEmpty
                            ? _BannerFromApi(banner: state.banners[index])
                            : _Banner(
                              title: 'Flat 50% Off!',
                              subtitle: 'Paragon Kitchen - Lulu Mall',
                            );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        state.banners.isNotEmpty ? state.banners.length : 3,
                        (i) {
                          final active = i == _bannerIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: active ? 18 : 6,
                            decoration: BoxDecoration(
                              color:
                                  active
                                      ? const Color(0xFF5E60CE)
                                      : Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                for (final section in state.sections.where(
                  (s) => s.title.toLowerCase() != 'home',
                )) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8,
                      ),
                      child: Text(
                        section.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (section.title.toLowerCase().contains(
                    'latest',
                  )) // <-- Only for "Latest Products"
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260, // Adjust height as needed for your card
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: section.products.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemBuilder:
                              (context, index) => _ProductCard(
                                product: section.products[index],
                              ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _ProductCard(product: section.products[index]),
                          childCount: section.products.length,
                        ),
                      ),
                    ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => 
          previous.searchResults != current.searchResults && 
          current.searchResults != null,
      listener: (context, state) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              searchResults: state.searchResults!,
              searchQuery: state.query,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(Icons.search_sharp, color: Colors.black54),
                onPressed: () {
                  final query = _searchController.text.trim();
                  if (query.isNotEmpty) {
                    context.read<HomeBloc>().add(SearchProducts(query));
                  }
                },
              ),
              hintText: 'Search',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                context.read<HomeBloc>().add(SearchProducts(value.trim()));
              }
            },
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Text(
                      'Know More',
                      style: TextStyle(
                        color: Color(0xFF5E60CE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset('assets/Logo.png', height: 90),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});
  final home_models.Product product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late home_models.Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  _product.featuredImage ?? 'https://via.placeholder.com/150',
                  height: 155,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/Logo.png',
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    final wishlistBloc = context.read<WishlistBloc>();
                    setState(() {
                      _product = _product.copyWith(
                        inWishlist: !_product.inWishlist,
                      );
                    });
                    wishlistBloc.add(WishlistItemToggled(_product));
                    context.read<HomeBloc>().add(ToggleWishlist(_product.id.toString())); // Convert id to string
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _product.inWishlist
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: const Color(0xFF5E60CE),
                      size: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE7E9EE)),
                  ),
                  child: Text(
                    '₹${_product.salePrice}',
                    style: const TextStyle(
                      color: Color(0xFF5E60CE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    Text(
                      '${_product.avgRating}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    if (_product.mrp != null &&
                        _product.mrp != _product.salePrice)
                      Text(
                        '₹${_product.mrp}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerFromApi extends StatelessWidget {
  const _BannerFromApi({required this.banner});
  final home_models.Banner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          banner.image,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: const Color(0xFFE9F2FF),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF5E60CE)),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              color: const Color(0xFFE9F2FF),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Color(0xFF5E60CE),
                  size: 50,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
