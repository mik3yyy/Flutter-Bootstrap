#!/bin/bash

# Initialize Project
projectName=$1

echo "Initializing Flutter project: $projectName"

# Create a new Flutter project
flutter create $projectName
cd $projectName

# Create Assets Folder
mkdir -p application/assets/{images,fonts}
# Write to pubspec.yaml
cat <<EOL > pubspec.yaml
name: $projectName
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.3.4 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons:
  go_router: 
  hive_flutter: 
  bloc_test: 
  mocktail: 
  gap: 
  flutter_dotenv:
  loading_animation_widget: 
  image_picker: 
  bottom_sheet: 
  smooth_page_indicator: 
  cached_network_image: 
  pinput: 
  permission_handler: 
  intl: 
  equatable: 
  dartz: 
  bloc: 
  flutter_bloc: 
  get_it: 
  flutter_gen: 
  dartx: 
  url_launcher:
  dio:
  flutter_local_notifications: 
  firebase_core: 
  firebase_messaging: 


dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: 
  flutter_lints: ^3.0.0

  hive_generator: 
  flutter_gen_runner: 

flutter:
  uses-material-design: true

  assets:
    - application/assets/images/
    - application/assets/fonts/

EOL

flutter pub get


# Setup Core Folder Structure
# Create Extensions Folder and move string_extension.dart
mkdir -p lib/core/extensions

# Setup Core Folder Structure without certain folders, add notifications and widgets
mkdir -p lib/core/{error,services,storage/hive,theme,usecases,utils,widgets}
mkdir -p lib/core/notifications
mkdir -p lib/core/transitions
mkdir -p lib/core/routes

touch lib/core/error/{exceptions.dart,failures.dart}
touch lib/core/services/injection_container.dart
touch lib/core/storage/hive/hive_service.dart
touch lib/core/theme/{theme.dart,colors.dart,text_styles.dart,app_colors.dart}
touch lib/core/usecases/usecase.dart
touch lib/core/utils/{typedef.dart,constants.dart,image_util.dart,logger_util.dart,url_launch_services.dart,validators.dart}
mkdir -p lib/core/network
touch lib/core/network/{api_error.dart,api_interceptor.dart,error_interceptor.dart,network_provider.dart,network.dart,url_config.dart}
# Create Notification Service and Widgets Files
touch lib/core/notifications/{push_notification.dart,notification_service.dart}
touch lib/core/widgets/{custom_button.dart,custom_text_field.dart}
touch lib/core/extensions/{context_extensions.dart,widget_extensions.dart,string_extensions.dart}


touch lib/core/transitions/custom_slide_transition.dart
touch lib/core/transitions/custom_scale_transition.dart
touch lib/core/transitions/custom_rotation_transition.dart
touch lib/core/transitions/custom_size_transition.dart
touch lib/core/transitions/custom_fade_slide_transition.dart

# Add content to core files
cat <<EOL > lib/core/error/exceptions.dart
class ServerException implements Exception {}
class CacheException implements Exception {}
EOL

cat <<EOL > lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
EOL

cat <<EOL > lib/core/services/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:$projectName/core/notifications/notification_service.dart';
import 'package:$projectName/core/notifications/push_notification.dart';
import 'package:$projectName/core/storage/hive/hive_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => LocalNotificationService());
  sl.registerLazySingleton(() => PushNotificationService());

  // Hive initialization
  final hiveService = HiveService();
  await hiveService.init();
  sl.registerLazySingleton(() => hiveService);

  // TODO: Add other services and dependencies here
}

EOL
EOL

cat <<EOL > lib/core/storage/hive/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  HiveService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here
  }

  Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  Future<void> closeBox(String boxName) async {
    await Hive.box(boxName).close();
  }

  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk(boxName);
  }
}
EOL

cat <<EOL > lib/core/usecases/usecase.dart
import 'package:$projectName/core/utils/typedef.dart';

abstract class UsecaseWithParams<Type, Params> {
  const UsecaseWithParams();
  ResultFuture<Type> call(Params params);
}

abstract class UsecaseWithoutParams<Type> {
  const UsecaseWithoutParams();
  ResultFuture<Type> call();
}
EOL

cat <<EOL > lib/core/utils/typedef.dart
import 'package:$projectName/core/error/failures.dart';
import 'package:dartz/dartz.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = ResultFuture<void>;
typedef DataMap = Map<String, dynamic>;
EOL





cat <<'EOL' > lib/core/utils/string_extension.dart
import 'dart:convert';

extension StringExtension on String? {
  String get nullToEmpty => this ?? '';

  String? get emptyToNull => this?.trim() == '' ? null : this;

  String get capitalize {
    if (this == null) return '';
    return this![0].toUpperCase() + this!.substring(1);
  }

  bool get isEmptyOrNull {
    if (this == null) return true;
    if (this!.isEmpty) return true;
    return false;
  }

  String get capitalizeAllFirst {
    if (this == null) return '';
    List<String> words = this!.split(" ");
    return words.map((e) => e.capitalize).join(" ");
  }

  String pluralize([num? number]) {
    if (this == null) return '';
    if ((number ?? 1) > 1) return '${this!}s';
    return this!;
  }

  List<T> parseJsonList<T extends JsonConvertible<T>>(T Function(Map<String, dynamic>) fromJsonFactory) {
    if (this == null) {
      return [];
    }

    final parsed = json.decode(this!).cast<Map<String, dynamic>>();
    return parsed.map<T>((json) => fromJsonFactory(json)).toList();
  }
}

abstract class JsonConvertible<T> {
  T fromJson(Map<String, dynamic> json);
}
EOL


cat <<'EOL' > lib/core/utils/image_util.dart
import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageUtils {
  static const defaultImage =
      "https://fieldmaxpro.s3-us-west-2.amazonaws.com/fmp_10002/contacts/07-2023/5hOvf0qWFn31hldTZ8SLVoQo8EqXhsT4lj3.jpg";

  static String fileName(String filePath) => filePath.split('/').last;

  static const List<String> allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
  ];

  static Future<String> localFileToBase64(File file) async {
    Uint8List imageBytes = await file.readAsBytes();
    String base64string = base64.encode(imageBytes);
    return base64string;
  }

  static Future<String> assetFileToBase64(String assetPath) async {
    ByteData bytes = await rootBundle.load(assetPath);
    var buffer = bytes.buffer;
    var base64String = base64.encode(Uint8List.view(buffer));
    return base64String;
  }

  static Uint8List memoryImageFromBase64(String base64Image) =>
      const Base64Decoder().convert(base64Image);

  // use with Image.network widget
  static dynamic decodeBase64(String encoded) {
    String decoded = utf8.decode(base64Url.decode(encoded));
    return decoded;
  }

  // Throws exception
  static Future<File?> pickImage([int quality = 50]) async {
    ImageSource source = kDebugMode ? ImageSource.gallery : ImageSource.camera;
    XFile? file = await ImagePicker().pickImage(
      source: source,
      imageQuality: quality,
    );

    if (file == null) return null;

    /// Check file uses allowed file extensions
    bool hasAllowedExtension = false;
    for (final extension in allowedExtensions) {
      if (file.path.toLowerCase().endsWith(extension)) {
        hasAllowedExtension = true;
      }
    }

    if (hasAllowedExtension) {
      return File(file.path);
    } else {
      throw "Only ${allowedExtensions.toString().replaceAll("[", "").replaceAll("]", "")} files are allowed";
    }
  }

  static const imgPermissions = [Permission.camera, Permission.storage];
  static Future<bool> requestImagePermissions() async {
    bool success = false;
    try {
      final status = await imgPermissions.request();
      for (final status in status.values) {
        success = status == PermissionStatus.limited ||
            status == PermissionStatus.granted;
      }
    } catch (_) {
      log("Image Utils: Image Permissions Request failed");
    }
    return success;
  }
}
EOL


cat <<EOL > lib/core/utils/logger_util.dart
import 'package:flutter/foundation.dart';

class Logger {
  static final Logger _instance = Logger._internal();
  Logger._internal();
  static Logger get instance => _instance;

  bool showLog = kDebugMode;

  void call(dynamic data1, [dynamic data2]) {
    if (showLog) {
      if (data2 != null) {
        print("$data1 : $data2");
      } else {
        printWrapped("$data1");
      }
    }
  }

  void error(dynamic data) => printWrapped("🔴 $data");
  void success(dynamic data) => printWrapped("🔴 $data");
  void info(dynamic data) => printWrapped("🔴 $data");
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

void printDioLogs(Object object) {
  printWrapped(object.toString());
}
EOL



cat <<EOL > lib/core/utils/url_launch_services.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class AppInterfaceService {
  static Future<void> _launchURL(String url) async => await launchUrl(Uri.parse(url));

  static Future<void> mailTo(String? emailAddress, {String subject = ''}) async {
    if (emailAddress == null) return;
    try {
      final uri = 'mailto:$emailAddress?subject=$subject';
      return await _launchURL(uri);
    } catch (_) {
      throw 'Could not launch email app';
    }
  }

  static Future<void> phoneCall(String? phone) async {
    if (phone == null) return;
    try {
      final uri = 'tel:$phone';
      return await _launchURL(uri);
    } catch (_) {
      throw 'Could not launch phone app';
    }
  }

  static Future<void> launchLink(String? link) async {
    if (link == null) return;
    try {
      final uri = link;
      return await _launchURL(uri);
    } catch (_) {
      throw 'Could not launch link';
    }
  }

  static void copyToClipboard(String val) => Clipboard.setData(ClipboardData(text: val));
}
EOL


#!/bin/bash


# Create network directories and files

# Add content to api_error.dart
cat <<'EOL'> lib/core/network/api_error.dart
part of 'network.dart';

class ApiError implements Exception {
  final String errorDescription;
  final dynamic data;
  final DioExceptionType? dioErrorType;
  final int? statusCode;
  static const unknownError = 'Something went wrong, please try again';
  static const internetError = 'Internet connection error, please try again';
  static const cancelError = 'API request canceled, please try again';
  static const internetError2 = 'Please check your internet connection, seems you are offline';

  ApiError({
    required this.errorDescription,
    this.data,
    this.dioErrorType,
    this.statusCode,
  });

  factory ApiError.fromDioError(DioException error) {
    try {
      String description = '';
      switch (error.type) {
        case DioExceptionType.badCertificate:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          description = unknownError;
          break;
        case DioExceptionType.badResponse:
          description = extractDescriptionFromResponse(error.response);
          break;
        case DioExceptionType.cancel:
          description = cancelError;
          break;
        case DioExceptionType.unknown:
        case DioExceptionType.connectionError:
          description = unknownError;
          if (error.error is SocketException) {
            description = internetError;
          } else {
            description = unknownError;
          }
          break;
      }
      return ApiError(
        errorDescription: description,
        dioErrorType: error.type,
        data: error.response?.data != null ? error.response?.data['detail'] : null,
        statusCode: error.response?.statusCode,
      );
    } catch (_) {
      throw unknownError;
    }
  }

  static String extractDescriptionFromResponse(Response? response) {
    try {
      if (response!.statusCode! >= 500) {
        return 'Internal Server error, please try again later';
      }
      if (response.data != null && response.data['detail'][0]["msg"] != null) {
        return response.data['detail'][0]["msg"] as String;
      } else {
        return response.statusMessage ?? '';
      }
    } catch (error) {
      throw unknownError;
    }
  }

  @override
  String toString() => errorDescription;
}

EOL

# Add content to api_interceptor.dart
cat <<'EOL' > lib/core/network/api_interceptor.dart
part of 'network.dart';

class ApiInterceptor extends Interceptor {
  factory ApiInterceptor() => _instance;
  static final ApiInterceptor _instance = ApiInterceptor._internal();

  ApiInterceptor._internal();

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
 

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
   
    handler.next(err);
  }
}

EOL

# Add content to error_interceptor.dart
cat <<EOL > lib/core/network/error_interceptor.dart
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode;
    final isValid = status != null && status >= 200 && status < 300;
    if (!isValid) {
      throw DioException.badResponse(
        statusCode: status!,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    super.onResponse(response, handler);
  }
}

EOL

# Add content to network_provider.dart
cat <<'EOL' > lib/core/network/network_provider.dart
part of 'network.dart';

class Network {
  static const connectTimeOut = Duration(seconds: 120);
  static const receiverTimeOut = Duration(seconds: 120);
  late Dio dio;
  late bool showLog;

  final _dioBaseOptions = BaseOptions(
    connectTimeout: connectTimeOut,
    receiveTimeout: receiverTimeOut,
    baseUrl: UrlConfig.baseUrl,
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  );

  Network({String? baseUrl, this.showLog = false}) {
    dio = Dio();
    dio.interceptors.add(ApiInterceptor());
    dio.interceptors.add(ErrorInterceptor());

    dio.options = _dioBaseOptions;
    if (baseUrl != null) dio.options.baseUrl = baseUrl;
    if (showLog) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
        ),
      );
    }
  }

  Network.noInterceptor([String? baseUrl]) {
    dio = Dio();
    if (baseUrl != null) dio.options.baseUrl = baseUrl;
    dio.options = _dioBaseOptions;
  }

  /// Factory constructor used mainly for injecting an instance of [Dio] mock
  Network.test(this.dio);

  Future<Response> call(
    String path,
    RequestMethod method, {
    Map<String, dynamic>? queryParams,
    data,
    FormData? formData,
    ResponseType responseType = ResponseType.json,
    String classTag = '',
    bool showLog = false,
    bool useUrlEncoded = false,
  }) async {
    Response? response;
    var params = queryParams ?? {};
    final headerOverride = useUrlEncoded
        ? {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          }
        : null;

    try {
      switch (method) {
        case RequestMethod.post:
          response = await dio.post(
            path,
            queryParameters: params,
            data: data ?? formData,
            options: Options(
              responseType: responseType,
              headers: headerOverride,
            ),
          );
          break;
        case RequestMethod.get:
          response = await dio.get(path, queryParameters: params);
          break;
        case RequestMethod.put:
          response = await dio.put(path, queryParameters: params, data: data);
          break;
        case RequestMethod.patch:
          response = await dio.patch(path, queryParameters: params, data: data);
          break;
        case RequestMethod.delete:
          response = await dio.delete(
            path,
            queryParameters: params,
            data: data,
          );
          break;
        case RequestMethod.upload:
          response = await dio.post(
            path,
            data: formData,
            queryParameters: params,
            options: Options(headers: {
              "Content-Disposition": "form-data",
              "Content-Type": "multipart/form-data",
            }),
            onSendProgress: (sent, total) {
              // eventBus.fire(FileTransferProgressEvent(sent, total, classTag));
            },
          );
          break;
      }
      // if (showLog) devLog("$path API response: $response");
      return response;
    } on DioException catch (error, stackTrace) {
      final apiError = ApiError.fromDioError(error);
      if (showLog) {
        // devLog("$path: ${error.response?.statusCode} code");
        // devLog("API response: ${error.response}");
      }
      return Future.error(apiError, stackTrace);
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> getResponseType(String url) async {
    try {
      final res = await Dio().get(url);
      return res.headers.value("Content-Type");
    } catch (_) {}
    return null;
  }

  Future<File> downloadFile({
    required String url,
    required String savePath,
  }) async {
    try {
      Response response = await Dio().get(
        url,
        onReceiveProgress: (received, total) {
          // eventBus.fire(FileTransferProgressEvent(received, total, savePath));
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return file;
    } catch (e) {
      rethrow;
    }
  }
}

enum RequestMethod { post, get, put, delete, upload, patch }

EOL

# Add content to network.dart
cat <<EOL > lib/core/network/network.dart
library network;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:io';

import 'package:$projectName/core/network/error_interceptor.dart';
import 'package:$projectName/core/network/url_config.dart';

part 'api_error.dart';
part 'api_interceptor.dart';
part 'network_provider.dart';

EOL

# Add content to url_config.dart
cat <<EOL > lib/core/network/url_config.dart
enum UrlEnvironment { development, production }

class UrlConfig {
  static UrlEnvironment _environment = UrlEnvironment.development;
  static UrlEnvironment get environment => _environment;
  static void setEnvironment(UrlEnvironment env) => _environment = env;

  static String get baseUrl => "$_baseUrl/api/v1/";

  static get _baseUrl {
    switch (_environment) {
      case UrlEnvironment.development:
        return 'https://dev.example.com';
      case UrlEnvironment.production:
        return 'https://prod.example.com';
    }
  }
}

EOL

# Content for string_extensions.dart
cat <<'EOL' > lib/core/extensions/string_extensions.dart
import 'dart:convert';

extension StringExtension on String? {
  String get nullToEmpty => this ?? '';

  String? get emptyToNull => this?.trim() == '' ? null : this;

  String get capitalize {
    if (this == null) return '';
    return this![0].toUpperCase() + this!.substring(1);
  }

  bool get isEmptyOrNull {
    if (this == null) return true;
    if (this!.isEmpty) return true;
    return false;
  }

  String get capitalizeAllFirst {
    if (this == null) return '';
    List<String> words = this!.split(" ");
    return words.map((e) => e.capitalize).join(" ");
  }

  String pluralize([num? number]) {
    if (this == null) return '';
    if ((number ?? 1) > 1) return '${this!}s';
    return this!;
  }

  List<T> parseJsonList<T extends JsonConvertible<T>>(
      T Function(Map<String, dynamic>) fromJsonFactory) {
    if (this == null) {
      return [];
    }

    final parsed = json.decode(this!).cast<Map<String, dynamic>>();
    return parsed.map<T>((json) => fromJsonFactory(json)).toList();
  }
}

abstract class JsonConvertible<T> {
  T fromJson(Map<String, dynamic> json);
}
EOL



# Content for custom_button.dart
cat <<EOL > lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
EOL

# Content for custom_text_field.dart
cat <<EOL > lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}
EOL

# Content for context_extensions.dart
cat <<EOL > lib/core/extensions/context_extensions.dart
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Access the screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  // Access the screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  // Access the primary color from the theme
  Color get primaryColor => Theme.of(this).primaryColor;

  // Access the text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Show a snackbar
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

}

EOL

# Content for widget_extensions.dart
cat <<EOL > lib/core/extensions/widget_extensions.dart
import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  // Adds padding to a widget
  Widget withPadding([EdgeInsetsGeometry padding = const EdgeInsets.all(8.0)]) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  // Adds margin to a widget
  Widget withMargin([EdgeInsetsGeometry margin = const EdgeInsets.all(8.0)]) {
    return Container(
      margin: margin,
      child: this,
    );
  }

  // Sets the visibility of a widget
  Widget withVisibility(bool isVisible) {
    return Visibility(
      visible: isVisible,
      child: this,
    );
  }

  // Adds a tap gesture to a widget
  Widget withOnTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}

EOL

cat <<EOL > lib/core/theme/theme.dart
library theme;

import 'package:flutter/material.dart';

part 'colors.dart';
part 'text_styles.dart';
part 'app_colors.dart';

ThemeData get appTheme => _buildLightTheme();

ThemeData _buildLightTheme() {
  const Color primaryColor = _Colors.primaryColor;
  const Color secondaryColor = _Colors.secondaryColor;

  final ColorScheme colorScheme = const ColorScheme.light().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
    error: _Colors.red,
  );

  final themeData = ThemeData(
    useMaterial3: false,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: _Colors.scaffoldColor,
    cardColor: _Colors.white,
    colorScheme: colorScheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: _Colors.scaffoldColor,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: _Colors.black,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      contentTextStyle: _AppTextStyles.bodyMedium,
      insetPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: _Colors.primaryColor,
        textStyle: _AppTextStyles.displayMedium.copyWith(color: _Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: _AppTextStyles.displayMedium.copyWith(
          color: _Colors.primaryColor,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: _Colors.white,
        foregroundColor: _Colors.primaryColor,
        side: BorderSide.none,
        textStyle: _AppTextStyles.displayMedium.copyWith(
          color: _Colors.primaryColor,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _Colors.greyOutline),
      ),
      isDense: true,
      filled: true,
      fillColor: _Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: _AppTextStyles.bodyLarge,
      bodyMedium: _AppTextStyles.bodyMedium, // default text styling
      bodySmall: _AppTextStyles.bodySmall,
      displayLarge: _AppTextStyles.displayLarge,
      displayMedium: _AppTextStyles.displayMedium,
      titleLarge: _AppTextStyles.titleLarge,
      titleMedium: _AppTextStyles.titleMedium,
      titleSmall: _AppTextStyles.titleSmall,
      labelSmall: _AppTextStyles.labelSmall,
    ),
    extensions: [
      AppColorExtension(
        green: _Colors.green,
        white: _Colors.white,
        red: _Colors.red,
        orange: _Colors.orange,
        captionGrey: _Colors.captionColor,
        black: _Colors.black,
        borderGrey: _Colors.greyLight,
        blueDecor: _Colors.blueDecor,
        greenDecor: _Colors.greenDecor,
        greyDecor: _Colors.greyDecor,
        orangeDecor: _Colors.orangeDecor,
        pinkDecor: _Colors.pinkDecor,
        purpleDecor: _Colors.purpleDecor,
        blueDecorDark: _Colors.blueDecorDark,
        greenDecorDark: _Colors.greenDecorDark,
        greyDecorDark: _Colors.greyDecorDark,
        orangeDecorDark: _Colors.orangeDecorDark,
        pinkDecorDark: _Colors.pinkDecorDark,
        purpleDecorDark: _Colors.purpleDecorDark,
        greyOutline: _Colors.greyOutline,
      ),
    ],
  );
  return themeData;
}
EOL


cat <<EOL > lib/core/theme/text_styles.dart
part of 'theme.dart';

/// Style plan
/// body - 11,13,15 - w300
/// title - 11,13,15 - w500
/// display - 18, 22 - w500
class _AppTextStyles {
  static const bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w300,
    color: _Colors.black,
  );
  static const bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w300,
    color: _Colors.black,
  );
  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w300,
    color: _Colors.black,
  );

  static const titleSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _Colors.black,
  );
  static const titleMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: _Colors.black,
  );
  static const titleLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: _Colors.black,
  );


  static const displayMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: _Colors.primaryColor,
  );

  static const displayLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: _Colors.primaryColor,
  );

  static const labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: _Colors.black,
  );

}
EOL
cat <<EOL > lib/core/theme/colors.dart
part of 'theme.dart';

class _Colors {
  static const primaryColor = Color(0xff249689);

  static const secondaryColor = Color(0xff249689);
  static const scaffoldColor = Color(0xffFAFAFA);

  static const captionColor = Color(0xff80848B);
  static const greyLight = Color(0xffF4F4F5);
  static const greyOutline = Color(0xffE4E4E7);

  // Decor colors
  static const greenDecor = Color(0xffE3FBCC);
  static const blueDecor = Color(0xffE0EAFF);
  static const orangeDecor = Color(0xffFFEDD4);
  static const purpleDecor = Color(0xffEBE9FE);
  static const pinkDecor = Color(0xffFAE9F5);
  static const greyDecor = Color(0xffEAECF5);

  static const greenDecorDark = Color(0xff2B5314);
  static const blueDecorDark = Color(0xff2D3282);
  static const orangeDecorDark = Color(0xff7E2D10);
  static const purpleDecorDark = Color(0xff3E1C96);
  static const pinkDecorDark = Color(0xff7B2050);
  static const greyDecorDark = Color(0xff101323);

  // Miscellaneous
  static const white = Colors.white;
  static const black = Colors.black;
  static const red = Colors.red;
  static const green = Colors.green;
  static const orange = Colors.orange;
}
EOL
cat <<EOL > lib/core/theme/app_colors.dart
part of 'theme.dart';

class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final Color red;
  final Color green;
  final Color orange;
  final Color white;
  final Color captionGrey;
  final Color black;
  final Color borderGrey;

  // decor colors
  final Color greenDecor;
  final Color blueDecor;
  final Color orangeDecor;
  final Color purpleDecor;
  final Color pinkDecor;
  final Color greyDecor;
  final Color greyOutline;

  // decor colors Dark
  final Color greenDecorDark;
  final Color blueDecorDark;
  final Color orangeDecorDark;
  final Color purpleDecorDark;
  final Color pinkDecorDark;
  final Color greyDecorDark;

  AppColorExtension({
    required this.green,
    required this.white,
    required this.orange,
    required this.red,
    required this.captionGrey,
    required this.black,
    required this.borderGrey,
    required this.greenDecor,
    required this.blueDecor,
    required this.orangeDecor,
    required this.purpleDecor,
    required this.pinkDecor,
    required this.greyDecor,
    required this.greenDecorDark,
    required this.blueDecorDark,
    required this.orangeDecorDark,
    required this.purpleDecorDark,
    required this.pinkDecorDark,
    required this.greyDecorDark,
    required this.greyOutline,
  });

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? green,
    Color? red,
    Color? white,
    Color? orange,
    Color? captionGrey,
    Color? black,
    Color? borderGrey,
    Color? greenDecor,
    Color? blueDecor,
    Color? orangeDecor,
    Color? purpleDecor,
    Color? pinkDecor,
    Color? greyDecor,
    Color? greenDecorDark,
    Color? blueDecorDark,
    Color? orangeDecorDark,
    Color? purpleDecorDark,
    Color? pinkDecorDark,
    Color? greyDecorDark,
    Color? greyOutline,
  }) {
    return AppColorExtension(
      green: green ?? this.green,
      white: white ?? this.white,
      red: red ?? this.red,
      orange: orange ?? this.orange,
      captionGrey: captionGrey ?? this.captionGrey,
      black: black ?? this.black,
      borderGrey: borderGrey ?? this.borderGrey,
      greenDecor: greenDecor ?? this.greenDecor,
      blueDecor: blueDecor ?? this.blueDecor,
      orangeDecor: orangeDecor ?? this.orangeDecor,
      purpleDecor: purpleDecor ?? this.purpleDecor,
      pinkDecor: pinkDecor ?? this.pinkDecor,
      greyDecor: greyDecor ?? this.greyDecor,
      greenDecorDark: greenDecorDark ?? this.greenDecorDark,
      blueDecorDark: blueDecorDark ?? this.blueDecorDark,
      orangeDecorDark: orangeDecorDark ?? this.orangeDecorDark,
      purpleDecorDark: purpleDecorDark ?? this.purpleDecorDark,
      pinkDecorDark: pinkDecorDark ?? this.pinkDecorDark,
      greyDecorDark: greyDecorDark ?? this.greyDecorDark,
      greyOutline: greyOutline ?? this.greyOutline,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
          covariant ThemeExtension<AppColorExtension>? other, double t) =>
      this;
}
EOL



# Add content to push_notification.dart
cat <<EOL > lib/core/notifications/push_notification.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:$projectName/core/notifications/notification_service.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _fcm.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap event
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    // Handle background notification
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  void subscribeToTopic(String topic) {
    _fcm.subscribeToTopic(topic);
  }

  void unsubscribeFromTopic(String topic) {
    _fcm.unsubscribeFromTopic(topic);
  }
}

EOL


# Add content to notification_service.dart
cat <<EOL > lib/core/notifications/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle notification tap event
      },
    );
  }

  static Future<void> display(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}

EOL




cat <<EOL > lib/core/transitions/custom_slide_transition.dart
import 'package:flutter/material.dart';

class CustomSlideTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
EOL

cat <<EOL > lib/core/transitions/custom_scale_transition.dart
import 'package:flutter/material.dart';

class CustomScaleTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(animation),
      child: child,
    );
  }
}
EOL

cat <<EOL > lib/core/transitions/custom_rotation_transition.dart
import 'package:flutter/material.dart';

class CustomRotationTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(animation),
      child: child,
    );
  }
}
EOL

cat <<EOL > lib/core/transitions/custom_size_transition.dart
import 'package:flutter/material.dart';

class CustomSizeTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: child,
    );
  }
}
EOL

cat <<EOL > lib/core/transitions/custom_fade_slide_transition.dart
import 'package:flutter/material.dart';

class CustomFadeSlideTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
EOL



# Create routes.dart file
cat <<EOL > lib/core/routes/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String home = '/';

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: home,
        builder: (context, state) => Container(), // Placeholder for home screen
      ),
    ],
  );
}
EOL

cat <<EOL > lib/core/routes/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define route constants
class Routes {
  static const String home = '/';
  static const String chat = '/chat';
  static const String settings = '/settings';
  static const String termsOfService = 'terms-of-services';

  // Navigator keys for nested navigation
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => Placeholder(),
        routes: [
          GoRoute(
            path: home,
            parentNavigatorKey: shellNavigatorKey,
            builder: (context, state) => Placeholder(), // Replace with actual screen widget
          ),
          GoRoute(
            path: chat,
            parentNavigatorKey: shellNavigatorKey,
            builder: (context, state) => Placeholder(), // Replace with actual screen widget
          ),
          GoRoute(
            path: settings,
            parentNavigatorKey: shellNavigatorKey,
            builder: (context, state) => Placeholder(), // Replace with actual screen widget
            routes: [
              GoRoute(
                path: termsOfService,
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => Placeholder(), // Replace with actual screen widget
              ),
            ],
          ),
        ],
      ),
    ],
  );
}



EOL

cat <<EOL > application/.env
# Add your environment variables here

EOL


cat <<EOL > lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:$projectName/core/routes/routes.dart';
import 'package:$projectName/core/services/injection_container.dart' as di;
import 'package:$projectName/core/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(
      fileName:
          'application/.env'); // Load environment variables from application folder
  await di.init(); // Initialize dependency injection
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '$projectName',
      theme: appTheme,
      routerConfig: Routes.router,
    );
  }
}
EOL

cat <<EOL > .gitignore
# Flutter/Dart/Pub related
.dart_tool/
.packages
.pub/
build/
flutter_*.png

# Visual Studio Code
.vscode/

# IntelliJ
.idea/
*.iml

# Android Studio
*.jks
*.keystore

# iOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/App.framework

# Generated files
*.flutter-plugins
*.flutter-plugins-dependencies
*.flutter-plugins-dependencies
*.flutter-plugins
*.flutter-plugins-dependencies
*.dart_tool/
.packages
.pub-cache/
.pub/
.buildlog
.lock
.dart_tool/
.packages

# Environment variable files
application/.env
application/.env.*
EOL



echo "Notifications setup completed for Flutter project: $projectName"
