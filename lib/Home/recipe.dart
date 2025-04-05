// import 'package:flutter/material.dart';


// // In RecipeDetailView file
// class Recipe {
//   final String title;
//   final String url;
//   final List<Ingredient> ingredients;
//   final List<String> instructions;

//   Recipe({
//     required this.title,
//     required this.url,
//     required this.ingredients,
//     required this.instructions,
//   });
// }

// class Ingredient {
//   final double quantity;
//   final String unit;
//   final String name;
//   final double? grams;
//   final String text;

//   const Ingredient({
//     required this.quantity,
//     required this.unit,
//     required this.name,
//     this.grams,
//     required this.text,
//   });
// }

// class RecipeDetailView extends StatefulWidget {
//   final Recipe recipe;
//   const RecipeDetailView({super.key, required this.recipe});


//   @override
//   State<RecipeDetailView> createState() => _RecipeDetailViewState();
// }

// class _RecipeDetailViewState extends State<RecipeDetailView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late Recipe _recipe;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize tab controller for switching between Details and Reviews tabs
//     _tabController = TabController(length: 2, vsync: this);

//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top navigation and image area
//             _buildRecipeHeader(),

//             // Recipe details content
//             Expanded(
//               child: _buildRecipeDetails(),
//             ),

//             // Bottom navigation
//             _buildBottomNavigation(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecipeHeader() {
//     return Stack(
//       children: [
//         // Recipe image (simplified for FlutLab)
//         Container(
//           height: 250,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF5F5F5),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.cake,
//                   size: 80,
//                   color: Colors.amber[300],
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Macarons Image',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Back button and bookmark
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildIconButton(Icons.arrow_back, () {
//                 // Back functionality would go here
//               }),
//               // _buildIconButton(
//               //   _recipe.isFavorite ? Icons.bookmark : Icons.bookmark_outline,
//               //   () {
//               //     setState(() {
//               //       _recipe.isFavorite = !_recipe.isFavorite;
//               //     });
//               //   },
//               // ),
//             ],
//           ),
//         ),

//         // Pagination dots
//         Positioned(
//           bottom: 16,
//           left: 0,
//           right: 0,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               for (int i = 0; i < 3; i++)
//                 Container(
//                   width: 8,
//                   height: 8,
//                   margin: const EdgeInsets.symmetric(horizontal: 2),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: i == 1 ? Colors.grey[700] : Colors.grey[400],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       // child: IconButton(
//       //   icon: Icon(icon,
//       //       color: _recipe.isFavorite && icon == Icons.bookmark
//       //           ? Colors.green
//       //           : Colors.black),
//       //   onPressed: onPressed,
//       // ),
//     );
//   }

//   Widget _buildRecipeDetails() {
//     return Column(
//       children: [
//         // Tab bar for switching between Details and Reviews
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: TabBar(
//             controller: _tabController,
//             labelColor: Colors.green,
//             unselectedLabelColor: Colors.grey,
//             indicatorColor: Colors.green,
//             tabs: const [
//               Tab(text: 'Details'),
//               Tab(text: 'Reviews'),
//             ],
//           ),
//         ),

//         // Tab content
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               _buildDetailsTab(),
//               _buildReviewsTab(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailsTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title and rating
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   _recipe.title,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     const Icon(Icons.star, color: Colors.amber, size: 20),
//                     const SizedBox(width: 4),
//                     Text(
//                       //_recipe.rating.toString(),
//                       "4.5",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//              // Author
//             // Text(
//             //   'By ${_recipe.author}',
//             //   style: const TextStyle(
//             //     fontSize: 14,
//             //     color: Colors.grey,
//             //   ),
//             // ),

//             const SizedBox(height: 16),

//             // Cooking info
//             // SingleChildScrollView(
//             //   scrollDirection: Axis.horizontal,
//             //   child: Row(
//             //     children: [
//             //       RecipeInfoChip(
//             //         icon: Icons.access_time,
//             //         label: _recipe.prepTime,
//             //       ),
//             //       RecipeInfoChip(
//             //         icon: Icons.restaurant,
//             //         label: _recipe.difficulty,
//             //       ),
//             //       RecipeInfoChip(
//             //         icon: Icons.local_fire_department,
//             //         label: _recipe.calories,
//             //       ),
//             //       RecipeInfoChip(
//             //         icon: Icons.people,
//             //         label: '4 servings',
//             //       ),
//             //     ],
//             //   ),
//             // ),

//             const SizedBox(height: 24),

//             // Description
//             const Text(
//               'Description',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Text(
//             //   _recipe.description,
//             //   style: const TextStyle(
//             //     fontSize: 14,
//             //     color: Colors.grey,
//             //     height: 1.5,
//             //   ),
//             // ),

//             const SizedBox(height: 24),

//             // Ingredients with "Add to cart" feature
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Ingredients',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 // "Add to cart" button for adding all ingredients to shopping list
//                 // This feature would allow users to quickly add all recipe ingredients to their shopping list
//                 OutlinedButton.icon(
//                   onPressed: () {
//                     // When pressed, this would:
//                     // 1. Collect all ingredients from the recipe
//                     // 2. Add them to the user's shopping list in a database/storage
//                     // 3. Potentially show a confirmation message or navigate to shopping list

//                     // Example implementation (commented out as it requires additional setup):
//                     // final ingredients = _recipe.ingredients;
//                     // ShoppingListService.addIngredientsToCart(ingredients);
//                     // ScaffoldMessenger.of(context).showSnackBar(
//                     //   SnackBar(content: Text('${ingredients.length} ingredients added to shopping list')),
//                     // );
//                   },
//                   icon: const Icon(Icons.shopping_cart, size: 16),
//                   label: const Text('Add to cart'),
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.green),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Ingredients list
//             ...List.generate(_recipe.ingredients.length, (index) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12.0),
//                 child: IngredientItem(
//                   name: _recipe.ingredients[index].name,
//                   amount: _recipe.ingredients[index].amount,
//                   iconColor: _recipe.ingredients[index].iconColor,
//                 ),
//               );
//             }),

//             const SizedBox(height: 24),

//             // Instructions title
//             const Text(
//               'Instructions',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Steps
//             ...List.generate(4, (index) {
//               return StepItem(
//                 stepNumber: index + 1,
//                 description:
//                     'This is step ${index + 1} of the recipe. ${index == 0 ? 'Preheat oven to 320°F (160°C) and line baking sheets with parchment paper.' : index == 1 ? 'In a large bowl, sift together ground almonds, powdered sugar, and cocoa powder.' : index == 2 ? 'Beat egg whites until foamy, then gradually add granulated sugar until stiff peaks form.' : 'Pipe small circles onto the baking sheets and let rest for 30 minutes before baking.'}',
//               );
//             }),

//             const SizedBox(height: 24),

//             // Watch videos button
//             Center(
//               child: ElevatedButton.icon(
//                 onPressed: () {},
//                 icon:
//                     const Icon(Icons.play_circle_outline, color: Colors.white),
//                 label: const Text(
//                   'Watch Video Tutorial',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   // Reviews tab that displays user feedback and ratings for the recipe
//   // This tab provides social proof and helps users decide if the recipe is worth trying
//   Widget _buildReviewsTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Overall rating summary section
//             // This gives users a quick overview of how the recipe has been rated
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   // Left side: Average rating display
//                   // Column(
//                   //   children: [
//                   //     // Large rating number
//                   //     Text(
//                   //       _recipe.rating.toString(),
//                   //       style: const TextStyle(
//                   //         fontSize: 48,
//                   //         fontWeight: FontWeight.bold,
//                   //       ),
//                   //     ),
//                   //     // Star display of rating (including half stars)
//                   //     Row(
//                   //       children: List.generate(5, (index) {
//                   //         return Icon(
//                   //           // Show filled, half-filled, or empty stars based on rating value
//                   //           index < _recipe.rating.floor()
//                   //               ? Icons.star
//                   //               : index == _recipe.rating.floor() &&
//                   //                       _recipe.rating % 1 > 0
//                   //                   ? Icons.star_half
//                   //                   : Icons.star_border,
//                   //           color: Colors.amber,
//                   //           size: 16,
//                   //         );
//                   //       }),
//                   //     ),
//                   //     const SizedBox(height: 4),
//                   //     // Total review count
//                   //     const Text('126 reviews',
//                   //         style: TextStyle(color: Colors.grey)),
//                   //   ],
//                   // ),
//                   const SizedBox(width: 24),
//                   // Right side: Rating breakdown by stars (5★ to 1★)
//                   // This shows the distribution of ratings across all reviewers
//                   Expanded(
//                     child: Column(
//                       children: List.generate(5, (index) {
//                         final starCount = 5 - index;
//                         // Example percentages for each star rating
//                         final percentage = [60, 25, 10, 3, 2][index];
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 2.0),
//                           child: Row(
//                             children: [
//                               // Star count (5, 4, 3, etc.)
//                               Text('$starCount',
//                                   style: const TextStyle(color: Colors.grey)),
//                               const SizedBox(width: 4),
//                               const Icon(Icons.star,
//                                   color: Colors.amber, size: 12),
//                               const SizedBox(width: 8),
//                               // Progress bar showing percentage of reviews with this rating
//                               Expanded(
//                                 child: LinearProgressIndicator(
//                                   value: percentage / 100,
//                                   backgroundColor: Colors.grey[300],
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.green),
//                                   minHeight: 8,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Percentage display
//                               Text('$percentage%',
//                                   style: const TextStyle(color: Colors.grey)),
//                             ],
//                           ),
//                         );
//                       }),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Individual user reviews
//             // These provide detailed feedback from users who have tried the recipe
//             ...List.generate(3, (index) {
//               // Sample review data - in a real app, this would come from a database
//               return ReviewItem(
//                 username: ['Laura K.', 'David M.', 'Sophie T.'][index],
//                 date: ['Feb 25, 2025', 'Mar 12, 2025', 'Feb 19, 2025'][index],
//                 rating: [5.0, 4.0, 4.5][index],
//                 comment: [
//                   'These macarons are absolutely delicious! The recipe is easy to follow and the results were better than the ones from my local bakery!',
//                   'Good recipe overall, but I had to adjust the baking time for my oven. I would suggest checking them earlier.',
//                   'Loved these macarons! The chocolate ganache filling was divine. Will definitely make these again for special occasions.'
//                 ][index],
//               );
//             }),

//             const SizedBox(height: 16),

//             // Write review button
//             // Allows users to add their own reviews to contribute to the community
//             OutlinedButton.icon(
//               onPressed: () {
//                 // When pressed, this would:
//                 // 1. Open a review form dialog or navigate to a review screen
//                 // 2. Allow user to enter a rating, comment, and possibly add photos
//                 // 3. Submit the review to be stored and displayed

//                 // Example implementation (commented out as it requires additional setup):
//                 // showDialog(
//                 //   context: context,
//                 //   builder: (context) => ReviewFormDialog(
//                 //     onSubmit: (rating, comment) {
//                 //       // Save review to database
//                 //       // Refresh reviews list
//                 //     },
//                 //   ),
//                 // );
//               },
//               icon: const Icon(Icons.rate_review),
//               label: const Text('Write a Review'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.green,
//                 side: const BorderSide(color: Colors.green),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.home_outlined, 'Home', false),
//           _buildNavItem(Icons.search, 'Search', false),
//           _buildNavItem(Icons.restaurant_menu, 'Recipes', true),
//           _buildNavItem(Icons.favorite_outline, 'Favorites', false),
//           _buildNavItem(Icons.person_outline, 'Profile', false),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, String label, bool isActive) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           color: isActive ? Colors.green : Colors.grey,
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: isActive ? Colors.green : Colors.grey,
//             fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class RecipeInfoChip extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const RecipeInfoChip({
//     Key? key,
//     required this.icon,
//     required this.label,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       margin: const EdgeInsets.only(right: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 2,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.green),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: const TextStyle(fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class IngredientItem extends StatelessWidget {
//   final String name;
//   final String amount;
//   final Color iconColor;

//   const IngredientItem({
//     Key? key,
//     required this.name,
//     required this.amount,
//     required this.iconColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200] ?? Colors.grey),
//       ),
//       child: Row(
//         children: [
//           // Ingredient icon
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: iconColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.food_bank,
//               color: iconColor,
//             ),
//           ),

//           const SizedBox(width: 12),

//           // Ingredient name
//           Expanded(
//             child: Text(
//               name,
//               style: const TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//           ),

//           // Amount
//           Text(
//             amount,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class StepItem extends StatelessWidget {
//   final int stepNumber;
//   final String description;

//   const StepItem({
//     Key? key,
//     required this.stepNumber,
//     required this.description,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Step number
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Center(
//               child: Text(
//                 stepNumber.toString(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(width: 12),

//           // Step description
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Step $stepNumber',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     height: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Review item widget that displays a single user review
// // This is used in the Reviews tab to show individual feedback
// class ReviewItem extends StatelessWidget {
//   final String username; // Name of the reviewer
//   final String date; // Date when review was posted
//   final double rating; // Star rating (1-5, supports half stars)
//   final String comment; // Text review content

//   const ReviewItem({
//     Key? key,
//     required this.username,
//     required this.date,
//     required this.rating,
//     required this.comment,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200] ?? Colors.grey),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Review header with user info and rating
//           Row(
//             children: [
//               // User avatar (in a real app, would show profile picture)
//               CircleAvatar(
//                 backgroundColor: Colors.green[100],
//                 child: Text(
//                   username[0], // First letter of username as avatar placeholder
//                   style: TextStyle(
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // User name and review date
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       username,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       date,
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Star rating display
//               Row(
//                 children: List.generate(5, (index) {
//                   return Icon(
//                     // Logic to show full, half, or empty stars
//                     index < rating.floor()
//                         ? Icons.star
//                         : index == rating.floor() && rating % 1 > 0
//                             ? Icons.star_half
//                             : Icons.star_border,
//                     color: Colors.amber,
//                     size: 16,
//                   );
//                 }),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           // Review content/comment
//           Text(
//             comment,
//             style: const TextStyle(
//               height: 1.5,
//             ),
//           ),
//           // In a full implementation, could include:
//           // - Helpful/Not helpful buttons
//           // - Photos from the reviewer
//           // - Reply from recipe author
//         ],
//       ),
//     );
//   }
// }