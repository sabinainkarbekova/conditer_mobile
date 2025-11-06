part of 'catalog_bloc.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends CatalogEvent {}

class FilterProducts extends CatalogEvent {
  final Map<String, dynamic> filters;

  const FilterProducts(this.filters);

  @override
  List<Object> get props => [filters];
}

class SearchProducts extends CatalogEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object> get props => [query];
}