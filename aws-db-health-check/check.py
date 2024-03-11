import json
from dotenv import load_dotenv
import time
import asyncpg  # type: ignore
import subprocess
import asyncio
from getpass import getpass

load_dotenv()


def get_terraform_output():
    process = subprocess.Popen(
        ["terraform", "output", "-json"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd="infra",  # change working directory to infra
    )
    stdout, stderr = process.communicate()
    if stderr:
        print(f"Error: {stderr.decode('utf-8')}")
        exit(1)
    return json.loads(stdout.decode("utf-8"))


terraform_output = get_terraform_output()
db_endpoint = terraform_output["db_endpoint"]["value"]
db_id = terraform_output["db_id"]["value"]
db_name = terraform_output["db_name"]["value"]
db_user = terraform_output["db_user"]["value"]
db_password = terraform_output["db_password"]["value"]

host, port = db_endpoint.split(":")


async def check_database_health():
    conn = None
    try:

        conn = await asyncpg.connect(
            host=host,
            port=port,
            user=db_user,
            password=db_password,
            database=db_name,
            ssl=None,
        )
        await conn.execute("SELECT NOW()")  # Simple query to check the health
        print("Database is healthy")
    except (Exception, asyncpg.exceptions.InterfaceError) as error:
        print("Database is unhealthy", error)
        answer = getpass("Do you want to re-apply the changes? (yes/no) ")
        if answer.lower() == "yes":
            # run terraform from local working dir and re-apply the changes
            process = subprocess.Popen(
                ["terraform", "apply"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                cwd="infra",  # change working directory to infra
            )
            stdout, stderr = process.communicate()
            if stderr:
                print(f"Error: {stderr.decode('utf-8')}")
            else:
                print(f"stdout: {stdout.decode('utf-8')}")
        else:
            exit(1)
    finally:
        if conn is not None:
            await conn.close()


# Run the health check every 1 second
while True:
    asyncio.run(check_database_health())
    time.sleep(1)
