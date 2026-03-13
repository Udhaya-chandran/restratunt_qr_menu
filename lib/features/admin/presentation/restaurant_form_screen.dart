import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RestaurantFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? restaurant;
  const RestaurantFormScreen({super.key, this.restaurant});

  @override
  ConsumerState<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends ConsumerState<RestaurantFormScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      _nameController.text = widget.restaurant!['name'] ?? '';
      _addressController.text = widget.restaurant!['city'] ?? '';
      _phoneController.text = widget.restaurant!['phone'] ?? '';
      _descriptionController.text = widget.restaurant!['description'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? finalImageUrl = widget.restaurant != null ? widget.restaurant!['image_url'] : null;
      
      if (_selectedImage != null) {
        finalImageUrl = await ref.read(supabaseServiceProvider).uploadImage(
          'restaurant-media',
          'restaurants',
          _selectedImage!,
        );
      }

      final slug = _nameController.text.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9-]'), '');
      
      await ref.read(supabaseServiceProvider).saveRestaurant({
        if (widget.restaurant != null) 'id': widget.restaurant!['id'],
        'name': _nameController.text.trim(),
        'city': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': finalImageUrl,
        'slug': slug,
      });

      if (mounted) {
        ref.invalidate(restaurantsProvider);
        ref.invalidate(allCategoriesProvider);
        ref.invalidate(allMenuItemsProvider);
        context.pop();
      }
    } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(content: Text('Error saving restaurant: $e')),
            );
        }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant != null ? 'EDIT RESTAURANT' : 'ADD RESTAURANT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(context, 'Restaurant Name', Icons.store, _nameController),
            const SizedBox(height: 20),
            _buildTextField(context, 'Address', Icons.location_on, _addressController),
            const SizedBox(height: 20),
            _buildTextField(context, 'Phone Number', Icons.phone, _phoneController),
            const SizedBox(height: 20),
            _buildTextField(context, 'Description / Caption', Icons.description, _descriptionController, maxLines: 3),
            const SizedBox(height: 30),
            
            // Image Upload Section
            const Text('Restaurant Image', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : (widget.restaurant?['image_url'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(widget.restaurant!['image_url'], fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, size: 40, color: AppTheme.primaryGold),
                              const SizedBox(height: 8),
                              Text('Select Image', style: TextStyle(color: AppTheme.primaryGold.withValues(alpha: 0.7))),
                            ],
                          )),
              ),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Text(widget.restaurant != null ? 'UPDATE RESTAURANT' : 'SAVE RESTAURANT', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ).animate().scale(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryGold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGold, width: 2),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }
}
