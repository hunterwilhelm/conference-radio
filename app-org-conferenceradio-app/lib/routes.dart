enum Routes {
  languagePage,
  welcomeBeginPage,
  homePage,
  filterPage,
  bookmarksPage,
}

extension PathOnRoutesExtension on Routes {
  String get path => "/${toString()}";
}
