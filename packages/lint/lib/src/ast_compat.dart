import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:meta/meta.dart';

/// analyzer 14 向け: 型宣言の名前トークン.
///
/// `ClassDeclaration.name` / `EnumDeclaration.name` /
/// `ExtensionTypeDeclaration.name` は削除され [ClassNamePart.typeName] になった.
@internal
Token? typeDeclarationNameToken(AstNode node) {
  return switch (node) {
    ClassDeclaration(:final namePart) => namePart.typeName,
    EnumDeclaration(:final namePart) => namePart.typeName,
    ExtensionTypeDeclaration(:final namePart) => namePart.typeName,
    MixinDeclaration(:final name) => name,
    ExtensionDeclaration(:final name) => name,
    _ => null,
  };
}

/// analyzer 14 向け: クラス相当のメンバー一覧.
///
/// `ClassDeclaration.members` 等は削除され [ClassBody.members] /
/// [EnumBody.members] になった.
@internal
NodeList<ClassMember> typeDeclarationMembers(AstNode node) {
  return switch (node) {
    ClassDeclaration(:final body) => body.members,
    EnumDeclaration(:final body) => body.members,
    ExtensionTypeDeclaration(:final body) => body.members,
    MixinDeclaration(:final body) => body.members,
    ExtensionDeclaration(:final body) => body.members,
    _ => throw ArgumentError(
      'typeDeclarationMembers expects a type declaration, got $node',
    ),
  };
}

/// [ClassDeclaration] の名前トークン（analyzer 14: [ClassNamePart.typeName]）.
@internal
Token classDeclarationName(ClassDeclaration node) => node.namePart.typeName;

/// [ClassDeclaration] のメンバー（analyzer 14: [ClassBody.members]）.
@internal
NodeList<ClassMember> classDeclarationMembers(ClassDeclaration node) =>
    node.body.members;

/// [ExtensionDeclaration] のメンバー（analyzer 14: [ClassBody.members]）.
@internal
NodeList<ClassMember> extensionDeclarationMembers(
  ExtensionDeclaration node,
) => node.body.members;
