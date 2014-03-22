//
//  Constants.h
//  Middlecoin Toolkit
//
//  Created by Mathieu Mallet on 2/6/2014.
//  Copyright (c) 2014 Equinox Synthetics. All rights reserved.
//

#ifndef Middlecoin_Toolkit_Constants_h
#define Middlecoin_Toolkit_Constants_h

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define DONATE_ADDRESS @"1KxZwnp8GrKFoPZ828Wagg9TSpUhvYEZUF"

// emh
#define TEST_ADDRESS @"1DLkgH9K7dFaT2y2wuUDDvX9EzbSeoraNS"
// goblez
#define TEST_ADDRESS2 @"17MyQX9derjSHcveyXPYrSRra67DmWtRfy"
// some guy with high hash/return rate
#define TEST_ADDRESS3 @"1BtzFDErNKMMFeCSkho9tK7Cr8eus64x5K"
#define TEST_ADDRESS4 @"16uxhDQEso5dkY1kco5hTcmbSPT7bEMmj3"

#define TEST_RIG_ADDRESS @"http://emh.ottawaengineers.ca:8724/"

#define RATES_URL @"https://blockchain.info/ticker"

//#define BITCOIN_SYMBOL @"฿"
#define BITCOIN_SYMBOL @"Ƀ"

#define INSUFFICIENT_DATA_INTERVAL (60.0 * 60.0 * 3.0)

#define AUTO_REFRESH_INTERVAL (60 * 10)

#define ERROR_BTC_PER_MHS 0.003

#define WARNING_REJECT_RATIO 0.05
#define ERROR_REJECT_RATIO 0.20

#define ERROR_ACCEPTED_RATE 0.1
#define WARNING_ACCEPTED_RATE 1.0

#define WARNING_DATA_UPDATE_INTERVAL (60.0 * 20.0)
#define ERROR_DATA_UPDATE_INTERVAL (60.0 * 60.0)

#define POOLS_STATS_PAGE @"http://www.middlecoin.com"
#define USER_STATS_PAGE @"http://www.middlecoin.com/reports/%@.html"

#define POOL_GRAPH_PAGE @"http://192.237.252.90/coinGeek/js/graphTotal.js"

#define USER_GRAPH_PAGE @"http://192.237.252.90/coinGeek/js/all/%@.js"
#define USER_JSON_PAGE @"http://www.middlecoin.com/reports/%@.json"

#define FALLBACK_POOL_GRAPH_URL_PAGE POOLS_STATS_PAGE

#define FALLBACK_GRAPH_URL_PAGE @"http://www.middlecoin.com/reports/16o1d3U6CDjaedUo2V5H4NGSDgK2xDaLmW.html"
#define FALLBACK_GRAPH_ADDRESS @"16o1d3U6CDjaedUo2V5H4NGSDgK2xDaLmW"

#define DATA_DOWNLOAD_TIMEOUT 10.0

#endif
