// lib/models/artwork.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Artwork {
  final String id;
  final String title;
  final String artist;
  final List<String> imageUrls;
  final String thumbnailUrl;
  final String category;
  final List<String> tags;
  final Map<String, dynamic> dimensions;
  final String description;
  final double price;
  final bool isFree;
  final DateTime createdAt;
  final bool isArchived;
  final bool isDownloadable; // NEW FIELD

  Artwork({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrls,
    required this.thumbnailUrl,
    required this.category,
    required this.tags,
    required this.dimensions,
    required this.description,
    required this.price,
    required this.isFree,
    required this.createdAt,
    this.isArchived = false,
    this.isDownloadable = true, // NEW: Default to downloadable
  });

  factory Artwork.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Artwork(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      artist: data['artist'] ?? 'Unknown Artist',
      imageUrls: List<String>.from(data['imageUrls'] ?? (data['imageUrl'] != null ? [data['imageUrl']] : [])),
      thumbnailUrl: data['thumbnailUrl'] ?? (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty ? data['imageUrls'][0] : ''),
      category: data['category'] ?? 'Uncategorized',
      tags: List<String>.from(data['tags'] ?? []),
      dimensions: Map<String, dynamic>.from(data['dimensions'] ?? {}),
      description: data['description'] ?? 'No description provided.',
      price: (data['price'] ?? 0.0).toDouble(),
      isFree: data['isFree'] ?? true,
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isArchived: data['isArchived'] ?? false,
      isDownloadable: data['isDownloadable'] ?? true, // NEW: Read from Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'imageUrls': imageUrls,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'tags': tags,
      'dimensions': dimensions,
      'description': description,
      'price': price,
      'isFree': isFree,
      'createdAt': createdAt, // Use the object's date on updates
      'isArchived': isArchived,
      'isDownloadable': isDownloadable, // NEW: Write to Firestore
    };
  }

  Artwork copyWith({
    String? id,
    String? title,
    String? artist,
    List<String>? imageUrls,
    String? thumbnailUrl,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? dimensions,
    String? description,
    double? price,
    bool? isFree,
    DateTime? createdAt,
    bool? isArchived,
    bool? isDownloadable, // NEW
  }) {
    return Artwork(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      dimensions: dimensions ?? this.dimensions,
      description: description ?? this.description,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      isDownloadable: isDownloadable ?? this.isDownloadable, // NEW
    );
  }
}