#!/usr/bin/env python3
import sys
import os

try:
    import yaml
except ImportError:
    sys.exit("Error: PyYAML is required. Install it with: pip install pyyaml")

# Prevent PyYAML from parsing ISO 8601 timestamps as datetime objects.
# The tickets system stores timestamps as plain strings and round-trips
# them as-is; datetime conversion would change '2026-06-20T12:00:00Z'
# to '2026-06-20 12:00:00+00:00', breaking validation.
def _keep_timestamps_as_strings(loader, node):
    return loader.construct_scalar(node)

yaml.SafeLoader.add_constructor('tag:yaml.org,2002:timestamp', _keep_timestamps_as_strings)


def usage():
    print("Usage: yz.py <subcommand> [args...]", file=sys.stderr)
    print(file=sys.stderr)
    print("Subcommands:", file=sys.stderr)
    print("  extract <file.md> <yaml_path> [default]", file=sys.stderr)
    print("  update  <file.md> <yaml_path> <value>", file=sys.stderr)
    print("  set-env <file.md> <yaml_path> <env_var>", file=sys.stderr)
    print("  delete  <file.md> <yaml_path>", file=sys.stderr)
    print("  keys    <file.md>", file=sys.stderr)
    print("  len     <file.md> <yaml_path>", file=sys.stderr)
    print("  read    <file.yaml> <yaml_path> [default]", file=sys.stderr)
    print("  write   <file.yaml> <yaml_path> <value>", file=sys.stderr)
    print("  append  <file.yaml> <yaml_path> <json_string>", file=sys.stderr)


def resolve_path(yaml_path, data, default=None):
    parts = yaml_path.lstrip('.').split('.')
    if not parts or parts == ['']:
        return data
    current = data
    for part in parts:
        if isinstance(current, dict):
            key = part
            idx = None
            if '[' in part:
                arr_part = part.split('[', 1)
                key = arr_part[0] if arr_part[0] else None
                idx = int(arr_part[1].rstrip(']'))
            if key:
                current = current.get(key)
                if current is None:
                    return default
            if idx is not None:
                if isinstance(current, list):
                    current = current[idx]
                else:
                    return default
        elif isinstance(current, list):
            current = current[int(part)]
        else:
            return default
    if current is None:
        return default
    return current


def set_path(yaml_path, data, value):
    parts = yaml_path.lstrip('.').split('.')
    current = data
    for i, part in enumerate(parts[:-1]):
        key = part
        idx = None
        if '[' in part:
            arr_part = part.split('[', 1)
            key = arr_part[0] if arr_part[0] else None
            idx = int(arr_part[1].rstrip(']'))
        if key:
            next_obj = current.get(key)
            if next_obj is None or not isinstance(next_obj, dict):
                current[key] = {}
                next_obj = current[key]
            current = next_obj
        if idx is not None:
            while len(current) <= idx:
                current.append({})
            current = current[idx]
    last = parts[-1]
    if '[' in last:
        arr_part = last.split('[', 1)
        lkey = arr_part[0]
        lidx = int(arr_part[1].rstrip(']'))
        current[lkey][lidx] = value
    else:
        current[last] = value


def del_path(yaml_path, data):
    parts = yaml_path.lstrip('.').split('.')
    current = data
    for i, part in enumerate(parts[:-1]):
        if isinstance(current, dict):
            key = part
            idx = None
            if '[' in part:
                arr_part = part.split('[', 1)
                key = arr_part[0] if arr_part[0] else None
                idx = int(arr_part[1].rstrip(']'))
            if key:
                current = current.get(key)
            if idx is not None and isinstance(current, list):
                current = current[idx]
        elif isinstance(current, list):
            current = current[int(part)]
        if current is None:
            return
    last = parts[-1]
    if '[' in last:
        arr_part = last.split('[', 1)
        lkey = arr_part[0]
        lidx = int(arr_part[1].rstrip(']'))
        if lkey in current and isinstance(current[lkey], list):
            current[lkey][lidx] = None
    elif isinstance(current, dict) and last in current:
        del current[last]


def _parse_content(content):
    if not content.startswith('---'):
        return {}, content
    parts = content.split('---', 2)
    if len(parts) < 3:
        return {}, content
    return parts[1], parts[2]


def parse_front_matter(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    fm_text, body = _parse_content(content)
    try:
        front_matter = yaml.safe_load(fm_text) or {}
    except yaml.YAMLError:
        front_matter = {}
    return front_matter, body


def write_front_matter(filepath, front_matter, body):
    fm_yaml = yaml.dump(
        front_matter,
        default_flow_style=False,
        sort_keys=False,
        allow_unicode=True,
    )
    output = '---\n' + fm_yaml + '---\n' + body.lstrip('\n')
    tmp = filepath + '.tmp'
    with open(tmp, 'w') as f:
        f.write(output)
    os.replace(tmp, filepath)


def parse_value(val_str):
    if val_str == 'null':
        return None
    if val_str == 'true':
        return True
    if val_str == 'false':
        return False
    try:
        return int(val_str)
    except ValueError:
        try:
            return float(val_str)
        except ValueError:
            return val_str


def _print_value(val, default=''):
    if val is None:
        sys.stdout.write(str(default))
    elif isinstance(val, bool):
        sys.stdout.write('true' if val else 'false')
    elif isinstance(val, str):
        sys.stdout.write(val)
    else:
        sys.stdout.write(str(val))


def cmd_extract(args):
    if len(args) < 2:
        sys.exit("Usage: yz.py extract <file.md> <yaml_path> [default]")
    filepath = args[0]
    yaml_path = args[1]
    default = args[2] if len(args) > 2 else ''
    front_matter, _ = parse_front_matter(filepath)
    val = resolve_path(yaml_path, front_matter)
    _print_value(val, default)


def cmd_update(args):
    if len(args) < 3:
        sys.exit("Usage: yz.py update <file.md> <yaml_path> <value>")
    filepath = args[0]
    yaml_path = args[1]
    value = parse_value(args[2])
    front_matter, body = parse_front_matter(filepath)
    set_path(yaml_path, front_matter, value)
    write_front_matter(filepath, front_matter, body)


def cmd_set_env(args):
    if len(args) < 3:
        sys.exit("Usage: yz.py set-env <file.md> <yaml_path> <env_var>")
    filepath = args[0]
    yaml_path = args[1]
    env_var = args[2]
    value = os.environ.get(env_var, '')
    front_matter, body = parse_front_matter(filepath)
    set_path(yaml_path, front_matter, value)
    write_front_matter(filepath, front_matter, body)


def cmd_delete(args):
    if len(args) < 2:
        sys.exit("Usage: yz.py delete <file.md> <yaml_path>")
    filepath = args[0]
    yaml_path = args[1]
    front_matter, body = parse_front_matter(filepath)
    del_path(yaml_path, front_matter)
    write_front_matter(filepath, front_matter, body)


def cmd_keys(args):
    if len(args) < 1:
        sys.exit("Usage: yz.py keys <file.md>")
    front_matter, _ = parse_front_matter(args[0])
    for key in front_matter:
        print(key)


def cmd_len(args):
    if len(args) < 2:
        sys.exit("Usage: yz.py len <file.md> <yaml_path>")
    front_matter, _ = parse_front_matter(args[0])
    val = resolve_path(args[1], front_matter)
    if isinstance(val, (list, dict)):
        sys.stdout.write(str(len(val)))
    else:
        sys.stdout.write('0')


def cmd_read(args):
    if len(args) < 2:
        sys.exit("Usage: yz.py read <file.yaml> <yaml_path> [default]")
    filepath = args[0]
    yaml_path = args[1]
    default = args[2] if len(args) > 2 else ''
    try:
        with open(filepath, 'r') as f:
            data = yaml.safe_load(f) or {}
    except FileNotFoundError:
        sys.exit(1)
    val = resolve_path(yaml_path, data)
    _print_value(val, default)


def cmd_write(args):
    if len(args) < 3:
        sys.exit("Usage: yz.py write <file.yaml> <yaml_path> <value>")
    filepath = args[0]
    yaml_path = args[1]
    value = parse_value(args[2])
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f) or {}
    set_path(yaml_path, data, value)
    tmp = filepath + '.tmp'
    with open(tmp, 'w') as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
    os.replace(tmp, filepath)


def cmd_append(args):
    if len(args) < 3:
        sys.exit("Usage: yz.py append <file.yaml> <yaml_path> <json_string>")
    filepath = args[0]
    yaml_path = args[1]
    json_str = args[2]
    import json
    try:
        new_obj = json.loads(json_str)
    except json.JSONDecodeError as e:
        sys.exit(f"Error: invalid JSON: {e}")
    with open(filepath, 'r') as f:
        data = yaml.safe_load(f) or {}
    seq = resolve_path(yaml_path, data)
    if seq is None:
        set_path(yaml_path, data, [new_obj])
    elif isinstance(seq, list):
        seq.append(new_obj)
    else:
        set_path(yaml_path, data, [seq, new_obj])
    tmp = filepath + '.tmp'
    with open(tmp, 'w') as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
    os.replace(tmp, filepath)


def main():
    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    subcommand = sys.argv[1]
    args = sys.argv[2:]

    commands = {
        'extract': cmd_extract,
        'update': cmd_update,
        'set-env': cmd_set_env,
        'delete': cmd_delete,
        'keys': cmd_keys,
        'len': cmd_len,
        'read': cmd_read,
        'write': cmd_write,
        'append': cmd_append,
    }

    if subcommand in commands:
        commands[subcommand](args)
    elif subcommand in ('-h', '--help'):
        usage()
    else:
        print(f"Error: unknown subcommand '{subcommand}'", file=sys.stderr)
        usage()
        sys.exit(1)


if __name__ == '__main__':
    main()
