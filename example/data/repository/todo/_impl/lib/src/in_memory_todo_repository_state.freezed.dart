// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'in_memory_todo_repository_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InMemoryTodoRepositoryState {

 List<Todo> get items;
/// Create a copy of InMemoryTodoRepositoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InMemoryTodoRepositoryStateCopyWith<InMemoryTodoRepositoryState> get copyWith => _$InMemoryTodoRepositoryStateCopyWithImpl<InMemoryTodoRepositoryState>(this as InMemoryTodoRepositoryState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as InMemoryTodoRepositoryState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InMemoryTodoRepositoryState&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as InMemoryTodoRepositoryState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as InMemoryTodoRepositoryState;
  return 'InMemoryTodoRepositoryState(items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $InMemoryTodoRepositoryStateCopyWith<$Res>  {
  factory $InMemoryTodoRepositoryStateCopyWith(InMemoryTodoRepositoryState value, $Res Function(InMemoryTodoRepositoryState) _then) = _$InMemoryTodoRepositoryStateCopyWithImpl;
@useResult
$Res call({
 List<Todo> items
});




}
/// @nodoc
class _$InMemoryTodoRepositoryStateCopyWithImpl<$Res>
    implements $InMemoryTodoRepositoryStateCopyWith<$Res> {
  _$InMemoryTodoRepositoryStateCopyWithImpl(this._self, this._then);

  final InMemoryTodoRepositoryState _self;
  final $Res Function(InMemoryTodoRepositoryState) _then;

/// Create a copy of InMemoryTodoRepositoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(InMemoryTodoRepositoryState(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Todo>,
  ));
}

}


/// Adds pattern-matching-related methods to [InMemoryTodoRepositoryState].
extension InMemoryTodoRepositoryStatePatterns on InMemoryTodoRepositoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InMemoryTodoRepositoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InMemoryTodoRepositoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InMemoryTodoRepositoryState value)  $default,){
final _that = this;
switch (_that) {
case _InMemoryTodoRepositoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InMemoryTodoRepositoryState value)?  $default,){
final _that = this;
switch (_that) {
case _InMemoryTodoRepositoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Todo> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InMemoryTodoRepositoryState() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Todo> items)  $default,) {final _that = this;
switch (_that) {
case _InMemoryTodoRepositoryState():
return $default(_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Todo> items)?  $default,) {final _that = this;
switch (_that) {
case _InMemoryTodoRepositoryState() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _InMemoryTodoRepositoryState implements InMemoryTodoRepositoryState {
  const _InMemoryTodoRepositoryState({required  List<Todo> items}): _items = items;
  

 final  List<Todo> _items;
@override List<Todo> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of InMemoryTodoRepositoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InMemoryTodoRepositoryStateCopyWith<_InMemoryTodoRepositoryState> get copyWith => __$InMemoryTodoRepositoryStateCopyWithImpl<_InMemoryTodoRepositoryState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InMemoryTodoRepositoryState&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'InMemoryTodoRepositoryState(items: $items)';
}


}

/// @nodoc
abstract mixin class _$InMemoryTodoRepositoryStateCopyWith<$Res> implements $InMemoryTodoRepositoryStateCopyWith<$Res> {
  factory _$InMemoryTodoRepositoryStateCopyWith(_InMemoryTodoRepositoryState value, $Res Function(_InMemoryTodoRepositoryState) _then) = __$InMemoryTodoRepositoryStateCopyWithImpl;
@override @useResult
$Res call({
 List<Todo> items
});




}
/// @nodoc
class __$InMemoryTodoRepositoryStateCopyWithImpl<$Res>
    implements _$InMemoryTodoRepositoryStateCopyWith<$Res> {
  __$InMemoryTodoRepositoryStateCopyWithImpl(this._self, this._then);

  final _InMemoryTodoRepositoryState _self;
  final $Res Function(_InMemoryTodoRepositoryState) _then;

/// Create a copy of InMemoryTodoRepositoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_InMemoryTodoRepositoryState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Todo>,
  ));
}


}

// dart format on
