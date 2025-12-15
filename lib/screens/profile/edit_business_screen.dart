import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class EditBusinessScreen extends StatefulWidget {
  final BusinessModel business;

  const EditBusinessScreen({super.key, required this.business});

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _contactInfoController;
  final ImagePicker _picker = ImagePicker();
  
  File? _newLogoFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _descriptionController = TextEditingController(text: widget.business.description);
    _addressController = TextEditingController(text: widget.business.address);
    _contactInfoController = TextEditingController(text: widget.business.contactInfo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() => _newLogoFile = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final businessService = Provider.of<BusinessService>(context, listen: false);

      String logoUrl = widget.business.logoUrl;
      if (_newLogoFile != null) {
        logoUrl = await businessService.uploadLogo(_newLogoFile!, _nameController.text);
      }

      final updates = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'contact_info': _contactInfoController.text.trim(),
        'logo_url': logoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await businessService.updateBusiness(widget.business.businessId, updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Picker
              Center(
                child: GestureDetector(
                  onTap: _pickLogo,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _newLogoFile != null ? AppColors.primaryBlue : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _newLogoFile != null
                          ? Image.file(_newLogoFile!, fit: BoxFit.cover)
                          : widget.business.logoUrl.isNotEmpty
                              ? Image.network(
                                  widget.business.logoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.store_mall_directory, size: 40, color: Colors.grey),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
                                    SizedBox(height: 4),
                                    Text('Logo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _pickLogo,
                  child: const Text('Change Logo'),
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _nameController,
                hintText: 'Business Name',
                prefixIcon: const Icon(Icons.store_mall_directory_outlined, color: AppColors.textLight),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Business name is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                hintText: 'Description',
                prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textLight),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Description is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _addressController,
                hintText: 'Address',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.textLight),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Address is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactInfoController,
                hintText: 'Contact Info (Email/Phone)',
                prefixIcon: const Icon(Icons.contact_phone_outlined, color: AppColors.textLight),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Contact info is required';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
