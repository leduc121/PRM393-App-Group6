import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_app/core.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Product? product; // If null, it's create mode. If not null, edit mode.

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _shortDescCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _salePriceCtrl;
  late TextEditingController _imageCtrl;
  late TextEditingController _materialCtrl;
  late TextEditingController _originCtrl;
  late TextEditingController _warrantyCtrl;
  late TextEditingController _stockCtrl;

  String? _selectedCategoryId;
  String? _selectedBrandId;
  String? _customBrandName;
  String _gender = 'unisex';

  bool _isLoading = false;
  XFile? _mainImageFile;
  final List<Map<String, dynamic>> _subImages = [];
  final List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _shortDescCtrl = TextEditingController(text: p?.shortDescription ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.originalPrice?.toString() ?? p?.price.toString() ?? '');
    _salePriceCtrl = TextEditingController(text: p?.originalPrice != null ? p?.price.toString() : '');
    _imageCtrl = TextEditingController(text: p?.imageUrl != 'https://via.placeholder.com/300x300?text=No+Image' ? p?.imageUrl : '');
    _materialCtrl = TextEditingController(text: p?.material ?? '');
    _originCtrl = TextEditingController(text: p?.origin ?? '');
    _warrantyCtrl = TextEditingController(text: p?.warrantyInfo ?? '');
    _stockCtrl = TextEditingController(text: p?.totalStock.toString() ?? '0');

    _selectedCategoryId = p?.categoryId;
    _selectedBrandId = p?.brandId;
    _gender = p?.gender ?? 'unisex';

    if (p != null && p.images.length > 1) {
      for (int i = 1; i < p.images.length; i++) {
        _subImages.add({
          'url': p.images[i],
          'file': null,
        });
      }
    }

    // Fetch categories and brands if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<SportZoneState>();
      if (state.apiCategories.isEmpty) state.fetchCategories();
      if (state.apiBrands.isEmpty) state.fetchBrands();
      if (widget.product != null) {
        _loadProductDetail();
      }
    });
  }

  String _resolveImageUrl(String url) {
    if (url.startsWith('/')) {
      final host = ApiService.baseUrl.replaceAll('/api/v1', '');
      return host + url;
    }
    return url;
  }

  Future<void> _loadProductDetail() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getProductDetail(widget.product!.id);
    if (result.isSuccess) {
      final data = result.data;
      setState(() {
        _nameCtrl.text = data['name']?.toString() ?? '';
        _shortDescCtrl.text = data['shortDescription']?.toString() ?? data['short_description']?.toString() ?? '';
        _descCtrl.text = data['description']?.toString() ?? '';
        _priceCtrl.text = data['price']?.toString() ?? '';
        _salePriceCtrl.text = data['salePrice']?.toString() ?? '';
        _imageCtrl.text = (data['images'] is List && (data['images'] as List).isNotEmpty)
            ? (data['images'] as List).first.toString()
            : '';
        _materialCtrl.text = data['material']?.toString() ?? '';
        _originCtrl.text = data['origin']?.toString() ?? '';
        _warrantyCtrl.text = data['warrantyInfo']?.toString() ?? data['warranty_info']?.toString() ?? '';
        
        _selectedCategoryId = data['categoryId'] ?? data['category_id'];
        _selectedBrandId = data['brandId'] ?? data['brand_id'];
        _gender = data['gender']?.toString() ?? 'unisex';

        _subImages.clear();
        if (data['images'] is List && (data['images'] as List).length > 1) {
          final list = data['images'] as List;
          for (int i = 1; i < list.length; i++) {
            _subImages.add({
              'url': list[i].toString(),
              'file': null,
            });
          }
        }

        _variants.clear();
        if (data['variants'] is List) {
          for (var v in data['variants']) {
            _variants.add({
              'size': v['size'],
              'colorName': v['colorName'] ?? v['color_name'],
              'stockQty': v['stockQty'] ?? v['stock_qty'] ?? 0,
            });
          }
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết sản phẩm: ${result.errorMessage}')),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortDescCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _salePriceCtrl.dispose();
    _imageCtrl.dispose();
    _materialCtrl.dispose();
    _originCtrl.dispose();
    _warrantyCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedBrandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn Danh mục và Thương hiệu')));
      return;
    }

    setState(() => _isLoading = true);

    String finalBrandId = _selectedBrandId!;
    if (_selectedBrandId == 'OTHER') {
      final brandResult = await ApiService.createBrand(_customBrandName!.trim());
      if (brandResult.isSuccess) {
        finalBrandId = brandResult.data['brandId'];
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tạo thương hiệu: ${brandResult.errorMessage}')));
        return;
      }
    }

    // 1. Upload main image if picked from local
    String mainImageUrl = '';
    if (_mainImageFile != null) {
      final bytes = kIsWeb ? await _mainImageFile!.readAsBytes() : null;
      final uploadResult = await ApiService.uploadProductImage(
        _mainImageFile!.path,
        bytes: bytes,
        fileName: _mainImageFile!.name,
      );
      if (uploadResult.isSuccess) {
        mainImageUrl = uploadResult.data['url'];
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi upload ảnh chính: ${uploadResult.errorMessage}')));
        return;
      }
    } else {
      mainImageUrl = _imageCtrl.text.trim();
    }

    // Clean localhost prefix if present to keep DB relative
    if (mainImageUrl.startsWith('http://localhost:3000/api/v1/products/uploads/')) {
      mainImageUrl = mainImageUrl.replaceAll('http://localhost:3000', '');
    } else if (mainImageUrl.startsWith('http://127.0.0.1:3000/uploads/')) {
      mainImageUrl = mainImageUrl.replaceAll('http://127.0.0.1:3000', '/api/v1/products');
    }

    // 2. Upload sub images if picked from local
    final List<String> finalSubUrls = [];
    for (var sub in _subImages) {
      if (sub['file'] != null) {
        final file = sub['file'] as XFile;
        final bytes = kIsWeb ? await file.readAsBytes() : null;
        final uploadResult = await ApiService.uploadProductImage(
          file.path,
          bytes: bytes,
          fileName: file.name,
        );
        if (uploadResult.isSuccess) {
          finalSubUrls.add(uploadResult.data['url']);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi upload ảnh phụ: ${uploadResult.errorMessage}')));
          return;
        }
      } else if (sub['url'] != null && sub['url'].toString().trim().isNotEmpty) {
        var urlStr = sub['url'].toString().trim();
        if (urlStr.startsWith('http://localhost:3000/api/v1/products/uploads/')) {
          urlStr = urlStr.replaceAll('http://localhost:3000', '');
        } else if (urlStr.startsWith('http://127.0.0.1:3000/uploads/')) {
          urlStr = urlStr.replaceAll('http://127.0.0.1:3000', '/api/v1/products');
        }
        finalSubUrls.add(urlStr);
      }
    }

    // Combine main + sub images
    final List<String> finalImages = [];
    if (mainImageUrl.isNotEmpty) {
      finalImages.add(mainImageUrl);
    }
    finalImages.addAll(finalSubUrls);

    final data = {
      'categoryId': _selectedCategoryId,
      'brandId': finalBrandId,
      'name': _nameCtrl.text.trim(),
      'shortDescription': _shortDescCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': int.parse(_priceCtrl.text),
      'salePrice': _salePriceCtrl.text.isNotEmpty ? int.parse(_salePriceCtrl.text) : null,
      'images': finalImages,
      'material': _materialCtrl.text.trim(),
      'gender': _gender,
      'origin': _originCtrl.text.trim(),
      'warrantyInfo': _warrantyCtrl.text.trim(),
      'variants': _variants.map((v) => {
        'size': v['size'],
        'colorName': v['colorName'],
        'stockQty': v['stockQty'],
      }).toList(),
    };

    ApiResult result;
    if (widget.product == null) {
      result = await ApiService.createProduct(data);
    } else {
      result = await ApiService.updateProduct(widget.product!.id, data);
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.product == null ? 'Thêm mới thành công!' : 'Cập nhật thành công!')),
      );
      context.read<SportZoneState>().fetchProducts();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Đã xảy ra lỗi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Sản phẩm' : 'Thêm Sản phẩm', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Tên sản phẩm (*)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Danh mục (*)', border: OutlineInputBorder()),
                            value: _selectedCategoryId,
                            items: state.apiCategories.map((c) => DropdownMenuItem(value: c.categoryId, child: Text(c.name))).toList(),
                            onChanged: (v) => setState(() => _selectedCategoryId = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Thương hiệu (*)', border: OutlineInputBorder()),
                                value: _selectedBrandId,
                                items: [
                                  ...state.apiBrands.map((b) => DropdownMenuItem(value: b.brandId, child: Text(b.name))),
                                  const DropdownMenuItem(value: 'OTHER', child: Text('Khác... (Thêm mới)')),
                                ],
                                onChanged: (v) => setState(() => _selectedBrandId = v),
                              ),
                              if (_selectedBrandId == 'OTHER') ...[
                                const SizedBox(height: 8),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Tên thương hiệu mới (*)', border: OutlineInputBorder()),
                                  onChanged: (v) => _customBrandName = v,
                                  validator: (v) => (_selectedBrandId == 'OTHER' && (v == null || v.trim().isEmpty)) ? 'Vui lòng nhập tên' : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Giá gốc (VNĐ) (*)', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _salePriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Giá KM (Nếu có)', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Giới tính', border: OutlineInputBorder()),
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'men', child: Text('Nam')),
                        DropdownMenuItem(value: 'women', child: Text('Nữ')),
                        DropdownMenuItem(value: 'unisex', child: Text('Unisex')),
                      ],
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                    const SizedBox(height: 16),
                    // --- 1. Ảnh chính (Main Image) ---
                    const Text('Ảnh chính (*)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageCtrl,
                            onChanged: (value) {
                              setState(() {
                                if (_mainImageFile != null) {
                                  _mainImageFile = null;
                                }
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'URL Ảnh chính hoặc chọn file từ máy',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _mainImageFile = pickedFile;
                                _imageCtrl.text = pickedFile.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Chọn ảnh chính'),
                        ),
                      ],
                    ),
                    if (_mainImageFile != null || _imageCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: _mainImageFile != null
                              ? (kIsWeb
                                  ? Image.network(_mainImageFile!.path, fit: BoxFit.cover)
                                  : Image.file(File(_mainImageFile!.path), fit: BoxFit.cover))
                              : Image.network(_resolveImageUrl(_imageCtrl.text), fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox()),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // --- 2. Ảnh phụ (Sub Images) ---
                    const Text('Ảnh phụ (Ảnh chi tiết sản phẩm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ..._subImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: ValueKey('sub-img-$index-${item['file']?.name ?? ''}'),
                                initialValue: item['file'] != null ? item['file']!.name : (item['url']?.toString() ?? ''),
                                decoration: const InputDecoration(
                                  labelText: 'URL Ảnh phụ hoặc chọn file từ máy',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onChanged: (v) {
                                  item['url'] = v.trim();
                                  if (item['file'] != null) {
                                    setState(() {
                                      item['file'] = null;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                if (pickedFile != null) {
                                  setState(() {
                                    _subImages[index]['file'] = pickedFile;
                                  });
                                }
                              },
                              icon: const Icon(Icons.image, size: 16),
                              label: const Text('Chọn ảnh phụ', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            if (item['file'] != null || (item['url'] != null && item['url'].toString().trim().isNotEmpty)) ...[
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: item['file'] != null
                                      ? (kIsWeb
                                          ? Image.network(item['file']!.path, fit: BoxFit.cover)
                                          : Image.file(File(item['file']!.path), fit: BoxFit.cover))
                                      : Image.network(_resolveImageUrl(item['url'].toString()), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.error, size: 16)),
                                ),
                              ),
                            ],
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _subImages.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setState(() => _subImages.add({'url': '', 'file': null})),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm ảnh phụ'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shortDescCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Mô tả ngắn gọn', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Mô tả chi tiết', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _materialCtrl,
                      decoration: const InputDecoration(labelText: 'Chất liệu', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _originCtrl,
                      decoration: const InputDecoration(labelText: 'Xuất xứ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _warrantyCtrl,
                      decoration: const InputDecoration(labelText: 'Thông tin bảo hành', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tùy chọn Sản phẩm (Size & Màu)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ..._variants.asMap().entries.map((entry) {
                      final index = entry.key;
                      final variant = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Size', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                value: variant['size'],
                                items: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', 'FREE']
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                    .toList(),
                                onChanged: (v) => setState(() => _variants[index]['size'] = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Màu', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                value: ['Đen', 'Trắng', 'Đỏ', 'Xanh dương', 'Xanh lá', 'Vàng', 'Cam', 'Xám', 'Nâu', 'Hồng', 'Tím', 'Khác'].contains(variant['colorName']) ? variant['colorName'] : 'Đen',
                                items: ['Đen', 'Trắng', 'Đỏ', 'Xanh dương', 'Xanh lá', 'Vàng', 'Cam', 'Xám', 'Nâu', 'Hồng', 'Tím', 'Khác']
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) => setState(() => _variants[index]['colorName'] = v),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: variant['stockQty'].toString(),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'SL', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                                onChanged: (v) => _variants[index]['stockQty'] = int.tryParse(v) ?? 0,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _variants.removeAt(index)),
                            )
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setState(() => _variants.add({'size': 'M', 'colorName': 'Đen', 'stockQty': 0})),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm Size/Màu'),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SportZoneTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submitForm,
                        child: const Text('LƯU SẢN PHẨM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
