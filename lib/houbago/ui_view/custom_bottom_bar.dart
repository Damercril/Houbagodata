import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/ui_view/bottom_bar_painter.dart';
import 'package:houbago/houbago/screens/add/add_driver_modal.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final int selectedIndex;
  final Function(int) onItemTapped;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animationController?.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController!,
          builder: (BuildContext context, Widget? child) {
            return Transform(
              transform: Matrix4.translationValues(0.0, 0.0, 0.0),
              child: PhysicalShape(
                color: HoubagoTheme.backgroundLight,
                elevation: 16.0,
                clipper: BottomBarPainter(
                  radius: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: animationController!,
                              curve: Curves.fastOutSlowIn))
                          .value *
                      38.0,
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 62,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: _TabIcon(
                                icon: Icons.home_outlined,
                                activeIcon: Icons.home_rounded,
                                label: 'Accueil',
                                isSelected: widget.selectedIndex == 0,
                                onTap: () => widget.onItemTapped(0),
                              ),
                            ),
                            Expanded(
                              child: _TabIcon(
                                icon: Icons.people_outline,
                                activeIcon: Icons.people_rounded,
                                label: 'Mon équipe',
                                isSelected: widget.selectedIndex == 1,
                                onTap: () => widget.onItemTapped(1),
                              ),
                            ),
                            SizedBox(
                              width: Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(CurvedAnimation(
                                          parent: animationController!,
                                          curve: Curves.fastOutSlowIn))
                                      .value *
                                  64.0,
                            ),
                            Expanded(
                              child: _TabIcon(
                                icon: Icons.flag_outlined,
                                activeIcon: Icons.flag_rounded,
                                label: 'Objectifs',
                                isSelected: widget.selectedIndex == 3,
                                onTap: () => widget.onItemTapped(3),
                              ),
                            ),
                            Expanded(
                              child: _TabIcon(
                                icon: Icons.account_circle_outlined,
                                activeIcon: Icons.account_circle_rounded,
                                label: 'Mon compte',
                                isSelected: widget.selectedIndex == 4,
                                onTap: () => widget.onItemTapped(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    )
                  ],
                ),
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: SizedBox(
            width: 38 * 2.0,
            height: 38 + 62.0,
            child: Container(
              alignment: Alignment.topCenter,
              color: Colors.transparent,
              child: SizedBox(
                width: 38 * 2.0,
                height: 38 * 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScaleTransition(
                    alignment: Alignment.center,
                    scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animationController!,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: HoubagoTheme.primary,
                        gradient: LinearGradient(
                          colors: [
                            HoubagoTheme.primary,
                            HoubagoTheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            offset: const Offset(0, 0),
                            blurRadius: 15.0,
                            spreadRadius: 2.0,
                          ),
                          BoxShadow(
                            color: HoubagoTheme.primary.withOpacity(0.6),
                            offset: const Offset(4.0, 8.0),
                            blurRadius: 16.0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: Colors.white.withOpacity(0.1),
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const AddDriverModal(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.add,
                              color: HoubagoTheme.textLight,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? HoubagoTheme.primary : HoubagoTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: HoubagoTheme.textTheme.labelSmall?.copyWith(
                color: isSelected ? HoubagoTheme.primary : HoubagoTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
