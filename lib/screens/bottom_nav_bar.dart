import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    // Adjust sizes based on screen width
    final double navBarHeight = isSmallScreen ? 70 : 80;
    final double horizontalMargin = screenSize.width * 0.05;
    final double verticalMargin = screenSize.height * 0.02;
    final double iconSize = isSmallScreen ? 24 : 28;
    final double centerButtonSize = isSmallScreen ? 54 : 65;

    return Container(
      height: navBarHeight,
      margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin, vertical: verticalMargin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background designs for added aesthetics
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: screenSize.width * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.blue.withOpacity(0.03)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // Main navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                  0, Icons.home_outlined, Icons.home_rounded, iconSize, "Home"),
              _buildNavItem(1, Icons.car_crash_sharp, Icons.car_crash_sharp,
                  iconSize, "SOS"),
              SizedBox(
                  width: centerButtonSize * 0.7), // Space for center button
              _buildNavItem(3, Icons.shopping_cart_outlined,
                  Icons.shopping_cart_outlined, iconSize, "Cart"),
              _buildNavItem(4, Icons.person_outline, Icons.person_rounded,
                  iconSize, "Profile"),
            ],
          ),

          // Center floating button
          _buildCenterButton(centerButtonSize),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutlined, IconData iconFilled,
      double iconSize, String label) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemTapped(index),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCirc,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.blue.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutlined,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
              size: iconSize,
            ),
            if (isSelected) SizedBox(height: 4),
            if (isSelected)
              Text(
                label,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(double size) {
    final bool isActive = selectedIndex == 2;

    return GestureDetector(
      onTap: () => onItemTapped(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: size,
        width: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [Colors.blue.shade700, Colors.blue.shade500]
                : [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(isActive ? 0.5 : 0.3),
              blurRadius: isActive ? 15 : 10,
              spreadRadius: isActive ? 2 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: isActive ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.settings_suggest_sharp,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
