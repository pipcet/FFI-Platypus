import gdb
import gdb.types

def real_name(t):
    if t.name:
        return t.name
    elif t.tag:
        return type_code_string(t) + " " + t.tag

def type_code_string(t):
    if t.code == gdb.TYPE_CODE_STRUCT:
        return "struct"
    elif t.code == gdb.TYPE_CODE_UNION:
        return "union"
    elif t.code == gdb.TYPE_CODE_ENUM:
        return "enum"
    elif t.code == gdb.TYPE_CODE_PTR:
        return "ptr"
    elif t.code == gdb.TYPE_CODE_ARRAY:
        return "array"
    elif t.code == gdb.TYPE_CODE_INT:
        return "int"
    elif t.code == gdb.TYPE_CODE_VOID:
        return "void"
    elif t.code == gdb.TYPE_CODE_TYPEDEF:
        return "typedef"
    elif t.code == gdb.TYPE_CODE_FUNC:
        return "func"
    elif t.code == gdb.TYPE_CODE_STRING:
        return "string"
    elif t.code == gdb.TYPE_CODE_RANGE:
        return "range"
    elif t.code == gdb.TYPE_CODE_BOOL:
        return "bool"
    else:
        return "TYPE_CODE_" + str(t.code)

def print_field(f, show):
    ret = "{"
    try:
        ret += "name=>'" + f.name + "', "
    except Exception:
        pass
    if f.bitsize != 0:
        ret += "bitsize=>" + str(f.bitsize) + ", "
    ret += "bitpos=>" + str(f.bitpos) + ", "
    ret += "type=>" + print_type_rec(f.type, False) + ", "
    ret += "}"
    return ret

def print_type_fields(t, show):
    ret = ""
    try:
        ret2 = "["
        for f in t.fields():
            ret2 += print_field(f, show)
            ret2 += ", "
        ret2 += "]"
        ret += ret2
    except Exception:
        pass
    return ret

def print_type_inner(t, show):
    ret = "{"
    f = print_type_fields(t,show)
    if f != "":
        ret += "fields=>" + f + ", "
    ret += "sizeof=>" + str(t.sizeof)
    try:
        ret += ", target=>" + print_type_rec(t.target(), False)
    except Exception:
        pass
    ret += "}"
    return ret

def print_type_rec(t, show):
    name = real_name(t)
    if name and not show:
        return "'" + name + "'"
    else:
        return "$" + type_code_string(t) + "->(" + print_type_inner(t, show) + ")"

def print_symbol_type(name):
    o = gdb.lookup_global_symbol(name)
    if not o:
        return ""
    t = o.type
    return "$def->('" + o.name + "', " + print_type_rec(t, True) + ");\n"

def print_type(name):
    t = gdb.lookup_type(name)
    return "$def->('" + real_name(t) + "', " + print_type_rec(t, True) + ");\n"
