
import os
import base64
import psycopg2
import subprocess
import glob
import time

db = psycopg2.connect(dbname='mydb', user='postgres', host='localhost', password='root')

audio_path = "C:\\Users\\loren\\Desktop\\scheduler_analisi\\env\\audio_patients\\"
libray_path = "C:\\Users\\loren\\Desktop\\scheduler_analisi\\env\\emotion-recognition-using-speech\\"

while True:

    for file in glob.glob(audio_path+"/*.wav"):
        cursor = db.cursor()
        basename = os.path.basename(file)

        split_string = basename.split(".", 1)
        print("analisi..")
        os.chdir(libray_path)
        process = subprocess.Popen(['python3',libray_path+'test.py', file], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = process.communicate()

        out = out.decode('utf-8')
        print(out)
        val = base64.b64encode(bytes(out, 'utf-8'))

        query = "UPDATE public.storico_domande SET humor='" + val.decode('ascii') + "'"  
        
        query += " WHERE id_domanda='" + split_string[0] + "';"


        try:
            cursor.execute(query)
            db.commit()
            print('updated humor')
        except psycopg2.IntegrityError as e:
            print('error humor')
        finally:
            cursor.close()
            os.remove(audio_path + split_string[0] + '_c.' + split_string[1])
        
    print("ATTESA")
    time.sleep(60)