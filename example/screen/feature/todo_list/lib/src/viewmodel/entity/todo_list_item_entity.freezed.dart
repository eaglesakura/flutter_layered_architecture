// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_list_item_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodoListItemEntity {

/// Identifier used for row actions.
 String get id;/// Title shown in the list.
 String get title;/// Whether the checkbox is checked.
 bool get isCompleted;
/// Create a copy of TodoListItemEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodoListItemEntityCopyWith<TodoListItemEntity> get copyWith => _$TodoListItemEntityCopyWithImpl<TodoListItemEntity>(this as TodoListItemEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodoListItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,isCompleted);

@override
String toString() {
  return 'TodoListItemEntity(id: $id, title: $title, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $TodoListItemEntityCopyWith<$Res>  {
  factory $TodoListItemEntityCopyWith(TodoListItemEntity value, $Res Function(TodoListItemEntity) _then) = _$TodoListItemEntityCopyWithImpl;
@useResult
$Res call({
 String id, String title, bool isCompleted
});




}
/// @nodoc
class _$TodoListItemEntityCopyWithImpl<$Res>
    implements $TodoListItemEntityCopyWith<$Res> {
  _$TodoListItemEntityCopyWithImpl(this._self, this._then);

  final TodoListItemEntity _self;
  final $Res Function(TodoListItemEntity) _then;

/// Create a copy of TodoListItemEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TodoListItemEntity].
extension TodoListItemEntityPatterns on TodoListItemEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodoListItemEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodoListItemEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodoListItemEntity value)  $default,){
final _that = this;
switch (_that) {
case _TodoListItemEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodoListItemEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TodoListItemEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodoListItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _TodoListItemEntity():
return $default(_that.id,_that.title,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _TodoListItemEntity() when $default != null:
return $default(_that.id,_that.title,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc


class _TodoListItemEntity implements TodoListItemEntity {
  const _TodoListItemEntity({required this.id, required this.title, required this.isCompleted});
  

/// Identifier used for row actions.
@override final  String id;
/// Title shown in the list.
@override final  String title;
/// Whether the checkbox is checked.
@override final  bool isCompleted;

/// Create a copy of TodoListItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodoListItemEntityCopyWith<_TodoListItemEntity> get copyWith => __$TodoListItemEntityCopyWithImpl<_TodoListItemEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodoListItemEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,isCompleted);

@override
String toString() {
  return 'TodoListItemEntity(id: $id, title: $title, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$TodoListItemEntityCopyWith<$Res> implements $TodoListItemEntityCopyWith<$Res> {
  factory _$TodoListItemEntityCopyWith(_TodoListItemEntity value, $Res Function(_TodoListItemEntity) _then) = __$TodoListItemEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, bool isCompleted
});




}
/// @nodoc
class __$TodoListItemEntityCopyWithImpl<$Res>
    implements _$TodoListItemEntityCopyWith<$Res> {
  __$TodoListItemEntityCopyWithImpl(this._self, this._then);

  final _TodoListItemEntity _self;
  final $Res Function(_TodoListItemEntity) _then;

/// Create a copy of TodoListItemEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? isCompleted = null,}) {
  return _then(_TodoListItemEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
