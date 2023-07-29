class General {

  final String id;
  final String title;
  final String content;

  General({
    required this.id,
    required this.title,
    required this.content,
  });
}

class ProductCategories {

  final String id;
  final String name;

  ProductCategories({
    required this.id,
    required this.name,
  });
}

class Products {

  final String id;
  final String name;
  final String price;
  final String stock;
  final String sold;
  final String description;
  final String tags;
  final String categories;
  final String url;
  final String category;

  Products({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.sold,
    required this.description,
    required this.tags,
    required this.categories,
    required this.url,
    required this.category,
  });
}

class Transactions {

  final String id;
  final String transaction_code;
  final String users_id;
  final String address;
  final String total_price;
  final String shipping_price;
  final String status;
  final String payment;
  final String bukti_transfer;
  final String expired_time;
  final String created_at;

  Transactions({
    required this.id,
    required this.transaction_code,
    required this.users_id,
    required this.address,
    required this.total_price,
    required this.shipping_price,
    required this.status,
    required this.payment,
    required this.bukti_transfer,
    required this.expired_time,
    required this.created_at,
  });
}

class TransactionItems {

  final String id;
  final String users_id;
  final String products_id;
  final String quantity;
  final String transactions_id;
  final String transaction_code;
  final String product;
  final String price;
  final String stock;
  final String url;
  final String categories_id;
  final String category;

  TransactionItems({
    required this.id,
    required this.users_id,
    required this.products_id,
    required this.quantity,
    required this.transactions_id,
    required this.transaction_code,
    required this.product,
    required this.price,
    required this.stock,
    required this.url,
    required this.categories_id,
    required this.category,
  });
}

class Reports {

  final String tanggal;
  final String total_transaksi;
  final String total_omset;
  final String total_produk;

  Reports({
    required this.tanggal,
    required this.total_transaksi,
    required this.total_omset,
    required this.total_produk,
  });
}

class ContentUpdate {

  final String image;
  final String url;
  final String name;

  ContentUpdate({
    required this.image,
    required this.url,
    required this.name,
  });
}