import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:craftshop/data/repositories/category_repository_impl.dart';
import 'package:craftshop/data/repositories/product_repository_impl.dart';
import 'package:craftshop/domain/repositories/category_repository.dart';
import 'package:craftshop/domain/repositories/product_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Database
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  
  // Repositories
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(databaseHelper: getIt<DatabaseHelper>())
  );
  
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(databaseHelper: getIt<DatabaseHelper>())
  );
}
