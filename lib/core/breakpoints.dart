/// Batas lebar layar untuk layout responsif.
///
/// compact : lebar < 600   (ponsel)
/// medium  : 600 - 999     (tablet / jendela sedang)
/// wide    : lebar >= 1000 (tablet landscape / desktop / web)
class Breakpoints {
  Breakpoints._();

  static const double compact = 600;
  static const double wide = 1000;

  /// True untuk layar selain compact (medium dan wide).
  static bool isExpanded(double width) => width >= compact;

  /// Jumlah kolom grid menurut lebar yang tersedia.
  static int gridColumns(double width) {
    if (width >= wide) return 4;
    if (width >= compact) return 3;
    return 2;
  }
}
