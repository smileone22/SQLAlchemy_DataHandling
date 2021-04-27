
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer,Text, Date
import sqlalchemy 

def generate_dsn(path):
    import json
    with open(path+'/config.json') as config_file:
        data = json.load(config_file)
    id= data['username']
    pw = data['password']
    db= data['database']
    return f'postgresql://{id}:{pw}@localhost/{db}'


# return a SQLAlchemy session with dsn as input 
def get_session(dsn):
    engine = create_engine(dsn, echo=True)
    Base = declarative_base()
    Session = sessionmaker(engine)
    session = Session()
    return session

Base = declarative_base()
# a class that represents an eatery
class Eatery(Base):
    __tablename__ = 'eatery'
    eatery_id = Column('eatery_id',Integer, primary_key=True)
    name = Column('name',Text  )
    location =Column('location',Text  )
    park_id =Column('park_id',Text  )
    start_date =Column('start_date',Date)
    end_date =Column('end_date',Date)
    description =Column('description',Text  )
    permit_number =Column('permit_number',Text )
    phone =Column('phone',Text )
    website =Column('website',Text  )
    type_name =Column('type_name',Text )
    def __str__(self):
        return self.__repr__()