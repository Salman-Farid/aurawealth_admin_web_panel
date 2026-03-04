import 'package:get/get.dart';
import '../models/message.dart';
import '../models/message_thread.dart';
import '../services/api_service.dart';

class MessageController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<MessageThread> messageThreads = <MessageThread>[].obs;
  final RxList<Message> currentThreadMessages = <Message>[].obs;
  final RxString selectedUserId = ''.obs;
  final RxBool isSendingMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessageThreads();
  }

  Future<void> loadMessageThreads() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _apiService.getMessageThreads();
      messageThreads.value = data
          .map((json) => MessageThread.fromJson(json))
          .toList();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserMessages(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedUserId.value = userId;

      final data = await _apiService.getUserMessages(userId);
      currentThreadMessages.value = data
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendReply(String userId, String message) async {
    try {
      isSendingMessage.value = true;
      errorMessage.value = '';

      await _apiService.replyToUser(userId, message);
      
      // Reload messages to show the new reply
      await loadUserMessages(userId);
      await loadMessageThreads(); // Update unread counts
      
      Get.snackbar('Success', 'Reply sent successfully');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isSendingMessage.value = false;
    }
  }

  void refresh() {
    if (selectedUserId.value.isNotEmpty) {
      loadUserMessages(selectedUserId.value);
    } else {
      loadMessageThreads();
    }
  }
}
