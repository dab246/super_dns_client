// ignore_for_file: invalid_annotation_target, non_constant_identifier_names

import 'package:freezed_annotation/freezed_annotation.dart';

part 'dns_record.freezed.dart';

part 'dns_record.g.dart';

@freezed
class DnsRecord with _$DnsRecord {
  const DnsRecord._();

  @JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
  const factory DnsRecord({
    /// DNS response code (0 = NOERROR, 2 = SERVFAIL)
    int? status,

    /// Truncated flag
    @JsonKey(name: 'TC') bool? tc,

    /// Recursion desired
    @JsonKey(name: 'RD') bool? rd,

    /// Recursion available
    @JsonKey(name: 'RA') bool? ra,

    /// Authenticated data
    @JsonKey(name: 'AD') bool? ad,

    /// Checking disabled
    @JsonKey(name: 'CD') bool? cd,

    /// EDNS client subnet (optional)
    @JsonKey(name: 'edns_client_subnet') String? ednsClientSubnet,

    /// Answer records
    @JsonKey(name: 'Answer') List<Answer>? answer,

    /// Optional comment from resolver
    @JsonKey(name: 'Comment') String? comment,
  }) = _DnsRecord;

  factory DnsRecord.fromJson(Map<String, dynamic> json) =>
      _$DnsRecordFromJson(json);

  bool get isFailure => status == 2;

  bool get isSuccess => status == 0;
}

@freezed
class Question with _$Question {
  @JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
  const factory Question({
    required String name,
    required int type,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@freezed
class Answer with _$Answer {
  @JsonSerializable(fieldRename: FieldRename.none, explicitToJson: true)
  const factory Answer({
    required String name,
    required int type,
    @JsonKey(name: 'TTL') required int ttl,
    required String data,
  }) = _Answer;

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  static List<Answer> listFromJson(List<dynamic> jsonList) =>
      jsonList.map((e) => Answer.fromJson(e as Map<String, dynamic>)).toList();
}
