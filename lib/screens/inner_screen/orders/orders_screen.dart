import 'package:flutter/material.dart';
import '../../../../widgets/empty_bag.dart';
import '../../../services/assets_manager.dart';
import '../../../widgets/title_text.dart';
import 'orders_widget.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/OrderScreen';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isEmptyOrders = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const TitlesTextWidget(
            label: 'Placed orders',
          ),
        ),
        body: isEmptyOrders
            ? EmptyBagWidget(
                imagePath: AssetsManager.order,
                title: "No orders has been placed yet",
                subtitle: "",
              )
            : ListView.separated(
                itemCount: 15,
                itemBuilder: (ctx, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    child: OrdersWidgetFree(),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                      // thickness: 8,
                      // color: Colors.red,
                      );
                },
              ));
  }
}
