import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../config/app_colors.dart';
import '../models/song.dart';
import '../services/api_service.dart';
import '../providers/music_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _movieController = TextEditingController();
  final _singerController = TextEditingController();
  final _actorController = TextEditingController();
  final _actressController = TextEditingController();
  final _composerController = TextEditingController();
  final _lyricistController = TextEditingController();
  final _categoryController = TextEditingController();

  PlatformFile? _songFile;
  PlatformFile? _imageFile;

  bool _isLoading = false;
  Song? _editingSong;

  @override
  void dispose() {
    _nameController.dispose();
    _movieController.dispose();
    _singerController.dispose();
    _actorController.dispose();
    _actressController.dispose();
    _composerController.dispose();
    _lyricistController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showAddEditDialog({Song? song}) {
    if (song != null) {
      _editingSong = song;
      _nameController.text = song.name;
      _movieController.text = song.movie;
      _singerController.text = song.singer;
      _actorController.text = song.actor ?? '';
      _actressController.text = song.actress ?? '';
      _composerController.text = song.composer;
      _lyricistController.text = song.lyricist;
      _categoryController.text = song.category;
      _songFile = null;
      _imageFile = null;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          // Inner helper function to trigger pickers and update modal bottom sheet state
          Future<void> pickSong() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3', 'mp4', 'm4a', 'wav', 'aac'],
              );
              if (result != null && result.files.isNotEmpty) {
                setModalState(() {
                  _songFile = result.files.first;
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error picking song: $e'),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
            }
          }

          Future<void> pickImage() async {
            try {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (result != null && result.files.isNotEmpty) {
                setModalState(() {
                  _imageFile = result.files.first;
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error picking image: $e'),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
            }
          }

          Future<void> save() async {
            debugPrint("=== SAVE SONG CLICKED ===");
            if (_formKey.currentState == null) {
              debugPrint("FormState is NULL!");
              return;
            }
            final isValid = _formKey.currentState!.validate();
            debugPrint("Form validation result: $isValid");
            if (!isValid) return;

            debugPrint("Files selected: songFile=${_songFile?.name}, imageFile=${_imageFile?.name}");

            if (_editingSong == null && _songFile == null) {
              debugPrint("Error: songFile is null during creation");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a song file'),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
              return;
            }

            if (_editingSong == null && _imageFile == null) {
              debugPrint("Error: imageFile is null during creation");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select an image file'),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
              return;
            }

            setModalState(() => _isLoading = true);
            setState(() => _isLoading = true);

            try {
              final song = Song(
                id: _editingSong?.id ?? 0,
                name: _nameController.text,
                movie: _movieController.text,
                singer: _singerController.text,
                actor: _actorController.text.isEmpty ? null : _actorController.text,
                actress: _actressController.text.isEmpty ? null : _actressController.text,
                composer: _composerController.text,
                lyricist: _lyricistController.text,
                category: _categoryController.text,
                songUrl: _editingSong?.songUrl ?? '',
                imageUrl: _editingSong?.imageUrl ?? '',
              );

              debugPrint("Sending save song request to ApiService: name=${song.name}");
              if (_editingSong != null) {
                await ApiService.updateSong(song, _songFile, _imageFile);
              } else {
                await ApiService.createSong(song, _songFile!, _imageFile!);
              }
              debugPrint("ApiService save song request succeeded!");

              if (!mounted) return;

              Navigator.pop(context);
              context.read<MusicProvider>().fetchAllSongs();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _editingSong != null
                        ? 'Song updated successfully'
                        : 'Song added successfully',
                  ),
                  backgroundColor: AppColors.cyan,
                ),
              );
            } catch (e) {
              debugPrint("Save song failed with error: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.primaryRed,
                ),
              );
            } finally {
              setModalState(() => _isLoading = false);
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          }

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _editingSong != null ? 'Edit Song Details' : 'Add New Song',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_nameController, 'Song Name'),
                    _buildTextField(_movieController, 'Movie'),
                    _buildTextField(_singerController, 'Singer'),
                    _buildTextField(_actorController, 'Actor', optional: true),
                    _buildTextField(_actressController, 'Actress', optional: true),
                    _buildTextField(_composerController, 'Composer'),
                    _buildTextField(_lyricistController, 'Lyricist'),
                    _buildTextField(_categoryController, 'Category'),
                    const SizedBox(height: 12),
                    _buildFilePicker(
                      label: 'Song Audio File',
                      onTap: pickSong,
                      selectedFile: _songFile,
                      existingUrl: _editingSong?.songUrl,
                      icon: Icons.music_note,
                    ),
                    _buildImagePicker(
                      onTap: pickImage,
                      selectedFile: _imageFile,
                      existingUrl: _editingSong?.imageUrl,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator(color: AppColors.cyan)
                        : ElevatedButton(
                            onPressed: save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _clearForm() {
    _editingSong = null;
    _nameController.clear();
    _movieController.clear();
    _singerController.clear();
    _actorController.clear();
    _actressController.clear();
    _composerController.clear();
    _lyricistController.clear();
    _categoryController.clear();
    _songFile = null;
    _imageFile = null;
  }

  Future<void> _deleteSong(Song song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.navyBlue,
        title: const Text('Delete Song'),
        content: Text('Delete "${song.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await context.read<MusicProvider>().deleteSong(song.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Song "${song.name}" deleted successfully'),
            backgroundColor: AppColors.cyan,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting song: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Manage Songs', style: Theme.of(context).textTheme.displaySmall),
                    FloatingActionButton(
                      backgroundColor: AppColors.primaryRed,
                      onPressed: () => _showAddEditDialog(),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: musicProvider.allSongs.length,
                  itemBuilder: (_, i) {
                    final song = musicProvider.allSongs[i];
                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.darkGrey,
                              child: const Icon(Icons.music_note, color: AppColors.cyan, size: 20),
                            ),
                          ),
                        ),
                      ),
                      title: Text(song.name),
                      subtitle: Text(song.singer),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.cyan),
                            onPressed: () => _showAddEditDialog(song: song),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.primaryRed),
                            onPressed: () => _deleteSong(song),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker({
    required String label,
    required VoidCallback onTap,
    required PlatformFile? selectedFile,
    required String? existingUrl,
    required IconData icon,
  }) {
    String statusText = 'No file selected';
    bool hasFile = false;

    if (selectedFile != null) {
      statusText = selectedFile.name;
      hasFile = true;
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      try {
        final segments = Uri.parse(existingUrl).pathSegments;
        if (segments.isNotEmpty) {
          statusText = 'Using existing: ${segments.last}';
        } else {
          statusText = 'Using existing file';
        }
      } catch (_) {
        statusText = 'Using existing file';
      }
      hasFile = true;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasFile ? AppColors.cyan.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasFile ? AppColors.cyan.withOpacity(0.1) : AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: hasFile ? AppColors.cyan : AppColors.lightGrey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasFile ? AppColors.white : AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Choose'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker({
    required VoidCallback onTap,
    required PlatformFile? selectedFile,
    required String? existingUrl,
  }) {
    Widget? imagePreview;

    if (selectedFile != null) {
      if (kIsWeb && selectedFile.bytes != null) {
        imagePreview = Image.memory(selectedFile.bytes!, fit: BoxFit.cover);
      } else if (selectedFile.path != null) {
        imagePreview = Image.file(io.File(selectedFile.path!), fit: BoxFit.cover);
      }
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      imagePreview = Image.network(existingUrl, fit: BoxFit.cover);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: imagePreview != null ? AppColors.cyan.withOpacity(0.5) : AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePreview != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imagePreview,
                    )
                  : const Icon(Icons.image, color: AppColors.lightGrey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Song Cover Image',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedFile != null
                        ? selectedFile.name
                        : (existingUrl != null && existingUrl.isNotEmpty ? 'Using existing image' : 'No image selected'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: imagePreview != null ? AppColors.white : AppColors.lightGrey,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Choose'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: optional ? '$label (optional)' : label),
        validator: optional ? null : (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}

