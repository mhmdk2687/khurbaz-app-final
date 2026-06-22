import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moona/screens/addresses/presentation/screens/add_address_map_screen.dart';
import 'package:moona/screens/auth/uis/screens/login_screen.dart';
import 'package:moona/state-managment/bloc/auth/auth_cubit.dart';

import '../../../../../utils/helper/navigation/push_to.dart';
import '../../../../../utils/resources/app_colors.dart';
import '../../cubit/addresses_cubit.dart';
import '../../cubit/addresses_state.dart';
import '../add_address_screen.dart';
import '../widgets/address_card.dart';
import '../widgets/address_card_shimmer.dart';

class AddressesDialog extends StatefulWidget {
  const AddressesDialog({super.key});

  @override
  State<AddressesDialog> createState() => _AddressesDialogState();
}

class _AddressesDialogState extends State<AddressesDialog> {
  @override
  void initState() {
    super.initState();
    context.read<AddressesCubit>().loadAddresses();
  }

  void _addAddress() {
    if (AuthCubit.user?.phoneNumber == null) {
      pushTo(context, const LoginScreen());
    } else {
      // pushTo(context, const AddAddressScreen(add: true));
      pushTo(context, const AddAddressMapScreen(add: true));
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('حذف العنوان'),
            content: const Text('هل تريد حذف هذا العنوان؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'حذف',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: kScaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'عناوين التوصيل',
                      style: TextStyle(
                        fontFamily: 'DINNextLT',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _addAddress,
                      icon: const Icon(
                        Icons.add_circle,
                        color: kMainColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              /// CONTENT
              Expanded(
                child: BlocBuilder<AddressesCubit, AddressesState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case AddressesStatus.initial:
                        return const SizedBox();

                      case AddressesStatus.loading:
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: 4,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, __) => const AddressCardShimmer(),
                        );

                      case AddressesStatus.error:
                        return _ErrorState(
                          message:
                              state.errorMessage ?? 'حدث خطأ أثناء التحميل',
                          onRetry: () =>
                              context.read<AddressesCubit>().loadAddresses(),
                        );

                      case AddressesStatus.loaded:
                        if (state.addresses.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد عناوين محفوظة',
                              style: TextStyle(
                                fontFamily: 'DINNextLT',
                                fontSize: 14,
                                color: kSubtitleColor,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.addresses.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final address = state.addresses[index];

                            return Dismissible(
                              key: ValueKey(address.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => _confirmDelete(context),
                              onDismissed: (_) {
                                context
                                    .read<AddressesCubit>()
                                    .deleteAddress(id: address.id);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  AddressCard(address: address),

                                  // SAFE FRONTEND FIX: Subtle swipe hint icon
                                  PositionedDirectional(
                                    top: 75,
                                    end: 12,
                                    child: IgnorePointer(
                                      child: Icon(
                                        Icons.swipe,
                                        color: Colors.grey.withOpacity(0.4),
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= ERROR UI =================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 48, color: kTitleGreyColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontFamily: 'DINNextLT', fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: kMainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
