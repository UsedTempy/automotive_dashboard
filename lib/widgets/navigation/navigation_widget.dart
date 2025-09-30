import 'package:car_dashboard/templates/searchResults.dart';
import 'package:car_dashboard/widgets/navigation/search_item_widget.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _showResults = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 280, // stays fixed width
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.search,
                    color: Color(0xFF9E9E9E),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5, // slightly smaller
                        fontWeight: FontWeight.w500, // less bold while typing
                        height: 1.2, // tighter line height
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Navigate',
                        hintStyle: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400, // lighter hint
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _showResults = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 28, // bigger circle for tap
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.clear,
                            color: Color(0xFF9E9E9E),
                            size: 16, // keep icon size, just bigger circle
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Search results dropdown
            if (_showResults)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: searchResults.map((result) {
                      return SearchItemWidget(
                        result: result,
                        onTap: () {
                          // Handle location selection
                          print('Selected: ${result.name}');
                          _searchController.clear();
                          _focusNode.unfocus();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
