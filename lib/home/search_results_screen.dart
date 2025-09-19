import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../wishlist/wishlist_bloc.dart';
import 'home_bloc.dart';
import 'home_models.dart' as home_models;

class SearchResultsScreen extends StatelessWidget {
  final List<home_models.Product> searchResults;
  final String searchQuery;

  const SearchResultsScreen({
    super.key,
    required this.searchResults,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WishlistBloc()),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Results for "$searchQuery"',
            style: const TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: searchResults.length,
          itemBuilder: (context, index) => _ProductCard(
            product: searchResults[index],
          ),
        ),
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
                    context.read<HomeBloc>().add(ToggleWishlist(_product.id.toString()));
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
                      _product.inWishlist ? Icons.favorite : Icons.favorite_border,
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
                    if (_product.mrp != null && _product.mrp != _product.salePrice)
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

