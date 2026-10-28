import 'package:flutter/material.dart';
import 'package:projeto_final_m02/view/history/history_page.dart';
import 'package:projeto_final_m02/view/home/home_page.dart';
import 'package:projeto_final_m02/view/login/login_page.dart';
import 'package:projeto_final_m02/view/service_report/service_report_page.dart';
import 'package:projeto_final_m02/view/splash/splash_page.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const serviceReport = '/service-report';
  static const history = '/history';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashPage(),
    login: (_) => const LoginPage(),
    home: (_) => const HomePage(),
    serviceReport: (_) => const ServiceReportPage(),
    history: (_) => const HistoryPage(),
  };
}
