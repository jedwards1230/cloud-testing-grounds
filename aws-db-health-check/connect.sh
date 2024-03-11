db_endpoint=$(terraform output -raw db_endpoint)
db_host=$(echo $db_endpoint | cut -d':' -f1)
db_port=$(echo $db_endpoint | cut -d':' -f2)

db_name=$(terraform output -raw db_name)

echo "postgres://adminUser:adminPassword@$db_host:$db_port/$db_name"

psql -h $db_host -p $db_port -U adminUser -d $db_name 
```
