import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'admin_product_form_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when entering admin screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SportZoneState>().fetchProducts();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('XÓA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang xóa...')),
    );

    final result = await ApiService.deleteProduct(product.id);
    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa sản phẩm thành công!')),
      );
      context.read<SportZoneState>().fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Lỗi khi xóa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        title: const Text('Quản lý Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: SportZoneTheme.primary, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoadingProducts
          ? const Center(child: CircularProgressIndicator(color: SportZoneTheme.primary))
          : RefreshIndicator(
              onRefresh: () async {
                await state.fetchProducts();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.apiProducts.length,
                itemBuilder: (context, index) {
                  final product = state.apiProducts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: ProductImage(
                            imageUrl: product.imageUrl,
                            productName: product.name,
                          ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(formatVnd(product.price), style: const TextStyle(color: SportZoneTheme.primary, fontWeight: FontWeight.w600)),
                          Text('Kho: ${product.totalStock} | Danh mục: ${product.category}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AdminProductFormScreen(product: product)),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
