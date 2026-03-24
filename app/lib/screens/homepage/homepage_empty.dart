import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_vectorial_images.dart';
import 'package:formation_flutter/widget/custom_button.dart';

class HomePageEmpty extends StatelessWidget {
  const HomePageEmpty({super.key, this.onScan});

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Spacer(flex: 20),
          SvgPicture.asset(AppVectorialImages.illEmpty),
          Spacer(flex: 10),
          Expanded(
            flex: 20,
            child: Column(
              children: <Widget>[
                SizedBox(
                  width:
                      173, // Force le texte à s'afficher sur deux lignes comme sur la maquette
                  child: Text(
                    localizations.my_scans_screen_description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF080040),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.41,
                    ),
                  ),
                ),
                Spacer(flex: 5),
                CustomButton(
                  text: localizations.my_scans_screen_button,
                  onPressed: onScan ?? () {},
                ),
              ],
            ),
          ),
          Spacer(flex: 20),
        ],
      ),
    );
  }
}
