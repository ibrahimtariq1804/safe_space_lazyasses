import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'pet_home_screen.dart';
import 'search_doctors_screen.dart';
import 'pet_appointments_list_screen.dart';
import 'notifications_screen.dart';
import 'user_type_selection_screen.dart';

class PetMainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const PetMainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<PetMainNavigationScreen> createState() => _PetMainNavigationScreenState();
}

class _PetMainNavigationScreenState extends State<PetMainNavigationScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Create animation controllers for each nav item
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    // Create scale animations
    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate the initial selected item
    _animationControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  late final List<Widget> _screens = [
    const PetHomeScreen(),
    const SearchDoctorsScreen(isHumanMode: false), // Pet doctors only
    const PetAppointmentsListScreen(),
    const NotificationsScreen(),
    const UserTypeSelectionScreen(),
  ];

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // Animate out the old selection
      _animationControllers[_currentIndex].reverse();

      // Animate in the new selection
      _animationControllers[index].forward();

      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.tealAccent.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withValues(alpha: 0.95),
              border: Border.all(
                color: AppColors.tealAccent.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Animated background indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _getIndicatorPosition(),
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 55,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.tealAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.tealAccent.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                // Nav items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_rounded, 'Home'),
                    _buildNavItem(1, Icons.pets_rounded, 'Vets'),
                    _buildNavItem(2, Icons.calendar_month_rounded, 'Visits'),
                    _buildNavItem(3, Icons.notifications_rounded, 'Alerts'),
                    _buildNavItem(4, Icons.pets_rounded, 'Pet'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getIndicatorPosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (AppSpacing.lg * 2)) / 5;
    return (_currentIndex * itemWidth) + (itemWidth / 2) - 27.5;
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final isHovered = _hoveredIndex == index;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: GestureDetector(
          onTap: () => _onItemTapped(index),
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
            animation: _animationControllers[index],
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with glow effect
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.translationValues(
                          0,
                          isHovered && !isSelected ? -2 : 0,
                          0,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isSelected)
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.tealAccent.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            Icon(
                              icon,
                              color: isSelected
                                  ? AppColors.tealAccent
                                  : (isHovered
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.tealAccent
                              : (isHovered
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 10,
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
