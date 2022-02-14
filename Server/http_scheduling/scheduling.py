import time
import jwt
import datetime
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()
questions = db.collection('questions')
zzZ = 15
questions_to_answer = db.collection('questions_to_answer')


while True:
    now = datetime.datetime.now()
    data_oggi = now.strftime("%Y-%m-%d %H:%M")
    # if now.strftime("%H:%M") >= "21:00":
    #     time.sleep(39600)
    print(now)
    # results = domande.order_by(u'ora_domanda', direction=firestore.Query.DESCENDING).where('data_domanda', '==', data_oggi).stream()
    results = questions.order_by('data_domanda', direction=firestore.Query.DESCENDING).where('data_domanda', '<=', data_oggi).get()
    for value in results:
        if value.exists:
            print(value.to_dict())

            questions_to_answer.add({
                
                'cod_fiscale_dottore' : value.to_dict()["cod_fiscale_dottore"],
                'cod_fiscale_paziente': value.to_dict()["cod_fiscale_paziente"],
                'cognome': value.to_dict()["cognome"],
                'nome': value.to_dict()["nome"],
                'letto': value.to_dict()["letto"],
                'data_domanda':  value.to_dict()["data_domanda"],
                'ripeti': value.to_dict()["ripeti"],
                'testo_domanda': value.to_dict()["testo_domanda"]

            })
            if value.to_dict()["ripeti"] != 0:
                date1 = datetime.datetime.strptime(value.to_dict()["data_domanda"], '%Y-%m-%d %H:%M')
                new_date = date1 + datetime.timedelta(days=1)
                new_date = new_date.strftime("%Y-%m-%d %H:%M")
                questions.add({
                    'cod_fiscale_dottore' : value.to_dict()["cod_fiscale_dottore"],
                    'cod_fiscale_paziente': value.to_dict()["cod_fiscale_paziente"],
                    'cognome': value.to_dict()["cognome"],
                    'nome': value.to_dict()["nome"],
                    'letto': value.to_dict()["letto"],
                    'data_domanda':  new_date,
                    'ripeti': value.to_dict()["ripeti"]-1,
                    'testo_domanda': value.to_dict()["testo_domanda"]
                })
            questions.document(value.id).delete()
            


    time.sleep(zzZ)
