import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailyboost/features/quotes/data/models/custom_quote_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CustomQuoteRepository {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference for custom quotes
  CollectionReference get _customQuotesCollection => _firestore.collection('custom_quotes');
  
  // Helper to get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;
  
  // Create a new custom quote
  Future<CustomQuoteModel> createCustomQuote({
    required String content,
    required String author,
    required String mood,
    bool isPublic = false,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User must be logged in to create a custom quote');
      }
      
      // Generate a unique ID
      final String quoteId = const Uuid().v4();
      
      // Create the custom quote model
      final CustomQuoteModel quote = CustomQuoteModel(
        id: quoteId,
        content: content,
        author: author,
        mood: mood,
        userId: _currentUserId,
        createdAt: Timestamp.now(),
        isPublic: isPublic,
      );
      
      // Save to Firestore
      await _customQuotesCollection.doc(quoteId).set(quote.toMap());
      
      return quote;
    } catch (e) {
      debugPrint('Error creating custom quote: $e');
      throw Exception('Failed to create custom quote: $e');
    }
  }
  
  // Get all custom quotes for the current user with pagination
  Future<List<CustomQuoteModel>> getUserCustomQuotes({
    int limit = 10,
    CustomQuoteModel? lastDoc,
  }) async {
    try {
      if (_currentUserId == null) {
        return [];
      }
      
      Query query = _customQuotesCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true);
        
      // Apply pagination if lastDoc is provided
      if (lastDoc != null) {
        query = query.startAfter([lastDoc.createdAt]);
      }
      
      // Apply limit
      query = query.limit(limit);
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
        .map((doc) => CustomQuoteModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        ))
        .toList();
    } catch (e) {
      debugPrint('Error fetching user custom quotes: $e');
      return [];
    }
  }
  
  // Get public quotes from all users with pagination
  Future<List<CustomQuoteModel>> getPublicCustomQuotes({
    int limit = 10,
    CustomQuoteModel? lastDoc,
  }) async {
    try {
      Query query = _customQuotesCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true);
        
      // Apply pagination if lastDoc is provided
      if (lastDoc != null) {
        query = query.startAfter([lastDoc.createdAt]);
      }
      
      // Apply limit
      query = query.limit(limit);
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
        .map((doc) => CustomQuoteModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        ))
        .toList();
    } catch (e) {
      debugPrint('Error fetching public custom quotes: $e');
      return [];
    }
  }
  
  // Get a specific custom quote by ID
  Future<CustomQuoteModel?> getCustomQuoteById(String quoteId) async {
    try {
      final docSnapshot = await _customQuotesCollection.doc(quoteId).get();
      
      if (docSnapshot.exists) {
        return CustomQuoteModel.fromMap(
          docSnapshot.data() as Map<String, dynamic>,
          docSnapshot.id
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching custom quote by ID: $e');
      return null;
    }
  }
  
  // Update an existing custom quote
  Future<void> updateCustomQuote(CustomQuoteModel quote) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User must be logged in to update a custom quote');
      }
      
      // Verify the user owns this quote
      if (quote.userId != _currentUserId) {
        throw Exception('You can only update your own quotes');
      }
      
      await _customQuotesCollection.doc(quote.id).update(quote.toMap());
    } catch (e) {
      debugPrint('Error updating custom quote: $e');
      throw Exception('Failed to update custom quote: $e');
    }
  }
  
  // Delete a custom quote
  Future<void> deleteCustomQuote(String quoteId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User must be logged in to delete a custom quote');
      }
      
      // Get the quote to verify ownership
      final quoteSnapshot = await _customQuotesCollection.doc(quoteId).get();
      
      if (!quoteSnapshot.exists) {
        throw Exception('Quote not found');
      }
      
      final quoteData = quoteSnapshot.data() as Map<String, dynamic>;
      
      // Verify the user owns this quote
      if (quoteData['userId'] != _currentUserId) {
        throw Exception('You can only delete your own quotes');
      }
      
      await _customQuotesCollection.doc(quoteId).delete();
    } catch (e) {
      debugPrint('Error deleting custom quote: $e');
      throw Exception('Failed to delete custom quote: $e');
    }
  }
  
  // Toggle the public/private status of a quote
  Future<CustomQuoteModel> toggleQuotePublicStatus(String quoteId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User must be logged in to update a quote');
      }
      
      // Get the quote
      final docSnapshot = await _customQuotesCollection.doc(quoteId).get();
      
      if (!docSnapshot.exists) {
        throw Exception('Quote not found');
      }
      
      final quoteData = docSnapshot.data() as Map<String, dynamic>;
      
      // Verify the user owns this quote
      if (quoteData['userId'] != _currentUserId) {
        throw Exception('You can only update your own quotes');
      }
      
      // Toggle the isPublic status
      final bool currentStatus = quoteData['isPublic'] ?? false;
      await _customQuotesCollection.doc(quoteId).update({
        'isPublic': !currentStatus
      });
      
      // Return the updated quote
      final updatedSnapshot = await _customQuotesCollection.doc(quoteId).get();
      return CustomQuoteModel.fromMap(
        updatedSnapshot.data() as Map<String, dynamic>,
        updatedSnapshot.id
      );
    } catch (e) {
      debugPrint('Error toggling quote public status: $e');
      throw Exception('Failed to update quote visibility: $e');
    }
  }
}