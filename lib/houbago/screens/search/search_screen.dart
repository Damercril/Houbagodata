import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/models/driver_detail.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:houbago/houbago/utils/currency_formatter.dart';
import 'package:fl_chart/fl_chart.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedVehicleType = 'all';
  String _selectedStatus = 'all';
  List<DriverDetail> _allDrivers = [];
  List<DriverDetail> _filteredDrivers = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    final driversData = await DatabaseService.getDrivers();
    if (mounted) {
      setState(() {
        _allDrivers = driversData.map((json) => DriverDetail(
          id: json['id'].toString(),
          firstName: json['first_name'].toString(),
          lastName: json['last_name'].toString(),
          phoneNumber: json['phone'].toString(),
          registrationDate: DateTime.parse(json['created_at']),
          lastRideDate: DateTime.parse(json['last_ride_date'] ?? json['created_at']),
          photoUrl: json['photo_url']?.toString() ?? '',
          vehicleType: json['vehicle_type']?.toString() ?? 'moto',
          totalRides: (json['total_rides'] as num?)?.toInt() ?? 0,
          rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
          totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
          referredDrivers: (json['referred_drivers'] as num?)?.toInt() ?? 0,
          status: json['status']?.toString() ?? 'inactive',
        )).toList();
      });
    }
  }

  void _filterDrivers() {
    setState(() {
      _filteredDrivers = _allDrivers.where((driver) {
        final matchesSearch = driver.fullName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            driver.phoneNumber.contains(_searchController.text);

        final matchesVehicleType = _selectedVehicleType == 'all' ||
            driver.vehicleType == _selectedVehicleType;

        final matchesStatus =
            _selectedStatus == 'all' || driver.status == _selectedStatus;

        return matchesSearch && matchesVehicleType && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoubagoTheme.background,
      appBar: AppBar(
        backgroundColor: HoubagoTheme.background,
        title: const Text('Recherche'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un conducteur...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterDrivers();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => _filterDrivers(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown(
                        value: _selectedVehicleType,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Tous les véhicules'),
                          ),
                          DropdownMenuItem(
                            value: 'moto',
                            child: Text('Moto'),
                          ),
                          DropdownMenuItem(
                            value: 'car',
                            child: Text('Voiture'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value ?? 'all';
                            _filterDrivers();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _FilterDropdown(
                        value: _selectedStatus,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Tous les statuts'),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Actif'),
                          ),
                          DropdownMenuItem(
                            value: 'inactive',
                            child: Text('Inactif'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('En attente'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value ?? 'all';
                            _filterDrivers();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDrivers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun conducteur trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadDrivers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredDrivers.length,
                          itemBuilder: (context, index) {
                            return _DriverCard(
                              driver: _filteredDrivers[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.driver,
  });

  final DriverDetail driver;

  Color _getStatusColor() {
    switch (driver.status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (driver.status) {
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      case 'pending':
        return 'En attente';
      default:
        return 'Inconnu';
    }
  }

  String _formatLastRideDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui à ${DateFormat.Hm().format(date)}";
    } else if (difference.inDays == 1) {
      return "Hier à ${DateFormat.Hm().format(date)}";
    } else {
      return DateFormat.yMMMd('fr_FR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(driver.photoUrl),
          radius: 25,
        ),
        title: Text(
          driver.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(driver.phoneNumber),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dernière course: ${_formatLastRideDate(driver.lastRideDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.star,
                      value: driver.rating.toString(),
                      label: 'Note',
                    ),
                    _StatItem(
                      icon: Icons.directions_car,
                      value: driver.totalRides.toString(),
                      label: 'Courses',
                    ),
                    _StatItem(
                      icon: Icons.people,
                      value: driver.referredDrivers.toString(),
                      label: 'Parrainages',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StatItem(
                  icon: Icons.attach_money,
                  value: CurrencyFormatter.format(driver.totalEarnings),
                  label: 'Gains totaux',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: HoubagoTheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.date,
    required this.onPressed,
  });

  final DateTime date;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        DateFormat.yMMMd('fr_FR').format(date),
        style: TextStyle(
          color: HoubagoTheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
