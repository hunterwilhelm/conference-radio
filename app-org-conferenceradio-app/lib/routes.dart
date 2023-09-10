enum Routes {
  welcomeLanguagePage,
  welcomeBeginPage,
  homePage,
  filterPage,
}

extension PathOnRoutesExtension on Routes {
  String get path => "/${toString()}";
}
