package FFI::Platypus::GDB::GDBExpression::BINOP_ADD;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
  '(';
}

sub c_suffix {
  ')';
}


sub c_infix {
  '+';
}


sub opcode {
  return 1; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_SUB;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}

sub c_infix {
  '-';
}


sub opcode {
  return 2; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_MUL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}

sub c_infix {
  '*';
}


sub opcode {
  return 3; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_DIV;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '/';
}


sub opcode {
  return 4; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_REM;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '%';
}


sub opcode {
  return 5; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_MOD;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '%';
}


sub opcode {
  return 6; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_LSH;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '<<';
}


sub opcode {
  return 7; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_RSH;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '>>';
}


sub opcode {
  return 8; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_LOGICAL_AND;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '&&';
}


sub opcode {
  return 9; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_LOGICAL_OR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '||';
}


sub opcode {
  return 10; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_BITWISE_AND;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '&';
}


sub opcode {
  return 11; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_BITWISE_IOR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '|';
}


sub opcode {
  return 12; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_BITWISE_XOR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '^';
}


sub opcode {
  return 13; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_EQUAL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '==';
}


sub opcode {
  return 14; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_NOTEQUAL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '!=';
}


sub opcode {
  return 15; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_LESS;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '<';
}


sub opcode {
  return 16; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_GTR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '>';
}


sub opcode {
  return 17; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_LEQ;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
  '<=';
}


sub opcode {
  return 18; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_GEQ;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 19; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_REPEAT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 20; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_ASSIGN;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 21; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_COMMA;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 22; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_SUBSCRIPT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 23; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_EXP;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 24; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_MIN;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 25; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_MAX;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 26; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::STRUCTOP_MEMBER;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 27; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::STRUCTOP_MPTR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 28; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::TYPE_INSTANCE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 29; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_INTDIV;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 30; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_ASSIGN_MODIFY;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 31; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_VAL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 32; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_CONCAT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 33; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::BINOP_END;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::BinaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}


sub opcode {
  return 34; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::TERNOP_COND;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::TernaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}

sub c_infix2 {
}


sub opcode {
  return 35; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::TERNOP_SLICE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::TernaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub c_infix {
}

sub c_infix2 {
}


sub opcode {
  return 36; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::MULTI_SUBSCRIPT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 37; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_LONG;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 38; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_DOUBLE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 39; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_VAR_VALUE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 40; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_VAR_ENTRY_VALUE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 41; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_LAST;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 42; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_REGISTER;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 43; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_INTERNALVAR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 44; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_FUNCALL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 45; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_OBJC_MSGCALL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 46; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_F77_UNDETERMINED_ARGLIST;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 47; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_COMPLEX;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 48; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_STRING;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 49; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_ARRAY;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 50; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_CAST;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 51; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_CAST_TYPE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 52; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_DYNAMIC_CAST;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 53; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_REINTERPRET_CAST;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 54; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_MEMVAL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 55; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_MEMVAL_TLS;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 56; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_MEMVAL_TYPE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 57; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_NEG;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 58; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_LOGICAL_NOT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 59; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_COMPLEMENT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 60; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_IND;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 61; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_ADDR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 62; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_PREINCREMENT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 63; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_POSTINCREMENT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 64; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_PREDECREMENT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 65; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_POSTDECREMENT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 66; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_SIZEOF;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 67; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_PLUS;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 68; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_CAP;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 69; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_CHR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 70; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_ORD;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 71; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_ABS;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 72; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_FLOAT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 73; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_HIGH;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 74; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_MAX;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 75; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_MIN;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 76; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_ODD;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 77; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::UNOP_TRUNC;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression::UnaryOperator';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 78; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_BOOL;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 79; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_M2_STRING;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 80; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::STRUCTOP_STRUCT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 81; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::STRUCTOP_PTR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 82; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_THIS;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 83; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_OBJC_SELECTOR;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 84; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_SCOPE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 85; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_TYPE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 86; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_NAME;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 87; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_OBJC_NSSTRING;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 88; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_F90_RANGE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 89; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_DECFLOAT;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 90; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_ADL_FUNC;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 91; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_TYPEOF;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 92; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_DECLTYPE;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 93; # expanded before we eval
}


package FFI::Platypus::GDB::GDBExpression::OP_TYPEID;
use parent -norequire, 'FFI::Platypus::GDB::GDBExpression';


sub c_prefix {
}

sub c_suffix {
}


sub opcode {
  return 94; # expanded before we eval
}
