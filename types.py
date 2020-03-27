

class Pos:
    def __init__(self, x, y, z):
        if x is None:
            x = 0.0
        if y is None:
            y = 0.0
        if z is None:
            z = 0.0
        self.set(x, y, z)

    def set(self, *argv):
        try:
            if not isinstance(argv[0].x, float):
                raise TypeError("x must be a float.")
            if not isinstance(argv[0].y, float):
                raise TypeError("y must be a float.")
            if not isinstance(argv[0].z, float):
                raise TypeError("z must be a float.")
            self.x = argv[0].x
            self.y = argv[0].y
            self.z = argv[0].z
        except AttributeError:
            pass
            # assume got [x, y, z] and continue
        if not isinstance(argv[0], float):
            raise TypeError("x must be a float.")
        if not isinstance(argv[1], float):
            raise TypeError("y must be a float.")
        if not isinstance(argv[2], float):
            raise TypeError("z must be a float.")
        self.x = argv[0]
        self.y = argv[1]
        self.z = argv[2]

    def __str__(self):
        return ", ".join((self.x, self.y, self.z))

_types = {
    "string": str,
    "bool": bool,
    "pos": Pos
}
print("types: {}".format(_types))

_conf_types = ["string", "bool", "pos"]
_false_strings = ["0", "off", "false", "no"]
_true_strings = ["1", "on", "true", "yes"]


class _Comment:
    def __init__(text, line_index):
        # can be a comment or blank line (may be whitespace)
        if not (text.startswith('#') or (len(text.strip()) < 1)):
            raise ValueError("A comment must be either a blank line or"
                             " start with '#' (got '{}')".format(text))
        self.text = text
        self.line_index = line_index

def is_comment(c):
    # duck typing
    try:
        text = c.text
        line_index = c.line_index
    except AttributeError:
        return False
    return True

def _deserialize(name, value, _type):
    """
    Convert the value to an intrinsic or engine-defined type.

    Sequential arguments:
    name -- The variable name (only used for error output!)
    value -- The value (should not be a str unless _type is "string")
    _type -- This must be a key in the _types dictionary.
    """
    if not isinstance(value, str):
        raise ValueError("_deserialize expected a string value for '{}'"
                         " but got a(n) {}."
                         "".format(name, type(value).__name__))
    if _type == "string":
        return value
    elif _type == "bool":
        value = value.strip().lower()
        if value in _false_strings:
            return False
        elif value in _true_strings:
            return True
        raise ValueError("The value for '{}' has an unknown bool string"
                         ": {} (should be {})"
                         "".format(name, _false_strings + _true_strings,
                                   value))
    elif _type == "pos":
        while "  " in value:
            value = value.replace("  ", " ")
        parts = value.split(" ")
        if len(parts) != 3:
            raise ValueError("The value for '{}' has an incorrect"
                             " number of elements for pos:"
                             " {} (should have 3 elements, but has {})"
                             "".format(name, parts, len(parts)))
        return Pos(float(parts[0]), float(parts[1]), float(parts[2]))
    else:
        if _type in _conf_types:
            print("ERROR in _deserialize: '{}' is in _conf_types but"
                  " not implemented.".format(_type))
        if not _type in _types.keys():
            raise RuntimeError("_deserialize got '{}' as"
                                " a(n) '{}' which is not a valid"
                                " type.".format(
                                    name,
                                    type(value).__name__
                                ))
        else:
            raise RuntimeError("_deserialize got '{}' as"
                                " a(n) '{}' which is not a valid"
                                " conf type.".format(
                                    name,
                                    type(value).__name__
                                ))

    return None
def _serialize(name, value, _type):
    """
    Convert the value to a string.

    Sequential arguments:
    name -- The variable name (only used for error output!)
    value -- The value (should not be a str unless _type is "string")
    _type -- This must be a key in the _types dictionary.
    """
    if _type == "string":
        if not isinstance(value, str):
            raise TypeError("The engine tried to set '{}' as a(n)"
                            " '{}' but the type should have been"
                            " '{}'".format(name,
                                           type(value).__name__,
                                           _type))
        return value
    elif _type == "bool":
        if not isinstance(value, bool):
            raise TypeError("The engine tried to set '{}' as a(n)"
                            " '{}' but the type should have been"
                            " '{}'".format(name,
                                           type(value).__name__,
                                           _type))
        if _value:
            return "true"
        return "false"
    elif _type == "pos":
        if not isinstance(value, Pos):
            raise TypeError("The engine tried to set '{}' as a(n)"
                            " '{}' but the type should have been"
                            " '{}'".format(name,
                                           type(value).__name__,
                                           _type))
        return str(value)
    else:
        if _type in _conf_types:
            print("ERROR: '{}' is in _conf_types but not"
                  " implemented.".format(_type))
        if not _type in _types.keys():
            raise RuntimeError("The engine tried to set '{}' as"
                                " a(n) '{}' which is not a valid"
                                " type.".format(
                                    name,
                                    type(value).__name__
                                ))
        else:
            raise RuntimeError("The engine tried to set '{}' as"
                                " a(n) '{}' which is not a valid"
                                " conf type.".format(
                                    name,
                                    type(value).__name__
                                ))
    return None

def _write_as(stream, name, sign, value, suffix, _type):
    s = _serialize(value, _type)
    stream.write(name + sign + s + suffix)

class Conf:
    def __init__(self, _path):
        self._path = None
        self._lines = []  # keep this so preserving comments is possible
        self._metalines = {}
        self._order = []
        self._end_comments = []
        self.load(_path)  # must be LAST

    # def _generate_metaline(name, value, comment_list=None,
    #         line_index=None)

    def set(self, name, value):
        self._set(name, value, "string", comments=None, line_index=None)

    def set_bool(self, name, value):
        self._set(name, value, "bool", comments=None, line_index=None)

    def set_pos(self, name, value):
        self._set(name, value, "pos", comments=None, line_index=None)

    def save(self):
        line_index = 0
        with open(self._path, 'w') as outs:
            for k in order:
                ml = self._metalines[k]
                _write_as(outs, k, ml['value'], ml['type'])
            fatal_errors = []
            for k, ml in self._metalines.items():
                if k not in order:
                    fatal_errors.append(
                        "The Conf class failed to ensure that there is"
                        " a line order containing '{}', but the line"
                        " was written anyway. '{}' must be"
                        " reloaded.".format(k, self._path)
                    )
                    _write_as(outs, name, ml['value'], ml['type'])
        if len(fatal_errors) > 0:
            self.load()
            raise RuntimeError(";".join(fatal_errors))

    # def _force_set(name, sign, value, suffix, _type, comments=None,
    #                line_index=None):
    #     self._metalines[name] =

    def _set(self, name, value, _type, comments=None, line_index=None):
        ml = {
            'comments': comments,
            'sign': " = ",  # allow the user to format the conf
            'value': value,
            'suffix': "",  # allow the user to format the conf
            'type': _type,
            'line_index': line_index
        }
        tmp = _serialize(value, _type)  # only here for sanity check
        if ml.comments is None:
            ml.comments = []
        else:
            for comment in comments:
                if not is_comment(comment):
                    raise TypeError("A comment failed"
                                    " the is_comment test.")
        sign = " = "
        suffix = ""
        old_meta = self._metalines.get(name)
        if old_meta is None:
            # INFO: In this case, `load` will set sign and suffix after
            # calling `_set`.
            self._metalines[name] = ml
            self._order.append(name)
        else:
            sign = old_meta["sign"]
            suffix = old_meta["suffix"]
            if old_meta["type"] != _type:
                raise ValueError(
                    "The type '{}' is incorrect (should be"
                    " '{}' for '{}')".format(
                        _type,
                        old_meta["type"],
                        name
                    )
                )
            self._metalines[name]['value'] = value
            if len(ml.comments) > 0:
                self._metalines[name]['comments'] = ml.comments
            # else keep existing comments if any
            ml = old_meta
        _metaline_set

    def insert_comment_before(self, variable_name, text):
        # This technically changes the line numbering, but that is not
        # important except in its saved form.
        # - Save renumbers the _lines.
        comment = _Comment(text, -1)
        self._metalines[variable_name]["comments"].append(comment)

    def append_end_comment(self, comment):
        self._end_comments.append(comment)

    def load(self, _path):
        count = 0
        if _path is None:
            return 0
        if self._path is not None:
            if _path != self._path:
                raise RuntimeError("A Conf can only be based on one"
                                   " file.")
            else:
                self._lines = []
                print("WARNING: discarding changes to '{}' and"
                      " reloading".format(_path))
        if os._path.isfile(_path):
            with open(_path) as ins:
                while True:
                    line_original = ins.readline()
                    comments = []
                    if line_original:
                        line = line_original.rstrip("\n\r")
                        if not line.startswith("#"):
                            self.set(
                            comments = []
                        else:
                            comment = _Comment(line, count)
                            comments.append(comment)
                        count += 1
                    else:
                        break
            for i in range(new_i, len(_lines)):
                count += 1
                if (not line.startswith("#")) and (len(line) > 0):
                    sign_i = line.find("=")
        return count
