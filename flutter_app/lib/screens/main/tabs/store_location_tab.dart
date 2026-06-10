import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class _StoreLocationScreenState extends State<StoreLocationScreen> {
  bool isMutedMap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCeX0Ie7HHcWaSYC5_A8VtMYXIndKwbivdqY3Rji7URMItPKu9RyMz8rD2XJ7RPSx-BxSpp4zFJVp7JidRdjdi7DDo8HDdRbJK4V-ytryGBrQf40ScQdhtYQzZxmgASggswYiePuljqJGclkOsX7zFSCNiE7pkzF96zs6IF51wpRF4VG6_FVM84E7nU3cwoXuRRgtEVjnDXFS5Bfoor6PHXziVKu-Idi8qL1YsP7d7aU8b5LrNDJ0r9drdplCn014oM1yJUzYqagXI',
              fit: BoxFit.cover,
              colorBlendMode: isMutedMap ? BlendMode.saturation : BlendMode.dst,
              color: isMutedMap ? Colors.grey : null,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: SportZoneTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: SportZoneTheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SportZoneTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 96,
            right: 16,
            child: Column(
              children: [
                _mapAction(icon: Icons.add, onTap: () {}),
                const SizedBox(height: 8),
                _mapAction(icon: Icons.remove, onTap: () {}),
                const SizedBox(height: 8),
                _mapAction(
                  icon: Icons.my_location,
                  onTap: () => setState(() => isMutedMap = !isMutedMap),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 96,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SportZoneTheme.primary, width: 4),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BadgeTag(text: 'FLAGSHIP', isAccent: true),
                            const SizedBox(height: 6),
                            Text(
                              'SportZone Flagship Store',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '123 Lê Lợi, Quận 1, TP.HCM',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: SportZoneTheme.secondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: SportZoneTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: SportZoneTheme.borderSubtle),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.call,
                                color: SportZoneTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PHONE',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                        ),
                                  ),
                                  Text(
                                    '+84 28 3456 7890',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: SportZoneTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OPEN UNTIL',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                        ),
                                  ),
                                  Text(
                                    '22:00 PM',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SportZoneTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CHỈ ĐƯỜNG',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: SportZoneTheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.directions_run,
                            size: 18,
                            color: SportZoneTheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SportZoneTheme.primary),
        ),
        child: Icon(icon, color: SportZoneTheme.primary),
      ),
    );
  }
}

class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

