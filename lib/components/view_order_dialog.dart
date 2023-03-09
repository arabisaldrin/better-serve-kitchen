import 'dart:io';

import 'package:better_serve_kitchen/constant.dart';
import 'package:better_serve_kitchen/order_service.dart';
import 'package:better_serve_lib/components/dialog_pane.dart';
import 'package:better_serve_lib/model/order.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class ViewOrderDialog extends StatefulWidget {
  final Order order;
  const ViewOrderDialog({required this.order, super.key});

  @override
  State<ViewOrderDialog> createState() => _ViewOrderDialogState();
}

class _ViewOrderDialogState extends State<ViewOrderDialog> {
  late OrderService orderService;
  @override
  void initState() {
    orderService = Provider.of<OrderService>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Order order = widget.order;
    return DialogPane(
      tag: "order_${order.id}",
      width: 500,
      maxHeight: 500,
      builder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "#${order.queueNumber}",
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const Expanded(child: SizedBox()),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 3, horizontal: 10),
                      decoration: BoxDecoration(
                          color: orderStatusColor[order.status],
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        order.statusName,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  // IconButton(
                  //     padding: const EdgeInsets.all(5),
                  //     constraints: const BoxConstraints(),
                  //     splashRadius: 20,
                  //     onPressed: () {

                  //     },
                  //     icon: const Icon(Icons.push_pin))
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (OrderItem item in order.items) ...[
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: CachedNetworkImage(
                              imageUrl: publicPath(item.productImg),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Builder(
                                builder: (context) {
                                  String str = "${item.quantity}x";
                                  if (item.variationValue != null) {
                                    str += " ${item.variationValue}";
                                  }
                                  str += " ${item.productName}";
                                  if (item.addons.isNotEmpty) {
                                    str += " with ";
                                    for (var i = 0;
                                        i < item.addons.length;
                                        i++) {
                                      OrderItemAddon addon = item.addons[i];
                                      int len = item.addons.length;
                                      str +=
                                          "${addon.name} ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                    }
                                  }
                                  return Text(
                                    str,
                                    style: const TextStyle(fontSize: 20),
                                  );
                                },
                              ),
                              if (item.attributes.isNotEmpty) ...[
                                for (OrderItemAttribute attr in item.attributes)
                                  Builder(
                                    builder: (context) {
                                      String str = "${attr.name} :";
                                      for (var i = 0;
                                          i < attr.values.length;
                                          i++) {
                                        String opt = attr.values[i];
                                        int len = attr.values.length;
                                        str +=
                                            "$opt ${i < len - 1 ? i == len - 2 ? 'and ' : ',' : ''}";
                                      }
                                      return Text(str);
                                    },
                                  ),
                              ],
                            ],
                          ),
                        )
                      ],
                    ),
                    if (order.items.indexOf(item) != order.items.length - 1)
                      const Divider()
                  ]
                ],
              ),
              const Divider(),
              SizedBox(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close")),
                    // Expanded(child: Container()),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          toggleLoadding();
                          if (order.status == OrderStatus.pending.ordinal) {
                            orderService
                                .updateOrderStatus(order, OrderStatus.processing)
                                .then((value) {
                              setState(() {
                                order.status = OrderStatus.processing.ordinal;
                                Navigator.of(context).pop();
                              });
                            });
                          } else {
                            orderService
                                .updateOrderStatus(order, OrderStatus.done, true)
                                .then((value) {
                              setState(() {
                                order.status = OrderStatus.processing.ordinal;
                                Navigator.of(context).pop();
                              });
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            order.isPending
                                ? const Icon(Icons.timelapse)
                                : const Icon(MdiIcons.check),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(order.isPending ? "Process" : "Done"),
                          ],
                        ))
                  ],
                ),
              ),
              if (Platform.isWindows)
                const SizedBox(
                  height: 5,
                ),
            ],
          ),
        );
      },
    );
  }
}
