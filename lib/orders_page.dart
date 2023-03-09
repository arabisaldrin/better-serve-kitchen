import 'package:better_serve_kitchen/constant.dart';
import 'package:better_serve_kitchen/settings.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show RealtimeSubscription;

import 'components/order_card.dart';
import 'order_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({
    Key? key,
  }) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late RealtimeSubscription statusSubscription;

  late SettingsService settings;

  @override
  void initState() {
    OrderService service = Provider.of<OrderService>(context, listen: false);
    statusSubscription = service.subscribeToStatusChange();
    settings = Provider.of<SettingsService>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    statusSubscription.subscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderService>(builder: (context, orderService, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "(${orderService.orders.length}) Orders",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      splashRadius: 20,
                      onPressed: () {
                        settings.toggleDarkMode(context);
                      },
                      icon: context.isDarkMode
                          ? const Icon(Icons.light_mode)
                          : const Icon(Icons.dark_mode))
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: orderService.loadingOrders
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : orderService.orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.format_list_numbered_sharp,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                                Text(
                                  "No ongoing orders right now",
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : GridView.count(
                            childAspectRatio: 1.7,
                            crossAxisCount: 3,
                            // crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (Order order in orderService.orders)
                                OrderCard(order: order)
                            ],
                          ),
              ),
            ),
          )
        ],
      );
    });
  }
}
