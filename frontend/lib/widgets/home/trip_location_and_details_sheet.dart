import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_planner_controller.dart';
import '../../theme/navtrip_theme.dart';

class CuratedDestination {
  const CuratedDestination({
    required this.name,
    required this.region,
    required this.tagline,
    required this.category,
    required this.themeGroup,
    required this.image,
    required this.defaultDays,
    required this.bestSeason,
    required this.weatherSummary,
    required this.budgetPerDay,
    required this.highlights,
    required this.crowdTip,
  });

  final String name;
  final String region;
  final String tagline;
  final String category;
  final String themeGroup;
  final String image;
  final int defaultDays;
  final String bestSeason;
  final String weatherSummary;
  final String budgetPerDay;
  final List<String> highlights;
  final String crowdTip;
}

const List<CuratedDestination> curatedDestinationsList = [
  CuratedDestination(
    name: 'Jaipur',
    region: 'Rajasthan, India',
    tagline: 'Royal Forts, Amber Stone & Vibrant Bazaars',
    category: 'historical',
    themeGroup: 'Heritage & Royal',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBhweeDqK7cfx6FGBKWhcAYPW9AkaPzgKU0rQc_AcZS4rODLP2sB9WdkWkj1yH-Y9xAAV4EXiyUDR99MubUQuqcJDOzAkH1_HmTnWg8QPEvnvVgeLjJrspwddE39R8j0n-21X1CSGuX2FWmd-TIJonqH1JVLb8hJWIRZg3cXfTbVtmWkD4vWcJG8kwTssPhkq8GvR5pxDLU6Z56Ot0N0zeMzWSOVtqCw2S0B-Fb5Sj7Saqccj3gtLTsVWASDa7_LTSWXH7SI8eMHyW7',
    defaultDays: 3,
    bestSeason: 'Oct - Mar • 24°C Sunny & Mild',
    weatherSummary: 'Crisp mornings, golden afternoon light, cool evenings.',
    budgetPerDay: '₹3,200 / \$40 per day',
    highlights: ['Hawa Mahal', 'Amber Fort', 'City Palace', 'Jantar Mantar', 'Nahargarh Sunset'],
    crowdTip: 'Visit Amber Fort early at 08:30 AM before tourist buses arrive.',
  ),
  CuratedDestination(
    name: 'Kyoto',
    region: 'Kansai, Japan',
    tagline: 'Zen Temples, Moss Gardens & Cedar Shrines',
    category: 'historical',
    themeGroup: 'Food & Culture',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCjHVtVcf5pUDBcddizpfb9nfeINpnEgWtrq-HMvA2aD9ilQLk2IsmkcNVpoR08XvpsdVQ93Zl5SEY9fqqK8VToD0RZEBQu97rr12Efx8ZdeWll2Vq24cjhYhBJDSDi_9pZf-mpsPv22b-kppUQxidiU5nagOOC6v9lpSQMTa4qO0hjEKR929OAY4m4sn-IstAgDZsEZNlA8E2lE5w_5Ca53MUkcXnfWSnQG-P6s1C1B-LJkpGCp5W88q52MSVtroABrxBuVBSNr1Ie',
    defaultDays: 4,
    bestSeason: 'Mar - May / Oct - Nov • 18°C Pleasant',
    weatherSummary: 'Mild breezes with cherry blossoms or fiery maples.',
    budgetPerDay: '¥14,000 / \$95 per day',
    highlights: ['Fushimi Inari', 'Kinkaku-ji', 'Arashiyama Bamboo', 'Gion Quarter', 'Higashiyama Walk'],
    crowdTip: 'Higashiyama street walks are quietest and most atmospheric before 07:00 AM.',
  ),
  CuratedDestination(
    name: 'Isle of Skye',
    region: 'Highlands, Scotland',
    tagline: 'Volcanic Crags, Fairy Pools & Misty Lochs',
    category: 'nature',
    themeGroup: 'Hills & Mountains',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDcaoykP8GYJS_PcuSy8Z5MsdQsfRP5yoxYavgicUHxgiD9cY-kKxCGaeJ80z8PcKWBkPt6fK-g6LRz4Xd_j00E3JzmVbHqdrgAMch51pDNPPP2u3nv0YOJXPIiGGKQv46huMOLX4Pd9Bz7PUm4sm92jVpgxpOB8KK3yJKmzkvQsKChf-ZWkQtN7iW48uYkhqcQRFoMVrWTl2jq-c9vaPAep-tUYAGNmGeLHep1xowOWr92tBZMxvrRhUnOPsWTOkTzNsZwBU9TRK0i',
    defaultDays: 3,
    bestSeason: 'May - Sep • 15°C Dramatic Skies',
    weatherSummary: 'Ever-shifting highland weather with dramatic light bursts.',
    budgetPerDay: '£95 / \$120 per day',
    highlights: ['Old Man of Storr', 'Quiraing', 'Fairy Pools', 'Neist Point Lighthouse', 'Portree Harbor'],
    crowdTip: 'Pack windproof layers. Fairy Pools are best enjoyed in late afternoon light.',
  ),
  CuratedDestination(
    name: 'Rome',
    region: 'Lazio, Italy',
    tagline: 'Ancient Amphitheaters, Pasticcerias & Piazzas',
    category: 'historical',
    themeGroup: 'Food & Culture',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC9NmwaW7BBkFcjJs8MRalpoUSctS9aLxf9A3z0nKoReBW6owD2T57Cr4fukvl-Z90Rsm-ZMfmo46uAcPrscRM4-rPZKH0OSOC-sArA8lzEjrMl2-jh0o6EL9mRwDpPMiO6gQDNPSzQRfSAEmXc8KFOx6f5SJ62PPPgaBc3u4dxLVgMLFG6BGrN0d20ep7a_yOg95k3mWJ1ZWmWzDl5A-yBvoOK3JUXOy2DT4jEXQ4hZijrYtT55DvpdiQRyt39fUuW2UodoJOrc1-f',
    defaultDays: 5,
    bestSeason: 'Apr - Jun / Sep - Oct • 22°C Balmy',
    weatherSummary: 'Warm cobblestones, golden hour sun, outdoor dining weather.',
    budgetPerDay: '€110 / \$120 per day',
    highlights: ['Colosseum', 'Pantheon', 'Trevi Fountain', 'Trastevere', 'Vatican Museums'],
    crowdTip: 'Walk Trastevere in the late evening for authentic trattorias away from crowds.',
  ),
  CuratedDestination(
    name: 'Manali',
    region: 'Himachal Pradesh, India',
    tagline: 'Himalayan Pines, Glacial Rivers & Solang Valleys',
    category: 'adventure',
    themeGroup: 'Hills & Mountains',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDRpFXG1Fa46N8fnNfSf8ICeYzNmolpXUgu4jXbP8ztVfuOIQlYaWQ6iNV-lL-GvKCz-1VceN1uB2eh1ZNZxDVL8RaP-P4-DtGfljwxFr_52MfP2aQuvwH3GXVTXStYhFHl3cgAAofRo_Pw_t7a0st6zMyVmBdIAxKaj0rrmHQxTutpbbH4Lem9BsX5FQqtUYt-QpyFJz0KicXnnpVvuYKCUktSGxKH4v9vKa2fH8nGNGjRSxAyL8C2rEbDTZLYU9irDpSphbv0vLyX',
    defaultDays: 4,
    bestSeason: 'Mar - Jun / Oct - Feb • 12°C Alpine',
    weatherSummary: 'Crisp mountain air, snowy horizons, river breezes.',
    budgetPerDay: '₹3,500 / \$45 per day',
    highlights: ['Solang Valley', 'Hadimba Temple', 'Old Manali Cafes', 'Jogini Waterfall', 'Rohtang Pass'],
    crowdTip: 'Trek to Jogini Waterfall from Vashisht village in the morning for peaceful views.',
  ),
  CuratedDestination(
    name: 'Udaipur',
    region: 'Rajasthan, India',
    tagline: 'Lakeside Palaces, Ghats & Mewar Heritage',
    category: 'historical',
    themeGroup: 'Heritage & Royal',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBAEXGXMZdRt9Qlfp1YXjUFUchOD7q0aHNBBCnRvcAuYkdoUCzeWjgKfpUH7_WtpKIWq8dvG1VM5W_O52FR9Q0g_nolife3sRwuNnYoQRQiWYbk44GMKwEFh7U5ffGv5BnnFAYd231PWxXpGqFkFpGzNFjwMETzYQY6ShT1bWqgxy6scPIwpMCC4cFQO_jCS1pM9Dg-odeFFuyLcfPcgI6Gn_q6_Ba9kXVl6jYoM4tdLLLQRsQqRhfEPOZANbTG5QVgKI1R7IRuu8JI',
    defaultDays: 3,
    bestSeason: 'Oct - Mar • 23°C Sunny & Calm',
    weatherSummary: 'Gentle lake breezes and panoramic sunset vantage points.',
    budgetPerDay: '₹3,800 / \$48 per day',
    highlights: ['City Palace Udaipur', 'Lake Pichola Boat Ride', 'Jagmandir', 'Saheliyon-ki-Bari', 'Bagore Ki Haveli'],
    crowdTip: 'Sunset boat rides on Lake Pichola provide the most magical reflection of the palaces.',
  ),
  CuratedDestination(
    name: 'Goa',
    region: 'Goa, India',
    tagline: 'Palm Fringed Sands, Heritage Chapels & Seafood',
    category: 'nature',
    themeGroup: 'Coastal & Beaches',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB6X-nbkrD2RuSThyypMSJ4dPWmB8NvsIlabOYZCea3JqcRawYtxt6qReBvly4mX6dddRBWAxZBF7OdS0oQ2-AAwZb0PtjK0vrTw9omWqoKElBsoBmjqNiXBdDv1_nahfFPp-aydiYMQ62R5d1dapegzrtoVZwdAFYLkoI8Ve1t9_uQ0EcwO7g53WQArUSNWylmcvS34ZdISCzZydb2aFbk36j_2F0G9uLyFK_4jtDdUFMi4L6SvSTx_dNqCMErGsQRW8Tsq47iMQfA',
    defaultDays: 4,
    bestSeason: 'Nov - Feb • 28°C Tropical & Sunny',
    weatherSummary: 'Warm beach weather with coastal sea breezes.',
    budgetPerDay: '₹4,000 / \$50 per day',
    highlights: ['Fontainhas Latin Quarter', 'Aguada Fort', 'Palolem Beach', 'Chapora Fort', 'Dudhsagar Falls'],
    crowdTip: 'Explore Fontainhas heritage quarter on foot during early morning hours.',
  ),
  CuratedDestination(
    name: 'Munnar & Alleppey',
    region: 'Kerala, India',
    tagline: 'Emerald Tea Slopes & Serene Backwater Canals',
    category: 'nature',
    themeGroup: 'Coastal & Beaches',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBBj229moOMV-6SYMCNj19csS_yeumcFOAJ7PP6qcjtNgD4fc7EqpHKbCOoz193F2gnjrI5YOsbqsEXxjFpIrrXLpUt34vove7iJToc2pmbjquwKGGw_e1hSselOGnLJSefeWtEoc3TJjXoLajUtEcNgZMUl8Gyc8qSdpR_qGpboxE8g1fAHK-sH-GTroVJjE6GAxnZu_RdIqFih20EEFq3YLtlNtU4RZeZrzygD2wjLwB9Cl9eXSs6miSObNAnFuhjT6fs9tyiFVvh',
    defaultDays: 5,
    bestSeason: 'Sep - Mar • 20°C Refreshing',
    weatherSummary: 'Misty green valleys transitioning into calm coastal backwaters.',
    budgetPerDay: '₹3,600 / \$45 per day',
    highlights: ['Tea Estate Walks', 'Eravikulam National Park', 'Alleppey Houseboat', 'Mattupetty Dam', 'Marari Beach'],
    crowdTip: 'Book backwater canoe rides instead of large ferries for secluded canals.',
  ),
  CuratedDestination(
    name: 'Varanasi',
    region: 'Uttar Pradesh, India',
    tagline: 'Ancient River Ghats, Saffron Robes & Evening Aarti',
    category: 'religious',
    themeGroup: 'Spiritual & Serene',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDqSr-jDZ3s6sJ4MHVblLt9e-M5iEWpK60asKVE_30veuVDeQXEIT3nErCK9WawEgngsA5OrM20FTWtwaDk8xx4gVQb_XnB7HB05-_JRuPaNkZpO-t4WtFNdg5Z5_zmJe7B4A3ifbPN_yRgUEVOJdZtc_mDW1aJ-M5F5SgVuBrQ7n6NpdtnQnkuHEmZxBTmmNTlGwwA1hsMlh7c48gIJjKt1F6GUNqjKMhW6_SR3vr9-rzm1P0TqzG10OxZLr_g7-mVRSPtcy-ecQWH',
    defaultDays: 3,
    bestSeason: 'Oct - Mar • 21°C Pleasant',
    weatherSummary: 'Cool morning mist over the sacred Ganga river.',
    budgetPerDay: '₹2,600 / \$32 per day',
    highlights: ['Dashashwamedh Ghat Aarti', 'Sunrise Boat Ride', 'Kashi Vishwanath', 'Sarnath Stupa', 'Old City Galis'],
    crowdTip: 'Take a hand-rowed sunrise boat from Assi Ghat to Manikarnika Ghat at 05:45 AM.',
  ),
  CuratedDestination(
    name: 'Iceland Ring Road',
    region: 'Iceland',
    tagline: 'Lava Fields, Geothermal Springs & Waterfalls',
    category: 'adventure',
    themeGroup: 'Hills & Mountains',
    image:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAvM2OTp2gDpKOxH_Kl-WmlyBp8GHw7-mZjEbwr8_B6HUY4UvNNGqKC6-Z7rcU_c9ZsFgVi-9wYCMyUCr_xO26X_usQChYzFsmDyA_WEMQzi-eIH3BlUOLXRTB--i5oQgIEToK8PWa-Ywq3DDAXKgnRl6OztI_LdZXmf52qrCa7OM5FuA-tPOMLXege9SPYNoCRbZT-4d0d5zuRiloVcMhJyNO48vsaDOXSe4x-q-NoLFLgjYSi-t77-PPu1i9RB5ZtOJj_Kx82vjVL',
    defaultDays: 7,
    bestSeason: 'Jun - Aug / Sep - Oct • 10°C Rugged',
    weatherSummary: 'Crisp sub-arctic air, northern lights in autumn.',
    budgetPerDay: 'kr24,000 / \$180 per day',
    highlights: ['Blue Lagoon', 'Reynisfjara Beach', 'Skogafoss', 'Jokulsarlon Glacier Lagoon', 'Golden Circle'],
    crowdTip: 'Start coastal drives early to catch waterfalls in solitude.',
  ),
];

class TripLocationAndDetailsSheet extends StatefulWidget {
  const TripLocationAndDetailsSheet({
    this.initialDestination,
    super.key,
  });

  final String? initialDestination;

  static Future<void> show(
    BuildContext context, {
    String? initialDestination,
  }) async {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 840;

    if (isDesktop) {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
            child: TripLocationAndDetailsSheet(
              initialDestination: initialDestination,
            ),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.92,
          child: TripLocationAndDetailsSheet(
            initialDestination: initialDestination,
          ),
        ),
      );
    }
  }

  @override
  State<TripLocationAndDetailsSheet> createState() =>
      _TripLocationAndDetailsSheetState();
}

class _TripLocationAndDetailsSheetState
    extends State<TripLocationAndDetailsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _customDestinationController = TextEditingController();

  String _selectedDestination = 'Jaipur';
  String _selectedThemeGroup = 'All';
  int _selectedDays = 3;
  String _selectedCategory = 'historical';
  String _selectedBudgetTier = 'moderate';
  String _selectedTravelStyle = 'balanced';
  int _selectedGroupSize = 2;
  bool _includeHiddenGems = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final controller = context.read<TripPlannerController>();
    _selectedDestination = widget.initialDestination ?? controller.destination;
    _selectedDays = controller.days;
    _selectedCategory = controller.category;
    _selectedBudgetTier = controller.budgetTier;
    _selectedTravelStyle = controller.travelStyle;
    _selectedGroupSize = controller.groupSize;

    // Check if initial destination is in catalog
    final match = curatedDestinationsList.firstWhere(
      (d) => d.name.toLowerCase() == _selectedDestination.toLowerCase(),
      orElse: () => curatedDestinationsList.first,
    );
    if (_selectedDestination.isNotEmpty) {
      _selectedCategory = match.category;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _customDestinationController.dispose();
    super.dispose();
  }

  CuratedDestination get _activeDestinationMeta {
    return curatedDestinationsList.firstWhere(
      (d) => d.name.toLowerCase() == _selectedDestination.toLowerCase(),
      orElse: () => CuratedDestination(
        name: _selectedDestination,
        region: 'Custom Destination',
        tagline: 'Your custom planned exploration',
        category: _selectedCategory,
        themeGroup: 'Custom',
        image:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDRpFXG1Fa46N8fnNfSf8ICeYzNmolpXUgu4jXbP8ztVfuOIQlYaWQ6iNV-lL-GvKCz-1VceN1uB2eh1ZNZxDVL8RaP-P4-DtGfljwxFr_52MfP2aQuvwH3GXVTXStYhFHl3cgAAofRo_Pw_t7a0st6zMyVmBdIAxKaj0rrmHQxTutpbbH4Lem9BsX5FQqtUYt-QpyFJz0KicXnnpVvuYKCUktSGxKH4v9vKa2fH8nGNGjRSxAyL8C2rEbDTZLYU9irDpSphbv0vLyX',
        defaultDays: _selectedDays,
        bestSeason: 'Flexible Season',
        weatherSummary: 'Curated timing and routing for this journey.',
        budgetPerDay: _selectedBudgetTier == 'budget'
            ? '₹2,500 / \$30 per day'
            : _selectedBudgetTier == 'luxury'
                ? '₹9,500 / \$140 per day'
                : '₹4,500 / \$60 per day',
        highlights: ['City Center', 'Local Cultural Quarter', 'Scenic Viewpoint', 'Traditional Market'],
        crowdTip: 'Explore early mornings for peaceful sightseeing.',
      ),
    );
  }

  List<CuratedDestination> get _filteredDestinations {
    final query = _searchController.text.trim().toLowerCase();
    return curatedDestinationsList.where((destination) {
      final matchesSearch = query.isEmpty ||
          destination.name.toLowerCase().contains(query) ||
          destination.region.toLowerCase().contains(query) ||
          destination.tagline.toLowerCase().contains(query);

      final matchesTheme =
          _selectedThemeGroup == 'All' || destination.themeGroup == _selectedThemeGroup;

      return matchesSearch && matchesTheme;
    }).toList();
  }

  Future<void> _handleConfirmTrip() async {
    final controller = context.read<TripPlannerController>();
    final destinationToSet = _customDestinationController.text.trim().isNotEmpty
        ? _customDestinationController.text.trim()
        : _selectedDestination;

    Navigator.of(context).pop();

    await controller.setTripPlan(
      newDestination: destinationToSet,
      newDays: _selectedDays,
      newCategory: _selectedCategory,
      newBudgetTier: _selectedBudgetTier,
      newTravelStyle: _selectedTravelStyle,
      newGroupSize: _selectedGroupSize,
      newInterests: [
        _selectedCategory,
        if (_includeHiddenGems) 'hidden-gems',
        _selectedTravelStyle,
      ],
      autoGenerate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      decoration: BoxDecoration(
        color: NavTripPalette.surface,
        borderRadius: BorderRadius.circular(width < 600 ? 18 : 22),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.22),
            blurRadius: 36,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(color: NavTripPalette.outlineVariant, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width < 600 ? 18 : 22),
        child: Column(
          children: [
            // Top Header Banner
            _buildHeader(theme),
            // Navigation Tabs
            _buildTabBar(theme),
            // Tab Contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDestinationTab(theme),
                  _buildTripDetailsTab(theme),
                ],
              ),
            ),
            // Bottom Action Footer
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: NavTripPalette.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: NavTripPalette.terracotta,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Next Adventure',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: NavTripPalette.terracottaDeep,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose where to go, set the vibe, and tune every detail.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: NavTripPalette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NavTripPalette.sand,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: NavTripPalette.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place, size: 14, color: NavTripPalette.terracotta),
                const SizedBox(width: 6),
                Text(
                  _selectedDestination,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: NavTripPalette.terracottaDeep,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      color: NavTripPalette.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        labelColor: NavTripPalette.terracottaDeep,
        unselectedLabelColor: NavTripPalette.mutedInk,
        indicatorColor: NavTripPalette.terracotta,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.map_outlined, size: 20),
            text: '1. Select Location',
          ),
          Tab(
            icon: Icon(Icons.tune, size: 20),
            text: '2. More About Trip & Vibe',
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationTab(ThemeData theme) {
    final destinations = _filteredDestinations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Custom Location Entry Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: NavTripPalette.terracotta),
                    hintText: 'Search destinations (e.g. Kyoto, Rome, Manali, Goa)...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: NavTripPalette.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: NavTripPalette.outlineVariant),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _customDestinationController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.add_location_alt_outlined,
                        color: NavTripPalette.terracotta),
                    hintText: 'Or enter custom city...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: NavTripPalette.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: NavTripPalette.outlineVariant),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        _selectedDestination = value.trim();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Theme Group Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Heritage & Royal',
                'Hills & Mountains',
                'Coastal & Beaches',
                'Spiritual & Serene',
                'Food & Culture',
              ].map((group) {
                final selected = _selectedThemeGroup == group;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(group),
                    selected: selected,
                    selectedColor: NavTripPalette.terracotta,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : NavTripPalette.ink,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedThemeGroup = group);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),
          // Grid of Curated Destinations
          if (destinations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: NavTripStyles.paperCard(context: context, radius: 12),
              child: Column(
                children: [
                  const Icon(Icons.travel_explore, size: 44, color: NavTripPalette.terracotta),
                  const SizedBox(height: 12),
                  Text('No predefined destinations match "$_searchController.text"',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'You can still type "${_searchController.text.trim()}" into the custom box and plan your route anywhere!',
                    style: theme.textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedDestination = _searchController.text.trim();
                      });
                    },
                    child: Text('Use "${_searchController.text.trim()}"'),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width < 720 ? 1 : 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isSelected =
                    _selectedDestination.toLowerCase() == item.name.toLowerCase();

                return _DestinationPolaroidCard(
                  destination: item,
                  isSelected: isSelected,
                  onSelect: () {
                    setState(() {
                      _selectedDestination = item.name;
                      _selectedCategory = item.category;
                      _selectedDays = item.defaultDays;
                      _customDestinationController.clear();
                    });
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsTab(ThemeData theme) {
    final meta = _activeDestinationMeta;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Destination Banner with Vibe Overview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: NavTripStyles.paperCard(context: context, radius: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meta.image,
                    width: 100,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 90,
                      color: NavTripPalette.sand,
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            meta.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: NavTripPalette.terracottaDeep,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${meta.region})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: NavTripPalette.mutedInk,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.tagline,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _BadgePill(icon: Icons.wb_sunny_outlined, label: meta.bestSeason),
                          _BadgePill(icon: Icons.attach_money, label: meta.budgetPerDay),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Duration / Days Selector
          Text('Trip Duration', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: _selectedDays > 1 ? () => setState(() => _selectedDays--) : null,
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '$_selectedDays ${_selectedDays == 1 ? 'Day' : 'Days'}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: NavTripPalette.terracottaDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _selectedDays < 14 ? () => setState(() => _selectedDays++) : null,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 20),
              // Preset chips
              Wrap(
                spacing: 8,
                children: [
                  _PresetDayChip(
                    label: '2D Weekend',
                    days: 2,
                    selected: _selectedDays == 2,
                    onTap: () => setState(() => _selectedDays = 2),
                  ),
                  _PresetDayChip(
                    label: '3D Explorer',
                    days: 3,
                    selected: _selectedDays == 3,
                    onTap: () => setState(() => _selectedDays = 3),
                  ),
                  _PresetDayChip(
                    label: '5D In-Depth',
                    days: 5,
                    selected: _selectedDays == 5,
                    onTap: () => setState(() => _selectedDays = 5),
                  ),
                  _PresetDayChip(
                    label: '7D Odyssey',
                    days: 7,
                    selected: _selectedDays == 7,
                    onTap: () => setState(() => _selectedDays = 7),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 2. Travel Vibe / Category Selection
          Text('Travel Category / Vibe', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _VibeChoiceChip(
                label: 'Historical & Forts',
                icon: Icons.castle_outlined,
                value: 'historical',
                selected: _selectedCategory == 'historical',
                onSelect: () => setState(() => _selectedCategory = 'historical'),
              ),
              _VibeChoiceChip(
                label: 'Nature & Landscapes',
                icon: Icons.forest_outlined,
                value: 'nature',
                selected: _selectedCategory == 'nature',
                onSelect: () => setState(() => _selectedCategory = 'nature'),
              ),
              _VibeChoiceChip(
                label: 'Adventure & Treks',
                icon: Icons.hiking,
                value: 'adventure',
                selected: _selectedCategory == 'adventure',
                onSelect: () => setState(() => _selectedCategory = 'adventure'),
              ),
              _VibeChoiceChip(
                label: 'Spiritual & Sacred',
                icon: Icons.temple_hindu_outlined,
                value: 'religious',
                selected: _selectedCategory == 'religious',
                onSelect: () => setState(() => _selectedCategory = 'religious'),
              ),
              _VibeChoiceChip(
                label: 'Food & Culinary',
                icon: Icons.restaurant_menu,
                value: 'food',
                selected: _selectedCategory == 'food',
                onSelect: () => setState(() => _selectedCategory = 'food'),
              ),
              _VibeChoiceChip(
                label: 'Family & Leisure',
                icon: Icons.family_restroom,
                value: 'family',
                selected: _selectedCategory == 'family',
                onSelect: () => setState(() => _selectedCategory = 'family'),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 3. Travel Pace & Companions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pace
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Exploration Pace', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _OptionChip(
                          label: 'Relaxed (Slow)',
                          selected: _selectedTravelStyle == 'relaxed',
                          onTap: () => setState(() => _selectedTravelStyle = 'relaxed'),
                        ),
                        _OptionChip(
                          label: 'Balanced',
                          selected: _selectedTravelStyle == 'balanced',
                          onTap: () => setState(() => _selectedTravelStyle = 'balanced'),
                        ),
                        _OptionChip(
                          label: 'Intensive (See all)',
                          selected: _selectedTravelStyle == 'intensive',
                          onTap: () => setState(() => _selectedTravelStyle = 'intensive'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              // Group / Companions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Travel Companions', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _OptionChip(
                          label: 'Solo (1)',
                          selected: _selectedGroupSize == 1,
                          onTap: () => setState(() => _selectedGroupSize = 1),
                        ),
                        _OptionChip(
                          label: 'Couple (2)',
                          selected: _selectedGroupSize == 2,
                          onTap: () => setState(() => _selectedGroupSize = 2),
                        ),
                        _OptionChip(
                          label: 'Family (3-4)',
                          selected: _selectedGroupSize == 4,
                          onTap: () => setState(() => _selectedGroupSize = 4),
                        ),
                        _OptionChip(
                          label: 'Friends (5+)',
                          selected: _selectedGroupSize == 6,
                          onTap: () => setState(() => _selectedGroupSize = 6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 4. Budget Tier & Special Interests
          Text('Budget Preference', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BudgetTierCard(
                  title: 'Backpacker / Budget',
                  subtitle: 'Public transit & heritage homestays',
                  selected: _selectedBudgetTier == 'budget',
                  onTap: () => setState(() => _selectedBudgetTier = 'budget'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BudgetTierCard(
                  title: 'Explorer / Moderate',
                  subtitle: 'Boutique hotels & curated dining',
                  selected: _selectedBudgetTier == 'moderate',
                  onTap: () => setState(() => _selectedBudgetTier = 'moderate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BudgetTierCard(
                  title: 'Luxury / Indulgent',
                  subtitle: '5-star heritage stays & private cars',
                  selected: _selectedBudgetTier == 'luxury',
                  onTap: () => setState(() => _selectedBudgetTier = 'luxury'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 5. Hidden Gems & Offbeat Spots Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: NavTripPalette.outlineVariant),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Include Offbeat & Hidden Gems', style: theme.textTheme.titleMedium),
              subtitle: Text('Add secret alleyways, local tea houses, and scenic lookouts.', style: theme.textTheme.bodySmall),
              value: _includeHiddenGems,
              activeThumbColor: NavTripPalette.terracotta,
              activeTrackColor: NavTripPalette.terracotta.withValues(alpha: 0.35),
              onChanged: (val) => setState(() => _includeHiddenGems = val),
            ),
          ),
          const SizedBox(height: 18),

          // 6. Sticky Note with Local Insight & Crowd Advice
          Container(
            decoration: NavTripStyles.stickyNote(context: context),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.push_pin, color: NavTripPalette.terracotta, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Local Guide Tip for ${meta.name}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: NavTripPalette.terracottaDeep,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        meta.crowdTip,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Top Recommended Stops: ${meta.highlights.join(" • ")}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: NavTripPalette.mutedInk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: NavTripPalette.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: NavTripPalette.terracotta, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI & Map Engine will arrange Day 1 to Day $_selectedDays for $_selectedDestination',
                style: theme.textTheme.bodyMedium?.copyWith(color: NavTripPalette.mutedInk),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _handleConfirmTrip,
                icon: const Icon(Icons.route_outlined),
                label: Text('Generate & Plan $_selectedDestination'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DestinationPolaroidCard extends StatefulWidget {
  const _DestinationPolaroidCard({
    required this.destination,
    required this.isSelected,
    required this.onSelect,
  });

  final CuratedDestination destination;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  State<_DestinationPolaroidCard> createState() => _DestinationPolaroidCardState();
}

class _DestinationPolaroidCardState extends State<_DestinationPolaroidCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? NavTripPalette.terracotta
                  : (_hovered ? NavTripPalette.outline : NavTripPalette.outlineVariant),
              width: widget.isSelected ? 2.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? NavTripPalette.terracotta.withValues(alpha: 0.22)
                    : const Color.fromRGBO(0, 0, 0, 0.08),
                blurRadius: _hovered ? 14 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          widget.destination.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: NavTripPalette.sand,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                    ),
                    if (widget.isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: NavTripPalette.terracotta,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('ACTIVE',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.destination.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: widget.isSelected
                          ? NavTripPalette.terracottaDeep
                          : NavTripPalette.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${widget.destination.defaultDays} Days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: NavTripPalette.mutedInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.destination.region,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: NavTripPalette.mutedInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetDayChip extends StatelessWidget {
  const _PresetDayChip({
    required this.label,
    required this.days,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int days;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: NavTripPalette.terracotta,
      labelStyle: TextStyle(
        color: selected ? Colors.white : NavTripPalette.ink,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _VibeChoiceChip extends StatelessWidget {
  const _VibeChoiceChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : NavTripPalette.terracotta),
      label: Text(label),
      selected: selected,
      selectedColor: NavTripPalette.terracotta,
      labelStyle: TextStyle(
        color: selected ? Colors.white : NavTripPalette.ink,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      onSelected: (_) => onSelect(),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: NavTripPalette.terracotta,
      labelStyle: TextStyle(
        color: selected ? Colors.white : NavTripPalette.ink,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _BudgetTierCard extends StatelessWidget {
  const _BudgetTierCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? NavTripPalette.sand : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? NavTripPalette.terracotta : NavTripPalette.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? NavTripPalette.terracottaDeep : NavTripPalette.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: NavTripPalette.mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: NavTripPalette.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: NavTripPalette.terracotta),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
