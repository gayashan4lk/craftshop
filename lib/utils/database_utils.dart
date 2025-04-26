import 'package:craftshop/data/data_sources/database_helper.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUtils {
  /// Forces a database reset for testing purposes
  /// WARNING: This will delete all data in the database
  static Future<void> forceReset() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "craftshop.db");
    
    // Delete the existing database
    await deleteDatabase(path);
    
    // Reinitialize the database
    await DatabaseHelper.instance.database;
  }
}
