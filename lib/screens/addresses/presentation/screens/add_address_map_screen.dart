import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../managers/location_maneger.dart';
import '../../../../utils/resources/app_colors.dart';
import '../../../../utils/widgets/field.dart';
import '../../../../utils/widgets/snackbar/failed_snackbar.dart';
import '../../data/entities/address_entity.dart';
import '../cubit/addresses_cubit.dart';
import 'package:flutter/services.dart';

class AddAddressMapScreen extends StatefulWidget {
  const AddAddressMapScreen({super.key, required this.add});

  final bool add;

  @override
  State<AddAddressMapScreen> createState() => _AddAddressMapScreenState();
}

class _AddAddressMapScreenState extends State<AddAddressMapScreen> {
  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      return 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
    }

    if (phone.length != 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام';
    }

    return null;
  }

  static const List<LatLng> _deliveryBoundary = <LatLng>[
    LatLng(17.5669100, 44.3170080),
    LatLng(17.5668250, 44.3105620),
    LatLng(17.5643700, 44.3042530),
    LatLng(17.5597060, 44.3051980),
    LatLng(17.5588470, 44.3019790),
    LatLng(17.5607290, 44.3008630),
    LatLng(17.5565960, 44.2941250),
    LatLng(17.5794850, 44.2372040),
    LatLng(17.5879790, 44.2429170),
    LatLng(17.6016690, 44.2417640),
    LatLng(17.6094240, 44.2345830),
    LatLng(17.6261790, 44.2253390),
    LatLng(17.6365370, 44.2213810),
    LatLng(17.6296110, 44.2047320),
    LatLng(17.5827010, 44.2173710),
    LatLng(17.5742050, 44.2194360),
    LatLng(17.5724950, 44.2082950),
    LatLng(17.5544430, 44.2020340),
    LatLng(17.5404900, 44.2107840),
    LatLng(17.5372530, 44.1935100),
    LatLng(17.5405770, 44.1912300),
    LatLng(17.5393540, 44.1891940),
    LatLng(17.5335280, 44.1876850),
    LatLng(17.5289250, 44.1884390),
    LatLng(17.5231700, 44.1845920),
    LatLng(17.5215150, 44.1847430),
    LatLng(17.5200770, 44.1867800),
    LatLng(17.5200050, 44.1891180),
    LatLng(17.5183500, 44.1904010),
    LatLng(17.5156890, 44.1855730),
    LatLng(17.5141060, 44.1778030),
    LatLng(17.5153260, 44.1753850),
    LatLng(17.5254680, 44.1773470),
    LatLng(17.5207930, 44.1579600),
    LatLng(17.5214400, 44.1492850),
    LatLng(17.5184910, 44.1460410),
    LatLng(17.5112250, 44.1504920),
    LatLng(17.5090950, 44.1469450),
    LatLng(17.5027610, 44.1478930),
    LatLng(17.4973930, 44.1458400),
    LatLng(17.4795450, 44.1536710),
    LatLng(17.4751850, 44.1456730),
    LatLng(17.4678390, 44.1449810),
    LatLng(17.4591360, 44.1628770),
    LatLng(17.4613250, 44.1706610),
    LatLng(17.4701960, 44.1700870),
    LatLng(17.4710860, 44.1762790),
    LatLng(17.4797910, 44.1768680),
    LatLng(17.4843770, 44.1807930),
    LatLng(17.4859210, 44.1855020),
    LatLng(17.4845730, 44.1885820),
    LatLng(17.4878930, 44.1947030),
    LatLng(17.4923920, 44.1957690),
    LatLng(17.4910510, 44.1959940),
    LatLng(17.4913890, 44.1994160),
    LatLng(17.4898350, 44.1990150),
    LatLng(17.4834360, 44.2043960),
    LatLng(17.4789440, 44.2067070),
    LatLng(17.4761190, 44.2067650),
    LatLng(17.4737920, 44.2125160),
    LatLng(17.4807170, 44.2178600),
    LatLng(17.4847370, 44.2197790),
    LatLng(17.4851250, 44.2214340),
    LatLng(17.4886740, 44.2378260),
    LatLng(17.4928580, 44.2475740),
    LatLng(17.4968870, 44.2541390),
    LatLng(17.5009960, 44.2523250),
    LatLng(17.4998700, 44.2474460),
    LatLng(17.5001380, 44.2472830),
    LatLng(17.5021000, 44.2470020),
    LatLng(17.5043220, 44.2461280),
    LatLng(17.5053050, 44.2441790),
    LatLng(17.5062880, 44.2442910),
    LatLng(17.5069930, 44.2459490),
    LatLng(17.5088340, 44.2462170),
    LatLng(17.5113790, 44.2466420),
    LatLng(17.5125200, 44.2439860),
    LatLng(17.5134390, 44.2432690),
    LatLng(17.5176100, 44.2403420),
    LatLng(17.5191850, 44.2405340),
    LatLng(17.5200630, 44.2407760),
    LatLng(17.5181690, 44.2439720),
    LatLng(17.5212190, 44.2484860),
    LatLng(17.5230670, 44.2482930),
    LatLng(17.5245910, 44.2466940),
    LatLng(17.5266230, 44.2492600),
    LatLng(17.5241970, 44.2529580),
    LatLng(17.5230220, 44.2557380),
    LatLng(17.5214560, 44.2575480),
    LatLng(17.5213560, 44.2589640),
    LatLng(17.5234820, 44.2601970),
    LatLng(17.5232570, 44.2615080),
    LatLng(17.5221070, 44.2640000),
    LatLng(17.5230570, 44.2663600),
    LatLng(17.5234320, 44.2674350),
    LatLng(17.5208060, 44.2707660),
    LatLng(17.5188550, 44.2712910),
    LatLng(17.5165540, 44.2698750),
    LatLng(17.5125240, 44.2676620),
    LatLng(17.5070600, 44.2695200),
    LatLng(17.5050300, 44.2839580),
    LatLng(17.5007820, 44.3085620),
    LatLng(17.4912300, 44.3358440),
    LatLng(17.4913690, 44.3663360),
    LatLng(17.5012010, 44.3685140),
    LatLng(17.5085400, 44.3664810),
    LatLng(17.5181910, 44.3614730),
    LatLng(17.5342520, 44.3621990),
    LatLng(17.5506590, 44.3591880),
    LatLng(17.5509960, 44.3830160),
    LatLng(17.5426650, 44.3876060),
    LatLng(17.5551190, 44.4203030),
    LatLng(17.5602050, 44.4432200),
    LatLng(17.5676100, 44.4544280),
    LatLng(17.5777900, 44.4643130),
    LatLng(17.5955410, 44.4646660),
    LatLng(17.6088710, 44.4646650),
    LatLng(17.6152920, 44.4775200),
    LatLng(17.6209240, 44.4911590),
    LatLng(17.6233050, 44.5026520),
    LatLng(17.6352470, 44.5034650),
    LatLng(17.6422940, 44.5040650),
    LatLng(17.6552620, 44.5041650),
    LatLng(17.6594520, 44.4971690),
    LatLng(17.6601180, 44.4881750),
    LatLng(17.6599380, 44.4740850),
    LatLng(17.6613820, 44.4555460),
    LatLng(17.6554730, 44.4476830),
    LatLng(17.6424290, 44.4555020),
    LatLng(17.6323310, 44.4382750),
    LatLng(17.6280630, 44.4163930),
    LatLng(17.6280630, 44.4160320),
    LatLng(17.6208470, 44.4042550),
    LatLng(17.6030770, 44.3878960),
    LatLng(17.6014720, 44.3823630),
    LatLng(17.6088100, 44.3753870),
    LatLng(17.6092680, 44.3693730),
    LatLng(17.6104150, 44.3563820),
    LatLng(17.6081220, 44.3502470),
    LatLng(17.5965420, 44.3330470),
    LatLng(17.5755520, 44.3344880),
    LatLng(17.5671810, 44.3168060),
    LatLng(17.5670660, 44.3168060),
    LatLng(17.5669100, 44.3170080),
  ];

  LatLng get _deliveryAreaCenter {
    final lat = _deliveryBoundary.fold<double>(
          0,
          (sum, point) => sum + point.latitude,
        ) /
        _deliveryBoundary.length;

    final lng = _deliveryBoundary.fold<double>(
          0,
          (sum, point) => sum + point.longitude,
        ) /
        _deliveryBoundary.length;

    return LatLng(lat, lng);
  }

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();

  GoogleMapController? _mapController;

  LatLng? location;
  LatLng? _cameraTarget;
  CameraPosition? _initialCameraPosition;

  bool setDefault = false;
  bool loading = false;
  String type = 'home';

  bool _isInsideDeliveryZone = true;
  bool _zoneMessageShowing = false;

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#383838"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

  @override
  void initState() {
    super.initState();
    _addressNameController.text = 'عنوان المنزل';
    _loadCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyMapStyleIfReady();
    });
  }

  bool _isInsideDeliveryArea(LatLng point) {
    bool inside = false;
    final n = _deliveryBoundary.length;
    if (n < 3) return false;

    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = _deliveryBoundary[i].longitude;
      final yi = _deliveryBoundary[i].latitude;
      final xj = _deliveryBoundary[j].longitude;
      final yj = _deliveryBoundary[j].latitude;

      final intersects = ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) *
                      (point.latitude - yi) /
                      ((yj - yi) == 0 ? 1e-12 : (yj - yi)) +
                  xi);

      if (intersects) inside = !inside;
    }

    return inside;
  }

  // Keeping this in case you still want the snackbar occasionally,
  // but the new floating widget handles the main visual warning.
  Future<void> _showUnsupportedRegionMessage() async {
    if (_zoneMessageShowing || !mounted) return;

    _zoneMessageShowing = true;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('عذراً، هذا الموقع خارج نطاق التوصيل حالياً.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _zoneMessageShowing = false;
    }
  }

  Future<void> _syncLocationAndZone(
    LatLng point, {
    bool showDialogIfOutside = true,
  }) async {
    final inside = _isInsideDeliveryArea(point);

    if (!mounted) return;

    setState(() {
      location = point;
      _cameraTarget = point;
      _isInsideDeliveryZone = inside;
    });

    if (!inside && showDialogIfOutside) {
      await _showUnsupportedRegionMessage();
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final locationManager = LocationManager();
      final currentLocation = await locationManager.getLocation();

      if (!mounted) return;

      setState(() {
        location = currentLocation;
        _cameraTarget = currentLocation;
        _initialCameraPosition = CameraPosition(
          target: currentLocation,
          zoom: 16,
        );
      });

      await _syncLocationAndZone(
        currentLocation,
        showDialogIfOutside: false,
      );
    } catch (_) {
      if (!mounted) return;

      const fallback = LatLng(24.7136, 46.6753);

      setState(() {
        location = fallback;
        _cameraTarget = fallback;
        _initialCameraPosition = const CameraPosition(
          target: fallback,
          zoom: 12,
        );
      });

      await _syncLocationAndZone(
        fallback,
        showDialogIfOutside: false,
      );
    }
  }

  void _applyMapStyleIfReady() {
    if (_mapController == null) return;

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    _mapController!.setMapStyle(isDark ? _darkMapStyle : null);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final locationManager = LocationManager();
      final currentLocation = await locationManager.getLocation();

      if (!mounted) return;

      await _syncLocationAndZone(
        currentLocation,
        showDialogIfOutside: false,
      );

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 16,
          ),
        ),
      );

      if (!_isInsideDeliveryZone) {
        await _showUnsupportedRegionMessage();
      }
    } catch (_) {}
  }

  Future<void> _goToDeliveryArea() async {
    if (!mounted) return;

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _deliveryAreaCenter,
          zoom: 13,
        ),
      ),
    );

    await _syncLocationAndZone(
      _deliveryAreaCenter,
      showDialogIfOutside: false,
    );
  }

  Future<void> onSave() async {
    if (!key.currentState!.validate()) return;

    if (location == null) {
      showFailedTopSnackBar(
        context: context,
        title: 'انتبه',
        content: 'يحب تحديد العنوان أولا',
      );
      return;
    }

    if (!_isInsideDeliveryZone) {
      await _showUnsupportedRegionMessage();
      return;
    }

    setState(() {
      loading = true;
    });

    final address = AddressEntity(
      id: 0,
      receiverName: _userNameController.text,
      phoneNumber: _phoneNumberController.text,
      addressName: _addressNameController.text,
      locationName: _addressController.text,
      buildingName: _buildingController.text,
      floor: _floorController.text,
      latitude: location!.latitude,
      longitude: location!.longitude,
      isDefault: setDefault,
    );

    await context.read<AddressesCubit>().addAddress(address: address);
    context.read<AddressesCubit>().loadAddresses();

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    Navigator.pop(context);
  }

  Widget _buildBottomSheet(ScrollController scrollController) {
    return Container(
      decoration: const BoxDecoration(
        color: kScaffoldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: key,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'إضافة عنوان',
                      style: TextStyle(
                        fontFamily: 'DINNextLT',
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      location == null
                          ? 'جاري تحديد الموقع'
                          : (_isInsideDeliveryZone
                              ? 'التوصيل متاح'
                              : 'خارج النطاق'),
                      style: TextStyle(
                        fontFamily: 'DINNextLT',
                        fontSize: 12,
                        color: location == null
                            ? kSubtitleColor
                            : (_isInsideDeliveryZone
                                ? Colors.green
                                : Colors.red),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SelectableIconsRow(
                  onUpdateType: (type) {
                    setState(() {
                      this.type = type;
                      if (type == 'home') {
                        _addressNameController.text = 'عنوان المنزل';
                      } else if (type == 'work') {
                        _addressNameController.text = 'عنوان العمل';
                      } else {
                        _addressNameController.text = '';
                      }
                    });
                  },
                ),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: Field(
                                text: 'اسم العنوان',
                                validateText: 'اسم العنوان',
                                readOnly: false,
                                obscureText: false,
                                controller: _addressNameController,
                                prefixIcon: const Icon(
                                  Icons.edit,
                                  color: kMainColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Field(
                                text: 'اسم المستلم',
                                validateText: 'اسم المستلم',
                                readOnly: false,
                                obscureText: false,
                                controller: _userNameController,
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: kMainColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Field(
                          text: 'العنوان',
                          validateText: 'العنوان',
                          readOnly: false,
                          obscureText: false,
                          controller: _addressController,
                          prefixIcon: const Icon(
                            Icons.home_work_rounded,
                            color: kMainColor,
                          ),
                        ),
                        Row(
                          spacing: 8,
                          children: [
                            // Expanded(
                            //   child: Field(
                            //     text: 'اسم البناء',
                            //     validateText: 'اسم البناء',
                            //     readOnly: false,
                            //     obscureText: false,
                            //     controller: _buildingController,
                            //     prefixIcon: const Icon(
                            //       Icons.house_outlined,
                            //       color: kMainColor,
                            //     ),
                            //   ),
                            // ),
                            //   Expanded(
                            //     child: Field(
                            //       text: 'الطابق',
                            //       validateText: 'الطابق',
                            //       readOnly: false,
                            //       obscureText: false,
                            //       controller: _floorController,
                            //       prefixIcon: const Icon(
                            //         Icons.house_outlined,
                            //         color: kMainColor,
                            //       ),
                            //     ),
                            //   ),
                          ],
                        ),
                        Field(
                          text: 'رقم الهاتف',
                          validateText: 'رقم الهاتف',
                          readOnly: false,
                          obscureText: false,
                          maxLength: 10,
                          keyboardType: TextInputType.phone,
                          controller: _phoneNumberController,
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: kMainColor,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: _validatePhone,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'عنواني الإفتراضي',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DINNextLT',
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              Switch(
                                value: setDefault,
                                activeColor: kMainColor,
                                onChanged: (val) {
                                  setState(() {
                                    setDefault = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onSave,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(color: kMainColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: kMainColor.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'حفظ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DINNextLT',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _phoneNumberController.dispose();
    _userNameController.dispose();
    _addressNameController.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (_initialCameraPosition == null)
              const Center(
                child: CircularProgressIndicator(color: kMainColor),
              )
            else
              GoogleMap(
                initialCameraPosition: _initialCameraPosition!,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _applyMapStyleIfReady();
                },
                // --- INVERTED POLYGON ADDED HERE ---
                polygons: {
                  Polygon(
                    polygonId: const PolygonId('dimmed_world'),
                    // Draw a polygon covering the entire world
                    points: const [
                      LatLng(90.0, -180.0),
                      LatLng(90.0, 180.0),
                      LatLng(-90.0, 180.0),
                      LatLng(-90.0, -180.0),
                    ],
                    // Cut out the delivery boundary as a clear "hole"
                    holes: const [
                      _deliveryBoundary,
                    ],
                    // The dark overlay color (adjust opacity for more/less dimming)
                    fillColor:
                        const Color.fromARGB(248, 39, 70, 51).withOpacity(0.55),
                    strokeWidth: 0,
                    consumeTapEvents: false,
                  ),
                },
                polylines: {
                  const Polyline(
                    polylineId: PolylineId('delivery_area'),
                    points: _deliveryBoundary,
                    color: Colors.green,
                    width: 1,
                    geodesic: true,
                  ),
                },
                padding: const EdgeInsets.only(
                  top: 64,
                  right: 22,
                  left: 12,
                  bottom: 130,
                ),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onCameraMove: (CameraPosition position) {
                  _cameraTarget = position.target;
                },
                onCameraIdle: () {
                  if (_cameraTarget != null && mounted) {
                    _syncLocationAndZone(
                      _cameraTarget!,
                      showDialogIfOutside:
                          true, // Still triggers the existing snackbar
                    );
                  }
                },
              ),

            // Back Button
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            // --- FLOATING WARNING MESSAGE ADDED HERE ---
            // Positioned(
            //   top: 85, // Positioned slightly high on top of the map
            //   left: 16,
            //   right: 16,
            //   child: AnimatedSwitcher(
            //     duration: const Duration(milliseconds: 300),
            //     transitionBuilder: (Widget child, Animation<double> animation) {
            //       return FadeTransition(opacity: animation, child: child);
            //     },
            //     child: !_isInsideDeliveryZone
            //         ? Container(
            //             key: const ValueKey('out_of_zone_banner'),
            //             padding: const EdgeInsets.symmetric(
            //                 vertical: 12, horizontal: 16),
            //             decoration: BoxDecoration(
            //               color: Colors.red.shade50,
            //               borderRadius: BorderRadius.circular(12),
            //               border: Border.all(
            //                   color: Colors.red.shade200, width: 1.5),
            //               boxShadow: const [
            //                 BoxShadow(
            //                   color: Colors.black12,
            //                   blurRadius: 8,
            //                   offset: Offset(0, 4),
            //                 )
            //               ],
            //             ),
            //             child: const Row(
            //               children: [
            //                 Icon(Icons.info_outline, color: Colors.red),
            //                 SizedBox(width: 10),
            //                 Expanded(
            //                   child: Text(
            //                     'عذراً، هذا الموقع خارج نطاق التوصيل حالياً.',
            //                     style: TextStyle(
            //                       fontFamily: 'DINNextLT',
            //                       fontSize: 14,
            //                       fontWeight: FontWeight.w600,
            //                       color: Colors.red,
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           )
            //         : const SizedBox.shrink(key: ValueKey('empty_banner')),
            //   ),
            // ),

            // Center Pin Marker
            const IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place,
                      size: 58,
                      color: kMainColor,
                    ),
                    SizedBox(height: 2),
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Color.fromARGB(77, 1, 1, 1),
                    ),
                  ],
                ),
              ),
            ),

            // Go To Delivery Area Button
            Positioned(
              right: 16,
              top:
                  120, // Keep an eye on this padding to make sure it doesn't overlap the new banner
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.96),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _goToDeliveryArea,
                  child: const SizedBox(
                    width: 132,
                    height: 46,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alt_route,
                          color: Colors.black,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'اذهب للنطاق',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'DINNextLT',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.18,
                minChildSize: 0.15,
                maxChildSize: 0.82,
                builder: (context, scrollController) {
                  return _buildBottomSheet(scrollController);
                },
              ),
            ),

            // Loading Overlays
            if (loading)
              Container(
                width: size.width,
                height: size.height,
                color: Colors.black38,
              ),
            if (loading)
              const Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(color: kMainColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SelectableIconsRow extends StatefulWidget {
  const SelectableIconsRow({super.key, required this.onUpdateType});

  final Function(String) onUpdateType;

  @override
  State<SelectableIconsRow> createState() => _SelectableIconsRowState();
}

class _SelectableIconsRowState extends State<SelectableIconsRow> {
  String type = 'home';

  Widget _buildIcon({
    required IconData icon,
    required String value,
    required String current,
  }) {
    final bool isSelected = current == value;

    return GestureDetector(
      onTap: () {
        setState(() => type = value);
        widget.onUpdateType(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? kMainColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? kMainColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? kMainColor : Colors.grey,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
      child: Row(
        spacing: 12,
        children: [
          _buildIcon(icon: Icons.home, value: 'home', current: type),
          _buildIcon(icon: Icons.work_outline, value: 'work', current: type),
          _buildIcon(icon: Icons.category, value: 'category', current: type),
        ],
      ),
    );
  }
}
