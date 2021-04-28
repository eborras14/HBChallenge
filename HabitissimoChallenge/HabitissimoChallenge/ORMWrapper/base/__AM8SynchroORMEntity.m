//
//  __AM8SynchroORMEntity.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "__AM8SynchroORMEntity.h"

@implementation __AM8SynchroORMEntity



#pragma mark SqlGeneration

-(NSString *) getDeleteSql {
    RecordTypeAction laction = self.action;
    
    NSString *sql;

    if(laction == RecordTypeInsert){
        sql = [AM8SqlGenerator getSQLDelete:[NSString stringWithFormat:_subguionTable_s,_subguion,[self tableName],_subguion_s] filters:[NSMutableArray arrayWithObject:[NSString stringWithFormat:_idEqualTo, self.Id]]];
    }
    else{
        self.action = RecordTypeDelete;
        NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
        sql = [AM8SqlGenerator getSQLInsertUpdate:[NSString stringWithFormat:_subguionTable_s,_subguion,[self tableName],_subguion_s] fieldsAndValues:fieldsAndValues];
    }
    
    return sql;
}

-(NSString *) getUpdateSql {
    self.action = (!self.idServer ? RecordTypeInsert : RecordTypeUpdate);
    NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
    
    /* Actions according Salesforce framework
     if idServer != 0
     this record comes from Salesforce => update in Salesforce
     else
     this record will be NEW on Salesforce => insert in Salesforce
     */
    
    if (!self.Id || self.Id==0) {
        [fieldsAndValues setValue:[NSNull null] forKey:_suffixIDLower];
    }
    
    return [AM8SqlGenerator getSQLInsertUpdate:[NSString stringWithFormat:_subguionTable_s,_subguion,[self tableName],_subguion_s] fieldsAndValues:fieldsAndValues];
}

-(NSArray *) getDeleteSqlArray {
    RecordTypeAction laction = self.action;
    
    NSArray *sqlArray;
    
    if(laction == RecordTypeInsert){
        sqlArray = @[[AM8SqlGenerator getSQLDelete:[NSString stringWithFormat:_subguionTable_s,_subguion,[self tableName],_subguion_s] filters:[NSMutableArray arrayWithObject:[NSString stringWithFormat:_idEqualTo, self.Id]]]];
    }
    else{
        self.action = RecordTypeDelete;
        NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
        sqlArray = @[[AM8SqlGenerator getSQLInsertUpdate:[NSString stringWithFormat:_subguionTable_s,_subguion,[self tableName],_subguion_s] fieldsAndValues:fieldsAndValues]];
    }
    
    return sqlArray;
}

-(NSArray *) getUpdateSqlArray {
    self.action = (!self.idServer ? RecordTypeInsert : RecordTypeUpdate);
	NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
    
    /* Actions according Salesforce framework
     if idServer != 0
     this record comes from Salesforce => update in Salesforce
     else
     this record will be NEW on Salesforce => insert in Salesforce
     */
	
	if (!self.Id || self.Id==0) {
		[fieldsAndValues setValue:[NSNull null] forKey:_suffixIDLower];
	}
    
	return @[[AM8SqlGenerator getSQLInsertUpdate:[NSString stringWithFormat:_subguionTable_s,_subguion,[self tableName],_subguion_s] fieldsAndValues:fieldsAndValues],
             fieldsAndValues];
}

@end
