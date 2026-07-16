import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedColor = '';
  String selectedSize = '';
  int quantity = 1;
  int currentStock = 0;
  bool isLoading = true;
  List<ProductVariant> variants = [];
  List<String> availableColors = [];
  List<String> availableSizes = [];
  int currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    final result = await ApiService.getProductDetail(widget.product.id);
    if (!mounted) return;
    if (result.isSuccess) {
      final List vList = result.data['variants'] ?? [];
      variants = vList.map((v) => ProductVariant.fromJson(v)).toList();
      
      final colorSet = <String>{};
      final sizeSet = <String>{};
      for (var v in variants) {
        colorSet.add(v.colorName);
        sizeSet.add(v.size);
      }
      
      availableColors = colorSet.toList()..sort();
      availableSizes = sizeSet.toList()..sort();
      
      if (availableColors.isNotEmpty) selectedColor = availableColors.first;
      if (availableSizes.isNotEmpty) selectedSize = availableSizes.first;
      
      _updateStock();
      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'Lỗi tải chi tiết')));
    }
  }

  void _updateStock() {
    final variant = variants.firstWhere(
      (v) => v.colorName == selectedColor && v.size == selectedSize,
      orElse: () => ProductVariant(id: '', productId: '', size: '', colorName: '', stockQty: 0),
    );
    setState(() {
      currentStock = variant.stockQty;
      if (quantity > currentStock) quantity = currentStock > 0 ? 1 : 0;
      if (quantity == 0 && currentStock > 0) quantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final recommended = productList
        .where((p) => p.id != widget.product.id)
        .take(2)
        .toList();
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  Text(
                    'CHI TIẾT MẪU',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _circleIconButton(icon: Icons.favorite_border, onTap: () {}),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: SportZoneTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.8,
                          child: Builder(
                            builder: (context) {
                              final productImages = widget.product.images.isNotEmpty
                                  ? widget.product.images
                                  : [widget.product.imageUrl];
                              return Stack(
                                children: [
                                  PageView.builder(
                                    controller: _pageController,
                                    itemCount: productImages.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        currentImageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return ProductImage(
                                        imageUrl: productImages[index],
                                        productName: widget.product.name,
                                      );
                                    },
                                  ),
                                  if (productImages.length > 1) ...[
                                    // Dots indicator
                                    Positioned(
                                      bottom: 12,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          productImages.length,
                                          (index) => Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                            width: currentImageIndex == index ? 16 : 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: currentImageIndex == index
                                                  ? SportZoneTheme.primary
                                                  : Colors.grey.shade400,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Left Navigation Arrow Button
                                    if (currentImageIndex > 0)
                                      Positioned(
                                        left: 8,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: ClipOval(
                                            child: Material(
                                              color: Colors.black26,
                                              child: InkWell(
                                                onTap: () {
                                                  _pageController.previousPage(
                                                    duration: const Duration(milliseconds: 350),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Right Navigation Arrow Button
                                    if (currentImageIndex < productImages.length - 1)
                                      Positioned(
                                        right: 8,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: ClipOval(
                                            child: Material(
                                              color: Colors.black26,
                                              child: InkWell(
                                                onTap: () {
                                                  _pageController.nextPage(
                                                    duration: const Duration(milliseconds: 350),
                                                    curve: Curves.easeInOut,
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.brand,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: SportZoneTheme.secondary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.name.toUpperCase(),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatVnd(widget.product.price),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: SportZoneTheme.primary,
                                ),
                          ),
                          if (widget.product.originalPrice != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  formatVnd(widget.product.originalPrice!),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color: SportZoneTheme.secondary,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                BadgeTag(
                                  text: widget.product.discount ?? '',
                                  isAccent: true,
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          const Divider(color: SportZoneTheme.borderSubtle),
                          const SizedBox(height: 24),
                          Text(
                            'MÀU SẮC',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                                            isLoading 
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: CircularProgressIndicator(),
                                )
                              : Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: availableColors.map((colorName) {
                                    final selected = selectedColor == colorName;
                                    return ChoiceChip(
                                      label: Text(colorName),
                                      selected: selected,
                                      onSelected: (val) {
                                        if (val) {
                                          setState(() {
                                            selectedColor = colorName;
                                            _updateStock();
                                          });
                                        }
                                      },
                                      selectedColor: SportZoneTheme.primary,
                                      labelStyle: TextStyle(
                                        color: selected ? Colors.white : Colors.black,
                                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KÍCH CỠ',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              GestureDetector(
                                onTap: _showSizeGuideDialog,
                                child: Text(
                                  'Bảng size',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        decoration: TextDecoration.underline,
                                        color: SportZoneTheme.secondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          isLoading 
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: CircularProgressIndicator(),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: availableSizes.map((size) {
                                    final selected = selectedSize == size;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedSize = size;
                                          _updateStock();
                                        });
                                      },
                                      child: Container(
                                        height: 44,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? SportZoneTheme.primary
                                              : SportZoneTheme.surfaceVariant,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          size,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: selected
                                                    ? SportZoneTheme.onPrimary
                                                    : SportZoneTheme.secondary,
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                          if (!isLoading) ...[
                            const SizedBox(height: 16),
                            Text(
                              currentStock > 0 ? 'Số lượng kho: $currentStock' : 'Hết hàng',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: currentStock > 0 ? SportZoneTheme.primary : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          AccordionItem(
                            title: 'MÔ TẢ SẢN PHẨM',
                            content: widget.product.description.isNotEmpty 
                                ? widget.product.description 
                                : 'Chưa có mô tả cho sản phẩm này.',
                          ),
                          if (widget.product.material != null && widget.product.material!.isNotEmpty)
                            AccordionItem(
                              title: 'CHẤT LIỆU',
                              content: widget.product.material!,
                            ),
                          if (widget.product.gender != null && widget.product.gender!.isNotEmpty)
                            AccordionItem(
                              title: 'GIỚI TÍNH',
                              content: widget.product.gender == 'men' ? 'Nam' : (widget.product.gender == 'women' ? 'Nữ' : 'Unisex'),
                            ),
                          if (widget.product.origin != null && widget.product.origin!.isNotEmpty)
                            AccordionItem(
                              title: 'XUẤT XỨ',
                              content: widget.product.origin!,
                            ),
                          AccordionItem(
                            title: 'BẢO HÀNH',
                            content: (widget.product.warrantyInfo != null && widget.product.warrantyInfo!.isNotEmpty)
                                ? widget.product.warrantyInfo!
                                : 'Bảo hành chính hãng 6 tháng. Đổi trả miễn phí trong 30 ngày.',
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'CÓ THỂ BẠN SẼ THÍCH',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                              itemCount: recommended.length,
                              padding: const EdgeInsets.only(right: 16),
                              itemBuilder: (context, index) {
                                final product = recommended[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final error = await state.addToCart(product);
                                    if (!context.mounted) return;
                                    if (error != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: SizedBox(
                                            width: 160,
                                            height: 160,
                                            child: ProductImage(
                                              imageUrl: product.imageUrl,
                                              productName: product.name,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          product.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatVnd(product.price),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: SportZoneTheme.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 148),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        color: SportZoneTheme.surface,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: SportZoneTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.remove, size: 18),
                        color: SportZoneTheme.primary,
                        onPressed: quantity <= 1
                            ? null
                            : () => setState(() => quantity--),
                      ),
                      SizedBox(
                        width: 24,
                        child: Text(
                          quantity.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.add, size: 18),
                        color: SportZoneTheme.primary,
                        onPressed: quantity >= currentStock
                            ? null
                            : () => setState(() => quantity++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SportZoneTheme.primary,
                      foregroundColor: SportZoneTheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      disabledBackgroundColor: SportZoneTheme.borderSubtle,
                      disabledForegroundColor: SportZoneTheme.secondary,
                    ),
                     onPressed: (currentStock == 0 || isLoading) ? null : () async {
                       setState(() => isLoading = true);
                       final error = await state.addToCart(
                         widget.product,
                         size: selectedSize,
                         color: selectedColor,
                         quantity: quantity,
                       );
                       setState(() => isLoading = false);
                       if (!context.mounted) return;
                       if (error != null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(error)),
                         );
                       } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                         );
                       }
                     },
                    child: Text(
                      (currentStock == 0 && !isLoading) ? 'HẾT HÀNG' : 'THÊM VÀO GIỎ HÀNG',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: (currentStock == 0 || isLoading) ? SportZoneTheme.secondary : SportZoneTheme.onPrimary,
                        fontWeight: FontWeight.w900,
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
  }

  void _showSizeGuideDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Bảng Size Tiêu Chuẩn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dành cho Nam (Quần/Áo)', style: TextStyle(fontWeight: FontWeight.bold, color: SportZoneTheme.primary)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(color: SportZoneTheme.surfaceVariant),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Chiều cao (cm)', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ]
                    ),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('S')), Padding(padding: EdgeInsets.all(8.0), child: Text('160 - 165')), Padding(padding: EdgeInsets.all(8.0), child: Text('50 - 55'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('M')), Padding(padding: EdgeInsets.all(8.0), child: Text('166 - 169')), Padding(padding: EdgeInsets.all(8.0), child: Text('56 - 65'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('L')), Padding(padding: EdgeInsets.all(8.0), child: Text('170 - 174')), Padding(padding: EdgeInsets.all(8.0), child: Text('66 - 75'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('XL')), Padding(padding: EdgeInsets.all(8.0), child: Text('175 - 179')), Padding(padding: EdgeInsets.all(8.0), child: Text('76 - 85'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('XXL')), Padding(padding: EdgeInsets.all(8.0), child: Text('180 - 185')), Padding(padding: EdgeInsets.all(8.0), child: Text('86 - 95'))]),
                  ]
                ),
                const SizedBox(height: 24),
                const Text('Dành cho Nữ (Quần/Áo)', style: TextStyle(fontWeight: FontWeight.bold, color: SportZoneTheme.primary)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(color: SportZoneTheme.surfaceVariant),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Chiều cao (cm)', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Cân nặng (kg)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ]
                    ),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('S')), Padding(padding: EdgeInsets.all(8.0), child: Text('150 - 155')), Padding(padding: EdgeInsets.all(8.0), child: Text('40 - 45'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('M')), Padding(padding: EdgeInsets.all(8.0), child: Text('156 - 160')), Padding(padding: EdgeInsets.all(8.0), child: Text('46 - 50'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('L')), Padding(padding: EdgeInsets.all(8.0), child: Text('161 - 165')), Padding(padding: EdgeInsets.all(8.0), child: Text('51 - 55'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('XL')), Padding(padding: EdgeInsets.all(8.0), child: Text('166 - 170')), Padding(padding: EdgeInsets.all(8.0), child: Text('56 - 60'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('XXL')), Padding(padding: EdgeInsets.all(8.0), child: Text('171 - 175')), Padding(padding: EdgeInsets.all(8.0), child: Text('61 - 65'))]),
                  ]
                ),
                const SizedBox(height: 24),
                const Text('Giày Thể Thao (Unisex)', style: TextStyle(fontWeight: FontWeight.bold, color: SportZoneTheme.primary)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(color: SportZoneTheme.surfaceVariant),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Chiều dài chân (cm)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ]
                    ),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('38')), Padding(padding: EdgeInsets.all(8.0), child: Text('23.5 - 24.0'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('39')), Padding(padding: EdgeInsets.all(8.0), child: Text('24.1 - 24.5'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('40')), Padding(padding: EdgeInsets.all(8.0), child: Text('24.6 - 25.0'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('41')), Padding(padding: EdgeInsets.all(8.0), child: Text('25.1 - 25.5'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('42')), Padding(padding: EdgeInsets.all(8.0), child: Text('25.6 - 26.0'))]),
                    TableRow(children: [Padding(padding: EdgeInsets.all(8.0), child: Text('43')), Padding(padding: EdgeInsets.all(8.0), child: Text('26.1 - 26.5'))]),
                  ]
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ĐÓNG', style: TextStyle(fontWeight: FontWeight.bold, color: SportZoneTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: SportZoneTheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: SportZoneTheme.primary),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({required this.product, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
