import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class CurrencyLocalDataSource {
  Future<void> cacheCurrencies(List<CurrencyEntity> currencies);
  Future<List<CurrencyEntity>> getCachedCurrencies();
  Future<void> cacheSelectedCurrency(CurrencyEntity currency);
  Future<CurrencyEntity?> getSelectedCurrency();
  Future<void> clearCache();
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  static const String _currenciesBoxName = 'currencies';
  static const String _selectedCurrencyKey = 'selected_currency';
  static const String _currenciesListKey = 'currencies_list';

  @override
  Future<void> cacheCurrencies(List<CurrencyEntity> currencies) async {
    try {
      final box = await Hive.openBox(_currenciesBoxName);
      final currencyMaps =
          currencies.map((currency) => _entityToMap(currency)).toList();
      await box.put(_currenciesListKey, currencyMaps);
    } catch (e) {
      throw CacheException(message: 'Failed to cache currencies: $e');
    }
  }

  @override
  Future<List<CurrencyEntity>> getCachedCurrencies() async {
    try {
      final box = await Hive.openBox(_currenciesBoxName);
      final raw = box.get(_currenciesListKey);
      final currencyMaps = (raw as List?)?.cast<dynamic>();

      if (currencyMaps == null) {
        return [];
      }

      return currencyMaps
          .map((map) => _mapToEntity(Map<String, dynamic>.from(map as Map)))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached currencies: $e');
    }
  }

  @override
  Future<void> cacheSelectedCurrency(CurrencyEntity currency) async {
    try {
      final box = await Hive.openBox(_currenciesBoxName);
      await box.put(_selectedCurrencyKey, _entityToMap(currency));
    } catch (e) {
      throw CacheException(message: 'Failed to cache selected currency: $e');
    }
  }

  @override
  Future<CurrencyEntity?> getSelectedCurrency() async {
    try {
      final box = await Hive.openBox(_currenciesBoxName);
      final raw = box.get(_selectedCurrencyKey);
      if (raw == null) {
        return null;
      }

      // Ensure proper typing from Hive's dynamic map
      final currencyMap = Map<String, dynamic>.from(raw as Map);

      return _mapToEntity(currencyMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get selected currency: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(_currenciesBoxName);
      await box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  Map<String, dynamic> _entityToMap(CurrencyEntity entity) {
    return {
      'id': entity.id,
      'code': entity.code,
      'symbol': entity.symbol,
      'noOfDecimal': entity.noOfDecimal,
      'exchangeRate': entity.exchangeRate,
      'symbolPosition': entity.symbolPosition,
      'thousandsSeparator': entity.thousandsSeparator,
      'decimalSeparator': entity.decimalSeparator,
      'systemReserve': entity.systemReserve,
      'status': entity.status,
      'createdById': entity.createdById,
      'createdAt': entity.createdAt,
      'updatedAt': entity.updatedAt,
      'deletedAt': entity.deletedAt,
    };
  }

  CurrencyEntity _mapToEntity(Map<String, dynamic> map) {
    return CurrencyEntity(
      id: map['id'] as int,
      code: map['code'] as String,
      symbol: map['symbol'] as String,
      noOfDecimal: map['noOfDecimal'] as int,
      exchangeRate: map['exchangeRate'] as String,
      symbolPosition: map['symbolPosition'] as String,
      thousandsSeparator: map['thousandsSeparator'] as String,
      decimalSeparator: map['decimalSeparator'] as String,
      systemReserve: map['systemReserve'] as int,
      status: map['status'] as int,
      createdById: map['createdById'],
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      deletedAt: map['deletedAt'],
    );
  }
}
