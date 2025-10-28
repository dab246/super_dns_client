// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dns_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DnsRecord _$DnsRecordFromJson(Map<String, dynamic> json) {
  return _DnsRecord.fromJson(json);
}

/// @nodoc
mixin _$DnsRecord {
  /// DNS response code (0 = NOERROR, 2 = SERVFAIL)
  int? get status => throw _privateConstructorUsedError;

  /// Truncated flag
  @JsonKey(name: 'TC')
  bool? get tc => throw _privateConstructorUsedError;

  /// Recursion desired
  @JsonKey(name: 'RD')
  bool? get rd => throw _privateConstructorUsedError;

  /// Recursion available
  @JsonKey(name: 'RA')
  bool? get ra => throw _privateConstructorUsedError;

  /// Authenticated data
  @JsonKey(name: 'AD')
  bool? get ad => throw _privateConstructorUsedError;

  /// Checking disabled
  @JsonKey(name: 'CD')
  bool? get cd => throw _privateConstructorUsedError;

  /// EDNS client subnet (optional)
  @JsonKey(name: 'edns_client_subnet')
  String? get ednsClientSubnet => throw _privateConstructorUsedError;

  /// Answer records
  @JsonKey(name: 'Answer')
  List<Answer>? get answer => throw _privateConstructorUsedError;

  /// Optional comment from resolver
  @JsonKey(name: 'Comment')
  String? get comment => throw _privateConstructorUsedError;

  /// Serializes this DnsRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DnsRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DnsRecordCopyWith<DnsRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DnsRecordCopyWith<$Res> {
  factory $DnsRecordCopyWith(DnsRecord value, $Res Function(DnsRecord) then) =
      _$DnsRecordCopyWithImpl<$Res, DnsRecord>;
  @useResult
  $Res call(
      {int? status,
      @JsonKey(name: 'TC') bool? tc,
      @JsonKey(name: 'RD') bool? rd,
      @JsonKey(name: 'RA') bool? ra,
      @JsonKey(name: 'AD') bool? ad,
      @JsonKey(name: 'CD') bool? cd,
      @JsonKey(name: 'edns_client_subnet') String? ednsClientSubnet,
      @JsonKey(name: 'Answer') List<Answer>? answer,
      @JsonKey(name: 'Comment') String? comment});
}

/// @nodoc
class _$DnsRecordCopyWithImpl<$Res, $Val extends DnsRecord>
    implements $DnsRecordCopyWith<$Res> {
  _$DnsRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DnsRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? tc = freezed,
    Object? rd = freezed,
    Object? ra = freezed,
    Object? ad = freezed,
    Object? cd = freezed,
    Object? ednsClientSubnet = freezed,
    Object? answer = freezed,
    Object? comment = freezed,
  }) {
    return _then(_value.copyWith(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      tc: freezed == tc
          ? _value.tc
          : tc // ignore: cast_nullable_to_non_nullable
              as bool?,
      rd: freezed == rd
          ? _value.rd
          : rd // ignore: cast_nullable_to_non_nullable
              as bool?,
      ra: freezed == ra
          ? _value.ra
          : ra // ignore: cast_nullable_to_non_nullable
              as bool?,
      ad: freezed == ad
          ? _value.ad
          : ad // ignore: cast_nullable_to_non_nullable
              as bool?,
      cd: freezed == cd
          ? _value.cd
          : cd // ignore: cast_nullable_to_non_nullable
              as bool?,
      ednsClientSubnet: freezed == ednsClientSubnet
          ? _value.ednsClientSubnet
          : ednsClientSubnet // ignore: cast_nullable_to_non_nullable
              as String?,
      answer: freezed == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as List<Answer>?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DnsRecordImplCopyWith<$Res>
    implements $DnsRecordCopyWith<$Res> {
  factory _$$DnsRecordImplCopyWith(
          _$DnsRecordImpl value, $Res Function(_$DnsRecordImpl) then) =
      __$$DnsRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? status,
      @JsonKey(name: 'TC') bool? tc,
      @JsonKey(name: 'RD') bool? rd,
      @JsonKey(name: 'RA') bool? ra,
      @JsonKey(name: 'AD') bool? ad,
      @JsonKey(name: 'CD') bool? cd,
      @JsonKey(name: 'edns_client_subnet') String? ednsClientSubnet,
      @JsonKey(name: 'Answer') List<Answer>? answer,
      @JsonKey(name: 'Comment') String? comment});
}

/// @nodoc
class __$$DnsRecordImplCopyWithImpl<$Res>
    extends _$DnsRecordCopyWithImpl<$Res, _$DnsRecordImpl>
    implements _$$DnsRecordImplCopyWith<$Res> {
  __$$DnsRecordImplCopyWithImpl(
      _$DnsRecordImpl _value, $Res Function(_$DnsRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of DnsRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? tc = freezed,
    Object? rd = freezed,
    Object? ra = freezed,
    Object? ad = freezed,
    Object? cd = freezed,
    Object? ednsClientSubnet = freezed,
    Object? answer = freezed,
    Object? comment = freezed,
  }) {
    return _then(_$DnsRecordImpl(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      tc: freezed == tc
          ? _value.tc
          : tc // ignore: cast_nullable_to_non_nullable
              as bool?,
      rd: freezed == rd
          ? _value.rd
          : rd // ignore: cast_nullable_to_non_nullable
              as bool?,
      ra: freezed == ra
          ? _value.ra
          : ra // ignore: cast_nullable_to_non_nullable
              as bool?,
      ad: freezed == ad
          ? _value.ad
          : ad // ignore: cast_nullable_to_non_nullable
              as bool?,
      cd: freezed == cd
          ? _value.cd
          : cd // ignore: cast_nullable_to_non_nullable
              as bool?,
      ednsClientSubnet: freezed == ednsClientSubnet
          ? _value.ednsClientSubnet
          : ednsClientSubnet // ignore: cast_nullable_to_non_nullable
              as String?,
      answer: freezed == answer
          ? _value._answer
          : answer // ignore: cast_nullable_to_non_nullable
              as List<Answer>?,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
class _$DnsRecordImpl extends _DnsRecord {
  const _$DnsRecordImpl(
      {this.status,
      @JsonKey(name: 'TC') this.tc,
      @JsonKey(name: 'RD') this.rd,
      @JsonKey(name: 'RA') this.ra,
      @JsonKey(name: 'AD') this.ad,
      @JsonKey(name: 'CD') this.cd,
      @JsonKey(name: 'edns_client_subnet') this.ednsClientSubnet,
      @JsonKey(name: 'Answer') final List<Answer>? answer,
      @JsonKey(name: 'Comment') this.comment})
      : _answer = answer,
        super._();

  factory _$DnsRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$DnsRecordImplFromJson(json);

  /// DNS response code (0 = NOERROR, 2 = SERVFAIL)
  @override
  final int? status;

  /// Truncated flag
  @override
  @JsonKey(name: 'TC')
  final bool? tc;

  /// Recursion desired
  @override
  @JsonKey(name: 'RD')
  final bool? rd;

  /// Recursion available
  @override
  @JsonKey(name: 'RA')
  final bool? ra;

  /// Authenticated data
  @override
  @JsonKey(name: 'AD')
  final bool? ad;

  /// Checking disabled
  @override
  @JsonKey(name: 'CD')
  final bool? cd;

  /// EDNS client subnet (optional)
  @override
  @JsonKey(name: 'edns_client_subnet')
  final String? ednsClientSubnet;

  /// Answer records
  final List<Answer>? _answer;

  /// Answer records
  @override
  @JsonKey(name: 'Answer')
  List<Answer>? get answer {
    final value = _answer;
    if (value == null) return null;
    if (_answer is EqualUnmodifiableListView) return _answer;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Optional comment from resolver
  @override
  @JsonKey(name: 'Comment')
  final String? comment;

  @override
  String toString() {
    return 'DnsRecord(status: $status, tc: $tc, rd: $rd, ra: $ra, ad: $ad, cd: $cd, ednsClientSubnet: $ednsClientSubnet, answer: $answer, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DnsRecordImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tc, tc) || other.tc == tc) &&
            (identical(other.rd, rd) || other.rd == rd) &&
            (identical(other.ra, ra) || other.ra == ra) &&
            (identical(other.ad, ad) || other.ad == ad) &&
            (identical(other.cd, cd) || other.cd == cd) &&
            (identical(other.ednsClientSubnet, ednsClientSubnet) ||
                other.ednsClientSubnet == ednsClientSubnet) &&
            const DeepCollectionEquality().equals(other._answer, _answer) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, tc, rd, ra, ad, cd,
      ednsClientSubnet, const DeepCollectionEquality().hash(_answer), comment);

  /// Create a copy of DnsRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DnsRecordImplCopyWith<_$DnsRecordImpl> get copyWith =>
      __$$DnsRecordImplCopyWithImpl<_$DnsRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DnsRecordImplToJson(
      this,
    );
  }
}

abstract class _DnsRecord extends DnsRecord {
  const factory _DnsRecord(
      {final int? status,
      @JsonKey(name: 'TC') final bool? tc,
      @JsonKey(name: 'RD') final bool? rd,
      @JsonKey(name: 'RA') final bool? ra,
      @JsonKey(name: 'AD') final bool? ad,
      @JsonKey(name: 'CD') final bool? cd,
      @JsonKey(name: 'edns_client_subnet') final String? ednsClientSubnet,
      @JsonKey(name: 'Answer') final List<Answer>? answer,
      @JsonKey(name: 'Comment') final String? comment}) = _$DnsRecordImpl;
  const _DnsRecord._() : super._();

  factory _DnsRecord.fromJson(Map<String, dynamic> json) =
      _$DnsRecordImpl.fromJson;

  /// DNS response code (0 = NOERROR, 2 = SERVFAIL)
  @override
  int? get status;

  /// Truncated flag
  @override
  @JsonKey(name: 'TC')
  bool? get tc;

  /// Recursion desired
  @override
  @JsonKey(name: 'RD')
  bool? get rd;

  /// Recursion available
  @override
  @JsonKey(name: 'RA')
  bool? get ra;

  /// Authenticated data
  @override
  @JsonKey(name: 'AD')
  bool? get ad;

  /// Checking disabled
  @override
  @JsonKey(name: 'CD')
  bool? get cd;

  /// EDNS client subnet (optional)
  @override
  @JsonKey(name: 'edns_client_subnet')
  String? get ednsClientSubnet;

  /// Answer records
  @override
  @JsonKey(name: 'Answer')
  List<Answer>? get answer;

  /// Optional comment from resolver
  @override
  @JsonKey(name: 'Comment')
  String? get comment;

  /// Create a copy of DnsRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DnsRecordImplCopyWith<_$DnsRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  String get name => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call({String name, int type});
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionImplCopyWith<$Res>
    implements $QuestionCopyWith<$Res> {
  factory _$$QuestionImplCopyWith(
          _$QuestionImpl value, $Res Function(_$QuestionImpl) then) =
      __$$QuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int type});
}

/// @nodoc
class __$$QuestionImplCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$QuestionImpl>
    implements _$$QuestionImplCopyWith<$Res> {
  __$$QuestionImplCopyWithImpl(
      _$QuestionImpl _value, $Res Function(_$QuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
  }) {
    return _then(_$QuestionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
class _$QuestionImpl implements _Question {
  const _$QuestionImpl({required this.name, required this.type});

  factory _$QuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuestionImplFromJson(json);

  @override
  final String name;
  @override
  final int type;

  @override
  String toString() {
    return 'Question(name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, type);

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      __$$QuestionImplCopyWithImpl<_$QuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuestionImplToJson(
      this,
    );
  }
}

abstract class _Question implements Question {
  const factory _Question(
      {required final String name, required final int type}) = _$QuestionImpl;

  factory _Question.fromJson(Map<String, dynamic> json) =
      _$QuestionImpl.fromJson;

  @override
  String get name;
  @override
  int get type;

  /// Create a copy of Question
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionImplCopyWith<_$QuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Answer _$AnswerFromJson(Map<String, dynamic> json) {
  return _Answer.fromJson(json);
}

/// @nodoc
mixin _$Answer {
  String get name => throw _privateConstructorUsedError;
  int get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'TTL')
  int get ttl => throw _privateConstructorUsedError;
  String get data => throw _privateConstructorUsedError;

  /// Serializes this Answer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Answer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnswerCopyWith<Answer> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnswerCopyWith<$Res> {
  factory $AnswerCopyWith(Answer value, $Res Function(Answer) then) =
      _$AnswerCopyWithImpl<$Res, Answer>;
  @useResult
  $Res call(
      {String name, int type, @JsonKey(name: 'TTL') int ttl, String data});
}

/// @nodoc
class _$AnswerCopyWithImpl<$Res, $Val extends Answer>
    implements $AnswerCopyWith<$Res> {
  _$AnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Answer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? ttl = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      ttl: null == ttl
          ? _value.ttl
          : ttl // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnswerImplCopyWith<$Res> implements $AnswerCopyWith<$Res> {
  factory _$$AnswerImplCopyWith(
          _$AnswerImpl value, $Res Function(_$AnswerImpl) then) =
      __$$AnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name, int type, @JsonKey(name: 'TTL') int ttl, String data});
}

/// @nodoc
class __$$AnswerImplCopyWithImpl<$Res>
    extends _$AnswerCopyWithImpl<$Res, _$AnswerImpl>
    implements _$$AnswerImplCopyWith<$Res> {
  __$$AnswerImplCopyWithImpl(
      _$AnswerImpl _value, $Res Function(_$AnswerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Answer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? ttl = null,
    Object? data = null,
  }) {
    return _then(_$AnswerImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as int,
      ttl: null == ttl
          ? _value.ttl
          : ttl // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
class _$AnswerImpl implements _Answer {
  const _$AnswerImpl(
      {required this.name,
      required this.type,
      @JsonKey(name: 'TTL') required this.ttl,
      required this.data});

  factory _$AnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnswerImplFromJson(json);

  @override
  final String name;
  @override
  final int type;
  @override
  @JsonKey(name: 'TTL')
  final int ttl;
  @override
  final String data;

  @override
  String toString() {
    return 'Answer(name: $name, type: $type, ttl: $ttl, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnswerImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.ttl, ttl) || other.ttl == ttl) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, ttl, data);

  /// Create a copy of Answer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnswerImplCopyWith<_$AnswerImpl> get copyWith =>
      __$$AnswerImplCopyWithImpl<_$AnswerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnswerImplToJson(
      this,
    );
  }
}

abstract class _Answer implements Answer {
  const factory _Answer(
      {required final String name,
      required final int type,
      @JsonKey(name: 'TTL') required final int ttl,
      required final String data}) = _$AnswerImpl;

  factory _Answer.fromJson(Map<String, dynamic> json) = _$AnswerImpl.fromJson;

  @override
  String get name;
  @override
  int get type;
  @override
  @JsonKey(name: 'TTL')
  int get ttl;
  @override
  String get data;

  /// Create a copy of Answer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnswerImplCopyWith<_$AnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
