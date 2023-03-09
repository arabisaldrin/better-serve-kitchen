import 'package:better_serve_lib/model/order.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constant.dart';

class OrderService with ChangeNotifier {
  List<Order> orders = List.empty(growable: true);
  bool loadingOrders = true;

  String orderSelect =
      """*,order_items(*,product:product_id(*, category:category_id(*),
          variation:variation_id(*,options:product_variation_options(*)),
          attributes:product_attributes(*,options:product_attribute_options(*))),
          order_item_attributes(*),order_item_addons(*,addon:addon_id(*))),
          coupon:coupon_id(*)
""";

  OrderService() {
    loadOrders();
  }

  RealtimeSubscription subscribeToStatusChange() {
    return supabase.from("orders").on(SupabaseEventTypes.update, (x) async {
      if (x.newRecord != null) {
        if (x.newRecord!["status"] == 1) {
          PostgrestResponse res = await supabase
              .from("orders")
              .select(orderSelect)
              .eq("id", x.newRecord!["id"])
              .limit(1)
              .single()
              .execute();
          if (res.hasError) {
            return;
          }
          Order order = Order.fromJson(res.data);
          orders.add(order);
        }
        notifyListeners();
      }
    }).subscribe();
  }

  Future<void> loadOrders() async {
    PostgrestResponse res = await supabase
        .from("orders")
        .select(orderSelect)
        .in_("status", [
      OrderStatus.pending.ordinal,
      OrderStatus.processing.ordinal
    ]).execute();
    orders.clear();
    orders.addAll((res.data as List<dynamic>).map((e) => Order.fromJson(e)));

    loadingOrders = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(Order order, OrderStatus status,
      [bool remove = false]) async {
    await supabase
        .from("orders")
        .update({"status": status.ordinal})
        .eq("id", order.id)
        .execute();

    if (remove) {
      int index = orders.indexWhere((e) => e.id == order.id);
      orders.removeAt(index);
    }

    notifyListeners();
  }
}
