#!/usr/bin/env bash
#
# test.sh - test executor for the tickets CLI test suite.
#
# Test cases live in test/cases/tcXXX_short_test_name.sh and are sourced by
# this script. Each case must define two functions:
#
#   fixture()  echoes the code of the fixture the case requires (e.g. f001)
#   run()      executes the test inside its prepared execution directory;
#              exit 0 = pass, non-zero = fail; echoes an informative message
#
# Fixtures live in test/fixtures/fXXX_short_fixture_name and are copied into
# each fresh execution directory under test/executions/ before run() is
# invoked. The CLI under test is available to run() as $TICKETS_CLI.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

CASES_DIR="$SCRIPT_DIR/test/cases"
FIXTURES_DIR="$SCRIPT_DIR/test/fixtures"
EXECUTIONS_DIR="$SCRIPT_DIR/test/executions"

usage() {
  cat <<EOF
Usage: test.sh <subcommand> [options]

Subcommands:
  exec    Execute test cases

Options:
  -h, --help  Show this help message
EOF
}

exec_usage() {
  cat <<EOF
Usage: test.sh exec --cases <tcXXX,tcYYY|all> [options]

Options:
  --cases <list|all>  Comma-separated test case codes (e.g. tc001,tc005)
                      or 'all' to execute every case in test/cases (required)
  --cli <path>        Path to the tickets CLI under test
                      (default: $SCRIPT_DIR/tickets.sh)
  -h, --help          Show this help message
EOF
}

cmd_exec() {
  local cases_arg=""
  local cli="$SCRIPT_DIR/tickets.sh"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --cases)
        [[ -z "${2:-}" ]] && { echo "Error: --cases requires a value" >&2; exit 1; }
        cases_arg="$2"
        shift
        ;;
      --cli)
        [[ -z "${2:-}" ]] && { echo "Error: --cli requires a path argument" >&2; exit 1; }
        cli="$2"
        shift
        ;;
      -h|--help)
        exec_usage
        return 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        exec_usage
        exit 1
        ;;
    esac
    shift
  done

  if [[ -z "$cases_arg" ]]; then
    echo "Error: --cases is required" >&2
    exec_usage
    exit 1
  fi

  if [[ ! -f "$cli" ]]; then
    echo "Error: CLI not found: $cli" >&2
    exit 1
  fi
  if [[ ! -x "$cli" ]]; then
    echo "Error: CLI is not executable: $cli" >&2
    exit 1
  fi
  local cli_abs
  cli_abs=$(readlink -f "$cli")

  # Parse the --cases value into a list of case codes.
  local -a tokens=()
  IFS=',' read -r -a tokens <<< "$cases_arg"

  local all_seen=0
  local -a codes=()
  local token
  for token in "${tokens[@]}"; do
    token="${token//[[:space:]]/}"
    if [[ -z "$token" ]]; then
      echo "Error: empty case code in --cases" >&2
      exit 1
    fi
    if [[ "$token" == "all" ]]; then
      all_seen=1
      continue
    fi
    if [[ ! "$token" =~ ^tc[0-9]{3}$ ]]; then
      echo "Error: invalid case code '$token' (expected tcXXX or 'all')" >&2
      exit 1
    fi
    codes+=("$token")
  done

  if [[ $all_seen -eq 1 ]]; then
    if [[ ${#codes[@]} -gt 0 ]]; then
      echo "Error: 'all' cannot be combined with explicit case codes" >&2
      exit 1
    fi
    local f
    for f in "$CASES_DIR"/tc[0-9][0-9][0-9]_*.sh; do
      [[ -f "$f" ]] || continue
      codes+=("$(basename "$f" | cut -c1-5)")
    done
    if [[ ${#codes[@]} -eq 0 ]]; then
      echo "Error: no test cases found in $CASES_DIR" >&2
      exit 1
    fi
  fi

  # Reject duplicates and resolve case files.
  local -A seen=()
  local -a case_files=()
  local code
  for code in "${codes[@]}"; do
    if [[ -n "${seen[$code]:-}" ]]; then
      echo "Error: duplicate case code '$code'" >&2
      exit 1
    fi
    seen[$code]=1
    local matches=("$CASES_DIR/$code"_*.sh)
    if [[ ! -f "${matches[0]}" ]]; then
      echo "Error: unknown test case '$code'" >&2
      exit 1
    fi
    case_files+=("${matches[0]}")
  done

  local total=0 passed=0 failed=0
  local -a failed_codes=()

  local i
  for i in "${!codes[@]}"; do
    code="${codes[$i]}"
    local case_file="${case_files[$i]}"
    total=$((total + 1))

    local ts exec_dir
    ts=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
    exec_dir="$EXECUTIONS_DIR/${code}_${ts}"
    if [[ -e "$exec_dir" ]]; then
      echo "Error: execution directory already exists: $exec_dir" >&2
      exit 1
    fi
    mkdir -p "$exec_dir"

    echo "==> Running $code ($(basename "$case_file"))"

    unset -f fixture run 2>/dev/null || true
    # shellcheck disable=SC1090
    source "$case_file"
    if ! declare -F fixture >/dev/null || ! declare -F run >/dev/null; then
      echo "FAIL $code - case must define 'fixture' and 'run' functions"
      failed=$((failed + 1))
      failed_codes+=("$code")
      continue
    fi

    local fcode fstatus
    set +e
    fcode=$(fixture)
    fstatus=$?
    set -e
    fcode=$(echo "$fcode" | tr -d '[:space:]')
    if [[ $fstatus -ne 0 || -z "$fcode" ]]; then
      echo "FAIL $code - fixture() did not return a fixture code"
      failed=$((failed + 1))
      failed_codes+=("$code")
      continue
    fi

    local fixture_matches=("$FIXTURES_DIR/$fcode"_*)
    if [[ ! -d "${fixture_matches[0]}" ]]; then
      echo "FAIL $code - fixture '$fcode' not found in $FIXTURES_DIR"
      failed=$((failed + 1))
      failed_codes+=("$code")
      continue
    fi
    cp -a "${fixture_matches[0]}/." "$exec_dir/"

    local output status
    set +e
    output=$(cd "$exec_dir" && TICKETS_CLI="$cli_abs" run 2>&1)
    status=$?
    set -e
    printf '%s\n' "$output" > "$exec_dir/output.log"

    local first_line
    first_line=${output%%$'\n'*}
    if [[ $status -eq 0 ]]; then
      echo "PASS $code - $first_line"
      passed=$((passed + 1))
    else
      echo "FAIL $code - $first_line"
      failed=$((failed + 1))
      failed_codes+=("$code")
    fi
    if [[ "$output" == *$'\n'* ]]; then
      printf '%s\n' "${output#*$'\n'}" | sed 's/^/  /'
    fi
  done

  echo "----------------------------------------"
  echo "$total executed, $passed passed, $failed failed"
  if [[ $failed -gt 0 ]]; then
    echo "Failed: ${failed_codes[*]}"
    exit 1
  fi
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

subcommand="$1"
shift

case "$subcommand" in
  -h|--help)
    usage
    ;;
  exec)
    cmd_exec "$@"
    ;;
  *)
    echo "Unknown subcommand: $subcommand" >&2
    usage
    exit 1
    ;;
esac
