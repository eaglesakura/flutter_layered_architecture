// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_list_screen_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoListScreenEntity {

/// Whether a loading indicator should be shown.
 bool get isLoading;/// Rows to render.
 List<TodoListItemEntity> get items;/// Current draft title for the input field.
 String get draftTitle;/// Whether the add button should be enabled.
 bool get canAdd;
/// Create a copy of TodoListScreenEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoListScreenEntityCopyWith<TodoListScreenEntity> get copyWith => _$TodoListScreenEntityCopyWithImpl<TodoListScreenEntity>(this as TodoListScreenEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoListScreenEntity&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.draftTitle, draftTitle) || other.draftTitle == draftTitle)&&(identical(other.canAdd, canAdd) || other.canAdd == canAdd));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(items),draftTitle,canAdd);

@override
String toString() {
  return 'TodoListScreenEntity(isLoading: $isLoading, items: $items, draftTitle: $draftTitle, canAdd: $canAdd)';
}


}

/// @nodoc
abstract mixin class $TodoListScreenEntityCopyWith<$Res>  {
  factory $TodoListScreenEntityCopyWith(TodoListScreenEntity value, $Res Function(TodoListScreenEntity) _then) = _$TodoListScreenEntityCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<TodoListItemEntity> items, String draftTitle, bool canAdd
});




}
/// @nodoc
class _$TodoListScreenEntityCopyWithImpl<$Res>
    implements $TodoListScreenEntityCopyWith<$Res> {
  _$TodoListScreenEntityCopyWithImpl(this._self, this._then);

  final TodoListScreenEntity _self;
  final $Res Function(TodoListScreenEntity) _then;

/// Create a copy of TodoListScreenEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? items = null,Object? draftTitle = null,Object? canAdd = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TodoListItemEntity>,draftTitle: null == draftTitle ? _self.draftTitle : draftTitle // ignore: cast_nullable_to_non_nullable
as String,canAdd: null == canAdd ? _self.canAdd : canAdd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoListScreenEntity].
extension TodoListScreenEntityPatterns on TodoListScreenEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoListScreenEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoListScreenEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoListScreenEntity value)  $default,){
final _that = this;
switch (_that) {
case _TodoListScreenEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoListScreenEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TodoListScreenEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<TodoListItemEntity> items,  String draftTitle,  bool canAdd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoListScreenEntity() when $default != null:
return $default(_that.isLoading,_that.items,_that.draftTitle,_that.canAdd);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<TodoListItemEntity> items,  String draftTitle,  bool canAdd)  $default,) {final _that = this;
switch (_that) {
case _TodoListScreenEntity():
return $default(_that.isLoading,_that.items,_that.draftTitle,_that.canAdd);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<TodoListItemEntity> items,  String draftTitle,  bool canAdd)?  $default,) {final _that = this;
switch (_that) {
case _TodoListScreenEntity() when $default != null:
return $default(_that.isLoading,_that.items,_that.draftTitle,_that.canAdd);case _:
  return null;

}
}

}

/// @nodoc


class _TodoListScreenEntity implements TodoListScreenEntity {
  const _TodoListScreenEntity({required this.isLoading, required  List<TodoListItemEntity> items, required this.draftTitle, required this.canAdd}): _items = items;
  

/// Whether a loading indicator should be shown.
@override final  bool isLoading;
/// Rows to render.
 final  List<TodoListItemEntity> _items;
/// Rows to render.
@override List<TodoListItemEntity> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// Current draft title for the input field.
@override final  String draftTitle;
/// Whether the add button should be enabled.
@override final  bool canAdd;

/// Create a copy of TodoListScreenEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoListScreenEntityCopyWith<_TodoListScreenEntity> get copyWith => __$TodoListScreenEntityCopyWithImpl<_TodoListScreenEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoListScreenEntity&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.draftTitle, draftTitle) || other.draftTitle == draftTitle)&&(identical(other.canAdd, canAdd) || other.canAdd == canAdd));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_items),draftTitle,canAdd);

@override
String toString() {
  return 'TodoListScreenEntity(isLoading: $isLoading, items: $items, draftTitle: $draftTitle, canAdd: $canAdd)';
}


}

/// @nodoc
abstract mixin class _$TodoListScreenEntityCopyWith<$Res> implements $TodoListScreenEntityCopyWith<$Res> {
  factory _$TodoListScreenEntityCopyWith(_TodoListScreenEntity value, $Res Function(_TodoListScreenEntity) _then) = __$TodoListScreenEntityCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<TodoListItemEntity> items, String draftTitle, bool canAdd
});




}
/// @nodoc
class __$TodoListScreenEntityCopyWithImpl<$Res>
    implements _$TodoListScreenEntityCopyWith<$Res> {
  __$TodoListScreenEntityCopyWithImpl(this._self, this._then);

  final _TodoListScreenEntity _self;
  final $Res Function(_TodoListScreenEntity) _then;

/// Create a copy of TodoListScreenEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? items = null,Object? draftTitle = null,Object? canAdd = null,}) {
  return _then(_TodoListScreenEntity(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TodoListItemEntity>,draftTitle: null == draftTitle ? _self.draftTitle : draftTitle // ignore: cast_nullable_to_non_nullable
as String,canAdd: null == canAdd ? _self.canAdd : canAdd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
