import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import 'doctor_home_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_notifications_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorMainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const DoctorMainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<DoctorMainNavigationScreen> createState() => _DoctorMainNavigationScreenState();
}

class _DoctorMainNavigationScreenState extends State<DoctorMainNavigationScreen>
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
      4,
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

  final List<Widget> _screens = [
    const DoctorHomeScreen(),
    const DoctorAppointmentsScreen(),
    const DoctorNotificationsScreen(),
    const DoctorProfileScreen(),
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
                      width: 60,
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
                    _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
                    _buildNavItem(1, Icons.calendar_month_rounded, 'Appointments'),
                    _buildNavItem(2, Icons.notifications_rounded, 'Alerts'),
                    _buildNavItem(3, Icons.person_rounded, 'Profile'),
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
    final itemWidth = (screenWidth - (AppSpacing.lg * 2)) / 4;
    return (_currentIndex * itemWidth) + (itemWidth / 2) - 30;
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
                            // Glow effect
                            if (isSelected || isHovered)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.tealAccent.withValues(
                                        alpha: isSelected ? 0.6 : 0.3,
                                      ),
                                      blurRadius: isSelected ? 10 : 6,
                                      spreadRadius: isSelected ? 2 : 1,
                                    ),
                                  ],
                                ),
                              ),
                            // Icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                icon,
                                size: 24,
                                color: isSelected
                                    ? AppColors.tealAccent
                                    : isHovered
                                        ? AppColors.tealAccent.withValues(alpha: 0.7)
                                        : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.tealAccent
                              : isHovered
                                  ? AppColors.tealAccent.withValues(alpha: 0.7)
                                  : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: isSelected ? 9 : 8,
                          height: 1.2,
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

