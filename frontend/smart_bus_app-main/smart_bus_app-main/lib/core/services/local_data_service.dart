enum AppRole { student, parent, admin }

class AppUser {
  const AppUser({
    required this.username,
    required this.password,
    required this.displayName,
    required this.role,
    this.busId,
    this.linkedStudent,
  });

  final String username;
  final String password;
  final String displayName;
  final AppRole role;
  final String? busId;
  final String? linkedStudent;
}

class BusStop {
  const BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.morningTime,
    this.eveningTime,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? morningTime;
  final String? eveningTime;
}

class BusRoute {
  const BusRoute({
    required this.busId,
    required this.stops,
  });

  final String busId;
  final List<BusStop> stops;

  String get title {
    if (stops.isEmpty) {
      return busId;
    }
    return '${stops.first.name} -> ${stops.last.name}';
  }
}

class SessionService {
  static AppUser? currentUser;

  static void logout() {
    currentUser = null;
  }
}

class LocalDataService {
  static const List<AppUser> _users = [
    AppUser(
      username: 'student_akhil',
      password: '1234',
      displayName: 'Akhil',
      role: AppRole.student,
      busId: 'KL21C6097',
    ),
    AppUser(
      username: 'parent_akhil',
      password: '1234',
      displayName: 'Akhil Parent',
      linkedStudent: 'Akhil',
      role: AppRole.parent,
      busId: 'KL21C6097',
    ),
    AppUser(
      username: 'student_anju',
      password: '1234',
      displayName: 'Anju',
      role: AppRole.student,
      busId: 'KL01AX416',
    ),
    AppUser(
      username: 'parent_anju',
      password: '1234',
      displayName: 'Anju Parent',
      linkedStudent: 'Anju',
      role: AppRole.parent,
      busId: 'KL01AX416',
    ),
    AppUser(
      username: 'student_nemo',
      password: '1234',
      displayName: 'Nemo',
      role: AppRole.student,
      busId: 'KL01AI711',
    ),
    AppUser(
      username: 'parent_nemo',
      password: '1234',
      displayName: 'Nemo Parent',
      linkedStudent: 'Nemo',
      role: AppRole.parent,
      busId: 'KL01AI711',
    ),
    AppUser(
      username: 'student_athira',
      password: '1234',
      displayName: 'Athira',
      role: AppRole.student,
      busId: 'KL01Z418',
    ),
    AppUser(
      username: 'parent_athira',
      password: '1234',
      displayName: 'Athira Parent',
      linkedStudent: 'Athira',
      role: AppRole.parent,
      busId: 'KL01Z418',
    ),
    AppUser(
      username: 'student_vivek',
      password: '1234',
      displayName: 'Vivek',
      role: AppRole.student,
      busId: 'KL21C6095',
    ),
    AppUser(
      username: 'parent_vivek',
      password: '1234',
      displayName: 'Vivek Parent',
      linkedStudent: 'Vivek',
      role: AppRole.parent,
      busId: 'KL21C6095',
    ),
    AppUser(
      username: 'admin',
      password: 'admin',
      displayName: 'Operations Admin',
      role: AppRole.admin,
    ),
  ];

  static const Map<String, BusRoute> _routes = {
    'KL21C6097': BusRoute(
      busId: 'KL21C6097',
      stops: [
        BusStop(
            name: 'Pettah',
            latitude: 8.499459746883616,
            longitude: 76.9153429306698,
            morningTime: '07:35',
            eveningTime: '17:57'),
        BusStop(
            name: 'Chakka',
            latitude: 8.492044822673023,
            longitude: 76.92260247852028,
            morningTime: '07:37',
            eveningTime: '17:55'),
        BusStop(
            name: 'Ananthapuri Hospital',
            latitude: 8.486947500914184,
            longitude: 76.92740379035172,
            morningTime: '07:39',
            eveningTime: '17:53'),
        BusStop(
            name: 'Enchakkal',
            latitude: 8.480076679169642,
            longitude: 76.93372524563347,
            morningTime: '07:42',
            eveningTime: '17:50'),
        BusStop(
            name: 'Kallummoodu',
            latitude: 8.469835233146554,
            longitude: 76.9365369158428,
            morningTime: '07:43',
            eveningTime: '17:49'),
        BusStop(
            name: 'Muttathara Sarathy',
            latitude: 8.46462628086708,
            longitude: 76.93946260155553,
            morningTime: '07:44',
            eveningTime: '17:48'),
        BusStop(
            name: 'Kumarichanda',
            latitude: 8.450100972326865,
            longitude: 76.94782081552466,
            morningTime: '07:48',
            eveningTime: '17:44'),
        BusStop(
            name: 'Thiruvallam',
            latitude: 8.440447073757795,
            longitude: 76.95568817432769,
            morningTime: '07:50',
            eveningTime: '17:42'),
        BusStop(
            name: 'Ampalathara (Milma)',
            latitude: 8.452557142085837,
            longitude: 76.95120908992288,
            morningTime: '07:52',
            eveningTime: '17:27'),
        BusStop(
            name: 'Kallattumukku',
            latitude: 8.461772596646341,
            longitude: 76.95022099526778,
            morningTime: '07:55',
            eveningTime: '17:25'),
        BusStop(
            name: 'Kamaleswaram',
            latitude: 8.468022101681726,
            longitude: 76.94817164655757,
            morningTime: '07:57',
            eveningTime: '17:22'),
        BusStop(
            name: 'Manacaud',
            latitude: 8.475307020390673,
            longitude: 76.94758909657804,
            morningTime: '08:00',
            eveningTime: '17:20'),
        BusStop(
            name: 'Attakulangara',
            latitude: 8.479110361879748,
            longitude: 76.94751877842748,
            morningTime: '08:02',
            eveningTime: '17:22'),
        BusStop(
            name: 'Sreevaraham',
            latitude: 8.478950417869811,
            longitude: 76.9423407226526,
            morningTime: '08:05',
            eveningTime: '17:20'),
        BusStop(
            name: 'West Fort',
            latitude: 8.483017441054756,
            longitude: 76.9417954955232,
            morningTime: '08:07',
            eveningTime: '17:17'),
        BusStop(
            name: 'Kaithamukku',
            latitude: 8.48495732482047,
            longitude: 76.94181617405127,
            morningTime: '08:10',
            eveningTime: '17:16'),
        BusStop(
            name: 'Uppalamoodu Bridge',
            latitude: 8.490093392160759,
            longitude: 76.9410705888688,
            morningTime: '08:12',
            eveningTime: '17:15'),
        BusStop(
            name: 'Vanchiyoor',
            latitude: 8.494106990279377,
            longitude: 76.940443638705,
            morningTime: '08:15',
            eveningTime: '17:14'),
        BusStop(
            name: 'College',
            latitude: 8.548540764913199,
            longitude: 76.93879898422404,
            morningTime: '08:45',
            eveningTime: '16:45'),
      ],
    ),
    'KL01AX416': BusRoute(
      busId: 'KL01AX416',
      stops: [
        BusStop(
            name: 'Pangappara',
            latitude: 8.558164,
            longitude: 76.9280,
            morningTime: '07:40',
            eveningTime: '17:47'),
        BusStop(
            name: 'Karyavattom',
            latitude: 8.566900,
            longitude: 76.9340,
            morningTime: '07:47',
            eveningTime: '17:45'),
        BusStop(
            name: 'Kazhakkoottam',
            latitude: 8.566563,
            longitude: 76.9440,
            morningTime: '07:50',
            eveningTime: '17:40'),
        BusStop(
            name: 'Kulathoor',
            latitude: 8.540721,
            longitude: 76.9480,
            morningTime: '08:00',
            eveningTime: '17:30'),
        BusStop(
            name: 'CET',
            latitude: 8.546817,
            longitude: 76.9530,
            morningTime: '08:08',
            eveningTime: '17:22'),
        BusStop(
            name: 'Sreekaryam',
            latitude: 8.549818,
            longitude: 76.9570,
            morningTime: '08:13',
            eveningTime: '17:17'),
        BusStop(
            name: 'Kochulloor',
            latitude: 8.533785,
            longitude: 76.9620,
            morningTime: '08:20',
            eveningTime: '17:10'),
      ],
    ),
    'KL01AI711': BusRoute(
      busId: 'KL01AI711',
      stops: [
        BusStop(
            name: 'Neramankara',
            latitude: 8.476919,
            longitude: 76.9430,
            morningTime: '07:30',
            eveningTime: '18:05'),
        BusStop(
            name: 'Pravachanam',
            latitude: 8.450369,
            longitude: 76.9490,
            morningTime: '07:50',
            eveningTime: '17:45'),
        BusStop(
            name: 'Nemo',
            latitude: 8.454353,
            longitude: 76.9540,
            morningTime: '07:55',
            eveningTime: '17:40'),
        BusStop(
            name: 'Vellayani',
            latitude: 8.460200,
            longitude: 76.9600,
            morningTime: '08:00',
            eveningTime: '17:35'),
        BusStop(
            name: 'Karakkamandapam',
            latitude: 8.470000,
            longitude: 76.9670,
            morningTime: '08:03',
            eveningTime: '17:32'),
        BusStop(
            name: 'Pappanam',
            latitude: 8.471428,
            longitude: 76.9720,
            morningTime: '08:05',
            eveningTime: '17:30'),
        BusStop(
            name: 'Kaimanam',
            latitude: 8.476354,
            longitude: 76.9780,
            morningTime: '08:10',
            eveningTime: '17:25'),
      ],
    ),
    'KL01Z418': BusRoute(
      busId: 'KL01Z418',
      stops: [
        BusStop(
            name: 'PRS',
            latitude: 8.481353,
            longitude: 76.9220,
            morningTime: '07:47',
            eveningTime: '17:43'),
        BusStop(
            name: 'Karamana',
            latitude: 8.482116,
            longitude: 76.9300,
            morningTime: '07:50',
            eveningTime: '17:40'),
        BusStop(
            name: 'Poojappura',
            latitude: 8.491044,
            longitude: 76.9360,
            morningTime: '07:52',
            eveningTime: '17:38'),
        BusStop(
            name: 'Jagathy',
            latitude: 8.494247,
            longitude: 76.9440,
            morningTime: '08:00',
            eveningTime: '17:30'),
        BusStop(
            name: 'DPI Jn',
            latitude: 8.495900,
            longitude: 76.9520,
            morningTime: '08:03',
            eveningTime: '17:27'),
        BusStop(
            name: 'Women\'s College',
            latitude: 8.499045,
            longitude: 76.9600,
            morningTime: '08:05',
            eveningTime: '17:25'),
        BusStop(
            name: 'Sreeram',
            latitude: 8.502259,
            longitude: 76.9680,
            morningTime: '08:07',
            eveningTime: '17:23'),
      ],
    ),
    'KL21C6095': BusRoute(
      busId: 'KL21C6095',
      stops: [
        BusStop(
            name: 'Edapazhanji',
            latitude: 8.505429,
            longitude: 76.9150,
            morningTime: '07:30',
            eveningTime: '17:45'),
        BusStop(
            name: 'Pangode',
            latitude: 8.765826,
            longitude: 76.9200,
            morningTime: '07:31',
            eveningTime: '17:44'),
        BusStop(
            name: 'Thirumala',
            latitude: 8.502949,
            longitude: 76.9280,
            morningTime: '07:33',
            eveningTime: '17:42'),
        BusStop(
            name: 'Valiyavila',
            latitude: 8.507052,
            longitude: 76.9360,
            morningTime: '07:38',
            eveningTime: '17:37'),
        BusStop(
            name: 'Vettamukku',
            latitude: 8.508408,
            longitude: 76.9440,
            morningTime: '07:43',
            eveningTime: '17:32'),
        BusStop(
            name: 'PTP Nagar',
            latitude: 8.513161,
            longitude: 76.9520,
            morningTime: '07:45',
            eveningTime: '17:30'),
        BusStop(
            name: 'Marutham',
            latitude: 8.513223,
            longitude: 76.9600,
            morningTime: '07:48',
            eveningTime: '17:27'),
      ],
    ),
  };

  static AppUser? authenticate(String username, String password) {
    final normalizedUsername = username.trim().toLowerCase();
    final normalizedPassword = password.trim();

    for (final user in _users) {
      if (user.username.toLowerCase() == normalizedUsername &&
          user.password == normalizedPassword) {
        return user;
      }
    }
    return null;
  }

  static List<AppUser> usersByRole(AppRole role) {
    return _users.where((user) => user.role == role).toList(growable: false);
  }

  static List<AppUser> allUsers() {
    return List<AppUser>.unmodifiable(_users);
  }

  static List<BusRoute> allRoutes() {
    return List<BusRoute>.unmodifiable(_routes.values);
  }

  static int etaApiBusIdForRoute(String? routeBusId) {
    if (routeBusId == null) {
      return 1;
    }

    final routeKeys = _routes.keys.toList(growable: false);
    final index = routeKeys.indexOf(routeBusId);
    if (index < 0) {
      return 1;
    }

    return index + 1;
  }

  static BusRoute? routeForBus(String? busId) {
    if (busId == null) {
      return null;
    }
    return _routes[busId];
  }
}
