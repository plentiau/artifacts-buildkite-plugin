#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Pre-command downloads artifacts" {
  stub buildkite-agent \
    "artifact download *.log . : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
}

@test "Pre-command downloads artifacts with relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download /tmp/foo.log : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
}

@test "Pre-command downloads compressing artifacts" {
  mkdir -p /tmp/data && touch /tmp/data/foo.log
  tar -C /tmp -czf /tmp/data.tar.gz data
  stub buildkite-agent \
    "artifact download /tmp/data.tar : echo Downloading compressing artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/data.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_EXTRACT=$true
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Extracting"
  assert [ -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_EXTRACT
}

@test "Pre-command downloads artifacts with step" {
  stub buildkite-agent \
    "artifact download --step 54321 *.log . : echo Downloading artifacts with args: --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --step 54321"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
}

@test "Pre-command downloads artifacts with step and relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download --step 54321 /tmp/foo.log : echo Downloading artifacts with args: --step 54321"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_STEP="54321"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --step 54321"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_STEP
}

@test "Pre-command downloads artifacts with build" {
  stub buildkite-agent \
    "artifact download --build 12345 *.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple artifacts" {
  stub buildkite-agent \
    "artifact download foo.log . : echo Downloading artifacts" \
    "artifact download bar.log . : echo Downloading artifacts" \
    "artifact download baz.log . : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
}

@test "Pre-command downloads multiple artifacts with some relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download /tmp/foo.log . : echo Downloading artifacts" \
    "artifact download bar.log . : echo Downloading artifacts" \
    "artifact download baz.log . : echo Downloading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2="baz.log"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_2
}

@test "Pre-command downloads multiple compressing artifact" {
  mkdir -p /tmp/data-{1,2} && touch /tmp/data-{1,2}/foo-{1,2}.log
  tar -C /tmp/data-1 -czf /tmp/data-1.tar.gz .
  tar -C /tmp/data-2 -czf /tmp/data-2.tar.gz .
  stub buildkite-agent \
    "artifact download /tmp/data-1.tar.gz . : echo Downloading compressing artifacts" \
    "artifact download /tmp/data-2.tar.gz . : echo Downloading compressing artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/data-1.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_EXTRACT=$true
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_FROM="/tmp/data-2.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_TO="/tmp"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_EXTRACT=$true
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Extracting"
  assert [ -e /tmp/foo-1.log ]
  assert [ -e /tmp/foo-2.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_EXTRACT
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_EXTRACT
}

@test "Pre-command downloads multiple artifacts with build" {
  stub buildkite-agent \
    "artifact download --build 12345 foo.log . : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 bar.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Pre-command downloads multiple compressing artifacts with build" {
  mkdir -p /tmp/data-{1,2} && touch /tmp/data-{1,2}/foo-{1,2}.log
  tar -C /tmp/data-1 -czf /tmp/data-1.tar.gz .
  tar -C /tmp/data-2 -czf /tmp/data-2.tar.gz .
  stub buildkite-agent \
    "artifact download --build 12345 /tmp/data-1.tar.gz . : echo Downloading compressing artifacts with args: --build 12345" \
    "artifact download --build 12345 /tmp/data-2.tar.gz . : echo Downloading compressing artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/data-1.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="./data"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_EXTRACT=$true
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_FROM="/tmp/data-2.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_TO="./data"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_EXTRACT=$true
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"
  assert_output --partial "Extracting"
  assert [ -e ./data/foo-1.log ]
  assert [ -e ./data/foo-2.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_EXTRACT
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1_EXTRACT
}

@test "Pre-command downloads multiple artifacts with build and relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact download --build 12345 /tmp/foo.log : echo Downloading artifacts with args: --build 12345" \
    "artifact download --build 12345 bar.log . : echo Downloading artifacts with args: --build 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_BUILD="12345"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "Downloading artifacts with args: --build 12345"
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_BUILD
}

@test "Post-command uploads artifacts with a single value for upload" {
  stub buildkite-agent \
    "artifact upload *.log : echo Uploading artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
}

@test "Post-command uploads artifacts with a single value for upload with relocation" {
  stub buildkite-agent \
    "artifact upload /tmp/foo2.log : echo Uploading artifacts"
  touch /tmp/foo.log

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Moving [/tmp/foo.log]"
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
}

@test "Post-command uploads artifacts with a compressing option" {
  mkdir -p /tmp/data && touch /tmp/data/foo.log
  stub buildkite-agent \
    "artifact upload /tmp/data/ : echo Uploading compressing artifacts"
  touch /tmp/foo.log

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/data/"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/data.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_COMPRESS=$true
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Compressing"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_COMPRESS
}

@test "Post-command uploads artifacts with a single value for upload and a job" {
  stub buildkite-agent \
    "artifact upload --job 12345 *.log : echo Uploading artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD="*.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts with args: --job 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads artifacts with compressing option and a job" {
  stub buildkite-agent \
    "artifact upload --job 12345 /tmp/data/ : echo Uploading compressing artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/data/"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/data.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_COMPRESS=$true
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Compressing"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_DOWNLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_COMPRESS
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads artifacts with a single value for upload and a job and relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload --job 12345 /tmp/foo2.log : echo Uploading artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts with args: --job 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}

@test "Post-command uploads multiple artifacts" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload /tmp/foo2.log : echo Uploading artifacts" \
    "artifact upload bar.log : echo Uploading artifacts" \
    "artifact upload baz.log : echo Uploading artifacts" \

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
}

@test "Post-command uploads multiple compressing artifacts" {
  mkdir -p /tmp/data-{1,2} && touch /tmp/data-{1,2}/foo-{1,2}.log
  stub buildkite-agent \
    "artifact upload /tmp/data-1/ : echo Uploading compressing artifacts" \
    "artifact upload /tmp/data-2/ : echo Uploading compressing artifacts"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/data-1/"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/data-1.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_COMPRESS=$true
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_FROM="/tmp/data-2/"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_TO="/tmp/data-2.tar.gz"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_COMPRESS=$true
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts"
  assert_output --partial "Compressing [/tmp/data-1/] to [/tmp/data-1.tar.gz]"
  assert_output --partial "Compressing [/tmp/data-2/] to [/tmp/data-2.tar.gz]"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_COMPRESS
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1_COMPRESS
}

@test "Post-command uploads multiple artifacts with some relocation" {
  touch /tmp/foo.log
  stub buildkite-agent \
    "artifact upload /tmp/foo2.log : echo Uploading artifacts" \
    "artifact upload bar.log : echo Uploading artifacts" \
    "artifact upload baz.log : echo Uploading artifacts" \

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM="/tmp/foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO="/tmp/foo2.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2="baz.log"
  run "$PWD/hooks/post-command"

  assert_success
  assert [ -e /tmp/foo2.log ]
  assert [ ! -e /tmp/foo.log ]
  assert_output --partial "Uploading artifacts"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_FROM
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0_TO
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_2
}

@test "Post-command uploads multiple artifacts with a job" {
  stub buildkite-agent \
    "artifact upload --job 12345 foo.log : echo Uploading artifacts with args: --job 12345" \
    "artifact upload --job 12345 bar.log : echo Uploading artifacts with args: --job 12345"

  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0="foo.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1="bar.log"
  export BUILDKITE_PLUGIN_ARTIFACTS_JOB="12345"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Uploading artifacts with args: --job 12345"

  unstub buildkite-agent
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_0
  unset BUILDKITE_PLUGIN_ARTIFACTS_UPLOAD_1
  unset BUILDKITE_PLUGIN_ARTIFACTS_JOB
}