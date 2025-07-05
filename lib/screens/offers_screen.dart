// lib/screens/offers_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Class to define an Offer
class Offer {
  final String title;
  final String description;
  final String validity;
  final IconData icon;
  final List<Color> gradientColors;
  final String brand;
  final String category;

  const Offer({
    required this.title,
    required this.description,
    required this.validity,
    required this.icon,
    required this.gradientColors,
    required this.brand,
    required this.category,
  });
}

// Class to define a Brand Category
class Brand {
  final String name;
  final IconData icon;
  final String category;

  const Brand({
    required this.name,
    required this.icon,
    required this.category,
  });
}

// Class to define a top-level Category
class Category {
  final String name;
  final IconData icon;

  const Category({
    required this.name,
    required this.icon,
  });
}

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String? _selectedCategory; // State variable for the currently selected top-level category
  String? _selectedBrand; // State variable for the currently selected brand within a category

  // Define top-level categories
  final List<Category> _categories = const [
    Category(name: 'All', icon: Icons.apps_rounded),
    Category(name: 'Food', icon: Icons.fastfood_rounded),
    Category(name: 'Grocery', icon: Icons.shopping_cart_rounded),
    Category(name: 'OTT', icon: Icons.movie_filter_rounded),
    Category(name: 'Fashion', icon: Icons.shopping_bag_rounded),
    Category(name: 'Electronics', icon: Icons.devices_rounded),
  ];

  // Sample brand data
  final List<Brand> _brands = const [
    Brand(name: 'All', icon: Icons.apps_rounded, category: 'All'), // 'All' brand for 'All' category
    Brand(name: 'Zomato', icon: Icons.fastfood_rounded, category: 'Food'),
    Brand(name: 'Swiggy', icon: Icons.delivery_dining_rounded, category: 'Food'),
    Brand(name: 'Dunzo', icon: Icons.motorcycle_rounded, category: 'Food'), // Dunzo can be food/grocery
    Brand(name: 'BigBasket', icon: Icons.shopping_cart_rounded, category: 'Grocery'),
    Brand(name: 'Reliance Fresh', icon: Icons.local_grocery_store_rounded, category: 'Grocery'),
    Brand(name: 'Netflix', icon: Icons.movie_filter_rounded, category: 'OTT'),
    Brand(name: 'Amazon', icon: Icons.live_tv_rounded, category: 'OTT'), // Amazon Prime Video
    Brand(name: 'Hotstar', icon: Icons.sports_soccer_rounded, category: 'OTT'),
    Brand(name: 'Myntra', icon: Icons.shopping_bag_rounded, category: 'Fashion'),
    Brand(name: 'Flipkart', icon: Icons.shopping_basket_rounded, category: 'Electronics'), // Flipkart for electronics
    Brand(name: 'Croma', icon: Icons.laptop_chromebook_rounded, category: 'Electronics'),
  ];

  // Sample offer data
  final List<Offer> _allOffers = const [
    Offer(
      title: 'Zomato Gold Offer',
      description: 'Get 50% off on your next 5 orders!',
      validity: 'Expires: July 31, 2025',
      icon: Icons.fastfood_rounded,
      gradientColors: [Color(0xFFE53935), Color(0xFFB71C1C)],
      brand: 'Zomato',
      category: 'Food',
    ),
    Offer(
      title: 'Swiggy Super Saver',
      description: 'Flat ₹100 off on orders above ₹299.',
      validity: 'Expires: August 15, 2025',
      icon: Icons.delivery_dining_rounded,
      gradientColors: [Color(0xFFFDD835), Color(0xFFFBC02D)],
      brand: 'Swiggy',
      category: 'Food',
    ),
    Offer(
      title: 'Netflix Premium Deal',
      description: '3 months subscription at 20% off!',
      validity: 'Expires: September 10, 2025',
      icon: Icons.movie_filter_rounded,
      gradientColors: [Color(0xFFE57373), Color(0xFFD32F2F)],
      brand: 'Netflix',
      category: 'OTT',
    ),
    Offer(
      title: 'Amazon Prime Video',
      description: 'Get 1 month free on annual subscription.',
      validity: 'Expires: August 30, 2025',
      icon: Icons.live_tv_rounded,
      gradientColors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
      brand: 'Amazon',
      category: 'OTT',
    ),
    Offer(
      title: 'BigBasket Discount',
      description: '₹200 off on first grocery order over ₹1000.',
      validity: 'Expires: July 25, 2025',
      icon: Icons.shopping_cart_rounded,
      gradientColors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
      brand: 'BigBasket',
      category: 'Grocery',
    ),
    Offer(
      title: 'Hotstar VIP Pass',
      description: 'Unlock all sports and shows for 6 months at 15% off.',
      validity: 'Expires: October 01, 2025',
      icon: Icons.sports_soccer_rounded,
      gradientColors: [Color(0xFFFFA726), Color(0xFFF57C00)],
      brand: 'Hotstar',
      category: 'OTT',
    ),
    Offer(
      title: 'Dunzo Express Delivery',
      description: 'Free delivery on your next 3 orders.',
      validity: 'Expires: August 05, 2025',
      icon: Icons.motorcycle_rounded,
      gradientColors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
      brand: 'Dunzo',
      category: 'Food',
    ),
    Offer(
      title: 'Myntra Fashion Sale',
      description: 'Up to 70% off on all fashion categories.',
      validity: 'Expires: July 20, 2025',
      icon: Icons.shopping_bag_rounded,
      gradientColors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
      brand: 'Myntra',
      category: 'Fashion',
    ),
    Offer(
      title: 'Flipkart Big Billion Days',
      description: 'Special discounts on electronics and home appliances.',
      validity: 'Expires: September 05, 2025',
      icon: Icons.shopping_basket_rounded,
      gradientColors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
      brand: 'Flipkart',
      category: 'Electronics',
    ),
    Offer(
      title: 'Croma Mega Sale',
      description: 'Flat 10% off on all laptops and smartphones.',
      validity: 'Expires: July 28, 2025',
      icon: Icons.laptop_chromebook_rounded,
      gradientColors: [Color(0xFF7CB342), Color(0xFF558B2F)],
      brand: 'Croma',
      category: 'Electronics',
    ),
    Offer(
      title: 'Reliance Fresh Daily Deals',
      description: 'Buy 1 Get 1 Free on select fruits and vegetables.',
      validity: 'Expires: July 18, 2025',
      icon: Icons.local_grocery_store_rounded,
      gradientColors: [Color(0xFF00BFA5), Color(0xFF00897B)],
      brand: 'Reliance Fresh',
      category: 'Grocery',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter brands based on selected category
    final List<Brand> brandsToShow = _selectedCategory == null || _selectedCategory == 'All'
        ? _brands.where((brand) => brand.name == 'All').toList() // Only show 'All' brand if 'All' category is selected initially
        : _brands.where((brand) => brand.category == _selectedCategory || brand.name == 'All').toList();

    // Filter offers based on selected brand OR selected category
    final List<Offer> filteredOffers = _allOffers.where((offer) {
      bool matchesCategory = (_selectedCategory == null || _selectedCategory == 'All' || offer.category == _selectedCategory);
      bool matchesBrand = (_selectedBrand == null || _selectedBrand == 'All' || offer.brand == _selectedBrand);
      return matchesCategory && matchesBrand;
    }).toList();

    return Scaffold(
      
      body: SingleChildScrollView( // Use SingleChildScrollView for the entire body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Offers Heading
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
              child: Text(
                _selectedBrand != null && _selectedBrand != 'All'
                    ? 'Offers for $_selectedBrand'
                    : (_selectedCategory != null && _selectedCategory != 'All'
                        ? 'Offers in $_selectedCategory Category'
                        : 'All Available Offers'),
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            // Section 2: Horizontally Scrollable Offer Cards (Full Width)
            SizedBox(
              height: 200, // Fixed height for horizontal offer cards
              child: filteredOffers.isEmpty
                  ? Center(
                      child: Text(
                        'No offers found for this selection.',
                        style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredOffers.length,
                      itemBuilder: (context, index) {
                        final offer = filteredOffers[index];
                        return Container(
                          width: MediaQuery.of(context).size.width - 32.0, // Make card full width minus padding
                          margin: const EdgeInsets.only(right: 16.0), // Consistent margin
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: offer.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: offer.gradientColors.last.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(offer.icon, size: 30, color: Colors.white),
                                        Flexible(
                                          child: Text(
                                            offer.title,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      offer.description,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      offer.validity,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: Colors.white54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Getting offer for "${offer.title}"!', style: GoogleFonts.montserrat()),
                                              backgroundColor: Colors.blue.shade700,
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: offer.gradientColors.first,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          elevation: 2,
                                        ),
                                        child: Text(
                                          'Get Offer',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Section 3: Categories Heading
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
              child: Text(
                'Browse by Category',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            // Section 4: Non-scrollable Category Icons (Round)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap( // Non-scrollable grid for categories
                spacing: 12.0, // Horizontal spacing between items
                runSpacing: 12.0, // Vertical spacing between lines
                alignment: WrapAlignment.start, // Align items to the start
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedCategory == category.name) {
                          _selectedCategory = null; // Deselect if already selected
                        } else {
                          _selectedCategory = category.name; // Select the new category
                        }
                        _selectedBrand = null; // Reset selected brand when category changes
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.blue.shade700 : Colors.blue.shade50,
                            border: Border.all(
                              color: isSelected ? Colors.blue.shade700 : Colors.blue.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? Colors.blue.shade700.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            category.icon,
                            size: 30,
                            color: isSelected ? Colors.white : Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: isSelected ? Colors.blue.shade700 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Section 5: Brands Heading (Conditional)
            if (brandsToShow.isNotEmpty && (_selectedCategory != null && _selectedCategory != 'All'))
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
                child: Text(
                  'Brands in $_selectedCategory',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            // Section 6: Horizontally scrollable Brand chips (filtered by category, conditional)
            if (brandsToShow.isNotEmpty && (_selectedCategory != null && _selectedCategory != 'All'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 50, // Fixed height for the horizontal list
                  child: ListView.builder( // Changed back to ListView.builder for horizontal scroll
                    scrollDirection: Axis.horizontal,
                    itemCount: brandsToShow.length,
                    itemBuilder: (context, index) {
                      final brand = brandsToShow[index];
                      final isSelected = _selectedBrand == brand.name;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: ChoiceChip(
                          label: Row(
                            children: [
                              Icon(brand.icon, size: 18, color: isSelected ? Colors.white : Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                brand.name,
                                style: GoogleFonts.montserrat(
                                  color: isSelected ? Colors.white : Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: Colors.blue.shade700,
                          backgroundColor: Colors.blue.shade50,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBrand = selected ? brand.name : null;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.blue.shade700 : Colors.blue.shade200,
                              width: 1.5,
                            ),
                          ),
                          elevation: isSelected ? 4 : 1,
                          shadowColor: isSelected ? Colors.blue.shade700.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
