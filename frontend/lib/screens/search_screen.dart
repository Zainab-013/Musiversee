import 'dart:async';

import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import '../widgets/song_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> categories = [
    {'name': 'English', 'gradient': AppColors.categoryGradient1},
    {'name': 'Hindi', 'gradient': AppColors.categoryGradient2},
    {'name': 'Punjabi', 'gradient': AppColors.categoryGradient3},
    {'name': 'Korean', 'gradient': AppColors.categoryGradient4},
    {'name': 'Pop', 'gradient': AppColors.categoryGradient1},
    {'name': 'Romantic', 'gradient': AppColors.categoryGradient2},
    {'name': 'Classic', 'gradient': AppColors.categoryGradient3},
    {'name': 'Motivational', 'gradient': AppColors.categoryGradient4},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<Song> get filteredResults {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];
    if (_selectedFilter == 'All') return _searchResults;
    return _searchResults.where((song) {
      if (_selectedFilter == 'Songs') {
        return song.name.toLowerCase().contains(query);
      } else if (_selectedFilter == 'Artists') {
        return song.singer.toLowerCase().contains(query);
      } else if (_selectedFilter == 'Movies') {
        return song.movie.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _selectedFilter = 'All';
      });
      return;
    }
    setState(() {
      _selectedFilter = 'All';
    });
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final results = await musicProvider.searchSongs(query);

    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _navigateToCategorySongs(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySongsScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, movies',
                    prefixIcon: const Icon(Icons.search, color: AppColors.cyan),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                ),
              ),

              // Filter Chips
              if (_searchController.text.isNotEmpty) _buildFilterChips(),

              // Content
              Expanded(
                child: _searchController.text.isEmpty
                    ? _buildCategories()
                    : _isSearching
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.cyan,
                            ),
                          )
                        : filteredResults.isEmpty
                            ? const Center(
                                child: Text('No results found'),
                              )
                            : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Songs', 'Artists', 'Movies'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.cyan, AppColors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : AppColors.darkGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.cyan : AppColors.lightGrey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.lightGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Browse Categories',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => _navigateToCategorySongs(category['name']),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: category['gradient'] as LinearGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final musicProvider = Provider.of<MusicProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final results = filteredResults;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return SongCard(
          song: song,
          onTap: () {
            musicProvider.playSong(song, playlist: results);
          },
          onLike: () {
            if (authProvider.user == null) return;
            if (musicProvider.isSongLiked(song.id)) {
              musicProvider.unlikeSong(authProvider.user!.id, song);
            } else {
              musicProvider.likeSong(authProvider.user!.id, song);
            }
          },
          isLiked: musicProvider.isSongLiked(song.id),
        );
      },
    );
  }
}

class CategorySongsScreen extends StatefulWidget {
  final String category;

  const CategorySongsScreen({super.key, required this.category});

  @override
  State<CategorySongsScreen> createState() => _CategorySongsScreenState();
}

class _CategorySongsScreenState extends State<CategorySongsScreen> {
  List<Song> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final songs = await musicProvider.fetchSongsByCategory(widget.category);
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.cyan),
              )
            : _songs.isEmpty
                ? const Center(child: Text('No songs found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      return SongCard(
                        song: song,
                        onTap: () {
                          musicProvider.playSong(song, playlist: _songs);
                        },
                        onLike: () {
                          if (authProvider.user == null) return;
                          if (musicProvider.isSongLiked(song.id)) {
                            musicProvider.unlikeSong(authProvider.user!.id, song);
                          } else {
                            musicProvider.likeSong(authProvider.user!.id, song);
                          }
                        },
                        isLiked: musicProvider.isSongLiked(song.id),
                      );
                    },
                  ),
      ),
    );
  }
}