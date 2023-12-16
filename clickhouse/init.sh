#!/bin/bash
set -e

clickhouse-client --user=${CLICKHOUSE_USER} --password=${CLICKHOUSE_PASSWORD} -n <<-EOSQL
    USE ${CLICKHOUSE_DB};
    CREATE TABLE IF NOT EXISTS instrument
    (
        id         Int32,
        changed    Int32,
        title      String,
        short_title String,
        symbol     String,
        rate       Float64
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS company
    (
        id        Int32,
        changed   Int32,
        title     String,
        full_title String,
        www       String,
        country   Int32
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS user
    (
        id       Int32,
        changed  Int32,
        login    Nullable(String),
        currency Int32,
        parent   Nullable(Int32)
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS country
    (
        id       Int32,
        title    String,
        currency Int32,
        domain   String
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS account
    (
        id                    UUID,
        changed               Int32,
        user                  Int32,
        role                  Nullable(Int32),
        instrument            Nullable(Int32),
        company               Nullable(Int32),
        type                  String,
        title                 String,
        sync_id                Array(String),
        balance               Nullable(Float64),
        start_balance          Nullable(Float64),
        credit_limit           Nullable(Float64),
        in_balance             UInt8,
        savings               Nullable(BOOL),
        enable_correction      UInt8,
        enable_sms             UInt8,
        archive               UInt8,
        capitalization        Nullable(BOOL),
        percent               Nullable(Float64),
        start_date             Nullable(String),
        end_date_offset         Nullable(Int32),
        end_date_offset_interval Nullable(String),
        payoff_step            Nullable(Int32),
        payoff_interval        Nullable(String)
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS tag
    (
        id            UUID,
        changed       Int32,
        user          Int32,
        title         String,
        parent        Nullable(String),
        icon          Nullable(String),
        picture       Nullable(String),
        color         Nullable(Int64),
        show_income    UInt8,
        show_outcome   UInt8,
        budget_income  UInt8,
        budget_outcome UInt8,
        required      Nullable(BOOL)
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS merchant
    (
        id      UUID,
        changed Int32,
        user    Int32,
        title   String
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS reminder
    (
        id                UUID,
        changed           Int32,
        user              Int32,
        income_instrument  Int32,
        income_account     String,
        income            Float64,
        outcome_instrument Int32,
        outcome_account    String,
        outcome           Float64,
        tag               Array(UUID),
        merchant          Nullable(UUID),
        payee             String,
        comment           String,
        interval          Nullable(String),
        step              Nullable(Int32),
        points            Array(Int32),
        start_date         String,
        end_date           Nullable(String),
        notify            UInt8
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS reminder_marker
    (
        id                UUID,
        changed           Int32,
        user              Int32,
        income_instrument  Int32,
        income_account     String,
        income            Float64,
        outcome_instrument Int32,
        outcome_account    String,
        outcome           Float64,
        tag               Array(UUID),
        merchant          Nullable(UUID),
        payee             String,
        comment           String,
        date              String,
        reminder          UUID,
        state             String,
        notify            UInt8
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS transaction
    (
        id                  UUID,
        changed             Int32,
        created             Int32,
        user                Int32,
        deleted             BOOL,
        hold                Nullable(BOOL),
        income_instrument    Int32,
        income_account       String,
        income              Float64,
        outcome_instrument   Int32,
        outcome_account      String,
        outcome             Float64,
        tag                 Array(UUID),
        merchant            Nullable(UUID),
        payee               String,
        original_payee       String,
        comment             String,
        date                String,
        mcc                 Nullable(Int32),
        reminder_marker      Nullable(UUID),
        op_income            Nullable(Float64),
        op_income_instrument  Nullable(Int32),
        op_outcome           Nullable(Float64),
        op_outcome_instrument Nullable(Int32),
        latitude            Nullable(Float64),
        longitude           Nullable(Float64)
    ) ENGINE = MergeTree PRIMARY KEY id;

    CREATE TABLE IF NOT EXISTS budget
    (
        changed     Int32,
        user        Int32,
        tag         Nullable(UUID),
        date        String,
        income      Float64,
        income_lock  UInt8,
        outcome     Float64,
        outcome_lock UInt8
    ) ENGINE = MergeTree() ORDER BY date;
EOSQL