import mysql.connector

db = mysql.connector.connect(
  host="localhost",
  user="root",
  passwd="admin",
  database="crc"
)

cursor = db.cursor()
query = ""\
"SELECT sumofMonths - tamountThis as Previous_Months, tamountThis as This_Month, total - sumofMonths as Next_Months FROM "\
"(SELECT YEAR(r.pickupdate), MONTH(r.pickupdate), sum(r.amount) as tamountThis, "\
"(SELECT sum(amount) FROM carrental WHERE YEAR(carrental.pickupdate) = '2015' ) as total, "\
"(SELECT sum(c.amount) FROM carrental as c WHERE MONTH(c.pickupdate) <= MONTH(r.pickupdate) and YEAR(c.pickupdate) = YEAR(r.pickupdate)) as sumofMonths "\
"FROM carrental as r "\
"WHERE YEAR(r.pickupdate) = '2015' and MONTH(r.pickupdate) = %s) as answer;"
print("Previous Months  This Month  Next Month")
for month in range(1,13):
    cursor.execute(query,(month,))
    try:
        records = cursor.fetchone()
        print("{: >10} {: >13} {: >10}".format(*records)) 
    except TypeError:
        continue