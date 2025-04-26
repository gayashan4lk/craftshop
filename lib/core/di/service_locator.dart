import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/data/repositories/bill_repository_impl.dart';
import 'package:craftshop/data/repositories/category_repository_impl.dart';
import 'package:craftshop/data/repositories/line_item_repository_impl.dart';
import 'package:craftshop/data/repositories/product_repository_impl.dart';
import 'package:craftshop/domain/repositories/bill_repository.dart';
import 'package:craftshop/domain/repositories/category_repository.dart';
import 'package:craftshop/domain/repositories/line_item_repository.dart';
import 'package:craftshop/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  
  // Repositories
  getIt.registerLazySingleton<LineItemRepository>(
    () => LineItemRepositoryImpl(databaseHelper: getIt<DatabaseHelper>())
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(databaseHelper: getIt<DatabaseHelper>())
  );
  
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(databaseHelper: getIt<DatabaseHelper>())
  );

  getIt.registerLazySingleton<BillRepository>(
    () => BillRepositoryImpl(
      lineItemRepository: getIt<LineItemRepository>(),
      databaseHelper: getIt<DatabaseHelper>()
    )
  );
}
