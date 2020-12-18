#!/usr/bin/env bats

# https://github.com/bats-core/bats-core

# Import functions
#. functions.sh

# https://advancedweb.hu/testing-bash-scripts-with-the-bats-testing-framework/

load 'test_helper'
fixtures file_setup_teardown

setup_file() {
  export SETUP_FILE_EXPORT_TEST=true
}

setup() {
  # give each test their own tmpdir to allow for parallelization without interference
  make_bats_test_suite_tmpdir "$BATS_TEST_NAME"
}

teardown() {
  test_helper::cleanup_tmpdir "$BATS_TEST_NAME"
}

@test "addition" {
  result=$(expr 2 + 2)
  [ "$result" -eq 4 ]
}

@test "RoundNumber" {
  result=$(RoundNumber 99,9 0)
  [ "$result" -eq 4 ]
}

@test "hello.sh" {
  run src/hello.sh John
  assert_output "Hello John"
}

@test "hello.sh should great the user" {
  result=$(src/hello.sh John)
  [ "$result" = "Hello John" ]
}