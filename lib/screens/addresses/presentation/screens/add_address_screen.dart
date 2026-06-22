import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moona/screens/addresses/presentation/screens/widgets/pick_location_widget.dart';
import 'package:moona/utils/widgets/snackbar/failed_snackbar.dart';

import '../../../../utils/resources/app_colors.dart';
import '../../../../utils/widgets/field.dart';
import '../../data/entities/address_entity.dart';
import '../cubit/addresses_cubit.dart';
import '.../../pick_location_map_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key, required this.add});

  final bool add;

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  LatLng? location;
  bool done = true;
  String type = 'home';
  bool setDefault = false;
  bool loading = false;

  @override
  void initState() {
    _addressNameController.text = 'عنوان المنزل';
    // if (AuthCubit.user != null) {
    //   _userNameController.text = "${AuthCubit.user!.fullName}";
    // } else {
    //   _userNameController.text = '';
    // }
    // if (!widget.add && widget.address != null) {
    //   _userNameController.text = widget.address!.firstname;
    //   _phoneNumberController.text = widget.address!.telephone;
    //   _addressNameController.text = widget.address!.name;
    //   _addressController.text = widget.address!.address;
    //   setDefault = widget.address!.isDefault == 1 ? true : false;
    // }
    // TODO: implement initState
    super.initState();
  }

  Widget _buildMapPreview() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PickLocationMapScreen(
              view: false,
              location: location,
            ),
          ),
        );

        if (result != null && result is LatLng) {
          setState(() {
            location = result;
          });
        }
      },
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        clipBehavior: Clip.antiAlias,
        child: location == null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(24.7136, 46.6753),
                      zoom: 12,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.location_on,
                          color: kMainColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'حدد موقعك',
                          style: TextStyle(
                            fontFamily: 'DINNextLT',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location!,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: location!,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
      ),
    );
  }

  onSave() async {
    if (!key.currentState!.validate()) return;
    if (location == null) {
      showFailedTopSnackBar(
        context: context,
        title: 'انتبه',
        content: 'يحب تحديد العنوان أولا',
      );
    }
    // setState(() {
    //   loading = true;
    // });

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
    setState(() {
      loading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset('assets/images/arrow-right.svg'),
          ),
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
            child: Text(
              "إضافة عنوان",
              style: const TextStyle(
                fontFamily: 'DINNextLT',
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: key,
                  child: Column(
                    children: [
                      _buildMapPreview(),
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
                                  Expanded(
                                    child: Field(
                                      text: 'اسم البناء',
                                      validateText: 'اسم البناء',
                                      readOnly: false,
                                      obscureText: false,
                                      controller: _buildingController,
                                      prefixIcon: const Icon(
                                        Icons.house_outlined,
                                        color: kMainColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Field(
                                      text: 'الطابق',
                                      validateText: 'الطابق',
                                      readOnly: false,
                                      obscureText: false,
                                      controller: _floorController,
                                      prefixIcon: const Icon(
                                        Icons.house_outlined,
                                        color: kMainColor,
                                      ),
                                    ),
                                  ),
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
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'عنواني الإفتراضي',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PickLocationWidget(
                          location: location,
                          onTap: (LatLng? p2) {
                            setState(() {
                              location = p2;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => onSave(),
                          child: Container(
                            height: 50,
                            width: size.width,
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
                            child: Center(
                              child: Text(
                                'حفظ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'DINNextLT',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
            loading
                ? Container(
                    width: size.width,
                    height: size.height,
                    color: Colors.black38,
                  )
                : Container(),
            loading
                ? const Center(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(color: kMainColor),
                      ),
                    ),
                  )
                : Container(),
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
