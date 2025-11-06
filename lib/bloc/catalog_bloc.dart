import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product.dart';
import '../services/api_service.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final ApiService apiService;

  CatalogBloc({required this.apiService}) : super(CatalogLoading()) {
    on<LoadProducts>(_onLoadProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      final products = await apiService.getProducts();
      emit(CatalogLoaded(products: products));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }

  Future<void> _onFilterProducts(FilterProducts event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      final products = await apiService.getFilteredProducts(event.filters);
      emit(CatalogLoaded(products: products));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<CatalogState> emit) async {
    emit(CatalogLoading());
    try {
      final products = await apiService.searchProducts(event.query);
      emit(CatalogLoaded(products: products));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}