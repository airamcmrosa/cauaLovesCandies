import 'package:flame/palette.dart';

/// A palette of colors to be used in the game.
///
/// The reason we're not going with something like Material Design's
/// `Theme` is simply that this is simpler to work with and yet gives
/// us everything we need for a game.
///
/// Games generally have more radical color palettes than apps. For example,
/// every level of a game can have radically different colors.
/// At the same time, games rarely support dark mode.
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.
class Palette {
  // Screen roles. Names are kept stable; values follow the Candy Pastel
  // palette documented in docs/product/design/color-palette.md.
  PaletteEntry get seed => brandBubblegum;
  PaletteEntry get text => ink;
  PaletteEntry get backgroundMain => bgCream;
  PaletteEntry get backgroundLevelSelection => bgCotton;
  PaletteEntry get backgroundPlaySession => bgSky;
  PaletteEntry get backgroundSettings => bgLavender;

  // Backgrounds and surfaces.
  PaletteEntry get bgCream => const PaletteEntry(Color(0xFFFFF5E6));
  PaletteEntry get bgSky => const PaletteEntry(Color(0xFFCDEBFF));
  PaletteEntry get bgCotton => const PaletteEntry(Color(0xFFFFD6E8));
  PaletteEntry get bgLavender => const PaletteEntry(Color(0xFFE6D9FF));

  // Brand and UI accents.
  PaletteEntry get brandBubblegum => const PaletteEntry(Color(0xFFFF8FC0));
  PaletteEntry get brandBubblegumDark => const PaletteEntry(Color(0xFFE5609D));
  PaletteEntry get accentLemon => const PaletteEntry(Color(0xFFFFE98A));
  PaletteEntry get accentSky => const PaletteEntry(Color(0xFF7CC8FF));
  PaletteEntry get accentGrape => const PaletteEntry(Color(0xFFB79CFF));
  PaletteEntry get accentMint => const PaletteEntry(Color(0xFFA8F0D1));
  PaletteEntry get accentTangerine => const PaletteEntry(Color(0xFFFFB36B));

  // Gameplay.
  PaletteEntry get beltBase => const PaletteEntry(Color(0xFFBFA6EC));
  PaletteEntry get beltStripe => const PaletteEntry(Color(0xFF8F72D6));
  PaletteEntry get heart => const PaletteEntry(Color(0xFFFF5C7A));
  PaletteEntry get dangerSoft => const PaletteEntry(Color(0xFFFF7A7A));
  PaletteEntry get shadow => const PaletteEntry(Color(0xFFC9B6F2));

  // Tutorial feedback symbols. The check sits on an accentMint circle and the
  // cross (bgCream) sits on a dangerSoft circle.
  PaletteEntry get tutorialCheck => const PaletteEntry(Color(0xFF2E9E6B));
  PaletteEntry get tutorialCheckCircle => accentMint;
  PaletteEntry get tutorialCross => bgCream;
  PaletteEntry get tutorialCrossCircle => dangerSoft;

  // Text and outlines.
  PaletteEntry get ink => const PaletteEntry(Color(0xFF5B3A6B));
  PaletteEntry get inkSoft => const PaletteEntry(Color(0xFF8A6A9B));
}
