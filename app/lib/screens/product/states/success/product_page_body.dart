import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/rappel_fetcher.dart';
import 'package:formation_flutter/screens/product/states/success/product_header.dart';
import 'package:formation_flutter/screens/product/states/success/recall_banner.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab0.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab1.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab2.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab3.dart';
import 'package:provider/provider.dart';

class ProductPageBody extends StatelessWidget {
  final int currentIndex;

  const ProductPageBody({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Provider<Product>(
      create: (_) =>
          (context.read<ProductFetcher>().state as ProductFetcherSuccess)
              .product,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                // En-tête produit (photo, nom, etc.)
                ProductPageHeader(),

                // 4️⃣ Bandeau de rappel — juste avant les scores
                SliverToBoxAdapter(
                  child: Consumer<RappelFetcher>(
                    builder: (_, fetcher, __) {
                      final state = fetcher.state;
                      if (state is RappelFetcherFound) {
                        return RecallBanner(rappel: state.rappel);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Corps (scores + onglets)
                SliverPadding(
                  padding: const EdgeInsetsDirectional.only(top: 10.0),
                  sliver: SliverFillRemaining(
                    fillOverscroll: true,
                    hasScrollBody: false,
                    child: _getBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    return Stack(
      children: <Widget>[
        Offstage(offstage: currentIndex != 0, child: ProductTab0()),
        Offstage(offstage: currentIndex != 1, child: ProductTab1()),
        Offstage(offstage: currentIndex != 2, child: ProductTab2()),
        Offstage(offstage: currentIndex != 3, child: ProductTab3()),
      ],
    );
  }
}
