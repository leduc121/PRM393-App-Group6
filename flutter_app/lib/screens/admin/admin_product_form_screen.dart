import 'dart:io';
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
  File? _selectedImage;
  String? _uploadedImageUrl;
  final List<Map<String, dynamic>> _variants = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.originalPrice?.toString() ?? p?.price.toString() ?? '');
    _salePriceCtrl = TextEditingController(text: p?.originalPrice != null ? p?.price.toString() : '');
    _imageCtrl = TextEditingController(text: p?.imageUrl != 'https://via.placeholder.com/300x300?text=No+Image' ? p?.imageUrl : '');
    _materialCtrl = TextEditingController(text: p?.material ?? '');
    _originCtrl = TextEditingController(text: ''); // Not in local model yet, just skip or mock
    _warrantyCtrl = TextEditingController(text: '');
    _stockCtrl = TextEditingController(text: p?.totalStock.toString() ?? '0');

    _selectedCategoryId = p?.categoryId;
    _selectedBrandId = p?.brandId;
    _gender = p?.gender ?? 'unisex';

    // Fetch categories and brands if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<SportZoneState>();
      if (state.apiCategories.isEmpty) state.fetchCategories();
      if (state.apiBrands.isEmpty) state.fetchBrands();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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

    if (_selectedImage != null) {
      final uploadResult = await ApiService.uploadProductImage(_selectedImage!.path);
      if (uploadResult.isSuccess) {
        final String uploadedPath = uploadResult.data['url'];
        final host = ApiService.baseUrl.replaceAll('/api/v1', '');
        _uploadedImageUrl = host + uploadedPath;
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(uploadResult.errorMessage ?? 'Lỗi upload ảnh')));
        return;
      }
    }

    final data = {
      'categoryId': _selectedCategoryId,
      'brandId': finalBrandId,
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': int.parse(_priceCtrl.text),
      'salePrice': _salePriceCtrl.text.isNotEmpty ? int.parse(_salePriceCtrl.text) : null,
      'images': _uploadedImageUrl != null ? [_uploadedImageUrl!] : (_imageCtrl.text.isNotEmpty ? [_imageCtrl.text.trim()] : []),
      'material': _materialCtrl.text.trim(),
      'gender': _gender,
      'origin': _originCtrl.text.trim(),
      'warrantyInfo': _warrantyCtrl.text.trim(),
      'variants': _variants,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _imageCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'Ảnh sản phẩm', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _selectedImage = File(pickedFile.path);
                                _imageCtrl.text = pickedFile.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Chọn ảnh'),
                        ),
                      ],
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: Image.file(_selectedImage!),
                      ),
                    ] else if (_imageCtrl.text.isNotEmpty && _imageCtrl.text.startsWith('http')) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: Image.network(_imageCtrl.text, errorBuilder: (c, e, s) => const Text('Ảnh không hợp lệ')),
                      ),
                    ],
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
