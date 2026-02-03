import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _songUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

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
    _songUrlController.dispose();
    _imageUrlController.dispose();
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
      _songUrlController.text = song.songUrl;
      _imageUrlController.text = song.imageUrl;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSongForm(),
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
    _songUrlController.clear();
    _imageUrlController.clear();
  }

  Future<void> _saveSong() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final song = Song(
        id: _editingSong?.id ?? 0, // backend generates ID
        name: _nameController.text,
        movie: _movieController.text,
        singer: _singerController.text,
        actor: _actorController.text.isEmpty ? null : _actorController.text,
        actress: _actressController.text.isEmpty ? null : _actressController.text,
        composer: _composerController.text,
        lyricist: _lyricistController.text,
        category: _categoryController.text,
        songUrl: _songUrlController.text,
        imageUrl: _imageUrlController.text,
      );

      if (_editingSong != null) {
        await ApiService.updateSong(song);
      } else {
        await ApiService.createSong(song);
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSong(Song song) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.navyBlue,
        title: const Text('Delete Song'),
        content: Text('Delete "${song.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.deleteSong(song.id);
      context.read<MusicProvider>().fetchAllSongs();
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
                      leading: Image.network(song.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
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

  Widget _buildSongForm() {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Song Name'),
              _buildTextField(_movieController, 'Movie'),
              _buildTextField(_singerController, 'Singer'),
              _buildTextField(_actorController, 'Actor'),
              _buildTextField(_actressController, 'Actress'),
              _buildTextField(_composerController, 'Composer'),
              _buildTextField(_lyricistController, 'Lyricist'),
              _buildTextField(_categoryController, 'Category'),
              _buildTextField(_songUrlController, 'Song URL'),
              _buildTextField(_imageUrlController, 'Image URL'),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveSong, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}

