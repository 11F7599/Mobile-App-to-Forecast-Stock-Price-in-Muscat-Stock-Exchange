import 'package:flutter/material.dart';

Future<String?> showBottomSheetFilter(BuildContext context, String sCategory) async {
  double screenHeight = MediaQuery.of(context).size.height;
  double statusBarHeight = MediaQuery.of(context).padding.top;
  double availableHeight = screenHeight - statusBarHeight - 67;

  const List<String> categories = ["All", "Industrial Sector", "Services Sector", "Financial Sector", "Bonds_Sukuk", "Mutual Funds"];

  String selectedCategory = sCategory; // Default value

  Future<void> onCategorySelected(String category, BuildContext context) async {
    Navigator.pop(context, category); // Pass the selected category to the Navigator.pop
  }

  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: availableHeight,
        ),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Column(
          children: [
            const SizedBox(height: 9),
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Filter by Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
                  ),
                  onTap: () {
                    Navigator.pop(context, null); // Pass null when closed without selecting a category
                  },
                ),
                const SizedBox(width: 10,)
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: categories[index] == selectedCategory ? Colors.pinkAccent : null,
                        border: const Border(
                          bottom: BorderSide(width: 0.5, color: Color.fromARGB(255, 189, 189, 189)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              categories[index], 
                              style: TextStyle(fontSize: 16, color: categories[index] == selectedCategory ? Colors.white : null)),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => onCategorySelected(categories[index], context),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
