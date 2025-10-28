// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dns_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DnsRecordImpl _$$DnsRecordImplFromJson(Map<String, dynamic> json) =>
    _$DnsRecordImpl(
      status: (json['status'] as num?)?.toInt(),
      tc: json['TC'] as bool?,
      rd: json['RD'] as bool?,
      ra: json['RA'] as bool?,
      ad: json['AD'] as bool?,
      cd: json['CD'] as bool?,
      ednsClientSubnet: json['edns_client_subnet'] as String?,
      answer: (json['Answer'] as List<dynamic>?)
          ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['Comment'] as String?,
    );

Map<String, dynamic> _$$DnsRecordImplToJson(_$DnsRecordImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'TC': instance.tc,
      'RD': instance.rd,
      'RA': instance.ra,
      'AD': instance.ad,
      'CD': instance.cd,
      'edns_client_subnet': instance.ednsClientSubnet,
      'Answer': instance.answer?.map((e) => e.toJson()).toList(),
      'Comment': instance.comment,
    };

_$QuestionImpl _$$QuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuestionImpl(
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
    );

Map<String, dynamic> _$$QuestionImplToJson(_$QuestionImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
    };

_$AnswerImpl _$$AnswerImplFromJson(Map<String, dynamic> json) => _$AnswerImpl(
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
      ttl: (json['TTL'] as num).toInt(),
      data: json['data'] as String,
    );

Map<String, dynamic> _$$AnswerImplToJson(_$AnswerImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'TTL': instance.ttl,
      'data': instance.data,
    };
