//Evento
class Event {
  final String id;
  final String name;
  final String imageUrl;
  final String place;
  final DateTime startDate;
  final DateTime endDate;
  final List<OutFlow>? outFlows;
  final Map<String, double>? expenses;
  final bool paid;
  final String? observations;

  Event({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.place,
    required this.startDate,
    required this.endDate,
    required this.paid,
    this.outFlows,
    this.expenses,
    this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'place': place,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'paid': paid,
      if (outFlows != null) 'outFlows': outFlows!.map((outFlow) => outFlow.toMap()).toList(),
      if (expenses != null) 'expenses': expenses,
      if (observations != null) 'observations': observations,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      place: map['place'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      paid: map['paid'] as bool,
      outFlows: (map['outFlows'] as List<dynamic>?)?.map((outFlow) => OutFlow.fromMap(outFlow as Map<String, dynamic>, 'ID')).toList(),
      expenses: (map['expenses'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as double)),
      observations: map['observations'] as String?,
    );
  }
}

// Cliente
class Customer {
  final String id;
  final String name;
  final String? cpf;
  final String? contact;
  final String? phoneNumber;
  final String? address;
  final String? cep;
  final String? observations;
  final List<OutFlow> outFlows;

  Customer({
    required this.id,
    required this.name,
    this.cpf,
    this.contact,
    this.phoneNumber,
    this.address,
    this.cep,
    this.observations,
    required this.outFlows,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      cpf: map['cpf'] as String?,
      contact: map['contact'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      address: map['address'] as String?,
      cep: map['cep'] as String?,
      observations: map['observations'] as String?,
      outFlows: (map['outFlows'] as List<dynamic>?)?.map((outFlow) => OutFlow.fromMap(outFlow as Map<String, dynamic>, 'ID')).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'contact': contact,
      'phoneNumber': phoneNumber,
      'address': address,
      'cep': cep,
      'observations': observations,
      'outFlows': outFlows.map((outFlow) => outFlow.toMap()).toList(),
    };
  }
}

// 1. Transações de entrada
abstract class OutFlow {
  final String id;
  final DateTime dateTime;
  final Map<String, int> products;
  final Map<String, double> prices;
  final bool isSale;

  OutFlow({
    required this.id,
    required this.dateTime,
    required this.products,
    required this.prices,
    required this.isSale
  });

  String get type;

  Map<String, dynamic> toMap();

  static OutFlow fromMap(Map<String, dynamic> map, String id) {
    final type = map['type'] as String;
    switch (type) {
      case 'event':
        return EventOutFlow.fromMap(map, id);
      case 'order':
        return OrderOutFlow.fromMap(map, id);
      case 'marketplace':
        return MarketplaceOutFlow.fromMap(map, id);
      case 'loss':
        return LossOutFlow.fromMap(map, id);
      case 'gift':
        return GiftOutFlow.fromMap(map, id);
      case 'barter':
        return BarterOutFlow.fromMap(map, id);
      default:
        throw ArgumentError('Tipo de transação desconhecido: $type');
    }
  }

  @override
  String toString() {
    return 'TransactionOutFlow(dateTime: $dateTime, products: $products, type: $type)';
  }

  double get totalValue {
    double total = 0.0;
    products.forEach((code, amount) {
      total += (amount * prices[code]!);
    });
    return total;
  }
}

// 2.1. Evento
class EventOutFlow extends OutFlow {
  final String eventId;

  EventOutFlow({
    required String id,
    required DateTime dateTime,
    required Map<String, int> products,
    required Map<String, double> prices,
    required this.eventId,
  }) : super(id: id, dateTime: dateTime, products: products, prices: prices, isSale: true);

  @override
  String get type => 'event';

  @override
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'products': products,
      'prices': prices,
      'type': type,
      'eventId': eventId,
    };
  }

  factory EventOutFlow.fromMap(Map<String, dynamic> map, String id) {
    return EventOutFlow(
      id: id,
      dateTime: DateTime.parse(map['dateTime'] as String),
      products: Map<String, int>.from(map['products']),
      prices: Map<String, double>.from(map['prices']),
      eventId: map['eventId'] as String,
    );
  }
}

// 2.2. Encomenda
class OrderOutFlow extends OutFlow {
  final String customerId;

  OrderOutFlow({
    required String id,
    required DateTime dateTime,
    required Map<String, int> products,
    required Map<String, double> prices,
    required this.customerId,
  }) : super(id: id, dateTime: dateTime, products: products, prices: prices, isSale: true);

  @override
  String get type => 'order';

  @override
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'products': products,
      'prices': prices,
      'type': type,
      'customerId': customerId,
    };
  }

  factory OrderOutFlow.fromMap(Map<String, dynamic> map, String id) {
    return OrderOutFlow(
      id: id,
      dateTime: DateTime.parse(map['dateTime'] as String),
      products: Map<String, int>.from(map['products']),
      prices: Map<String, double>.from(map['prices']),
      customerId: map['customerId'] as String,
    );
  }
}

// 2.3. Marketplace
class MarketplaceOutFlow extends OutFlow {
  final String platform;
  final String transactionId;

  MarketplaceOutFlow({
    required String id,
    required DateTime dateTime,
    required Map<String, int> products,
    required Map<String, double> prices,
    required this.platform,
    required this.transactionId,
  }) : super(id: id, dateTime: dateTime, products: products, prices: prices, isSale: true);

  @override
  String get type => 'marketplace';

  @override
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'products': products,
      'prices': prices,
      'type': type,
      'platform': platform,
      'transactionId': transactionId,
    };
  }

  factory MarketplaceOutFlow.fromMap(Map<String, dynamic> map, String id) {
    return MarketplaceOutFlow(
      id: id,
      dateTime: DateTime.parse(map['dateTime'] as String),
      products: Map<String, int>.from(map['products']),
      prices: Map<String, double>.from(map['prices']),
      platform: map['platform'] as String,
      transactionId: map['transactionId'] as String,
    );
  }
}

// 2.4. Perda
enum LossStage {
  printed,
  finished,
}

extension LossStageExtension on LossStage {
  String toShortString() {
    return this.name;
  }

  static LossStage fromString(String value) {
    switch (value.toLowerCase()) {
      case 'printed':
        return LossStage.printed;
      case 'finished':
        return LossStage.finished;
      default:
        throw ArgumentError('Valor inválido para LossStage: $value');
    }
  }

  String label() {
    switch (this) {
      case LossStage.printed:
        return 'Impresso';
      case LossStage.finished:
        return 'Finalizado';
    }
  }
}

class LossOutFlow extends OutFlow {
  final LossStage stage;
  final String reason;
  final String? responsible;

  LossOutFlow({
    required String id,
    required DateTime dateTime,
    required Map<String, int> products,
    required Map<String, double> prices,
    required this.reason,
    required this.stage,
    this.responsible,
  }) : super(id: id, dateTime: dateTime, products: products, prices: prices, isSale: false);

  @override
  String get type => 'loss';

  @override
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'products': products,
      'prices': prices,
      'stage': stage.toShortString(),
      'type': type,
      'reason': reason,
      if (responsible != null) 'responsible': responsible,
    };
  }

  factory LossOutFlow.fromMap(Map<String, dynamic> map, String id) {
    return LossOutFlow(
      id: id,
      dateTime: DateTime.parse(map['dateTime'] as String),
      products: Map<String, int>.from(map['products']),
      prices: Map<String, double>.from(map['prices']),
      stage: LossStageExtension.fromString(map['stage']),
      reason: map['reason'] as String,
      responsible: map['responsible'] as String?,
    );
  }
}

// 2.5. Brinde
class GiftOutFlow extends OutFlow {
  final String recipientId;
  final String? occasion;

  GiftOutFlow({
    required String id,
    required DateTime dateTime,
    required Map<String, int> products,
    required Map<String, double> prices,
    required this.recipientId,
    this.occasion,
  }) : super(id: id, dateTime: dateTime, products: products, prices: prices, isSale: false);

  @override
  String get type => 'gift';

  @override
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'products': products,
      'prices': prices,
      'type': type,
      'recipient': recipientId,
      if (occasion != null) 'occasion': occasion,
    };
  }

  factory GiftOutFlow.fromMap(Map<String, dynamic> map, String id) {
    return GiftOutFlow(
      id: id,
      dateTime: DateTime.parse(map['dateTime'] as String),
      products: Map<String, int>.from(map['products']),
      prices: Map<String, double>.from(map['prices']),
      recipientId: map['recipient'] as String,
      occasion: map['occasion'] as String?,
    );
  }
}

// 2.6. Escambo (Barter)
class BarterOutFlow extends OutFlow {
  final String partner;
  final Map<String, double> itemsReceived;

  BarterOutFlow({
    required String id,
    required DateTime dateTime,
    required Map<String, int> products,
    required Map<String, double> prices,
    required this.partner,
    required this.itemsReceived,
  }) : super(id: id, dateTime: dateTime, products: products, prices: prices, isSale: false);

  @override
  String get type => 'barter';

  @override
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'products': products,
      'prices': prices,
      'type': type,
      'partner': partner,
      'itemsReceived': itemsReceived,
    };
  }

  factory BarterOutFlow.fromMap(Map<String, dynamic> map, String id) {
    return BarterOutFlow(
      id: id,
      dateTime: DateTime.parse(map['dateTime'] as String),
      products: Map<String, int>.from(map['products']),
      prices: Map<String, double>.from(map['prices']),
      partner: map['partner'] as String,
      itemsReceived: (map['itemsReceived'] as Map<String, dynamic>?)?.map((key, value) => MapEntry(key, value as double)) ?? {},
    );
  }
}