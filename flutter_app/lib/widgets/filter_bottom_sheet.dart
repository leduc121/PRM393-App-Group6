import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int? _minPrice;
  int? _maxPrice;
  String? _gender;
  String? _size;
  String? _priceRange;

  String? _categoryId;
  String? _categoryName;
  String? _brandId;
  String? _brandName;

  final List<String> _priceRanges = [
    'Tất cả',
    'Dưới 1 triệu',
    '1 triệu - 3 triệu',
    '3 triệu - 5 triệu',
    '5 triệu - 10 triệu',
    'Trên 10 triệu',
    'Đại gia (Trên 50 triệu)',
    'Max (Dưới 100 triệu)',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<SportZoneState>();
    _minPrice = state.filterMinPrice;
    _maxPrice = state.filterMaxPrice;
    _gender = state.filterGender;
    _size = state.filterSize;
    _categoryId = state.selectedCategoryId;
    _categoryName = state.selectedCategory;
    _brandId = state.selectedBrandId;
    _brandName = state.selectedBrand;

    // determine price range dropdown string
    if (_minPrice == null && _maxPrice == null) {
      _priceRange = 'Tất cả';
    } else if (_minPrice == null && _maxPrice == 1000000) {
      _priceRange = 'Dưới 1 triệu';
    } else if (_minPrice == 1000000 && _maxPrice == 3000000) {
      _priceRange = '1 triệu - 3 triệu';
    } else if (_minPrice == 3000000 && _maxPrice == 5000000) {
      _priceRange = '3 triệu - 5 triệu';
    } else if (_minPrice == 5000000 && _maxPrice == 10000000) {
      _priceRange = '5 triệu - 10 triệu';
    } else if (_minPrice == 10000000 && _maxPrice == null) {
      _priceRange = 'Trên 10 triệu';
    } else if (_minPrice == 50000000 && _maxPrice == null) {
      _priceRange = 'Đại gia (Trên 50 triệu)';
    } else if (_minPrice == null && _maxPrice == 100000000) {
      _priceRange = 'Max (Dưới 100 triệu)';
    } else {
      _priceRange = 'Tất cả';
    }
  }

  void _applyPriceRange(String range) {
    setState(() {
      _priceRange = range;
      switch (range) {
        case 'Dưới 1 triệu':
          _minPrice = null;
          _maxPrice = 1000000;
          break;
        case '1 triệu - 3 triệu':
          _minPrice = 1000000;
          _maxPrice = 3000000;
          break;
        case '3 triệu - 5 triệu':
          _minPrice = 3000000;
          _maxPrice = 5000000;
          break;
        case '5 triệu - 10 triệu':
          _minPrice = 5000000;
          _maxPrice = 10000000;
          break;
        case 'Trên 10 triệu':
          _minPrice = 10000000;
          _maxPrice = null;
          break;
        case 'Đại gia (Trên 50 triệu)':
          _minPrice = 50000000;
          _maxPrice = null;
          break;
        case 'Max (Dưới 100 triệu)':
          _minPrice = null;
          _maxPrice = 100000000;
          break;
        default:
          _minPrice = null;
          _maxPrice = null;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc tìm kiếm',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: SportZoneTheme.primary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Danh mục',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('Tất cả', null),
              ...context.read<SportZoneState>().apiCategories.map((c) => _buildCategoryChip(c.name, c.categoryId)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Thương hiệu',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBrandChip('Tất cả', null),
              ...context.read<SportZoneState>().apiBrands.map((b) => _buildBrandChip(b.name, b.brandId)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Giới tính',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderChip('Tất cả', null),
              const SizedBox(width: 8),
              _buildGenderChip('Nam', 'men'),
              const SizedBox(width: 8),
              _buildGenderChip('Nữ', 'women'),
              const SizedBox(width: 8),
              _buildGenderChip('Unisex', 'unisex'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Size',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildSizeChip('Tất cả', null),
              _buildSizeChip('XS', 'XS'),
              _buildSizeChip('S', 'S'),
              _buildSizeChip('M', 'M'),
              _buildSizeChip('L', 'L'),
              _buildSizeChip('XL', 'XL'),
              _buildSizeChip('XXL', 'XXL'),
              _buildSizeChip('FREE', 'FREE'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Khoảng giá (VND)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: SportZoneTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _priceRange,
                items: _priceRanges.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) _applyPriceRange(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SportZoneTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                context.read<SportZoneState>().applyFilters(
                  minPrice: _minPrice,
                  maxPrice: _maxPrice,
                  gender: _gender,
                  size: _size,
                  categoryName: _categoryName,
                  categoryId: _categoryId,
                  brandName: _brandName,
                  brandId: _brandId,
                );
                Navigator.pop(context);
              },
              child: const Text(
                'ÁP DỤNG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ), // Column
     ), // SingleChildScrollView
    ), // Container
   ), // ConstrainedBox
  ); // SafeArea
}

  Widget _buildGenderChip(String label, String? value) {
    final isSelected = _gender == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _gender = value;
        });
      },
      selectedColor: SportZoneTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: SportZoneTheme.surface,
    );
  }

  Widget _buildSizeChip(String label, String? value) {
    final isSelected = _size == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _size = value;
        });
      },
      selectedColor: SportZoneTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: SportZoneTheme.surface,
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _categoryId == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _categoryName = label;
          _categoryId = value;
        });
      },
      selectedColor: SportZoneTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: SportZoneTheme.surface,
    );
  }

  Widget _buildBrandChip(String label, String? value) {
    final isSelected = _brandId == value;
    return ChoiceChip(
      label: Text(label.toUpperCase()),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _brandName = label;
          _brandId = value;
        });
      },
      selectedColor: SportZoneTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: SportZoneTheme.surface,
    );
  }
}
