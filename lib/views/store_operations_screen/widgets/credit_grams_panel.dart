import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../controllers/user_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user.dart';
import '../../../widgets/common/user_avatar_image.dart';
import 'quick_tips.dart';

class CreditGramsPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController gramsController;
  final TextEditingController userSearchController;
  final bool isLoading;
  final List<User> filteredUsers;
  final String? selectedUserId;
  final User? selectedUser;
  final UserController userController;
  final VoidCallback onCreditGrams;
  final Function(String) onFilterUsers;
  final Function(User) onSelectUser;
  final String? Function(String?) gramsValidator;

  const CreditGramsPanel({
    super.key,
    required this.formKey,
    required this.gramsController,
    required this.userSearchController,
    required this.isLoading,
    required this.filteredUsers,
    required this.selectedUserId,
    required this.selectedUser,
    required this.userController,
    required this.onCreditGrams,
    required this.onFilterUsers,
    required this.onSelectUser,
    required this.gramsValidator,
  });

  String _backendDisplayId(User user) {
    final backendId = user.backendId?.trim();
    if (backendId != null && backendId.isNotEmpty) return backendId;
    return user.id;
  }

  String _shorten(String value) {
    if (value.length <= 20) return value;
    return '${value.substring(0, 20)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // === Header ===
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_card, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit Grams to User',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        'For in-store purchases',
                        style: TextStyle(color: AppColors.grey500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Lottie.asset(
                    'assets/lottie/website building of shopping sale.json',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // === ROW: Left (User + Grams + Button) | Right (Fee + Tips) ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT: Select User + Grams + Button
                Expanded(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Select User',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.grey200, width: 1),
                          ),
                          child: PopupMenuButton<Map<String, dynamic>>(
                            offset: const Offset(0, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(
                              maxWidth: 500,
                              maxHeight: 400,
                            ),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem<Map<String, dynamic>>(
                                  enabled: false,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: userSearchController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          hintText: 'Search users...',
                                          prefixIcon: const Icon(Icons.search, size: 18),
                                          filled: true,
                                          fillColor: AppColors.grey100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10,
                                          ),
                                        ),
                                        onChanged: onFilterUsers,
                                      ),
                                      const Divider(),
                                      Obx(
                                        () => userController.isLoading.value
                                            ? const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: CircularProgressIndicator(),
                                              )
                                            : filteredUsers.isEmpty
                                                ? Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Text(
                                                      'No users found',
                                                      style: TextStyle(color: AppColors.grey600),
                                                    ),
                                                  )
                                                : Container(
                                                    constraints: const BoxConstraints(maxHeight: 250),
                                                    child: SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: filteredUsers.map((user) {
                                                          final displayId = _backendDisplayId(user);
                                                          return InkWell(
                                                            onTap: () {
                                                              onSelectUser(user);
                                                              Navigator.pop(context);
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets.symmetric(
                                                                horizontal: 14, vertical: 8,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                color: selectedUserId == user.id
                                                                    ? AppColors.primary.withValues(alpha: 0.1)
                                                                    : Colors.transparent,
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  UserAvatarImage(user: user, radius: 14),
                                                                  const SizedBox(width: 8),
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          user.displayName,
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.w500,
                                                                            color: AppColors.textPrimary,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                        if (user.phoneNumber != null)
                                                                          Text(
                                                                            user.phoneNumber!,
                                                                            style: TextStyle(fontSize: 10, color: AppColors.grey600),
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        Text(
                                                                          'ID: ${_shorten(displayId)}',
                                                                          style: TextStyle(fontSize: 9, color: AppColors.grey600),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  selectedUser != null
                                      ? UserAvatarImage(user: selectedUser!, radius: 14)
                                      : Icon(Icons.person_outline, color: AppColors.grey600, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: selectedUser != null
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                selectedUser!.displayName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'ID: ${_shorten(_backendDisplayId(selectedUser!))}',
                                                style: TextStyle(fontSize: 9, color: AppColors.grey600),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Select a user',
                                            style: TextStyle(color: AppColors.grey600, fontSize: 12),
                                          ),
                                  ),
                                  Icon(Icons.arrow_drop_down, color: AppColors.grey600, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Grams',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: gramsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'e.g., 5.0',
                            prefixIcon: const Icon(Icons.scale, size: 16),
                            suffixText: 'g',
                            filled: true,
                            fillColor: AppColors.grey100,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.grey200, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: gramsValidator,
                        ),
                        const SizedBox(height: 10),
                        // Button under grams field
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : onCreditGrams,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: isLoading ? 0 : 1,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 16),
                                      SizedBox(width: 5),
                                      Text(
                                        'Credit Grams',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // RIGHT: Fee Details + Quick Tips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.info, size: 14),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Fee: ${AppConstants.buyFeePercent}% + ${AppConstants.vatPercent}% VAT',
                                    style: TextStyle(
                                      color: AppColors.info,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline, color: AppColors.success, size: 13),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Auto-approved',
                                    style: TextStyle(color: AppColors.success, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      QuickTips(
                        tips: const [
                          'Verify user identity',
                          'Double-check amount',
                          'Irreversible',
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
