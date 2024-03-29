#!/usr/bin/env bash
# shellcheck disable=SC2091
###############################################################################

function cmd {
    printf "./avalanche-cli.sh platform get-max-stake-amount" ;
}

function check {
    local result="$1" ;
    local result_u ; result_u=$(printf '%s' "$result" | cut -d' ' -f3) ;
    local result_h ; result_h=$(printf '%s' "$result" | cut -d' ' -f5) ;
    local result_d ; result_d=$(printf '%s' "$result" | cut -d' ' -f7) ;
    local expect_u ; expect_u="'https://api.avax.network/ext/P'" ;
    assertEquals "$expect_u" "$result_u" ;
    local expect_h ; expect_h="'content-type:application/json'" ;
    assertEquals "$expect_h" "$result_h" ;
    local expect_d ; expect_d="'{" ;
    expect_d+='"jsonrpc":"2.0",' ;
    expect_d+='"id":1,' ;
    expect_d+='"method":"platform.getMaxStakeAmount",' ;
    expect_d+='"params":{' ;
    expect_d+='"subnetID":'"$(echo "\"$2\"")," ;
    expect_d+='"nodeID":'"$(echo "\"$3\"")," ;
    expect_d+='"startTime":1,' ;
    expect_d+='"endTime":3' ;
    expect_d+="}}'" ;
    assertEquals "$expect_d" "$result_d" ;
    local expect="curl --url $expect_u --header $expect_h --data $expect_d" ;
    assertEquals "$expect" "$result" ;
}

function test_platform__get_max_stake_amount_1a {
    check "$(AVAX_ID_RPC=1 $(cmd) -s SUBNET_ID -n NODE_ID -t1 -T3)" SUBNET_ID NODE_ID;
}

function test_platform__get_max_stake_amount_1b {
    check "$(AVAX_ID_RPC=1 AVAX_START_TIME=1 AVAX_END_TIME=3 $(cmd) -s SUBNET_ID -n NODE_ID)" SUBNET_ID NODE_ID ;
}

function test_platform__get_max_stake_amount_1c {
    check "$(AVAX_ID_RPC=1 AVAX_SUBNET_ID=SUBNET_ID AVAX_NODE_ID=NODE_ID $(cmd) -t1 -T3)"  SUBNET_ID NODE_ID ;
}

###############################################################################
###############################################################################
