#!/bin/bash

featureName=$1

if [ -z "$featureName" ]; then
  echo "Error: No feature name provided."
  echo "Usage: $0 <feature_name>"
  exit 1
fi

# Capitalize the first letter of the feature name
featureNameCapitalized="$(tr '[:lower:]' '[:upper:]' <<< ${featureName:0:1})${featureName:1}"
# Convert the feature name to lowercase
featureNameLower="$(echo $featureName | tr '[:upper:]' '[:lower:]')"

echo "Initializing feature: $featureNameCapitalized"

# Base directory for the feature
baseDir="lib/features/$featureNameLower"

# Create feature directories and files
mkdir -p $baseDir/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{blocs,views,widgets}}

# Data layer files
touch $baseDir/data/datasources/${featureNameLower}_hive_data_source.dart
touch $baseDir/data/datasources/${featureNameLower}_remote_data_source.dart
touch $baseDir/data/models/${featureNameLower}_model.dart
touch $baseDir/data/repositories/${featureNameLower}_repository_impl.dart

# Domain layer files
touch $baseDir/domain/entities/${featureNameLower}_entity.dart
touch $baseDir/domain/repositories/${featureNameLower}_repository.dart
touch $baseDir/domain/usecases/get_${featureNameLower}_data.dart

# Presentation layer files
touch $baseDir/presentation/blocs/${featureNameLower}_state.dart
touch $baseDir/presentation/blocs/${featureNameLower}_event.dart
touch $baseDir/presentation/blocs/${featureNameLower}_bloc.dart
touch $baseDir/presentation/views/${featureNameLower}_page.dart
touch $baseDir/presentation/widgets/${featureNameLower}_widget.dart

# Add content to hive data source abstract class
cat <<EOL > $baseDir/data/datasources/${featureNameLower}_hive_data_source.dart
abstract class ${featureNameCapitalized}HiveDataSource {
  // Define abstract methods here
}

class ${featureNameCapitalized}HiveDataSourceImpl
    extends ${featureNameCapitalized}HiveDataSource {}
EOL

# Add content to remote data source abstract class
cat <<EOL > $baseDir/data/datasources/${featureNameLower}_remote_data_source.dart
import '../../../../core/network/network.dart';

abstract class ${featureNameCapitalized}RemoteDataSource {
 
  // Define abstract methods here
}

class ${featureNameCapitalized}RemoteDataSourceImpl
    extends ${featureNameCapitalized}RemoteDataSource {
    
     final Network _network;
 
    ${featureNameCapitalized}RemoteDataSourceImpl({required Network network})
      : _network = network;
      
  }
EOL

# Add content to repository implementation file
cat <<EOL > $baseDir/data/repositories/${featureNameLower}_repository_impl.dart
import '../datasources/${featureNameLower}_hive_data_source.dart';
import '../datasources/${featureNameLower}_remote_data_source.dart';
import '../../domain/repositories/${featureNameLower}_repository.dart';

class ${featureNameCapitalized}RepositoryImpl implements ${featureNameCapitalized}Repository {
  final ${featureNameCapitalized}HiveDataSource hiveDataSource;
  final ${featureNameCapitalized}RemoteDataSource remoteDataSource;

  ${featureNameCapitalized}RepositoryImpl({
    required this.hiveDataSource,
    required this.remoteDataSource,
  });

  // Implement repository methods here, using hiveDataSource and remoteDataSource
}
EOL

# Add content to repository abstract class
cat <<EOL > $baseDir/domain/repositories/${featureNameLower}_repository.dart
abstract class ${featureNameCapitalized}Repository {
  // Define abstract methods here
}
EOL

# Add placeholder content to model class
cat <<EOL > $baseDir/data/models/${featureNameLower}_model.dart
import 'package:equatable/equatable.dart';

class ${featureNameCapitalized}Model extends Equatable {
  // Define properties here

  @override
  List<Object> get props => [];
}
EOL

# Add placeholder content to entity class
cat <<EOL > $baseDir/domain/entities/${featureNameLower}_entity.dart
import 'package:equatable/equatable.dart';

class ${featureNameCapitalized}Entity extends Equatable {
  // Define properties here

  @override
  List<Object> get props => [];
}
EOL

# Add placeholder content to use case
cat <<EOL > $baseDir/domain/usecases/get_${featureNameLower}_data.dart
import 'package:dartz/dartz.dart';
import '../entities/${featureNameLower}_entity.dart';
import '../repositories/${featureNameLower}_repository.dart';

class Get${featureNameCapitalized}Data {
  final ${featureNameCapitalized}Repository repository;

  Get${featureNameCapitalized}Data({required  this.repository});

  // Implement call method here
}
EOL

# Add content to bloc file
cat <<EOL > $baseDir/presentation/blocs/${featureNameLower}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_${featureNameLower}_data.dart';

part '${featureNameLower}_event.dart';
part '${featureNameLower}_state.dart';


class ${featureNameCapitalized}Bloc extends Bloc<${featureNameCapitalized}Event, ${featureNameCapitalized}State> {
  final Get${featureNameCapitalized}Data get${featureNameCapitalized}Data;

  ${featureNameCapitalized}Bloc({
  required this.get${featureNameCapitalized}Data
  }) : super(${featureNameCapitalized}Initial());

}
EOL

# Add content to state file
cat <<EOL > $baseDir/presentation/blocs/${featureNameLower}_state.dart
part of '${featureNameLower}_bloc.dart';

abstract class ${featureNameCapitalized}State extends Equatable {
  const ${featureNameCapitalized}State();

  @override
  List<Object> get props => [];
}

class ${featureNameCapitalized}Initial extends ${featureNameCapitalized}State {}
EOL

# Add content to event file
cat <<EOL > $baseDir/presentation/blocs/${featureNameLower}_event.dart
part of '${featureNameLower}_bloc.dart';

abstract class ${featureNameCapitalized}Event extends Equatable {
  const ${featureNameCapitalized}Event();

  @override
  List<Object> get props => [];
}
EOL

# Add placeholder content to page file
cat <<EOL > $baseDir/presentation/views/${featureNameLower}_page.dart
import 'package:flutter/material.dart';
import '../blocs/${featureNameLower}_bloc.dart';

class ${featureNameCapitalized}Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$featureNameCapitalized Page'),
      ),
      body: Center(
        child: Text('Welcome to the $featureNameCapitalized feature!'),
      ),
    );
  }
}
EOL

# Add placeholder content to widget file
cat <<EOL > $baseDir/presentation/widgets/${featureNameLower}_widget.dart
import 'package:flutter/material.dart';

class ${featureNameCapitalized}Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('$featureNameCapitalized Widget'),
    );
  }
}
EOL

echo "
  sl
    ..registerFactory(() =>
        ${featureNameCapitalized}Bloc(get${featureNameCapitalized}Data: sl()))
    ..registerLazySingleton(() => Get${featureNameCapitalized}Data(repository: sl()))
  

    // AuthenticationHiveDataSource
    ..registerLazySingleton<${featureNameCapitalized}Repository>(() =>
        ${featureNameCapitalized}RepositoryImpl(remoteDataSource: sl(), hiveDataSource: sl()))
    ..registerLazySingleton<${featureNameCapitalized}RemoteDataSource>(
      () => ${featureNameCapitalized}RemoteDataSourceImpl(network: sl()),
    )
       ..registerLazySingleton<${featureNameCapitalized}HiveDataSource>(
      () => ${featureNameCapitalized}HiveDataSourceImpl(),
    )
    ..registerLazySingleton(
        () => Network(baseUrl: UrlConfig.baseUrl, showLog: true));

"


echo "Feature $featureNameCapitalized initialized successfully!"
