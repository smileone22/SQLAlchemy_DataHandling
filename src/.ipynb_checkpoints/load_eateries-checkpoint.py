from db import * 
import os 
import json
curpath=os.getcwd()
dsn=generate_dsn(curpath) 
session= get_session(dsn)




with open('DPR_Eateries_001.json') as f:
    data = json.load(f)
    full=[]
    for line in data: 
        e= Eatery()
        #e.eatery_id = line['eatery_id']
        e.name = line['name']
        e.location =line['location']
        e.park_id =line['park_id']
        e.start_date =line['start_date']
        e.end_date =line['end_date']
        e.description =line['description']
        e.permit_number =line['permit_number']
        e.phone =line['phone']
        e.website =line['website']
        e.type_name =line['type_name']
        full.append(e)
    session.add_all(full)   
    session.commit()
