//
//  MTFrameAnimationDataBase.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/4.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "MTFrameAnimationDataBase.h"
#import <sqlite3.h>
#import <pthread.h>

static const char *dbPath = "";

static NSString *createCacheListTable = @"create table if not exists prefixcache_table(id integer primary key autoincrement, prefixname text, result integer)";
static NSString *updateCacheListTable = @"update prefixcache_table set result = ? WHERE prefixname = '%@'";
static NSString *queryCacheListTable = @"select * form prefixcache_table WHERE prefixname = '%@' COLLATE NOCASE";
static NSString *insertCacheListTable = @"insert into prefixcache_table(prefixname, result) values(?, ?)";

static NSString *createCacheTable = @"create table if not exists %@_table(id integer primary key autoincrement, content BLOB)";
static NSString *insertCacheTable = @"insert into %@_table(content) values(?)";
static NSString *queryCacheTable = @"select * from %@_table COLLATE NOCASE";

@interface MTFrameAnimationDataBase() {
    sqlite3 *db;
}
@end

@implementation MTFrameAnimationDataBase

#pragma mark - LifeCycle

- (instancetype)init {
    if (self = [super init]) {
        NSString *localPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                             stringByAppendingPathComponent:@"com.mp.frameAnimation"];
        dbPath = [[localPath stringByAppendingPathComponent:@"framebytes.db"] UTF8String];
        sqlite3_open(dbPath, &db);
        sqlite3_exec(db, [createCacheListTable UTF8String], NULL, NULL, nil);
    }
    return self;
}

#pragma mark - Public

- (NSArray<MTFrameAnimationImage *> *)db_getSourcesWithPrefixName:(NSString *)prefixName {
    sqlite3_exec(db, "begin", 0, 0, 0);
    sqlite3_stmt *stmt = NULL;
    
    NSMutableArray * resourceArr = nil;
    if (pv_isLoadCacheResultWithPrefix(prefixName, db, stmt)) {
        sqlite3_reset(stmt);
        const char * querySql = [[NSString stringWithFormat:queryCacheTable, prefixName] UTF8String];
        if (sqlite3_prepare_v2(db, querySql, -1, &stmt, NULL) == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                //TODO:处理二进制成图片
                //TODO:添加到数据库中
            }
        }
    }
    sqlite3_finalize(stmt);
    sqlite3_exec(db, "commit", 0, 0, 0);
    return resourceArr;
}

- (void)db_insertSourcesWithPrefixName:(NSString *)prefixName
                               sources:(NSArray<MTFrameAnimationImage *> *)sources {
    sqlite3_exec(db, [[NSString stringWithFormat:createCacheTable, prefixName] UTF8String], NULL, NULL, NULL);
    
    sqlite3_exec(db, "begin", 0, 0, 0);
    sqlite3_stmt *stmt = NULL;
    
    if (!pv_isLoadCacheResultWithPrefix(prefixName, db, stmt)) {
        const char *insertSql = [[NSString stringWithFormat:insertCacheTable, prefixName] UTF8String];
        sqlite3_reset(stmt);
        sqlite3_prepare_v2(db, insertSql, -1, &stmt, NULL);
        [sources enumerateObjectsUsingBlock:^(MTFrameAnimationImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @autoreleasepool{
                //TODO:转换成二进制，存入数据库中
                sqlite3_bind_blob(stmt, 1, NULL, -1, NULL);
            }
        }];
        pv_updateIsLoadCacheResultWithPrefix(db, stmt, prefixName, 1);
    }
    
    sqlite3_finalize(stmt);
    sqlite3_exec(db, "commit", 0, 0, 0);
}

#pragma mark - Private

static BOOL pv_isLoadCacheResultWithPrefix(NSString *prefixName, sqlite3 *db, sqlite3_stmt *stmt) {
    sqlite3_reset(stmt);
    BOOL find = NO;
    const char * querySqlString = [[NSString stringWithFormat:queryCacheListTable, prefixName] UTF8String];
    if (sqlite3_prepare_v2(db, querySqlString, -1, &stmt, NULL) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            find = sqlite3_column_int(stmt, 2) == 1 ? YES : NO;
            break;
        }
    }
    return find;
}

static void pv_updateIsLoadCacheResultWithPrefix(sqlite3 *db, sqlite3_stmt *stmt, NSString *prefixName, int result) {
    sqlite3_reset(stmt);
    const char *updateSql = [[NSString stringWithFormat:updateCacheListTable, result, prefixName] UTF8String];
    int rt = sqlite3_prepare_v2(db, updateSql, -1, &stmt, NULL);
    if (rt != SQLITE_OK) {
        NSLog(@"update cacheList status failed!");
    }
}

@end